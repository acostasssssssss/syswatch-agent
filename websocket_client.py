"""Cliente WebSocket para conectar con el backend."""

import asyncio
import json

import websockets


class WebSocketClient:
    """Mantiene conexión WebSocket con reintentos automáticos."""

    def __init__(self, url: str, api_key: str):
        self.url = f"{url}?api_key={api_key}"
        self.api_key = api_key
        self.ws = None
        self.connected = False

    async def connect(self):
        """Conecta al backend con reintentos."""
        while not self.connected:
            try:
                self.ws = await websockets.connect(self.url)
                self.connected = True
                print(f"✅ Conectado a {self.url.split('?')[0]}")
            except Exception as e:
                print(f"❌ Error conectando: {e}. Reintentando en 5s...")
                await asyncio.sleep(5)

    async def send(self, data: dict):
        """Envía datos JSON al backend."""
        if self.ws and self.connected:
            await self.ws.send(json.dumps(data))

    async def receive(self) -> dict | None:
        """Recibe mensaje del backend."""
        if not self.ws:
            return None
        try:
            msg = await self.ws.recv()
            return json.loads(msg)
        except websockets.ConnectionClosed:
            self.connected = False
            return None

    async def close(self):
        """Cierra conexión."""
        if self.ws:
            await self.ws.close()
            self.connected = False