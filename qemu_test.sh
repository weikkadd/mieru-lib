#!/bin/bash
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq qemu-user-static gcc libc6-dev >/dev/null 2>&1
gcc -O2 -o probe_bin probe/probe.c -ldl || exit 9
for FEAT in "" "+popcnt" "+sse4.1" "+sse4.2" "+bmi2" "+avx" "+avx2"; do
  echo "== qemu64 $FEAT =="
  qemu-x86_64-static -cpu "qemu64$FEAT" ./probe_bin dist/bot_amd64.so && echo "RESULT: PASS" || echo "RESULT: FAIL"
done
