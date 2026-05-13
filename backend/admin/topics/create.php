<?php
$pageTitle = 'Thêm Topic mới';
$currentPage = 'topics';
$breadcrumb = [
    'Dashboard' => '/hisuesl_backend/admin/index.php',
    'Topics' => '/hisuesl_backend/admin/topics/index.php',
    'Thêm mới' => '#'
];

require_once __DIR__ . '/../../config/database.php';
include __DIR__ . '/../partials/header.php';

$errors = [];
$success = false;
$values = ['title' => '', 'description' => '', 'image_path' => '', 'color' => '#6c5ce7'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $values['title']       = trim($_POST['title'] ?? '');
    $values['description'] = trim($_POST['description'] ?? '');
    $values['image_path']  = trim($_POST['image_path'] ?? '');
    $values['color']       = trim($_POST['color'] ?? '#6c5ce7');

    if (empty($values['title'])) {
        $errors[] = 'Title là bắt buộc.';
    }
    if (!preg_match('/^#[0-9A-Fa-f]{6}$/', $values['color'])) {
        $errors['color'] = 'Màu sắc phải dạng HEX (VD: #FF5500).';
    }

    if (empty($errors)) {
        $stmt = $db->prepare("INSERT INTO topics (title, description, image_path, color) VALUES (?, ?, ?, ?)");
        $stmt->execute([
            $values['title'],
            $values['description'],
            $values['image_path'],
            $values['color']
        ]);
        $success = true;
    }
}
?>

<div class="page-header">
    <h1>Thêm Topic mới</h1>
    <a href="index.php" class="btn btn-secondary"><i class="ri-arrow-left-line"></i> Quay lại</a>
</div>

<?php if ($success): ?>
<div class="alert alert-success">
    <i class="ri-check-line"></i>
    <div>
        <strong>Thêm topic thành công!</strong><br>
        <a href="index.php" style="color:inherit;text-decoration:underline;">Quay lại danh sach</a>
    </div>
</div>
<?php endif; ?>

<?php if (!empty($errors)): ?>
<div class="alert alert-error">
    <i class="ri-error-warning-line"></i>
    <div>
        <?php foreach ($errors as $e): ?>
            <?= htmlspecialchars($e) ?><br>
        <?php endforeach; ?>
    </div>
</div>
<?php endif; ?>

<div class="card">
    <form method="POST" autocomplete="off">
        <div class="form-row">
            <div class="form-group">
                <label>Title <span class="required">*</span></label>
                <input type="text" name="title" class="form-control" placeholder="VD: Unit 1 - Greetings"
                       value="<?= htmlspecialchars($values['title']) ?>" required autofocus>
            </div>
            <div class="form-group">
                <label>Mau sac (HEX) <span class="required">*</span></label>
                <div style="display:flex;gap:10px;align-items:center;">
                    <input type="color" id="colorPicker" value="<?= htmlspecialchars($values['color']) ?>"
                           style="width:52px;height:44px;padding:4px;border:2px solid var(--border);border-radius:8px;cursor:pointer;">
                    <input type="text" name="color" id="colorHex" class="form-control" style="flex:1;"
                           placeholder="#6c5ce7" value="<?= htmlspecialchars($values['color']) ?>">
                </div>
                <?php if (!empty($errors['color'])): ?>
                <small style="color:var(--danger);"><?= htmlspecialchars($errors['color']) ?></small>
                <?php endif; ?>
            </div>
        </div>

        <div class="form-group">
            <label>Description</label>
            <textarea name="description" class="form-control" rows="3"
                      placeholder="Mô tả ngắn về topic này..."><?= htmlspecialchars($values['description']) ?></textarea>
        </div>

        <div class="form-group">
            <label>Image Path</label>
            <input type="text" name="image_path" class="form-control" placeholder="VD: assets/icons/handshake.png"
                   value="<?= htmlspecialchars($values['image_path']) ?>">
            <p class="form-hint">Đường dẫn tuyệt đối đến hình ảnh của topic (neu co).</p>
        </div>

        <div style="display:flex;gap:12px;padding-top:8px;">
            <button type="submit" class="btn btn-primary"><i class="ri-save-line"></i> Lưu Topic</button>
            <a href="index.php" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</div>

<script>
// Sync color picker va text input
document.getElementById('colorPicker').addEventListener('input', function() {
    document.getElementById('colorHex').value = this.value.toUpperCase();
});
document.getElementById('colorHex').addEventListener('input', function() {
    if (/^#[0-9A-Fa-f]{6}$/.test(this.value)) {
        document.getElementById('colorPicker').value = this.value;
    }
});
</script>

<?php include __DIR__ . '/../partials/footer.php'; ?>
