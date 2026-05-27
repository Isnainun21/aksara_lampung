import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const KagangaKidsApp());
}

const _cream = Color(0xFFFFF7E8);
const _ink = Color(0xFF21312A);
const _leaf = Color(0xFF2F8F6B);
const _sun = Color(0xFFFFC857);
const _coral = Color(0xFFE85D45);
const _sky = Color(0xFF3D8DFF);
const _pageMaxWidth = 760.0;
const _desktopMaxWidth = 980.0;

int _gridColumns(
  double width, {
  int compact = 1,
  int medium = 2,
  int wide = 3,
}) {
  if (width >= 840) return wide;
  if (width >= 520) return medium;
  return compact;
}

double _homeTileAspect(double width) {
  if (width < 360) return 1.08;
  if (width < 520) return 1.18;
  return 1.28;
}

double _responsiveTitleSize(double width) => width < 360 ? 24 : 28;

class KagangaKidsApp extends StatelessWidget {
  const KagangaKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaganga',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _leaf,
          primary: _leaf,
          secondary: _sun,
          surface: _cream,
        ),
        scaffoldBackgroundColor: _cream,
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class AppState extends ChangeNotifier {
  int songPoint = 0;
  int writeCount = 0;
  int writeStars = 0;
  int quizBest = 0;
  int languageStars = 0;
  int markScore = 0;

  void addSong([int amount = 1]) {
    songPoint += amount;
    notifyListeners();
  }

  void addWrite(int stars) {
    writeCount += 1;
    writeStars += stars;
    notifyListeners();
  }

  void saveQuiz(int score) {
    quizBest = max(quizBest, score);
    notifyListeners();
  }

  void addLanguage([int amount = 1]) {
    languageStars += amount;
    notifyListeners();
  }

  void addMarkScore(int amount) {
    markScore += amount;
    notifyListeners();
  }
}

