import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';
import 'package:geolocator/geolocator.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMapState();
}

class _OpenMapState extends State<OpenMap> {
  late GoogleMapController _mapController;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;
  final LatLng _staticMarkerPosition =
      const LatLng(13.350918350149795, 103.86433962916841);
  LatLng _currentPosition =
      const LatLng(13.350918350149795, 103.86433962916841);
  bool _isLocationReady = false;

  // Markers
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _getCurrentLocation();
  }

  // Load custom icon for static marker
  void _loadCustomIcon() async {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      'assets/img/logo_google_map.png',
    ).then((markerIcon) {
      setState(() {
        _markerIcon = markerIcon;
        _updateMarkers();
      });
    });
  }

  // Get current device location
  void _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle error, show message to user about enabling location
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLocationReady = true;
      _updateMarkers();
    });

    // Ensure the map controller is initialized before animating the camera
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 18),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Animate the camera only after the location is ready
    if (_isLocationReady) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition, 18),
      );
    }
  }

  // Update markers
  void _updateMarkers() {
    _markers = {
      // Static marker (using custom icon)
      Marker(
        markerId: const MarkerId('static_marker'),
        position: _staticMarkerPosition,
        icon: _markerIcon,
      ),
      // Dynamic marker (following current device location)
      Marker(
        markerId: const MarkerId('current_location_marker'),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };
  }

  void _zoomIn() {
    _mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController.animateCamera(CameraUpdate.zoomOut());
  }

  MapType _currentMapType = MapType.normal;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(title: 'Map'),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            mapType: _currentMapType,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 18,
            ),
            markers: _markers, // Use the updated markers
            circles: {
              Circle(
                circleId: const CircleId("1"),
                // center: _currentPosition,
                center: _staticMarkerPosition,
                radius: 46,
                strokeWidth: 2,
                strokeColor: primaryColor,
                fillColor: primaryColor.withOpacity(0.2),
              ),
            },
          ),
          Positioned(
            top: 20,
            right: 5,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _onMapTypeButtonPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: secondaryColor,
                    backgroundColor: primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    elevation: 4,
                  ),
                  child: const Icon(Icons.layers),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: _zoomIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: secondaryColor,
                    backgroundColor: primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    elevation: 4,
                  ),
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: _zoomOut,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: secondaryColor,
                    backgroundColor: primaryColor,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(8),
                    elevation: 4,
                  ),
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
