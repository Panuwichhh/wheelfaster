import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:wheelfaster/models/place_amenity.dart';
import 'package:wheelfaster/services/ors_service.dart';
import 'package:wheelfaster/services/place_amenity_service.dart';
import 'package:flutter_compass/flutter_compass.dart';

class MyMapController extends ChangeNotifier {
  MyMapController(this._service);

  final PlaceAmenityService _service;
  OrsRoute? currentRoute;
  final Distance _distance = const Distance();

  // ===== Map Controller =====
  MapController? _mapController;

  void setMapController(MapController controller) {
    _mapController = controller;
    //notifyListeners();
  }

  // ===== Animated Map Move =====
  void simpleMove(LatLng destLocation, double destZoom) {
    if (_mapController == null) {
      debugPrint('MapController not initialized');
      return;
    }
    
    _mapController!.move(destLocation, destZoom);
  }

  // ===== Map state =====
  LatLng center = const LatLng(14.0711, 100.6031);
  double zoom = 16;
  String _mapType = 'openstreet';
  String get mapType => _mapType;

  String get tileUrl {
    switch (_mapType) {
      case 'openstreet':
        return 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png';

      case 'satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

      case 'light':
        return 'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}{r}.png';
      case 'dark':
        return 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

      default:
        return 'https://{s}.tile.openstreetmap.de/{z}/{x}/{y}.png';
    }
  }

  void setMapType(String type) {
    _mapType = type;
    notifyListeners();
  }
  //Realtime update location
  LatLng? _userLocation;
  LatLng? get userLocation => _userLocation;

  double? _heading; // degree 0–360
  double? get heading => _heading;

  StreamSubscription<Position>? _posSub;
  StreamSubscription<dynamic>? _compassSub;

  void _updateRouteProgress() {
    if (_userLocation == null) return;
    if (routePoints.isEmpty) return;

    final user = _userLocation!;

    // หา point บนเส้นทางที่ใกล้ user มากที่สุด
    int closestIndex = 0;
    double closestDist = double.infinity;

    for (int i = 0; i < routePoints.length; i++) {
      final d = _distance(user, routePoints[i]); // หน่วยเป็นเมตร
      if (d < closestDist) {
        closestDist = d;
        closestIndex = i;
      }
    }

    // ถ้าผู้ใช้อยู่ไกลกว่า 15m จากเส้น ไม่ต้องตัด (กันเผื่อ GPS เพี้ยน)
    if (closestDist > 15) return;

    // ตัดจุดก่อนหน้าออก ให้เหลือเฉพาะเส้น ข้างหน้าผู้ใช้
    if (closestIndex > 0 && closestIndex < routePoints.length) {
      routePoints = List.from(routePoints.sublist(closestIndex));

      // ถ้าใกล้ถึงปลายทางแล้ว เคลียร์ route ทิ้งเลย
      if (routePoints.length < 5) {
        clearRoute();
      } else {
        notifyListeners();
        }
      }
  }

  Future<void> startUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return;
    }

    // ตำแหน่งผู้ใช้แบบ realtime
    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3, // ขยับเกิน 3 เมตรค่อยอัปเดต
      ),
    ).listen((pos) {
      _userLocation = LatLng(pos.latitude, pos.longitude);
      _updateRouteProgress();
      notifyListeners();
      
    });

    // เข็มทิศ / ทิศที่หันอยู่
    _compassSub?.cancel();
    _compassSub = FlutterCompass.events!.listen((event) {
      _heading = event.heading; // องศา 0–360
      notifyListeners();
    });
    
  }

  void stopUserLocation() {
    _posSub?.cancel();
    _compassSub?.cancel();
    _posSub = null;
    _compassSub = null;
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
    _updateRouteProgress();
  }
  
    @override
  void dispose() {
    _sub?.cancel();    // ยกเลิก stream สถานที่
    _posSub?.cancel(); // ยกเลิก stream ตำแหน่งผู้ใช้ (realtime)
    _compassSub?.cancel();
    super.dispose();
  }
}
