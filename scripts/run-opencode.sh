#!/usr/bin/env bash
set -euo pipefail

export OPENCODE_CONFIG_CONTENT='{"permission":{"*":"allow"}}'

opencode run -m opencode/hy4-flash-free
