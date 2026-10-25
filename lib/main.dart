import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rootin_mobile/app/app.dart';
import 'package:rootin_mobile/core/config/supabase_config.dart';

Future<void> main() async {
  await initializeSupabaseSafely();
  runApp(const ProviderScope(child: RootinApp()));
}
