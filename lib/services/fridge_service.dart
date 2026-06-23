import 'package:shared_preferences/shared_preferences.dart';

class FridgeService {
  static const _key = 'fridge_ids';
  Set<String> _ids = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _ids = _prefs?.getStringList(_key)?.toSet() ?? {};
    _initialized = true;
  }

  Set<String> getFridgeIds() => Set.from(_ids);

  Future<void> add(String id) async {
    _ids.add(id);
    await _prefs?.setStringList(_key, _ids.toList());
  }

  Future<void> remove(String id) async {
    _ids.remove(id);
    await _prefs?.setStringList(_key, _ids.toList());
  }

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      await remove(id);
    } else {
      await add(id);
    }
  }

  bool has(String id) => _ids.contains(id);

  Future<void> clearAll() async {
    _ids.clear();
    await _prefs?.setStringList(_key, []);
  }
}
