<?php
require_once 'db_connection.php';

echo json_encode([
    "success" => true,
    "message" => "الاتصال بقاعدة البيانات يعمل بشكل صحيح",
    "server_info" => $conn->server_info
]);
?>