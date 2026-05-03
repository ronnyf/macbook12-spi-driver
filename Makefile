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

# Match the compiler used to build the running kernel
_KERN_CLANG := $(shell grep -q CONFIG_CC_IS_CLANG $(KDIR)/.config 2>/dev/null && echo 1)
_KERN_CC :=
ifeq ($(_KERN_CLANG),1)
  _CLANG := $(shell which clang 2>/dev/null)
  ifneq ($(_CLANG),)
    _KERN_CC := CC=clang
  endif
endif

all:
	$(MAKE) -C $(KDIR) M=$(PWD) $(_KERN_CC) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install

test: all
	sync
	-rmmod applespi
	insmod ./applespi.ko

PKGNAME = applespi
PKGVER = 0.1

package-pacman: all
	tar czf $(PKGNAME)-$(PKGVER).tar.gz --exclude-vcs --exclude='*.tar.gz' --exclude='.git' .
	makepkg --force -s
