// // lib/core/services/onesignal_service.dart
//
// import 'package:onesignal_flutter/onesignal_flutter.dart';
//
//
// class OneSignalService {
//   static const String appId = "cebaa375-de95-4fb8-9403-71089f304ffe";
//
//   static Future<void> initialize() async {
//     await OneSignal.initialize(appId);
//     await OneSignal.User.addTag("user_type", "user");
//     final playerId = await getPlayerId();
//     print("OneSignal playerId: $playerId");
//   }
//
//   static Future<String> getPlayerId() async {
//     try {
//       return await OneSignal.User.getOnesignalId() ?? '';
//     } catch (e) {
//       return '';
//     }
//   }
// }