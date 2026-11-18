#!/usr/bin/env python3
"""
Lokální můstek pro čtení dat ze sériového portu (např. COM3 nebo /dev/ttyUSB0).
Čte data ze senzoru a vystavuje je na lokálním HTTP endpointu:
http://localhost:8080/data
"""

import sys
import time
import re
import json
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

try:
    import serial
    import serial.tools.list_ports
except ImportError:
    serial = None

latest_reading = {
    "connected": False,
    "co2": None,
    "temperature": None,
    "humidity": None,
    "timestamp": None,
    "raw": "Čekání na data...",
    "error": None
}

def parse_line(line: str):
    global latest_reading
    line = line.strip()
    if not line:
        return
    
    latest_reading["raw"] = line
    latest_reading["timestamp"] = time.strftime("%Y-%m-%d %H:%M:%S")

    if "chyba" in line.lower() or "error" in line.lower():
        latest_reading["error"] = line
        return

    # Formát výstupu ze senzoru: "CO2: 780 ppm, Temp: 22.4 C, Hum: 45"
    m = re.search(r"CO2:\s*(\d+)\s*ppm,\s*Temp:\s*([\d\.]+)\s*C,\s*Hum:\s*([\d\.]+)", line, re.IGNORECASE)
    if m:
        latest_reading["co2"] = int(m.group(1))
        latest_reading["temperature"] = float(m.group(2))
        latest_reading["humidity"] = float(m.group(3))
        latest_reading["error"] = None
        print(f"[{latest_reading['timestamp']}] CO2={latest_reading['co2']} ppm | T={latest_reading['temperature']} °C | RH={latest_reading['humidity']} %")

def serial_worker(port_name="COM3", baud=115200):
    global latest_reading
    if not serial:
        print("Knihovna pyserial není nainstalována. Spusťte: pip install pyserial")
        return

    while True:
        try:
            print(f"Připojování k sériovému portu {port_name} ({baud} Bd)...")
            with serial.Serial(port_name, baud, timeout=2) as ser:
                latest_reading["connected"] = True
                print(f"Port {port_name} úspěšně připojen.")
                while True:
                    line = ser.readline().decode("utf-8", errors="ignore")
                    if line:
                        parse_line(line)
        except Exception as e:
            latest_reading["connected"] = False
            latest_reading["error"] = str(e)
            print(f"Chyba portu {port_name}: {e}. Opakuji za 3 s...")
            time.sleep(3)

class BridgeRequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path in ["/", "/data", "/api/live"]:
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(latest_reading, ensure_ascii=False).encode("utf-8"))
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        return

def run_server(port=8080):
    server = HTTPServer(("127.0.0.1", port), BridgeRequestHandler)
    print(f"Lokální HTTP server běží na http://localhost:{port}/data")
    server.serve_forever()

if __name__ == "__main__":
    port_arg = "COM3"
    if len(sys.argv) > 1:
        port_arg = sys.argv[1]
    
    t = threading.Thread(target=serial_worker, args=(port_arg,), daemon=True)
    t.start()
    try:
        run_server(8080)
    except KeyboardInterrupt:
        print("\nUkončeno.")
