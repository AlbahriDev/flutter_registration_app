<?php
require_once 'db_connection.php';

$sql = "SELECT id, full_name, email, phone, created_at FROM users ORDER BY created_at DESC";
$result = $conn->query($sql);

$users = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $users[] = $row;
    }
}

echo json_encode([
    "success" => true,
    "users" => $users
]);

$conn->close();
?>