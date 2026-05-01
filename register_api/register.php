<?php
require_once 'db_connection.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // قراءة البيانات المرسلة من Flutter
    $json_data = file_get_contents('php://input');
    $data = json_decode($json_data, true);
    
    // التحقق من وجود البيانات المطلوبة
    if (!$data || !isset($data['full_name']) || !isset($data['email']) || 
        !isset($data['password']) || !isset($data['phone'])) {
        echo json_encode([
            "success" => false,
            "message" => "بيانات غير مكتملة"
        ]);
        exit;
    }
    
    // تنظيف المدخلات
    $full_name = $conn->real_escape_string(trim($data['full_name']));
    $email = $conn->real_escape_string(trim($data['email']));
    $phone = $conn->real_escape_string(trim($data['phone']));
    
    // ✅ إضافة: التحقق من صحة البريد إلكتروني في الخادم
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            "success" => false,
            "message" => "البريد الإلكتروني غير صحيح"
        ]);
        exit;
    }
    
    // ✅ إضافة: التحقق من قوة كلمة المرور في الخادم
    $password = $data['password'];
    if (strlen($password) < 8) {
        echo json_encode([
            "success" => false,
            "message" => "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
        ]);
        exit;
    }
    
    // ✅ إضافة: التحقق من وجود أرقام وحروف ورموز في كلمة المرور
    if (!preg_match('/[A-Za-z]/', $password) || 
        !preg_match('/[0-9]/', $password) || 
        !preg_match('/[!@#$%^&*(),.?":{}|<>]/', $password)) {
        echo json_encode([
            "success" => false,
            "message" => "كلمة المرور يجب أن تحتوي على حروف وأرقام ورموز"
        ]);
        exit;
    }
    
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // التحقق من عدم وجود البريد الإلكتروني مسبقاً
    $check_email = "SELECT id FROM users WHERE email = '$email'";
    $result = $conn->query($check_email);
    
    if ($result->num_rows > 0) {
        echo json_encode([
            "success" => false,
            "message" => "البريد الإلكتروني مسجل مسبقاً"
        ]);
        exit;
    }
    
    // إدخال المستخدم الجديد
    $sql = "INSERT INTO users (full_name, email, password, phone) VALUES ('$full_name', '$email', '$hashed_password', '$phone')";
    
    if ($conn->query($sql) === TRUE) {
        $user_id = $conn->insert_id;
        echo json_encode([
            "success" => true,
            "message" => "تم التسجيل بنجاح",
            "user_id" => $user_id,
            "user_name" => $full_name,
            "user_email" => $email
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "خطأ في التسجيل: " . $conn->error
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