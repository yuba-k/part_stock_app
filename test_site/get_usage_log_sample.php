<?php
header('Content-Type: application/json');
$apiKey = 'xxxx';
$headers = array_change_key_case(getallheaders(), CASE_UPPER);
if (!isset($headers['X-API-KEY']) || $headers['X-API-KEY'] !== $apiKey) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden']);
    exit;
}
$host = 'localhost';
$dbname = 'your db name';
$user = 'your user name';
$password = 'your passward';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("SELECT * FROM usage_log ORDER BY changed_at DESC");
    $parts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($parts);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}