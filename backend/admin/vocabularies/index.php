<?php
$pageTitle = 'Vocabularies';
$currentPage = 'vocabularies';
$breadcrumb = ['Dashboard' => '/hisuesl_backend/admin/index.php'];

require_once __DIR__ . '/../../config/database.php';
include __DIR__ . '/../partials/header.php';

$keyword    = trim($_GET['search'] ?? '');
$unitFilter = trim($_GET['unit_id'] ?? '');
$page       = max(1, (int)($_GET['page'] ?? 1));
$perPage    = 20;
$offset     = ($page - 1) * $perPage;

$where = "WHERE 1=1";
$params = [];

if ($keyword) {
    $where .= " AND (v.word LIKE ? OR v.meaning LIKE ?)";
    $params[] = "%$keyword%";
    $params[] = "%$keyword%";
}
if ($unitFilter) {
    $where .= " AND v.unit_id = ?";
    $params[] = $unitFilter;
}

$countSql = "SELECT COUNT(*) FROM vocabularies v $where";
$stmtCount = $db->prepare($countSql);
$stmtCount->execute($params);
$total = $stmtCount->fetchColumn();
$totalPages = ceil($total / $perPage);

$sql = "SELECT v.*, t.title AS unit_title
    FROM vocabularies v
    LEFT JOIN topics t ON v.unit_id = t.id
    $where
    ORDER BY v.unit_id, v.id ASC
    LIMIT $perPage OFFSET $offset";
$stmt = $db->prepare($sql);
$stmt->execute($params);
$vocabs = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Topics cho filter
$topics = $db->query("SELECT id, title FROM topics ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
    <h1>Vocabularies (<?= number_format($total) ?>)</h1>
    <div class="btn-group">
        <a href="../export.php" class="btn btn-success"><i class="ri-download-2-line"></i> Export</a>
        <a href="create.php" class="btn btn-primary"><i class="ri-add-line"></i> Thêm Vocabulary</a>
    </div>
</div>

<!-- Search & Filter -->
<div class="toolbar">
    <form method="GET" style="display:flex;flex:1;gap:12px;flex-wrap:wrap;align-items:center;" autocomplete="off">
        <div class="search-box">
            <i class="ri-search-line"></i>
            <input type="text" name="search" placeholder="Tìm kiếm từ hoặc nghĩa..." value="<?= htmlspecialchars($keyword) ?>">
        </div>
        <select name="unit_id" class="form-control" style="min-width:160px;">
            <option value="">Tất cả Unit</option>
            <?php foreach ($topics as $t): ?>
            <option value="<?= $t['id'] ?>" <?= $unitFilter == $t['id'] ? 'selected' : '' ?>>
                <?= htmlspecialchars($t['title']) ?>
            </option>
            <?php endforeach; ?>
        </select>
        <button type="submit" class="btn btn-primary btn-sm"><i class="ri-filter-line"></i> Lọc</button>
        <?php if ($keyword || $unitFilter): ?>
        <a href="index.php" class="btn btn-secondary btn-sm"><i class="ri-refresh-line"></i> Reset</a>
        <?php endif; ?>
    </form>
</div>

<?php if (count($vocabs) === 0): ?>
<div class="card">
    <div class="empty-state">
        <i class="ri-file-word-2-line"></i>
        <p>Không có vocabulary nào.
            <?php if ($keyword || $unitFilter): ?>
            <a href="index.php" style="color:var(--accent);">Xóa lọc</a>
            <?php else: ?>
            <a href="create.php" style="color:var(--accent);">Tạo vocabulary đầu tiên</a>
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
                    <th>Word</th>
                    <th>Meaning</th>
                    <th>Pronunciation</th>
                    <th>Type</th>
                    <th>Unit</th>
                    <th style="text-align:center;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($vocabs as $v): ?>
                <?php
                $typeClass = match($v['type']) {
                    'noun' => 'badge-info',
                    'verb' => 'badge-danger',
                    'adjective' => 'badge-success',
                    'adverb' => 'badge-warning',
                    'phrase' => 'badge-accent',
                    default => 'badge-accent',
                };
                ?>
                <tr>
                    <td><strong><?= $v['id'] ?></strong></td>
                    <td><div style="font-weight:600;"><?= htmlspecialchars($v['word']) ?></div></td>
                    <td><?= htmlspecialchars($v['meaning']) ?></td>
                    <td><span class="text-muted" style="font-style:italic;"><?= htmlspecialchars($v['pronunciation'] ?? '-') ?></span></td>
                    <td><span class="badge <?= $typeClass ?>"><?= htmlspecialchars($v['type'] ?? '-' ) ?></span></td>
                    <td><span class="text-muted"><?= htmlspecialchars($v['unit_title'] ?? '-') ?></span></td>
                    <td>
                        <div class="btn-group" style="justify-content:center;">
                            <a href="edit.php?id=<?= urlencode($v['id']) ?>" class="action-btn edit" title="Sửa">
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

<!-- Pagination -->
<?php if ($totalPages > 1): ?>
<div class="pagination-wrapper">
    <div class="pagination-info">
        Hiển thị <?= (($page - 1) * $perPage) + 1 ?> - <?= min($page * $perPage, $total) ?> trong <?= number_format($total) ?> vocabularies
    </div>
    <div class="pagination">
        <?php
        $queryParams = [];
        if ($keyword) $queryParams['search'] = $keyword;
        if ($unitFilter) $queryParams['unit_id'] = $unitFilter;
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
