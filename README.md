# Centrální aplikace pro sledování kvality ovzduší

Klientská aplikace vytvořená v frameworku Flutter pro vizualizaci a monitoring parametrů vnitřního ovzduší ve školních učebnách v rámci maturitního projektu.

Aplikace zpracovává telemetrická data z měřicích sond vybavených senzory Sensirion STCC4 a zprostředkovává přehled o stavu vnitřního mikroklimatu.

---

## Klíčové funkce

* **Monitoring v reálném čase:** Zobrazení koncentrace oxidu uhličitého ($CO_2$), teploty a relativní vlhkosti vzduchu.
* **Hygienická signalizace (semafor):**
  * Zelená (optimální): do 1 000 ppm
  * Žlutá (zvýšená): 1 000 až 1 500 ppm
  * Červená (kritická): nad 1 500 ppm (doporučení okamžitého větrání)
* **Historické přehledy a trendy:** Vlastní vykreslování vývoje koncentrace $CO_2$ za zvolené období (týden, měsíc, rok) s vyznačenými referenčními limity.
* **Integrace s backendem:** Automatické stahování dat přes REST API s indikací stavu připojení k serveru.

---

## Struktura projektu

* `lib/models/` – datové modely pro naměřené body a místnosti (`air_data_point.dart`, `room.dart`).
* `lib/screens/` – hlavní obrazovka dashboardu (`dashboard_screen.dart`).
* `lib/services/` – komunikace s API serverem a generování historických dat (`server_api_service.dart`, `air_quality_service.dart`).
* `lib/widgets/` – komponenty uživatelského rozhraní:
  * `interactive_chart.dart` – vykreslování křivky $CO_2$ přes CustomPainter,
  * `metric_card.dart` – dlaždice s aktuálními hodnotami,
  * `period_selector.dart` – volič časového rozsahu,
  * `traffic_light_badge.dart` – stavový indikátor.
* `serial_bridge.py` – pomocný Python skript pro přímé lokální čtení dat ze sériového portu USB (COM port).

---

## Požadavky a spuštění

### Spuštění Flutter aplikace

1. Nainstalované Flutter SDK (3.0.0 nebo novější).
2. Načtení závislostí:
   ```bash
   flutter pub get
   ```
3. Spuštění v prohlížeči nebo na desktopu:
   ```bash
   flutter run -d chrome
   ```
   nebo
   ```bash
   flutter run -d windows
   ```

### Lokální sériový můstek (volitelné pro USB testování)

Pokud je senzor připojen přímo k PC přes USB sériový port (např. COM3):
```bash
pip install pyserial
python serial_bridge.py COM3
```
Skript čte data ze sériové linky a vystavuje je na lokálním rozhraní `http://localhost:8080/data`.
