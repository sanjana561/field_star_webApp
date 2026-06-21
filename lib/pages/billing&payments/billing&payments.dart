import 'package:field_star/component/billing_card.dart';
import 'package:field_star/component/payment_card.dart';
import 'package:field_star/navigation/primaryscaffold.dart';
import 'package:flutter/material.dart';

class Billingpayments extends StatefulWidget {
  const Billingpayments({super.key});

  @override
  State<Billingpayments> createState() => _BillingpaymentsState();
}

class _BillingpaymentsState extends State<Billingpayments> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return sidebar(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Billing & Payments",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 4, 6, 10),
                  ),
                ),
                Text(
                  "Track invoices and payment collection",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: BillingCard(
                    label: "Total Revenue (MTD)",
                    value: "₹4.2M",
                    subText: "+12.5%",
                    subTextColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BillingCard(
                    label: "Pending Payments",
                    value: "₹245K",
                    subText: "8 invoices",
                    subTextColor: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BillingCard(
                    label: "Pending Payments",
                    value: "₹245K",
                    subText: "8 invoices",
                    subTextColor: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: BillingCard(
                    label: "Pending Payments",
                    value: "₹245K",
                    subText: "8 invoices",
                    subTextColor: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E9F0), width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase().trim();
                          });
                        },
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          hintText:
                              'Search by TicketId, Customer, Equipments...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8), // Muted text token colors
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildTableHeader(),
                  const Divider(height: 1),
                  _buildTableRow(
                    "INV-2451",
                    "TCK-2451",
                    "Grand Hyatt Mumbai",
                    "₹6,962",
                    "Paid",
                    "UPI",
                    "2026-05-25",
                  ),
                  _buildTableRow(
                    "INV-2450",
                    "TCK-2450",
                    "JW Marriott Juhu",
                    "₹4,580",
                    "Paid",
                    "Cash",
                    "2026-05-25",
                  ),
                  _buildTableRow(
                    "INV-2449",
                    "TCK-2449",
                    "ITC Maratha",
                    "₹8,920",
                    "Pending",
                    "-",
                    "2026-05-24",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TransactionStatsCard(
                    title: "UPI Payments",
                    subtitle: "Digital transactions",
                    icon: Icons.qr_code,
                    iconColor: Colors.blue,
                    iconBgColor: Colors.blue.shade50,
                    metrics: [
                      {"Today:": "₹52,400"},
                      {"This Month:": "₹2.8M"},
                      {"Transactions:": "248"},
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TransactionStatsCard(
                    title: "Cash Payments",
                    subtitle: "On-site collection",
                    icon: Icons.payments_outlined,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.shade50,
                    metrics: [
                      {"Today:": "₹33,600"},
                      {"This Month:": "₹1.4M"},
                      {"Transactions:": "142"},
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TransactionStatsCard(
                    title: "Pending Collections",
                    subtitle: "Outstanding amount",
                    icon: Icons.payments_outlined,
                    iconColor: Colors.green,
                    iconBgColor: Colors.green.shade50,
                    metrics: [
                      {"Due Today:": "₹33,600"},
                      {"Total Pending:": "₹1.4M"},
                      {"Invoices:": "142"},
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: const [
          Expanded(
            flex: 2,
            child: Text(
              "INVOICE ID",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "TICKET",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              "CUSTOMER",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "AMOUNT",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "STATUS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "PAYMENT METHOD",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "DATE",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String id,
    String tck,
    String cust,
    String amt,
    String status,
    String method,
    String date,
  ) {
    final isPaid = status == 'Paid';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              id,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(tck, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(cust, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(amt, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isPaid ? Colors.green : Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(method, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            flex: 2,
            child: Text(date, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
