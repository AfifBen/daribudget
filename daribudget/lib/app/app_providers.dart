import 'package:provider/provider.dart';

import '../db/app_db.dart';

class AppProviders {
  static List<Provider> all() => [
        Provider<AppDb>(
          create: (_) => AppDb(),
          dispose: (_, db) => db.close(),
        ),
      ];
}
