<?php

namespace App\Models;

use App\Core\BaseModel;

/**
 * [P-02] Model Danh mục sản phẩm — bảng categories.
 * CRUD cơ bản kế thừa BaseModel (getAll, findById, search, paginate, delete);
 * các hàm dưới đây bổ sung nghiệp vụ riêng của danh mục.
 */
class Category extends BaseModel
{
    protected string $table = 'categories';

    /** Các cột được phép ghi qua create/update. */
    private array $fillable = ['name', 'slug', 'description', 'is_active'];

    /** Danh mục đang hoạt động, dùng cho menu/lọc phía Client. */
    public function getActive(): array
    {
        $stmt = $this->db->query(
            'SELECT * FROM categories WHERE is_active = 1 ORDER BY id ASC'
        );

        return $stmt->fetchAll();
    }

    /** Tìm danh mục theo slug (URL thân thiện). */
    public function findBySlug(string $slug): array|false
    {
        $stmt = $this->db->prepare(
            'SELECT * FROM categories WHERE slug = :slug LIMIT 1'
        );
        $stmt->execute(['slug' => $slug]);

        return $stmt->fetch();
    }

    /** Kiểm tra slug đã tồn tại chưa (bỏ qua chính bản ghi khi sửa). */
    public function slugExists(string $slug, int $excludeId = 0): bool
    {
        $stmt = $this->db->prepare(
            'SELECT COUNT(*) FROM categories WHERE slug = :slug AND id <> :id'
        );
        $stmt->execute(['slug' => $slug, 'id' => $excludeId]);

        return (int) $stmt->fetchColumn() > 0;
    }

    /** Số món thuộc danh mục — Admin dùng để chặn xóa danh mục còn món. */
    public function countProducts(int $id): int
    {
        $stmt = $this->db->prepare(
            'SELECT COUNT(*) FROM products WHERE category_id = :id'
        );
        $stmt->execute(['id' => $id]);

        return (int) $stmt->fetchColumn();
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
