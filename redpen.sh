#!/bin/bash
#
# Copyright 2023 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# This script installs and runs the redpen linter, which we use to limit which
# functions can panic.

set -eo pipefail

function print-usage-and-exit {
  echo "Usage:"                                                                         >&2
  echo "  $0 install  Installs redpen and the toolchain redpen requires (uses rustup)." >&2
  echo "  $0 run      Runs the redpen linter."                                          >&2
  exit 1
}

[[ $# -gt 0 ]] || print-usage-and-exit

case "$1" in
  install)
    # Each redpen version is pinned to a particular Rust toolchain version. The
    # following need to be updated in unison:
    #   1. The redpen-linter version here
    #   2. The Rust toolchain version here
    #   3. The redpen-shim version in Cargo.toml
    rustup toolchain install 1.72.0 --profile minimal -c llvm-tools-preview,rust-src,rustc-dev
    RUSTC_BOOTSTRAP=1 cargo +1.72.0 install redpen-linter --version 0.2.0
    ;;
  run)
    # The error message redpen outputs if the crate does not build is very
    # unhelpful, so we run check first as a build check then run redpen.
    RUSTUP_TOOLCHAIN=1.72.0 cargo check
    RUSTUP_TOOLCHAIN=1.72.0 redpen
    ;;
  *)
    print-usage-and-exit
    ;;
esac
