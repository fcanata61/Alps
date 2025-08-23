#!/bin/bash
# Funções utilitárias para ALPS

spinner() {
    # Spinner simples para processos longos
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid &>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

log() {
    local msg="$1"
    local level="${2:-INFO}"
    local logfile="$LOG_DIR/alps.log"
    local color="$RESET"
    case "$level" in
        INFO) color="$BLUE";;
        WARN) color="$YELLOW";;
        ERROR) color="$RED";;
        SUCCESS) color="$GREEN";;
    esac
    echo -e "$(date '+%F %T') [$level] $msg" | tee -a "$logfile"
    echo -e "${color}$msg${RESET}"
}

sha256_check() {
    local file="$1"
    local hash_expected="$2"
    echo "${hash_expected}  ${file}" | sha256sum -c - >/dev/null 2>&1
    return $?
}
