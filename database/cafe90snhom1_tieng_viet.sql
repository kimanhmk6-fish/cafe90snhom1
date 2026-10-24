-- =========================================================
-- GÓC CÀ PHÊ 90S - KHỞI TẠO CƠ SỞ DỮ LIỆU
-- 12 bảng theo ERD; dữ liệu mẫu hiển thị bằng tiếng Việt có dấu
-- Database: cafe90snhom1
-- Dữ liệu mẫu sản phẩm (P-01, Kim Anh): 3 danh mục + 21 món theo chuẩn UC
-- đã chốt 25/10/2026 — S = giá gốc, M +5.000đ, L +10.000đ; bánh không size.
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

-- 2. USER_PROFILES: thông tin chi tiết của tài khoản
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
-- Theo ERD, bảng liên kết bằng email logic, không tạo khóa ngoại.
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

-- 7. PRODUCT_SIZES: giá theo kích cỡ; bánh không cần dòng trong bảng này
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

-- 11. ORDER_DETAILS: chi tiết đơn hàng, lưu tên/giá tại thời điểm mua
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

-- 12. PAYMENTS: mỗi đơn hàng có tối đa một bản ghi thanh toán
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
-- DỮ LIỆU MẪU
-- =========================================================

INSERT INTO categories (name, slug, description, is_active) VALUES
('Cà phê', 'ca-phe', 'Cà phê pha phin, pha máy kiểu 90s.', 1),
('Trà & Đá xay', 'tra-da-xay', 'Trà trái cây, trà sữa, sinh tố & đá xay.', 1),
('Bánh ngọt & Ăn nhẹ', 'banh-ngot-an-nhe', 'Ăn kèm cho buổi cà phê thêm trọn.', 1);

INSERT INTO sizes (name, description, sort_order) VALUES
('S', 'Nhỏ', 1),
('M', 'Vừa', 2),
('L', 'Lớn', 3);

