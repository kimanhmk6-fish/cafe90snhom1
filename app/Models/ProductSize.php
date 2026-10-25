<?php

namespace App\Models;

use App\Core\BaseModel;
use PDOException;

/**
 * [P-02] Model Giá theo kích cỡ — bảng product_sizes.
 * Chuẩn UC: S = giá gốc (base_price của products), M = S + 5.000đ,
 * L = S + 10.000đ. Bánh không có dòng trong bảng này (không size).
 */
class ProductSize extends BaseModel
{
    protected string $table = 'product_sizes';

    /** Các cột được phép ghi qua create/update. */
    private array $fillable = ['product_id', 'size_id', 'price'];

    /**
     * Bảng giá của một món, kèm tên size, sắp theo sort_order (S → M → L).
     * Bánh trả về mảng rỗng.
     */
    public function getByProduct(int $productId): array
    {
        $stmt = $this->db->prepare(
            'SELECT ps.*, s.name AS size_name, s.sort_order
             FROM product_sizes ps
             JOIN sizes s ON s.id = ps.size_id
             WHERE ps.product_id = :product_id
             ORDER BY s.sort_order ASC'
        );
        $stmt->execute(['product_id' => $productId]);

        return $stmt->fetchAll();
    }

    /** Giá của một món theo size; null nếu món không có size đó (ví dụ bánh). */
    public function getPrice(int $productId, int $sizeId): ?float
    {
        $stmt = $this->db->prepare(
            'SELECT price FROM product_sizes
             WHERE product_id = :product_id AND size_id = :size_id
             LIMIT 1'
        );
        $stmt->execute(['product_id' => $productId, 'size_id' => $sizeId]);
        $price = $stmt->fetchColumn();

        return $price === false ? null : (float) $price;
    }

    /**
     * Đồng bộ bảng giá của một món: $prices là [size_id => price].
     * Size nào vắng mặt hoặc giá null sẽ bị xóa khỏi bảng giá
     * (dùng khi Admin sửa món, hoặc khi món chuyển thành bánh).
     */
    public function syncPrices(int $productId, array $prices): void
    {
        $this->db->beginTransaction();
        try {
            $delete = $this->db->prepare(
                'DELETE FROM product_sizes WHERE product_id = :product_id'
            );
            $delete->execute(['product_id' => $productId]);

            $insert = $this->db->prepare(
                'INSERT INTO product_sizes (product_id, size_id, price)
                 VALUES (:product_id, :size_id, :price)'
            );
            foreach ($prices as $sizeId => $price) {
                if ($price === null || $price === '') {
                    continue;
                }
                $insert->execute([
                    'product_id' => $productId,
                    'size_id' => (int) $sizeId,
                    'price' => $price,
                ]);
            }
            $this->db->commit();
        } catch (PDOException $e) {
            $this->db->rollBack();
            throw $e;
        }
    }

    /** Xóa toàn bộ bảng giá của một món. */
    public function deleteByProduct(int $productId): bool
    {
        $stmt = $this->db->prepare(
            'DELETE FROM product_sizes WHERE product_id = :product_id'
        );

        return $stmt->execute(['product_id' => $productId]);
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
