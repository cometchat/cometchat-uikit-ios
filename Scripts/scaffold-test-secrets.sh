#!/usr/bin/env bash
# Ensure TestSecrets.swift exists so a clean clone (CI or fresh checkout) compiles.
# The generated file holds only placeholders; real values come from env vars at runtime
# (TestConfig reads env first, falls back to this file). Idempotent — never overwrites
# an existing file, so local secrets are safe.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/SampleAppUITests/Helpers"
secrets="$dir/TestSecrets.swift"
example="$dir/TestSecrets.swift.example"

if [[ -f "$secrets" ]]; then
  echo "TestSecrets.swift already present — leaving it untouched."
  exit 0
fi

if [[ ! -f "$example" ]]; then
  echo "error: $example not found" >&2
  exit 1
fi

cp "$example" "$secrets"
echo "Created placeholder TestSecrets.swift from the template. Set COMETCHAT_*/TEST_* env vars to supply real values."
