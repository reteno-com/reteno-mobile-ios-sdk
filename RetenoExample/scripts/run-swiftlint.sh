#!/bin/sh
#
if [ "${PODS_ROOT+x}" ] && [ -x "${PODS_ROOT}/SwiftLint/swiftlint" ]; then
  ${PODS_ROOT}/SwiftLint/swiftlint
elif which swiftlint >/dev/null; then
  swiftlint
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
