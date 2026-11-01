#!/bin/bash
docker run --rm -v "$PWD":/w -w /w debian:bookworm bash -c '
  apt-get update -qq >/dev/null 2>&1
  apt-get install -y -qq qemu-user-static gcc libc6-dev curl ca-certificates gdb >/dev/null 2>&1
  which qemu-x86_64-static || exit 8
  gcc -O2 -o probe_bin probe/probe.c -ldl || exit 9
  qemu-x86_64-static -cpu qemu64 -g 1234 ./probe_bin dist/bot_amd64.so &
  sleep 2
  gdb -batch \
    -ex "set confirm off" \
    -ex "target remote :1234" \
    -ex "handle SIGILL stop print nopass" \
    -ex "continue" \
    -ex "info registers rip" \
    -ex "x/3i \$rip" \
    -ex "bt 8" \
    2>&1 | tail -40
  pkill -f probe_bin 2>/dev/null
  true
'
