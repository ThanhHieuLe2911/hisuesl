<?php
$pageTitle = 'Import CSV';
$currentPage = 'import';
$breadcrumb = ['Dashboard' => '/hisuesl_backend/admin/index.php'];

require_once __DIR__ . '/../config/database.php';
include __DIR__ . '/partials/header.php';

$errors = [];
$success = false;
$preview = null;
$importResult = null;
$dataType = $_GET['type'] ?? ($_POST['data_type'] ?? '');
$step = $_POST['step'] ?? 'upload';
$csvContentForForm = '';

// --- Handle File Upload ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $step === 'upload') {
    $dataType = trim($_POST['data_type'] ?? '');

    if (empty($dataType)) {
        $errors[] = 'Vui lòng chọn loại dữ liệu.';
    }

    if (!isset($_FILES['csv_file']) || $_FILES['csv_file']['error'] !== UPLOAD_ERR_OK) {
        $errors[] = 'Vui lòng upload file CSV hợp lệ.';
    } else {
        $file = $_FILES['csv_file'];
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));

        if ($ext !== 'csv' && $ext !== 'txt') {
            $errors[] = 'Chỉ chấp nhận file .csv hoặc .txt.';
        }

        if ($file['size'] > 5 * 1024 * 1024) {
            $errors[] = 'File quá lớn (giới hạn 5MB).';
        }
    }

    if (empty($errors)) {
        $content = file_get_contents($file['tmp_name']);
        if ($content === false) {
            $errors[] = 'Không thể đọc file.';
        } else {
            // Remove BOM
            if (substr($content, 0, 3) === "\xEF\xBB\xBF") {
                $content = substr($content, 3);
            }

            $lines = explode("\n", $content);
            $headerLine = trim($lines[0] ?? '');
            $headerLine = ltrim($headerLine, "\xEF\xBB\xBF");

            $section = null;
            if (stripos($headerLine, '=== TOPICS') !== false) {
                $section = 'topics';
            } elseif (stripos($headerLine, '=== VOCABULARIES') !== false) {
                $section = 'vocabularies';
            } elseif (stripos($headerLine, '=== QUESTIONS') !== false) {
                $section = 'questions';
            } elseif (stripos($headerLine, 'id,title') !== false) {
                $section = $dataType;
            }

            if (!$section) {
                $errors[] = 'Không nhận diện được cấu trúc file CSV. Đảm bảo format đúng.';
            } else {
                $rows = [];
                $headerParsed = false;
                $headers = [];
                $lineIdx = 0;

                foreach ($lines as $line) {
                    $line = trim($line);
                    $lineIdx++;
                    if ($lineIdx === 1) continue;
                    if ($lineIdx === 2 && !$headerParsed) {
                        $headers = str_getcsv($line);
                        $headerParsed = true;
                        continue;
                    }
                    if (empty($line)) continue;
                    if (preg_match('/^=== [A-Z]+ ===$/', $line)) continue;

                    $cols = str_getcsv($line);
                    if (count($cols) >= 2) {
                        $rows[] = $cols;
                        if (count($rows) >= 10) break;
                    }
                }

                // Store CSV content for hidden field (trim all lines)
                $allLines = explode("\n", $content);
                $trimmedLines = [];
                foreach ($allLines as $l) {
                    $trimmedLines[] = trim($l);
                }
                $csvContentForForm = implode("\n", $trimmedLines);

                $preview = [
                    'section' => $section,
                    'headers' => $headers,
                    'rows' => $rows,
                    'filename' => $file['name'],
                    'filesize' => $file['size'],
                    'total_lines' => count($lines)
                ];
                $step = 'preview';
            }
        }
    }
}

