#!/bin/sh

set -e

APP_NAME="gh-proxy"
VERSION="v0.0.1"
URL_PREFIX="https://github.com/plutonyx/gh-proxy/releases/download/${VERSION}"
INSTALL_DIR=${INSTALL_DIR:-/usr/local/bin}

case "$(uname -sm)" in
  "Darwin x86_64") FILENAME="${APP_NAME}-darwin-amd64" ;;
  "Darwin arm64") FILENAME="${APP_NAME}-darwin-arm64" ;;
  "Linux x86_64") FILENAME="${APP_NAME}-linux-amd64" ;;
  "Linux i686") FILENAME="${APP_NAME}-linux-386" ;;
  "Linux armv7l") FILENAME="${APP_NAME}-linux-arm" ;;
  "Linux aarch64") FILENAME="${APP_NAME}-linux-arm64" ;;
  *) echo "Unsupported architecture: $(uname -sm)" >&2; exit 1 ;;
esac

echo "Downloading $FILENAME from github releases"
if ! curl -sSLf "$URL_PREFIX/$FILENAME" -o "$INSTALL_DIR/${APP_NAME}"; then
  echo "Failed to write to $INSTALL_DIR; try with sudo" >&2
  exit 1
fi

if ! chmod +x "$INSTALL_DIR/${APP_NAME}"; then
  echo "Failed to set executable permission on $INSTALL_DIR/${APP_NAME}" >&2
  exit 1
fi

echo "${APP_NAME} is successfully installed"
