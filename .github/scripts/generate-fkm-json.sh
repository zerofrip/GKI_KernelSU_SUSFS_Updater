#!/usr/bin/env bash
# =============================================================================
# generate-fkm-json.sh
# Generates a Franco Kernel Manager (FKM) compatible JSON file for a kernel.
#
# FKM JSON Schema (matches reference):
# {
#   "kernel": {
#     "date":          "YYYY-MM-DD",
#     "name":          "Human-readable kernel name",
#     "version":       "X.Y.Z-androidNN-patch",
#     "link":          "Permanent download URL (GitHub Release asset)",
#     "changelog_url": "URL to release changelog",
#     "sha1":          "SHA1 hash of the downloadable zip"
#   },
#   "support": {
#     "link": "URL to support/discussions page"
#   }
# }
#
# Usage:
#   ./generate-fkm-json.sh \
#     --kernel-version "6.6.118" \
#     --android-version "android15" \
#     --os-patch-level "lts" \
#     --release-tag "v2.0.0-r5" \
#     --repo "zerofrip/GKI_KernelSU_SUSFS_Updater" \
#     --build-date "2026-03-03" \
#     --sha1 "abc123def456" \
#     --output "kernel-downloads-6.6.118-android15-lts.json"
# =============================================================================

set -euo pipefail

# --- Argument parsing ---
KERNEL_VERSION=""
ANDROID_VERSION=""
OS_PATCH_LEVEL=""
RELEASE_TAG=""
REPO=""
BUILD_DATE=""
SHA1=""
OUTPUT=""
VARIANT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kernel-version)   KERNEL_VERSION="$2";   shift 2 ;;
    --android-version)  ANDROID_VERSION="$2";  shift 2 ;;
    --os-patch-level)   OS_PATCH_LEVEL="$2";   shift 2 ;;
    --release-tag)      RELEASE_TAG="$2";       shift 2 ;;
    --repo)             REPO="$2";              shift 2 ;;
    --build-date)       BUILD_DATE="$2";        shift 2 ;;
    --sha1)             SHA1="$2";              shift 2 ;;
    --output)           OUTPUT="$2";            shift 2 ;;
    --variant)          VARIANT="$2";           shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# --- Validation ---
for var in KERNEL_VERSION ANDROID_VERSION OS_PATCH_LEVEL RELEASE_TAG REPO BUILD_DATE SHA1 OUTPUT; do
  if [[ -z "${!var}" ]]; then
    echo "Error: --$(echo "$var" | tr '[:upper:]' '[:lower:]' | tr '_' '-') is required" >&2
    exit 1
  fi
done

# --- Build the full version string ---
# Format: "6.6.118-android15-lts" or "6.6.118-android15-lts-Bypass"
FULL_VERSION="${KERNEL_VERSION}-${ANDROID_VERSION}-${OS_PATCH_LEVEL}"
if [[ -n "$VARIANT" ]]; then
  FULL_VERSION="${FULL_VERSION}-${VARIANT}"
fi

# --- Build the kernel display name ---
# Example: "Wild GKI Kernel 6.6.118-android15-lts"
KERNEL_NAME="Wild GKI Kernel ${FULL_VERSION}"

# --- Build download URL ---
# Points to the GitHub Release asset (permanent URL)
# Asset name matches the AnyKernel3 artifact naming: {version}-AnyKernel3.zip
ASSET_NAME="${FULL_VERSION}-AnyKernel3.zip"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${RELEASE_TAG}/${ASSET_NAME}"

# --- Build changelog URL ---
# Points to the GitHub Release page for the tag
CHANGELOG_URL="https://github.com/${REPO}/releases/tag/${RELEASE_TAG}"

# --- Support URL ---
SUPPORT_URL="https://github.com/${REPO}/discussions"

# --- Generate JSON ---
cat > "$OUTPUT" <<EOF
{
  "kernel": {
    "date": "${BUILD_DATE}",
    "name": "${KERNEL_NAME}",
    "version": "${FULL_VERSION}",
    "link": "${DOWNLOAD_URL}",
    "changelog_url": "${CHANGELOG_URL}",
    "sha1": "${SHA1}"
  },
  "support": {
    "link": "${SUPPORT_URL}"
  }
}
EOF

echo "Generated FKM JSON: $OUTPUT"
echo "  Kernel:  $KERNEL_NAME"
echo "  Version: $FULL_VERSION"
echo "  Link:    $DOWNLOAD_URL"
