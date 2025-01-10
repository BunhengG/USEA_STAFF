import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usea_staff_test/Components/custom_appbar_widget.dart';
import 'package:usea_staff_test/constant/constant.dart';

class OpenMap extends StatefulWidget {
  const OpenMap({super.key});

  @override
  State<OpenMap> createState() => _OpenMapState();
}

class _OpenMapState extends State<OpenMap> {
  late GoogleMapController _mapController;
  BitmapDescriptor _markerIcon = BitmapDescriptor.defaultMarker;
  final LatLng _initialPosition =
      const LatLng(13.350918350149795, 103.86433962916841);

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
  }

  void _loadCustomIcon() async {
    // ignore: deprecated_member_use
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(devicePixelRatio: 2.5),
      'assets/img/usea_check.png',
    );
    setState(() {
      _markerIcon = customIcon;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
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
              target: _initialPosition,
              zoom: 13,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('university_marker'),
                position: _initialPosition,
                icon: _markerIcon,
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
