<?php
require_once __DIR__ . '/../config/database.php';

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}
if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$filename = 'hisuesl_export_' . date('Ymd_His') . '.csv';

header('Content-Type: text/csv; charset=utf-8');
header('Content-Disposition: attachment; filename=' . $filename);

// BOM UTF-8 for Excel
echo "\xEF\xBB\xBF";

// === TOPICS ===
$topics = $db->query("SELECT * FROM topics ORDER BY id")->fetchAll(PDO::FETCH_ASSOC);
echo "=== TOPICS ===\n";
echo "id,title,description,image_path,color\n";
foreach ($topics as $t) {
    echo "{$t['id']},";
    echo '"' . str_replace('"', '""', $t['title']) . '",';
    echo '"' . str_replace('"', '""', $t['description'] ?? '') . '",';
    echo '"' . str_replace('"', '""', $t['image_path'] ?? '') . '",';
    echo '"' . str_replace('"', '""', $t['color'] ?? '') . '"';
    echo "\n";
}

// === VOCABULARIES ===
$vocabs = $db->query("SELECT * FROM vocabularies ORDER BY unit_id, id")->fetchAll(PDO::FETCH_ASSOC);
echo "\n=== VOCABULARIES ===\n";
echo "id,unit_id,word,meaning,pronunciation,type,example_sentence\n";
foreach ($vocabs as $v) {
    echo "{$v['id']},{$v['unit_id']},";
    echo '"' . str_replace('"', '""', $v['word']) . '",';
    echo '"' . str_replace('"', '""', $v['meaning']) . '",';
    echo '"' . str_replace('"', '""', $v['pronunciation'] ?? '') . '",';
    echo '"' . str_replace('"', '""', $v['type'] ?? '') . '",';
    echo '"' . str_replace('"', '""', $v['example_sentence'] ?? '') . '"';
    echo "\n";
}

// === QUESTIONS ===
$questions = $db->query("SELECT * FROM questions ORDER BY unit_id, id")->fetchAll(PDO::FETCH_ASSOC);
echo "\n=== QUESTIONS ===\n";
echo "id,unit_id,type,question_text,correct_answer,options\n";
foreach ($questions as $q) {
    echo "{$q['id']},{$q['unit_id']},";
    echo '"' . str_replace('"', '""', $q['type']) . '",';
    echo '"' . str_replace('"', '""', $q['question_text']) . '",';
    echo '"' . str_replace('"', '""', $q['correct_answer']) . '",';
    echo '"' . str_replace('"', '""', $q['options'] ?? '') . '"';
    echo "\n";
}
exit;
