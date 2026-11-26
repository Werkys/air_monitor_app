# Maturitní projekt - zařízení pro měření kvality ovzduší

## Popis aplikace

Klientská aplikace vytvořená v frameworku Flutter pro zobrazení kvality ovzduší ve školních učebnách v rámci maturitního projektu.

Aplikace zpracovává data z měřicího čidla STCC4 a zprostředkovává přehled o stavu vnitřního klimatu.

---

## funkce

* **Monitoring:** Zobrazení koncentrace oxidu uhličitého ($CO_2$), teploty a relativní vlhkosti vzduchu.
* **semafor:**
  * Zelená (optimální): do 1 000 ppm
  * Žlutá (zvýšená): 1 000 až 1 500 ppm
  * Červená (kritická): nad 1 500 ppm (doporučení okamžitého větrání)
* **grafy:** Vlastní vykreslování vývoje koncentrace $CO_2$ za zvolené období (týden, měsíc, rok) s vyznačenými referenčními limity.
* **backend:** Automatické stahování dat přes internet s hlášením aktualního stavu připojení k serveru.

---

## Struktura projektu

* `lib/models/` – datové modely pro naměřené body a místnosti (`air_data_point.dart`, `room.dart`).
* `lib/screens/` – hlavní obrazovka dashboardu (`dashboard_screen.dart`).
* `lib/services/` – komunikace se serverem a generování historických dat (`server_api_service.dart`, `air_quality_service.dart`).
* `lib/widgets/` – komponenty uživatelského rozhraní:
  * `interactive_chart.dart` – vykreslování křivky $CO_2$ přes CustomPainter,
  * `metric_card.dart` – dlaždice s aktuálními hodnotami,
  * `period_selector.dart` – volič časového rozsahu,
  * `traffic_light_badge.dart` – stavový indikátor.
* `serial_bridge.py` – pomocný Python skript pro přímé lokální čtení dat ze sériového portu USB (COM port).

---

## spuštění aplikace

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

---

## Model krabičky
Zde je momentální verze modelu zobrazená v PrushaSliceru:
<img width="2023" height="1279" alt="image" src="https://github.com/user-attachments/assets/02253a79-3411-4085-9f6a-3d7746e76a75" />
* **popis:** model se skládá z víčka a krabičky. ve víčku je prostor pro čidlo nad kterým je odvzdušněné mřížkou nad ním. následně je zde prostor na tři led diody. Krabička má 2 přepážky. jedna na na umístění desky a druhá na baterii. Na straně krabičky je otvor pro nabíjení zařízení.
