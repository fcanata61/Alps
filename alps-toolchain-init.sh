#!/bin/bash
# ALPS Toolchain Init Script
# Automatiza o download, descompactação e build do toolchain

set -e

# Carregar perfil ALPS
source ~/.alps_profile

# Lista de pacotes do toolchain na ordem das dependências
TOOLCHAIN_PKGS=(binutils gcc glibc make)

echo "=== Inicializando toolchain ALPS ==="
mkdir -p "$WORKDIR"
mkdir -p "$DESTDIR"
mkdir -p "$INSTALLDIR"
mkdir -p "$LOG_DIR"

download_and_unpack() {
    local pkg="$1"
    local url="$2"
    local work="$WORKDIR/$pkg"

    mkdir -p "$work"
    cd "$work"

    echo ">> Baixando $pkg..."
    curl -LO "$url"

    local file="$(basename "$url")"
    echo ">> Descompactando $file..."
    case "$file" in
        *.tar.gz|*.tgz) tar -xzf "$file" ;;
        *.tar.xz)       tar -xJf "$file" ;;
        *.tar.bz2)      tar -xjf "$file" ;;
        *) echo "Formato desconhecido: $file"; exit 1 ;;
    esac

    # Retornar diretório do source
    local src_dir=$(find . -maxdepth 1 -type d ! -name "." | head -n1)
    echo "$work/$src_dir"
}

# Loop para cada pacote do toolchain
for pkg in "${TOOLCHAIN_PKGS[@]}"; do
    url="${DEP_DB_URL[$pkg]}"
    if [ -z "$url" ]; then
        echo "URL não encontrada para $pkg"
        exit 1
    fi

    echo "=== Preparando pacote $pkg ==="
    SRC_DIR=$(download_and_unpack "$pkg" "$url")

    # Executar hooks pré-build
    HOOK_PRE="$SRC_DIR/hooks/pre-build"
    if [ -d "$HOOK_PRE" ]; then
        for hook in "$HOOK_PRE"/*.sh; do
            [ -e "$hook" ] || continue
            echo ">> Executando hook pré-build: $(basename $hook)"
            bash "$hook"
        done
    fi

    # Executar build.sh
    BUILD_SCRIPT="$SRC_DIR/build.sh"
    if [ -f "$BUILD_SCRIPT" ]; then
        echo ">> Compilando $pkg"
        bash "$BUILD_SCRIPT"
    else
        echo ">> build.sh não encontrado para $pkg"
        exit 1
    fi

    # Executar hooks pós-build
    HOOK_POST="$SRC_DIR/hooks/post-build"
    if [ -d "$HOOK_POST" ]; then
        for hook in "$HOOK_POST"/*.sh; do
            [ -e "$hook" ] || continue
            echo ">> Executando hook pós-build: $(basename $hook)"
            bash "$hook"
        done
    fi

    echo "=== Pacote $pkg concluído ==="
done

echo "=== Toolchain ALPS finalizado ==="
echo "Instalado em: $DESTDIR"
