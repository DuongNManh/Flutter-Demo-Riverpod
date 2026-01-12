import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recording_provider.dart';

/// Màn hình cài đặt - Demo StatelessWidget chuyển thành ConsumerWidget
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đây là điểm khác biệt chính:
    // Thay vì StatelessWidget.build(context), ta có ConsumerWidget.build(context, ref)
    final recordingState = ref.watch(
      recordingProvider,
    ); // Watch provider để rebuild khi cần

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(Icons.settings, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Cài đặt ứng dụng',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tùy chỉnh trải nghiệm thu âm',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Recording Status Card - Reactive với provider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trạng thái thu âm hiện tại:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sử dụng state từ provider để hiển thị dynamic content
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(recordingState).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(recordingState),
                            color: _getStatusColor(recordingState),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            recordingState.statusText,
                            style: TextStyle(
                              color: _getStatusColor(recordingState),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Thời gian: ${_formatDuration(recordingState.duration)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Settings Options
            _buildSettingsSection(context, 'Thu âm', [
              _buildSettingsTile(
                context,
                'Chất lượng âm thanh',
                'High Quality (44.1kHz)',
                Icons.high_quality,
              ),
              _buildSettingsTile(
                context,
                'Định dạng file',
                'M4A (AAC)',
                Icons.audio_file,
              ),
              _buildSettingsTile(context, 'Auto save', 'Bật', Icons.save),
            ]),

            const SizedBox(height: 16),

            _buildSettingsSection(context, 'Giao diện', [
              _buildSettingsTile(context, 'Theme', 'System', Icons.palette),
              _buildSettingsTile(
                context,
                'Ngôn ngữ',
                'Tiếng Việt',
                Icons.language,
              ),
            ]),

            const Spacer(),

            // Quick Actions dựa trên state
            if (recordingState.isActive) ...[
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Đang có phiên thu âm active. Hoàn tất trước khi thay đổi cài đặt.',
                          style: TextStyle(color: Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Có thể reset settings hoặc thực hiện action khác
                    ref.read(recordingProvider.notifier).reset();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cài đặt đã được reset!')),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset toàn bộ cài đặt'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(child: Column(children: children)),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tùy chọn "$title" sẽ được phát triển sau!')),
        );
      },
    );
  }

  // Helper methods để xử lý state từ provider
  Color _getStatusColor(recordingState) {
    if (recordingState.isRecording) return Colors.red;
    if (recordingState.isPaused) return Colors.orange;
    if (recordingState.filePath != null) return Colors.green;
    return Colors.grey;
  }

  IconData _getStatusIcon(recordingState) {
    if (recordingState.isRecording) return Icons.mic;
    if (recordingState.isPaused) return Icons.pause_circle;
    if (recordingState.filePath != null) return Icons.check_circle;
    return Icons.mic_none;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
