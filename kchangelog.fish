# kchangelog fish completion script

# Disable file completion by default
for cmd in kchangelog ./kchangelog
    complete -c $cmd -f

    # Options
    complete -c $cmd -l cve -d "Show only lines containing CVE identifiers"
    complete -c $cmd -l open -d "Pipe output into PAGER"
    complete -c $cmd -l diff -d "Show diff against last read version"
    complete -c $cmd -l last -x -a "1 3 5 10 20" -d "Limit to N entries"
    complete -c $cmd -l list-subs -d "List current subscriptions"
    complete -c $cmd -l check -d "Check active subscriptions"
    complete -c $cmd -l install-service -d "Install systemd timer"
    complete -c $cmd -l remove-service -d "Uninstall systemd timer"
    complete -c $cmd -l list-available -d "List all available kernel versions"
    complete -c $cmd -l color -x -a "always never auto" -d "Specify when to colorize output"
    complete -c $cmd -l grep -x -d "Filter changelog by keyword"
    complete -c $cmd -l json -d "Output changelog in structured JSON"
    complete -c $cmd -s h -l help -d "Display help menu"
    complete -c $cmd -s v -l version -d "Display version"
end

# Dynamic versions completion
function __fish_kchangelog_kernels
    apt-cache pkgnames linux-image- 2>/dev/null \
        | grep -E '^linux-image-[0-9]' \
        | sed -E 's/^linux-image-//; s/-(generic|dbgsym|lowlatency|aws|gcp|azure|oem|oracle|ibm|gke|unsigned)//g' \
        | grep -E '^[0-9]' \
        | sort -V -u
end

for cmd in kchangelog ./kchangelog
    complete -c $cmd -l subscribe -x -a "active (__fish_kchangelog_kernels)" -d "Subscribe to kernel version"
    complete -c $cmd -l unsubscribe -x -a "active (__fish_kchangelog_kernels)" -d "Unsubscribe from kernel version"

    # Suggest versions for normal arguments
    complete -c $cmd -n "not __fish_seen_subcommand_from --subscribe --unsubscribe --last --color --grep" -a "(__fish_kchangelog_kernels)"
end
