<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// إعدادات الاتصال بقاعدة البيانات
$host = "localhost";
$username = "root";
$password = "";
$database = "user_registration";

// إنشاء الاتصال
$conn = new mysqli($host, $username, $password, $database);

// التحقق من الاتصال
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "فشل الاتصال بقاعدة البيانات: " . $conn->connect_error
    ]));
}

// تعيين الترميز إلى UTF-8
$conn->set_charset("utf8");
?>