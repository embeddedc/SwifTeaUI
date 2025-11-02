#!/usr/bin/env bash
set -euo pipefail

CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-.build/clang-module-cache}"
SWIFTPM_MODULECACHE_PATH="${SWIFTPM_MODULECACHE_PATH:-.build/modulecache}"

export CLANG_MODULE_CACHE_PATH
export SWIFTPM_MODULECACHE_PATH

swift test "$@"
