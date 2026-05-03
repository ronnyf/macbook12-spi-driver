# Maintainer: Ronny F. <ronnyf@icloud.com>

pkgname=applespi
pkgver=0.1
pkgrel=1
pkgdesc='Input driver for the SPI keyboard/trackpad found on 12" MacBooks and newer MacBook Pros, plus touchbar and ALS drivers for iBridge (T1) chip'
arch=(x86_64)
url='https://github.com/ronnyf/macbook12-spi-driver'
license=(GPL-2.0)
depends=(kernel>=5.3)
makedepends=(make kmod)
source=(
  "$url/releases/download/v$pkgver/$pkgname-$pkgver.tar.gz"
  "$pkgname.install"
)
install=$pkgname.install
options=(!strip)
sha256sums=(SKIP)

prepare() {
  # Nothing to prepare for out-of-tree kernel modules
}

build() {
  make "KERNELRELEASE=$(uname -r)" all
}

package() {
  install -Dm0644 applespi.ko "${pkgdir}/lib/modules/$(uname -r)/extra/applespi.ko"
  install -Dm0644 apple-ibridge.ko "${pkgdir}/lib/modules/$(uname -r)/extra/apple-ibridge.ko"
  install -Dm0644 apple-ib-tb.ko "${pkgdir}/lib/modules/$(uname -r)/extra/apple-ib-tb.ko"
  install -Dm0644 apple-ib-als.ko "${pkgdir}/lib/modules/$(uname -r)/extra/apple-ib-als.ko"
  install -Dm0644 dkms.conf "${pkgdir}/usr/src/${pkgname}-${pkgver}/dkms.conf"
  install -Dm0644 -t "${pkgdir}/usr/src/${pkgname}-${pkgver}/" *.c *.h applespi_trace.h Makefile
}
