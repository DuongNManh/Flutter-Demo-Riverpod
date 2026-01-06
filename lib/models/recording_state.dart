/// Model cho trạng thái thu âm
class RecordingState {
  final bool isRecording;
  final bool isPaused;
  final Duration duration;
  final String? filePath;
  final String? errorMessage;

  const RecordingState({
    this.isRecording = false,
    this.isPaused = false,
    this.duration = Duration.zero,
    this.filePath,
    this.errorMessage,
  });

  RecordingState copyWith({
    bool? isRecording,
    bool? isPaused,
    Duration? duration,
    String? filePath,
    String? errorMessage,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Kiểm tra có đang trong quá trình thu âm không (đang thu hoặc pause)
  bool get isActive => isRecording || isPaused;

  /// Lấy trạng thái hiển thị dưới dạng text
  String get statusText {
    if (isRecording) return 'Đang thu âm...';
    if (isPaused) return 'Tạm dừng';
    if (filePath != null) return 'Đã hoàn thành';
    return 'Chưa bắt đầu';
  }

  @override
  String toString() {
    return 'RecordingState(isRecording: $isRecording, isPaused: $isPaused, duration: $duration, filePath: $filePath)';
  }
}
