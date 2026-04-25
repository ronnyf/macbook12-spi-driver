# Add `make dkms` Target — Pacman PKGBUILD Approach

## Goal
Add a `make dkms` target that produces an installable pacman DKMS package (`applespi-dkms`), following the AIC8800-Linux-Driver pattern.

## Files Changed/Created

### `Makefile`
- Added clang auto-detect (lines 15-26): auto-uses clang if available, `make LLVM=1` forces, `LLVM=0` forces gcc
- Added `modules: all` alias target for DKMS compatibility
- Added `check_deps` target: verifies clang, makepkg, PKGBUILD, dkms.conf
- Added `dkms` target: builds modules, checks deps, runs `makepkg -f`
- Updated `.PHONY`

### `dkms.conf`
- Changed `MAKE="make"` → `MAKE="make modules"` (explicit target)

### `PKGBUILD` (new)
- Package name: `applespi-dkms`, version `0.1-1`
- Source: GitHub tarball + local dkms.conf
- `prepare()`: copies dkms.conf into extracted source
- `package()`: copies all .c/.h + Makefile + dkms.conf to `/usr/src/applespi-dkms-0.1/`
- Dependencies: `dkms`, `linux-headers`, `clang` (makedepends)

### `applespi.install` (new)
- `pre_install`: removes manually installed modules (applespi from `drivers/input/keyboard/`, iBridge from `extra/`)
- `post_install`: checks for dkms, advises installation if missing
- `pre_upgrade`/`post_upgrade`: delegate to install hooks
- `post_remove`: no-op

## Flow
```
make dkms
  → builds modules (all)              ← catches compile errors upfront
  → checks deps (clang, makepkg, PKGBUILD, dkms.conf)
  → makepkg -f                        ← produces applespi-dkms-0.1-1-x86_64.pkg.tar.zst

sudo pacman -U applespi-dkms-0.1-1-x86_64.pkg.tar.zst
  → copies source to /usr/src/applespi-dkms-0.1/
  → DKMS auto-installs and builds modules
```

## Design Decisions
- **PKGBUILD over direct dkms**: Produces a distributable package, follows AIC8800 pattern
- **GitHub tarball source**: Ensures reproducible builds from clean state
- **`modules: all` alias**: DKMS calls `make modules`; Makefile delegates to `all`
- **Clang auto-detect**: Matches AIC8800 pattern, fewer compiler warnings
- **`applespi` in `drivers/input/keyboard/`**: It's upstream since kernel 5.3
- **iBridge in `extra/`**: Out-of-tree modules default to `extra/`

## Review Fixes Applied
| Issue | Fix |
|---|---|
| `source=` missing files | Added GitHub tarball source |
| `MAKE="make modules"` would fail | Added `modules: all` alias target |
| Self-conflicting package | Removed `provides=` and `conflicts=` |
| Wrong module paths | applespi → `drivers/input/keyboard/`, iBridge → `extra/` |
| Plan/implementation mismatch | Updated plan to match PKGBUILD approach |