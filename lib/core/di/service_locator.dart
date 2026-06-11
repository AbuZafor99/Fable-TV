import 'set_controllers.dart';
import 'setup_core.dart';
import 'setup_repository.dart';
import 'setup_services.dart';

Future<void> setupServiceLocator() async {
  await setupCore();
  await setupServices();
  setupRepository();
  setupControllers();
}
