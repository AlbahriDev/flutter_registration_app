import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ التصحيح: للمحاكي Android استخدم 10.0.2.2 بدلاً من localhost
  // static const String baseUrl = 'http://localhost/register_api';  // ❌ هذا لا يعمل مع المحاكي
  
  // ✅ للحاسوب (تشغيل على متصفح Chrome)
   static const String baseUrl = 'http://localhost/register_api';
  
  // ✅ للمحاكي Android (الاستخدام الأكثر شيوعاً)
//  static const String baseUrl = 'http://10.0.2.2/register_api';
  
  // ✅ للهاتف الحقيقي (استبدل 192.168.1.100 بـ IP جهازك الحقيقي)
  // static const String baseUrl = 'http://192.168.1.100/register_api';
  
  // ✅ للـ Web على منفذ 8080
  // static const String baseUrl = 'http://localhost:8080/register_api';

  // دالة تسجيل مستخدم جديد
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      print('📤 محاولة التسجيل لـ: $email');
      print('🌐 الاتصال بـ: ${Uri.parse('$baseUrl/register.php')}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        return {
          'success': false,
          'message': '❌ خطأ في الاتصال بالخادم: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': '❌ فشل الاتصال بالخادم. تأكد من:\n1. تشغيل XAMPP\n2. Apache و MySQL شغالين\n3. الاتصال بالإنترنت صحيح',
      };
    }
  }

  // دالة تسجيل الدخول (جديدة)
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 محاولة تسجيل الدخول لـ: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': '❌ خطأ في الاتصال بالخادم: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': '❌ فشل الاتصال بالخادم',
      };
    }
  }

  // دالة جلب جميع المستخدمين
  Future<Map<String, dynamic>> getUsers() async {
    try {
      print('📤 جلب قائمة المستخدمين...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/get_users.php'),
        headers: {'Accept': 'application/json'},
      );

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': '❌ خطأ في جلب البيانات: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': '❌ فشل الاتصال بالخادم: $e',
      };
    }
  }

  // دالة حذف مستخدم (لأغراض الاختبار)
  Future<Map<String, dynamic>> deleteUser({
    required String email,
  }) async {
    try {
      print('📤 محاولة حذف المستخدم: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/delete_user.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': '❌ خطأ في حذف المستخدم: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': '❌ فشل الاتصال بالخادم: $e',
      };
    }
  }

  // دالة التحقق من صحة الاتصال بالخادم
  Future<Map<String, dynamic>> checkConnection() async {
    try {
      print('🔍 التحقق من الاتصال بالخادم...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/check_connection.php'),
        headers: {'Accept': 'application/json'},
      );

      print('✅ Connection check status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': '❌ فشل الاتصال بالخادم: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Connection error: $e');
      return {
        'success': false,
        'message': '❌ لا يمكن الاتصال بالخادم. تأكد من:\n• تشغيل XAMPP\n• Apache يعمل\n• MySQL يعمل',
      };
    }
  }

  // دالة تحديث بيانات المستخدم
  Future<Map<String, dynamic>> updateUser({
    required String email,
    String? fullName,
    String? phone,
    String? password,
  }) async {
    try {
      print('📤 تحديث بيانات المستخدم: $email');
      
      Map<String, dynamic> updateData = {
        'email': email,
      };
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (phone != null) updateData['phone'] = phone;
      if (password != null) updateData['password'] = password;
      
      final response = await http.post(
        Uri.parse('$baseUrl/update_user.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      print('✅ Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': '❌ خطأ في تحديث البيانات: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'message': '❌ فشل الاتصال بالخادم: $e',
      };
    }
  }
}