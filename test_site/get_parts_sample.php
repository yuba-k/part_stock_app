<?php
header('Content-Type: application/json');

$host = 'localhost';
$dbname = 'your db name';
$user = 'your user name';
$password = 'your passward';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $stmt = $pdo->query("SELECT id, name, quantity FROM parts ORDER BY id");
    $parts = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($parts);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}