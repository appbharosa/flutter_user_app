import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user/features/admission/pages/admission_form_screen.dart';

import 'package:flutter/material.dart';
import 'package:user/features/admission/pages/admission_form_screen.dart';
import 'package:user/features/hospital/presentation/pages/hospitals_tab.dart';

import '../../../domain/entities/address.dart';



// Placeholder screens (you can replace with actual ones later)
class PlannedAdmissionScreen extends StatelessWidget {
  const PlannedAdmissionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Planned Admission')));
}
class FindHospitalScreen extends StatelessWidget {
  const FindHospitalScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Find Hospital')));
}
class TrackAdmissionScreen extends StatelessWidget {
  const TrackAdmissionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Track Admission')));
}

class AdmissionSupportScreen extends StatelessWidget {
  const AdmissionSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access global notifiers
    final searchNotifier = context.watch<ValueNotifier<String>>();
    final addressNotifier = context.watch<ValueNotifier<Address?>>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FF),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0057FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmissionFormScreen()));
            },
            child: const Text(
              "Request Admission",
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Admission",
                          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xff13234B)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 46),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    "assets/hospital.jpeg",
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 26),
                // Action tiles (with navigation)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 70,
                  children: [
                    _serviceTile(
                      Icons.emergency,
                      "Emergency",
                      Colors.red,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HospitalsTab(
                            searchNotifier: searchNotifier,
                            addressNotifier: addressNotifier,
                          ),
                        ),
                      ),
                    ),
                    _serviceTile(
                      Icons.calendar_month,
                      "Planned Admission",
                      Colors.blue,
                      // onTap: () => Navigator.push(...), // add when ready
                    ),
                    _serviceTile(
                      Icons.search,
                      "Find Hospital",
                      Colors.green,
                      // onTap: () => Navigator.push(...), // add when ready
                    ),
                    _serviceTile(
                      Icons.location_on,
                      "Track Admission",
                      Colors.orange,
                      // onTap: () => Navigator.push(...), // add when ready
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Why Choose MedRayder?",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xff13234B)),
                ),
                const SizedBox(height: 18),
                // Benefits tiles (no navigation – only information)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 100,
                  children: [
                    _serviceTile(Icons.local_hospital, "Hospital Selection", const Color(0xff0057FF)),
                    _serviceTile(Icons.admin_panel_settings, "Admission Coordination", Colors.purple),
                    _serviceTile(Icons.currency_rupee, "Cost Estimation", Colors.green),
                    _serviceTile(Icons.meeting_room, "Room Availability", Colors.orange),
                    _serviceTile(Icons.health_and_safety, "Insurance Guide", Colors.redAccent),
                    _serviceTile(Icons.support_agent, "24×7 Support", Colors.teal),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Service tile with optional onTap (null by default)
  Widget _serviceTile(
      IconData icon,
      String title,
      Color color, {
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff13234B),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}