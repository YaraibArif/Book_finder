import 'package:book_finder/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart'; // 👈 AppColors import karo

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "icon": Icons.menu_book_rounded,
      "title": "Search Books",
      "desc":
      "Find books by title, author, or ISBN from the Open Library collection.",
    },
    {
      "icon": Icons.favorite,
      "title": "Save Favorites",
      "desc": "Sign in and save your favorite books for quick access later.",
    },
    {
      "icon": Icons.person,
      "title": "Explore Authors",
      "desc":
      "Discover authors, explore their works, and learn more about them.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 👈 HomeScreen jaisa background
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: AppColors.background, // 👈 match with HomeScreen
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pages[index]["icon"] as IconData,
                      size: 150,
                      color: AppColors.secondary, // theme accent
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _pages[index]["title"]!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pages[index]["desc"]!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 🔘 Dots indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          // ⏭ Skip Button
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  SignInScreen()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // ⏭ Next / Get Started Button
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: () {
                if (_currentPage == _pages.length - 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  SignInScreen()),
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text(
                _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
