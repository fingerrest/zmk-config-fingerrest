#!/usr/bin/env bash
# Local Docker build of the boards in build.yaml (currently just bakeneko60_go)
# against danielsvane/zmk@customkeyboards. Output: out/<artifact>.uf2.
#
# docker cp instead of a bind mount: colima only shares $HOME with its VM, and
# copying works wherever the checkout lives. The west workspace lives in a named
# volume, so only the first run downloads ZMK and Zephyr.
set -euo pipefail
IMAGE=zmkfirmware/zmk-build-arm:stable
WS_VOLUME=zmk-dsvane-ws
BOARD=bakeneko60_go/nrf52840/zmk
ARTIFACT=bakeneko60_go-studio
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$here/out"
cid=$(docker create -v "$WS_VOLUME:/ws" -w /ws -e BOARD="$BOARD" "$IMAGE" bash -euo pipefail -c '
    mkdir -p config && cp /repo/config/west.yml config/
    # GitHub drops long HTTP/2 fetches here; HTTP/1.1, shallow clones and retries
    # get west update through.
    git config --global http.version HTTP/1.1
    [ -d .west ] || west init -l config
    west config manifest.project-filter -- "-hal_.*,+hal_nordic,-trusted-firmware-a,-percepio,-mipi-sys-t,-nrf_hw_models,-open-amp,-uoscore-uedhoc,-cmsis-nn,-fatfs,-picolibc"
    for i in 1 2 3 4 5; do
      west update -n --fetch-opt=--depth=1 >/tmp/wu.log 2>&1 && break
      echo "west update attempt $i failed"
      [ $i = 5 ] && { tail -20 /tmp/wu.log; exit 1; }
    done
    echo "zmk @ $(git -C zmk log -1 --format="%h %cd" --date=short)"
    west zephyr-export >/dev/null
    west build -p -s zmk/app -d build/out -b "$BOARD" -S studio-rpc-usb-uart -- \
      -DZMK_CONFIG=/repo/config -DZMK_EXTRA_MODULES=/repo -DCONFIG_ZMK_STUDIO=y
    cp build/out/zephyr/zmk.uf2 /out.uf2
  ')
docker cp "$here/." "$cid:/repo"
if docker start -a "$cid"; then
  docker cp "$cid:/out.uf2" "$here/out/$ARTIFACT.uf2"
  docker rm "$cid" >/dev/null
else
  docker rm "$cid" >/dev/null
  exit 1
fi
ls -lh "$here/out/$ARTIFACT.uf2"
