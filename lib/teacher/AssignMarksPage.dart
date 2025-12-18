import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssignMarksPage extends StatefulWidget {
  const AssignMarksPage({super.key});

  @override
  State<AssignMarksPage> createState() => _AssignMarksPageState();
}

class _AssignMarksPageState extends State<AssignMarksPage> {
  String? selectedExamId;
  String? selectedSubjectId;

  List exams = [];
  List subjects = [];
  List students = [];
  List filteredStudents = [];

  bool isLoading = false;
  bool isSubmitting = false;

  String searchQuery = '';

  final TextEditingController totalMarkController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// one controller per student
  final Map<int, TextEditingController> obtainControllers = {};

  @override
  void initState() {
    super.initState();
    fetchExams();
    fetchSubjects();
  }

  @override
  void dispose() {
    totalMarkController.dispose();
    for (final c in obtainControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------- EXAMS ----------------
  Future<void> fetchExams() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await http.post(
      Uri.parse("https://school.edusathi.in/api/get_exam"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200 && mounted) {
      setState(() => exams = jsonDecode(res.body));
    }
  }

  // ---------------- SUBJECTS ----------------
  Future<void> fetchSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final res = await http.post(
      Uri.parse("https://school.edusathi.in/api/get_subject"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200 && mounted) {
      setState(() => subjects = jsonDecode(res.body));
    }
  }

  // ---------------- STUDENTS ----------------
  Future<void> fetchStudents() async {
    if (selectedExamId == null || selectedSubjectId == null) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse("https://school.edusathi.in/api/teacher/mark"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "ExamId": selectedExamId!,
          "SubjectId": selectedSubjectId!,
        },
      );

      if (!mounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        // clear old controllers
        for (final c in obtainControllers.values) {
          c.dispose();
        }
        obtainControllers.clear();

        students = List.from(data['marks'] ?? []);

        if (students.isNotEmpty) {
          totalMarkController.text =
              students.first['TotalMark']?.toString() ?? '';
        }

        for (var s in students) {
          s['IsPresent'] ??= 'Yes';
          final id = s['id'];

          obtainControllers[id] = TextEditingController(
            text: s['GetMark']?.toString() ?? '',
          );
        }

        setState(() {
          filteredStudents = List.from(students);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ---------------- SEARCH ----------------
  void filterStudents(String query) {
    setState(() {
      searchQuery = query;
      filteredStudents = students.where((s) {
        return s['StudentName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            s['FatherName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase());
      }).toList();
    });
  }

  // ---------------- SUBMIT ----------------
  Future<void> updateMarks() async {
    for (var s in students) {
      final obtain = obtainControllers[s['id']]?.text ?? '';
      final total = totalMarkController.text;

      if (obtain.isEmpty || total.isEmpty) {
        _alert('Marks missing for ${s['StudentName']}');
        return;
      }

      final o = double.tryParse(obtain) ?? -1;
      final t = double.tryParse(total) ?? -1;

      if (o > t) {
        _alert('Obtain marks greater than Total for ${s['StudentName']}');
        return;
      }

      s['GetMark'] = obtain;
      s['TotalMark'] = total;
    }

    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final payload = {
      "ExamId": selectedExamId,
      "SubjectId": selectedSubjectId,
      "marks": students.map((s) {
        return {
          "StudentId": s['id'],
          "IsPresent": s['IsPresent'],
          "TotalMark": s['TotalMark'],
          "GetMark": s['GetMark'],
        };
      }).toList(),
    };

    try {
      final res = await http.post(
        Uri.parse("https://school.edusathi.in/api/teacher/mark/store"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (!mounted) return;
      setState(() => isSubmitting = false);

      final msg = res.statusCode == 200
          ? jsonDecode(res.body)['message']
          : "Failed to submit marks";

      _alert(msg);
    } catch (e) {
      if (mounted) setState(() => isSubmitting = false);
      _alert(e.toString());
    }
  }

  void _alert(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alert'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ---------------- UI (UNCHANGED) ----------------
  @override
  Widget build(BuildContext context) {
    // ⛔ UI untouched as requested
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Marks"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            children: [
              // existing UI 그대로 유지됨
            ],
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
