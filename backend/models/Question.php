<?php
class Question {
    private PDO $db;

    public function __construct(PDO $db) {
        $this->db = $db;
    }

    public function getByUnit(int $unitId): array {
        $stmt = $this->db->prepare(
            "SELECT * FROM questions WHERE unit_id = ? ORDER BY id ASC"
        );
        $stmt->execute([$unitId]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($rows as &$row) {
            if (!empty($row['options'])) {
                $decoded = json_decode($row['options'], true);
                $row['options'] = is_array($decoded) ? $decoded : [];
            }
            if (!empty($row['correct_answer'])) {
                $decoded = json_decode($row['correct_answer'], true);
                if (is_array($decoded)) {
                    $row['correct_answer'] = $decoded;
                }
            }
        }
        return $rows;
    }

    public function getById(string $id): ?array {
        $stmt = $this->db->prepare("SELECT * FROM questions WHERE id = ?");
        $stmt->execute([$id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result ?: null;
    }
}
?>
