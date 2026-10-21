
# LAB 2 - CALMS SELF-ASSESSMENT

## 5.1. Tự đánh giá DevOps Maturity

| Nguyên tắc | 1 (Yếu) | 3 (Trung bình) | 5 (Xuất sắc) | Điểm của tôi |
|---|---|---|---|---|
| Culture | Dev và Ops đổ lỗi cho nhau | Dev và Ops cùng làm việc | Mọi người cùng chịu trách nhiệm production | 2/5 |
| Automation | Deploy hoàn toàn thủ công | Có CI/CD cho một số dự án | Toàn bộ pipeline được tự động hóa | 3/5 |
| Lean | Setup môi trường mất hơn 1 ngày | Có sử dụng script và Docker | Một lệnh thiết lập toàn bộ môi trường | 4/5 |
| Measurement | Không biết ứng dụng có đang chạy không | Có monitoring cơ bản | Dashboard real-time và cảnh báo tự động | 2/5 |
| Sharing | Không có tài liệu chia sẻ | Có tài liệu hướng dẫn | Code Review, post-mortem và chia sẻ kiến thức | 3/5 |
| **TỔNG** | | | | **14/25** |

### Nhận xét

- Culture (2/5): Chưa có nhiều kinh nghiệm phối hợp giữa Dev và Ops.
- Automation (3/5): Đã thực hành GitHub Actions và script tự động thiết lập môi trường.
- Lean (4/5): Đã sử dụng Docker để đóng gói ứng dụng và đồng nhất môi trường chạy.
- Measurement (2/5): Mới kiểm tra trạng thái container và ứng dụng, chưa có hệ thống monitoring.
- Sharing (3/5): Đã viết tài liệu Markdown và sơ đồ DevOps Toolchain để chia sẻ kiến thức.

## 5.2. Kế hoạch cải thiện

### Hành động 1: Tăng cường Automation
- Sử dụng GitHub Actions để tự động build và test.
- Giảm thao tác thủ công khi triển khai ứng dụng.

### Hành động 2: Cải thiện Measurement
- Tìm hiểu Prometheus và Grafana.
- Theo dõi CPU, RAM, trạng thái container và thời gian phản hồi của ứng dụng.

### Hành động 3: Nâng cao Culture và Sharing
- Sử dụng GitHub để quản lý và chia sẻ mã nguồn.
- Viết README hướng dẫn cài đặt và sử dụng dự án.
- Thực hành Code Review khi làm việc nhóm.

## Kết luận

Tổng điểm tự đánh giá là 14/25.

Qua Lab 2, tôi đã hiểu rõ hơn về 5 nguyên tắc
CALMS và thực hành tự động hóa môi trường
phát triển bằng PowerShell và Docker.

Trong thời gian tới, tôi cần cải thiện kỹ năng
làm việc nhóm, đo lường hệ thống và xây dựng
CI/CD pipeline hoàn chỉnh.
