import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top:250,
              left: 50,
              right: 50,
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/images/logo_letras.png',
                    width: 380,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              top: 265,
              left: 180,
              right: 50,
              bottom: 10,
            ),
            child: Text("POWERED BY",
              style: TextStyle(
                  color: Color(0xFF346cb0),
                  fontSize: 10,
                  fontWeight: FontWeight.bold),),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 230,
              right: 50,
            ),
            child: Image.asset('assets/images/my_sense.png'),
          ),
        ],
      ),
    );
  }
}