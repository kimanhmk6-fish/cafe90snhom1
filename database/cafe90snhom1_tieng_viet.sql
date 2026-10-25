-- =========================================================
-- GÓC CÀ PHÊ 90S - KHỞI TẠO CƠ SỞ DỮ LIỆU + DỮ LIỆU MẪU
-- 12 bảng theo ERD (Cách 2 – có product_sizes)
-- Database: cafe90snhom1
-- =========================================================
-- Hướng dẫn:
-- 1. Import file này trên phpMyAdmin / MySQL Workbench / CLI
-- 2. Tài khoản mẫu (mật khẩu mặc định: password):
--      khach1@example.com  (customer)
--      khach2@example.com  (customer)
--      admin@example.com   (admin)
-- 3. Nên thay hash mật khẩu bằng password_hash('Cafe90s@123', PASSWORD_DEFAULT)
-- =========================================================

CREATE DATABASE IF NOT EXISTS cafe90snhom1
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cafe90snhom1;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_details;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS product_sizes;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS sizes;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS password_resets;
DROP TABLE IF EXISTS user_profiles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- PHẦN 1: TẠO 12 BẢNG
-- =========================================================

-- 1. USERS: tài khoản đăng nhập
CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    remember_token VARCHAR(100) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. USER_PROFILES: thông tin chi tiết của tài khoản (1-1 với users)
CREATE TABLE user_profiles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    full_name VARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    address TEXT NULL,
    avatar VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_profiles_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. PASSWORD_RESETS: mã/token đặt lại mật khẩu
CREATE TABLE password_resets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(150) NOT NULL,
    token VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_password_resets_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. CATEGORIES: danh mục sản phẩm
CREATE TABLE categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    description TEXT NULL,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. SIZES: kích cỡ đồ uống
CREATE TABLE sizes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(10) NOT NULL UNIQUE,
    description VARCHAR(50) NULL,
    sort_order TINYINT UNSIGNED NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. PRODUCTS: sản phẩm
