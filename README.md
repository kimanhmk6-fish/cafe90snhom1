# Góc Cà Phê 90s — Website đặt hàng trực tuyến

Bài tập lớn môn học: xây dựng website đặt hàng trực tuyến cho quán cà phê phong cách hoài niệm thập niên 90.

- **Công nghệ:** PHP OOP thuần theo mô hình MVC tự xây (không dùng framework, không dùng lại code thủ tục cũ)
- **Cơ sở dữ liệu:** MySQL — database `cafe90s_oop`
- **Nhóm:** 4 thành viên — lộ trình thực hiện 3 tuần (21 ngày)
- **Quản lý công việc:** Trello board "Góc Cà Phê 90" — https://trello.com/b/gqzIs74o

## Phạm vi dự án

**Phía khách hàng (Client):** trang chủ; thực đơn (tìm kiếm, lọc theo danh mục, phân trang, xem chi tiết món, chọn size S/M/L và số lượng); đăng ký/đăng nhập/quên mật khẩu; hồ sơ cá nhân (cập nhật thông tin, upload avatar, đổi mật khẩu, lịch sử đơn hàng); giỏ hàng; đặt hàng và thanh toán chuyển khoản VietQR; theo dõi trạng thái đơn hàng.

**Phía quản trị (Admin):** đăng nhập và phân quyền Admin; quản lý sản phẩm và danh mục (CRUD, tìm kiếm, phân trang, upload ảnh); quản lý đơn hàng (tìm kiếm, lọc, cập nhật trạng thái); quản lý người dùng (tìm kiếm, phân trang, đổi vai trò, khóa/mở tài khoản); dashboard thống kê cơ bản.

**Ngoài phạm vi (đã thống nhất loại bỏ):** tin tức/bài viết, món yêu thích, đánh giá sản phẩm, phản hồi/liên hệ, đặt bàn. Không tạo bảng, Model, View hay chức năng cho các phần này.

## Phân công theo module dọc

Mỗi thành viên phụ trách trọn gói module của mình: Database → Model → Controller → View → JS → Test → Tài liệu.

| Thành viên | Module | Nội dung chính |
| --- | --- | --- |
| Kim Anh | Sản phẩm & Thực đơn | Bảng `categories`, `products`, `sizes`, `product_sizes`; Trang chủ, Thực đơn; Admin quản lý Menu & Danh mục |
| Phương Anh | Giỏ hàng & Đơn hàng | Bảng `cart_items`, `orders`, `order_details`, `payments`; Giỏ hàng, Thanh toán VietQR, Theo dõi đơn; Admin quản lý Đơn hàng |
| Hải Anh (nhóm trưởng) | Tài khoản & Core dùng chung | Bảng `users`, `user_profiles`, `password_resets`; Database (PDO), BaseModel, Pagination, Auth Middleware; Đăng nhập, Hồ sơ; Admin quản lý Thành viên |
| Hoàng Anh | Giao diện Admin & Tiện ích | Upload Helper, Layout Admin, Dashboard cơ bản, màn hình chi tiết đơn; kiểm thử và hoàn thiện phần Admin, tài liệu |

## Cấu trúc thư mục

```
cafe90snhom1/
├── public/                 # Thư mục web root - index.php là Front Controller duy nhất
│   └── assets/             # CSS, JS, hình ảnh tĩnh (css/ js/ img/)
├── app/
│   ├── Core/               # Database, Router, Controller, Model, View, Pagination, Upload, Auth
│   ├── Models/             # Mỗi thực thể là 1 class Model
│   ├── Controllers/
│   │   ├── Client/         # Controller phía khách hàng
│   │   └── Admin/          # Controller phía quản trị
│   └── Views/
│       ├── client/         # Giao diện khách hàng
│       ├── admin/          # Giao diện quản trị
│       └── layouts/        # Layout dùng chung
├── config/                 # config.php - cấu hình kết nối CSDL, hằng số hệ thống
├── database/               # cafe90s_oop.sql (cấu trúc) + seed.sql (dữ liệu mẫu)
└── uploads/
    ├── avatars/            # Ảnh đại diện người dùng upload
    └── products/           # Ảnh sản phẩm upload
```

## Cài đặt và chạy dự án

**Yêu cầu môi trường:** PHP 8.x, MySQL/MariaDB, Apache (khuyến nghị dùng XAMPP).

1. Clone repo và đặt thư mục dự án vào `htdocs` của XAMPP:

   ```bash
   git clone https://github.com/kimanhmk6-fish/cafe90snhom1.git
   ```

2. Tạo database `cafe90s_oop` trong phpMyAdmin, sau đó import lần lượt:
   - `database/cafe90s_oop.sql` (cấu trúc bảng)
   - `database/seed.sql` (dữ liệu mẫu)

   *(Hai file SQL được tạo ở Ngày 5 — Tuần 1 của lộ trình.)*

3. Kiểm tra thông tin kết nối CSDL trong `config/config.php` (host, dbname, username, password) cho khớp máy của bạn.
4. Trỏ DocumentRoot của Apache vào thư mục `public/` (hoặc dùng Virtual Host), khởi động Apache + MySQL.
5. Mở trình duyệt tại địa chỉ đã cấu hình để vào trang chủ.

**Tài khoản demo:** sẽ bổ sung sau khi seed dữ liệu (gồm 1 tài khoản Admin và tài khoản khách mẫu).

## Quy ước code (bắt buộc với cả nhóm)

- Mọi truy vấn dùng **PDO + Prepared Statement**; mật khẩu lưu bằng `password_hash()` / kiểm tra bằng `password_verify()`.
- Tách hoàn toàn SQL khỏi View; View chỉ hiển thị dữ liệu Controller truyền sang.
- Mọi form validate cả phía client (JS) và phía server.
- Tên class/file dùng PascalCase, tên method dùng camelCase.
- Upload file: chỉ cho phép `jpg/png/webp`, tối đa 2MB, kiểm tra mime type thật, đổi tên file bằng `uniqid()`.

## Quy ước Git

- Nhánh chính: `main`. Mỗi module làm việc trên nhánh riêng và merge vào `main`:
  - `feature/san-pham` — Kim Anh
  - `feature/don-hang` — Phương Anh
  - `feature/tai-khoan` — Hải Anh
  - `feature/admin` — Hoàng Anh
- File dùng chung (layout, `config/`, Core) chỉ sửa khi đã báo trên Trello để tránh xung đột.
- Commit message theo mẫu: `[Mã card Trello] mô tả việc đã làm` — ví dụ: `[P-01] Tạo bảng products và seed 21 món`.

## Lộ trình 3 tuần

- **Tuần 1 (Ngày 1–7):** Phân tích (Xác định vấn đề, Use Case, ERD), dựng khung OOP/MVC, tạo CSDL + dữ liệu mẫu, viết Model cơ bản.
- **Tuần 2 (Ngày 8–14):** Code toàn bộ chức năng Client + Admin; cuối Ngày 11 chạy trọn luồng Đăng nhập → Đặt hàng → Thanh toán → Xem lịch sử; cuối Ngày 13 Admin quản lý được mọi dữ liệu.
- **Tuần 3 (Ngày 15–21):** Kiểm thử, rà soát bảo mật, sửa bug và đóng băng code (Ngày 18), viết báo cáo + slide (Ngày 19), tổng duyệt demo và vấn đáp (Ngày 20), nộp bài (Ngày 21).
