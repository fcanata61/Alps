# ~/.alps_profile
# Configurações globais para ALPS (Advanced Linux Package Source Builder)

########################################
# Diretórios
########################################
WORKDIR="$HOME/build"              # Diretório de trabalho para baixar e compilar pacotes
DESTDIR="/tmp/alps-install"        # Diretório para instalação temporária
INSTALLDIR="/usr/local"            # Diretório final de instalação
LOG_DIR="$HOME/alps-logs"          # Diretório para logs do ALPS

########################################
# Comportamento
########################################
TOOCHAIN_BUILD=0        # 1 = apenas construir toolchain (ignora logs/git)
ENABLE_COLOR=1          # 1 = mensagens coloridas, 0 = sem cor
ENABLE_SPINNER=1        # 1 = spinner em operações longas, 0 = desliga
CHECK_DEPS_ONLY=0       # 1 = apenas checa dependências
BUILD_ONLY=0            # 1 = build sem instalar

########################################
# Segurança
########################################
SHA256_KEY="minha_chave_ativa"  # Chave para verificação de pacotes

########################################
# Git
########################################
GIT_REPO="$HOME/linux-system"  # Repositório para versionamento do sistema

########################################
# Pacotes e Dependências
########################################

# Declaração de dependências (pacote => "lista de dependências")
declare -A DEP_DB
DEP_DB[hello]=""
DEP_DB[coreutils]=""
DEP_DB[glibc]=""
DEP_DB[binutils]=""
DEP_DB[gcc]="binutils glibc"
DEP_DB[make]="gcc"
DEP_DB[linux-kernel]="gcc make"

# URLs dos pacotes (pacote => URL do source)
declare -A DEP_DB_URL
DEP_DB_URL[hello]="https://ftp.gnu.org/gnu/hello/hello-2.12.tar.gz"
DEP_DB_URL[coreutils]="https://ftp.gnu.org/gnu/coreutils/coreutils-9.2.tar.xz"
DEP_DB_URL[glibc]="https://ftp.gnu.org/gnu/libc/glibc-2.39.tar.xz"
DEP_DB_URL[binutils]="https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz"
DEP_DB_URL[gcc]="https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
DEP_DB_URL[make]="https://ftp.gnu.org/gnu/make/make-4.4.tar.gz"
DEP_DB_URL[linux-kernel]="https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.6.tar.xz"

########################################
# Variáveis adicionais
########################################
# Número de threads para make (opcional)
ALPS_MAKE_THREADS=$(nproc)

# Ativa log detalhado por padrão
ALPS_LOG_LEVEL="INFO"

# Configurações de hooks globais (opcional)
ALPS_HOOKS_ENABLED=1  # 1 = permite hooks, 0 = desativa hooks globalmente
