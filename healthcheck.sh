#!/usr/bin/env bash
#
# Simple script that pings the Metamapper healthcheck endpoint and confirms all
# services are available and healthy.
set -e

sleep 3

HEALTHCHECK_URL="localhost:5050/health"
EXPECTED_STATUS="healthy"

function healthcheck() {
   curl -s $HEALTHCHECK_URL | jq --raw-output "$1"
}

METASTORE_STATUS=$(healthcheck '.metastore.status')

if [[ "$METASTORE_STATUS" != "$EXPECTED_STATUS" ]]; then
    echo "Metastore health check failed: $METASTORE_STATUS"
    exit 1
fi

SCHEDULER_STATUS=$(healthcheck '.scheduler.status')

if [[ "$SCHEDULER_STATUS" != "$EXPECTED_STATUS" ]]; then
    echo "Scheduler health check failed: $SCHEDULER_STATUS"
    exit 1
fi

WORKER_STATUS=$(healthcheck '.worker.status')

if [[ "$WORKER_STATUS" != "$EXPECTED_STATUS" ]]; then
    echo "Worker health check failed: $WORKER_STATUS"
    exit 1
fi

echo "Healthchecks have all passed."
