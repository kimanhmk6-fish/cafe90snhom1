<?php

namespace App\Models;

use App\Core\BaseModel;
use PDO;

/**
 * [P-02] Model Sản phẩm — bảng products.
 * Giá hiển thị mặc định là base_price (= giá size S); giá từng size
 * nằm ở bảng product_sizes (xem ProductSize). Bánh không có size.
 */
class Product extends BaseModel
{
    protected string $table = 'products';

    /** Các cột được phép ghi qua create/update. */
    private array $fillable = [
        'category_id', 'name', 'slug', 'description', 'image',
        'base_price', 'is_featured', 'is_active',
    ];

    /** Món nổi bật cho Trang chủ (UC01): is_featured = 1 và đang bán. */
    public function getFeatured(int $limit = 6): array
    {
        $stmt = $this->db->prepare(
            'SELECT p.*, c.name AS category_name, c.slug AS category_slug
             FROM products p
             JOIN categories c ON c.id = p.category_id
             WHERE p.is_active = 1 AND p.is_featured = 1
             ORDER BY p.id ASC
             LIMIT :limit'
        );
        $stmt->bindValue(':limit', max(1, $limit), PDO::PARAM_INT);
        $stmt->execute();

        return $stmt->fetchAll();
    }

    /**
     * Danh sách món cho trang Thực đơn (UC02): lọc theo danh mục,
     * tìm kiếm theo tên, phân trang (mặc định 9 món/trang).
     * $filters: ['category_id' => ?int, 'keyword' => ?string]
     * Trả về cùng cấu trúc với BaseModel::paginate().
     */
    public function getMenu(array $filters = [], int $page = 1, int $perPage = 9): array
    {
        $page = max(1, $page);
        $perPage = max(1, min($perPage, 100));

        $where = ['p.is_active = 1'];
        $params = [];

        if (!empty($filters['category_id'])) {
            $where[] = 'p.category_id = :category_id';
            $params[':category_id'] = (int) $filters['category_id'];
        }
        if (!empty($filters['keyword'])) {
            $where[] = 'p.name LIKE :keyword';
            $params[':keyword'] = '%' . trim((string) $filters['keyword']) . '%';
        }
        $whereSql = implode(' AND ', $where);

        $countStmt = $this->db->prepare(
            "SELECT COUNT(*) FROM products p WHERE {$whereSql}"
        );
        $countStmt->execute($params);
        $totalRecords = (int) $countStmt->fetchColumn();

        $stmt = $this->db->prepare(
            "SELECT p.*, c.name AS category_name, c.slug AS category_slug
             FROM products p
             JOIN categories c ON c.id = p.category_id
             WHERE {$whereSql}
             ORDER BY p.id ASC
             LIMIT :limit OFFSET :offset"
        );
        foreach ($params as $key => $value) {
            $stmt->bindValue($key, $value);
        }
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', ($page - 1) * $perPage, PDO::PARAM_INT);
        $stmt->execute();

        return [
            'data' => $stmt->fetchAll(),
            'current_page' => $page,
            'per_page' => $perPage,
            'total_records' => $totalRecords,
            'total_pages' => (int) ceil($totalRecords / $perPage),
        ];
    }

    /** Tìm món theo slug, kèm tên danh mục. */
    public function findBySlug(string $slug): array|false
    {
        $stmt = $this->db->prepare(
            'SELECT p.*, c.name AS category_name, c.slug AS category_slug
             FROM products p
             JOIN categories c ON c.id = p.category_id
             WHERE p.slug = :slug
             LIMIT 1'
        );
        $stmt->execute(['slug' => $slug]);

        return $stmt->fetch();
    }

    /** Kiểm tra slug đã tồn tại chưa (bỏ qua chính bản ghi khi sửa). */
    public function slugExists(string $slug, int $excludeId = 0): bool
    {
        $stmt = $this->db->prepare(
            'SELECT COUNT(*) FROM products WHERE slug = :slug AND id <> :id'
        );
        $stmt->execute(['slug' => $slug, 'id' => $excludeId]);

        return (int) $stmt->fetchColumn() > 0;
    }

    /** Đếm số món trong một danh mục. */
    public function countByCategory(int $categoryId): int
    {
        $stmt = $this->db->prepare(
            'SELECT COUNT(*) FROM products WHERE category_id = :id'
        );
        $stmt->execute(['id' => $categoryId]);

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
