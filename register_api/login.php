<?php
require_once 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $json_data = file_get_contents('php://input');
    $data = json_decode($json_data, true);
    
    if (!$data || !isset($data['email']) || !isset($data['password'])) {
        echo json_encode([
            "success" => false,
            "message" => "البريد الإلكتروني وكلمة المرور مطلوبان"
        ]);
        exit;
    }
    
    $email = $conn->real_escape_string(trim($data['email']));
    $password = $data['password'];
    
    // البحث عن المستخدم
    $sql = "SELECT id, full_name, email, password, phone FROM users WHERE email = '$email'";
    $result = $conn->query($sql);
    
    if ($result->num_rows === 0) {
        echo json_encode([
            "success" => false,
            "message" => "البريد الإلكتروني غير موجود"
        ]);
        exit;
    }
    
    $user = $result->fetch_assoc();
    
    // التحقق من كلمة المرور
    if (password_verify($password, $user['password'])) {
        // إخفاء كلمة المرور قبل الإرسال
        unset($user['password']);
        echo json_encode([
            "success" => true,
            "message" => "تم تسجيل الدخول بنجاح",
            "user" => $user
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "كلمة المرور غير صحيحة"
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "طريقة طلب غير صحيحة"
    ]);
}

$conn->close();
?>