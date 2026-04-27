#!/usr/bin/env bash
set -e

print_help() {
cat <<'EOF'

Snag That Extension! - Downloads the VSIX file from the VS Code Extension Marketplace for offline install

Usage:
  snag-that-ext.sh -Publisher PUBLISHER -ExtensionName EXTENSION_NAME \
                   [-Version VERSION] [-OutputPath OUTPUT_DIR]

  snag-that-ext.sh -ExtensionLink MARKETPLACE_URL \
                   [-Version VERSION] [-OutputPath OUTPUT_DIR]

Arguments:
  -Publisher     -p  Required unless -ExtensionLink is used
  -ExtensionName -n  Required unless -ExtensionLink is used
  -ExtensionLink -l  Optional, Marketplace URL, takes precedence over -Publisher and -ExtensionName if all provided

  -Version       -v  Optional, defaults to "latest"
  -OutputPath    -o  Optional, directory to save the VSIX (defaults to cwd)
  -Help          -h  Display this message

EOF
}

# Defaults
VERSION="latest"
OUTPUT_PATH="$(pwd)"

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -Publisher|-p)
      PUBLISHER="$2"
      shift 2
      ;;
    -ExtensionName|-n)
      EXTENSION_NAME="$2"
      shift 2
      ;;
    -ExtensionLink|-l)
      EXTENSION_LINK="$2"
      shift 2
      ;;
    -Version|-v)
      VERSION="$2"
      shift 2
      ;;
    -OutputPath|-o)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    -Help|-h|--help)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      print_help
      exit 1
      ;;
  esac
done

# Parse ExtensionLink if provided
if [ -n "$EXTENSION_LINK" ]; then
  # Extract itemName=Publisher.ExtensionName
  ITEM_NAME="$(printf '%s\n' "$EXTENSION_LINK" | sed -n 's/.*itemName=\([^&]*\).*/\1/p')"

  if [ -z "$ITEM_NAME" ] || [[ "$ITEM_NAME" != *.* ]]; then
    echo "Error: could not parse itemName=Publisher.ExtensionName from ExtensionLink"
    exit 1
  fi

  LINK_PUBLISHER="${ITEM_NAME%%.*}"
  LINK_EXTENSION_NAME="${ITEM_NAME#*.}"

  PUBLISHER="$LINK_PUBLISHER"
  EXTENSION_NAME="$LINK_EXTENSION_NAME"
fi

# Validate required args
if [ -z "$PUBLISHER" ] || [ -z "$EXTENSION_NAME" ]; then
  echo "snag-that-ext: Publisher and ExtensionName must be provided, either directly or via -ExtensionLink."
  print_help
  exit 1
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_PATH"

VSIX_FILE="${PUBLISHER}.${EXTENSION_NAME}.${VERSION}.vsix"
OUTPUT_FILE="${OUTPUT_PATH}/${VSIX_FILE}"

URL="https://${PUBLISHER}.gallery.vsassets.io/_apis/public/gallery/publisher/${PUBLISHER}/extension/${EXTENSION_NAME}/${VERSION}/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage"

if curl -fsSL "$URL" -o "$OUTPUT_FILE"; then
  echo "Extension $EXTENSION_NAME downloaded successfully."
else
  echo "Error: failed to download VSIX" >&2
  exit 1
fi