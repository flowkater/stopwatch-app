import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stopwatch_app/application/providers/provider_reset.dart';
import '../../application/providers/providers.dart';
import '../../application/providers/usercase/usecase_providers.dart';
import 'stopwatch_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 먼저 모든 프로바이더 초기화
      resetAllProviders(ref);
      final userId = _userIdController.text.trim();

      // userId를 설정 (Provider 초기화 후)
      ref.read(userIdProvider.notifier).state = userId;

      // 인증 유즈케이스 사용
      final authUseCase = ref.read(authUseCaseProvider);
      await authUseCase.login(userId);

      if (mounted) {
        // 스톱워치 페이지로 이동
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StopwatchPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '스톱워치 앱에 오신 것을 환영합니다!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _userIdController,
                decoration: const InputDecoration(
                  labelText: '사용자 ID',
                  hintText: '사용자 ID를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '사용자 ID를 입력해주세요';
                  }
                  if (value.trim().length < 3) {
                    return '사용자 ID는 최소 3자 이상이어야 합니다';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _login,
                          child: const Text(
                            '로그인',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
