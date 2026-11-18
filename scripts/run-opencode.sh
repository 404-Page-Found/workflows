#!/usr/bin/env bash
set -euo pipefail

export OPENCODE_CONFIG_CONTENT='{"permission":{"*":"allow"}}'

prompt=$(cat)
opencode run -m opencode/hy4-flash-free "$prompt"
