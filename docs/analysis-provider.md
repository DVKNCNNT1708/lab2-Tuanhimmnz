# Phan tich yeu cau - vai Provider

- Cap dam phan: #7 Camera Stream (A2) -> Analytics (A5)
- Product: A
- Provider service: Analytics (A5) - xay dung dich vu tong hop va phan tich du lieu
- Consumer service: Camera Stream (A2)
- Nguoi viet: Duong Trong Tuan - 1771020715
- Ngay: 2026-05-18

---

## 1. Resource chinh

| Resource | Mo ta | Thuoc tinh bat buoc | Thuoc tinh tuy chon |
|---|---|---|---|
| `CameraEvent` | Event camera do Camera Stream phat ra de Analytics tong hop. | `eventId`, `eventType`, `occurredAt`, `correlationId`, `source`, `cameraId`, `campusZone`, `detectionId` | `motion`, `frame`, `status` tuy theo `eventType` |
| `CameraAggregate` | So lieu tong hop theo camera va cua so thoi gian. | `cameraId`, `campusZone`, `windowStart`, `windowEnd`, `motionCount`, `abnormalCount`, `analyzedFrameCount`, `healthStatus` | `lastEventId` |
| `Problem` | Mau loi chuan cho mock REST trong Lab 02. | `type`, `title`, `status`, `detail`, `instance`, `traceId` | `invalidParams` |

---

## 2. Action/API du kien

> Dependency goc la Queue async. Cac API ben duoi la mat cat mock/quan sat de kiem tra contract trong Lab 02; AsyncAPI chi tiet se chuyen sang Lab 03.

| Method | Path | Muc dich | Consumer goi khi nao? |
|---|---|---|---|
| POST | `/camera-events` | Mock endpoint tiep nhan event camera va validate schema. | Khi Camera Stream muon test payload truoc khi dua vao queue/topic. |
| GET | `/camera-events` | Liet ke event da chap nhan, co cursor pagination. | Khi hai ben doi soat delivery, retry va idempotency. |
| GET | `/camera-events/{eventId}` | Lay chi tiet mot event. | Khi can debug correlation hoac so sanh payload. |
| GET | `/camera-aggregates` | Liet ke metric tong hop theo camera, co cursor pagination. | Khi can xem ket qua aggregate tu event camera. |
| GET | `/camera-aggregates/{cameraId}` | Lay aggregate moi nhat cua mot camera. | Khi dashboard hoac nhom tich hop can xem trang thai tung camera. |

---

## 3. Error case

| Status | Tinh huong | Response body du kien |
|---:|---|---|
| 400 | Payload sai JSON/schema, thieu `eventType`, sai query cursor/limit | `Problem` |
| 401 | Thieu hoac sai Bearer token khi goi endpoint can bao ve | `Problem` |
| 403 | Token hop le nhung khong co scope doc/ghi camera analytics | `Problem` |
| 404 | Khong tim thay `eventId` hoac `cameraId` | `Problem` |
| 409 | Trung `eventId` nhung payload hash khac nhau | `Problem` |
| 422 | JSON hop le nhung vi pham nghiep vu, vi du motion event khong co confidence | `Problem` |
| 500 | Analytics tam thoi khong xu ly duoc event | `Problem` |

---

## 4. Gia dinh bo sung

- Event khong nhung anh raw/base64 vao payload; chi gui `imageRef` hoac `frameRef`.
- `eventId` la idempotency key chinh. Neu retry cung `eventId` va cung payload thi Analytics duoc phep tra ve `duplicate: true`.
- `correlationId` bat buoc de noi chuoi voi detection hoac request upstream; `detectionId` co the null neu event khong den tu AI Vision.
- Camera offline tu 180 giay tro len thi Camera Stream phat `camera.status.changed`.
- Lab 03 se chot topic/broker, retry policy, dead-letter queue va schema compatibility rule.

---

## 5. Cau hoi cho Consumer

1. Camera Stream co dam bao moi event co `eventId` on dinh qua cac lan retry khong?
2. `imageRef` va `frameRef` se la URL noi bo, object storage URI hay duong dan RTSP snapshot?
3. Camera Stream co gui `camera.frame.analyzed` cho moi frame hay chi gui frame da qua bo loc bat thuong?

---

## 6. Rui ro tich hop

| Rui ro | Tac dong | De xuat xu ly |
|---|---|---|
| Producer gui anh raw lam payload qua lon | Queue cham, mock/test kho chay | Chi gui reference, khong gui binary trong event |
| Retry tao trung event | Aggregate dem lap, KPI sai | Bat buoc idempotency bang `eventId` va payload hash |
| Hai ben hieu khac trang thai camera | Dashboard bao sai online/offline | Chot enum `online`, `degraded`, `offline` trong schema |
| Thieu correlation | Kho truy vet tu frame sang aggregate | Bat buoc `correlationId`, `detectionId` cho phep null |
| Thay doi schema dot ngot | Lab 03 va service khac parse loi | Dung versioning, chi them field optional cho backward-compatible change |
