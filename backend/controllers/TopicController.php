<?php
require_once __DIR__ . '/../models/Topic.php';

header('Content-Type: application/json; charset=utf-8');

$topicModel = new Topic($db);

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (isset($_GET['id'])) {
        $id = (int) $_GET['id'];
        $result = $topicModel->getById($id);
        if ($result) {
            echo json_encode($result);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'Topic not found']);
        }
    } else {
        echo json_encode($topicModel->getAll());
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
