#!/bin/bash
docker run --rm -v "$PWD":/w -w /w debian:bookworm bash -c '
  apt-get update -qq >/dev/null 2>&1
  apt-get install -y -qq qemu-user-static gcc libc6-dev curl ca-certificates >/dev/null 2>&1
  which qemu-x86_64-static || exit 8
  gcc -O2 -o probe_bin probe/probe.c -ldl || exit 9
  for FEAT in "+popcnt" "+sse4.2" "+bmi2" "+popcnt,+sse4.2" "+popcnt,+bmi2" "+sse4.2,+bmi2" "+popcnt,+sse4.2,+bmi2" "+popcnt,+sse4.2,+bmi2,+avx" "+popcnt,+sse4.2,+bmi2,+avx,+avx2"; do
    echo "== qemu64 $FEAT =="
    qemu-x86_64-static -cpu "qemu64$FEAT" ./probe_bin dist/bot_amd64.so && echo "RESULT: PASS" || echo "RESULT: FAIL"
  done
'
