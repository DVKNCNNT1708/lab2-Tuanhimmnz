# Phan tich yeu cau - vai Consumer

- Cap dam phan: #7 Camera Stream (A2) -> Analytics (A5)
- Product: A
- Consumer service: Camera Stream (A2)
- Provider service: Analytics (A5) - xay dung dich vu tong hop va phan tich du lieu
- Nguoi viet: Duong Trong Tuan - 1771020715
- Ngay: 2026-05-18

---

## 1. Resource Consumer can nhan/gui

| Resource | Consumer dung de lam gi? | Field bat buoc voi Consumer | Field co the tuy chon |
|---|---|---|---|
| `CameraEvent` | Camera Stream gui su kien cho Analytics de aggregate motion, frame va health. | `eventId`, `eventType`, `occurredAt`, `correlationId`, `source`, `cameraId`, `campusZone`, `detectionId` | `imageRef`, `frameRef`, `notes`, `reason` |
| `EventAccepted` | Biet event da duoc Analytics chap nhan trong mock Lab 02. | `eventId`, `status`, `acceptedAt`, `duplicate` | `aggregateJobId` |
| `CameraAggregate` | Doi soat ket qua Analytics tinh tu event camera. | `cameraId`, `windowStart`, `windowEnd`, `motionCount`, `abnormalCount`, `healthStatus` | `lastEventId` |

---

## 2. API Consumer can goi

> Dependency thuc te la Queue async, nhung Lab 02 dung cac endpoint nay de mock va chung minh contract co the validate bang Prism/curl.

| Method | Path | Luc nao goi? | Ky vong response |
|---|---|---|---|
| POST | `/camera-events` | Khi can test payload event truoc khi chot topic Lab 03. | `202 EventAccepted`, co `duplicate` de kiem tra retry. |
| GET | `/camera-events` | Khi doi soat cac event da gui/duoc mock chap nhan. | `CameraEventPage`, co `nextCursor`, `limit`, `hasMore`. |
| GET | `/camera-events/{eventId}` | Khi debug mot event cu the. | Mot `CameraEvent` dung subtype theo `eventType`. |
| GET | `/camera-aggregates` | Khi xem Analytics da tong hop thanh metric nhu the nao. | `CameraAggregatePage`, co cursor-based pagination. |
| GET | `/camera-aggregates/{cameraId}` | Khi can metric moi nhat cua mot camera. | `CameraAggregate` hoac `Problem` neu khong tim thay. |

---

## 3. Error case Consumer can xu ly

| Status | Consumer hieu la gi? | Consumer se xu ly the nao? |
|---:|---|---|
| 400 | Payload hoac query khong dung schema | Sua mapping payload, log `invalidParams` |
| 401 | Thieu/sai token khi goi mock/API | Cau hinh lai token hoac refresh credential |
| 403 | Token khong co scope phu hop | Bao nguoi phu trach cap quyen |
| 404 | `eventId` hoac `cameraId` khong ton tai | Kiem tra id, correlation, hoac bo qua ban ghi doi soat |
| 409 | Retry dung `eventId` nhung payload khac | Dung retry, sinh incident vi idempotency bi vi pham |
| 422 | Event hop le JSON nhung sai rule nghiep vu | Sua logic tao event theo `eventType` |
| 500 | Analytics/mock loi tam thoi | Retry co backoff, de Lab 03 chot dead-letter policy |

---

## 4. Gia dinh bo sung

- Camera Stream la producer cua cac event `camera.motion.detected`, `camera.frame.analyzed`, `camera.status.changed`.
- Analytics la consumer xu ly bat dong bo va tao aggregate; mock REST chi phuc vu Lab 02.
- `confidence` nam trong khoang 0..1, lam tron den 2 chu so thap phan neu co the.
- Neu khong co detection lien quan, `detectionId` phai la `null` thay vi bo field.

---

## 5. Cau hoi cho Provider

1. Analytics can giu event raw trong bao lau de doi soat lai aggregate?
2. Khi duplicate event co cung payload, Provider tra `202 duplicate: true` hay `409`?
3. Nguong `abnormalScore` nao se tinh vao `abnormalCount`?

---

## 6. Rui ro tich hop

| Rui ro | Tac dong | De xuat xu ly |
|---|---|---|
| Provider thay doi enum `eventType` | Producer gui sai topic/schema | Khoa enum trong contract va dung versioning |
| Provider yeu cau anh raw | Payload lon va lo du lieu | Chot chi gui `imageRef`/`frameRef` |
| Khong co cursor pagination | Doi soat event lon bi cham | Dung `cursor`, `limit`, `nextCursor`, `hasMore` |
| Provider xu ly duplicate khac ky vong | Motion count bi lech | Chot `eventId` la idempotency key |
| Loi khong theo Problem Details | Consumer kho xu ly tu dong | Tat ca loi 4xx/5xx dung `application/problem+json` |