// --- Handle Confirm Import ---
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $step === 'preview') {
    $dataType = trim($_POST['data_type'] ?? '');
    $rawCsv = $_POST['csv_content'] ?? '';

    if (empty($dataType) || empty($rawCsv)) {
        $errors[] = 'Dữ liệu không hợp lệ.';
    } else {
        $lines = explode("\n", trim($rawCsv));
        $headerParsed = false;
        $headers = [];
        $inserted = 0;
        $skipped = 0;
        $lineErrors = [];

        foreach ($lines as $lineIdx => $line) {
            $line = trim($line);
            if ($lineIdx === 0) continue;
            if ($lineIdx === 1) {
                $headers = str_getcsv($line);
                $headerParsed = true;
                continue;
            }
            if (empty($line)) continue;
            if (preg_match('/^=== [A-Z]+ ===$/', $line)) continue;

            $cols = str_getcsv($line);
            if (count($cols) < 2) {
                $skipped++;
                continue;
            }

            try {
                if ($dataType === 'topics') {
                    $stmt = $db->prepare("INSERT IGNORE INTO topics (id, title, description, image_path, color) VALUES (?, ?, ?, ?, ?)");
                    $stmt->execute([
                        intval($cols[0] ?? 0),
                        $cols[1] ?? '',
                        $cols[2] ?? '',
                        $cols[3] ?? '',
                        $cols[4] ?? ''
                    ]);
                } elseif ($dataType === 'vocabularies') {
                    $stmt = $db->prepare("INSERT IGNORE INTO vocabularies (id, unit_id, word, meaning, pronunciation, type, example_sentence) VALUES (?, ?, ?, ?, ?, ?, ?)");
                    $stmt->execute([
                        intval($cols[0] ?? 0),
                        intval($cols[1] ?? 0),
                        $cols[2] ?? '',
                        $cols[3] ?? '',
                        $cols[4] ?? '',
                        $cols[5] ?? '',
                        $cols[6] ?? ''
                    ]);
                } elseif ($dataType === 'questions') {
                    $stmt = $db->prepare("INSERT IGNORE INTO questions (id, unit_id, type, question_text, correct_answer, options) VALUES (?, ?, ?, ?, ?, ?)");
                    $stmt->execute([
                        intval($cols[0] ?? 0),
                        intval($cols[1] ?? 0),
                        $cols[2] ?? '',
                        $cols[3] ?? '',
                        $cols[4] ?? '',
                        $cols[5] ?? ''
                    ]);
                }
                if ($stmt->rowCount() > 0) {
                    $inserted++;
                } else {
                    $skipped++;
                }
            } catch (Exception $e) {
                $skipped++;
                $lineErrors[] = "Dòng " . ($lineIdx + 1) . ": " . $e->getMessage();
            }
        }

        $importResult = [
            'inserted' => $inserted,
            'skipped' => $skipped,
            'errors' => $lineErrors
        ];
        $success = true;
        $step = 'done';
    }
}
?>

<div class="page-header">
    <h1>Import CSV</h1>
    <a href="index.php" class="btn btn-secondary"><i class="ri-arrow-left-line"></i> Quay lại Dashboard</a>
</div>

<?php if (!empty($errors)): ?>
<div class="alert alert-error">
    <i class="ri-error-warning-line"></i>
    <div><?php foreach ($errors as $e) echo htmlspecialchars($e) . '<br>'; ?></div>
</div>
<?php endif; ?>

<?php if ($success && $importResult): ?>
<div class="alert alert-success">
    <i class="ri-check-line"></i>
    <div>
        <strong>Import thành công!</strong><br>
        <?= number_format($importResult['inserted']) ?> dòng được thêm.<br>
        <?= number_format($importResult['skipped']) ?> dòng bị bỏ qua (trùng ID hoặc lỗi).
        <?php if (!empty($importResult['errors'])): ?>
        <details style="margin-top:8px;">
            <summary style="cursor:pointer;color:var(--danger-dark);font-weight:600;">Xem lỗi (<?= count($importResult['errors']) ?>)</summary>
            <div style="margin-top:8px;font-size:12px;color:#c0392b;background:#fff5f5;padding:8px;border-radius:4px;">
                <?php foreach (array_slice($importResult['errors'], 0, 20) as $err): ?>
                    <?= htmlspecialchars($err) ?><br>
                <?php endforeach; ?>
                <?php if (count($importResult['errors']) > 20): ?>
                    ... và <?= count($importResult['errors']) - 20 ?> lỗi khác
                <?php endif; ?>
            </div>
        </details>
        <?php endif; ?>
    </div>
</div>
<div style="margin-top:16px;">
    <a href="import.php" class="btn btn-primary"><i class="ri-upload-2-line"></i> Import thêm</a>
</div>
<?php endif; ?>

<?php if ($step === 'upload' || !empty($errors)): ?>
<div class="card">
    <div class="card-header">
        <h2><i class="ri-upload-cloud-2-line"></i> Upload file CSV</h2>
    </div>

    <form method="POST" enctype="multipart/form-data">
        <input type="hidden" name="step" value="upload">

        <div class="form-group">
            <label>Loại dữ liệu <span class="required">*</span></label>
            <select name="data_type" class="form-control" required>
                <option value="">-- Chọn loại --</option>
                <option value="topics" <?= $dataType === 'topics' ? 'selected' : '' ?>>Topics</option>
                <option value="vocabularies" <?= $dataType === 'vocabularies' ? 'selected' : '' ?>>Vocabularies</option>
                <option value="questions" <?= $dataType === 'questions' ? 'selected' : '' ?>>Questions</option>
            </select>
            <p class="form-hint">Chọn đúng loại dữ liệu trong file CSV của bạn.</p>
        </div>

        <div class="form-group">
            <label>File CSV <span class="required">*</span></label>
            <div class="import-dropzone" id="dropzone" onclick="document.getElementById('csvFile').click();">
                <i class="ri-upload-cloud-2-line"></i>
                <p>Kéo thả file vào đây hoặc click để chọn</p>
                <small>Chỉ chấp nhận file .csv (tối đa 5MB)</small>
            </div>
            <input type="file" name="csv_file" id="csvFile" accept=".csv,.txt" style="display:none;" onchange="handleFileSelect(this)">
            <div id="fileInfo" style="margin-top:12px;display:none;" class="alert alert-info">
                <i class="ri-file-chart-line"></i>
                <span id="fileName"></span>
                <span id="fileSize"></span>
            </div>
        </div>

        <div style="display:flex;gap:12px;padding-top:8px;">
            <button type="submit" class="btn btn-primary"><i class="ri-eye-line"></i> Xem trước</button>
        </div>
    </form>
