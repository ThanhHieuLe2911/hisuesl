<?php
$pageTitle = 'Dashboard';
$currentPage = 'dashboard';

require_once __DIR__ . '/../config/database.php';
include __DIR__ . '/partials/header.php';

// Thong ke co ban
$topicCount    = $db->query("SELECT COUNT(*) FROM topics")->fetchColumn();
$vocabCount    = $db->query("SELECT COUNT(*) FROM vocabularies")->fetchColumn();
$questionCount = $db->query("SELECT COUNT(*) FROM questions")->fetchColumn();

// Phan bo cau hoi theo loai
$typeStats = $db->query("
    SELECT type, COUNT(*) as count
    FROM questions GROUP BY type
")->fetchAll(PDO::FETCH_ASSOC);

// Top 5 Unit nhieu vocab nhat
$unitStats = $db->query("
    SELECT t.title, COUNT(v.id) as vocab_count
    FROM topics t
    LEFT JOIN vocabularies v ON t.id = v.unit_id
    GROUP BY t.id, t.title
    ORDER BY vocab_count DESC
    LIMIT 5
")->fetchAll(PDO::FETCH_ASSOC);
?>

<!-- Stats Cards -->
<div class="stats-grid">
    <div class="stat-card topics">
        <div class="stat-icon">
            <i class="ri-book-2-line"></i>
        </div>
        <div class="stat-info">
            <h3><?= number_format($topicCount) ?></h3>
            <p>Topics</p>
        </div>
    </div>
    <div class="stat-card vocabs">
        <div class="stat-icon">
            <i class="ri-file-word-2-line"></i>
        </div>
        <div class="stat-info">
            <h3><?= number_format($vocabCount) ?></h3>
            <p>Vocabularies</p>
        </div>
    </div>
    <div class="stat-card questions">
        <div class="stat-icon">
            <i class="ri-bubble-chart-line"></i>
        </div>
        <div class="stat-info">
            <h3><?= number_format($questionCount) ?></h3>
            <p>Questions</p>
        </div>
    </div>
</div>

<!-- Quick Actions -->
<div class="quick-actions" style="margin-bottom: 28px;">
    <a href="topics/index.php" class="btn btn-primary"><i class="ri-book-2-line"></i> Quản lý Topics</a>
    <a href="vocabularies/index.php" class="btn btn-primary"><i class="ri-file-word-2-line"></i> Quản lý Vocabularies</a>
    <a href="questions/index.php" class="btn btn-primary"><i class="ri-bubble-chart-line"></i> Quản lý Questions</a>
    <a href="export.php" class="btn btn-secondary"><i class="ri-download-2-line"></i> Export CSV</a>
    <a href="import.php" class="btn btn-secondary"><i class="ri-upload-2-line"></i> Import CSV</a>
</div>

<!-- Analytics Grid -->
<div class="dashboard-grid">
    <!-- Câu hỏi theo loại -->
    <div class="card">
        <div class="card-header">
            <h3><i class="ri-pie-chart-line"></i> Câu hỏi theo loại</h3>
        </div>
        <?php if (count($typeStats) > 0): ?>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Loại</th>
                        <th>Số lượng</th>
                        <th>Tỷ lệ</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($typeStats as $s): ?>
                    <?php $percent = $questionCount > 0 ? round($s['count'] / $questionCount * 100, 1) : 0; ?>
                    <tr>
                        <td>
                            <?php
                            $badgeClass = match($s['type']) {
                                'multiple_choice' => 'badge-info',
                                'true_false' => 'badge-success',
                                'fill_blank' => 'badge-warning',
                                default => 'badge-accent',
                            };
                            ?>
                            <span class="badge <?= $badgeClass ?>"><?= htmlspecialchars($s['type']) ?></span>
                        </td>
                        <td><strong><?= $s['count'] ?></strong></td>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <div style="flex:1;height:8px;background:#eee;border-radius:4px;overflow:hidden;">
                                    <div style="width:<?= $percent ?>%;height:100%;background:var(--accent);border-radius:4px;"></div>
                                </div>
                                <span style="font-size:12px;color:var(--text-muted);min-width:40px;"><?= $percent ?>%</span>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php else: ?>
        <div class="empty-state">
            <i class="ri-file-list-3-line"></i>
            <p>Chưa có câu hỏi nào</p>
        </div>
        <?php endif; ?>
    </div>

    <!-- Top 5 Unit nhieu vocab -->
    <div class="card">
        <div class="card-header">
            <h3><i class="ri-bar-chart-2-line"></i> Top 5 Unit có nhiều từ nhất</h3>
        </div>
        <?php if (count($unitStats) > 0): ?>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Unit</th>
                        <th>Vocabularies</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($unitStats as $i => $s): ?>
                    <tr>
                        <td>
                            <div style="display:flex;align-items:center;gap:8px;">
                                <span style="font-weight:700;color:var(--accent);font-size:13px;">#<?= $i + 1 ?></span>
                                <?= htmlspecialchars($s['title']) ?>
                            </div>
                        </td>
                        <td>
                            <div style="display:flex;align-items:center;gap:10px;">
                                <span style="font-weight:700;color:var(--success);"><?= $s['vocab_count'] ?></span>
                                <div style="flex:1;height:8px;background:#eee;border-radius:4px;overflow:hidden;max-width:120px;">
                                    <?php
                                    $maxCount = $unitStats[0]['vocab_count'];
                                    $barWidth = $maxCount > 0 ? round($s['vocab_count'] / $maxCount * 100) : 0;
                                    ?>
                                    <div style="width:<?= $barWidth ?>%;height:100%;background:var(--success);border-radius:4px;"></div>
                                </div>
                            </div>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
        <?php else: ?>
        <div class="empty-state">
            <i class="ri-book-2-line"></i>
            <p>Chưa có topic nào</p>
        </div>
        <?php endif; ?>
    </div>
</div>

<?php include __DIR__ . '/partials/footer.php'; ?>
