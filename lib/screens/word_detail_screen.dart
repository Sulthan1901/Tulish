import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/word_bloc.dart';
import '../blocs/bookmark_bloc.dart';
import '../models/word.dart';

class WordDetailScreen extends StatefulWidget {
  final int wordId;

  const WordDetailScreen({super.key, required this.wordId});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    context.read<WordBloc>().add(LoadWordDetailsEvent(widget.wordId));
    _checkBookmark();
  }

  Future<void> _checkBookmark() async {
    final isBookmarked = await context.read<BookmarkBloc>().dbHelper.isBookmarked(widget.wordId);
    setState(() {
      _isBookmarked = isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<WordBloc, WordState>(
        builder: (context, state) {
          if (state is WordLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is WordDetailsLoaded) {
            return _buildWordDetails(state.word);
          } else if (state is WordError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Word not found'));
        },
      ),
    );
  }

  Widget _buildWordDetails(Word word) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isBookmarked ? Icons.favorite : Icons.favorite_border,
                      color: _isBookmarked ? const Color(0xFFFFB3D9) : null,
                    ),
                    onPressed: () {
                      if (_isBookmarked) {
                        context.read<BookmarkBloc>().add(RemoveBookmarkEvent(word.id!));
                      } else {
                        context.read<BookmarkBloc>().add(AddBookmarkEvent(word));
                      }
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (word.partOfSpeech != null) ...[
            Text(
              word.partOfSpeech!,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Text(
                '/${word.word}/',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  // TTS functionality would go here
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Definition',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            word.definition,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (word.example != null) ...[
            const SizedBox(height: 24),
            Text(
              'Example Sentences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...word.example!.split('\n').map((example) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                example.trim(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )),
          ],
          if (word.synonymsList.isNotEmpty || word.antonymsList.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (word.synonymsList.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Synonyms',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: word.synonymsList.map((syn) => Chip(
                            label: Text(
                              syn,
                              style: const TextStyle(color: Color(0xFFFFB3D9)),
                            ),
                            backgroundColor: const Color(0xFF2A2A2A),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                if (word.synonymsList.isNotEmpty && word.antonymsList.isNotEmpty)
                  const SizedBox(width: 16),
                if (word.antonymsList.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Antonyms',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: word.antonymsList.map((ant) => Chip(
                            label: Text(
                              ant,
                              style: const TextStyle(color: Color(0xFFFFB3D9)),
                            ),
                            backgroundColor: const Color(0xFF2A2A2A),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (word.etymology != null) ...[
            const SizedBox(height: 24),
            Text(
              'Etymology',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              word.etymology!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
