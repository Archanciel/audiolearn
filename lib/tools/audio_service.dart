import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'audio_task_handler.dart';

class AudioService {
  late AudioTaskHandler _audioTaskHandler;

  void startService() {
    _audioTaskHandler = AudioTaskHandler();
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'audio_service',
        channelName: 'Audio Service',
        channelDescription: 'Foreground service for audio playback',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher',
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: false,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );

    FlutterForegroundTask.startService(
      notificationTitle: 'Audio Service',
      notificationText: 'Audio is playing',
      callback: startCallback,
    );
  }

  @pragma('vm:entry-point')
  void startCallback() {
    FlutterForegroundTask.setTaskHandler(_audioTaskHandler);
  }

  AudioTaskHandler get audioTaskHandler => _audioTaskHandler;
}
