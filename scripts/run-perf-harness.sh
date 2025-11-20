#!/usr/bin/env bash
set -euo pipefail

OUTPUT_FILE=${1:-perf/runs.jsonl}
SAMPLES=${PERF_SAMPLES:-200}
WARMUPS=${PERF_WARMUPS:-20}
COLUMNS=${PERF_COLUMNS:-120}
ROWS=${PERF_ROWS:-40}
RUN_ID=$(date -u +"%Y%m%dT%H%M%SZ")

mkdir -p "$(dirname "$OUTPUT_FILE")"

TEMP_JSON="$(mktemp)"
COMMIT_HASH="$(git rev-parse --short HEAD)"

echo "Running perf harness..."
PERF_OUTPUT_PATH="$TEMP_JSON" \
PERF_COMMIT="$COMMIT_HASH" \
PERF_SAMPLES="$SAMPLES" \
PERF_WARMUPS="$WARMUPS" \
PERF_COLUMNS="$COLUMNS" \
PERF_ROWS="$ROWS" \
swift run -c debug SwifTeaPerfHarness >/dev/null

printf '{"runID":"%s","recordedAt":"%s","data":%s}\n' "$RUN_ID" "$RUN_ID" "$(cat "$TEMP_JSON")" >>"$OUTPUT_FILE"

echo "Recorded run at commit $COMMIT_HASH to $OUTPUT_FILE"
echo "To inspect the human-readable output, re-run without redirecting stdout or drop the PERF_* overrides as needed."
