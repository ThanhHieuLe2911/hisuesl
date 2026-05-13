<?php
$pageTitle = 'Sửa Vocabulary';
$currentPage = 'vocabularies';
$breadcrumb = [
    'Dashboard' => '/hisuesl_backend/admin/index.php',
    'Vocabularies' => '/hisuesl_backend/admin/vocabularies/index.php',
    'Sửa' => '#'
];

require_once __DIR__ . '/../../config/database.php';
include __DIR__ . '/../partials/header.php';

$id = $_GET['id'] ?? null;
if (!$id) {
    header('Location: index.php');
    exit;
}

$stmt = $db->prepare("SELECT * FROM vocabularies WHERE id = ?");
$stmt->execute([$id]);
$vocab = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$vocab) {
    header('Location: index.php');
    exit;
}

$topics = $db->query("SELECT id, title FROM topics ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);

$errors = [];
$success = false;
$values = [
    'word' => $vocab['word'],
    'meaning' => $vocab['meaning'],
    'pronunciation' => $vocab['pronunciation'] ?? '',
    'type' => $vocab['type'] ?? 'noun',
    'example_sentence' => $vocab['example_sentence'] ?? '',
    'unit_id' => $vocab['unit_id']
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $values['word']             = trim($_POST['word'] ?? '');
    $values['meaning']          = trim($_POST['meaning'] ?? '');
    $values['pronunciation']    = trim($_POST['pronunciation'] ?? '');
    $values['type']             = trim($_POST['type'] ?? 'noun');
    $values['example_sentence'] = trim($_POST['example_sentence'] ?? '');
    $values['unit_id']          = trim($_POST['unit_id'] ?? '');

    if (empty($values['word'])) $errors[] = 'Word là bắt buộc.';
    if (empty($values['meaning'])) $errors[] = 'Meaning là bắt buộc.';
    if (empty($values['unit_id'])) $errors[] = 'Vui lòng chọn Unit.';

    if (empty($errors)) {
        $stmt = $db->prepare("UPDATE vocabularies SET unit_id=?, word=?, meaning=?, pronunciation=?, type=?, example_sentence=? WHERE id=?");
        $stmt->execute([
            $values['unit_id'], $values['word'], $values['meaning'],
            $values['pronunciation'], $values['type'], $values['example_sentence'], $id
        ]);
        $success = true;
    }
}
?>

<div class="page-header">
    <h1>Sửa Vocabulary</h1>
    <a href="index.php" class="btn btn-secondary"><i class="ri-arrow-left-line"></i> Quay lại</a>
</div>

<?php if ($success): ?>
<div class="alert alert-success">
    <i class="ri-check-line"></i>
    <div>
        <strong>Cập nhật vocabulary thành công!</strong><br>
        <a href="index.php" style="color:inherit;text-decoration:underline;">Quay lại danh sach</a>
    </div>
</div>
<?php endif; ?>

<?php if (!empty($errors)): ?>
<div class="alert alert-error">
    <i class="ri-error-warning-line"></i>
    <div><?php foreach ($errors as $e) echo htmlspecialchars($e) . '<br>'; ?></div>
</div>
<?php endif; ?>

<div class="card">
    <div style="display:flex;align-items:center;gap:12px;margin-bottom:24px;padding:14px;background:var(--accent-light);border-radius:8px;">
        <i class="ri-information-line" style="font-size:20px;color:var(--accent);"></i>
        <div>
            <div style="font-weight:700;color:var(--text);">Vocabulary ID: <?= $id ?></div>
            <div style="font-size:13px;color:var(--text-muted);">
                Word hiện tại: <strong><?= htmlspecialchars($vocab['word']) ?></strong>
            </div>
        </div>
    </div>

    <form method="POST" autocomplete="off">
        <div class="form-row">
            <div class="form-group">
                <label>Word <span class="required">*</span></label>
                <input type="text" name="word" class="form-control"
                       value="<?= htmlspecialchars($values['word']) ?>" required autofocus>
            </div>
            <div class="form-group">
                <label>Meaning <span class="required">*</span></label>
                <input type="text" name="meaning" class="form-control"
                       value="<?= htmlspecialchars($values['meaning']) ?>" required>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label>Pronunciation</label>
                <input type="text" name="pronunciation" class="form-control"
                       value="<?= htmlspecialchars($values['pronunciation']) ?>">
            </div>
            <div class="form-group">
                <label>Type</label>
                <select name="type" class="form-control">
                    <?php
                    $types = ['noun' => 'Danh từ (noun)', 'verb' => 'Động từ (verb)', 'adjective' => 'Tính từ (adjective)',
                              'adverb' => 'Trạng từ (adverb)', 'phrase' => 'Cụm nghi (phrase)'];
                    foreach ($types as $val => $label):
                    ?>
                    <option value="<?= $val ?>" <?= $values['type'] === $val ? 'selected' : '' ?>><?= $label ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Unit (Topic) <span class="required">*</span></label>
                <select name="unit_id" class="form-control" required>
                    <option value="">-- Chon Unit --</option>
                    <?php foreach ($topics as $t): ?>
                    <option value="<?= $t['id'] ?>" <?= $values['unit_id'] == $t['id'] ? 'selected' : '' ?>>
                        <?= htmlspecialchars($t['title']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label>Example Sentence</label>
            <textarea name="example_sentence" class="form-control" rows="3"><?= htmlspecialchars($values['example_sentence']) ?></textarea>
        </div>

        <div style="display:flex;gap:12px;padding-top:8px;">
            <button type="submit" class="btn btn-primary"><i class="ri-save-line"></i> Cập nhật</button>
            <a href="index.php" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</div>

<?php include __DIR__ . '/../partials/footer.php'; ?>
