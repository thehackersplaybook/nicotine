#!/bin/bash
./scripts/cli/lint.sh || exit 1
./scripts/cli/typecheck.sh || exit 1
bandit -r nicotine/ || exit 1
./scripts/cli/test.sh || exit 1
echo "✅ All validation checks passed."