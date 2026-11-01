#!/bin/bash
docker run --rm -v "$PWD":/w -w /w debian:bookworm bash -c '
  apt-get update -qq >/dev/null 2>&1
  apt-get install -y -qq qemu-user-static gcc libc6-dev curl ca-certificates >/dev/null 2>&1
  which qemu-x86_64-static || exit 8
  gcc -O2 -o probe_bin probe/probe.c -ldl || exit 9
  curl -fsSL -o dist/status_amd64.so https://amd64.oooen.com/v1.so || exit 7
  echo "== bot -cpu max (all features) =="
  qemu-x86_64-static -cpu max ./probe_bin dist/bot_amd64.so && echo "RESULT: PASS" || echo "RESULT: FAIL"
  echo "== v1.so -cpu qemu64 (control: known-loadable on real host) =="
  qemu-x86_64-static -cpu qemu64 ./probe_bin dist/status_amd64.so && echo "RESULT: PASS" || echo "RESULT: FAIL"
  echo "== v1.so -cpu max (control) =="
  qemu-x86_64-static -cpu max ./probe_bin dist/status_amd64.so && echo "RESULT: PASS" || echo "RESULT: FAIL"
'
