import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نموذج التسجيل الذكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        useMaterial3: true,
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: FirstScreen(),
      ),
    );
  }
}

// الشاشة الأولى: نموذج التسجيل
class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // متغيرات لعرض قوة كلمة المرور
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  double _strengthProgress = 0.0;

  // متغيرات لإظهار/إخفاء كلمة المرور
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // متغيرات لتتبع الحقول التي تم التفاعل معها
  bool _nameTouched = false;
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _confirmTouched = false;
  bool _phoneTouched = false;

  // دوال التحقق من صحة الحقول
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return '✖ الحقل مطلوب';
    }
    if (value.length < 10) {
      return '✖ يجب أن يكون الاسم 10  حرف على الأقل';
    }
    if (value.length > 20) {
      return '✖ يجب ألا يزيد الاسم عن 20 حرف';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return '✖ البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return '✖ أدخل بريداً إلكترونياً صحيحاً';
    }
    return null;
  }

  // دالة حساب قوة كلمة المرور
  void _updatePasswordStrength(String password) {
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
        _strengthColor = Colors.grey;
        _strengthProgress = 0.0;
        return;
      }
      bool hasLetters = RegExp(r'[A-Za-z]').hasMatch(password);
      bool hasNumbers = RegExp(r'[0-9]').hasMatch(password);
      bool hasSymbols = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      int strengthScore = (hasLetters ? 1 : 0) + (hasNumbers ? 1 : 0) + (hasSymbols ? 1 : 0);
      
      if (password.length >= 8 && strengthScore == 3) {
        _passwordStrength = '💪 قوية';
        _strengthColor = Colors.green;
        _strengthProgress = 1.0;
      } else if (password.length >= 6 && strengthScore >= 2) {
        _passwordStrength = '⚠️ متوسطة';
        _strengthColor = Colors.orange;
        _strengthProgress = 0.6;
      } else {
        _passwordStrength = '❌ ضعيفة';
        _strengthColor = Colors.red;
        _strengthProgress = 0.3;
      }
    });
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '✖ كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return '✖ يجب أن تكون 8 أحرف على الأقل';
    }
    bool hasLetters = RegExp(r'[A-Za-z]').hasMatch(value);
    bool hasNumbers = RegExp(r'[0-9]').hasMatch(value);
    bool hasSymbols = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
    
    if (!hasLetters) {
      return '✖ يجب أن تحتوي على حروف';
    }
    if (!hasNumbers) {
      return '✖ يجب أن تحتوي على أرقام';
    }
    if (!hasSymbols) {
      return '✖ يجب أن تحتوي على رموز';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return '✖ تأكيد كلمة المرور مطلوب';
    }
    if (value != _passwordController.text) {
      return '✖ كلمة المرور غير متطابقة';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '✖ رقم الهاتف مطلوب';
    }
    if (value.length < 9) {
      return '✖ رقم الهاتف قصير جداً';
    }
    if (!RegExp(r'^[0-9+()-]+$').hasMatch(value)) {
      return '✖ أرقام فقط (+ أو - أو () مسموح)';
    }
    return null;
  }

void _validateAndProceed() async {
  setState(() {
    _nameTouched = true;
    _emailTouched = true;
    _passwordTouched = true;
    _confirmTouched = true;
    _phoneTouched = true;
  });

  String? nameError = _validateName(_nameController.text);
  String? emailError = _validateEmail(_emailController.text);
  String? passwordError = _validatePassword(_passwordController.text);
  String? confirmError = _validateConfirmPassword(_confirmPasswordController.text);
  String? phoneError = _validatePhone(_phoneController.text);

  if (nameError != null) {
    _showErrorDialog('خطأ في حقل الاسم', nameError);
    return;
  }
  if (emailError != null) {
    _showErrorDialog('خطأ في البريد الإلكتروني', emailError);
    return;
  }
  if (passwordError != null) {
    _showErrorDialog('خطأ في كلمة المرور', passwordError);
    return;
  }
  if (confirmError != null) {
    _showErrorDialog('خطأ في تأكيد كلمة المرور', confirmError);
    return;
  }
  if (phoneError != null) {
    _showErrorDialog('خطأ في رقم الهاتف', phoneError);
    return;
  }

  // عرض مؤشر تحميل
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  // محاولة التسجيل عبر API
  final apiService = ApiService();
  final result = await apiService.registerUser(
    fullName: _nameController.text,
    email: _emailController.text,
    password: _passwordController.text,
    phone: _phoneController.text,
  );

  // إغلاق مؤشر التحميل
  Navigator.pop(context);

  if (result['success'] == true) {
    // نجاح (سواء تسجيل جديد أو تسجيل دخول)
    String userName = result['user_name'] ?? _nameController.text;
    String userEmail = result['user_email'] ?? _emailController.text;
    
    if (result['is_login'] == true) {
      // ✅ تم تسجيل الدخول (بريد موجود)
      _showSuccessDialog('تم تسجيل الدخول', 'مرحباً بعودتك $userName', userName, userEmail);
    } else {
      // ✅ تم التسجيل الجديد
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: SecondScreen(
              userName: userName,
              userEmail: userEmail,
            ),
          ),
        ),
      );
    }
  } else {
    // فشل
    _showErrorDialog('فشل', result['message'] ?? 'حدث خطأ غير متوقع');
  }
}

