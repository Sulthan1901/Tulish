import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/bookmark_bloc.dart';
import 'word_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(LoadBookmarksEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(32, 32),
              painter: MiniSunburstPainter(),
            ),
            const SizedBox(width: 8),
            const Text('Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<BookmarkBloc>().add(LoadBookmarksEvent());
                } else {
                  context.read<BookmarkBloc>().add(SearchBookmarksEvent(value));
                }
              },
              decoration: InputDecoration(
                hintText: 'Search favorites...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<BookmarkBloc>().add(LoadBookmarksEvent());
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<BookmarkBloc, BookmarkState>(
              builder: (context, state) {
                if (state is BookmarkLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BookmarksLoaded) {
                  if (state.bookmarks.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: state.bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = state.bookmarks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            bookmark.wordText,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${bookmark.partOfSpeech ?? ''}\n${bookmark.definition ?? ''}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  if (bookmark.wordId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WordDetailScreen(wordId: bookmark.wordId!),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (bookmark.wordId != null) {
                                    context.read<BookmarkBloc>().add(RemoveBookmarkEvent(bookmark.wordId!));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is BookmarkError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('Loading...'));
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (index == 2) {
            Navigator.of(context).pushReplacementNamed('/settings');
          }
        },
      ),
    );
  }
}

class MiniSunburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFB3D9)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3.5;

    canvas.drawCircle(center, radius, paint);

    const rayCount = 16;
    for (var i = 0; i < rayCount; i++) {
      final angle = (i * 360 / rayCount) * (3.14159 / 180);
      final startX = center.dx + (radius * 1.1) * _cos(angle);
      final startY = center.dy + (radius * 1.1) * _sin(angle);
      final endX = center.dx + (radius * 1.6) * _cos(angle);
      final endY = center.dy + (radius * 1.6) * _sin(angle);

      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(endX, endY);
      
      final rayPaint = Paint()
        ..color = const Color(0xFFFFB3D9)
        ..strokeWidth = i.isEven ? 4 : 2
        ..strokeCap = StrokeCap.round;
      
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
  
  double _cos(double radians) {
    final x = radians;
    return 1 - (x * x) / 2 + (x * x * x * x) / 24;
  }
  
  double _sin(double radians) {
    final x = radians;
    return x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  }
}
