#!/usr/bin/env bash
# shellcheck shell=bash
# Provides NTSync support patch application for the kernel build pipeline.

apply_ntsync_patches() {
  local patch_urls=(
    "https://github.com/Goldzxcbug/Droidspaces_Kernel_patch/raw/refs/heads/main/NTsync/ntsync_base.patch"
    "https://github.com/Goldzxcbug/Droidspaces_Kernel_patch/raw/refs/heads/main/NTsync/ntsync_compat_android13-5.15.patch"
  )
  local patch_dir
  local patch_url
  local patch_file

  patch_dir="$(mktemp -d /tmp/ntsync-patches.XXXXXX)"

  for patch_url in "${patch_urls[@]}"; do
    patch_file="${patch_dir}/$(basename "${patch_url}")"

    echo "Downloading NTSync kernel patch from ${patch_url}"
    curl -fsSL "${patch_url}" -o "${patch_file}"

    echo "Checking NTSync patch applicability: $(basename "${patch_file}")"
    if ! git apply --check "${patch_file}"; then
      rm -rf "${patch_dir}"
      echo "::error::Failed to apply NTSync patch cleanly: $(basename "${patch_file}")"
      exit 1
    fi

    echo "Applying NTSync kernel patch: $(basename "${patch_file}")"
    git apply "${patch_file}"
  done

  rm -rf "${patch_dir}"
  echo "NTSync support patches applied successfully."
}
