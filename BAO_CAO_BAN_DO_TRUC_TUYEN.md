# Báo cáo phân tích vị trí đơn hàng trên bản đồ trực tuyến

## Phạm vi và kết luận nhanh

Đã rà soát mã Flutter của màn **Bản đồ trực tuyến** (`/dispatch_map`), Dashboard và các model/service liên quan. Ứng dụng dùng `flutter_map` + OpenStreetMap.

**Kết luận:** vị trí marker của **đơn hàng** hiện không đại diện cho vị trí lấy hàng hay giao hàng thực tế. Mã tự tạo tọa độ từ vị trí của phần tử trong danh sách, vì vậy marker thay đổi vị trí khi thứ tự/danh sách API thay đổi. Đây là nguyên nhân trực tiếp khiến đơn hiển thị sai vị trí trên bản đồ.

## Luồng hiện tại

```text
GET /api/DonHang/danh-sach-cho-nhan
  -> DonHangModel (chỉ có địa chỉ dạng chuỗi)
  -> DispatchMapScreen
  -> tạo LatLng cố định + offset theo index
  -> MarkerLayer trên flutter_map
```

Vị trí shipper đi theo một luồng khác: API -> `ShipperModel.lat/lng` -> marker. Tuy nhiên vẫn có fallback về một tọa độ TP.HCM, nên dữ liệu thiếu/sai có thể làm các shipper chồng lên cùng một điểm.

## Các vấn đề hiện tại

| Mức độ | Vấn đề | Bằng chứng trong mã | Ảnh hưởng |
|---|---|---|---|
| P0 | Marker đơn hàng dùng tọa độ giả, không dùng dữ liệu đơn | `dispatch_map_screen.dart:51-58`: `lat = 10.7769 + i * 0.004`, `lng = 106.7009 + i * 0.003` | Mỗi đơn bị đặt theo thứ tự API, không phải vị trí thực. |
| P0 | Model đơn hàng không có tọa độ cho điểm lấy/giao | `don_hang_model.dart:32-90` chỉ parse `diaChiLay`/`diaChiGiao` thành chuỗi | Client không có dữ liệu địa lý để đặt marker đúng. |
| P0 | Một marker đơn không xác định ngữ nghĩa | Tooltip hiển thị cả “Lấy” và “Giao” nhưng marker chỉ là một pin (`dispatch_map_screen.dart:61-72`) | Người điều phối không biết pin là điểm lấy, điểm giao hay vị trí bất kỳ. |
| P1 | Thứ tự API quyết định vị trí | Offset gắn với `i` ở `dispatch_map_screen.dart:51-54` | Refresh, lọc, thêm/xóa đơn làm pin của cùng mã đơn nhảy sang nơi khác. |
| P1 | Không tự khung bản đồ theo dữ liệu | `MapOptions` luôn initial center TP.HCM/zoom 13.5 (`dispatch_map_screen.dart:156-159`) | Điểm hợp lệ ngoài khung nhìn ban đầu có thể không thấy; map không phản ánh vùng hoạt động thực tế. |
| P1 | Không kiểm tra tính hợp lệ của lat/lng shipper | `shipper_model.dart:82-83` parse lỗi/thiếu thành `10.7769, 106.7009` | Nhiều shipper thiếu GPS bị hiển thị sai và chồng ở trung tâm TP.HCM thay vì được báo “chưa có vị trí”. |
| P1 | Dashboard lặp lại cùng lỗi tọa độ đơn | `dashboard_screen.dart:81-90` có công thức offset giống trang bản đồ | Sửa riêng `/dispatch_map` nhưng Dashboard vẫn tiếp tục hiển thị sai. |
| P2 | Không có cơ chế geocoding/cache nếu backend chỉ trả địa chỉ | Toàn codebase không có service geocoding; `tracking_service.dart` đang rỗng | Không thể chuyển địa chỉ văn bản thành tọa độ thực một cách có kiểm soát. |
| P2 | Không có phân biệt dữ liệu GPS cũ/đang cập nhật | API client chỉ tải một lần khi mở hoặc nhấn refresh (`dispatch_map_screen.dart:25-30`, `194-198`) | “Trực tuyến” chưa thật sự thể hiện tracking thời gian thực. |
| P2 | Điểm neo icon có thể tạo cảm giác lệch nhẹ | Marker là khung `40x40` chứa icon ghim `38px` (`dispatch_map_screen.dart:57-72`); không khai báo anchor | Dù tọa độ đúng, đầu nhọn icon có thể không nằm chính xác tại điểm LatLng tùy mặc định của `flutter_map`. |

## Nguyên nhân gốc

1. API/model đơn hàng hiện được dùng như dữ liệu nghiệp vụ, không phải dữ liệu không gian: chỉ có địa chỉ văn bản.
2. Để minh họa marker, giao diện tạo “tọa độ demo” bằng công thức offset; đoạn demo này chưa được thay thế.
3. Chưa xác định rõ quy ước hiển thị: mỗi đơn cần một hay hai điểm, và pin nào đại diện cho điểm nào.
4. Hệ thống chưa có quy tắc xử lý dữ liệu vị trí thiếu, không hợp lệ, bị đảo `lat/lng`, hoặc đã cũ.

## Giải pháp đề xuất

### Phương án khuyến nghị: backend lưu và trả tọa độ chuẩn

Lưu riêng tọa độ tại thời điểm tạo/sửa đơn, sau khi địa chỉ được chọn từ autocomplete/geocoding. API danh sách đơn chờ nhận nên trả tối thiểu:

```json
{
  "maDh": "DH001",
  "diaChiLay": "...",
  "pickupLatitude": 10.77510,
  "pickupLongitude": 106.70120,
  "diaChiGiao": "...",
  "deliveryLatitude": 10.78745,
  "deliveryLongitude": 106.69380
}
```

