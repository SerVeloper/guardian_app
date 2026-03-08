import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../application/aws_places_service.dart';
import '../../application/aws_routes_service.dart';
import '../../application/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapLibreMapController? _mapController;

  static const String _apiKey = 'v1.public.eyJqdGkiOiI0ZjE2NGZmZS1mMDEzLTQ0ZjEtOTQzMC0wNWFiYzhmYWFjNjgifXG793YQDv5U4n6UjpoT0eJnY-00rAaCP7nWiEIitlYRj_vlbSyZQLgSwtuXsaOaN2ih-DiFFTUJt-tnEjUoDiZHpzOLW3wIGzn8RK1YnjiWs2_2UQ1q7BL5LrbD2UWPwld9X684bDnAD5eEFLREhi6FXlYqmb4yjnbnLEIzAQ8oOzMVT16IPIQZCyWUbw7GResELcpITh1UsAGZUr8VQPU0X_ZAButigxQrQFG7l1FCHuX855NLC9zxjsPjzk_O2Zo8JF3Lx8p8GWZvjlGm_GVhfOfT7ln-Fk_jJI6xYlFW-I5WO_DdP_wV5oOAgjemw8QIIOmxoZWixk1l2MmAoIg.NjAyMWJkZWUtMGMyOS00NmRkLThjZTMtODEyOTkzZTUyMTBi';
  static const String _mapName = 'guardian-map';
  static const String _region = 'us-east-2';

  static const String _styleUrl =
      'https://maps.geo.us-east-2.amazonaws.com/maps/v0/maps/$_mapName/style-descriptor?key=$_apiKey';

  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();

  late final AwsPlacesService _placesService;
  late final AwsRoutesService _routesService;

  Position? _currentPosition;
  PlaceSearchResult? _selectedPlace;

  bool _loadingLocation = false;
  bool _searching = false;
  bool _calculatingRoute = false;
  bool _isWalking = true;

  bool _mapStyleLoaded = false;
  bool _markerImagesLoaded = false;

  Timer? _debounce;
  List<PlaceSearchResult> _results = [];

  double? _routeDistanceMeters;
  double? _routeDurationSeconds;
  Line? _routeLine;

  Symbol? _originMarker;
  Symbol? _destinationMarker;

  final List<String> _recentPlaces = const [
    'Avenida Juana Azurduy',
    'Supermercado SAS',
    'Hospital San Pedro Claver',
  ];

  @override
  void initState() {
    super.initState();

    _placesService = AwsPlacesService(
      apiKey: _apiKey,
      region: _region,
    );

    _routesService = AwsRoutesService(
      apiKey: _apiKey,
      region: _region,
    );

    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool get _canCalculateRoute =>
      _currentPosition != null && _selectedPlace != null && !_calculatingRoute;

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      final position = await _locationService.getCurrentLocation();

      setState(() {
        _currentPosition = position;
      });

      await _syncOriginOnMap();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ubicación: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingLocation = false;
        });
      }
    }
  }

  Future<void> _syncOriginOnMap() async {
    if (_mapController == null) return;
    if (!_mapStyleLoaded) return;
    if (!_markerImagesLoaded) return;
    if (_currentPosition == null) return;

    await _upsertOriginMarker(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        15,
      ),
    );
  }

  Future<void> _syncDestinationOnMap() async {
    if (_mapController == null) return;
    if (!_mapStyleLoaded) return;
    if (!_markerImagesLoaded) return;
    if (_selectedPlace == null) return;

    await _upsertDestinationMarker(
      _selectedPlace!.latitude,
      _selectedPlace!.longitude,
    );
  }

  Future<void> _upsertOriginMarker(double lat, double lng) async {
    if (_mapController == null || !_mapStyleLoaded || !_markerImagesLoaded) {
      return;
    }

    if (_originMarker != null) {
      await _mapController!.removeSymbol(_originMarker!);
      _originMarker = null;
    }

    _originMarker = await _mapController!.addSymbol(
      SymbolOptions(
        geometry: LatLng(lat, lng),
        iconImage: 'current_location_icon',
        iconSize: 0.38,
        iconAnchor: 'bottom',
      ),
    );
  }

  Future<void> _upsertDestinationMarker(double lat, double lng) async {
    if (_mapController == null || !_mapStyleLoaded || !_markerImagesLoaded) {
      return;
    }

    if (_destinationMarker != null) {
      await _mapController!.removeSymbol(_destinationMarker!);
      _destinationMarker = null;
    }

    _destinationMarker = await _mapController!.addSymbol(
      SymbolOptions(
        geometry: LatLng(lat, lng),
        iconImage: 'destination_location_icon',
        iconSize: 0.38,
        iconAnchor: 'bottom',
      ),
    );
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().length < 3) {
      setState(() {
        _results = [];
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _searchPlaces(value.trim());
    });
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _searching = true;
    });

    try {
      final results = await _placesService.searchText(
        query: query,
        biasLat: _currentPosition?.latitude,
        biasLng: _currentPosition?.longitude,
      );

      if (!mounted) return;

      setState(() {
        _results = results;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Búsqueda: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  Future<void> _selectPlace(PlaceSearchResult place) async {
    _searchController.text = place.addressLabel;

    setState(() {
      _results = [];
      _selectedPlace = place;
      _routeDistanceMeters = null;
      _routeDurationSeconds = null;
    });

    await _clearPreviousRoute();
    await _syncDestinationOnMap();

    await _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(place.latitude, place.longitude),
        16,
      ),
    );
  }

  Future<void> _searchFromRecent(String text) async {
    _searchController.text = text;
    await _searchPlaces(text);
  }

  Future<void> _clearPreviousRoute() async {
    if (_routeLine != null && _mapController != null) {
      await _mapController!.removeLine(_routeLine!);
      _routeLine = null;
    }
  }

  Future<Uint8List> _materialIconToBytes({
    required IconData icon,
    required Color color,
    double size = 90,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = TextPainter(textDirection: TextDirection.ltr);

    final textSpan = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );

    painter.text = textSpan;
    painter.layout();

    final width = painter.width + 12;
    final height = painter.height + 12;

    painter.paint(canvas, const Offset(6, 6));

    final picture = recorder.endRecording();
    final image = await picture.toImage(width.ceil(), height.ceil());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> _loadMarkerImages() async {
    if (_mapController == null) return;
    if (_markerImagesLoaded) return;

    final currentBytes = await _materialIconToBytes(
      icon: Icons.location_pin,
      color: const Color(0xFF0B7881),
      size: 88,
    );

    final destinationBytes = await _materialIconToBytes(
      icon: Icons.location_pin,
      color: const Color(0xFFD32F2F),
      size: 88,
    );

    await _mapController!.addImage('current_location_icon', currentBytes);
    await _mapController!.addImage(
      'destination_location_icon',
      destinationBytes,
    );

    _markerImagesLoaded = true;
  }

  Future<void> _calculateRoute() async {
    if (_currentPosition == null || _selectedPlace == null) return;

    setState(() {
      _calculatingRoute = true;
    });

    try {
      await _clearPreviousRoute();

      final route = await _routesService.calculateRoute(
        originLat: _currentPosition!.latitude,
        originLng: _currentPosition!.longitude,
        destLat: _selectedPlace!.latitude,
        destLng: _selectedPlace!.longitude,
        isWalking: _isWalking,
      );

      setState(() {
        _routeDistanceMeters = route.distanceMeters;
        _routeDurationSeconds = route.durationSeconds;
      });

      if (_mapController != null && route.coordinates.isNotEmpty) {
        final points = route.coordinates
            .map((c) => LatLng(c[1], c[0]))
            .toList();

        _routeLine = await _mapController!.addLine(
          LineOptions(
            geometry: points,
            lineColor: '#7FD36C',
            lineWidth: 5.0,
            lineOpacity: 0.95,
          ),
        );

        final bounds = _boundsFromLatLngList(points);

        await _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            left: 50,
            top: 80,
            right: 50,
            bottom: 340,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _calculatingRoute = false;
        });
      }
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat;
    double? maxLat;
    double? minLng;
    double? maxLng;

    for (final p in list) {
      minLat = minLat == null
          ? p.latitude
          : (p.latitude < minLat ? p.latitude : minLat);
      maxLat = maxLat == null
          ? p.latitude
          : (p.latitude > maxLat ? p.latitude : maxLat);
      minLng = minLng == null
          ? p.longitude
          : (p.longitude < minLng ? p.longitude : minLng);
      maxLng = maxLng == null
          ? p.longitude
          : (p.longitude > maxLng ? p.longitude : maxLng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  String _formatDistance(double? meters) {
    if (meters == null) return '1.2 km';
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '15 min aprox';
    final minutes = (seconds / 60).round();
    return '$minutes min aprox';
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialTarget = _currentPosition == null
        ? const LatLng(-19.047, -65.259)
        : LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            styleString: _styleUrl,
            initialCameraPosition: CameraPosition(
              target: initialTarget,
              zoom: 14,
            ),
            onMapCreated: (controller) async {
              _mapController = controller;
              await _syncOriginOnMap();
            },
            onStyleLoadedCallback: () async {
              _mapStyleLoaded = true;

              await _loadMarkerImages();
              await _syncOriginOnMap();
              await _syncDestinationOnMap();
            },
            myLocationEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: false,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: Row(
                    children: [
                      _FloatingCircleButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      _FloatingCircleButton(
                        onTap: _loadCurrentLocation,
                        child: _loadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.my_location,
                                size: 18,
                                color: Color(0xFF2B2B2B),
                              ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'A donde vas?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE4E4E4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Calle Luis Paz, 123',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF767676),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: Color(0xFF9D9D9D),
                            ),
                            suffixIcon: _searching
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      if (_results.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 210),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: _results.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _results[index];
                              return ListTile(
                                dense: true,
                                leading: const Icon(
                                  Icons.location_pin,
                                  size: 18,
                                  color: Color(0xFF8F8F8F),
                                ),
                                title: Text(
                                  item.title.isEmpty
                                      ? item.addressLabel
                                      : item.title,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                subtitle: Text(
                                  item.addressLabel,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onTap: () => _selectPlace(item),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: _TravelModeOption(
                              label: 'A Pie',
                              selected: _isWalking,
                              onTap: () {
                                setState(() {
                                  _isWalking = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TravelModeOption(
                              label: 'Transporte motorizado',
                              selected: !_isWalking,
                              onTap: () {
                                setState(() {
                                  _isWalking = false;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Lugares recientes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._recentPlaces.map(
                        (place) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () => _searchFromRecent(place),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_pin,
                                  size: 16,
                                  color: Color(0xFF969696),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    place,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF414141),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SafeRouteCard(
                        durationText: _formatDuration(_routeDurationSeconds),
                        distanceText: _formatDistance(_routeDistanceMeters),
                      ),
                      const SizedBox(height: 10),
                      const _RemoteMonitoringCard(),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _canCalculateRoute ? _calculateRoute : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B7881),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: _calculatingRoute
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Confirmar y comenzar',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingCircleButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback onTap;

  const _FloatingCircleButton({
    this.icon,
    this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(240),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: child ??
              Icon(
                icon,
                size: 18,
                color: const Color(0xFF2B2B2B),
              ),
        ),
      ),
    );
  }
}

class _TravelModeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TravelModeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final indicatorColor =
        selected ? const Color(0xFF0B7881) : const Color(0xFFB2B2B2);

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 18,
            color: indicatorColor,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF222222),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeRouteCard extends StatelessWidget {
  final String durationText;
  final String distanceText;

  const _SafeRouteCard({
    required this.durationText,
    required this.distanceText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8E7),
        border: Border.all(color: const Color(0xFF8FD87E)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(
                Icons.shield_outlined,
                size: 16,
                color: Color(0xFF6DCE5B),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Ruta segura encontrada',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6DCE5B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: Color(0xFF8E8E8E),
              ),
              const SizedBox(width: 4),
              Text(
                durationText,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7B7B7B),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.location_pin,
                size: 14,
                color: Color(0xFF8E8E8E),
              ),
              const SizedBox(width: 4),
              Text(
                distanceText,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7B7B7B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RemoteMonitoringCard extends StatelessWidget {
  const _RemoteMonitoringCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE7EB),
        border: Border.all(color: const Color(0xFF7DAAB6)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 16,
            color: Color(0xFF2C5C67),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Acompañamiento remoto',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2F4F57),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Monitoreo activo',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4E6B73),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(52, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Cambiar',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B7881),
              ),
            ),
          ),
        ],
      ),
    );
  }
}