CREATE TABLE products (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    category_id INT UNSIGNED NOT NULL,
    name VARCHAR(150) NOT NULL,
    slug VARCHAR(170) NOT NULL UNIQUE,
    description TEXT NULL,
    image VARCHAR(255) NULL,
    base_price DECIMAL(12,0) NOT NULL,
    is_featured TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_products_base_price CHECK (base_price >= 0),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_products_category_id (category_id),
    INDEX idx_products_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. PRODUCT_SIZES: giá theo kích cỡ
--    Chỉ sản phẩm đồ uống (Cà phê, Trà) có dòng trong bảng này.
--    Bánh không có dòng → không hiện chọn size, dùng base_price.
CREATE TABLE product_sizes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id INT UNSIGNED NOT NULL,
    size_id INT UNSIGNED NOT NULL,
    price DECIMAL(12,0) NOT NULL,
    UNIQUE KEY uq_product_size (product_id, size_id),
    CONSTRAINT chk_product_sizes_price CHECK (price >= 0),
    CONSTRAINT fk_product_sizes_product
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_product_sizes_size
        FOREIGN KEY (size_id) REFERENCES sizes(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. CARTS: mỗi tài khoản có tối đa một giỏ hàng
CREATE TABLE carts (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_carts_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. CART_ITEMS: sản phẩm trong giỏ hàng
--    size_id cho phép NULL (dành cho bánh)
CREATE TABLE cart_items (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    cart_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    size_id INT UNSIGNED NULL,
    quantity INT UNSIGNED NOT NULL DEFAULT 1,
    UNIQUE KEY uq_cart_product_size (cart_id, product_id, size_id),
    CONSTRAINT chk_cart_items_quantity CHECK (quantity >= 1),
    CONSTRAINT fk_cart_items_cart
        FOREIGN KEY (cart_id) REFERENCES carts(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_cart_items_product
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cart_items_size
        FOREIGN KEY (size_id) REFERENCES sizes(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_cart_items_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. ORDERS: đơn hàng
CREATE TABLE orders (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    order_code VARCHAR(30) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20) NOT NULL,
    shipping_address TEXT NOT NULL,
    note TEXT NULL,
    subtotal DECIMAL(12,0) NOT NULL DEFAULT 0,
    shipping_fee DECIMAL(12,0) NOT NULL DEFAULT 15000,
    total_amount DECIMAL(12,0) NOT NULL,
    status ENUM('pending', 'confirmed', 'preparing', 'shipping', 'completed', 'cancelled')
        NOT NULL DEFAULT 'pending',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_orders_subtotal CHECK (subtotal >= 0),
    CONSTRAINT chk_orders_shipping_fee CHECK (shipping_fee >= 0),
    CONSTRAINT chk_orders_total CHECK (total_amount >= 0),
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_orders_user_id (user_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. ORDER_DETAILS: chi tiết đơn hàng (snapshot tên/giá tại thời điểm mua)
--     size_id / size_name cho phép NULL (dành cho bánh)
CREATE TABLE order_details (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    size_id INT UNSIGNED NULL,
    product_name VARCHAR(150) NOT NULL,
    size_name VARCHAR(10) NULL,
    price DECIMAL(12,0) NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    total DECIMAL(12,0) NOT NULL,
    CONSTRAINT chk_order_details_price CHECK (price >= 0),
    CONSTRAINT chk_order_details_quantity CHECK (quantity >= 1),
    CONSTRAINT chk_order_details_total CHECK (total >= 0),
    CONSTRAINT fk_order_details_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_order_details_product
        FOREIGN KEY (product_id) REFERENCES products(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_order_details_size
        FOREIGN KEY (size_id) REFERENCES sizes(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_order_details_order_id (order_id),
    INDEX idx_order_details_product_id (product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. PAYMENTS: mỗi đơn hàng có tối đa một bản ghi thanh toán (1-1)
CREATE TABLE payments (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    order_id INT UNSIGNED NOT NULL UNIQUE,
    payment_method VARCHAR(50) NOT NULL DEFAULT 'bank_transfer',
    amount DECIMAL(12,0) NOT NULL,
    status ENUM('pending', 'paid', 'failed') NOT NULL DEFAULT 'pending',
    transaction_code VARCHAR(100) NULL,
    paid_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_payments_amount CHECK (amount >= 0),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id) REFERENCES orders(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================
-- PHẦN 2: DỮ LIỆU MẪU – DANH MỤC, SIZE, SẢN PHẨM
-- =========================================================

INSERT INTO categories (name, slug, description, is_active) VALUES
('Cà phê', 'ca-phe', 'Các loại cà phê pha chế, phù hợp để thưởng thức mỗi ngày.', 1),
('Trà', 'tra', 'Các loại trà trái cây thơm ngon và thanh mát.', 1),
('Bánh', 'banh', 'Các loại bánh ngọt dùng kèm đồ uống.', 1);

INSERT INTO sizes (name, description, sort_order) VALUES
('S', 'Nhỏ', 1),
('M', 'Vừa', 2),
('L', 'Lớn', 3);

-- Đồ uống: base_price = giá size S; M = +5.000đ; L = +10.000đ.
-- Bánh: giá cố định, KHÔNG tạo dòng trong product_sizes.
INSERT INTO products
(category_id, name, slug, description, image, base_price, is_featured, is_active)
SELECT c.id, p.name, p.slug, p.description, p.image, p.base_price, p.is_featured, 1
FROM (
    SELECT 'Cà phê sữa đá' AS name, 'ca-phe-sua-da' AS slug,
           'Cà phê đậm đà kết hợp sữa đặc, dùng cùng đá mát lạnh.' AS description,
           'uploads/product/ca-phe-sua-da.jpg' AS image, 30000 AS base_price, 1 AS is_featured,
           'ca-phe' AS category_slug
    UNION ALL
    SELECT 'Bạc xỉu', 'bac-xiu',
           'Vị sữa béo nhẹ hòa quyện cùng hương cà phê dịu dàng.',
           'uploads/product/bac-xiu.jpg', 32000, 1, 'ca-phe'
    UNION ALL
    SELECT 'Cà phê đen đá', 'ca-phe-den-da',
           'Cà phê đen đậm vị, dành cho người yêu thích hương vị nguyên bản.',
           'uploads/product/ca-phe-den-da.jpg', 25000, 0, 'ca-phe'
    UNION ALL
    SELECT 'Latte', 'latte',
           'Espresso kết hợp sữa tươi đánh bọt mềm mịn.',
           'uploads/product/latte.jpg', 40000, 0, 'ca-phe'
    UNION ALL
    SELECT 'Trà đào', 'tra-dao',
           'Trà đào thanh mát với hương đào thơm dịu.',
           'uploads/product/tra-dao.jpg', 35000, 1, 'tra'
    UNION ALL
    SELECT 'Trà vải', 'tra-vai',
           'Trà vải thơm ngọt, ngon hơn khi dùng lạnh.',
           'uploads/product/tra-vai.jpg', 35000, 0, 'tra'
    UNION ALL
    SELECT 'Trà chanh mật ong', 'tra-chanh-mat-ong',
           'Trà chanh chua dịu kết hợp vị ngọt tự nhiên của mật ong.',
           'uploads/product/tra-chanh-mat-ong.jpg', 30000, 0, 'tra'
    UNION ALL
    SELECT 'Bánh sừng bò bơ', 'banh-sung-bo-bo',
           'Bánh sừng bò nhiều lớp, thơm mùi bơ.',
           'uploads/product/banh-sung-bo-bo.jpg', 25000, 0, 'banh'
    UNION ALL
    SELECT 'Bánh Tiramisu', 'banh-tiramisu',
           'Bánh Tiramisu mềm mịn với hương cà phê và cacao.',
           'uploads/product/banh-tiramisu.jpg', 35000, 1, 'banh'
) AS p
JOIN categories c ON c.slug = p.category_slug;

-- Tạo giá theo kích cỡ CHỈ cho sản phẩm thuộc danh mục Cà phê và Trà.
INSERT INTO product_sizes (product_id, size_id, price)
SELECT p.id, s.id,
       p.base_price + CASE s.name
           WHEN 'S' THEN 0
           WHEN 'M' THEN 5000
           WHEN 'L' THEN 10000
       END AS price
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN sizes s
WHERE c.slug IN ('ca-phe', 'tra');

-- =========================================================
-- PHẦN 3: DỮ LIỆU MẪU – TÀI KHOẢN, GIỎ HÀNG, ĐƠN HÀNG
-- =========================================================
-- Mật khẩu mặc định của các tài khoản mẫu: password
-- Hash: $2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi
-- (hash mẫu Laravel/PHP, tương ứng chuỗi "password")
-- Nên thay bằng hash thực tế tạo từ password_hash('Cafe90s@123', PASSWORD_DEFAULT)

START TRANSACTION;

-- 3.1. Tài khoản: 2 khách + 1 admin
INSERT INTO users (email, password, role, is_active, remember_token)
VALUES
('khach1@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi', 'customer', 1, NULL),
('khach2@example.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi', 'customer', 1, NULL),
('admin@example.com',  '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2uheWG/igi',  'admin',    1, NULL);

SET @user1_id = (SELECT id FROM users WHERE email = 'khach1@example.com' LIMIT 1);
SET @user2_id = (SELECT id FROM users WHERE email = 'khach2@example.com' LIMIT 1);
SET @admin_id = (SELECT id FROM users WHERE email = 'admin@example.com' LIMIT 1);

INSERT INTO user_profiles (user_id, full_name, phone, address, avatar)
VALUES
(@user1_id, 'Nguyễn Minh Anh', '0901000001', 'Cầu Giấy, Hà Nội', NULL),
(@user2_id, 'Trần Hoàng Nam', '0901000002', 'Đống Đa, Hà Nội', NULL),
(@admin_id, 'Quản trị viên', '0901000003', 'Hà Nội', NULL);

-- 3.2. Lấy ID sản phẩm / size theo slug (không hard-code ID)
SET @product_coffee    = (SELECT id FROM products WHERE slug = 'ca-phe-sua-da' LIMIT 1);
SET @product_tea       = (SELECT id FROM products WHERE slug = 'tra-dao' LIMIT 1);
SET @product_cake      = (SELECT id FROM products WHERE slug = 'banh-tiramisu' LIMIT 1);
SET @product_croissant = (SELECT id FROM products WHERE slug = 'banh-sung-bo-bo' LIMIT 1);
SET @size_s = (SELECT id FROM sizes WHERE name = 'S' LIMIT 1);
SET @size_m = (SELECT id FROM sizes WHERE name = 'M' LIMIT 1);
SET @size_l = (SELECT id FROM sizes WHERE name = 'L' LIMIT 1);

-- 3.3. Giỏ hàng mẫu cho 2 khách
INSERT INTO carts (user_id) VALUES (@user1_id), (@user2_id);
SET @cart1_id = (SELECT id FROM carts WHERE user_id = @user1_id LIMIT 1);
SET @cart2_id = (SELECT id FROM carts WHERE user_id = @user2_id LIMIT 1);

INSERT INTO cart_items (cart_id, product_id, size_id, quantity)
VALUES
(@cart1_id, @product_coffee, @size_m, 2),   -- Cà phê sữa đá size M x2
(@cart1_id, @product_cake,   NULL,    1),   -- Bánh Tiramisu (không size)
(@cart2_id, @product_tea,    @size_l, 1);   -- Trà đào size L x1

-- 3.4. Đơn hàng mẫu (5 đơn với các trạng thái khác nhau)
INSERT INTO orders
(user_id, order_code, customer_name, customer_phone, shipping_address, note,
 subtotal, shipping_fee, total_amount, status)
VALUES
(@user1_id, 'DH-MAU-001', 'Nguyễn Minh Anh', '0901000001', 'Cầu Giấy, Hà Nội',
 'Đơn chờ xác nhận - dữ liệu mẫu', 70000, 15000, 85000, 'pending'),
(@user1_id, 'DH-MAU-002', 'Nguyễn Minh Anh', '0901000001', 'Cầu Giấy, Hà Nội',
 'Đơn đã xác nhận - dữ liệu mẫu', 80000, 15000, 95000, 'confirmed'),
(@user1_id, 'DH-MAU-003', 'Nguyễn Minh Anh', '0901000001', 'Cầu Giấy, Hà Nội',
 'Đơn hoàn thành - dữ liệu mẫu', 30000, 15000, 45000, 'completed'),
(@user2_id, 'DH-MAU-004', 'Trần Hoàng Nam', '0901000002', 'Đống Đa, Hà Nội',
 'Đơn đang chuẩn bị - dữ liệu mẫu', 40000, 15000, 55000, 'preparing'),
(@user2_id, 'DH-MAU-005', 'Trần Hoàng Nam', '0901000002', 'Đống Đa, Hà Nội',
 'Đơn đã hủy - dữ liệu mẫu', 25000, 15000, 40000, 'cancelled');

SET @order1_id = (SELECT id FROM orders WHERE order_code = 'DH-MAU-001' LIMIT 1);
SET @order2_id = (SELECT id FROM orders WHERE order_code = 'DH-MAU-002' LIMIT 1);
SET @order3_id = (SELECT id FROM orders WHERE order_code = 'DH-MAU-003' LIMIT 1);
SET @order4_id = (SELECT id FROM orders WHERE order_code = 'DH-MAU-004' LIMIT 1);
SET @order5_id = (SELECT id FROM orders WHERE order_code = 'DH-MAU-005' LIMIT 1);

INSERT INTO order_details
(order_id, product_id, size_id, product_name, size_name, price, quantity, total)
VALUES
(@order1_id, @product_coffee,    @size_m, 'Cà phê sữa đá', 'M', 35000, 2, 70000),
(@order2_id, @product_tea,       @size_l, 'Trà đào',       'L', 45000, 1, 45000),
(@order2_id, @product_cake,      NULL,    'Bánh Tiramisu', NULL, 35000, 1, 35000),
(@order3_id, @product_coffee,    @size_s, 'Cà phê sữa đá', 'S', 30000, 1, 30000),
(@order4_id, @product_tea,       @size_m, 'Trà đào',       'M', 40000, 1, 40000),
(@order5_id, @product_croissant, NULL,    'Bánh sừng bò bơ', NULL, 25000, 1, 25000);

INSERT INTO payments (order_id, payment_method, amount, status, transaction_code, paid_at)
VALUES
(@order1_id, 'bank_transfer', 85000,  'pending', NULL,          NULL),
(@order2_id, 'bank_transfer', 95000,  'paid',    'DEMO-TXN-002', NOW()),
(@order3_id, 'bank_transfer', 45000,  'paid',    'DEMO-TXN-003', NOW()),
(@order4_id, 'bank_transfer', 55000,  'paid',    'DEMO-TXN-004', NOW()),
(@order5_id, 'bank_transfer', 40000,  'failed',  'DEMO-TXN-005', NULL);

COMMIT;

-- =========================================================
-- PHẦN 4: KIỂM TRA SAU KHI IMPORT
-- =========================================================

SELECT 'Danh mục'          AS bang_du_lieu, COUNT(*) AS so_ban_ghi FROM categories
UNION ALL SELECT 'Kích cỡ',                 COUNT(*) FROM sizes
UNION ALL SELECT 'Sản phẩm',                COUNT(*) FROM products
UNION ALL SELECT 'Giá theo kích cỡ',        COUNT(*) FROM product_sizes
UNION ALL SELECT 'Tài khoản',               COUNT(*) FROM users
UNION ALL SELECT 'Hồ sơ',                   COUNT(*) FROM user_profiles
UNION ALL SELECT 'Giỏ hàng',                COUNT(*) FROM carts
UNION ALL SELECT 'Dòng giỏ hàng',           COUNT(*) FROM cart_items
UNION ALL SELECT 'Đơn hàng',                COUNT(*) FROM orders
UNION ALL SELECT 'Chi tiết đơn',            COUNT(*) FROM order_details
UNION ALL SELECT 'Thanh toán',              COUNT(*) FROM payments;

SELECT id, email, role FROM users
WHERE email IN ('khach1@example.com', 'khach2@example.com', 'admin@example.com');

SELECT order_code, customer_name, subtotal, shipping_fee, total_amount, status
FROM orders
WHERE order_code LIKE 'DH-MAU-%'
ORDER BY order_code;

-- =========================================================
-- GHI CHÚ MẬT KHẨU
-- =========================================================
-- Hash hiện tại tương ứng chuỗi "password".
-- Để dùng mật khẩu riêng (ví dụ Cafe90s@123):
--   1) Tạo file temp_hash.php:
--        <?php echo password_hash('Cafe90s@123', PASSWORD_DEFAULT), PHP_EOL;
--   2) Chạy: php temp_hash.php
--   3) Copy hash và UPDATE users SET password = '...' WHERE email = '...';
--   4) Xóa temp_hash.php
-- =========================================================
