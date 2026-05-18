$ErrorActionPreference = "Stop"

$BaseUrl = if ($env:BASE_URL) { $env:BASE_URL } else { "http://localhost:4010" }
$AuthHeader = "Authorization: Bearer test-token"

Write-Host "[Lab02] Testing Prism mock server at $BaseUrl"
Write-Host ""

Write-Host "[1/5] Happy path: GET /health"
curl.exe -sS -i "$BaseUrl/health"
Write-Host "`n---"

Write-Host "[2/5] Happy path: POST /camera-events"
$payload = '{
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
$payload | curl.exe -sS -i -X POST "$BaseUrl/camera-events" -H $AuthHeader -H "Content-Type: application/json" --data-binary "@-"
Write-Host "`n---"

Write-Host "[3/5] Happy path: GET /camera-events"
curl.exe -sS -i "$BaseUrl/camera-events?limit=1" -H $AuthHeader
Write-Host "`n---"

Write-Host "[4/5] Happy path: GET /camera-aggregates"
curl.exe -sS -i "$BaseUrl/camera-aggregates?limit=1&window=15m" -H $AuthHeader
Write-Host "`n---"

Write-Host "[5/5] Error case: POST /camera-events forced 422 Problem example"
$payload | curl.exe -sS -i -X POST "$BaseUrl/camera-events" -H $AuthHeader -H "Content-Type: application/json" -H "Prefer: code=422" --data-binary "@-"
Write-Host ""
