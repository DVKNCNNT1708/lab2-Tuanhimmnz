# Bien ban dam phan hop dong API

- Cap dam phan: #7 Camera Stream (A2) -> Analytics (A5)
- Product: A
- Provider: Analytics (A5) - xay dung dich vu tong hop va phan tich du lieu
- Consumer: Camera Stream (A2)
- Co che: Queue async; Lab 02 dung OpenAPI mock surface va event contract so bo
- Phien: v1.0
- Ngay: 2026-05-18
- Nguoi ghi: Duong Trong Tuan - 1771020715

---

## Issue #1

- Raised by: Provider
- Endpoint/Event: `camera.motion.detected`
- Concern: Payload co nen nhung anh raw/base64 hay chi gui tham chieu anh.
- Proposal: Chi gui `imageRef`, khong dua binary vao event.
- Resolution: Accepted.
- Rationale: Payload nho hon, queue on dinh hon, khong lam lo du lieu hinh anh trong log.
- Impact: Camera Stream can upload frame/snapshot vao storage truoc khi phat event neu can doi soat anh.

---

## Issue #2

- Raised by: Consumer
- Endpoint/Event: `camera.motion.detected`
- Concern: Motion event co can `confidence` hay khong.
- Proposal: Bat buoc `motion.confidence` trong khoang 0..1.
- Resolution: Accepted.
- Rationale: Analytics can confidence de loc nhieu va tinh KPI chinh xac.
- Impact: Camera Stream phai map confidence tu pipeline detection, neu khong co thi khong phat motion event.

---

## Issue #3

- Raised by: Provider
- Endpoint/Event: Tat ca camera events
- Concern: Retry co the tao trung event va lam aggregate dem lap.
- Proposal: Bat buoc `eventId` lam idempotency key; cung `eventId` cung payload duoc coi la duplicate hop le.
- Resolution: Accepted.
- Rationale: Xu ly at-least-once delivery ma khong lam sai metric.
- Impact: Analytics can luu `eventId` va payload hash; Camera Stream phai giu nguyen `eventId` khi retry.

---

## Issue #4

- Raised by: Consumer
- Endpoint/Event: Tat ca camera events
- Concern: Can truy vet event voi detection/frame upstream.
- Proposal: Bat buoc `correlationId`; `detectionId` bat buoc co field nhung cho phep `null`.
- Resolution: Accepted.
- Rationale: `correlationId` phuc vu trace bat buoc, con `detectionId` khong phai event nao cung co.
- Impact: OpenAPI dung union type `type: [string, "null"]` cho `detectionId` va cac reference optional.

---

## Issue #5

- Raised by: Provider
- Endpoint/Event: `camera.status.changed`
- Concern: Hai ben co the hieu khac nhau ve trang thai camera offline/degraded.
- Proposal: Chot enum `online`, `degraded`, `offline`; offline tu 180 giay thi phat status event.
- Resolution: Modified.
- Rationale: Enum ro rang giup dashboard va aggregate thong nhat, nguong 180 giay la tam thoi cho Lab 02.
- Impact: Lab 03 se xac nhan nguong offline cuoi cung va retry/dead-letter cho status event.

---

## Issue #6

- Raised by: Consumer
- Endpoint/Event: `camera.frame.analyzed`
- Concern: Gui event cho moi frame co the lam qua tai Analytics.
- Proposal: Lab 02 cho phep event frame analyzed nhung khuyen nghi chi gui frame sau khi da qua bo loc hoac co gia tri aggregate.
- Resolution: Accepted.
- Rationale: Giam volume ma van du thong tin de aggregate.
- Impact: Camera Stream can xac dinh sampling/filtering truoc khi phat event thuc te.

---

## Issue #7

- Raised by: Provider
- Endpoint/Event: Mock REST endpoints trong `openapi.yaml`
- Concern: Dependency goc la Queue async, nhung checklist Lab 02 van can Spectral, Prism va 5 request mau.
- Proposal: Dung OpenAPI lam mock surface cho `POST /camera-events`, `GET /camera-events`, `GET /camera-aggregates` va error responses; ghi ro AsyncAPI chuyen sang Lab 03.
- Resolution: Accepted.
- Rationale: Vua dung kien truc async, vua pass yeu cau kiem tra Lab 02 cua repo.
- Impact: `docs/event-contract-template.md` ghi event contract so bo, `openapi.yaml` dung de mock/test bang curl.

---

# Chot hop dong v1.0

- Provider sign-off: Analytics (A5) - Duong Trong Tuan - 1771020715
- Consumer sign-off: Camera Stream (A2) - can xac nhan ten nguoi ky truoc khi push
- Witness (GV/TA): can xac nhan tren lop truoc khi push
- Date: 2026-05-18

---

## Ghi chu warning neu Spectral con canh bao

| Warning | Ly do chap nhan tam thoi | Ke hoach sua |
|---|---|---|
| Khong co | Spectral report se duoc luu trong `evidence/buoi-02/spectral-report.txt` | Khong can xu ly them |