// دالة إضافية لعرض رسالة نجاح لتسجيل الدخول
void _showSuccessDialog(String title, String message, String userName, String userEmail) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            // الانتقال إلى شاشة النجاح
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: SecondScreen(
                    userName: userName,
                    userEmail: userEmail,
                  ),
                ),
              ),
            );
          },
          child: const Text('متابعة'),
        ),
      ],
    ),
  );
}
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('نموذج التسجيل'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topRight,
              end: Alignment.topLeft,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة ترحيب بالتصميم الجديد
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topRight,
                      end: Alignment.topLeft,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.assignment_turned_in,
                        size: 45,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'التكليف الجامعي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'أكمل البيانات بدقة ✓',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          'الدكتور زبير',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // الحقل الأول: اسم المستخدم
                _buildInputField(
                  label: 'الاسم الكامل',
                  controller: _nameController,
                  validator: _validateName,
                  touched: _nameTouched,
                  onFieldSubmitted: (_) => setState(() => _nameTouched = true),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) setState(() => _nameTouched = true);
                  },
                  hint: 'أدخل اسمك (10-20 حرف)',
                  maxLength: 20,
                  prefixIcon: Icons.person_outline,
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                ),
                const SizedBox(height: 20),

                // الحقل الثاني: البريد الإلكتروني
                _buildInputField(
                  label: 'البريد الإلكتروني',
                  controller: _emailController,
                  validator: _validateEmail,
                  touched: _emailTouched,
                  onFieldSubmitted: (_) => setState(() => _emailTouched = true),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) setState(() => _emailTouched = true);
                  },
                  hint: 'example@domain.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),

                // الحقل الثالث: كلمة المرور (مع زر إظهار/إخفاء)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPasswordField(
                      label: 'كلمة المرور',
                      controller: _passwordController,
                      validator: _validatePassword,
                      touched: _passwordTouched,
                      onFieldSubmitted: (_) => setState(() => _passwordTouched = true),
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) setState(() => _passwordTouched = true);
                      },
                      hint: '8 أحرف + أرقام + رموز',
                      prefixIcon: Icons.lock_outline,
                      isPasswordVisible: _isPasswordVisible,
                      onVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onChanged: (value) {
                        _updatePasswordStrength(value);
                        if (_passwordTouched) setState(() {});
                      },
                    ),
                    if (_passwordStrength.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('قوة كلمة المرور:', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                const SizedBox(width: 8),
                                Text(_passwordStrength, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _strengthColor)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: _strengthProgress,
                              backgroundColor: Colors.grey[200],
                              color: _strengthColor,
                              borderRadius: BorderRadius.circular(10),
                              minHeight: 6,
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildRequirementChip('حروف', RegExp(r'[A-Za-z]').hasMatch(_passwordController.text)),
                          _buildRequirementChip('أرقام', RegExp(r'[0-9]').hasMatch(_passwordController.text)),
                          _buildRequirementChip('رموز', RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)),
                          _buildRequirementChip('طول 8+', _passwordController.text.length >= 8),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // الحقل الرابع: تأكيد كلمة المرور (مع زر إظهار/إخفاء)
                _buildPasswordField(
                  label: 'تأكيد كلمة المرور',
                  controller: _confirmPasswordController,
                  validator: _validateConfirmPassword,
                  touched: _confirmTouched,
                  onFieldSubmitted: (_) => setState(() => _confirmTouched = true),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) setState(() => _confirmTouched = true);
                  },
                  hint: 'أعد كتابة كلمة المرور',
                  prefixIcon: Icons.lock_outline,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onVisibilityToggle: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 20),

                // الحقل الخامس: رقم الهاتف مع أيقونة
                _buildInputField(
                  label: 'رقم الهاتف',
                  controller: _phoneController,
                  validator: _validatePhone,
                  touched: _phoneTouched,
                  onFieldSubmitted: (_) => setState(() => _phoneTouched = true),
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) setState(() => _phoneTouched = true);
                  },
                  hint: '+967 123456789',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                ),
                const SizedBox(height: 35),

                // زر التحقق والانتقال
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 3,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('تسجيل ومتابعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء حقول كلمة المرور مع زر إظهار/إخفاء
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required bool touched,
    required void Function(String)? onFieldSubmitted,
    required void Function(bool)? onFocusChange,
    String? hint,
    required bool isPasswordVisible,
    required VoidCallback onVisibilityToggle,
    IconData? prefixIcon,
    void Function(String)? onChanged,
  }) {
    String? errorText = touched ? validator(controller.text) : null;
    bool hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isPasswordVisible,
          keyboardType: TextInputType.text,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF667EEA)) : null,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onVisibilityToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            errorText: hasError ? errorText : null,
            errorStyle: const TextStyle(fontSize: 11, height: 0.8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // دالة مساعدة لبناء الحقول العادية
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required bool touched,
    required void Function(String)? onFieldSubmitted,
    required void Function(bool)? onFocusChange,
    String? hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
    void Function(String)? onChanged,
  }) {
    String? errorText = touched ? validator(controller.text) : null;
    bool hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF667EEA)) : null,
            counterText: maxLength != null ? '${controller.text.length}/$maxLength' : null,
            filled: true,
            fillColor: Colors.white,
            errorText: hasError ? errorText : null,
            errorStyle: const TextStyle(fontSize: 11, height: 0.8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667EEA), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementChip(String text, bool isMet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isMet ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isMet ? Colors.green : Colors.grey.shade400),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isMet ? Icons.check_circle : Icons.cancel, size: 14, color: isMet ? Colors.green : Colors.red),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 12, color: isMet ? Colors.green[800] : Colors.grey[700])),
        ],
      ),
    );
  }
}

// الشاشة الثانية
class SecondScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SecondScreen({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('تم بنجاح'),
        centerTitle: true,
        backgroundColor: const Color(0xFF667EEA),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                  ],
                ),
                child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 30),
              Text(
                'تم التحقق بنجاح!',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  children: [
                    Text(
                      'مرحباً بك يا',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF667EEA)),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    Text(
                      userEmail,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '✓ جميع البيانات صحيحة',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('العودة إلى التسجيل', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667EEA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
            ],
          ),
        ),
      ),
    );
  }
}