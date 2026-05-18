#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:4010}"
AUTH_HEADER="Authorization: Bearer test-token"

echo "[Lab02] Testing Prism mock server at ${BASE_URL}"
echo

echo "[1/5] Happy path: GET /health"
curl -sS -i "${BASE_URL}/health"
echo
echo "---"

echo "[2/5] Happy path: POST /camera-events"
curl -sS -i -X POST "${BASE_URL}/camera-events" \
  -H "${AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "01970f8a-7a2b-7d2d-9444-1fbc0a701101",
    "eventType": "camera.motion.detected",
    "occurredAt": "2026-05-18T15:20:00Z",
    "correlationId": "01970f8a-7a2b-7d2d-9444-1fbc0a701100",
    "source": "camera-stream-a2",
    "cameraId": "CAM-A-LOBBY-01",
    "campusZone": "A-Lobby",
    "detectionId": "01970f8a-7a2b-7d2d-9444-1fbc0a701102",
    "motion": {
      "confidence": 0.94,
      "boundingBoxes": [
        { "x": 0.12, "y": 0.18, "width": 0.24, "height": 0.31 }
      ],
      "imageRef": "s3://smart-campus-a/camera/CAM-A-LOBBY-01/frame-001.jpg"
    }
  }'
echo
echo "---"

echo "[3/5] Happy path: GET /camera-events"
curl -sS -i "${BASE_URL}/camera-events?limit=1" -H "${AUTH_HEADER}"
echo
echo "---"

echo "[4/5] Happy path: GET /camera-aggregates"
curl -sS -i "${BASE_URL}/camera-aggregates?limit=1&window=15m" -H "${AUTH_HEADER}"
echo
echo "---"

echo "[5/5] Error case: POST /camera-events forced 422 Problem example"
curl -sS -i -X POST "${BASE_URL}/camera-events" \
  -H "${AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -H "Prefer: code=422" \
  -d '{
    "eventId": "01970f8a-7a2b-7d2d-9444-1fbc0a701101",
    "eventType": "camera.motion.detected",
    "occurredAt": "2026-05-18T15:20:00Z",
    "correlationId": "01970f8a-7a2b-7d2d-9444-1fbc0a701100",
    "source": "camera-stream-a2",
    "cameraId": "CAM-A-LOBBY-01",
    "campusZone": "A-Lobby",
    "detectionId": "01970f8a-7a2b-7d2d-9444-1fbc0a701102",
    "motion": {
      "confidence": 0.94,
      "boundingBoxes": [
        { "x": 0.12, "y": 0.18, "width": 0.24, "height": 0.31 }
      ],
      "imageRef": "s3://smart-campus-a/camera/CAM-A-LOBBY-01/frame-001.jpg"
    }
  }'
echo
