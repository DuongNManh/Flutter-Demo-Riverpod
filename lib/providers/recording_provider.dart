import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/recording_state.dart';

/// Provider cho RecordingNotifier
final recordingProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
      return RecordingNotifier();
    });

/// Notifier quản lý logic thu âm
class RecordingNotifier extends StateNotifier<RecordingState> {
  /**  state notifier là gì?
  - StateNotifier là một lớp trong Riverpod của Flutter, dùng để quản lý trạng thái (state) trong app có tổ chức và hiệu quả.
  - Nó cho phép bạn tạo các object state có thể thay đổi và Notify cho các widget hoặc các component của ứng dụng khi state có sự thay đổi
  - Khi bạn sử dụng StateNotifier, bạn define một class con của nó và quản lý trạng thái bên trong class đó. */

  /**  ở define trên RecordingState là gì?
  - RecordingState là một lớp dữ liệu (data class) trong ứng dụng Flutter, được sử dụng để đại diện cho trạng thái của quá trình thu âm.
  - Lớp này chứa các thuộc tính như isRecording (đang thu âm hay không), isPaused (đã tạm dừng hay chưa), duration (thời lượng thu âm), filePath (đường dẫn tệp thu âm) và errorMessage (thông báo lỗi nếu có).
  -  Nó giúp quản lý và theo dõi trạng thái của quá trình thu âm trong ứng dụng một cách rõ ràng và có tổ chức. */

  RecordingNotifier() : super(const RecordingState());

  final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  /// Bắt đầu thu âm
  Future<void> startRecording() async {
    try {
      // Kiểm tra quyền microphone
      final permission = await Permission.microphone.request();
      if (permission != PermissionStatus.granted) {
        state = state.copyWith(
          errorMessage: 'Cần quyền truy cập microphone để thu âm',
        );
        return;
      }

      // Kiểm tra xem thiết bị có hỗ trợ thu âm không
      if (!await _recorder.hasPermission()) {
        state = state.copyWith(errorMessage: 'Không có quyền thu âm');
        return;
      }

      // Tạo đường dẫn file
      final directory = Directory.systemTemp;
      final filePath =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Bắt đầu thu âm
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      // Cập nhật state
      state = state.copyWith(
        isRecording: true,
        isPaused: false,
        duration: Duration.zero,
        filePath: filePath,
        errorMessage: null,
      );

      // Bắt đầu timer để cập nhật thời gian
      _startTimer();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi khi bắt đầu thu âm: $e');
    }
  }

  /// Tạm dừng thu âm
  Future<void> pauseRecording() async {
    try {
      await _recorder.pause();
      state = state.copyWith(isRecording: false, isPaused: true);
      _timer?.cancel();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi khi tạm dừng: $e');
    }
  }

  /// Tiếp tục thu âm
  Future<void> resumeRecording() async {
    try {
      await _recorder.resume();
      state = state.copyWith(isRecording: true, isPaused: false);
      _startTimer();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi khi tiếp tục thu âm: $e');
    }
  }

  /// Dừng thu âm
  Future<void> stopRecording() async {
    try {
      final path = await _recorder.stop();
      _timer?.cancel();

      state = state.copyWith(
        isRecording: false,
        isPaused: false,
        filePath: path,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Lỗi khi dừng thu âm: $e');
    }
  }

  /// Reset trạng thái để bắt đầu thu âm mới
  void reset() {
    _timer?.cancel();
    state = const RecordingState();
  }

  /// Bắt đầu timer để cập nhật thời gian thu âm
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRecording) {
        state = state.copyWith(
          duration: Duration(seconds: state.duration.inSeconds + 1),
        );
      }
    });
  }
}