final appState = AppState();

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), _openHome);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_menu_aksara.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Panel(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo(size: 78),
                    const SizedBox(height: 10),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Kaganga',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Belajar Aksara Lampung',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: _ink),
                    ),
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _openHome,
                      child: const Text('Mulai'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AudioPlayer _backsound = AudioPlayer(playerId: 'menu_backsound');
  bool _musicEnabled = true;
  bool _playerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareBacksound();
  }

  Future<void> _prepareBacksound() async {
    try {
      await _backsound.setReleaseMode(ReleaseMode.loop);
      await _backsound.setVolume(.45);
      await _backsound.play(AssetSource('audio/back_sound_menu.mp3'));
      if (mounted) setState(() => _playerReady = true);
    } catch (_) {
      if (mounted) setState(() => _musicEnabled = false);
    }
  }

  Future<void> _toggleMusic() async {
    setState(() => _musicEnabled = !_musicEnabled);
    if (_musicEnabled) {
      if (_playerReady) {
        await _backsound.resume();
      } else {
        await _prepareBacksound();
      }
    } else {
      await _backsound.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_playerReady) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _backsound.pause();
    } else if (state == AppLifecycleState.resumed && _musicEnabled) {
      _backsound.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backsound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_menu_aksara.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720 ? 3 : 2;
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _desktopMaxWidth,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Row(
                              children: [
                                const AppLogo(size: 44),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kaganga',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: _responsiveTitleSize(
                                            constraints.maxWidth,
                                          ),
                                          fontWeight: FontWeight.w900,
                                          color: _ink,
                                        ),
                                      ),
                                      const Text(
                                        'Belajar Aksara Lampung',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF51645A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton.filledTonal(
                                  onPressed: _toggleMusic,
                                  tooltip:
                                      _musicEnabled
                                          ? 'Matikan musik'
                                          : 'Nyalakan musik',
                                  icon: Icon(
                                    _musicEnabled
                                        ? Icons.volume_up
                                        : Icons.volume_off,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  onPressed:
                                      () => showDialog<void>(
                                        context: context,
                                        builder: (_) => const SettingsDialog(),
                                      ),
                                  icon: const Icon(Icons.settings),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ScoreChip(
                                    label: 'Nyani',
                                    value: appState.songPoint,
                                  ),
                                  ScoreChip(
                                    label: 'Nulis',
                                    value: appState.writeCount,
                                  ),
                                  ScoreChip(
                                    label: 'Kuis',
                                    value: appState.quizBest,
                                  ),
                                  ScoreChip(
                                    label: 'Bahasa',
                                    value: appState.languageStars,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: GridView.count(
                              padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                              crossAxisCount: columns,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: _homeTileAspect(
                                constraints.maxWidth,
                              ),
                              children: const [
                                HomeTile(
                                  'Lagu Aksara',
                                  Icons.music_note,
                                  _coral,
                                  SongPage(),
                                ),
                                HomeTile(
                                  'Menulis Aksara',
                                  Icons.edit,
                                  _leaf,
                                  WritePage(),
                                ),
                                HomeTile(
                                  'Kuis Aksara',
                                  Icons.sports_esports,
                                  _sky,
                                  QuizPage(),
                                ),
                                HomeTile(
                                  'Tanda Baca',
                                  Icons.menu_book,
                                  Color(0xFF7D5FFF),
                                  MarksPage(),
                                ),
                                HomeTile(
                                  'Bahasa Lampung',
                                  Icons.record_voice_over,
                                  Color(0xFFF28C28),
                                  LanguagePage(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class HomeTile extends StatelessWidget {
  const HomeTile(this.title, this.icon, this.color, this.page, {super.key});

  final String title;
  final IconData icon;
  final Color color;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconBox = constraints.maxWidth < 150 ? 48.0 : 58.0;
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          elevation: 5,
          shadowColor: Colors.black.withValues(alpha: .16),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap:
                () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: (_) => page)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: iconBox * .54, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    required this.children,
    this.compactColumns = 1,
    this.mediumColumns = 2,
    this.wideColumns = 2,
    this.childAspectRatio = 2.5,
    super.key,
  });

  final List<Widget> children;
  final int compactColumns;
  final int mediumColumns;
  final int wideColumns;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _gridColumns(
          constraints.maxWidth,
          compact: compactColumns,
          medium: mediumColumns,
          wide: wideColumns,
        );
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

class ResponsiveListTile extends StatelessWidget {
  const ResponsiveListTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330 && trailing != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          subtitle!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: trailing),
            ],
          );
        }
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: leading,
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        );
      },
    );
  }
}

class PageContent extends StatelessWidget {
  const PageContent({
    required this.child,
    this.maxWidth = _pageMaxWidth,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 48, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _leaf,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: size * .06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .16),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.auto_stories, color: _sun, size: size * .52),
          Positioned(
            right: size * .14,
            bottom: size * .12,
            child: Icon(Icons.edit, color: Colors.white, size: size * .28),
          ),
        ],
      ),
    );
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pengaturan'),
      content: const Text(
        'Versi Flutter native awal. Musik, rating, chat, dan fitur online bisa ditambahkan berikutnya.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Tutup'),
        ),
      ],
    );
  }
}

