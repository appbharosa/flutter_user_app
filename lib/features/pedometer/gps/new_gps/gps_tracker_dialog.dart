import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'gps_bloc.dart';

class GpsTrackerDialog extends StatelessWidget {
  const GpsTrackerDialog({super.key});

  String formatDistance(double meters) {
    if (meters < 1000) {
      return "${meters.toStringAsFixed(0)} m";
    } else {
      return "${(meters / 1000).toStringAsFixed(2)} km";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            if (state is GpsTracking) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ICON
                  const Icon(Icons.directions_walk,
                      size: 50, color: Colors.blue),

                  const SizedBox(height: 10),

                  /// TITLE
                  const Text(
                    "Tracking Distance",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  /// DISTANCE CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text("Distance",
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text(
                          formatDistance(state.distanceMeters),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// LOCATION INFO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoBox("LAT", state.lat),
                      _infoBox("LON", state.lon),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// STOP BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<GpsBloc>().add(StopTracking());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Stop Tracking",style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              );
            }

            if (state is GpsError) {
              return Text("❌ ${state.message}");
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text("Getting GPS signal..."),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoBox(String label, double value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value.toStringAsFixed(5),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}