Quy ước bắt buộc:

- `latitude`: -90..90; `longitude`: -180..180.
- Tên trường, hệ tọa độ WGS84 (EPSG:4326), kiểu `number`; không dùng chuỗi địa chỉ thay cho tọa độ.
- Không đảo thứ tự: với `LatLng` của Flutter là `(latitude, longitude)`; riêng URL OSRM cần `(longitude, latitude)`.
- Backend chỉ gửi tọa độ đã xác thực. Nếu không có tọa độ thì trả `null`, **không** thay bằng tọa độ TP.HCM mặc định.

Ở client, mở rộng `DonHangModel` với hai `LatLng?` (hoặc các trường `double?`), tạo hai marker cho mỗi đơn:

- **Pickup:** icon/nhãn màu cam, tooltip “Điểm lấy – Mã đơn”.
- **Delivery:** icon/nhãn màu xanh hoặc đỏ, tooltip “Điểm giao – Mã đơn”.
- Nhấn marker mở panel/dialog của đúng đơn và đúng loại điểm.

Ưu điểm: chính xác, nhanh khi hiển thị, không phụ thuộc rate limit bên thứ ba; phù hợp để routing và điều phối.

### Phương án chuyển tiếp: geocode địa chỉ ở backend, có cache

Nếu hệ thống chưa thể thay đổi form/API tạo đơn ngay, backend gọi dịch vụ geocoding cho `diaChiLay` và `diaChiGiao`, sau đó lưu kết quả vào database. Client chỉ đọc tọa độ đã lưu như phương án khuyến nghị.

Không nên geocode trực tiếp từng đơn mỗi lần Flutter mở map vì chậm, có thể vượt quota/rate limit và cho kết quả không ổn định.

### Những thay đổi UI/map cần thực hiện cùng lúc

1. Bỏ hoàn toàn công thức tọa độ offset theo index tại cả `DispatchMapScreen` và `DashboardScreen`.
2. Bỏ marker khi tọa độ `null`/không hợp lệ, đồng thời hiển thị bộ đếm “chưa xác định vị trí” và danh sách mã đơn cần bổ sung địa chỉ/toạ độ.
3. Sau khi có marker hợp lệ, dùng `LatLngBounds`/`fitCamera` để đưa tất cả điểm vào khung nhìn, có padding cho card tiêu đề trên map.
4. Đặt anchor phù hợp để đầu nhọn của icon ghim trùng tọa độ (hoặc dùng marker widget kích thước rõ ràng với `Alignment.bottomCenter`).
5. Khi hai điểm trùng hoặc rất sát nhau, dùng cluster/spiderfy hoặc offset **chỉ ở cấp render**, nhưng vẫn giữ tọa độ gốc và hiển thị thông tin tránh hiểu nhầm.
6. Chỉ hiển thị shipper online có GPS hợp lệ; hiển thị thời điểm cập nhật GPS và làm mờ/cảnh báo khi dữ liệu quá cũ.
7. Tách phần chuyển `Order/ Shipper -> Map marker` thành mapper/service dùng chung để Dashboard và `/dispatch_map` không tái diễn sai khác.

## Thiết kế dữ liệu đề xuất

```text
DonHang
├── pickupAddress
├── pickupLatitude? / pickupLongitude?
├── deliveryAddress
├── deliveryLatitude? / deliveryLongitude?
├── geocodeStatus (pending | valid | failed)
└── geocodedAt

ShipperLocation
├── shipperId
├── latitude / longitude
└── recordedAt
```

Nên tách vị trí hiện thời của shipper khỏi hồ sơ shipper nếu cần lịch sử tracking hoặc cập nhật thường xuyên.

## Trình tự hiện thực đề nghị

1. Chốt contract API và quy ước: hai tọa độ cho một đơn (pickup/delivery), `null` khi chưa định vị.
2. Cập nhật backend/database/form tạo đơn để persist tọa độ; backfill các đơn cũ bằng geocoding có cache và có bước kiểm duyệt kết quả mơ hồ.
3. Cập nhật `DonHangModel`, mapper marker dùng chung và cả hai màn hình map.
4. Hiển thị hai marker, trạng thái thiếu vị trí, bounds tự động, anchor đúng.
5. Bổ sung kiểm thử parser và marker mapping; kiểm thử thủ công với: địa chỉ hợp lệ, thiếu tọa độ, lat/lng bị đảo, hai điểm trùng nhau, đơn ngoài TP.HCM, và refresh thay đổi thứ tự API.
6. Nếu yêu cầu “trực tuyến” là real-time, bổ sung polling/WebSocket cho GPS shipper cùng chiến lược stale-location.

## Tiêu chí nghiệm thu

- Cùng một `maDh` luôn hiển thị tại cùng tọa độ đã lưu, không phụ thuộc thứ tự API.
- Mỗi đơn phân biệt rõ điểm lấy và điểm giao; tooltip/panel khớp với marker được nhấn.
- Đơn không có tọa độ không bị đặt về TP.HCM hoặc tọa độ giả; được báo rõ để xử lý dữ liệu.
- Mở/refresh map tự bao quát các điểm hợp lệ; marker không bị card tiêu đề che khuất.
- Dashboard và trang “Bản đồ trực tuyến” dùng cùng dữ liệu/map mapper nên kết quả nhất quán.

## Ghi chú xác minh

- `flutter analyze` được khởi chạy để kiểm tra tĩnh nhưng hết thời gian 60 giây trước khi trả kết quả; báo cáo này dựa trên việc rà soát mã nguồn.
- Workspace đã có thay đổi sẵn ở các file generated plugin cho Linux/macOS/Windows. Báo cáo này không chỉnh sửa các file đó.
