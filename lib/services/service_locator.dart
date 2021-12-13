import 'package:audio_service/audio_service.dart';

import 'package:get_it/get_it.dart';
import 'package:nnn_app/Audio/audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // services
  //Registers the audio handler returned from initAudioService as singleton
  getIt.registerSingleton<AudioHandler>(await initAudioService());
}
