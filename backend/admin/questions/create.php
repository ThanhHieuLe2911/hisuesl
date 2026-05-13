<?php
$pageTitle = 'Thêm Question';
$currentPage = 'questions';
$breadcrumb = [
    'Dashboard' => '/hisuesl_backend/admin/index.php',
    'Questions' => '/hisuesl_backend/admin/questions/index.php',
    'Thêm mới' => '#'
];

require_once __DIR__ . '/../../config/database.php';
include __DIR__ . '/../partials/header.php';

$topics = $db->query("SELECT id, title FROM topics ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);
$types = [
    'multiple_choice' => 'Multiple Choice',
    'true_false' => 'True/False',
    'fill_blank' => 'Fill in Blank'
];

$errors = [];
$success = false;
$values = [
    'unit_id' => '', 'type' => 'multiple_choice',
    'question_text' => '', 'correct_answer' => '', 'options' => ''
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $values['unit_id']       = trim($_POST['unit_id'] ?? '');
    $values['type']         = trim($_POST['type'] ?? 'multiple_choice');
    $values['question_text'] = trim($_POST['question_text'] ?? '');
    $values['correct_answer'] = trim($_POST['correct_answer'] ?? '');
    $values['options']      = trim($_POST['options'] ?? '');

    if (empty($values['unit_id'])) $errors[] = 'Vui lòng chọn Unit.';
    if (empty($values['question_text'])) $errors[] = 'Question text là bắt buộc.';
    if (empty($values['correct_answer'])) $errors[] = 'Correct answer là bắt buộc.';
    if ($values['type'] === 'multiple_choice' && empty($values['options'])) {
        $errors[] = 'Multiple choice cần có ít nhất 2 options.';
    }

    if (empty($errors)) {
        $stmt = $db->prepare("INSERT INTO questions (unit_id, type, question_text, correct_answer, options)
                               VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([
            $values['unit_id'], $values['type'],
            $values['question_text'], $values['correct_answer'],
            $values['type'] === 'multiple_choice' ? $values['options'] : null
        ]);
        $success = true;
    }
}
?>

<div class="page-header">
    <h1>Thêm Question</h1>
    <a href="index.php" class="btn btn-secondary"><i class="ri-arrow-left-line"></i> Quay lại</a>
</div>

<?php if ($success): ?>
<div class="alert alert-success">
    <i class="ri-check-line"></i>
    <div>
        <strong>Thêm question thành công!</strong><br>
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
    <form method="POST" autocomplete="off" id="questionForm">
        <div class="form-row">
            <div class="form-group">
                <label>Unit (Topic) <span class="required">*</span></label>
                <select name="unit_id" class="form-control" required id="unitSelect">
                    <option value="">-- Chọn Unit --</option>
                    <?php foreach ($topics as $t): ?>
                    <option value="<?= $t['id'] ?>" <?= $values['unit_id'] == $t['id'] ? 'selected' : '' ?>>
                        <?= htmlspecialchars($t['title']) ?>
                    </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="form-group">
                <label>Loại câu hỏi <span class="required">*</span></label>
                <select name="type" class="form-control" id="typeSelect">
                    <?php foreach ($types as $val => $label): ?>
                    <option value="<?= $val ?>" <?= $values['type'] === $val ? 'selected' : '' ?>><?= $label ?></option>
                    <?php endforeach; ?>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label>Question Text <span class="required">*</span></label>
            <textarea name="question_text" class="form-control" rows="3"
                      placeholder="VD: What is the meaning of 'Hello'?"
                      id="questionText" required><?= htmlspecialchars($values['question_text']) ?></textarea>
        </div>

        <div class="form-group">
            <label>Correct Answer <span class="required">*</span></label>
            <input type="text" name="correct_answer" class="form-control" id="correctAnswer"
                   placeholder="VD: Xin chao"
                   value="<?= htmlspecialchars($values['correct_answer']) ?>" required>
        </div>

        <div class="form-group" id="optionsGroup">
            <label>Options (Multiple Choice)</label>
            <textarea name="options" class="form-control" rows="4" id="optionsField"
                      placeholder="Dòng đầu tiên là đáp án đúng (thêm * ở đầu dòng)
VD:
*Apple
Banana
Orange"><?= htmlspecialchars($values['options']) ?></textarea>
            <p class="form-hint">
                Dong dau tien = dap an dung (them <code>*</code> o dau dong).
                VD: <code>*Correct Answer</code><br>
                Mỗi dòng là 1 option. Tối thiểu 2 options.
            </p>
        </div>

        <!-- Preview -->
        <div class="card" style="background:#fafafa;padding:16px;margin-top:8px;" id="previewCard">
            <div style="font-size:13px;font-weight:700;color:var(--text-muted);margin-bottom:12px;text-transform:uppercase;letter-spacing:0.5px;">
                <i class="ri-eye-line"></i> Preview
            </div>
            <div id="previewContent">
                <p style="font-size:14px;color:var(--text);"><em>Điền vào form để xem preview...</em></p>
            </div>
        </div>

        <div style="display:flex;gap:12px;padding-top:16px;">
            <button type="submit" class="btn btn-primary"><i class="ri-save-line"></i> Lưu Question</button>
            <a href="index.php" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</div>

<script>
const typeSelect = document.getElementById('typeSelect');
const optionsGroup = document.getElementById('optionsGroup');
const previewContent = document.getElementById('previewContent');

function updatePreview() {
    const type = typeSelect.value;
    const question = document.getElementById('questionText').value;
    const correct = document.getElementById('correctAnswer').value;
    const options = document.getElementById('optionsField').value;

    optionsGroup.style.display = type === 'multiple_choice' ? 'block' : 'none';

    let html = '<p style="font-weight:600;margin-bottom:8px;">' + (question || '<em style="color:#999;">Điền câu hỏi để xem preview...</em>') + '</p>';
    html += '<p style="font-size:13px;color:var(--text-muted);margin-bottom:8px;">Loại: <span class="badge badge-' + (type === 'true_false' ? 'success' : type === 'fill_blank' ? 'warning' : 'info') + '">' + typeSelect.options[typeSelect.selectedIndex].text + '</span></p>';

    if (type === 'true_false') {
        html += '<div style="display:flex;gap:8px;">';
        ['True', 'False'].forEach(opt => {
            const isCorrect = correct.toLowerCase() === opt.toLowerCase();
            html += '<span class="badge ' + (isCorrect ? 'badge-success' : 'badge-warning') + '">' + opt + (isCorrect ? ' (Đáp án đúng)' : '') + '</span>';
        });
        html += '</div>';
    } else if (type === 'multiple_choice' && options) {
        html += '<div style="display:flex;flex-direction:column;gap:6px;margin-top:8px;">';
        options.split('\n').forEach(line => {
            const trimmed = line.trim();
            if (!trimmed) return;
            const isCorrect = trimmed.startsWith('*');
            const label = isCorrect ? trimmed.substring(1).trim() : trimmed;
            const isAnswerCorrect = label.toLowerCase() === correct.toLowerCase();
            if (isCorrect) {
                html += '<div style="display:flex;align-items:center;gap:8px;"><span class="badge badge-success" style="min-width:20px;text-align:center;">A</span> <strong>' + label + '</strong> <span style="color:var(--success);font-size:12px;">Đáp án đúng</span></div>';
            } else {
                html += '<div style="display:flex;align-items:center;gap:8px;"><span class="badge badge-secondary" style="min-width:20px;text-align:center;background:#eee;color:#666;">' + (options.split('\n').indexOf(line) + 1) + '</span> ' + label + '</div>';
            }
        });
        html += '</div>';
    } else if (type === 'fill_blank') {
        html += '<p style="margin-top:8px;">Đáp án: <strong style="color:var(--success);">' + (correct || '-') + '</strong></p>';
    }

    previewContent.innerHTML = html;
}

typeSelect.addEventListener('change', updatePreview);
document.getElementById('questionText').addEventListener('input', updatePreview);
document.getElementById('correctAnswer').addEventListener('input', updatePreview);
document.getElementById('optionsField').addEventListener('input', updatePreview);

// Init
updatePreview();
</script>

<?php include __DIR__ . '/../partials/footer.php'; ?>
