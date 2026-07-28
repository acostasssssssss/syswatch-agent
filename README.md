# 🤖 SysWatch Agent

Agente de monitoreo ligero para servidores Linux. Recolecta métricas del sistema (CPU, RAM, disco, red) y las envía en tiempo real al backend de SysWatch vía WebSocket.

---

## 📋 Requisitos

- Python 3.10+
- Linux (Ubuntu, Debian, CentOS, Alpine)
- Conexión a Internet (saliente, puerto 443)

---

## 🚀 Instalación rápida

Ejecuta este comando en tu VPS:

```bash
curl -sSL https://raw.githubusercontent.com/tu-usuario/syswatch-agent/main/install.sh | bash -s -- \
  --api-key sw_tu_api_key \
  --server-name "Mi VPS"
```

El script hace todo automáticamente:
- Instala Python y dependencias
- Descarga el agente
- Configura el servicio systemd
- Inicia el monitoreo

---

## ⚙️ Instalación manual

```bash
git clone https://github.com/tu-usuario/syswatch-agent.git /opt/syswatch-agent
cd /opt/syswatch-agent

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Crea archivo `.env`:
```bash
SYSWATCH_API_KEY=sw_tu_api_key
SYSWATCH_BACKEND_URL=wss://tu-backend.com/ws/agent
SYSWATCH_INTERVAL=5
```

Ejecuta:
```bash
python agent.py
```

---

## 🔧 Variables de entorno

| Variable | Descripción | Obligatoria |
|----------|-------------|-------------|
| `SYSWATCH_API_KEY` | API key del servidor | ✅ Sí |
| `SYSWATCH_BACKEND_URL` | URL WebSocket del backend | ❌ No (default: `ws://127.0.0.1:8000/ws/agent`) |
| `SYSWATCH_INTERVAL` | Segundos entre métricas | ❌ No (default: `5`) |

---

## 📊 Métricas enviadas

| Métrica | Unidad | Descripción |
|---------|--------|-------------|
| `cpu` | % | Uso de CPU |
| `ram` | % | Uso de memoria RAM |
| `disk` | % | Uso de disco raíz (/) |
| `net_sent` | MB | Datos enviados por red |
| `net_recv` | MB | Datos recibidos por red |

---

## 🛠️ Comandos útiles

```bash
# Ver estado del agente
systemctl status syswatch-agent

# Ver logs en tiempo real
journalctl -u syswatch-agent -f

# Detener agente
sudo systemctl stop syswatch-agent

# Reiniciar agente
sudo systemctl restart syswatch-agent

# Desinstalar
sudo systemctl stop syswatch-agent
sudo systemctl disable syswatch-agent
sudo rm -rf /opt/syswatch-agent
sudo rm /etc/systemd/system/syswatch-agent.service
```

---

## 🏗️ Arquitectura

```
┌─────────────┐      WebSocket       ┌─────────────────┐
│   Agente    │  ─────────────────►  │  SysWatch       │
│   (tu VPS)  │   cada 5 segundos    │  Backend        │
│             │                      │  (Render/VPS)   │
│  psutil →   │   {cpu, ram, disk}   │                 │
│  métricas   │                      │  Guarda en DB   │
└─────────────┘                      └─────────────────┘
```

---

## 📦 Stack tecnológico

- **Python 3.12**
- **psutil** - Métricas del sistema
- **websockets** - Conexión en tiempo real
- **systemd** - Servicio persistente

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit (`git commit -m 'Agrega feature'`)
4. Push (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

MIT © Carlos Andrés Acosta Yances