</div>

<div class="card">
    <div class="card-header">
        <h2><i class="ri-information-line"></i> Hướng dẫn</h2>
    </div>
    <div style="font-size:14px;color:var(--text-muted);line-height:1.8;">
        <p>1. Export dữ liệu từ Admin Panel trước bằng cách vào <strong>Export CSV</strong>.</p>
        <p>2. Mở file CSV, chỉnh sửa dữ liệu theo yêu cầu.</p>
        <p>3. Upload lại file đã chỉnh sửa, chọn đúng <strong>loại dữ liệu</strong>.</p>
        <p>4. Nhấn <strong>"Xem trước"</strong> để kiểm tra trước khi import.</p>
        <p>5. Sau khi xác nhận, nhấn <strong>"Import"</strong> để thêm dữ liệu.</p>
        <p style="margin-top:12px;padding:10px;background:#fff3cd;border-radius:6px;color:#856404;">
            <strong>Lưu ý:</strong> Dùng <code>INSERT IGNORE</code> — các dòng trùng ID sẽ tự động bị bỏ qua.
        </p>
    </div>
</div>
<?php endif; ?>

<?php if ($step === 'preview' && $preview): ?>
<div class="card">
    <div class="card-header">
        <h2><i class="ri-eye-line"></i> Xem trước: <?= ucfirst($preview['section']) ?></h2>
    </div>

    <div class="alert alert-info" style="margin-bottom:16px;">
        <i class="ri-file-chart-line"></i>
        <div>
            <strong><?= htmlspecialchars($preview['filename']) ?></strong><br>
            <?= number_format($preview['total_lines']) ?> dòng trong file. Hiển thị <?= count($preview['rows']) ?> dòng đầu.
        </div>
    </div>

    <div class="table-container">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <?php foreach ($preview['headers'] as $h): ?>
                    <th><?= htmlspecialchars($h) ?></th>
                    <?php endforeach; ?>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($preview['rows'] as $idx => $row): ?>
                <tr>
                    <td><?= $idx + 1 ?></td>
                    <?php foreach ($row as $cell): ?>
                    <td><?= htmlspecialchars($cell) ?></td>
                    <?php endforeach; ?>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <div style="margin-top:20px;padding:16px;background:#fff3cd;border-radius:8px;">
        <p style="font-size:14px;color:#856404;margin:0;">
            <i class="ri-alert-line"></i>
            <strong>Xác nhận Import?</strong> Các dòng trùng ID sẽ bị bỏ qua. Bạn có chắc chắn muốn tiếp tục?
        </p>
    </div>

    <form method="POST" style="margin-top:16px;">
        <input type="hidden" name="step" value="preview">
        <input type="hidden" name="data_type" value="<?= htmlspecialchars($preview['section']) ?>">
        <input type="hidden" name="csv_content" value="<?= htmlspecialchars($csvContentForForm) ?>">

        <div style="display:flex;gap:12px;">
            <button type="submit" class="btn btn-success"><i class="ri-upload-2-line"></i> Xác nhận Import</button>
            <a href="import.php" class="btn btn-secondary">Hủy</a>
        </div>
    </form>
</div>
<?php endif; ?>

<script>
const dropzone = document.getElementById('dropzone');
const csvFileInput = document.getElementById('csvFile');
const fileInfo = document.getElementById('fileInfo');

function handleFileSelect(input) {
    if (input.files && input.files[0]) {
        showFileInfo(input.files[0]);
    }
}

function showFileInfo(file) {
    document.getElementById('fileName').textContent = file.name;
    document.getElementById('fileSize').textContent = ' (' + formatSize(file.size) + ')';
    fileInfo.style.display = 'flex';
    dropzone.querySelector('p').textContent = file.name;
}

function formatSize(bytes) {
    if (bytes < 1024) return bytes + ' B';
    if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
}

if (dropzone) {
    dropzone.addEventListener('dragover', function(e) {
        e.preventDefault();
        dropzone.classList.add('dragover');
    });
    dropzone.addEventListener('dragleave', function() {
        dropzone.classList.remove('dragover');
    });
    dropzone.addEventListener('drop', function(e) {
        e.preventDefault();
        dropzone.classList.remove('dragover');
        if (e.dataTransfer.files && e.dataTransfer.files[0]) {
            csvFileInput.files = e.dataTransfer.files;
            showFileInfo(e.dataTransfer.files[0]);
        }
    });
}
</script>

<?php include __DIR__ . '/partials/footer.php'; ?>
