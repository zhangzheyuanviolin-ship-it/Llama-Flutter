
import 'llama_flutter_android_platform_interface.dart';

class LlamaFlutterAndroid {
  Future<String?> getPlatformVersion() {
    return LlamaFlutterAndroidPlatform.instance.getPlatformVersion();
  }
}
