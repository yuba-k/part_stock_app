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

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    // 削除前に、現在の情報を取得しておく
    $selectStmt = $pdo->prepare("SELECT name, quantity FROM parts WHERE id = :id");
    $selectStmt->execute(['id' => $id]);
    $row = $selectStmt->fetch(PDO::FETCH_ASSOC);

    $stmt = $pdo->prepare("DELETE FROM parts WHERE id = :id");
    $stmt->execute(['id' => $id]);

    if ($row) {
        $logStmt = $pdo->prepare(
            "INSERT INTO usage_log (part_id, part_name, delta) VALUES (:part_id, :part_name, :delta)"
        );
        $logStmt->execute([
            'part_id' => $id,
            'part_name' => $row['name'],
            'delta' => -$row['quantity'],
        ]);
    }

    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}