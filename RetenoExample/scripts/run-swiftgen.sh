#!/bin/sh

EFFECTIVE_PODS_ROOT="${SRCROOT}/Pods"

if [ "${EFFECTIVE_PODS_ROOT+x}" ] && [ -x "${EFFECTIVE_PODS_ROOT}/SwiftGen/bin/swiftgen" ]; then
    ${EFFECTIVE_PODS_ROOT}/SwiftGen/bin/swiftgen
else
    echo "warning: SwiftGen not added to the Pods"
fi
