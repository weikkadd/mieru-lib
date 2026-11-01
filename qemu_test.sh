#!/bin/bash
docker run --rm -v "$PWD":/w -w /w debian:bookworm bash -c '
  apt-get update -qq >/dev/null 2>&1
  apt-get install -y -qq qemu-user-static gcc libc6-dev curl ca-certificates gdb python3 >/dev/null 2>&1
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
    -ex "info proc mappings" \
    2>&1 | tee /tmp/gdb.log >/dev/null
  pkill -f probe_bin 2>/dev/null
  python3 - <<PY
import re, subprocess
log = open("/tmp/gdb.log").read()
rip = int(re.search(r"rip\s+0x([0-9a-f]+)", log).group(1), 16)
base = None
for line in log.splitlines():
    if "bot_amd64.so" in line:
        base = int(line.split()[0], 16)
        break
print("rip=0x%x base=0x%x offset=0x%x" % (rip, base or 0, rip - (base or 0)))
out = subprocess.run(["objdump", "-t", "dist/bot_amd64.so"], capture_output=True, text=True).stdout
syms = []
for line in out.splitlines():
    m = re.match(r"^([0-9a-f]+) .*?\.text\s+([0-9a-f]+) (.*)$", line)
    if m:
        syms.append((int(m.group(2), 16), m.group(3).strip()))
syms.sort()
best = None
for a, name in syms:
    if a <= (rip - base):
        best = (a, name)
print("SIGILL inside symbol:", best[1] if best else "UNKNOWN")
print("nearest disasm:")
subprocess.run(["objdump", "-d", "--start-address=%d" % (rip - base - 16),
                "--stop-address=%d" % (rip - base + 4), "dist/bot_amd64.so"])
PY
  true
'
