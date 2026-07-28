#!/bin/bash
# =============================================================================
# SysWatch Agent - Script de instalación
# Uso: curl -sSL https://syswatch.com/install.sh | bash -s -- --api-key KEY
# =============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Variables por defecto
API_KEY=""
SERVER_NAME="VPS-$(hostname)"
BACKEND_URL="wss://syswatch.onrender.com/ws/agent"
INSTALL_DIR="/opt/syswatch-agent"
REPO_URL="https://github.com/tu-usuario/syswatch-agent.git"

# -----------------------------------------------------------------------------
# Parsear argumentos
# -----------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --api-key)
            API_KEY="$2"
            shift 2
            ;;
        --server-name)
            SERVER_NAME="$2"
            shift 2
            ;;
        --backend-url)
            BACKEND_URL="$2"
            shift 2
            ;;
        --help)
            echo "Uso: install.sh --api-key sw_xxx [--server-name Nombre] [--backend-url ws://...]"
            exit 0
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${NC}"
            exit 1
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Validar API key
# -----------------------------------------------------------------------------
if [[ -z "$API_KEY" ]]; then
    echo -e "${RED}Error: --api-key es requerida${NC}"
    echo "Uso: install.sh --api-key sw_xxx"
    exit 1
fi

echo -e "${GREEN}🚀 Instalando SysWatch Agent...${NC}"
echo "Servidor: $SERVER_NAME"
echo "API Key: ${API_KEY:0:12}..."

# -----------------------------------------------------------------------------
# Detectar distro e instalar dependencias
# -----------------------------------------------------------------------------
echo -e "${YELLOW}📦 Instalando dependencias...${NC}"

if command -v apt-get &> /dev/null; then
    # Debian/Ubuntu
    apt-get update -qq
    apt-get install -y -qq python3 python3-pip python3-venv git
elif command -v yum &> /dev/null; then
    # CentOS/RHEL
    yum install -y -q python3 python3-pip git
elif command -v apk &> /dev/null; then
    # Alpine
    apk add --no-cache python3 py3-pip git
else
    echo -e "${RED}Distro no soportada${NC}"
    exit 1
fi

# -----------------------------------------------------------------------------
# Descargar agente
# -----------------------------------------------------------------------------
echo -e "${YELLOW}⬇️  Descargando agente...${NC}"

if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
fi

git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"

# -----------------------------------------------------------------------------
# Crear entorno virtual e instalar
# -----------------------------------------------------------------------------
echo -e "${YELLOW}🔧 Configurando entorno...${NC}"

cd "$INSTALL_DIR"
python3 -m venv venv
source venv/bin/activate
pip install -q -r requirements.txt

# -----------------------------------------------------------------------------
# Crear archivo de configuración
# -----------------------------------------------------------------------------
echo -e "${YELLOW}⚙️  Configurando agente...${NC}"

cat > "$INSTALL_DIR/.env" << EOF
SYSWATCH_API_KEY=$API_KEY
SYSWATCH_BACKEND_URL=$BACKEND_URL
SYSWATCH_INTERVAL=5
EOF

# -----------------------------------------------------------------------------
# Crear servicio systemd
# -----------------------------------------------------------------------------
echo -e "${YELLOW}📝 Creando servicio...${NC}"

cat > /etc/systemd/system/syswatch-agent.service << EOF
[Unit]
Description=SysWatch Agent - Monitoreo de servidor
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
Environment=PATH=$INSTALL_DIR/venv/bin
ExecStart=$INSTALL_DIR/venv/bin/python $INSTALL_DIR/agent.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# -----------------------------------------------------------------------------
# Iniciar servicio
# -----------------------------------------------------------------------------
echo -e "${YELLOW}▶️  Iniciando servicio...${NC}"

systemctl daemon-reload
systemctl enable syswatch-agent
systemctl start syswatch-agent

# -----------------------------------------------------------------------------
# Verificar
# -----------------------------------------------------------------------------
sleep 2

if systemctl is-active --quiet syswatch-agent; then
    echo -e "${GREEN}✅ SysWatch Agent instalado y corriendo!${NC}"
    echo ""
    echo "Comandos útiles:"
    echo "  systemctl status syswatch-agent   # Ver estado"
    echo "  journalctl -u syswatch-agent -f   # Ver logs"
    echo "  systemctl stop syswatch-agent     # Detener"
    echo ""
    echo -e "${GREEN}🎉 Tu servidor '$SERVER_NAME' está siendo monitoreado${NC}"
else
    echo -e "${RED}❌ Error iniciando el servicio${NC}"
    echo "Revisa: journalctl -u syswatch-agent -n 50"
    exit 1
fi