import 'package:flutter/material.dart';

import '../widgets/custom_text_field.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});
  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  String? _genderSelect;
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.transparent;
  bool _isTermsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validasi nama
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  // Fungsi memunculkan Data Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tanggal lahir tidak boleh kosong';
    }
    return null;
  }

  // Validasi nomor telepon
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    if (value.trim().length < 10 || value.trim().length > 13) {
      return 'Nomor Telepon minimal 10 angka dan maksimal 13 angka';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Nomor Telepon hanya boleh berisi angka';
    }
    return null;
  }

  // Validasi email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // Validasi password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password harus mengandung huruf kapital';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password harus mengandung angka';
    }
    return null;
  }

  // Validasi konfirmasi password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  void _checkPasswordStrength(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
      } else if (value.length < 8) {
        // Lemah: kurang dari 8 karakter
        _passwordStrength = 0.33;
        _passwordStrengthText = 'Lemah';
        _passwordStrengthColor = Colors.red;
      } else {
        bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
        bool hasLowercase = value.contains(RegExp(r'[a-z]'));
        bool hasDigits = value.contains(RegExp(r'[0-9]'));
        bool hasSpecialChars = value.contains(
          RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
        );

        if (hasUppercase && hasLowercase && hasDigits && hasSpecialChars) {
          // Kuat: >= 8 karakter, ada huruf kapital, huruf kecil, angka, dan simbol
          _passwordStrength = 1.0;
          _passwordStrengthText = 'Kuat';
          _passwordStrengthColor = Colors.green;
        } else if ((hasUppercase || hasLowercase) && hasDigits) {
          // Sedang: >= 8 karakter, mengandung huruf dan angka
          _passwordStrength = 0.66;
          _passwordStrengthText = 'Sedang';
          _passwordStrengthColor = Colors.orange;
        } else {
          // Default jika >= 8 tapi belum memenuhi syarat Sedang/Kuat
          _passwordStrength = 0.33;
          _passwordStrengthText = 'Lemah';
          _passwordStrengthColor = Colors.red;
        }
      }
    });
  }

  // Handler submit form
  void _submitForm() {
    if (!_isTermsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui Syarat & Ketentuan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      // Simulasi proses registrasi
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        // Tampilkan dialog sukses
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Registrasi Berhasil'),
            content: Text(
              'Selamat, ${_nameController.text}!\n'
              'Email: ${_emailController.text}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  // Reset form
  void _resetForm() {
    _formKey.currentState!.reset();
    _nameController.clear();
    _dateController.clear();
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Registrasi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 16),
                const Icon(
                  Icons.person_add,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi form di bawah ini untuk mendaftar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Field Nama
                CustomTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  prefixIcon: Icons.person,
                  validator: _validateName,
                ),
                // Field Tanggal Lahir
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir',
                      hintText: 'Pilih tanggal lahir',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: _validateDate,
                  ),
                ),
                // Dropdown Jenis Kelamin
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: DropdownButtonFormField<String>(
                    value: _genderSelect,
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      hintText: 'Pilih jenis kelamin',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Laki-laki',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'Perempuan',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _genderSelect =
                            newValue; // Menyimpan pilihan ke dalam state
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih jenis kelamin'; // Validasi required
                      }
                      return null;
                    },
                  ),
                ),
                //Field Nomor Telepon
                CustomTextField(
                  controller: _phoneController,
                  label: 'Nomor telepon',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                // Field Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                // Field Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Minimal 8 karakter, huruf kapital, angka',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    onChanged: _checkPasswordStrength,
                  ),
                ),
                if (_passwordStrengthText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: Colors.grey[300],
                          color: _passwordStrengthColor,
                          minHeight: 6,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kekuatan: $_passwordStrengthText',
                          style: TextStyle(
                            color: _passwordStrengthColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Field Konfirmasi Password
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      hintText: 'Ulangi password Anda',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                  ),
                ),
                const SizedBox(height: 24),

                CheckboxListTile(
                  title: const Text('Saya setuju dengan Syarat & Ketentuan'),
                  value: _isTermsAccepted,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _isTermsAccepted = newValue ?? false; // Update state
                    });
                  },
                  controlAffinity: ListTileControlAffinity
                      .leading, // Agar kotak centang ada di kiri
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // Tombol Submit
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Daftar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                // Tombol Reset
                OutlinedButton(
                  onPressed: _isLoading ? null : _resetForm,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
