import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recording_provider.dart';

/// Widget hiển thị trạng thái thu âm (dùng chung giữa các screen)
class RecordingIndicator extends ConsumerWidget {
  const RecordingIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordingState = ref.watch(recordingProvider);

    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getStatusColor(recordingState).withValues(alpha: 0.1),
              _getStatusColor(recordingState).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Status icon với animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getStatusColor(recordingState).withValues(alpha: 0.2),
              ),
              child: recordingState.isRecording
                  ? _buildPulsingIcon(
                      Icons.mic,
                      _getStatusColor(recordingState),
                    )
                  : Icon(
                      _getStatusIcon(recordingState),
                      color: _getStatusColor(recordingState),
                      size: 32,
                    ),
            ),

            const SizedBox(width: 16),

            // Status text và thông tin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recordingState.statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(recordingState),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(recordingState.duration),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  if (recordingState.filePath != null &&
                      !recordingState.isActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'File: ${recordingState.filePath!.split('/').last}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),

            // Live indicator khi đang recording
            if (recordingState.isRecording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingIcon(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 1000),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(icon, color: color, size: 32),
        );
      },
      onEnd: () {
        // Animation sẽ tự repeat do setState
      },
    );
  }

  IconData _getStatusIcon(recordingState) {
    if (recordingState.isRecording) return Icons.mic;
    if (recordingState.isPaused) return Icons.pause_circle;
    if (recordingState.filePath != null) return Icons.check_circle;
    return Icons.mic_none;
  }

  Color _getStatusColor(recordingState) {
    if (recordingState.isRecording) return Colors.red;
    if (recordingState.isPaused) return Colors.orange;
    if (recordingState.filePath != null) return Colors.green;
    return Colors.grey;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
