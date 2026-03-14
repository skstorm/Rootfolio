import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'manual_setup.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
void configureDependencies(String env) => manualSetup(getIt, env);
