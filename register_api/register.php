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
    
    // التحقق من صحة البريد إلكتروني
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            "success" => false,
            "message" => "البريد الإلكتروني غير صحيح"
        ]);
        exit;
    }
    
    // التحقق من قوة كلمة المرور
    $password = $data['password'];
    if (strlen($password) < 8) {
        echo json_encode([
            "success" => false,
            "message" => "كلمة المرور يجب أن تكون 8 أحرف على الأقل"
        ]);
        exit;
    }
    
    if (!preg_match('/[A-Za-z]/', $password) || 
        !preg_match('/[0-9]/', $password) || 
        !preg_match('/[!@#$%^&*(),.?":{}|<>]/', $password)) {
        echo json_encode([
            "success" => false,
            "message" => "كلمة المرور يجب أن تحتوي على حروف وأرقام ورموز"
        ]);
        exit;
    }
    
    // التحقق من وجود البريد الإلكتروني مسبقاً
    $check_email = "SELECT id, full_name, password FROM users WHERE email = '$email'";
    $result = $conn->query($check_email);
    
    if ($result->num_rows > 0) {
        // ✅ البريد موجود → محاولة تسجيل دخول
        $user = $result->fetch_assoc();
        
        // التحقق من كلمة المرور
        if (password_verify($password, $user['password'])) {
            // تسجيل الدخول ناجح
            echo json_encode([
                "success" => true,
                "message" => "تم تسجيل الدخول بنجاح",
                "is_login" => true,
                "user_id" => $user['id'],
                "user_name" => $user['full_name'],
                "user_email" => $email
            ]);
        } else {
            // كلمة المرور خاطئة
            echo json_encode([
                "success" => false,
                "message" => "البريد الإلكتروني موجود ولكن كلمة المرور غير صحيحة"
            ]);
        }
        exit;
    }
    
    // ✅ البريد غير موجود → تسجيل مستخدم جديد
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    $sql = "INSERT INTO users (full_name, email, password, phone) VALUES ('$full_name', '$email', '$hashed_password', '$phone')";
    
    if ($conn->query($sql) === TRUE) {
        $user_id = $conn->insert_id;
        echo json_encode([
            "success" => true,
            "message" => "تم التسجيل بنجاح",
            "is_login" => false,
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