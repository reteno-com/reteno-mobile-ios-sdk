#!/bin/sh

if [ -f "${SRCROOT}/Environment/${ENV_FILE}" ]; then
    cp "${SRCROOT}/Environment/${ENV_FILE}" "${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app/Environment.plist"
fi
