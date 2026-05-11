import 'package:flutter/material.dart';



class BillingDetailsScreen extends StatelessWidget {
  final VoidCallback onBackToHome;

  const BillingDetailsScreen({
    super.key,
    required this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Billing Receipt"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt Header
            _buildReceiptHeader(),

            const SizedBox(height: 20),

            // Receipt Body (Items, Totals, etc.)
            _buildReceiptBody(),

            const SizedBox(height: 20),

            // Footer (Thank You, Contact Info)
            _buildReceiptFooter(),

            const SizedBox(height: 20),

            // Back Button
            ElevatedButton(
              onPressed: onBackToHome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pharmacy Logo and Name
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_pharmacy, size: 40, color: Colors.blue),
                SizedBox(width: 10),
                Text(
                  "MedLife Pharmacy",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 10),
            // Receipt Title
            const Text(
              "OFFICIAL RECEIPT",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Order Details
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: const [
                TableRow(
                  children: [
                    Text("Order ID:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("ORD12345"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Date:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("08 May 2026"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Time:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("10:30 AM"),
                  ],
                ),
                TableRow(
                  children: [
                    Text("Patient:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("John Doe"),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptBody() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Items Table Header
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Item",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Qty",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Price",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(height: 10, color: Colors.grey),
            const SizedBox(height: 5),

            // Items List
            _buildItemRow("Paracetamol 500mg", "10", "₹50.00"),
            _buildItemRow("Amoxicillin 250mg", "5", "₹120.00"),
            _buildItemRow("Vitamin C Tablets", "30", "₹90.00"),
            _buildItemRow("Cough Syrup 100ml", "1", "₹85.00"),

            const Divider(height: 10, color: Colors.grey),
            const SizedBox(height: 10),

            // Totals
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Subtotal",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "₹345.00",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text("Discount"),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "-₹20.00",
                    style: TextStyle(color: Colors.green),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Tax (5%)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "₹16.25",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Colors.black),
            const SizedBox(height: 10),
            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "TOTAL",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "₹341.25",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(String itemName, String quantity, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(itemName),
          ),
          Expanded(
            flex: 1,
            child: Text(
              quantity,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              price,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptFooter() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Thank you for shopping with us!",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "For any queries, contact:",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              "📞 +91 98765 43210",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const Text(
              "📧 medlife@pharmacy.com",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              "MedLife Pharmacy\n123 Health Street, City - 560001",
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}