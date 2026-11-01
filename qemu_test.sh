#!/bin/bash
docker run --rm -v "$PWD":/w -w /w debian:bookworm bash -c '
  apt-get update -qq >/dev/null 2>&1
  apt-get install -y -qq qemu-user-static gcc libc6-dev curl ca-certificates >/dev/null 2>&1
  which qemu-x86_64-static || exit 8
  gcc -O2 -o probe_bin probe/probe.c -ldl || exit 9
  for LIB in dist/hello_go121.so dist/bot_go120.so dist/bot_go121.so dist/status_amd64.so; do
    echo "== $LIB qemu64 =="
    qemu-x86_64-static -cpu qemu64 ./probe_bin "$LIB" 2>&1 | head -3
    qemu-x86_64-static -cpu qemu64 ./probe_bin "$LIB" >/dev/null 2>&1 && echo "RESULT: PASS" || echo "RESULT: FAIL"
  done
'
