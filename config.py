"""Configuración del agente."""

import os
from dotenv import load_dotenv

load_dotenv()


class AgentConfig:
    """Carga configuración desde .env o variables de entorno."""

    def __init__(self):
        self.api_key = os.getenv("SYSWATCH_API_KEY", "")
        self.backend_url = os.getenv(
            "SYSWATCH_BACKEND_URL",
            "ws://127.0.0.1:8000/ws/agent"
        )
        self.interval = int(os.getenv("SYSWATCH_INTERVAL", "5"))

    def is_valid(self) -> bool:
        """Verifica que la configuración sea válida."""
        return bool(self.api_key) and bool(self.backend_url)


config = AgentConfig()