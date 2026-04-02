import 'package:face_locker/features/auth/presentation/pages/login_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_action_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_detail_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_edit_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_list_page.dart';
import 'package:face_locker/features/locker/presentation/pages/locker_stats_page.dart';
import 'package:face_locker/features/management/presentation/pages/daily_usage_page.dart';
import 'package:face_locker/features/management/presentation/pages/security_alert_page.dart';
import 'package:face_locker/features/management/presentation/pages/stats_overview_pages.dart';
import 'package:face_locker/features/management/presentation/pages/transaction_logs_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const StatsOverviewPages(),
    );
  }
}