class PageShell extends StatelessWidget {
  const PageShell({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.child,
    this.scrollPhysics,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Widget child;
  final ScrollPhysics? scrollPhysics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_mobile.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                physics: scrollPhysics,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                children: [
                  PageContent(
                    child: Panel(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back),
                            tooltip: 'Mulang',
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: Colors.white, size: 27),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  eyebrow.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: _leaf,
                                  ),
                                ),
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: _responsiveTitleSize(
                                      constraints.maxWidth,
                                    ),
                                    fontWeight: FontWeight.w900,
                                    color: _ink,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF51645A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  PageContent(child: child),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class FeatureIcon extends StatelessWidget {
  const FeatureIcon(this.icon, this.color, {super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class SongPage extends StatefulWidget {
  const SongPage({super.key});

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  final lines = const [
    ('Ka', 'Kaga ngedengi, anak rajin mulang'),
    ('Ga', 'Gaga nyani, hati senang terang'),
    ('Nga', 'Nga ni bunyi, diingat pelan-pelan'),
    ('Pa', 'Pa ba ma, tangan ikut tepuk'),
    ('Ba', 'Ba ma ta, suwara jadi bagus'),
    ('Ma', 'Ma ta da na, ulangi jama-sama'),
    ('Ca', 'Ca ja nya ya, aksara jadi kawan'),
    ('Ja', 'Ja nya ya, mulang jama kawan'),
    ('Ta', 'Ta da na, baca lagi perlahan'),
    ('Sa', 'La ra sa wa ha, tammat nyani hari ini'),
  ];
  int active = 0;
  int claps = 0;
  Timer? timer;
  Duration speed = const Duration(milliseconds: 2200);

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void nextLine() {
    setState(() => active = (active + 1) % lines.length);
    appState.addSong();
  }

  void togglePlay() {
    if (timer != null) {
      timer?.cancel();
      setState(() => timer = null);
      return;
    }
    setState(() => timer = Timer.periodic(speed, (_) => nextLine()));
  }

  @override
  Widget build(BuildContext context) {
    return PageShell(
      eyebrow: 'Belajar jama nyani',
      title: 'Nyanyian Aksara Lampung',
      subtitle: 'Ikuti baris lagu dan kumpulkan poin nyani.',
      icon: Icons.music_note,
      accent: _coral,
      child: Column(
        children: [
          Panel(
            child: Column(
              children: [
                Text(
                  lines[active].$1,
                  style: const TextStyle(
                    fontSize: 86,
                    fontWeight: FontWeight.w900,
                    color: _coral,
                  ),
                ),
                Text(
                  lines[active].$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: togglePlay,
                      icon: Icon(
                        timer == null ? Icons.play_arrow : Icons.pause,
                      ),
                      label: Text(timer == null ? 'Mulai Nyani' : 'Jeda Nyani'),
                    ),
                    OutlinedButton.icon(
                      onPressed: nextLine,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Teras'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => claps += 1);
                        appState.addSong(2);
                      },
                      icon: const Icon(Icons.front_hand),
                      label: const Text('Tepuk'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ScoreChip(label: 'Poin', value: appState.songPoint),
                    ScoreChip(label: 'Tepuk', value: claps),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                SpeedChip(
                  'Alon',
                  active: speed.inMilliseconds == 2200,
                  onTap:
                      () => setState(
                        () => speed = const Duration(milliseconds: 2200),
                      ),
                ),
                SpeedChip(
                  'Sedeng',
                  active: speed.inMilliseconds == 1600,
                  onTap:
                      () => setState(
                        () => speed = const Duration(milliseconds: 1600),
                      ),
                ),
                SpeedChip(
                  'Cepet',
                  active: speed.inMilliseconds == 1050,
                  onTap:
                      () => setState(
                        () => speed = const Duration(milliseconds: 1050),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: List.generate(
                lines.length,
                (i) => ListTile(
                  dense: true,
                  selected: i == active,
                  selectedTileColor: _sun.withValues(alpha: .26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: i == active ? _leaf : _cream,
                    child: Text(
                      lines[i].$1,
                      style: TextStyle(
                        color: i == active ? Colors.white : _ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  title: Text(
                    lines[i].$2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  onTap: () => setState(() => active = i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WritePage extends StatefulWidget {
  const WritePage({super.key});

  @override
  State<WritePage> createState() => _WritePageState();
}

class _WritePageState extends State<WritePage> {
  final letters = aksaraLetters;
  final paths = <Offset?>[];
  final canvasKey = GlobalKey();
  int index = 0;
  Color penColor = _coral;
  double penSize = 9;
  bool showGuide = true;
  bool isDrawing = false;

  void clear() => setState(paths.clear);

  Offset? _localPoint(PointerEvent event) {
    final box = canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final point = box.globalToLocal(event.position);
    return Offset(
      point.dx.clamp(0, box.size.width).toDouble(),
      point.dy.clamp(0, box.size.height).toDouble(),
    );
  }

  void _startStroke(PointerDownEvent event) {
    final point = _localPoint(event);
    if (point == null) return;
    setState(() {
      isDrawing = true;
      paths
        ..add(null)
        ..add(point);
    });
  }

  void _extendStroke(PointerMoveEvent event) {
    if (!isDrawing) return;
    final point = _localPoint(event);
    if (point == null) return;
    setState(() => paths.add(point));
  }

  void _endStroke(PointerEvent event) {
    if (!isDrawing) return;
    setState(() {
      isDrawing = false;
      paths.add(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = letters[index];
    return PageShell(
      eyebrow: 'Latihan tangan',
      title: 'Nulis Aksara Lampung',
      subtitle: 'Tiru bentuk, tarik garis, ulangi sampai lancar.',
      icon: Icons.edit,
      accent: _leaf,
      scrollPhysics:
          isDrawing
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
      child: Column(
        children: [
          Panel(
            child: Column(
              children: [
                Text(
                  item.symbol,
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: _leaf,
                  ),
                ),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                InfoLine(item.hint),
                InfoLine(item.move),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed:
                          () => setState(() {
                            index =
                                (index - 1 + letters.length) % letters.length;
                            paths.clear();
                          }),
                      child: const Text('Balik'),
                    ),
                    FilledButton(
                      onPressed:
                          () => setState(() {
                            index = (index + 1) % letters.length;
                            paths.clear();
                          }),
                      child: const Text('Teras'),
                    ),
                    OutlinedButton(
                      onPressed: () => setState(() => showGuide = !showGuide),
                      child: Text(showGuide ? 'Tutup Contoh' : 'Tampil Contoh'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final aspectRatio = constraints.maxWidth < 380 ? 1.0 : 1.22;
              return AspectRatio(
                aspectRatio: aspectRatio,
                child: Listener(
                  key: canvasKey,
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: _startStroke,
                  onPointerMove: _extendStroke,
                  onPointerUp: _endStroke,
                  onPointerCancel: _endStroke,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(
                        painter: WritingPainter(
                          points: paths,
                          color: penColor,
                          size: penSize,
                          guide: showGuide ? item.symbol : '',
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border.all(color: _leaf, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              ColorDot(
                _coral,
                penColor == _coral,
                () => setState(() => penColor = _coral),
              ),
              ColorDot(
                _leaf,
                penColor == _leaf,
                () => setState(() => penColor = _leaf),
              ),
              ColorDot(
                _sky,
                penColor == _sky,
                () => setState(() => penColor = _sky),
              ),
              ColorDot(
                const Color(0xFF7D5FFF),
                penColor == const Color(0xFF7D5FFF),
                () => setState(() => penColor = const Color(0xFF7D5FFF)),
              ),
              OutlinedButton(onPressed: clear, child: const Text('Apus')),
              OutlinedButton(
                onPressed: () => setState(() => penSize = 6),
                child: const Text('Alus'),
              ),
              OutlinedButton(
                onPressed: () => setState(() => penSize = 14),
                child: const Text('Tebal'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () => appState.addWrite(1),
                child: const Text('Aku Nyoba'),
              ),
              FilledButton.tonal(
                onPressed: () => appState.addWrite(2),
                child: const Text('Aku Bisa'),
              ),
              FilledButton.tonal(
                onPressed: () => appState.addWrite(3),
                child: const Text('Aku Lancar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: appState,
            builder:
                (_, __) => Wrap(
                  spacing: 8,
                  children: [
                    ScoreChip(label: 'Latihan', value: appState.writeCount),
                    ScoreChip(label: 'Bintang', value: appState.writeStars),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}

class WritingPainter extends CustomPainter {
  WritingPainter({
    required this.points,
    required this.color,
    required this.size,
    required this.guide,
  });

  final List<Offset?> points;
  final Color color;
  final double size;
  final String guide;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & canvasSize,
        const Radius.circular(8),
      ),
      bg,
    );
    if (guide.isNotEmpty) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: guide,
          style: TextStyle(
            fontSize: canvasSize.height * .42,
            fontWeight: FontWeight.w900,
            color: _leaf.withValues(alpha: .16),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: canvasSize.width);
      textPainter.paint(
        canvas,
        Offset(
          (canvasSize.width - textPainter.width) / 2,
          (canvasSize.height - textPainter.height) / 2,
        ),
      );
    }
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = size
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..isAntiAlias = true;
    for (var i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      if (current != null && next != null) {
        canvas.drawLine(current, next, paint);
      } else if (current != null && next == null) {
        canvas.drawCircle(current, size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant WritingPainter oldDelegate) => true;
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int current = 0;
  int score = 0;
  int combo = 0;
  String mode = 'bunyi';
  bool answered = false;
  String feedback = 'Aksara hinji dibaca api?';

  List<String> optionsFor(String answer) {
    final options =
        aksaraLetters.map((e) => e.symbol).where((e) => e != answer).toList()
          ..shuffle();
    return (options.take(3).toList()..add(answer))..shuffle();
  }

  void answer(String option) {
    if (answered) return;
    final correct = option == aksaraLetters[current].symbol;
    setState(() {
      answered = true;
      if (correct) {
        combo += 1;
        score += 10 + combo;
        feedback = 'Iya, jawabanmu bener!';
      } else {
        combo = 0;
        feedback = 'Belum pas. Jawaban: ${aksaraLetters[current].symbol}';
      }
      appState.saveQuiz(score);
    });
  }

  void next() {
    setState(() {
      current = (current + 1) % aksaraLetters.length;
      answered = false;
      feedback =
          mode == 'aksara'
              ? 'Pilih aksara sai cocok jama bunyi hinji.'
              : 'Aksara hinji dibaca api?';
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = aksaraLetters[current];
    final choices = optionsFor(item.symbol);
    return PageShell(
      eyebrow: 'Main sambil mulang',
      title: 'Kuis Aksara Lampung',
      subtitle: 'Pilih jawaban sai pas, kumpul bintang belajar.',
      icon: Icons.sports_esports,
      accent: _sky,
      child: Panel(
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: [
                SpeedChip(
                  'Tebak Bunyi',
                  active: mode == 'bunyi',
                  onTap: () => setState(() => mode = 'bunyi'),
                ),
                SpeedChip(
                  'Tebak Aksara',
                  active: mode == 'aksara',
                  onTap: () => setState(() => mode = 'aksara'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Soal ${current + 1}/${aksaraLetters.length}'),
                Text('Skor $score'),
              ],
            ),
            Text(
              mode == 'aksara' ? item.name : item.symbol,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: _sky,
              ),
            ),
            Text(
              feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            ...choices.map((choice) {
              final label = mode == 'aksara' ? 'Aksara $choice' : choice;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: () => answer(choice),
                    child: Text(label),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ScoreChip(label: 'Terbaik', value: appState.quizBest),
                ScoreChip(label: 'Runtun', value: combo),
                FilledButton(onPressed: next, child: const Text('Teras')),
                OutlinedButton(
                  onPressed:
                      () => setState(() {
                        current = 0;
                        score = 0;
                        combo = 0;
                        answered = false;
                      }),
                  child: const Text('Ulangi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  int current = 0;
  String feedback = 'Tanda hinji gunana api?';

  @override
  Widget build(BuildContext context) {
    final mark = marks[current];
    final choices =
        marks.map((e) => e.use).where((e) => e != mark.use).toList()..shuffle();
    final options =
        choices.take(3).toList()
          ..add(mark.use)
          ..shuffle();
    return PageShell(
      eyebrow: 'Ngerti tanda',
      title: 'Tanda Baca Aksara Lampung',
      subtitle: 'Pahami tanda, bunyi aksara jadi lebih terang.',
      icon: Icons.menu_book,
      accent: const Color(0xFF7D5FFF),
      child: Column(
        children: [
          ResponsiveGrid(
            childAspectRatio: 2.45,
            children:
                marks
                    .map(
                      (item) => Panel(
                        child: ResponsiveListTile(
                          leading: CircleAvatar(child: Text(item.symbol[0])),
                          title: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            '${item.use}\n${item.example}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Latihan cilik'),
                    Text('Skor ${appState.markScore}'),
                  ],
                ),
                Text(
                  mark.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width < 360 ? 30 : 38,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF7D5FFF),
                  ),
                ),
                Text(feedback, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                ...options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () {
                          final ok = option == mark.use;
                          if (ok) appState.addMarkScore(5);
                          setState(() {
                            feedback =
                                ok
                                    ? 'Bener, kamu makin paham.'
                                    : 'Belum pas. Jawaban: ${mark.use}';
                            current = (current + 1) % marks.length;
                          });
                        },
                        child: Text(option),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String category = 'tubuh';
  int numberIndex = 0;
  int colorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final words = vocab[category]!;
    final number = numbers[numberIndex];
    final color = colors[colorIndex];
    return PageShell(
      eyebrow: 'Mulang bahasa',
      title: 'Bahasa Lampung',
      subtitle: 'Kosakata, angka, warna, percakapan, jama latihan.',
      icon: Icons.record_voice_over,
      accent: const Color(0xFFF28C28),
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                vocab.keys
                    .map(
                      (key) => SpeedChip(
                        key,
                        active: category == key,
                        onTap: () => setState(() => category = key),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          ResponsiveGrid(
            childAspectRatio: 2.65,
            children:
                words.map((word) {
                  return Panel(
                    child: ResponsiveListTile(
                      leading: CircleAvatar(
                        backgroundColor: _sun,
                        child: Text(word.icon),
                      ),
                      title: Text(
                        word.lampung,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        word.meaning,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: FilledButton.tonalIcon(
                        onPressed: () => appState.addLanguage(),
                        icon: const Icon(Icons.check),
                        label: const Text('Bisa'),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              children: [
                const Text(
                  'Angka',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  number.$1,
                  style: const TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.w900,
                    color: _leaf,
                  ),
                ),
                Text(
                  number.$2,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed:
                          () => setState(
                            () =>
                                numberIndex =
                                    (numberIndex - 1 + numbers.length) %
                                    numbers.length,
                          ),
                      child: const Text('Balik'),
                    ),
                    FilledButton(
                      onPressed:
                          () => setState(
                            () =>
                                numberIndex =
                                    (numberIndex + 1) % numbers.length,
                          ),
                      child: const Text('Teras'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              children: [
                const Text(
                  'Warna',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Container(
                  height: 86,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.$1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ink.withValues(alpha: .1)),
                  ),
                  child: Text(
                    color.$3,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color.$1 == Colors.white ? _ink : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  color.$2,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                FilledButton.tonal(
                  onPressed:
                      () => setState(
                        () => colorIndex = (colorIndex + 1) % colors.length,
                      ),
                  child: const Text('Warna Lain'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Percakapan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                ChatBubble('A', 'Tabik pun.'),
                ChatBubble('B', 'Tabik. Api kabar?', right: true),
                ChatBubble('A', 'Kabar baik.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  const Panel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ink.withValues(alpha: .08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ScoreChip extends StatelessWidget {
  const ScoreChip({required this.label, required this.value, super.key});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _ink.withValues(alpha: .06)),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontWeight: FontWeight.w800, color: _ink),
      ),
    );
  }
}

class SpeedChip extends StatelessWidget {
  const SpeedChip(
    this.label, {
    required this.active,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
    );
  }
}

class ColorDot extends StatelessWidget {
  const ColorDot(this.color, this.active, this.onTap, {super.key});

  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            width: active ? 4 : 1,
            color: active ? _ink : Colors.white,
          ),
        ),
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _cream,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble(this.name, this.text, {this.right = false, super.key});

  final String name;
  final String text;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: right ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: right ? _leaf : _cream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$name: $text',
          style: TextStyle(
            color: right ? Colors.white : _ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class LetterData {
  const LetterData(this.symbol, this.name, this.hint, this.move);

  final String symbol;
  final String name;
  final String hint;
  final String move;
}

const aksaraLetters = [
  LetterData(
    'Ka',
    'Aksara Ka',
    'Titik awal: pucuk kiri.',
    'Gerak tangan: turun, lengkung, lalu tutup rapi.',
  ),
  LetterData(
    'Ga',
    'Aksara Ga',
    'Titik awal: bagian atas.',
    'Gerak tangan: garis besar dulu, tambah ekor kecil.',
  ),
  LetterData(
    'Nga',
    'Aksara Nga',
    'Titik awal: tengah atas.',
    'Gerak tangan: buat badan lebar, sambung pelan.',
  ),
  LetterData(
    'Pa',
    'Aksara Pa',
    'Titik awal: kiri bawah.',
    'Gerak tangan: naik lalu putar sedikit.',
  ),
  LetterData(
    'Ba',
    'Aksara Ba',
    'Titik awal: kiri atas.',
    'Gerak tangan: bentuk badan, tambah garis penanda.',
  ),
  LetterData(
    'Ma',
    'Aksara Ma',
    'Titik awal: atas.',
    'Gerak tangan: tarik turun, lengkungkan ujung.',
  ),
  LetterData(
    'Ta',
    'Aksara Ta',
    'Titik awal: kiri.',
    'Gerak tangan: garis pendek lalu sambung ke kanan.',
  ),
  LetterData(
    'Da',
    'Aksara Da',
    'Titik awal: atas kanan.',
    'Gerak tangan: ikuti contoh sampai garis bertemu.',
  ),
  LetterData(
    'Na',
    'Aksara Na',
    'Titik awal: tengah.',
    'Gerak tangan: buat lengkung kecil lalu panjangkan.',
  ),
  LetterData(
    'Ca',
    'Aksara Ca',
    'Titik awal: kiri atas.',
    'Gerak tangan: bentuk pendek dan jaga jarak.',
  ),
  LetterData(
    'Ja',
    'Aksara Ja',
    'Titik awal: kanan atas.',
    'Gerak tangan: turun pelan lalu beri ekor.',
  ),
  LetterData(
    'Nya',
    'Aksara Nya',
    'Titik awal: atas.',
    'Gerak tangan: buat badan besar, tutup rapi.',
  ),
  LetterData(
    'Ya',
    'Aksara Ya',
    'Titik awal: kiri.',
    'Gerak tangan: sambung halus ke kanan.',
  ),
  LetterData(
    'La',
    'Aksara La',
    'Titik awal: bawah.',
    'Gerak tangan: naik lalu lengkung.',
  ),
  LetterData(
    'Ra',
    'Aksara Ra',
    'Titik awal: atas.',
    'Gerak tangan: garis utama dulu, tambah tanda.',
  ),
  LetterData(
    'Sa',
    'Aksara Sa',
    'Titik awal: kiri atas.',
    'Gerak tangan: ikuti lekuk dengan sabar.',
  ),
  LetterData(
    'Wa',
    'Aksara Wa',
    'Titik awal: tengah kiri.',
    'Gerak tangan: buat putaran kecil.',
  ),
  LetterData(
    'Ha',
    'Aksara Ha',
    'Titik awal: atas kanan.',
    'Gerak tangan: tutup bentuk sampai rapi.',
  ),
];

class MarkData {
  const MarkData(this.symbol, this.name, this.use, this.example);

  final String symbol;
  final String name;
  final String use;
  final String example;
}

const marks = [
  MarkData('Ulan', 'Tanda Ulan', 'Nambah bunyi i.', 'Ka + ulan dibaca ki.'),
  MarkData('Bicek', 'Tanda Bicek', 'Nambah bunyi e.', 'Ga + bicek dibaca ge.'),
  MarkData(
    'Tekelubang',
    'Tanda Tekelubang',
    'Nambah bunyi u.',
    'Pa + tekelubang dibaca pu.',
  ),
  MarkData(
    'Rejunjung',
    'Tanda Rejunjung',
    'Nambah bunyi r.',
    'Ba + rejunjung jadi bunyi bar.',
  ),
  MarkData(
    'Datasan',
    'Tanda Datasan',
    'Nambah bunyi n.',
    'Ma + datasan jadi bunyi man.',
  ),
  MarkData(
    'Tekelingai',
    'Tanda Tekelingai',
    'Nambah bunyi ng.',
    'Sa + tekelingai jadi sang.',
  ),
  MarkData(
    'Nengen',
    'Tanda Nengen',
    'Matikeun bunyi vokal.',
    'Aksara jadi bunyi mati.',
  ),
  MarkData(
    'Keleniah',
    'Tanda Keleniah',
    'Membantu baca rangkaian kata.',
    'Dipakai di latihan lanjut.',
  ),
];

class VocabWord {
  const VocabWord(this.icon, this.lampung, this.meaning);

  final String icon;
  final String lampung;
  final String meaning;
}

const vocab = {
  'tubuh': [
    VocabWord('M', 'Mata', 'Mata'),
    VocabWord('C', 'Cuping', 'Telinga'),
    VocabWord('H', 'Hidung', 'Hidung'),
    VocabWord('T', 'Tangan', 'Tangan'),
    VocabWord('S', 'Suku', 'Kaki'),
  ],
  'angka': [
    VocabWord('1', 'Sai', 'Satu'),
    VocabWord('2', 'Rua', 'Dua'),
    VocabWord('3', 'Telu', 'Tiga'),
    VocabWord('4', 'Pak', 'Empat'),
    VocabWord('5', 'Lima', 'Lima'),
  ],
  'warna': [
    VocabWord('R', 'Handak Mira', 'Merah'),
    VocabWord('K', 'Kuning', 'Kuning'),
    VocabWord('H', 'Hijau', 'Hijau'),
    VocabWord('B', 'Biru', 'Biru'),
    VocabWord('A', 'Halom', 'Hitam'),
  ],
  'hewan': [
    VocabWord('K', 'Kucing', 'Kucing'),
    VocabWord('M', 'Manuk', 'Ayam'),
    VocabWord('I', 'Iwa', 'Ikan'),
    VocabWord('S', 'Sapi', 'Sapi'),
    VocabWord('W', 'Wedus', 'Kambing'),
  ],
  'keluarga': [
    VocabWord('B', 'Bapak', 'Ayah'),
    VocabWord('I', 'Induk', 'Ibu'),
    VocabWord('R', 'Anak Ragah', 'Anak laki-laki'),
    VocabWord('B', 'Anak Bebai', 'Anak perempuan'),
    VocabWord('T', 'Tuan', 'Kakek'),
  ],
  'sekolah': [
    VocabWord('B', 'Buku', 'Buku'),
    VocabWord('P', 'Pinsil', 'Pensil'),
    VocabWord('T', 'Tas', 'Tas'),
    VocabWord('S', 'Sekula', 'Sekolah'),
    VocabWord('K', 'Kursi', 'Kursi'),
  ],
};

const numbers = [
  ('1', 'Sai'),
  ('2', 'Rua'),
  ('3', 'Telu'),
  ('4', 'Pak'),
  ('5', 'Lima'),
  ('6', 'Enom'),
  ('7', 'Pitu'),
  ('8', 'Walu'),
  ('9', 'Siwa'),
  ('10', 'Puluh'),
];

const colors = [
  (Color(0xFFE53935), 'Mira', 'Merah'),
  (Color(0xFFFDD835), 'Kuning', 'Kuning'),
  (Color(0xFF43A047), 'Hijau', 'Hijau'),
  (Color(0xFF1E88E5), 'Biru', 'Biru'),
  (Color(0xFF212121), 'Halom', 'Hitam'),
  (Colors.white, 'Putih', 'Putih'),
];
