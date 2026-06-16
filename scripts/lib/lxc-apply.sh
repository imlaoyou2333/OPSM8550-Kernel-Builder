#!/usr/bin/env bash
# shellcheck shell=bash
# Provides LXC support patch application for the kernel build pipeline.

apply_lxc_patch() {
  local patch_url="https://github.com/ravindu644/Droidspaces-OSS/raw/refs/heads/main/Documentation/resources/kernel-patches/GKI/below-kernel-6.12/001.GKI-below-6.12-fix_sysvipc_kabi_1_2_3.patch"
  local patch_file

  patch_file="$(mktemp /tmp/lxc-patch.XXXXXX.patch)"
  echo "Downloading LXC kernel patch from ${patch_url}"
  curl -fsSL "${patch_url}" -o "${patch_file}"

  echo "Checking LXC patch applicability"
  if ! git apply --check "${patch_file}"; then
    rm -f "${patch_file}"
    echo "::error::Failed to apply LXC patch cleanly"
    exit 1
  fi

  echo "Applying LXC kernel patch"
  git apply "${patch_file}"
  rm -f "${patch_file}"
  echo "LXC support patch applied successfully."
}
