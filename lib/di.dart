import 'package:get_it/get_it.dart';

final di = GetIt.instance;

Future<void> inject() async {
  di.registerSingleton(10);
}
