# zmk-config-fingerrest

ZMK firmware for keyboards used with the [fingerrest ZMK Studio fork](https://github.com/fingerrest/zmk-studio).
Built against [danielsvane/zmk@customkeyboards](https://github.com/danielsvane/zmk/tree/customkeyboards)
(Zephyr 4.1), which adds runtime-editable combos and behaviors to Studio.

## Boards

| Board | Target | Notes |
|---|---|---|
| CannonKeys Bakeneko60 Go | `bakeneko60_go/nrf52840/zmk` | Ported to Zephyr 4.1 boards (HWMv2) from [cannonkeys/zmk-cannonkeys-keyboards](https://github.com/cannonkeys/zmk-cannonkeys-keyboards). Layouts: 60% ANSI, split Backspace / split Right Shift. |

## Build

- **CI:** every push builds the boards in `build.yaml`. Download the `.uf2` from the run's artifacts.
- **Locally (Docker):** `./build.sh`, which writes `out/bakeneko60_go-studio.uf2`. The first run downloads ZMK and Zephyr into a Docker volume.

## Flash

Double-tap reset. The board mounts as a USB drive; copy the `.uf2` onto it. Plug in directly,
not through a hub or dock — the bootloader drive and Studio's serial port both fail through one.

## Studio

Studio is locked until you press **Studio Unlock**: hold `Fn` and press Backspace (the left half of a split Backspace). Studio's saved
changes override the compiled keymap; reset its settings to go back to `bakeneko60_go.keymap`.

## License

Board files are MIT, © Andrew Kannan (CannonKeys), as noted in their headers.
