<?php
header('Content-Type: application/json');

$host = 'localhost';
$dbname = 'あなたのDB名';
$user = 'あなたのユーザー名';
$password = 'あなたのパスワード';

$input = json_decode(file_get_contents('php://input'), true);
$id = $input['id'];

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->prepare("DELETE FROM parts WHERE id = :id");
    $stmt->execute(['id' => $id]);

    echo json_encode(['success' => true]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}