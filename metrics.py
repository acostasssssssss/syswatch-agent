"""Recolecta métricas del sistema con psutil."""

import psutil


def get_cpu_percent() -> float:
    """Porcentaje de uso de CPU."""
    return psutil.cpu_percent(interval=1)


def get_ram_percent() -> float:
    """Porcentaje de uso de RAM."""
    return psutil.virtual_memory().percent


def get_disk_percent() -> float:
    """Porcentaje de uso de disco raíz."""
    return psutil.disk_usage("/").percent


def get_network_io() -> tuple[float, float]:
    """MB enviados y recibidos."""
    net = psutil.net_io_counters()
    return net.bytes_sent / (1024 * 1024), net.bytes_recv / (1024 * 1024)


def collect_all() -> dict:
    """Recolecta todas las métricas en un solo dict."""
    sent_mb, recv_mb = get_network_io()
    return {
        "cpu": round(get_cpu_percent(), 2),
        "ram": round(get_ram_percent(), 2),
        "disk": round(get_disk_percent(), 2),
        "net_sent": round(sent_mb, 2),
        "net_recv": round(recv_mb, 2),
    }