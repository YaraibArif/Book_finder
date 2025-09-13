import 'package:book_finder/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

class onboardingScreen extends StatefulWidget {
  const onboardingScreen({super.key});

  @override
  State<onboardingScreen> createState() => _onboardingScreenState();
}

class _onboardingScreenState extends State<onboardingScreen> {
  final PageController _pageController = PageController();
  int _currentpage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "icon": Icons.menu_book_rounded, //  book icon
      "title": "Search Books",
      "desc":
          "Find books by title, author, or ISBN from the Open Library collection.",
    },
    {
      "icon": Icons.favorite, // Heart icon
      "title": "Save Favorites",
      "desc": "Sign in and save your favorite books for quick access later.",
    },
    {
      "icon": Icons.person, // Author/Person icon
      "title": "Explore Authors",
      "desc":
          "Discover authors, explore their works, and learn more about them.",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentpage = index);
            },
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF2962FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pages[index]["icon"] as IconData,
                      size: 150,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _pages[index]["title"]!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _pages[index]["desc"]!,
                      textAlign: TextAlign.center,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              );
            },
          ),

          //dots indicator
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
                  width: _currentpage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentpage == index
                        ? Colors.white
                        : Colors.white54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          //Skip button
          Positioned(
            bottom: 20,
            left: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) =>  SignInScreen())
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          //Next Button
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: () {
                if (_currentpage == _pages.length - 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>  SignInScreen())
                  );
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text(
                _currentpage == _pages.length - 1 ? "Get Started" : "Next",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
