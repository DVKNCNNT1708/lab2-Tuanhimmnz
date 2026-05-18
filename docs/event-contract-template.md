# Event Contract so bo - dependency Queue async

> File nay ghi nhan thoa thuan ban dau cho Pair #7 trong Lab 02. Dac ta chi tiet bang AsyncAPI se chuyen sang Lab 03.

## 1. Thong tin dependency

- Dependency so: #7
- Producer: Camera Stream (A2)
- Consumer: Analytics (A5)
- Product: A
- Co che: Queue async
- Event/topic du kien: `camera.events.v1`
- Nguoi ghi: Duong Trong Tuan - 1771020715
- Ngay: 2026-05-18

## 2. Muc dich nghiep vu

Camera Stream phat event khi co motion, frame da duoc phan tich, hoac trang thai camera thay doi. Analytics tieu thu cac event nay de tong hop metric theo camera, khu vuc va cua so thoi gian, phuc vu dashboard va bao cao bat thuong trong Smart Campus Product A.

## 3. Event name / topic

| Muc | Gia tri |
|---|---|
| Event name | `camera.motion.detected` |
| Topic/queue | `camera.events.v1` |
| Producer | Camera Stream (A2) |
| Consumer | Analytics (A5) |

| Muc | Gia tri |
|---|---|
| Event name | `camera.frame.analyzed` |
| Topic/queue | `camera.events.v1` |
| Producer | Camera Stream (A2) |
| Consumer | Analytics (A5) |

| Muc | Gia tri |
|---|---|
| Event name | `camera.status.changed` |
| Topic/queue | `camera.events.v1` |
| Producer | Camera Stream (A2) |
| Consumer | Analytics (A5) |

## 4. Payload toi thieu

```json
{
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
      {
        "x": 0.12,
        "y": 0.18,
        "width": 0.24,
        "height": 0.31
      }
    ],
    "imageRef": "s3://smart-campus-a/camera/CAM-A-LOBBY-01/frame-001.jpg"
  }
}
```

## 5. Rang buoc can thong nhat

| Van de | Quyet dinh tam thoi |
|---|---|
| Event id co bat buoc khong? | Co. `eventId` la idempotency key. |
| Co can correlationId khong? | Co. `correlationId` bat buoc cho moi event. |
| Co cho phep gui trung event khong? | Co the xay ra do retry; consumer phai idempotent. |
| Co nhung anh raw/base64 khong? | Khong. Chi gui `imageRef` hoac `frameRef`. |
| `detectionId` co bat buoc khong? | Field bat buoc nhung gia tri co the `null`. |
| Retry khi loi | Chuyen sang Lab 03; tam thoi gia dinh retry co backoff. |
| Dead-letter queue | Chuyen sang Lab 03; can luu event loi schema hoac qua so lan retry. |

## 6. Issue chuyen sang Lab 03

1. Chot broker/topic thuc te va convention partition key theo `cameraId`.
2. Dac ta AsyncAPI cho `camera.events.v1`, retry policy va dead-letter queue.
3. Chot thoi gian luu raw event de Analytics doi soat aggregate.
4. Chot schema evolution rule: chi them field optional cho backward-compatible change.
5. Xac dinh nguong `abnormalScore` de tinh `abnormalCount`.
