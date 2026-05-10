#!/usr/bin/env bash
#
# Build the AnyKernel3 flashable zip from the freshly built Image.
#
# Required env:
#   SOC
#   KSU_TYPE
#   BUILD_TIMESTAMP
#   GITHUB_ENV
#
set -euo pipefail

: "${SOC:?}"
: "${KSU_TYPE:?}"
: "${BUILD_TIMESTAMP:?}"
: "${GITHUB_ENV:?}"

ZIP_NAME="${SOC}_${KSU_TYPE}_${BUILD_TIMESTAMP}"
echo "ZIP_NAME=$ZIP_NAME" >> "$GITHUB_ENV"

if [[ -d AnyKernel3/.git ]]; then
  echo "[+] Reusing cached AnyKernel3 checkout."
  (cd AnyKernel3 && git clean -fdx && git reset --hard HEAD)
else
  rm -rf AnyKernel3
  git clone --depth=1 --no-tags https://github.com/Kernel-SU/AnyKernel3.git
fi

sed -i 's/kernel.string=KernelSU by KernelSU Developers/kernel.string=KernelSU by TG@AzusaMyo/' \
  AnyKernel3/anykernel.sh
grep -q 'kernel.string=KernelSU by TG@AzusaMyo' AnyKernel3/anykernel.sh

cp "${SOC}/out/arch/arm64/boot/Image" AnyKernel3/Image

(
  cd AnyKernel3
  zip -r9 "../${ZIP_NAME}.zip" . -x .git/\* .github/\*
)

test -f "${ZIP_NAME}.zip"
