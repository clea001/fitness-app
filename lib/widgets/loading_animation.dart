import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartoonLoading extends StatefulWidget {
  final String message;

  const CartoonLoading({super.key, this.message = '正在生成中...'});

  @override
  State<CartoonLoading> createState() => _CartoonLoadingState();
}

class _CartoonLoadingState extends State<CartoonLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: -15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _bounceAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            widget.message,
            style: GoogleFonts.notoSansSc(
              fontSize: 16,
              color: const Color(0xFF636E72),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                backgroundColor: const Color(0xFFDFE6E9),
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFFFF6B35).withOpacity(0.7),
                ),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
