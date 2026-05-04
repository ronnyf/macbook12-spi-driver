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

# Match the compiler/toolchain used to build the running kernel
_KERN_CLANG := $(shell grep -q CONFIG_CC_IS_CLANG $(KDIR)/.config 2>/dev/null && echo 1)
_KERN_LLD := $(shell grep -q CONFIG_LLD_VERSION $(KDIR)/.config 2>/dev/null && echo 1)
_KERN_FLAGS :=
ifeq ($(_KERN_CLANG),1)
  _CLANG := $(shell which clang 2>/dev/null)
  _LLVM_AR := $(shell which llvm-ar 2>/dev/null)
  _LLVM_NM := $(shell which llvm-nm 2>/dev/null)
  _LLVM_OBJCOPY := $(shell which llvm-objcopy 2>/dev/null)
  _LLVM_OBJDUMP := $(shell which llvm-objdump 2>/dev/null)
  ifneq ($(_CLANG),)
    _KERN_FLAGS += CC=clang
    ifneq ($(_LLVM_AR),)
      _KERN_FLAGS += AR=$(_LLVM_AR)
    endif
    ifneq ($(_LLVM_NM),)
      _KERN_FLAGS += NM=$(_LLVM_NM)
    endif
    ifneq ($(_LLVM_OBJCOPY),)
      _KERN_FLAGS += OBJCOPY=$(_LLVM_OBJCOPY)
    endif
    ifneq ($(_LLVM_OBJDUMP),)
      _KERN_FLAGS += OBJDUMP=$(_LLVM_OBJDUMP)
    endif
  endif
endif
ifeq ($(_KERN_LLD),1)
  _LLD := $(shell which ld.lld 2>/dev/null)
  ifneq ($(_LLD),)
    _KERN_FLAGS += LD=$(_LLD)
  endif
endif

all:
	$(MAKE) -C $(KDIR) M=$(PWD) $(_KERN_FLAGS) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean
	rm -rf pkg src

install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install

test: all
	sync
	-rmmod applespi
	insmod ./applespi.ko

PKGNAME = applespi
PKGVER = 1.0.0

package-pacman: all
	tar czf $(PKGNAME)-$(PKGVER).tar.gz --exclude-vcs --exclude='*.tar.gz' --exclude='.git' .
	makepkg --force -s