-- Đồ uống: base_price là giá size S; size M cộng 5.000đ; size L cộng 10.000đ.
-- Bánh có giá cố định (base_price) nên không tạo dòng trong product_sizes.
-- 21 món: 6 cà phê + 10 trà & đá xay + 5 bánh. is_featured = 1 là món nổi bật trang chủ (UC01).
INSERT INTO products
(category_id, name, slug, description, image, base_price, is_featured, is_active)
SELECT c.id, p.name, p.slug, p.description, p.image, p.base_price, p.is_featured, 1
FROM (
    SELECT 'Cà phê đen đá' AS name, 'ca-phe-den-da' AS slug,
           'Pha phin truyền thống, đậm vị 90s.' AS description,
           'uploads/product/ca-phe-den-da.jpg' AS image, 22000 AS base_price, 1 AS is_featured,
           'ca-phe' AS category_slug
    UNION ALL
    SELECT 'Cà phê sữa đá', 'ca-phe-sua-da',
           'Sữa đặc + cà phê phin, quốc dân.',
           'uploads/product/ca-phe-sua-da.jpg', 25000, 1, 'ca-phe'
    UNION ALL
    SELECT 'Bạc xỉu', 'bac-xiu',
           'Nhiều sữa, ít cà phê — cho team sợ đắng.',
           'uploads/product/bac-xiu.jpg', 27000, 0, 'ca-phe'
    UNION ALL
    SELECT 'Cà phê trứng', 'ca-phe-trung',
           'Lớp kem trứng béo ngậy kiểu Hà Nội xưa.',
           'uploads/product/ca-phe-trung.jpg', 35000, 1, 'ca-phe'
    UNION ALL
    SELECT 'Cold brew cam sả', 'cold-brew-cam-sa',
           'Ủ lạnh 18h, thơm cam sả tươi.',
           'uploads/product/cold-brew-cam-sa.jpg', 38000, 0, 'ca-phe'
    UNION ALL
    SELECT 'Cà phê cốt dừa', 'ca-phe-cot-dua',
           'Cà phê + cốt dừa xay đá mát lạnh.',
           'uploads/product/ca-phe-cot-dua.jpg', 35000, 0, 'ca-phe'
    UNION ALL
    SELECT 'Trà đào cam sả', 'tra-dao-cam-sa',
           'Best-seller: đào giòn, cam sả thơm.',
           'uploads/product/tra-dao-cam-sa.jpg', 32000, 1, 'tra-da-xay'
    UNION ALL
    SELECT 'Trà vải', 'tra-vai',
           'Vải thiều ngọt thanh.',
           'uploads/product/tra-vai.jpg', 30000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Trà sữa trân châu đường đen', 'tra-sua-tran-chau-duong-den',
           'Trân châu dẻo nấu mỗi ngày.',
           'uploads/product/tra-sua-tran-chau-duong-den.jpg', 32000, 1, 'tra-da-xay'
    UNION ALL
    SELECT 'Hồng trà sữa', 'hong-tra-sua',
           'Vị trà đậm, ít ngọt.',
           'uploads/product/hong-tra-sua.jpg', 28000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Trà chanh giã tay', 'tra-chanh-gia-tay',
           'Chanh giã tay thơm the.',
           'uploads/product/tra-chanh-gia-tay.jpg', 25000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Trà atiso', 'tra-atiso',
           'Thanh nhiệt, không caffeine.',
           'uploads/product/tra-atiso.jpg', 22000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Nước cam ép', 'nuoc-cam-ep',
           'Cam sành ép nguyên chất.',
           'uploads/product/nuoc-cam-ep.jpg', 30000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Sinh tố bơ', 'sinh-to-bo',
           'Bơ sáp dẻo + sữa đặc.',
           'uploads/product/sinh-to-bo.jpg', 35000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Nước ép dưa hấu', 'nuoc-ep-dua-hau',
           'Giải khát mùa nóng.',
           'uploads/product/nuoc-ep-dua-hau.jpg', 25000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Chanh dây đá xay', 'chanh-day-da-xay',
           'Chua ngọt sảng khoái.',
           'uploads/product/chanh-day-da-xay.jpg', 32000, 0, 'tra-da-xay'
    UNION ALL
    SELECT 'Bánh mì pate', 'banh-mi-pate',
           'Pate gan béo, bánh mì giòn.',
           'uploads/product/banh-mi-pate.jpg', 25000, 0, 'banh-ngot-an-nhe'
    UNION ALL
    SELECT 'Croissant trứng muối', 'croissant-trung-muoi',
           'Ngàn lớp bơ + nhân trứng muối chảy.',
           'uploads/product/croissant-trung-muoi.jpg', 35000, 1, 'banh-ngot-an-nhe'
    UNION ALL
    SELECT 'Bánh flan', 'banh-flan',
           'Caramel đắng nhẹ kiểu cũ.',
           'uploads/product/banh-flan.jpg', 18000, 0, 'banh-ngot-an-nhe'
    UNION ALL
    SELECT 'Bông lan trứng muối', 'bong-lan-trung-muoi',
           'Sốt phô mai + chà bông.',
           'uploads/product/bong-lan-trung-muoi.jpg', 45000, 0, 'banh-ngot-an-nhe'
    UNION ALL
    SELECT 'Khoai tây chiên', 'khoai-tay-chien',
           'Giòn rụm, chấm tương ớt/mayo.',
           'uploads/product/khoai-tay-chien.jpg', 35000, 0, 'banh-ngot-an-nhe'
) AS p
JOIN categories c ON c.slug = p.category_slug;

-- Tạo giá theo kích cỡ cho đồ uống (danh mục Cà phê và Trà & Đá xay): 16 món x 3 size = 48 dòng.
-- Bánh ngọt & Ăn nhẹ không có dòng trong bảng này (giá cố định ở products.base_price).
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
WHERE c.slug IN ('ca-phe', 'tra-da-xay');

-- Không tạo tài khoản, giỏ hàng, đơn hàng và thanh toán giả.
-- Các bảng này sẽ có dữ liệu khi người dùng thực hiện chức năng trên website.

-- Kiểm tra số lượng dữ liệu mẫu sau khi import:
SELECT 'Danh mục' AS bang_du_lieu, COUNT(*) AS so_ban_ghi FROM categories
UNION ALL SELECT 'Kích cỡ', COUNT(*) FROM sizes
UNION ALL SELECT 'Sản phẩm', COUNT(*) FROM products
UNION ALL SELECT 'Giá theo kích cỡ', COUNT(*) FROM product_sizes;
