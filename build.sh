#!/bin/bash
# build.sh - Build script for Replica iOS app
# Creates an unsigned IPA for Sidestore installation

set -e

APP_NAME="Replica"
BUNDLE_ID="com.iosmirror"
OUTPUT_NAME="mirror"

echo "=== Building ${APP_NAME} for Sidestore ==="

# Check if we're in the right directory
if [ ! -f "Info.plist" ]; then
    echo "Error: Info.plist not found. Run from the app root directory."
    exit 1
fi

# Verify bundle ID
CURRENT_BUNDLE_ID=$(plutil -raw -key CFBundleIdentifier Info.plist 2>/dev/null || echo "unknown")
echo "Bundle ID: ${CURRENT_BUNDLE_ID}"

# Create temporary working directory
WORK_DIR=$(mktemp -d)
echo "Working in: ${WORK_DIR}"

# Copy app contents to Payload structure
mkdir -p "${WORK_DIR}/${APP_NAME}.app"
cp -R . "${WORK_DIR}/${APP_NAME}.app/" 2>/dev/null || true

# Remove README.md and .git if they exist
rm -f "${WORK_DIR}/${APP_NAME}.app/README.md" 2>/dev/null || true
rm -rf "${WORK_DIR}/${APP_NAME}.app/.git" 2>/dev/null || true
rm -rf "${WORK_DIR}/${APP_NAME}.app/.github" 2>/dev/null || true

# Strip code signing by clearing _CodeSignature
rm -rf "${WORK_DIR}/${APP_NAME}.app/_CodeSignature" 2>/dev/null || true

# Also need to remove embedded code signing from frameworks and extensions
find "${WORK_DIR}/${APP_NAME}.app" -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true

# Create the IPA (which is actually a ZIP)
OUTPUT_IPA="${OUTPUT_NAME}.ipa"
cd "${WORK_DIR}"
zip -r "${OUTPUT_IPA}" "${APP_NAME}.app"

# Move to original directory
mv "${WORK_DIR}/${OUTPUT_IPA}" ./

# Cleanup
rm -rf "${WORK_DIR}"

echo "=== Build Complete ==="
echo "Output: ${OUTPUT_IPA}"
ls -lh "${OUTPUT_IPA}"