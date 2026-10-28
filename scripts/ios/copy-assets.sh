#!/bin/sh
# Original helper copyright belongs to its upstream authors.
# Modified for Sunder on 2026-10-28; see docs/fork/MODIFICATIONS.md.
set -eu

# Keep the existing Xcode build-phase entry point, without importing external illustrations.
echo "Sunder: proprietary illustration import is disabled; system-symbol presentation is used."
