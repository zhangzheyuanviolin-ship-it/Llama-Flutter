import 'package:flutter_test/flutter_test.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:llama_flutter_android/llama_flutter_android_platform_interface.dart';
import 'package:llama_flutter_android/llama_flutter_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLlamaFlutterAndroidPlatform
    with MockPlatformInterfaceMixin
    implements LlamaFlutterAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LlamaFlutterAndroidPlatform initialPlatform = LlamaFlutterAndroidPlatform.instance;

  test('$MethodChannelLlamaFlutterAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLlamaFlutterAndroid>());
  });

  test('getPlatformVersion', () async {
    LlamaFlutterAndroid llamaFlutterAndroidPlugin = LlamaFlutterAndroid();
    MockLlamaFlutterAndroidPlatform fakePlatform = MockLlamaFlutterAndroidPlatform();
    LlamaFlutterAndroidPlatform.instance = fakePlatform;

    expect(await llamaFlutterAndroidPlugin.getPlatformVersion(), '42');
  });
}
