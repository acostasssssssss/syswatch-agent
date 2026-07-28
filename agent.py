"""Loop principal del agente."""

import asyncio
import os
import signal
import sys

from config import config
from metrics import collect_all
from websocket_client import WebSocketClient


class SysWatchAgent:
    """Agente que recolecta métricas y las envía al backend."""

    def __init__(self):
        self.client = WebSocketClient(config.backend_url, config.api_key)
        self.running = True

    async def run(self):
        """Inicia el loop principal."""
        if not config.is_valid():
            print("❌ Configuración inválida. Setea SYSWATCH_API_KEY")
            sys.exit(1)

        # Manejar señales de terminación
        signal.signal(signal.SIGINT, self._shutdown)
        signal.signal(signal.SIGTERM, self._shutdown)

        await self.client.connect()

        while self.running:
            try:
                metrics = collect_all()
                await self.client.send(metrics)
                print(f"📊 Enviado: {metrics}")

                # Verificar ping del servidor
                msg = await asyncio.wait_for(
                    self.client.receive(),
                    timeout=config.interval
                )
                if msg and msg.get("type") == "ping":
                    print("💓 Ping recibido")

            except asyncio.TimeoutError:
                pass  # Normal, no hay mensaje del servidor
            except Exception as e:
                print(f"❌ Error: {e}")
                self.client.connected = False
                await self.client.connect()

        await self.client.close()
        print("👋 Agente detenido")

    def _shutdown(self, signum, frame):
        """Maneja Ctrl+C o señal de terminación."""
        print("\n🛑 Deteniendo agente...")
        self.running = False


async def main():
    agent = SysWatchAgent()
    await agent.run()


if __name__ == "__main__":
    asyncio.run(main())