import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:wheelfaster/models/place_amenity.dart';
import 'package:wheelfaster/services/ors_service.dart';
import 'package:wheelfaster/services/place_amenity_service.dart';

class MyMapController extends ChangeNotifier {
  MyMapController(this._service);

  final PlaceAmenityService _service;
  OrsRoute? currentRoute;

  // ===== Map state =====
  LatLng center = const LatLng(14.0711, 100.6031);
  double zoom = 16;
  String _mapType = 'openstreet';
  String get mapType => _mapType;

  String get tileUrl => _mapType == 'openstreet'
      ? 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png'
      : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  void toggleMapType() {
    _mapType = _mapType == 'openstreet' ? 'satellite' : 'openstreet';
    notifyListeners();
  }

  // ===== Data state =====
  final List<PlaceAmenity> _items = [];
  List<PlaceAmenity> get items => List.unmodifiable(_items);

  bool loading = true;
  Object? error;

  // ฟิลเตอร์ตาม typeKey (ใช้ 'ALL' หรือคีย์ตัวพิมพ์ใหญ่ให้ตรงกับ model)
  String _selectedTypeKey = 'ALL';
  String get selectedTypeKey => _selectedTypeKey;

  // ลิสต์ที่ “ถูกกรองแล้ว” สำหรับนำไปวาด Marker
  List<PlaceAmenity> get visibleItems {
    if (_selectedTypeKey == 'ALL') return items;
    return _items.where((e) => e.typeKey == _selectedTypeKey).toList();
  }

  // เปลี่ยนฟิลเตอร์จาก UI (รับอะไรมาก็แปลงเป็น UPPERCASE ให้ตรงกับ model)
  void setFilter(String key) {
    _selectedTypeKey = (key.toUpperCase() == 'ALL') ? 'ALL' : key.toUpperCase();
    notifyListeners(); // ให้ UI รีบิลด์ แล้วไปอ่าน visibleItems
  }

  StreamSubscription<List<PlaceAmenity>>? _sub;

  void start() {
    loading = true;
    error = null;
    notifyListeners();

    _sub?.cancel();
    _sub = _service.watchAll().listen(
      (list) {
        _items
          ..clear()
          ..addAll(list); // list ควร map มาเป็น PlaceAmenity.fromDoc แล้ว
        loading = false;
        notifyListeners();
      },
      onError: (e) {
        error = e;
        loading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get hasRoute => currentRoute != null && routePoints.isNotEmpty;
  OrsRoute? get route => currentRoute;

  List<LatLng> routePoints = [];
  List<OrsStep> routeSteps = [];
  double routeDistance = 0; // m
  double routeDuration = 0; // s

  void clearRoute() {
    currentRoute = null;
    routePoints = [];
    routeSteps = [];
    routeDistance = 0;
    routeDuration = 0;
    notifyListeners();
  }

  void setRoute(OrsRoute r) {
    currentRoute = r;
    routePoints = r.geometry;
    routeSteps = r.steps;
    routeDistance = r.distance;
    routeDuration = r.duration;
    notifyListeners();
  }
}
