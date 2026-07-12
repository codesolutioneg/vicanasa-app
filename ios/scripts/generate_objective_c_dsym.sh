#!/bin/sh
# Flutter native-assets: objective_c.framework ships without a dSYM bundle.
# Generate one for App Store Connect symbol upload validation.
set -e

FRAMEWORK_BINARY="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework/objective_c"
DSYM_OUTPUT="${DWARF_DSYM_FOLDER_PATH}/objective_c.framework.dSYM"

if [ ! -e "$FRAMEWORK_BINARY" ]; then
  echo "note: objective_c.framework not embedded — skipping dSYM generation"
  exit 0
fi

if [ -d "$DSYM_OUTPUT" ]; then
  echo "note: objective_c.framework.dSYM already present"
  exit 0
fi

echo "Generating dSYM for objective_c.framework"
dsymutil "$FRAMEWORK_BINARY" -o "$DSYM_OUTPUT"
