#!/bin/bash
# build.sh - Build script for Replica iOS app
# Creates an unsigned IPA for Sidestore installation with proper Payload structure

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

WORK_DIR=$(mktemp -d)
echo "Working in: ${WORK_DIR}"

# Create Payload structure
mkdir -p "${WORK_DIR}/Payload/${APP_NAME}.app"

# Copy all app contents
for item in *; do
    [ "$item" = "${OUTPUT_NAME}.ipa" ] && continue
    [ "$item" = "replica.ipa" ] && continue
    [ "$item" = "build.sh" ] && continue
    [ "$item" = "README.md" ] && continue
    [ -e "$item" ] && cp -r "$item" "${WORK_DIR}/Payload/${APP_NAME}.app/" 2>/dev/null || true
done

# Strip code signing
find "${WORK_DIR}/Payload" -name "_CodeSignature" -type d -exec rm -rf {} + 2>/dev/null || true

# Create IPA
cd "${WORK_DIR}/Payload"
zip -r "../../${OUTPUT_NAME}.ipa" "${APP_NAME}.app"

# Move to original directory
mv "${WORK_DIR}/${OUTPUT_NAME}.ipa" ./

# Cleanup
rm -rf "${WORK_DIR}"

echo "=== Build Complete ==="
echo "Output: ${OUTPUT_NAME}.ipa"