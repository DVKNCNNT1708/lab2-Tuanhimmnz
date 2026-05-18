# Versioning

- Contract: Smart Campus Product A - Camera Stream to Analytics
- Dependency: #7 Camera Stream (A2) -> Analytics (A5)
- Version hien tai: `1.0.0`
- Nguoi ghi: Duong Trong Tuan - 1771020715
- Ngay: 2026-05-18

## 1. Nguyen tac chung

Contract dung semantic versioning:

- PATCH: sua mo ta, example, typo, khong doi hanh vi.
- MINOR: them field optional, them endpoint moi, them webhook moi, hoac them enum khi consumer da chap nhan xu ly unknown value.
- MAJOR: doi field bat buoc, doi kieu du lieu, xoa endpoint, xoa enum, doi y nghia idempotency hoac correlation.

## 2. Backward-compatible change

Vi du thay doi tuong thich nguoc:

- Them field optional `cameraModel` vao `CameraEventBase`.
- Them endpoint GET moi de truy van aggregate theo khu vuc.
- Them webhook optional khong lam thay doi endpoint hien co.

Nhung thay doi nay tang version tu `1.0.0` len `1.1.0`.

## 3. Breaking change

Vi du breaking change:

- Doi `eventId` tu `uuid` sang integer.
- Bo field bat buoc `correlationId`.
- Doi enum `camera.motion.detected` thanh `motion.detected`.
- Doi `detectionId` tu union null thanh string bat buoc.

Nhung thay doi nay phai tang version len `2.0.0` va co giai doan chuyen doi.

## 4. Deprecated va Sunset

Endpoint `/legacy/camera-events/{eventId}` trong `openapi.yaml` duoc danh dau:

```yaml
deprecated: true
```

Response `200` cua endpoint legacy co header:

```yaml
Sunset: 2026-08-31T00:00:00Z
```

Client moi phai dung `/camera-events/{eventId}`. Client cu can di chuyen truoc ngay Sunset neu endpoint legacy duoc trien khai that.

## 5. Cursor-based pagination

Hai endpoint GET tra danh sach ap dung cursor pagination:

- `GET /camera-events`
- `GET /camera-aggregates`

Response tra ve `page.nextCursor`, `page.limit`, `page.hasMore`. Client khong duoc tu giai ma cursor vi day la opaque token do Provider quan ly.

## 6. Webhook

OpenAPI co webhook `cameraAggregateReady` de ghi nhan yeu cau bai tap ve nha. Webhook nay thong bao khi Analytics da tinh xong aggregate window moi.
