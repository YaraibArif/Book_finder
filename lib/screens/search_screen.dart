import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/search_provider.dart';
import '../../widgets/book_card.dart';
import '../../utils/settings_manager.dart'; // ✅ import SettingsManager

class SearchScreen extends StatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, required this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _filter = "All";
  String _searchMode = "press"; // default

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialQuery;

    // ✅ load search mode from preferences
    SettingsManager.getSearchMode().then((mode) {
      setState(() => _searchMode = mode);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchProvider>().search(query: widget.initialQuery);
    });
  }

  void _onSearch() {
    context.read<SearchProvider>().search(
      query: _controller.text,
      filter: _filter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Search books, authors, ISBN...",
            border: InputBorder.none,
          ),
          // ✅ Behavior depends on searchMode
          onChanged: (val) {
            if (_searchMode == "on_type") {
              _onSearch();
            }
          },
          onSubmitted: (_) {
            if (_searchMode == "press") {
              _onSearch();
            }
          },
        ),
        actions: [
          if (_searchMode == "press") // ✅ only show button in press mode
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _onSearch,
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: ["All", "Title", "Author", "ISBN"]
                  .map((f) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _filter == f,
                  onSelected: (_) {
                    setState(() => _filter = f);
                    _onSearch();
                  },
                ),
              ))
                  .toList(),
            ),
          ),
          // Results
          Expanded(
            child: Builder(
              builder: (_) {
                if (provider.state == SearchState.loading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (provider.state == SearchState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.errorMessage ?? "Error occurred"),
                        ElevatedButton(
                          onPressed: _onSearch,
                          child: const Text("Retry"),
                        )
                      ],
                    ),
                  );
                } else if (provider.results.isEmpty) {
                  return const Center(child: Text("No results found"));
                } else {
                  return ListView.builder(
                    controller: provider.scrollController,
                    itemCount: provider.results.length,
                    itemBuilder: (_, i) =>
                        BookCard(book: provider.results[i]),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
