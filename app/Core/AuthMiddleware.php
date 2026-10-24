
<?php

namespace App\Core;

class AuthMiddleware
{
    // Kiểm tra người dùng đã đăng nhập chưa
    public static function check(): bool
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        return isset($_SESSION['user']);
    }

    // Yêu cầu đăng nhập
    public static function requireLogin(): void
    {
        if (!self::check()) {
            header('Location: /cafe90snhom1/public/login.php');
            exit;
        }
    }
}
