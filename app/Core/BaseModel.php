<?php

namespace App\Core;

use PDO;
use InvalidArgumentException;

abstract class BaseModel
{
    protected PDO $db;

    // Model con phải khai báo tên bảng.
    protected string $table;

    // Database hiện tại dùng id làm khóa chính.
    protected string $primaryKey = 'id';

    public function __construct()
    {
        $this->db = Database::getConnection();
    }

    /**
     * Kiểm tra tên bảng/cột được khai báo trong Model.
     * Chỉ dùng cho tên do lập trình viên định nghĩa,
     * không dùng tên lấy trực tiếp từ người dùng.
     */
    protected function validateIdentifier(string $name): string
    {
        if (!preg_match('/^[a-zA-Z_][a-zA-Z0-9_]*$/', $name)) {
            throw new InvalidArgumentException(
                'Tên bảng hoặc cột không hợp lệ.'
            );
        }

        return "`{$name}`";
    }

    /**
     * Lấy tất cả bản ghi.
     */
    public function getAll(): array
    {
        $table = $this->validateIdentifier($this->table);

        $stmt = $this->db->query(
            "SELECT * FROM {$table}"
        );

        return $stmt->fetchAll();
    }

    /**
     * Giữ tương thích với code đã dùng findAll().
     */
    public function findAll(): array
    {
        return $this->getAll();
    }

    /**
     * Tìm một bản ghi theo khóa chính.
     */
    public function findById(int $id): array|false
    {
        if ($id <= 0) {
            return false;
        }

        $table = $this->validateIdentifier($this->table);
        $primaryKey = $this->validateIdentifier($this->primaryKey);

        $stmt = $this->db->prepare(
            "SELECT * FROM {$table}
             WHERE {$primaryKey} = :id
             LIMIT 1"
        );

        $stmt->execute(['id' => $id]);

        return $stmt->fetch();
    }

    /**
     * Tìm kiếm theo các cột được Model cho phép.
     */
    public function search(
        string $keyword,
        array $columns
    ): array {
        if (empty($columns)) {
            return $this->getAll();
        }

        $table = $this->validateIdentifier($this->table);
        $conditions = [];
        $params = [];

        foreach (array_values($columns) as $index => $column) {
            $column = $this->validateIdentifier($column);
            $param = ':keyword' . $index;

            $conditions[] = "{$column} LIKE {$param}";
            $params[$param] = '%' . $keyword . '%';
        }

        $sql = "SELECT * FROM {$table}
                WHERE " . implode(' OR ', $conditions);

        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        return $stmt->fetchAll();
    }

    /**
     * Phân trang.
     * Trả về dữ liệu và tổng số bản ghi.
     */
    public function paginate(
        int $page = 1,
        int $perPage = 8
    ): array {
        $page = max(1, $page);
        $perPage = max(1, min($perPage, 100));

        $table = $this->validateIdentifier($this->table);
        $offset = ($page - 1) * $perPage;

        $countStmt = $this->db->query(
            "SELECT COUNT(*) FROM {$table}"
        );

        $totalRecords = (int) $countStmt->fetchColumn();

        $stmt = $this->db->prepare(
            "SELECT * FROM {$table}
             ORDER BY " .
            $this->validateIdentifier($this->primaryKey) .
            " DESC
             LIMIT :limit OFFSET :offset"
        );

        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        return [
            'data' => $stmt->fetchAll(),
            'current_page' => $page,
            'per_page' => $perPage,
            'total_records' => $totalRecords,
            'total_pages' => (int) ceil($totalRecords / $perPage),
        ];
    }

    /**
     * Thêm bản ghi.
     */
    public function create(array $data): bool
    {
        if (empty($data)) {
            throw new InvalidArgumentException(
                'Dữ liệu thêm không được để trống.'
            );
        }

        $table = $this->validateIdentifier($this->table);
        $columns = [];
        $placeholders = [];
        $params = [];

        foreach ($data as $column => $value) {
            $safeColumn = $this->validateIdentifier((string) $column);
            $param = ':v_' . $column;

            $columns[] = $safeColumn;
            $placeholders[] = $param;
            $params[$param] = $value;
        }

        $sql = "INSERT INTO {$table} (" .
            implode(', ', $columns) .
            ") VALUES (" .
            implode(', ', $placeholders) .
            ")";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute($params);
    }

    /**
     * Cập nhật bản ghi theo khóa chính.
     */
    public function update(int $id, array $data): bool
    {
        if ($id <= 0 || empty($data)) {
            return false;
        }

        // Không cho cập nhật khóa chính qua hàm này.
        unset($data[$this->primaryKey]);

        if (empty($data)) {
            return false;
        }

        $table = $this->validateIdentifier($this->table);
        $primaryKey = $this->validateIdentifier($this->primaryKey);

        $sets = [];
        $params = [];

        foreach ($data as $column => $value) {
            $safeColumn = $this->validateIdentifier((string) $column);
            $param = ':v_' . $column;

            $sets[] = "{$safeColumn} = {$param}";
            $params[$param] = $value;
        }

        $params[':id'] = $id;

        $sql = "UPDATE {$table}
                SET " . implode(', ', $sets) .
                " WHERE {$primaryKey} = :id";

        $stmt = $this->db->prepare($sql);

        return $stmt->execute($params);
    }

    /**
     * Xóa bản ghi theo khóa chính.
     */
    public function delete(int $id): bool
    {
        if ($id <= 0) {
            return false;
        }

        $table = $this->validateIdentifier($this->table);
        $primaryKey = $this->validateIdentifier($this->primaryKey);

        $stmt = $this->db->prepare(
            "DELETE FROM {$table}
             WHERE {$primaryKey} = :id"
        );

        return $stmt->execute(['id' => $id]);
    }
}
