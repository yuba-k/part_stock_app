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
$id = $input['id'];
$delta = $input['delta'];

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 数量を更新し、更新した行のnameをそのまま受け取る
    $stmt = $pdo->prepare(
        "UPDATE parts SET quantity = GREATEST(quantity + :delta, 0) WHERE id = :id RETURNING name"
    );
    $stmt->execute(['delta' => $delta, 'id' => $id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $partName = $row['name'] ?? 'unknown';

    // usage_logに1行記録
    $logStmt = $pdo->prepare(
        "INSERT INTO usage_log (part_id, part_name, delta) VALUES (:part_id, :part_name, :delta)"
    );
    $logStmt->execute(['part_id' => $id, 'part_name' => $partName, 'delta' => $delta]);

    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}