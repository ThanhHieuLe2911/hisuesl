<?php
require_once __DIR__ . '/../../config/database.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (!isset($_SESSION['admin_id'])) {
    header('Location: /hisuesl_backend/admin/login.php');
    exit;
}

$id = $_GET['id'] ?? null;
if (!$id) {
    header('Location: index.php');
    exit;
}

// Kiểm tra có vocab liên quan không
$stmt = $db->prepare("SELECT COUNT(*) FROM vocabularies WHERE unit_id = ?");
$stmt->execute([$id]);
$vocabCount = $stmt->fetchColumn();

if ($vocabCount > 0) {
    $_SESSION['flash_error'] = "Không thể xóa topic này! Có $vocabCount vocabularies liên quan. Hãy xóa vocab trước.";
    header('Location: index.php');
    exit;
}

$stmt = $db->prepare("DELETE FROM topics WHERE id = ?");
$stmt->execute([$id]);

$_SESSION['flash_success'] = 'Xóa topic thành công!';
header('Location: index.php');
exit;
