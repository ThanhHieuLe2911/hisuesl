<?php

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit(0);
}

require_once __DIR__ . '/config/database.php';


$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);


if (strpos($uri, '/api/topics') !== false) {
    require __DIR__ . '/controllers/TopicController.php';
    exit;
}

if (strpos($uri, '/api/vocabularies') !== false) {
    require __DIR__ . '/controllers/VocabularyController.php';
    exit;
}

if (strpos($uri, '/api/questions') !== false) {
    require __DIR__ . '/controllers/QuestionController.php';
    exit;
}

if (strpos($uri, '/api/health') !== false) {
    header('Content-Type: application/json; charset=utf-8');
    echo json_encode([
        'status' => 'ok',
        'database' => 'connected',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
    exit;
}

// ============================================================
// 404 Not Found
// ============================================================
http_response_code(404);
header('Content-Type: application/json; charset=utf-8');
echo json_encode([
    'error' => 'Endpoint not found',
    'path' => $uri,
    'hint' => 'Use /api/topics, /api/vocabularies, /api/questions, /api/health'
]);
?>
