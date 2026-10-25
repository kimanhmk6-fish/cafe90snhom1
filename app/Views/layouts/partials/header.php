<?php
/**
 * [L-01] Header dùng chung cho phía Client.
 * Biến do Controller truyền vào:
 *   $pageTitle   (string)  Tiêu đề trang, mặc định "Góc Cà Phê 90s".
 *   $currentUser (array?)  Người dùng đang đăng nhập (UC06 — trạng thái
 *                          header); null/rỗng nếu là khách.
 *   $cartCount   (int)     Số lượng món trong giỏ, mặc định 0.
 */
$pageTitle = $pageTitle ?? 'Góc Cà Phê 90s';
$currentUser = $currentUser ?? null;
$cartCount = $cartCount ?? 0;
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($pageTitle) ?> — Góc Cà Phê 90s</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:wght@400;500;700&family=Playfair+Display:ital,wght@0,600;0,800;1,600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/assets/css/style.css">
</head>
<body>
<header class="site-header">
    <div class="container header-inner">
        <a class="logo" href="/">Góc Cà Phê <span>90s</span></a>

        <button class="nav-toggle" type="button" aria-label="Mở menu" data-nav-toggle>
            &#9776;
        </button>

        <nav class="main-nav" data-main-nav>
            <a href="/">Trang chủ</a>
            <a href="/thuc-don">Thực đơn</a>
            <a href="/#cau-chuyen">Câu chuyện quán</a>
            <a href="/tim-kiem">Tìm kiếm</a>
        </nav>

        <div class="header-actions">
            <a class="cart-link" href="/gio-hang">
                Giỏ hàng
                <?php if ($cartCount > 0): ?>
                    <span class="cart-badge"><?= (int) $cartCount ?></span>
                <?php endif; ?>
            </a>
            <?php if (!empty($currentUser)): ?>
                <span class="user-greeting">
                    Xin chào, <?= htmlspecialchars($currentUser['full_name'] ?? $currentUser['email'] ?? '') ?>
                </span>
                <a href="/ho-so">Hồ sơ</a>
                <a href="/dang-xuat">Đăng xuất</a>
            <?php else: ?>
                <a href="/dang-nhap">Đăng nhập</a>
                <a class="btn btn-small" href="/dang-ky">Đăng ký</a>
            <?php endif; ?>
        </div>
    </div>
</header>
<main class="site-main">
