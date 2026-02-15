import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusconnect/main.dart'; // Import main to ensure Supabase is init

void main() async {
  // Simple checks
  print('--- DEBUGGING SERVICES DATA ---');
  
  // Note: We cannot easily run this standalone without proper async init of Supabase 
  // if it depends on flutter_dotenv etc. 
  // Instead, we will assume this is run IN the app context or we create a minimal init.
}
