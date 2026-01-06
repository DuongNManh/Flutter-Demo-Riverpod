import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recording_provider.dart';
import '../widgets/recording_controls.dart';
import '../widgets/recording_indicator.dart';

class RecordingScreen extends ConsumerStatefulWidget {
  //  demo screen dùng provider và các state nội bộ
  const RecordingScreen({super.key});

  @override
  ConsumerState<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends ConsumerState<RecordingScreen>
    with TickerProviderStateMixin {
  // State nội bộ - ví dụ: animation controller
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;

  // State nội bộ khác - ví dụ: hiển thị tips
  bool _showTips = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation cho pulse effect
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Lắng nghe thay đổi từ provider và thực hiện side effects
    ref.listenManual(recordingProvider, (previous, next) {
      // Bắt đầu animation khi recording
      if (next.isRecording && !(previous?.isRecording ?? false)) {
        _pulseAnimationController.repeat(reverse: true);
      }

      // Dừng animation khi không recording
      if (!next.isRecording && (previous?.isRecording ?? false)) {
        _pulseAnimationController.stop();
        _pulseAnimationController.reset();
      }

      // Hiển thị tips sau 3 giây recording
      if (next.isRecording && next.duration.inSeconds == 3) {
        setState(() {
          _showTips = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingProvider);
    final recordingNotifier = ref.read(recordingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu âm'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (recordingState.isActive)
            IconButton(
              onPressed: () {
                recordingNotifier.reset();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: recordingState.isRecording
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Icon(
                            Icons.mic,
                            size: 80,
                            color: recordingState.isRecording
                                ? Colors.red
                                : recordingState.isPaused
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Màn hình thu âm',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Điều khiển thu âm và theo dõi trạng thái',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Hiển thị trạng thái thu âm (component dùng chung)
            const RecordingIndicator(),

            const SizedBox(height: 24),

            // Tips sau 3 giây recording
            if (_showTips && recordingState.isRecording)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mẹo thu âm:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Giữ khoảng cách 15-20cm với micro để có chất lượng tốt nhất!',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _showTips = false;
                          });
                        },
                        icon: const Icon(Icons.close, size: 16),
                      ),
                    ],
                  ),
                ),
              ),

            // Thời gian thu âm lớn
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      _formatDuration(recordingState.duration),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: recordingState.isRecording
                                ? Colors.red
                                : Theme.of(context).primaryColor,
                          ),
                    ),
                    const SizedBox(height: 8),
                    if (recordingState.isRecording)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'RECORDING',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Controls
            const RecordingControls(),

            const SizedBox(height: 16),

            // Error message
            if (recordingState.errorMessage != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          recordingState.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const Spacer(),

            // Thông tin file đã lưu
            if (recordingState.filePath != null && !recordingState.isActive)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Thu âm hoàn tất!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'File đã lưu: ${recordingState.filePath!.split('/').last}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
