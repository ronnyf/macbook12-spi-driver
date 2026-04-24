# macbook12-spi-driver

Out-of-tree Linux kernel modules for MacBook SPI keyboard/trackpad and iBridge (touchbar, ALS).

## Modules

| Module | Source | Purpose |
|---|---|---|
| `applespi` | applespi.c | SPI keyboard + trackpad (upstream since kernel 5.3) |
| `apple-ibridge` | apple-ibridge.c | iBridge/T1 chip MFD core |
| `apple-ib-tb` | apple-ib-tb.c | Touch Bar (depends on apple-ibridge) |
| `apple-ib-als` | apple-ib-als.c | Ambient light sensor (depends on apple-ibridge) |

## Build

```
make LLVM=1 all   # builds all 4 .ko modules against running kernel
make clean        # removes build artifacts
make install      # modules_install to /lib/modules/...
```

`applespi.c` includes `applespi_trace.h` (kernel tracepoints), requiring the `-I$(src)` CFLAG in the Makefile. Do not remove it — tracepoint macros won't resolve otherwise.

## Test (manual only)

```
make test         # builds, then rmmod + insmod applespi.ko (requires root)
```

No CI, linter, formatter, or automated tests exist. Code review is manual.

## DKMS

`dkms.conf` declares all 4 modules with version `0.1`. For Debian/Ubuntu:
```
dkms install -m applespi -v 0.1
```

## Licensing

All source files use `SPDX-License-Identifier: GPL-2.0`. Match this header on new files.
