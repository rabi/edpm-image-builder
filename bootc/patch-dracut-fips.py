#!/usr/bin/env python3

"""Patch dracut's FIPS boot handling for bootc single-root layouts."""

from pathlib import Path
import re
import sys


FIPS_SH = Path("/usr/lib/dracut/modules.d/01fips/fips.sh")
PATTERNS = (
    re.compile(
        r'(?ms)^([ \t]*)if ! mount -oro "\$boot" /boot; then\n'
        r'(?:.*\n)*?^\1FIPS_MOUNTED_BOOT=1\n'
    ),
    re.compile(
        r'(?m)^([ \t]*)mount -oro "\$boot" /boot \|\| return 1\n'
        r'^\1FIPS_MOUNTED_BOOT=1\n'
    ),
)


def main() -> int:
    text = FIPS_SH.read_text()

    if 'Device mount failed, bind-mounting ${_bp} to /boot' in text:
        print(f"{FIPS_SH} already patched")
        return 0

    match = pattern = None
    for candidate in PATTERNS:
        match = candidate.search(text)
        if match:
            pattern = candidate
            break

    if not match or pattern is None:
        print(f"expected mount_boot block not found in {FIPS_SH}", file=sys.stderr)
        return 1

    indent = match.group(1)
    replacement = "\n".join([
        f'{indent}if ! mount -oro "$boot" /boot; then',
        f'{indent}    local _bp',
        f'{indent}    for _bp in /sysroot/sysroot/boot /sysroot/boot; do',
        f'{indent}        if [ -d "${{_bp}}/ostree" ]; then',
        f'{indent}            fips_info "Device mount failed, bind-mounting ${{_bp}} to /boot"',
        f'{indent}            if mount --bind "${{_bp}}" /boot; then',
        f'{indent}                break',
        f'{indent}            fi',
        f'{indent}        fi',
        f'{indent}    done',
        f'{indent}    ismounted /boot || return 1',
        f'{indent}fi',
        f'{indent}FIPS_MOUNTED_BOOT=1',
        "",
    ])
    FIPS_SH.write_text(pattern.sub(replacement, text, count=1))
    print(f"patched {FIPS_SH}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
