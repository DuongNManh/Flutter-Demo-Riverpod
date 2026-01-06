import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recording_provider.dart';

/// Widget điều khiển thu âm (start, pause, resume, stop)
class RecordingControls extends ConsumerWidget {
  const RecordingControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(
      recordingProvider,
    ); // Lấy trạng thái thu âm hiện tại, render lại khi có thay đổi
    final recordingNotifier = ref.read(
      recordingProvider.notifier,
    ); // Lấy notifier để gọi các hàm điều khiển thu âm

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Main control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Start/Resume button
                if (!recordingState.isActive)
                  _buildControlButton(
                    onPressed: () => recordingNotifier.startRecording(),
                    icon: Icons.fiber_manual_record,
                    label: 'Bắt đầu',
                    color: Colors.red,
                  )
                else if (recordingState.isPaused)
                  _buildControlButton(
                    onPressed: () => recordingNotifier.resumeRecording(),
                    icon: Icons.play_arrow,
                    label: 'Tiếp tục',
                    color: Colors.green,
                  ),

                // Pause button
                if (recordingState.isRecording)
                  _buildControlButton(
                    onPressed: () => recordingNotifier.pauseRecording(),
                    icon: Icons.pause,
                    label: 'Tạm dừng',
                    color: Colors.orange,
                  ),

                // Stop button
                if (recordingState.isActive)
                  _buildControlButton(
                    onPressed: () => recordingNotifier.stopRecording(),
                    icon: Icons.stop,
                    label: 'Dừng',
                    color: Colors.grey[700]!,
                  ),
              ],
            ),

            // Reset button (hiển thị khi có file đã thu)
            if (recordingState.filePath != null &&
                !recordingState.isActive) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => recordingNotifier.reset(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thu âm mới'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            elevation: 4,
          ),
          child: Icon(icon, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
