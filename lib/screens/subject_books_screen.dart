import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../widgets/subject_book_card.dart';
import 'work_detail_screen.dart';

class SubjectBooksScreen extends StatefulWidget {
  final String subject;

  const SubjectBooksScreen({super.key, required this.subject});

  @override
  State<SubjectBooksScreen> createState() => _SubjectBooksScreenState();
}

class _SubjectBooksScreenState extends State<SubjectBooksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SubjectProvider>().fetchSubject(widget.subject);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.works.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.errorMessage != null && provider.works.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.subject)),
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    provider.fetchSubject(widget.subject, loadMore: false),
                child: const Text("Retry"),
              ),
            ),
          );
        }

        final subjectTitle =
            provider.subjectMeta?['name'] ?? widget.subject.replaceAll("_", " ");
        final subjectDesc = provider.subjectMeta?['description'];
        final relatedSubjects =
            (provider.subjectMeta?['subjects'] as List?)
                ?.map((s) => s.toString())
                .toList() ??
                [];

        return Scaffold(
          appBar: AppBar(title: Text(subjectTitle)),
          body: Column(
            children: [
              // 🔹 Description
              if (subjectDesc != null) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    subjectDesc is String
                        ? subjectDesc
                        : (subjectDesc['value'] ?? ""),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],

              // 🔹 Related subjects chips
              if (relatedSubjects.isNotEmpty) ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: relatedSubjects
                        .map(
                          (s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(s),
                          onPressed: () {
                            final slug =
                            s.toLowerCase().replaceAll(" ", "_");
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SubjectBooksScreen(subject: slug),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 🔹 Works List
              Expanded(
                child: provider.works.isEmpty
                    ? const Center(child: Text("No books available"))
                    : NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (provider.hasMore &&
                        !provider.isLoadingMore &&
                        scroll.metrics.pixels >=
                            scroll.metrics.maxScrollExtent - 200) {
                      provider.fetchSubject(widget.subject,
                          loadMore: true);
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: provider.works.length +
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.works.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                              child: CircularProgressIndicator()),
                        );
                      }

                      final work = provider.works[index];

                      return SubjectBookCard(
                        title: work['title'] ?? "Untitled",
                        authors: (work['authors'] as List? ?? [])
                            .map((a) => a['name']?.toString() ?? "")
                            .where((name) => name.isNotEmpty)
                            .toList(),
                        coverId: work['cover_id'],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkDetailScreen(
                                  workKey: work['key']),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
