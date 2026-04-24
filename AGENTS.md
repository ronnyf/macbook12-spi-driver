# macbook12-spi-driver

Out-of-tree Linux kernel modules for MacBook SPI keyboard/trackpad and iBridge (touchbar, ALS).

## Modules

| Module | Source | Purpose |
|---|---|---|
| `applespi` | applespi.c | SPI keyboard + trackpad (upstream since kernel 5.3) |
| `apple-ibridge` | apple-ibridge.c | iBridge/T1 chip MFD core |
| `apple-ib-tb` | apple-ib-tb.c | Touch Bar (depends on apple-ibridge) |
| `apple-ib-als` | apple-ib-als.c | Ambient light sensor (depends on apple-ibridge) |

## Architecture

`applespi` is a standalone SPI bus driver (upstream since kernel 5.3; this out-of-tree copy supports older kernels). The other three modules form a dependency chain:

```
apple-ibridge  (MFD [multi-function device] core, discovers HID devices on T1 chip over USB)
 ├── apple-ib-tb   (Touch Bar, registers via appleib_register_hid_driver())
 └── apple-ib-als  (ALS, registers via appleib_register_hid_driver())
```

`apple-ib-tb` and `apple-ib-als` are HID sub-drivers — they don't talk to hardware directly, they receive HID reports through the `apple-ibridge` multiplexer.

## Kernel Config Prerequisites

- All MacBooks except MacBook8,1: `CONFIG_SPI_PXA2XX=m` and `CONFIG_MFD_INTEL_LPSS_PCI=m`
- MacBook8,1 (2015): `CONFIG_SPI_PXA2XX=m`, `CONFIG_SPI_PXA2XX_PCI=m`, and `CONFIG_X86_INTEL_LPSS=n` (kernels before 4.14)

## Build

```
make              # builds all 4 .ko modules against running kernel
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

## Debugging

Packet tracing via kernel tracepoints:
```
echo 1 > /sys/kernel/debug/tracing/events/applespi/<event>/enable
cat /sys/kernel/debug/tracing/trace
```

Trackpad dimensions via debugfs:
```
echo 1 > /sys/kernel/debug/applespi/enable_tp_dim
cat /sys/kernel/debug/applespi/tp_dim
```

## Licensing

All source files use `SPDX-License-Identifier: GPL-2.0`. Match this header on new files.
