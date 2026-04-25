obj-m += applespi.o
obj-m += apple-ibridge.o
obj-m += apple-ib-tb.o
obj-m += apple-ib-als.o

CFLAGS_applespi.o = -I$(src)	# for tracing

KVERSION := $(KERNELRELEASE)
ifeq ($(origin KERNELRELEASE), undefined)
KVERSION := $(shell uname -r)
endif
KDIR := /lib/modules/$(KVERSION)/build
PWD := $(shell pwd)

# Auto-detect clang/LLVM
# Usage: make (auto-detect) | make LLVM=1 (force clang) | make LLVM=0 (force gcc)
# Strip LLVM from MAKEOVERRIDES so command-line LLVM=0 doesn't leak
# to kbuild via MAKEFLAGS (kbuild's ifdef LLVM treats any value as true)
MAKEOVERRIDES := $(filter-out LLVM=% LLVM_IAS=%,$(MAKEOVERRIDES))

_USE_LLVM :=
ifeq ($(origin LLVM), undefined)
  ifneq ($(shell which clang 2>/dev/null),)
    _USE_LLVM := 1
  endif
else ifeq ($(LLVM),1)
  _USE_LLVM := 1
endif

all:
	$(MAKE) -C $(KDIR) M=$(PWD) $(if $(_USE_LLVM),LLVM=1 LLVM_IAS=1,LLVM= LLVM_IAS=) modules

modules: all

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install

test: all
	sync
	-rmmod applespi
	insmod ./applespi.ko

check_deps:
	@echo "Checking dependencies..."
	@if ! command -v clang >/dev/null 2>&1; then echo "ERROR: clang not found. Install with: sudo pacman -S clang" >&2; exit 1; fi
	@if ! command -v makepkg >/dev/null 2>&1; then echo "ERROR: makepkg not found. Install with: sudo pacman -S devtools" >&2; exit 1; fi
	@if [ ! -f "PKGBUILD" ]; then echo "ERROR: PKGBUILD not found" >&2; exit 1; fi
	@if [ ! -f "dkms.conf" ]; then echo "ERROR: dkms.conf not found" >&2; exit 1; fi
	@echo "All dependencies available."

dkms: all check_deps
	@echo "=== DKMS Deployment ==="
	@echo "Building DKMS package with makepkg..."
	makepkg -f
	@echo ""
	@echo "DKMS package created!"

.PHONY: all clean install test dkms check_deps modules