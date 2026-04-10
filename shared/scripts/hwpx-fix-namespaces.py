#!/usr/bin/env python3
"""
HWPX 네임스페이스 후처리 유틸리티

python-hwpx가 생성한 HWPX 파일의 XML 네임스페이스 프리픽스를
한컴오피스 표준 프리픽스로 교체한다.

이 스크립트를 실행하지 않으면 한글 Viewer(특히 macOS)에서
문서가 빈 페이지로 표시될 수 있다.

원본: https://github.com/Canine89/gonggong_hwpxskills
포팅: Forge CLI 환경용

사용법:
  CLI:    python hwpx-fix-namespaces.py <file.hwpx>
  Import: from hwpx_fix_namespaces import fix_hwpx_namespaces
"""

import zipfile
import os
import re
import sys


def fix_hwpx_namespaces(hwpx_path):
    """
    HWPX 파일의 ns0:/ns1: 등 자동 생성 프리픽스를
    한컴오피스 표준 프리픽스(hh/hc/hp/hs)로 교체한다.
    """
    NS_MAP = {
        "http://www.hancom.co.kr/hwpml/2011/head": "hh",
        "http://www.hancom.co.kr/hwpml/2011/core": "hc",
        "http://www.hancom.co.kr/hwpml/2011/paragraph": "hp",
        "http://www.hancom.co.kr/hwpml/2011/section": "hs",
    }

    tmp_path = hwpx_path + ".tmp"

    with zipfile.ZipFile(hwpx_path, "r") as zin:
        with zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = zin.read(item.filename)

                if item.filename.startswith("Contents/") and item.filename.endswith(".xml"):
                    text = data.decode("utf-8")

                    ns_aliases = {}
                    for match in re.finditer(r'xmlns:(ns\d+)="([^"]+)"', text):
                        alias, uri = match.group(1), match.group(2)
                        if uri in NS_MAP:
                            ns_aliases[alias] = NS_MAP[uri]

                    for old_prefix, new_prefix in ns_aliases.items():
                        text = text.replace(f"xmlns:{old_prefix}=", f"xmlns:{new_prefix}=")
                        text = text.replace(f"<{old_prefix}:", f"<{new_prefix}:")
                        text = text.replace(f"</{old_prefix}:", f"</{new_prefix}:")

                    data = text.encode("utf-8")

                zout.writestr(item, data)

    os.replace(tmp_path, hwpx_path)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python hwpx-fix-namespaces.py <file.hwpx>")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"Error: File not found: {path}")
        sys.exit(1)

    fix_hwpx_namespaces(path)
    print(f"Fixed namespaces: {path}")
