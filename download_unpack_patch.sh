#!/bin/bash
# ALPS: download, descompactação e patch

download_source() {
    local url="$1"
    local dest="$WORKDIR"
    local file=$(basename "$url")

    log "Baixando $file..." INFO
    curl -L -o "$dest/$file" "$url" &
    local pid=$!
    $ENABLE_SPINNER && spinner $pid
    wait $pid

    log "Download concluído: $file" SUCCESS
    echo "$dest/$file"
}

unpack_source() {
    local file="$1"
    local dest="$WORKDIR/$(basename "$file" | sed 's/\.[^.]*$//')"

    mkdir -p "$dest"

    case "$file" in
        *.tar.gz|*.tgz) tar -xzf "$file" -C "$dest" --strip-components=1;;
        *.tar.bz2|*.tbz2) tar -xjf "$file" -C "$dest" --strip-components=1;;
        *.tar.xz|*.txz) tar -xJf "$file" -C "$dest" --strip-components=1;;
        *.zip) unzip -q "$file" -d "$dest";;
        *) log "Formato de arquivo não suportado: $file" ERROR; return 1;;
    esac

    log "Descompactação concluída: $dest" SUCCESS
    echo "$dest"
}

apply_patch() {
    local src_dir="$1"
    local patch_dir="$src_dir/patches"
    if [ -d "$patch_dir" ]; then
        for p in "$patch_dir"/*.patch; do
            [ -e "$p" ] || continue
            log "Aplicando patch: $(basename "$p")" INFO
            patch -d "$src_dir" -p1 < "$p" &
            local pid=$!
            $ENABLE_SPINNER && spinner $pid
            wait $pid
        done
        log "Patches aplicados com sucesso" SUCCESS
    fi
}
