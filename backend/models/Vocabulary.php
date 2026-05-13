<?php
class Vocabulary {
    private PDO $db;

    public function __construct(PDO $db) {
        $this->db = $db;
    }

    public function getByUnit(int $unitId): array {
        $stmt = $this->db->prepare(
            "SELECT * FROM vocabularies WHERE unit_id = ? ORDER BY id ASC"
        );
        $stmt->execute([$unitId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(string $id): ?array {
        $stmt = $this->db->prepare("SELECT * FROM vocabularies WHERE id = ?");
        $stmt->execute([$id]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result ?: null;
    }
}
?>
