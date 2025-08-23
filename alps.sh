#!/bin/bash
# ALPS - Advanced Linux Package Source Builder
# Script principal que integra todos os módulos

# 1. Carregar módulos
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/config.sh"
source "$DIR/utils.sh"
source "$DIR/download_unpack_patch.sh"
source "$DIR/build_install.sh"
source "$DIR/deps_search_info.sh"
source "$DIR/hooks_git_help.sh"

# 2. Função principal para execução
alps_main() {
    local cmd="$1"
    local pkg="$2"
    local url="$3"

    case "$cmd" in
        build)
            if [ -z "$pkg" ] || [ -z "$url" ]; then
                log "Uso: alps build <pkg> <url>" ERROR
                return 1
            fi
            run_hooks "$pkg" "pre-build"
            SRC_FILE=$(download_source "$url")
            SRC_DIR=$(unpack_source "$SRC_FILE")
            apply_patch "$SRC_DIR"
            if [ "$CHECK_DEPS_ONLY" -eq 1 ]; then
                log "Check-deps mode: verificando dependências de $pkg" INFO
                resolve_dependencies_recursive "$pkg"
            else
                build_package "$SRC_DIR"
                run_hooks "$pkg" "post-build"
                install_package "$SRC_DIR"
                run_hooks "$pkg" "post-install"
                git_sync
            fi
            ;;
        build-only)
            if [ -z "$pkg" ] || [ -z "$url" ]; then
                log "Uso: alps build-only <pkg> <url>" ERROR
                return 1
            fi
            run_hooks "$pkg" "pre-build"
            SRC_FILE=$(download_source "$url")
            SRC_DIR=$(unpack_source "$SRC_FILE")
            apply_patch "$SRC_DIR"
            build_package "$SRC_DIR"
            run_hooks "$pkg" "post-build"
            ;;
        check-deps)
            if [ -z "$pkg" ]; then
                log "Uso: alps check-deps <pkg>" ERROR
                return 1
            fi
            log "Verificando dependências de $pkg..." INFO
            resolve_dependencies_recursive "$pkg"
            ;;
        search)
            if [ -z "$pkg" ]; then
                log "Uso: alps search <termo>" ERROR
                return 1
            fi
            search_package "$pkg"
            ;;
        info)
            if [ -z "$pkg" ]; then
                log "Uso: alps info <pkg>" ERROR
                return 1
            fi
            package_info "$pkg"
            ;;
        remove)
            if [ -z "$pkg" ]; then
                log "Uso: alps remove <pkg>" ERROR
                return 1
            fi
            log "Removendo pacote $pkg..." INFO
            rm -rf "$DESTDIR/$pkg" "$INSTALLDIR/$pkg"
            log "Pacote $pkg removido" SUCCESS
            ;;
        world-rebuild)
            log "Iniciando recompilação de todo o sistema..." INFO
            for pkg in "${!DEP_DB[@]}"; do
                log "Reconstruindo $pkg" INFO
                # Supondo que URLs estejam definidas em DEP_DB ou outra variável
                url="${DEP_DB_URL[$pkg]}"
                [ -n "$url" ] || continue
                SRC_FILE=$(download_source "$url")
                SRC_DIR=$(unpack_source "$SRC_FILE")
                apply_patch "$SRC_DIR"
                build_package "$SRC_DIR"
                install_package "$SRC_DIR"
            done
            git_sync
            ;;
        help|--help|-h)
            alps_help
            ;;
        *)
            log "Comando desconhecido: $cmd" ERROR
            alps_help
            return 1
            ;;
    esac
}

# 3. Executar função principal
alps_main "$@"
