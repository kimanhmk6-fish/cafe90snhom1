<?php
/** [L-01] Footer dùng chung cho phía Client + đóng thẻ main/body/html. */
?>
</main>
<footer class="site-footer">
    <div class="container footer-grid">
        <div class="footer-brand">
            <p class="logo">Góc Cà Phê <span>90s</span></p>
            <p>Hương vị cà phê Việt thập niên 90 — pha phin chậm rãi,
               nghe nhạc xưa và ôn lại chuyện cũ.</p>
        </div>
        <div class="footer-col">
            <h4>Khám phá</h4>
            <a href="/">Trang chủ</a>
            <a href="/thuc-don">Thực đơn</a>
            <a href="/tim-kiem">Tìm kiếm món</a>
            <a href="/gio-hang">Giỏ hàng</a>
        </div>
        <div class="footer-col">
            <h4>Thông tin quán</h4>
            <p>Giờ mở cửa: 07:00 — 22:00 hằng ngày</p>
            <p>Đặt món online, thanh toán VietQR tại quầy hoặc khi nhận món.</p>
        </div>
    </div>
    <div class="footer-bottom">
        <p>&copy; <?= date('Y') ?> Góc Cà Phê 90s — Bài tập lớn PHP OOP, Nhóm 1.</p>
    </div>
</footer>
<script src="/assets/js/main.js"></script>
</body>
</html>
