<?php
header('Content-Type: application/json');
$apiKey = 'ここに好きなランダム文字列';
$headers = array_change_key_case(getallheaders(), CASE_UPPER);
if (!isset($headers['X-API-KEY']) || $headers['X-API-KEY'] !== $apiKey) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden']);
    exit;
}
$host = 'localhost';
$dbname = 'あなたのDB名';
$user = 'あなたのユーザー名';
$password = 'あなたのパスワード';

$input = json_decode(file_get_contents('php://input'), true);
$name = $input['name'];
$quantity = $input['quantity'];

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->prepare(
        "INSERT INTO parts (name, quantity) VALUES (:name, :quantity)"
    );
    $stmt->execute(['name' => $name, 'quantity' => $quantity]);
    $newId = $pdo->lastInsertId('parts_id_seq');

    $logStmt = $pdo->prepare(
        "INSERT INTO usage_log (part_id, part_name, delta) VALUES (:part_id, :part_name, :delta)"
    );
    $logStmt->execute(['part_id' => $newId, 'part_name' => $name, 'delta' => $quantity]);

    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}