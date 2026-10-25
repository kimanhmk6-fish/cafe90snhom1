<?php

namespace App\Models;

use App\Core\BaseModel;

/**
 * [P-02] Model Kích cỡ đồ uống — bảng sizes (S/M/L).
 * Giá theo size nằm ở ProductSize; bảng này chỉ định nghĩa các size.
 */
class Size extends BaseModel
{
    protected string $table = 'sizes';

    /** Các cột được phép ghi qua create/update. */
    private array $fillable = ['name', 'description', 'sort_order'];

    /** Tất cả size theo thứ tự hiển thị (S → M → L). */
    public function getAllOrdered(): array
    {
        $stmt = $this->db->query(
            'SELECT * FROM sizes ORDER BY sort_order ASC, id ASC'
        );

        return $stmt->fetchAll();
    }

    /** Tìm size theo tên (S, M, L). */
    public function findByName(string $name): array|false
    {
        $stmt = $this->db->prepare(
            'SELECT * FROM sizes WHERE name = :name LIMIT 1'
        );
        $stmt->execute(['name' => $name]);

        return $stmt->fetch();
    }

    public function create(array $data): bool
    {
        return parent::create($this->filterFillable($data));
    }

    public function update(int $id, array $data): bool
    {
        return parent::update($id, $this->filterFillable($data));
    }

    /** Chỉ giữ các cột trong $fillable. */
    private function filterFillable(array $data): array
    {
        return array_intersect_key($data, array_flip($this->fillable));
    }
}
