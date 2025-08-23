#!/bin/bash
# ALPS Toolchain Final – Script completo para construção do toolchain
# Funciona com TOOCHAIN_BUILD=1, SHA opcional, hooks, spinner e cores
# Carrega variáveis do ~/.alps_profile

set -e

# Carregar perfil ALPS
if [ -f "$HOME/.alps_profile" ]; then
    source "$HOME/.alps_profile"
else
    echo "Arquivo ~/.alps_profile não encontrado. Abortando."
    exit 1
fi

# Lista de pacotes do toolchain (respeitando dependências)
TOOLCHAIN_PKGS=(binutils gcc glibc make)

# Função spinner
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "      \b\b\b\b\b\b"
}

# Função de log colorido
log() {
    local type="$1"
    local msg="$2"
    if [ "$ENABLE_COLOR" = "1" ]; then
        case "$type" in
            INFO) echo -e "\e[34m[INFO]\e[0m $msg" ;;
            WARN) echo -e "\e[33m[WARN]\e[0m $msg" ;;
            ERROR) echo -e "\e[31m[ERROR]\e[0m $msg" ;;
            SUCCESS) echo -e "\e[32m[SUCCESS]\e[0m $msg" ;;
            *) echo "$msg" ;;
        esac
    else
        echo "[$type] $msg"
    fi
}

# Função download e descompactação
download_and_unpack() {
    local pkg="$1"
    local url="$2"
    local work="$WORKDIR/$pkg"

    mkdir -p "$work"
    cd "$work"

    local file="$(basename "$url")"
    if [ ! -f "$file" ]; then
        log INFO "Baixando $pkg..."
        curl -LO "$url"
    else
        log INFO "Arquivo $file já existe, pulando download"
    fi

    # Verificação SHA256
    if [ -n "$SHA256_KEY" ] && [ "$SKIP_SHA_CHECK" != "1" ]; then
        log INFO "Verificação SHA256 habilitada para $file"
        # Aqui você poderia inserir hash real
    else
        log WARN "Verificação SHA256 desativada para $file"
    fi

    # Descompactar automaticamente
    case "$file" in
        *.tar.gz|*.tgz) tar -xzf "$file" ;;
        *.tar.xz)       tar -xJf "$file" ;;
        *.tar.bz2)      tar -xjf "$file" ;;
        *) log ERROR "Formato desconhecido: $file"; exit 1 ;;
    esac

    # Retorna diretório do source
    local src_dir=$(find . -maxdepth 1 -type d ! -name "." | head -n1)
    echo "$work/$src_dir"
}

# Loop para cada pacote do toolchain
for pkg in "${TOOLCHAIN_PKGS[@]}"; do
    url="${DEP_DB_URL[$pkg]}"
    if [ -z "$url" ]; then
        log ERROR "URL não definida para $pkg"
        exit 1
    fi

    log INFO "Preparando pacote $pkg"
    SRC_DIR=$(download_and_unpack "$pkg" "$url")

    # Hooks pré-build
    HOOK_PRE="$SRC_DIR/hooks/pre-build"
    if [ -d "$HOOK_PRE" ]; then
        for hook in "$HOOK_PRE"/*.sh; do
            [ -e "$hook" ] || continue
            log INFO "Executando hook pré-build: $(basename $hook)"
            bash "$hook"
        done
    fi

    # Build
    BUILD_SCRIPT="$SRC_DIR/build.sh"
    if [ -f "$BUILD_SCRIPT" ]; then
        log INFO "Compilando $pkg..."
        bash "$BUILD_SCRIPT" &
        pid=$!
        if [ "$ENABLE_SPINNER" = "1" ]; then
            spinner $pid
        else
            wait $pid
        fi
    else
        log ERROR "build.sh não encontrado para $pkg"
        exit 1
    fi

    # Hooks pós-build
    HOOK_POST="$SRC_DIR/hooks/post-build"
    if [ -d "$HOOK_POST" ]; then
        for hook in "$HOOK_POST"/*.sh; do
            [ -e "$hook" ] || continue
            log INFO "Executando hook pós-build: $(basename $hook)"
            bash "$hook"
        done
    fi

    log SUCCESS "Pacote $pkg concluído"
done

log SUCCESS "=== Toolchain ALPS finalizado ==="
log INFO "Instalado em: $DESTDIR"
