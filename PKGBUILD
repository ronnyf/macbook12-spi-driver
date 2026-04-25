# Maintainer: Ronny F. <ronnyf@icloud.com>

_pkgname=macbook12-spi-driver
pkgname=applespi-dkms
pkgver=0.1
pkgrel=1
pkgdesc="Apple MacBook SPI keyboard/trackpad and iBridge drivers (DKMS)"
arch=('x86_64')
url="https://github.com/ronnyf/macbook12-spi-driver"
license=('GPL2')
depends=('dkms' 'linux-headers')
makedepends=('clang')
optdepends=()
install=applespi.install

source=("$pkgname-$pkgver.tar.gz::https://github.com/ronnyf/macbook12-spi-driver/archive/refs/heads/main.tar.gz"
        "dkms.conf")
md5sums=('SKIP'
         'SKIP')

prepare() {
    cd "$srcdir/$_pkgname-main"
    cp "$srcdir/dkms.conf" .
}

build() {
    echo "Build phase: DKMS will compile during installation"
}

package() {
    cd "$srcdir/$_pkgname-main"

    local dkms_dest="$pkgdir/usr/src/$pkgname-$pkgver"

    install -dm 755 "$dkms_dest"
    cp applespi.c applespi.h applespi_trace.h "$dkms_dest/"
    cp apple-ibridge.c apple-ibridge.h "$dkms_dest/"
    cp apple-ib-tb.c "$dkms_dest/"
    cp apple-ib-als.c "$dkms_dest/"
    cp Makefile "$dkms_dest/"
    install -Dm 644 dkms.conf "$dkms_dest/dkms.conf"
}