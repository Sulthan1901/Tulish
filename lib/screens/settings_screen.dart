import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
            const Text('Settings'),
          ],
        ),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          String currentTheme = 'dark';
          double fontSize = 16.0;

          if (state is ThemeLoaded) {
            currentTheme = state.themeMode;
            fontSize = state.fontSize;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Display Preferences',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Theme',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Choose your preferred visual theme for the application.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'dark', label: Text('Dark')),
                          ButtonSegment(value: 'light', label: Text('Light')),
                          ButtonSegment(value: 'system', label: Text('System')),
                        ],
                        selected: {currentTheme},
                        onSelectionChanged: (Set<String> selected) {
                          context.read<ThemeBloc>().add(ChangeThemeEvent(selected.first));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Font Size',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Adjust the text size for better readability.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${fontSize.round()} px',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFB3D9),
                        ),
                      ),
                      Slider(
                        value: fontSize,
                        min: 12,
                        max: 24,
                        divisions: 12,
                        label: '${fontSize.round()} px',
                        onChanged: (value) {
                          context.read<ThemeBloc>().add(ChangeFontSizeEvent(value));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Application Information',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('About Tulish'),
                  subtitle: const Text(
                    'Learn more about the app, its mission, and acknowledgments.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('About Tulish'),
                        content: const Text(
                          'Tulish is an offline English dictionary application designed to help students and learners expand their vocabulary.\n\nEvery Word, a Step Forward.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text('App Version'),
                  subtitle: const Text('Current version: 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          } else if (index == 1) {
            Navigator.of(context).pushReplacementNamed('/favorites');
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
