import 'package:plan_ex_app/core/utils/app_logger.dart';

class SyncService {
  Future<void> syncPendingData() async {
    AppLogger.logString("🔄 Sync pending local changes with Firestore...");
  }
}
