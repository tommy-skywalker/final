import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ovorideuser/core/helper/string_format_helper.dart';
import 'package:ovorideuser/data/services/api_service.dart';

class AudioUtils {
  static Future<void> playAudio(String path) async {
    printx('isNotificationAudioEnable: ${path}');
    if (Get.find<ApiClient>().isNotificationAudioEnable() == true) {
      AudioPlayer player = AudioPlayer();
      try {
        await player.stop();
        await player.setUrl(path);
        await player.play();
      } catch (e) {
        printx(e);
      }
    }
  }
}
