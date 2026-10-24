
<?php

namespace App\Core;

class Pagination
{
    private int $currentPage;
    private int $perPage;
    private int $totalRecords;

    public function __construct(
        int $totalRecords,
        int $currentPage = 1,
        int $perPage = 8
    ) {
        $this->totalRecords = max(0, $totalRecords);
        $this->perPage = max(1, $perPage);

        $totalPages = $this->getTotalPages();

        $this->currentPage = max(
            1,
            min($currentPage, max(1, $totalPages))
        );
    }

    // Tổng số trang
    public function getTotalPages(): int
    {
        return (int) ceil($this->totalRecords / $this->perPage);
    }

    // Trang hiện tại
    public function getCurrentPage(): int
    {
        return $this->currentPage;
    }

    // Số bản ghi mỗi trang
    public function getPerPage(): int
    {
        return $this->perPage;
    }

    // Vị trí bắt đầu lấy dữ liệu
    public function getOffset(): int
    {
        return ($this->currentPage - 1) * $this->perPage;
    }

    // Tổng số bản ghi
    public function getTotalRecords(): int
    {
        return $this->totalRecords;
    }
}
