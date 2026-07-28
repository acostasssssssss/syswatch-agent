
1. Preparar entorno
bash
cd syswatch-agent
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

pip install -r requirements.txt
2. Configurar variables
bash
# Linux/Mac
export SYSWATCH_API_KEY="sw_tu_api_key_aqui"
export SYSWATCH_BACKEND_URL="ws://127.0.0.1:8000/ws/agent"

# Windows
set SYSWATCH_API_KEY=sw_tu_api_key_aqui
set SYSWATCH_BACKEND_URL=ws://127.0.0.1:8000/ws/agent
3. Ejecutar
bash
python agent.py
📄 agent/requirements.txt
plain
psutil==6.0.0
websockets==12.0
📄 agent/README.md
Markdown
Copy
Code
Preview
# 🤖 SysWatch Agent

Agente de monitoreo para servidores Linux. Se instala en cada VPS y envía métricas en tiempo real al backend.

## Requisitos

- Python 3.10+
- Linux (Ubuntu/Debian/CentOS)

## Instalación rápida

```bash
curl -sSL https://tu-dominio.com/install.sh | bash -s -- \
  --api-key sw_tu_api_key \
  --server-name "Mi VPS"
Instalación manual
bash
git clone https://github.com/tu-usuario/syswatch-agent.git
cd syswatch-agent

python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

export SYSWATCH_API_KEY="sw_tu_api_key"
export SYSWATCH_BACKEND_URL="ws://tu-backend.com/ws/agent"



python agent.py
Variables de entorno
Table
Variable	Descripción	Default
SYSWATCH_API_KEY	API key del servidor (obligatoria)	-
SYSWATCH_BACKEND_URL	URL WebSocket del backend	ws://127.0.0.1:8000/ws/agent
SYSWATCH_INTERVAL	Segundos entre métricas	5
Métricas enviadas
CPU (%)
RAM (%)
Disco (%)
Red (MB enviados/recibidos)
Comandos útiles
bash
# Verificar estado
systemctl status syswatch-agent

# Ver logs
journalctl -u syswatch-agent -f

# Detener
sudo systemctl stop syswatch-agent