<?php
require_once __DIR__ . '/../models/Question.php';

header('Content-Type: application/json; charset=utf-8');

$questionModel = new Question($db);

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (isset($_GET['unit_id'])) {
        $unitId = (int) $_GET['unit_id'];
        echo json_encode($questionModel->getByUnit($unitId));
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'unit_id is required']);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
