import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeStorageKey = 'app_theme_mode';
  final StorageService _storageService;

  ThemeCubit({StorageService? storageService})
      : _storageService = storageService ?? StorageService.instance,
        super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final saved = _storageService.getString(_themeStorageKey);
    if (saved == 'light') {
      emit(ThemeMode.light);
    } else if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';
    await _storageService.setString(_themeStorageKey, modeString);
  }

  void toggleTheme() {
    if (state == ThemeMode.dark) {
      setTheme(ThemeMode.light);
    } else {
      setTheme(ThemeMode.dark);
    }
  }
}
