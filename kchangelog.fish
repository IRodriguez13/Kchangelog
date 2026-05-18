# kchangelog fish completion script

# Disable file completion by default
complete -c kchangelog -f

# Options
complete -c kchangelog -l cve -d "Show only lines containing CVE identifiers"
complete -c kchangelog -l open -d "Pipe output into PAGER"
complete -c kchangelog -l diff -d "Show diff against last read version"
complete -c kchangelog -l last -x -a "1 3 5 10 20" -d "Limit to N entries"
complete -c kchangelog -l list-subs -d "List current subscriptions"
complete -c kchangelog -l check -d "Check active subscriptions"
complete -c kchangelog -l install-service -d "Install systemd timer"
complete -c kchangelog -l remove-service -d "Uninstall systemd timer"
complete -c kchangelog -l list-available -d "List all available kernel versions"
complete -c kchangelog -l color -x -a "always never auto" -d "Specify when to colorize output"
complete -c kchangelog -l grep -x -d "Filter changelog by keyword"
complete -c kchangelog -l json -d "Output changelog in structured JSON"
complete -c kchangelog -s h -l help -d "Display help menu"
complete -c kchangelog -s v -l version -d "Display version"

# Dynamic versions completion
function __fish_kchangelog_kernels
    apt-cache pkgnames linux-image- 2>/dev/null \
        | grep -E '^linux-image-[0-9]' \
        | sed -E 's/^linux-image-//; s/-(generic|dbgsym|lowlatency|aws|gcp|azure|oem|oracle|ibm|gke|unsigned)//g' \
        | grep -E '^[0-9]' \
        | sort -V -u
end

complete -c kchangelog -l subscribe -x -a "active (__fish_kchangelog_kernels)" -d "Subscribe to kernel version"
complete -c kchangelog -l unsubscribe -x -a "active (__fish_kchangelog_kernels)" -d "Unsubscribe from kernel version"

# Suggest versions for normal arguments
complete -c kchangelog -n "not __fish_seen_subcommand_from --subscribe --unsubscribe --last --color --grep" -a "(__fish_kchangelog_kernels)"
