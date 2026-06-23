import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const _key = 'favorite_recipes';
  Set<String> _ids = {};
  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _ids = _prefs?.getStringList(_key)?.toSet() ?? {};
    _initialized = true;
  }

  Set<String> getFavorites() => Set.from(_ids);

  Future<void> toggleFavorite(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    await _prefs?.setStringList(_key, _ids.toList());
  }

  bool isFavorite(String id) => _ids.contains(id);
}
