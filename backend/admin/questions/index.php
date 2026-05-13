<?php
$pageTitle = 'Questions';
$currentPage = 'questions';
$breadcrumb = ['Dashboard' => '/hisuesl_backend/admin/index.php'];

require_once __DIR__ . '/../../config/database.php';
include __DIR__ . '/../partials/header.php';

$unitFilter  = trim($_GET['unit_id'] ?? '');
$typeFilter  = trim($_GET['type'] ?? '');
$page        = max(1, (int)($_GET['page'] ?? 1));
$perPage     = 20;
$offset      = ($page - 1) * $perPage;

$where = "WHERE 1=1";
$params = [];

if ($unitFilter) {
    $where .= " AND q.unit_id = ?";
    $params[] = $unitFilter;
}
if ($typeFilter) {
    $where .= " AND q.type = ?";
    $params[] = $typeFilter;
}

$countSql = "SELECT COUNT(*) FROM questions q $where";
$stmtCount = $db->prepare($countSql);
$stmtCount->execute($params);
$total = $stmtCount->fetchColumn();
$totalPages = ceil($total / $perPage);

$sql = "SELECT q.*, t.title AS unit_title
    FROM questions q
    LEFT JOIN topics t ON q.unit_id = t.id
    $where
    ORDER BY q.unit_id, q.id ASC
    LIMIT $perPage OFFSET $offset";
$stmt = $db->prepare($sql);
$stmt->execute($params);
$questions = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Topics + Types cho filter
$topics = $db->query("SELECT id, title FROM topics ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);
$types = ['multiple_choice' => 'Multiple Choice', 'true_false' => 'True/False', 'fill_blank' => 'Fill in Blank'];
?>

<div class="page-header">
    <h1>Questions (<?= number_format($total) ?>)</h1>
    <a href="create.php" class="btn btn-primary"><i class="ri-add-line"></i> Thêm Question</a>
</div>

<!-- Filter -->
<div class="toolbar">
    <form method="GET" style="display:flex;flex:1;gap:12px;flex-wrap:wrap;align-items:center;" autocomplete="off">
        <select name="unit_id" class="form-control" style="min-width:160px;">
            <option value="">Tất cả Unit</option>
            <?php foreach ($topics as $t): ?>
            <option value="<?= $t['id'] ?>" <?= $unitFilter == $t['id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($t['title']) ?>
            </option>
            <?php endforeach; ?>
        </select>
        <select name="type" class="form-control" style="min-width:160px;">
            <option value="">Tất cả loại</option>
            <?php foreach ($types as $val => $label): ?>
            <option value="<?= $val ?>" <?= $typeFilter == $val ? 'selected' : '' ?>><?= $label ?></option>
            <?php endforeach; ?>
        </select>
        <button type="submit" class="btn btn-primary btn-sm"><i class="ri-filter-line"></i> Lọc</button>
        <?php if ($unitFilter || $typeFilter): ?>
        <a href="index.php" class="btn btn-secondary btn-sm"><i class="ri-refresh-line"></i> Reset</a>
        <?php endif; ?>
    </form>
</div>

<?php if (count($questions) === 0): ?>
<div class="card">
    <div class="empty-state">
        <i class="ri-bubble-chart-line"></i>
        <p>Không có câu hỏi nào.
            <?php if ($unitFilter || $typeFilter): ?>
            <a href="index.php" style="color:var(--accent);">Xóa lọc</a>
            <?php else: ?>
            <a href="create.php" style="color:var(--accent);">Tạo câu hỏi đầu tiên</a>
            <?php endif; ?>
        </p>
    </div>
</div>
<?php else: ?>
<div class="card" style="padding:0;overflow:hidden;">
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Unit</th>
                    <th>Loại</th>
                    <th>Câu hỏi</th>
                    <th>Đáp án đúng</th>
                    <th style="text-align:center;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($questions as $q): ?>
                <?php
                $typeClass = match($q['type']) {
                    'multiple_choice' => 'badge-info',
                    'true_false' => 'badge-success',
                    'fill_blank' => 'badge-warning',
                    default => 'badge-accent',
                };
                ?>
                <tr>
                    <td><strong><?= $q['id'] ?></strong></td>
                    <td><span class="text-muted"><?= htmlspecialchars($q['unit_title'] ?? '-') ?></span></td>
                    <td><span class="badge <?= $typeClass ?>"><?= htmlspecialchars($types[$q['type']] ?? $q['type']) ?></span></td>
                    <td>
                        <span class="truncate" style="max-width:280px;" title="<?= htmlspecialchars($q['question_text']) ?>">
                            <?= htmlspecialchars(mb_substr($q['question_text'], 0, 50)) ?><?= mb_strlen($q['question_text']) > 50 ? '...' : '' ?>
                        </span>
                    </td>
                    <td><strong style="color:var(--success);"><?= htmlspecialchars($q['correct_answer']) ?></strong></td>
                    <td>
                        <div class="btn-group" style="justify-content:center;">
                            <a href="edit.php?id=<?= urlencode($q['id']) ?>" class="action-btn edit" title="Sửa">
                                <i class="ri-edit-line"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<?php if ($totalPages > 1): ?>
<div class="pagination-wrapper">
    <div class="pagination-info">
        Hiển thị <?= (($page - 1) * $perPage) + 1 ?> - <?= min($page * $perPage, $total) ?> trong <?= number_format($total) ?> questions
    </div>
    <div class="pagination">
        <?php
        $queryParams = [];
        if ($unitFilter) $queryParams['unit_id'] = $unitFilter;
        if ($typeFilter) $queryParams['type'] = $typeFilter;
        $baseUrl = 'index.php?' . http_build_query($queryParams);
        ?>
        <?php if ($page > 1): ?>
            <a href="<?= $baseUrl ?>&page=<?= $page - 1 ?>"><i class="ri-arrow-left-s-line"></i></a>
        <?php else: ?>
            <span class="disabled"><i class="ri-arrow-left-s-line"></i></span>
        <?php endif; ?>

        <?php
        $start = max(1, $page - 2);
        $end = min($totalPages, $page + 2);
        if ($start > 1) echo '<a href="' . $baseUrl . '&page=1">1</a>';
        if ($start > 2) echo '<span class="disabled">...</span>';
        for ($i = $start; $i <= $end; $i++):
        ?>
            <?php if ($i == $page): ?>
                <span class="active"><?= $i ?></span>
            <?php else: ?>
                <a href="<?= $baseUrl ?>&page=<?= $i ?>"><?= $i ?></a>
            <?php endif; ?>
        <?php endfor; ?>
        <?php if ($end < $totalPages - 1) echo '<span class="disabled">...</span>'; ?>
        <?php if ($end < $totalPages) echo '<a href="' . $baseUrl . '&page=' . $totalPages . '">' . $totalPages . '</a>'; ?>

        <?php if ($page < $totalPages): ?>
            <a href="<?= $baseUrl ?>&page=<?= $page + 1 ?>"><i class="ri-arrow-right-s-line"></i></a>
        <?php else: ?>
            <span class="disabled"><i class="ri-arrow-right-s-line"></i></span>
        <?php endif; ?>
    </div>
</div>
<?php endif; ?>
<?php endif; ?>

<?php include __DIR__ . '/../partials/footer.php'; ?>
