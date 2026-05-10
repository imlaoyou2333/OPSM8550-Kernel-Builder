#!/usr/bin/env bash
#
# Emit susfs diagnostics into the GitHub Actions job summary.
#
# Required env:
#   SOC
#   KSU_TYPE
#   KERNEL_BRANCH
#   GITHUB_STEP_SUMMARY
#
# Optional env:
#   SUSFS_REF
#
set -euo pipefail

: "${SOC:?}"
: "${KSU_TYPE:?}"
: "${KERNEL_BRANCH:?}"
: "${GITHUB_STEP_SUMMARY:?}"

append_file_block() {
  local label="$1"
  local path="$2"

  [[ -f "$path" ]] || return 0

  echo "#### $label"
  echo '```text'
  cat "$path"
  echo '```'
  echo
}

{
  echo "### susfs diagnostics"
  echo
  echo "- Root solution: ${KSU_TYPE}"
  echo "- Branch: ${KERNEL_BRANCH}"
  if [[ -n "${SUSFS_REF:-}" ]]; then
    echo "- susfs ref: ${SUSFS_REF}"
  fi
  echo

  if [[ -f "${SOC}/out/.config" ]]; then
    echo '#### .config snapshot'
    echo '```text'
    grep -E '^CONFIG_KSU=|^CONFIG_KSU_SUSFS|^CONFIG_KSU_MANUAL_HOOK|^CONFIG_KPM=|^CONFIG_KALLSYMS=|^CONFIG_KALLSYMS_ALL=' "${SOC}/out/.config" || true
    echo '```'
    echo
  fi

  append_file_block "susfs-source-proof.txt" "${SOC}/susfs-source-proof.txt"
  append_file_block "susfs-hook-proof.txt"   "${SOC}/susfs-hook-proof.txt"
  append_file_block "susfs-proof.txt"        "${SOC}/susfs-proof.txt"
} >> "$GITHUB_STEP_SUMMARY"
