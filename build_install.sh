#!/bin/bash
# ALPS: Build e instalação

build_package() {
    local src_dir="$1"

    # Checar se existe script de build
    if [ ! -f "$src_dir/build.sh" ]; then
        log "Nenhum script build.sh encontrado em $src_dir" ERROR
        return 1
    fi

    log "Iniciando compilação em $src_dir" INFO
    cd "$src_dir" || return 1
    ./build.sh &
    local pid=$!
    $ENABLE_SPINNER && spinner $pid
    wait $pid

    log "Compilação concluída: $src_dir" SUCCESS
}

install_package() {
    local src_dir="$1"
    local dest="${DESTDIR:-$INSTALLDIR}"

    if [ "$BUILD_ONLY" -eq 1 ]; then
        log "Build-only mode: pulando instalação" INFO
        return 0
    fi

    log "Instalando pacote em $dest" INFO
    cd "$src_dir" || return 1

    # Suporte genérico, destdir-aware
    if [ -f "Makefile" ]; then
        make DESTDIR="$dest" install &
        local pid=$!
        $ENABLE_SPINNER && spinner $pid
        wait $pid
    else
        log "Instalação manual: copiando arquivos para $dest" WARN
        cp -r * "$dest/"
    fi

    log "Instalação concluída: $dest" SUCCESS
}
