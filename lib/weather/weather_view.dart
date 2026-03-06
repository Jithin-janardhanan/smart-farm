import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfarm/model/colors_model.dart';
import 'package:smartfarm/weather/weather_model.dart';
import 'package:smartfarm/weather/weather_service.dart';

/// Weather forecast card with location autocomplete (OpenStreetMap Nominatim).
/// Usage:  WeatherForecastWidget(token: token)
class WeatherForecastWidget extends StatefulWidget {
  final String token;

  const WeatherForecastWidget({super.key, required this.token});

  @override
  State<WeatherForecastWidget> createState() => _WeatherForecastWidgetState();
}

class _WeatherForecastWidgetState extends State<WeatherForecastWidget>
    with SingleTickerProviderStateMixin {
  // ── Weather state ──────────────────────────────────────────────────────────
  WeatherModel? _weather;
  bool _isLoading = true;
  String? _error;

  // ── Search state ───────────────────────────────────────────────────────────
  bool _showSearch = false;
  String _city = '';
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // ── Suggestions state ──────────────────────────────────────────────────────
  List<_CityOption> _suggestions = [];
  bool _loadingSuggestions = false;
  Timer? _debounce;

  late AnimationController _shimmerController;

  static const _cityPrefKey = 'weather_city';
  static const _defaultCity = 'Thrissur';

  // ──────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _cityController.addListener(_onTyping);
    _loadCityAndFetch();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _cityController.removeListener(_onTyping);
    _cityController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Autocomplete
  // ──────────────────────────────────────────────────────────────────────────

  void _onTyping() {
    // FIX Bug 2: Only run suggestion logic when search bar is actually visible.
    // Previously, AnimatedCrossFade still built the firstChild (search section)
    // even when hidden, so _onTyping fired on every keystroke regardless.
    if (!_showSearch) return;

    final query = _cityController.text.trim();
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (!mounted) return;
    setState(() => _loadingSuggestions = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&addressdetails=1&limit=6&featuretype=city',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'AgritaApp/1.0'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data
            .map((e) => _CityOption.fromNominatim(e))
            .where((c) => c.city.isNotEmpty)
            .toList();

        // Deduplicate by city+country
        final seen = <String>{};
        final unique = results.where((c) {
          final key = '${c.city}|${c.country}';
          return seen.add(key);
        }).toList();

        setState(() => _suggestions = unique);
      }
    } catch (_) {
      // Silently ignore suggestion errors
    } finally {
      if (mounted) setState(() => _loadingSuggestions = false);
    }
  }

  void _selectSuggestion(_CityOption option) {
    _debounce?.cancel();
    _cityController.text = option.city;
    setState(() {
      _suggestions = [];
      _showSearch = false;
    });
    _fetchWeather(city: option.city);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Weather fetch
  // ──────────────────────────────────────────────────────────────────────────

  Future<void> _loadCityAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_cityPrefKey) ?? _defaultCity;
    _city = saved;
    _cityController.text = saved;
    await _fetchWeather();
  }

  Future<void> _fetchWeather({String? city}) async {
    final target = (city ?? _city).trim();
    if (target.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _suggestions = [];
      _city = target;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityPrefKey, target);

      final data = await WeatherService.fetchWeather(
        city: target,
        token: widget.token,
      );
      if (mounted) {
        setState(() {
          _weather = data;
          // FIX Bug 3: collapse search bar on successful fetch
          _showSearch = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "No data found for '$target'";
          // FIX Bug 1: auto-open search so user can correct the city name
          _showSearch = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocus.requestFocus();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitSearch() {
    final input = _cityController.text.trim();
    if (input.isEmpty) return;
    _debounce?.cancel();
    setState(() {
      _showSearch = false;
      _suggestions = [];
    });
    _fetchWeather(city: input);
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      _suggestions = [];
      if (_showSearch) {
        _cityController.text = _city;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFocus.requestFocus();
        });
      }
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────

  IconData _weatherIcon(String description) {
    final d = description.toLowerCase();
    if (d.contains('thunder')) return Icons.thunderstorm_outlined;
    if (d.contains('rain') || d.contains('drizzle')) return Icons.grain;
    if (d.contains('snow')) return Icons.ac_unit;
    if (d.contains('mist') || d.contains('fog') || d.contains('haze')) {
      return Icons.cloud_outlined;
    }
    if (d.contains('cloud')) return Icons.cloud_queue;
    return Icons.wb_sunny_outlined;
  }

  Color _weatherColor(String description, ColorScheme cs) {
    final d = description.toLowerCase();
    if (d.contains('thunder')) return Colors.deepPurple;
    if (d.contains('rain') || d.contains('drizzle')) return Colors.blueAccent;
    if (d.contains('snow')) return Colors.lightBlue;
    if (d.contains('cloud')) return Colors.blueGrey;
    return cs.primary;
  }

  String _shortDay(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dt.weekday - 1];
    } catch (_) {
      return dateStr.length >= 7 ? dateStr.substring(5) : dateStr;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ──────────────────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // FIX Bug 2: Replaced AnimatedCrossFade with a conditional build.
          // AnimatedCrossFade always renders both children, meaning the search
          // TextField's listener ran even when the search bar was "hidden",
          // triggering spurious suggestion fetches on any city controller change.
          if (_showSearch) ...[
            _buildSearchSection(cs, tt),
            const SizedBox(height: 8),
          ],

          if (_isLoading)
            _buildShimmer(cs)
          else if (_error != null)
            _buildError(cs, tt)
          else if (_weather != null)
            _buildCard(cs, tt),
        ],
      ),
    );
  }

  // ── Search section (field + dropdown suggestions) ─────────────────────────

  Widget _buildSearchSection(ColorScheme cs, TextTheme tt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.greenGlow,
          ),
          child: TextField(
            controller: _cityController,
            focusNode: _searchFocus,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submitSearch(),
            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search city…',
              // FIX Bug 4: withOpacity is deprecated in Flutter 3.27+
              hintStyle: TextStyle(
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: cs.primary,
                size: 20,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loadingSuggestions)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                        ),
                      ),
                    )
                  else if (_cityController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        _cityController.clear();
                        setState(() => _suggestions = []);
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _submitSearch,
                      tooltip: 'Search',
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
          ),
        ),

        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppColors.greenGlow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _suggestions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final opt = entry.value;
                  final isLast = i == _suggestions.length - 1;
                  return InkWell(
                    onTap: () => _selectSuggestion(opt),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: cs.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.city,
                                      style: tt.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    if (opt.subtitle.isNotEmpty)
                                      Text(
                                        opt.subtitle,
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.onSurface.withValues(
                                            alpha: 0.5,
                                          ),
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.north_west,
                                size: 12,
                                color: cs.onSurface.withValues(alpha: 0.3),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 42,
                            endIndent: 16,
                            color: cs.onSurface.withValues(alpha: 0.08),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  // ── Main weather card ─────────────────────────────────────────────────────

  Widget _buildCard(ColorScheme cs, TextTheme tt) {
    final cur = _weather!.current;
    final iconColor = _weatherColor(cur.description, cs);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.greenGlow,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _weatherIcon(cur.description),
                    color: iconColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${cur.temperature.toStringAsFixed(1)}°',
                            style: tt.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              'C',
                              style: tt.titleSmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _toggleSearch,
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              _weather!.city,
                              style: tt.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '· ${_capitalize(cur.description)}',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _toggleSearch,
                      icon: Icon(
                        _showSearch
                            ? Icons.search_off
                            : Icons.edit_location_alt_outlined,
                        color: cs.primary,
                        size: 20,
                      ),
                      tooltip: 'Change location',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _fetchWeather(),
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: cs.onSurface.withValues(alpha: 0.45),
                        size: 20,
                      ),
                      tooltip: 'Refresh',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statChip(
                  icon: Icons.water_drop_outlined,
                  label: '${cur.humidity}%',
                  hint: 'Humidity',
                  color: Colors.blue,
                  cs: cs,
                ),
                _statChip(
                  icon: Icons.air,
                  label: '${cur.windSpeed} m/s',
                  hint: 'Wind',
                  color: Colors.teal,
                  cs: cs,
                ),
                _statChip(
                  icon: Icons.thermostat_outlined,
                  label: '${cur.temperature.toStringAsFixed(0)}°C',
                  hint: 'Temp',
                  color: Colors.orange,
                  cs: cs,
                ),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: cs.onSurface.withValues(alpha: 0.07),
            indent: 16,
            endIndent: 16,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _weather!.upcomingForecast
                  .take(5)
                  .map((f) => _forecastTile(f, cs, tt))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _forecastTile(Forecast f, ColorScheme cs, TextTheme tt) {
    final color = _weatherColor(f.description, cs);
    return Column(
      children: [
        Text(
          _shortDay(f.date),
          style: tt.labelSmall?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(_weatherIcon(f.description), color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          '${f.temperature.toStringAsFixed(0)}°',
          style: tt.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        Text(
          '${f.humidity}%',
          style: tt.labelSmall?.copyWith(
            color: Colors.blue.withValues(alpha: 0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // FIX Bug 4 + Bug 7: Added required `cs` param; hint text now uses
  // cs.onSurface instead of hardcoded Colors.black54 (dark mode safe).
  Widget _statChip({
    required IconData icon,
    required String label,
    required String hint,
    required Color color,
    required ColorScheme cs,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              hint,
              style: TextStyle(
                fontSize: 10,
                color: cs.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmer(ColorScheme cs) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        final shimmerColor = Color.lerp(
          cs.surface,
          cs.primary.withValues(alpha: 0.08),
          _shimmerController.value,
        )!;
        return Container(
          height: 180,
          decoration: BoxDecoration(
            color: shimmerColor,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  Widget _buildError(ColorScheme cs, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.greenGlow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: cs.onSurface.withValues(alpha: 0.3),
            size: 44,
          ),
          const SizedBox(height: 10),
          Text(
            _error!,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildSearchSection(cs, tt),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _fetchWeather(),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry same city'),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.primary,
              side: BorderSide(color: cs.primary.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Data class for a Nominatim suggestion
// ──────────────────────────────────────────────────────────────────────────────

class _CityOption {
  final String city;
  final String subtitle;

  const _CityOption({required this.city, required this.subtitle});

  factory _CityOption.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};

    final city =
        (address['city'] as String?) ??
        (address['town'] as String?) ??
        (address['village'] as String?) ??
        (address['county'] as String?) ??
        (json['name'] as String?) ??
        '';

    final state = (address['state'] as String?) ?? '';
    final country = (address['country'] as String?) ?? '';

    final subtitle = [state, country].where((s) => s.isNotEmpty).join(', ');

    return _CityOption(city: city, subtitle: subtitle);
  }

  String get country {
    final parts = subtitle.split(', ');
    return parts.isNotEmpty ? parts.last : '';
  }
}