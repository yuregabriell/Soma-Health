import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Best-effort local notifications without a server.
/// Notifications are scheduled for the next 21 days and refreshed on app launch.
class WaterReminderService {
  static final WaterReminderService instance=WaterReminderService._();
  WaterReminderService._();
  final FlutterLocalNotificationsPlugin plugin=FlutterLocalNotificationsPlugin();
  bool initialized=false;
  static const details=NotificationDetails(
    android:AndroidNotificationDetails(
      'soma_hydration','Hidratação','Lembretes de ingestão de água',
      importance:Importance.defaultImportance,
      priority:Priority.defaultPriority,
      playSound:true,
    ),
  );

  Future<void> initialize()async{
    if(initialized)return;
    tz.initializeTimeZones();
    await plugin.initialize(
      const InitializationSettings(android:AndroidInitializationSettings('@mipmap/ic_launcher')));
    initialized=true;
  }

  Future<bool> enable()async{
    await initialize();
    final api=plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final accepted=await api?.requestNotificationsPermission();
    if(accepted==false)return false;
    await refresh();
    return true;
  }
  Future<void> disable()async{
    await initialize();
    for(var i=0;i<130;i++)await plugin.cancel(2000+i);
  }

  Future<void> refresh()async{
    await initialize();
    await disable();
    final now=DateTime.now();
    final reminderTimes=[const (9,0),const (11,30),const (14,0),const (16,30),const (19,0)];
    var id=2000;
    for(var days=0;days<21;days++){
      final d=DateTime(now.year,now.month,now.day+days);
      for(final time in reminderTimes){
        final local=DateTime(d.year,d.month,d.day,time.$1,time.$2);
        if(local.isBefore(now.add(const Duration(minutes:3))))continue;
        await plugin.zonedSchedule(
          id++,'Hidratação','Como está a correr a tua meta de água hoje?',
          tz.TZDateTime.from(local.toUtc(),tz.UTC),
          details,
          androidScheduleMode:AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    }
  }
}
