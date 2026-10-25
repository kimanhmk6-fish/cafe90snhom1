<?php
/**
 * [L-01] Layout Client — khung trang dùng chung (header/footer/nav).
 *
 * Cách dùng ở Controller (Tuần 2):
 *   ob_start();
 *   require __DIR__ . '/../client/home/index.php'; // view con, dùng $data
 *   $content = ob_get_clean();
 *   $pageTitle = 'Trang chủ';
 *   require __DIR__ . '/../layouts/client.php';
 *
 * Biến: $content (string, bắt buộc), $pageTitle, $currentUser, $cartCount.
 */
require __DIR__ . '/partials/header.php';

echo $content ?? '';

require __DIR__ . '/partials/footer.php';
