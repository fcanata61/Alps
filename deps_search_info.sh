#!/bin/bash
# ALPS: Dependências, busca e informações

declare -A DEP_DB
# Exemplo: DEP_DB[pkg]="dep1 dep2 dep3"

check_dependencies() {
    local pkg="$1"
    local missing=0
    for dep in ${DEP_DB[$pkg]}; do
        if ! alps_is_installed "$dep"; then
            log "Dependência ausente: $dep" WARN
            missing=1
        fi
    done
    return $missing
}

resolve_dependencies_recursive() {
    local pkg="$1"
    local resolved=()
    local unresolved=("$pkg")

    while [ ${#unresolved[@]} -gt 0 ]; do
        local current="${unresolved[0]}"
        unresolved=("${unresolved[@]:1}")

        if ! check_dependencies "$current"; then
            for dep in ${DEP_DB[$current]}; do
                unresolved+=("$dep")
            done
        fi
        resolved+=("$current")
    done

    echo "${resolved[@]}"
}

alps_is_installed() {
    local pkg="$1"
    # Checagem simples via diretório em INSTALLDIR
    [ -d "$INSTALLDIR/$pkg" ]
}

search_package() {
    local term="$1"
    log "Buscando pacotes que correspondem a '$term'..." INFO
    for pkg in "${!DEP_DB[@]}"; do
        if [[ "$pkg" == *"$term"* ]]; then
            echo "$pkg -> Dependências: ${DEP_DB[$pkg]}"
        fi
    done
}

package_info() {
    local pkg="$1"
    if [ -d "$INSTALLDIR/$pkg" ]; then
        echo "Pacote: $pkg"
        echo "Local: $INSTALLDIR/$pkg"
        echo "Dependências: ${DEP_DB[$pkg]}"
    else
        echo "Pacote $pkg não está instalado."
    fi
}
