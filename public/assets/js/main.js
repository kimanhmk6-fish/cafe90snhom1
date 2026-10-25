// [L-01] JS nền phía Client — hiện chỉ có mở/đóng menu mobile.
// JS riêng của từng trang (giỏ hàng AJAX, modal món...) thuộc các thẻ sau.
document.addEventListener('DOMContentLoaded', function () {
    var toggle = document.querySelector('[data-nav-toggle]');
    var nav = document.querySelector('[data-main-nav]');

    if (toggle && nav) {
        toggle.addEventListener('click', function () {
            nav.classList.toggle('open');
        });
    }
});
