import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://zajdlwpkfzclakggrbpk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphamRsd3BrZnpjbGFrZ2dyYnBrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MjYxODUsImV4cCI6MjA1NzUwMjE4NX0.lQMt2o2aZNRtNJVJs4UlP-qA17CE3a6zBto24Ho19ZM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auth Demo',
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLogin ? LoginPage(onToggle: toggleMode) : SignUpPage(onToggle: toggleMode);
  }
}

class SignUpPage extends StatefulWidget {
  final VoidCallback onToggle;
  const SignUpPage({super.key, required this.onToggle});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    try {
      final response = await _supabase.auth.signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        await _supabase.from('profiles').insert({
          'user_id': response.user!.id,
          'name': _nameController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        widget.onToggle();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Create Account'),
            ),
            TextButton(
              onPressed: widget.onToggle,
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginPage({super.key, required this.onToggle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> _login() async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: widget.onToggle,
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}
