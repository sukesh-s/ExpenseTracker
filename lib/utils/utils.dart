import 'dart:ui';

import 'package:intl/intl.dart';

Map<String, String> formatNumber(int? number) {
  if (number == null || number == 0) {
    return {
      'value': '0',
      'notation': '',
    };
  }
  if (number < 10000) {
    return {
      'value': number.toString(),
      'notation': '',
    };
  } else if (number < 1000000) {
    return {
      'value': (number / 1000).toStringAsFixed(number % 1000 == 0 ? 0 : 1),
      'notation': 'K',
    };
  } else if (number < 1000000000) {
    return {
      'value':
          (number / 1000000).toStringAsFixed(number % 1000000 == 0 ? 0 : 1),
      'notation': 'M',
    };
  } else {
    return {
      'value': (number / 1000000000)
          .toStringAsFixed(number % 1000000000 == 0 ? 0 : 1),
      'notation': 'B',
    };
  }
}

/// only for expense_global
String formatDate(String date) {
  DateTime parsedDate = DateFormat('MM/yyyy').parse(date);
  String formattedDate = DateFormat('yy').format(parsedDate);
  return formattedDate;
}

/// only for expense_global
String formatMonth(String date) {
  DateTime parsedDate = DateFormat('MM/yyyy').parse(date);
  String formattedDate = DateFormat('MMMM').format(parsedDate);
  return formattedDate;
}

String formatDateTime(String date) {
  if (date.isEmpty) return '-';
  try {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd').format(parsedDate);
  } catch (e) {
    return '-';
  }
}

class ExpenseClass {
  final int elAmount;
  final String elLastUpdate;
  final String elRefId;
  final String? elComment;
  final int? elID;
  final String? elCategory;

  ExpenseClass({
    required this.elAmount,
    required this.elLastUpdate,
    required this.elRefId,
    this.elID,
    this.elComment,
    this.elCategory,
  });

  Map<String, dynamic> toMap() {
    return {
      'elAmount': elAmount,
      'elLastUpdate': elLastUpdate,
      'elRefId': elRefId,
      'elComment': elComment,
      'elID': elID,
      'elCategory': elCategory,
    };
  }

  factory ExpenseClass.fromMap(Map<String, dynamic> map) {
    return ExpenseClass(
      elAmount: map['elAmount'],
      elLastUpdate: map['elLastUpdate'],
      elRefId: map['elRefId'],
      elComment: map['elComment'],
      elID: map['elID'],
      elCategory: map['elCategory'],
    );
  }
}

class ExpenseGlobalClass {
  final int? exId;
  final String? exDate;
  final int? exTotal;
  final String? exLastUpdate;
  final String? exYear;
  final String? exRefID;

  ExpenseGlobalClass({
    this.exId,
    this.exDate,
    this.exTotal,
    this.exLastUpdate,
    this.exYear,
    this.exRefID,
  });

  Map<String, dynamic> toMap() {
    return {
      'exId': exId,
      'exDate': exDate,
      'exTotal': exTotal,
      'exLastUpdate': exLastUpdate,
      'exYear': exYear,
      'exRefID': exRefID,
    };
  }

  factory ExpenseGlobalClass.fromMap(Map<String, dynamic> map) {
    return ExpenseGlobalClass(
      exId: map['exId'],
      exDate: map['exDate'],
      exTotal: map['exTotal'],
      exLastUpdate: map['exLastUpdate'],
      exYear: map['exYear'],
      exRefID: map['exRefID'],
    );
  }
}

enum FormActionType {
  add,
  update,
  delete,
}

