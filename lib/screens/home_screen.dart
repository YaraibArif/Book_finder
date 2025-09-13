import 'package:book_finder/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/favorite_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/subject_card.dart';
import '../widgets/recent_search_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final List<String> subjects = [
    "fantasy",
    "science_fiction",
    "history",
    "romance",
    "mystery_and_detective_stories",
    "children",
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SubjectProvider>(context, listen: false)
          .fetchSubjects(subjects);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subjectProvider = Provider.of<SubjectProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Open Library"), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔎 Search Bar (using widget)
            SearchBarWidget(
              controller: _searchController,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  subjectProvider.addRecentSearch(val.trim());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(initialQuery: val.trim()),
                    ),
                  );
                }
              },
              // 🔎 Search button tap pe:
              onSearchTap: () {
                final query = _searchController.text.trim();
                if (query.isNotEmpty) {
                  subjectProvider.addRecentSearch(query);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchScreen(initialQuery: query),
                    ),
                  );
                }
              },
            ),

            /// 🕓 Recent Searches (using widget)
            if (subjectProvider.recentSearches.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Recent Searches",
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: subjectProvider.recentSearches.map((query) {
                    return RecentSearchChip(
                      query: query,
                      // 🕓 RecentSearchChip ke onTap me:
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SearchScreen(initialQuery: query),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],

            /// 📚 Popular Subjects
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Popular Subjects",
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              height: 260,
              child: subjectProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : subjectProvider.errorMessage != null
                  ? Center(child: Text(subjectProvider.errorMessage!))
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjectProvider.subjects.length,
                itemBuilder: (ctx, i) {
                  final subject = subjectProvider.subjects[i];
                  return SubjectCard(
                    slug: subject.slug,
                    name: subject.name,
                    covers: subject.covers,
                  );
                },
              ),
            ),

            /// ❤️ Favorites Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Your Favorites",
                  style: Theme.of(context).textTheme.titleMedium),
            ),

            if (authProvider.isSignedIn) ...[
              Consumer<FavoritesProvider?>(
                builder: (context, favoritesProvider, _) {
                  if (favoritesProvider == null) {
                    return const Center(child: Text("Sign in to see favorites"));
                  }

                  return SizedBox(
                    height: 200,
                    child: StreamBuilder(
                      stream: favoritesProvider.favoritesStream,
                      builder: (ctx, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text("Error: ${snapshot.error}"),
                          );
                        }

                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final favorites = snapshot.data!;
                        if (favorites.isEmpty) {
                          return const Center(child: Text("No favorites yet"));
                        }

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favorites.length,
                          itemBuilder: (ctx, i) {
                            final book = favorites[i];
                            return FavoriteCard(
                              book: book,
                              favoritesProvider: favoritesProvider,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    const Text("Sign in to see favorites"),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to SignInScreen
                      },
                      child: const Text("Sign In"),
                    ),
                  ],
                ),
              ),
            ]

          ],
        ),
      ),
    );
  }
}
