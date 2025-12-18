import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TeacherComplaintPage extends StatefulWidget {
  final int complaintId;
  final String date;
  final String description;
  final int status;

  const TeacherComplaintPage({
    super.key,
    required this.complaintId,
    required this.date,
    required this.description,
    required this.status,
  });

  @override
  State<TeacherComplaintPage> createState() => _TeacherComplaintPageState();
}

class _TeacherComplaintPageState extends State<TeacherComplaintPage> {
  List<dynamic> complaintHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchComplaintHistory();
  }

  // ---------------- FETCH HISTORY ----------------
  Future<void> fetchComplaintHistory() async {
    try {
      if (mounted) setState(() => isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          complaintHistory = [];
          isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse(
          'https://school.edusathi.in/api/teacher/complaint/history',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ComplaintId': widget.complaintId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);
        setState(() {
          complaintHistory = decoded is List ? decoded : [];
          isLoading = false;
        });
      } else {
        setState(() {
          complaintHistory = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        complaintHistory = [];
        isLoading = false;
      });
    }
  }

  // ---------------- STATUS BADGE ----------------
  Widget getStatusBadge(int status) {
    String text;
    Color color;

    switch (status) {
      case 0:
        text = 'Pending';
        color = Colors.orange;
        break;
      case 1:
        text = 'Resolved';
        color = Colors.green;
        break;
      default:
        text = 'Unknown';
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complaint Details"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔷 Complaint Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepPurple.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "📅 ${widget.date}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description.replaceAll(r'\r\n', '\n'),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        getStatusBadge(widget.status),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Complaint History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (complaintHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text("No history available")),
                    )
                  else
                    ...complaintHistory.map((entry) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "📅 ${entry['Date'] ?? ''}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry['Description']
                                        ?.replaceAll(
                                            r'\r\n', '\n') ??
                                    '',
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
    );
  }
}
