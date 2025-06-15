import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  late AnimationController _slideController;
  late Animation<Offset> _domainSlide;
  late Animation<double> _fadeSecondary;
  late Animation<Offset> _bottomSlide;

  bool _showDomains = false;
  bool _showBottomUI = false;

  final List<String> superDomains = [
    'CSE',
    'Mech',
    'Chem',
    'Civil',
    'Electrical',
    'Biochem',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _domainSlide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutExpo),
        );
    _fadeSecondary = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward().whenComplete(() {
      setState(() => _showDomains = true);
      _slideController.forward().whenComplete(() {
        setState(() => _showBottomUI = true);
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _handleTap(String domain) {
    if (domain == 'CSE') {
      Navigator.pushNamed(context, '/category-select');
    } else {
      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
            backgroundColor: const Color(0xFF0E0F1C),
            body: Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: Text(
                  '$domain Coming Soon!',
                  style: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E6D0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1C),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: _showBottomUI
            ? [
                SlideTransition(
                  position: _bottomSlide,
                  child: FadeTransition(
                    opacity: _fadeSecondary,
                    child: IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/auth');
                      },
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icon/xzellium_icon.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00E6D0), Color(0xFF4C00FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        'Welcome to Xzellium',
                        style: GoogleFonts.sora(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Xcel in your skills. Rise on the world’s podium.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFFB0B0B0),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              if (_showDomains)
                SlideTransition(
                  position: _domainSlide,
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: superDomains.map((domain) {
                      return GestureDetector(
                        onTap: () => _handleTap(domain),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C00FF), Color(0xFF00E6D0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Text(
                            domain,
                            style: GoogleFonts.sora(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 40),
              if (_showBottomUI)
                SlideTransition(
                  position: _bottomSlide,
                  child: FadeTransition(
                    opacity: _fadeSecondary,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/auth');
                      },
                      child: Text(
                        'Already have an account? Sign In',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF00E6D0),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
