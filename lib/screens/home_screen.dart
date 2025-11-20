import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/word_bloc.dart';
import '../blocs/history_bloc.dart';
import '../models/word.dart';
import 'word_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(LoadHistoryEvent());
    context.read<WordBloc>().add(LoadRandomWordsEvent());
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
            const Text('Tulish.'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<WordBloc>().add(SearchWordsEvent(value));
              },
              decoration: InputDecoration(
                hintText: 'Search a word...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<WordBloc>().add(ClearSearchEvent());
                          context.read<WordBloc>().add(LoadRandomWordsEvent());
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<WordBloc, WordState>(
              builder: (context, state) {
                if (state is WordLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is WordSearchResults) {
                  return _buildSearchResults(state.words);
                } else if (state is RandomWordsLoaded) {
                  return _buildHomeContent(state.words);
                } else if (state is WordError) {
                  return Center(child: Text(state.message));
                }
                return _buildHomeContent([]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 1) {
            Navigator.of(context).pushNamed('/favorites');
          } else if (index == 2) {
            Navigator.of(context).pushNamed('/settings');
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(List<Word> words) {
    if (words.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    return ListView.builder(
      itemCount: words.length,
      itemBuilder: (context, index) {
        final word = words[index];
        return ListTile(
          title: Text(
            word.word,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            word.definition,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WordDetailScreen(wordId: word.id!),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHomeContent(List<Word> randomWords) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<HistoryBloc, HistoryState>(
            builder: (context, state) {
              if (state is HistoryLoaded && state.history.isNotEmpty) {
                return _buildSection(
                  'Recent Searches',
                  state.history.take(5).map((h) {
                    return ListTile(
                      title: Text(h.wordText),
                      subtitle: Text(_formatTime(h.searchedAt)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final word = await context.read<WordBloc>().dbHelper.getWordByText(h.wordText);
                        if (word != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WordDetailScreen(wordId: word.id!),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),
          if (randomWords.isNotEmpty)
            _buildSection(
              'Word Suggestions',
              randomWords.map((word) {
                return ListTile(
                  title: Text(word.word),
                  subtitle: Text(
                    word.definition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WordDetailScreen(wordId: word.id!),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
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
