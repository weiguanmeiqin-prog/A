import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const InfoFilterApp());
}

class InfoFilterApp extends StatelessWidget {
  const InfoFilterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INFO FILTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFA8F8F9), // 心を落ち着かせる淡い背景
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF2C3E50)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// ホーム画面
// -----------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('INFO FILTER'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.filter_alt_outlined, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                '情報を取り入れる前に、\n一度立ち止まってみましょう。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('情報フィルターをはじめる', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FilterInputScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.psychology),
                label: const Text('認知テスト単体（動作確認）', style: TextStyle(fontSize: 16)),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MemoryTestScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 情報入力画面（質問1・2 & 優先度）
// -----------------------------------------------------------------------------
class FilterInputScreen extends StatefulWidget {
  const FilterInputScreen({super.key});

  @override
  State<FilterInputScreen> createState() => _FilterInputScreenState();
}

class _FilterInputScreenState extends State<FilterInputScreen> {
  final TextEditingController _targetController = TextEditingController();
  String _selectedReason = '必要な情報を調べるため';
  String _selectedPriority = '🟡 低';

  final List<String> _reasons = [
    '必要な情報を調べるため',
    '誰かから連絡が来た',
    '勉強・仕事のため',
    '趣味',
    '暇つぶし',
    'なんとなく',
    'その他'
  ];

