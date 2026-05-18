# kchangelog bash completion script

_kchangelog() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--cve --open --diff --last --subscribe --unsubscribe --list-subs --check --install-service --remove-service -h --help -v --version -l --list-available"

    case "${prev}" in
        --subscribe|--unsubscribe)
            local kernels
            kernels=$(apt-cache pkgnames linux-image- 2>/dev/null \
                | grep -E '^linux-image-[0-9]' \
                | sed -E 's/^linux-image-//; s/-(generic|dbgsym|lowlatency|aws|gcp|azure|oem|oracle|ibm|gke|unsigned)//g' \
                | grep -E '^[0-9]' \
                | sort -V -u)
            COMPREPLY=( $(compgen -W "active ${kernels}" -- "${cur}") )
            return 0
            ;;
        --last)
            COMPREPLY=( $(compgen -W "1 3 5 10 20 50" -- "${cur}") )
            return 0
            ;;
    esac

    if [[ ${cur} == -* ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
        return 0
    else
        local kernels
        kernels=$(apt-cache pkgnames linux-image- 2>/dev/null \
            | grep -E '^linux-image-[0-9]' \
            | sed -E 's/^linux-image-//; s/-(generic|dbgsym|lowlatency|aws|gcp|azure|oem|oracle|ibm|gke|unsigned)//g' \
            | grep -E '^[0-9]' \
            | sort -V -u)
        COMPREPLY=( $(compgen -W "${kernels}" -- "${cur}") )
        return 0
    fi
}
complete -F _kchangelog kchangelog
