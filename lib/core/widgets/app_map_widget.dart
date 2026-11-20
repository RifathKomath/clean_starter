// import 'package:flutter/material.dart';


// class MapSpot {
//   final String? id;
//   final String? name;
//   final String? imageUrl;
//   final double latitude;
//   final double longitude;
//   final bool usePointer;

//   MapSpot({
//     this.id,
//     this.name,
//     this.imageUrl,
//     required this.latitude,
//     required this.longitude,
//     this.usePointer = false,
//   });
// }

// class AppMapWidget extends StatefulWidget {
//   final List<MapSpot> spots;
//   final double height;
//   final double borderRadius;
//   final bool showControls;
//   final VoidCallback? onExpand;

//   const AppMapWidget({
//     super.key,
//     required this.spots,
//     this.height = 200,
//     this.borderRadius = 20,
//     this.showControls = true,
//     this.onExpand,
//   });

//   @override
//   State<AppMapWidget> createState() => _AppMapWidgetState();
// }

// class _AppMapWidgetState extends State<AppMapWidget> {
//   final MapController _mapController = MapController();

//   @override
//   void didUpdateWidget(AppMapWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.spots.isNotEmpty &&
//         (oldWidget.spots.isEmpty ||
//             widget.spots.first.latitude != oldWidget.spots.first.latitude)) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _moveCamera();
//       });
//     }
//   }

//   void _moveCamera() {
//     if (widget.spots.isEmpty) return;

//     if (widget.spots.length > 1) {
//       final bounds = LatLngBounds.fromPoints(
//         widget.spots.map((s) => LatLng(s.latitude, s.longitude)).toList(),
//       );
//       _mapController.fitCamera(
//         CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(15)),
//       );
//     } else {
//       _mapController.move(
//         LatLng(widget.spots[0].latitude, widget.spots[0].longitude),
//         15,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Initial center point
//     LatLng center = const LatLng(0, 0);
//     double initialZoom = 2.0;
//     CameraFit? cameraFit;

//     if (widget.spots.isNotEmpty) {
//       center = LatLng(widget.spots[0].latitude, widget.spots[0].longitude);
//       initialZoom = 15.0; // Slightly less zoomed in

//       if (widget.spots.length > 1) {
//         final bounds = LatLngBounds.fromPoints(
//           widget.spots.map((s) => LatLng(s.latitude, s.longitude)).toList(),
//         );
//         cameraFit = CameraFit.bounds(
//           bounds: bounds,
//           padding: const EdgeInsets.all(15), // Very tight padding
//         );
//       }
//     }

//     return Container(
//       height: widget.height,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: const Color(0xFFF0F0F0), // Map-like background color
//         borderRadius: BorderRadius.circular(widget.borderRadius),
//         border: Border.all(color: AppColors.white, width: 2),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(widget.borderRadius - 2),
//         child: Stack(
//           children: [
//             FlutterMap(
//               mapController: _mapController,
//               options: MapOptions(
//                 initialCenter: center,
//                 initialZoom: initialZoom,
//                 initialCameraFit: cameraFit,
//                 minZoom: 2,
//                 maxZoom: 18,
//                 interactionOptions: const InteractionOptions(
//                   flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
//                 ),
//               ),

//               children: [
//                 TileLayer(
//                   urlTemplate:
//                       'https://api.mapbox.com/styles/v1/mapbox/{styleId}/tiles/{z}/{x}/{y}?access_token={accessToken}',
//                   additionalOptions: {
//                     'styleId': 'streets-v12',
//                     'accessToken': mapBoxKey,
//                   },
//                   retinaMode: RetinaMode.isHighDensity(context),
//                   userAgentPackageName: 'com.noviindus.voyaj',
//                   tileDisplay: const TileDisplay.fadeIn(
//                     duration: Duration(milliseconds: 300),
//                   ),
//                 ),

//                 // if (widget.spots.length > 1)
//                 //   PolylineLayer(
//                 //     polylines: [
//                 //       Polyline(
//                 //         points: widget.spots
//                 //             .map((s) => LatLng(s.latitude, s.longitude))
//                 //             .toList(),
//                 //         color: AppColors.primary.withValues(alpha: 0.7),
//                 //         strokeWidth: 4,
//                 //         // isDotted: true,
//                 //       ),
//                 //     ],
//                 //   ),
//                 MarkerLayer(
//                   markers: widget.spots.map((spot) {
//                     return Marker(
//                       point: LatLng(spot.latitude, spot.longitude),
//                       width: 40,
//                       height: 40,
//                       child: _buildMarkerWidget(spot),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),

//             if (widget.showControls) ...[
//               // Zoom Controls
//               Positioned(
//                 left: 10,
//                 bottom: 10,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.1),
//                         blurRadius: 4,
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       _MapActionButton(
//                         icon: Icons.add,
//                         onTap: () {
//                           final zoom = _mapController.camera.zoom + 1;
//                           _mapController.move(
//                             _mapController.camera.center,
//                             zoom,
//                           );
//                         },
//                       ),
//                       Container(
//                         height: 1,
//                         width: 20,
//                         color: Colors.grey.shade200,
//                       ),
//                       _MapActionButton(
//                         icon: Icons.remove,
//                         onTap: () {
//                           final zoom = _mapController.camera.zoom - 1;
//                           _mapController.move(
//                             _mapController.camera.center,
//                             zoom,
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Expand Control
//               // Positioned(
//               //   right: 10,
//               //   top: 10,
//               //   child: _MapActionButton(
//               //     icon: Icons.open_in_full_rounded,
//               //     isCircular: true,
//               //     onTap: widget.onExpand,
//               //   ),
//               // ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMarkerWidget(MapSpot spot) {
//     final hasImage = spot.imageUrl != null && spot.imageUrl!.isNotEmpty;

//     if (hasImage && !spot.usePointer) {
//       return Center(
//         child: Container(
//           width: 52,
//           height: 52,
//           padding: const EdgeInsets.all(2),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.15),
//                 blurRadius: 10,
//                 spreadRadius: 1,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: AppImageView(
//               spot.imageUrl!,
//               width: 50,
//               height: 50,
//               fit: BoxFit.cover,
//             ),
//           ),
//         ),
//       );
//     } else {
//       return Center(
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Icon(Icons.location_on, color: AppColors.primary, size: 32),
//             Positioned(
//               top: 5,
//               child: Container(
//                 width: 10,
//                 height: 10,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//   }
// }

// class _MapActionButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   final bool isCircular;

//   const _MapActionButton({
//     required this.icon,
//     this.onTap,
//     this.isCircular = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
//           borderRadius: isCircular ? null : BorderRadius.circular(12),
//           boxShadow: isCircular
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.1),
//                     blurRadius: 4,
//                   ),
//                 ]
//               : null,
//         ),
//         child: Icon(icon, color: Colors.black, size: 20),
//       ),
//     );
//   }
// }