  final Map<String, String> _priorities = {
    '🔴 最優先': '今すぐ確認する必要がある。',
    '🟠 高': '近いうちに確認したい。',
    '🟡 低': '後でも問題ない。',
    '⚪ 特に必要ではない': 'なんとなく見たい。',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('目的と優先度の確認')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Q1. 何を見ようとしていますか？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _targetController,
              decoration: const InputDecoration(
                hintText: '例：猫の動画を見る、〇〇について調べる',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text('Q2. なぜ見ようとしていますか？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _selectedReason = val!),
              decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text('Q3. この情報の優先度は？', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Column(
              children: _priorities.keys.map((p) {
                return RadioListTile<String>(
                  title: Text(p),
                  subtitle: Text(_priorities[p]!),
                  value: p,
                  groupValue: _selectedPriority,
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('確認画面へ'),
                onPressed: () {
                  if (_targetController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('見ようとしている内容を入力してください')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DecisionScreen(
                        target: _targetController.text,
                        reason: _selectedReason,
                        priority: _selectedPriority,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 自己判断画面（見る / あとで見る / 30秒タイマー）
// -----------------------------------------------------------------------------
class DecisionScreen extends StatefulWidget {
  final String target;
  final String reason;
  final String priority;

  const DecisionScreen({
    super.key,
    required this.target,
    required this.reason,
    required this.priority,
  });

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  int _secondsLeft = 30;
  Timer? _timer;
  bool _isWaitingMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.priority == '⚪ 特に必要ではない') {
      _isWaitingMode = true;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
        setState(() => _isWaitingMode = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('自己判断')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isWaitingMode ? _buildWaitingUI() : _buildDecisionUI(),
      ),
    );
  }

  Widget _buildWaitingUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('ちょっとだけ待ってみよう。', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 32),
        Text('$_secondsLeft', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 32),
        Text('本当に「${widget.target}」を見る必要があるか、立ち止まっています。', textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildDecisionUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('あなたは今、「${widget.target}」を開こうとしています。', style: const TextStyle(fontSize: 16)),
                const Divider(height: 24),
                Text('理由：${widget.reason}'),
                const SizedBox(height: 8),
                Text('優先度：${widget.priority}'),
              ],
            ),
          ),
        ),
        const Spacer(),
        const Text(
          '本当に今見る必要がありますか？',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () {
            // 記憶テスト・反応速度テストへ移行（BEFORE測定）
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MemoryTestScreen()),
            );
          },
          child: const Text('見る（テストを実施）'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('選択ログ'),
                content: const Text('今回はここまで。\nあなた自身で選択しました。\n記録：情報を取り入れなかった'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text('OK'),
                  )
                ],
              ),
            );
          },
          child: const Text('あとで見る / もういい'),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 記憶力チェック（NORMAL: 8語）
// -----------------------------------------------------------------------------
class MemoryTestScreen extends StatefulWidget {
  const MemoryTestScreen({super.key});

  @override
  State<MemoryTestScreen> createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  final List<String> _pool = ['りんご', '時計', '海', '電車', '鉛筆', '猫', '山', '本', '太陽', '花', '川', '空', '星', '鍵', '犬', '月'];
  List<String> _targetWords = [];
  List<String> _choices = [];
  final List<String> _selectedWords = [];
  bool _isMemorizing = true;
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _setupTest();
  }

  void _setupTest() {
    _pool.shuffle();
    _targetWords = _pool.take(8).toList(); // 8個抽出
    _choices = List.from(_pool.take(12))..shuffle(); // ダミー含む12選択肢

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        setState(() => _isMemorizing = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('記憶力チェック')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isMemorizing ? _buildMemorizePhase() : _buildAnswerPhase(),
      ),
    );
  }

  Widget _buildMemorizePhase() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('単語を覚えてください ($_countdown秒)', style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _targetWords
              .map((w) => Chip(
                    label: Text(w, style: const TextStyle(fontSize: 18)),
                    padding: const EdgeInsets.all(12),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildAnswerPhase() {
    return Column(
      children: [
        const Text('先ほど表示された単語を選んでください', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _choices.length,
            itemBuilder: (context, index) {
              final word = _choices[index];
              final isSelected = _selectedWords.contains(word);
              return FilterChip(
                label: Text(word),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedWords.add(word);
                    } else {
                      _selectedWords.remove(word);
                    }
                  });
                },
              );
            },
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          onPressed: () {
            int correct = _selectedWords.where((w) => _targetWords.contains(w)).length;
            double score = (correct / _targetWords.length) * 100;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ReactionTestScreen(memoryScore: score)),
            );
          },
          child: const Text('次へ（反応速度テスト）'),
        )
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 反応速度チェック（5回平均計測）
// -----------------------------------------------------------------------------
class ReactionTestScreen extends StatefulWidget {
  final double memoryScore;
  const ReactionTestScreen({super.key, required this.memoryScore});

  @override
  State<ReactionTestScreen> createState() => _ReactionTestScreenState();
}

enum ReactionState { ready, waiting, canTap, result }

class _ReactionTestScreenState extends State<ReactionTestScreen> {
  ReactionState _state = ReactionState.ready;
  final List<int> _times = [];
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _randomTimer;
  String _message = '準備ができたらタップしてください';

  void _startAttempt() {
    setState(() {
      _state = ReactionState.waiting;
      _message = '画面が変わるまで待ってください...';
    });

    final randomDelay = Random().nextInt(2000) + 1500; // 1.5s - 3.5s
    _randomTimer = Timer(Duration(milliseconds: randomDelay), () {
      if (mounted) {
        setState(() {
          _state = ReactionState.canTap;
          _message = 'TAP!';
        });
        _stopwatch.reset();
        _stopwatch.start();
      }
    });
  }

  void _handleTap() {
    if (_state == ReactionState.ready) {
      _startAttempt();
    } else if (_state == ReactionState.waiting) {
      _randomTimer?.cancel();
      setState(() {
        _state = ReactionState.ready;
        _message = 'フライング！\nもう一度タップしてやり直してください。';
      });
    } else if (_state == ReactionState.canTap) {
      _stopwatch.stop();
      int elapsed = _stopwatch.elapsedMilliseconds;
      _times.add(elapsed);

      if (_times.length < 5) {
        setState(() {
          _state = ReactionState.ready;
          _message = '$elapsed ms!\n（${_times.length}/5回完了）タップして次へ';
        });
      } else {
        setState(() {
          _state = ReactionState.result;
        });
      }
    }
  }

  @override
  void dispose() {
    _randomTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double avgReaction = _times.isEmpty ? 0 : _times.reduce((a, b) => a + b) / _times.length;

    return Scaffold(
      appBar: AppBar(title: const Text('反応速度チェック')),
      body: _state == ReactionState.result
          ? _buildResultUI(avgReaction)
          : GestureDetector(
              onTap: _handleTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: _state == ReactionState.canTap ? Colors.green.shade300 : Colors.teal.shade50,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _state == ReactionState.canTap ? 48 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black80,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildResultUI(double avgReaction) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('今回の測定結果', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text('記憶力正答率: ${widget.memoryScore.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  Text('平均反応速度: ${avgReaction.toStringAsFixed(1)} ms', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('ホームに戻る'),
          )
        ],
      ),
    );
  }
}