List<Map<String, dynamic>> groupByWeek(List<ExpenseClass> expenses) {
  final DateFormat weekFormatter = DateFormat("yyyy-'W'ww");
  final Map<String, List<Map<String, dynamic>>> groupedData = {};
  final List<Map<String, dynamic>> result = [];
  for (var eachExpense in expenses) {
    final DateTime parsedDate = DateTime.parse(eachExpense.elLastUpdate);
    final String formattedDate = weekFormatter.format(parsedDate);
    if (groupedData.containsKey(formattedDate)) {
      groupedData[formattedDate]!.add(eachExpense.toMap());
    } else {
      groupedData[formattedDate] = [eachExpense.toMap()];
    }
  }

  int weekCounter = 1;
  groupedData.forEach((key, value) {
    result.add({
      'week': 'Week $weekCounter',
      'total': value.fold<int>(
          0,
          (previousValue, element) =>
              previousValue + (element['elAmount'] as int)),
      'data': value,
    });
    weekCounter++;
  });
  return result;
}

const List<Color> cardColors = [
  Color(0xFFFFCDD2), // Red[100]
  Color(0xFFF8BBD0), // Pink[100]
  Color(0xFFE1BEE7), // Purple[100]
  Color(0xFFD1C4E9), // Deep Purple[100]
  Color(0xFFC5CAE9), // Indigo[100]
  Color(0xFFBBDEFB), // Blue[100]
  Color(0xFFB3E5FC), // Light Blue[100]
  Color(0xFFB2EBF2), // Cyan[100]
  Color(0xFFB2DFDB), // Teal[100]
  Color(0xFFC8E6C9), // Green[100]
  Color(0xFFFFECB3), // Amber[100]
  Color(0xFFFFE0B2), // Orange[100]
];

String formatPrice(int number) {
  final formatter = NumberFormat.decimalPattern(); // Adds commas
  return formatter.format(number);
}

int getColumnCount(double maxWidth) {
  if (maxWidth < 600) {
    return 3; // Small screens (phones)
  } else if (maxWidth < 900) {
    return 6; // Medium screens (tablets)
  } else {
    return 9; // Large screens
  }
}

List<Map<String, dynamic>> generateRecords(
    int? year, List<Map<String, dynamic>> records) {
  // var year0 = year!.isEmpty ? DateTime.now().year : year;
  Object year0 =
      year == null || year == 0 ? DateTime.now().year : year.toString();

  List<Map<String, dynamic>> result = [];
  for (var i = 1; i <= 12; i++) {
    final String month = i.toString().padLeft(2, '0');
    final String date = '$month/$year0';
    final record = records.firstWhere((element) => element['exDate'] == date,
        orElse: () => {
              'exId': null,
              'exDate': date,
              'exTotal': 0,
              'exLastUpdate': DateTime.now().toString(),
              'exYear': year0,
              'exRefID': date,
            });
    result.add(record);
  }
  int currentMonth = DateTime.now().month;

  // Sort by month with current month first
  result.sort((a, b) {
    int monthA = int.parse(a['exDate'].split('/')[0]);
    int monthB = int.parse(b['exDate'].split('/')[0]);

    // Adjust sorting to start with the current month
    int adjustedA = (monthA - currentMonth + 12) % 12;
    int adjustedB = (monthB - currentMonth + 12) % 12;

    return adjustedA.compareTo(adjustedB);
  });
  return result;
}

final List<Map<String, String>> expenseCategories = [
  {"key": "housing", "value": "Housing"},
  {"key": "food_groceries", "value": "Food & Groceries"},
  {"key": "transportation", "value": "Transportation"},
  {"key": "health_fitness", "value": "Health & Fitness"},
  {"key": "entertainment", "value": "Entertainment"},
  {"key": "education", "value": "Education"},
  {"key": "personal_care", "value": "Personal Care"},
  {"key": "financial_obligations", "value": "Financial Obligations"},
  {"key": "travel", "value": "Travel"},
  {"key": "kids_family", "value": "Kids & Family"},
  {"key": "pets", "value": "Pets"},
  {"key": "technology", "value": "Technology"},
  {"key": "gifts_donations", "value": "Gifts & Donations"},
  {"key": "miscellaneous", "value": "Miscellaneous"},
  {"key": "insurance", "value": "Insurance"},
];

String getUniqueId(String year) {
  return 'global_$year';
}
