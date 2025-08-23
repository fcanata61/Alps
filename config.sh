#!/bin/bash
# ALPS Config Loader
# Carrega variáveis do .profile e define padrões

PROFILE="$HOME/.alps_profile"

if [ -f "$PROFILE" ]; then
    source "$PROFILE"
fi

# Diretórios padrão
WORKDIR="${WORKDIR:-$HOME/build}"
DESTDIR="${DESTDIR:-/tmp/alps-install}"
INSTALLDIR="${INSTALLDIR:-/usr/local}"
LOG_DIR="${LOG_DIR:-$HOME/alps-logs}"

# Comportamento
TOOCHAIN_BUILD="${TOOCHAIN_BUILD:-0}"
ENABLE_COLOR="${ENABLE_COLOR:-1}"
ENABLE_SPINNER="${ENABLE_SPINNER:-1}"
CHECK_DEPS_ONLY="${CHECK_DEPS_ONLY:-0}"
BUILD_ONLY="${BUILD_ONLY:-0}"

# Segurança
SHA256_KEY="${SHA256_KEY:-dummy_key}"

# Git
GIT_REPO="${GIT_REPO:-$HOME/linux-system}"

# Cores
if [ "$ENABLE_COLOR" -eq 1 ]; then
    RED="\e[31m"
    GREEN="\e[32m"
    YELLOW="\e[33m"
    BLUE="\e[34m"
    RESET="\e[0m"
else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    RESET=""
fi

mkdir -p "$WORKDIR" "$DESTDIR" "$LOG_DIR"
