<?php
$pageTitle = 'Topics';
$currentPage = 'topics';
$breadcrumb = ['Dashboard' => '/hisuesl_backend/admin/index.php'];

require_once __DIR__ . '/../../config/database.php';
include __DIR__ . '/../partials/header.php';

// Dem so vocab moi topic
$topics = $db->query("
    SELECT t.*, COUNT(v.id) as vocab_count
    FROM topics t
    LEFT JOIN vocabularies v ON t.id = v.unit_id
    GROUP BY t.id
    ORDER BY t.id ASC
")->fetchAll(PDO::FETCH_ASSOC);
?>

<div class="page-header">
    <h1>Quản lý Topics</h1>
    <a href="create.php" class="btn btn-primary"><i class="ri-add-line"></i> Thêm Topic mới</a>
</div>

<?php if (count($topics) === 0): ?>
<div class="card">
    <div class="empty-state">
        <i class="ri-book-2-line"></i>
        <p>Chưa có topic nào. <a href="create.php" style="color:var(--accent);">Tạo topic đầu tiên</a></p>
    </div>
</div>
<?php else: ?>
<div class="card" style="padding:0;overflow:hidden;">
    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Description</th>
                    <th>Màu sắc</th>
                    <th>Image</th>
                    <th>Vocab</th>
                    <th style="text-align:center;">Hành động</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($topics as $topic): ?>
                <tr>
                    <td><strong><?= $topic['id'] ?></strong></td>
                    <td>
                        <div style="font-weight:600;"><?= htmlspecialchars($topic['title']) ?></div>
                    </td>
                    <td>
                        <span class="truncate" style="max-width:220px;" title="<?= htmlspecialchars($topic['description'] ?? '') ?>">
                            <?= htmlspecialchars($topic['description'] ?? '-') ?>
                        </span>
                    </td>
                    <td>
                        <?php if (!empty($topic['color'])): ?>
                        <div style="display:flex;align-items:center;gap:8px;">
                            <span class="color-swatch" style="background:<?= htmlspecialchars($topic['color']) ?>;"></span>
                            <span class="text-muted"><?= htmlspecialchars($topic['color']) ?></span>
                        </div>
                        <?php else: ?>
                        <span class="text-muted">-</span>
                        <?php endif; ?>
                    </td>
                    <td>
                        <?php if (!empty($topic['image_path'])): ?>
                        <span class="text-muted" style="font-size:12px;"><?= htmlspecialchars(basename($topic['image_path'])) ?></span>
                        <?php else: ?>
                        <span class="text-muted">-</span>
                        <?php endif; ?>
                    </td>
                    <td>
                        <span class="badge <?= $topic['vocab_count'] > 0 ? 'badge-accent' : 'badge-warning' ?>">
                            <?= $topic['vocab_count'] ?>từ
                        </span>
                    </td>
                    <td>
                        <div class="btn-group" style="justify-content:center;">
                            <a href="edit.php?id=<?= $topic['id'] ?>" class="action-btn edit" title="Sua">
                                <i class="ri-edit-line"></i>
                            </a>
                            <a href="delete.php?id=<?= $topic['id'] ?>" class="action-btn delete" title="Xoa"
                               onclick="return confirm('Bạn có chắc muốn xóa topic \"<?= htmlspecialchars(addslashes($topic['title'])) ?>\"?')">
                                <i class="ri-delete-bin-line"></i>
                            </a>
                        </div>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>
<?php endif; ?>

<?php include __DIR__ . '/../partials/footer.php'; ?>
