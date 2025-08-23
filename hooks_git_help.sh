#!/bin/bash
# ALPS: Hooks, git sync e help

run_hooks() {
    local src_dir="$1"
    local hook_type="$2"  # pre-build, post-build, pre-install, post-install
    local hooks_dir="$src_dir/hooks/$hook_type"
    if [ -d "$hooks_dir" ]; then
        for hook in "$hooks_dir"/*.sh; do
            [ -e "$hook" ] || continue
            log "Executando hook $hook_type: $(basename "$hook")" INFO
            bash "$hook"
        done
    fi
}

git_sync() {
    if [ "$TOOCHAIN_BUILD" -eq 1 ]; then
        log "Toolchain mode: pulando git sync" INFO
        return
    fi

    cd "$GIT_REPO" || return
    git add . &&
    git commit -m "ALPS sync: $(date '+%F %T')" &&
    git push origin main &
    local pid=$!
    $ENABLE_SPINNER && spinner $pid
    wait $pid
    log "Git sincronizado com sucesso" SUCCESS
}

alps_help() {
    cat <<EOF
ALPS - Advanced Linux Package Source Builder

Comandos principais:
    alps build <pkg>          - Baixa, descompacta, patch, compila e instala
    alps build-only <pkg>     - Compila sem instalar
    alps check-deps <pkg>     - Verifica dependências recursivamente
    alps search <term>        - Busca pacotes disponíveis
    alps info <pkg>           - Informações do pacote
    alps remove <pkg>         - Remove pacote (destdir-aware)
    alps world-rebuild        - Recompila todo o sistema
    alps help                 - Mostra este help

Variáveis em .profile:
    WORKDIR, DESTDIR, INSTALLDIR, TOOCHAIN_BUILD, ENABLE_COLOR
    ENABLE_SPINNER, CHECK_DEPS_ONLY, BUILD_ONLY, SHA256_KEY, GIT_REPO

EOF
}
