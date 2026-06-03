import 'package:flutter/material.dart';
import 'package:user/features/admission/pages/admission_form_screen.dart';

class AdmissionSupportScreen extends StatelessWidget {
  const AdmissionSupportScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F8FF),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff0057FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdmissionFormScreen()));
            },

            child: const Text(
              "Request Admission",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= HEADER =================

                Row(
                  children: [


                    const Expanded(
                      child: Center(
                        child: Text(
                          "Admission",
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff13234B),
                          ),
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
                    "assets/hospital.png",
                    width: double.infinity,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 26),

                // ================= SERVICES =================

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
                    ),

                    _serviceTile(
                      Icons.calendar_month,
                      "Planned Admission",
                      Colors.blue,
                    ),

                    _serviceTile(
                      Icons.search,
                      "Find Hospital",
                      Colors.green,
                    ),

                    _serviceTile(
                      Icons.location_on,
                      "Track Admission",
                      Colors.orange,
                    ),
                  ],
                ),

                // ================= TITLE =================
              SizedBox(height: 20,),
                const Text(
                  "Why Choose MedRayder?",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff13234B),
                  ),
                ),

                const SizedBox(height: 18),

                // ================= BENEFITS =================

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 100,
                  children: [

                    _serviceTile(
                      Icons.local_hospital,
                      "Hospital Selection",
                      const Color(0xff0057FF),
                    ),

                    _serviceTile(
                      Icons.admin_panel_settings,
                      "Admission Coordination",
                      Colors.purple,
                    ),

                    _serviceTile(
                      Icons.currency_rupee,
                      "Cost Estimation",
                      Colors.green,
                    ),

                    _serviceTile(
                      Icons.meeting_room,
                      "Room Availability",
                      Colors.orange,
                    ),

                    _serviceTile(
                      Icons.health_and_safety,
                      "Insurance Guide",
                      Colors.redAccent,
                    ),

                    _serviceTile(
                      Icons.support_agent,
                      "24×7 Support",
                      Colors.teal,
                    ),
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

  Widget _serviceTile(
      IconData icon,
      String title,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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

          // ICON
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
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
    );
  }
}