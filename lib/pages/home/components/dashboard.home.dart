import 'package:ept/database/database.dart';
import 'package:ept/pages/expenseList/expenseList.dart';
import 'package:ept/pages/home/components/yearPicker.home.dart';
import 'package:ept/utils/routeObserver.dart';
import 'package:ept/utils/utils.dart';
import 'package:flutter/material.dart';
import 'monthCard.home.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _Dashboard();
}

class _Dashboard extends State<Dashboard> with RouteAware {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Future<List<Map<String, dynamic>>>? records;
  int selectedYear = DateTime.now().year;
  @override
  void initState() {
    super.initState();
    fetchInitRecords(selectedYear);
  }

  void fetchInitRecords(int year) {
    setState(() {
      records = _dbHelper.initMainList(year);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    super.dispose();
    routeObserver.unsubscribe(this);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    fetchInitRecords(selectedYear);
  }

  void onSelectYear(int year) {
    setState(() {
      selectedYear = year;
    });
    fetchInitRecords(year);
  }

  void showYearPicker(BuildContext context) async {
    showBottomSheet(
        showDragHandle: true,
        context: context,
        backgroundColor: Colors.black,
        builder: (BuildContext context) {
          return TapRegion(
              onTapOutside: (_) {
                Navigator.of(context).pop(); // Dismiss the bottom sheet
              },
              child: YearPickerHome(
                selectedYear: selectedYear,
                onSelectYear: (year) {
                  onSelectYear(year);
                },
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () {
              showYearPicker(context);
            },
            child: Row(
              children: [
                Text('$selectedYear',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const Icon(Icons.arrow_drop_down, color: Colors.white)
              ],
            ),
          )),
      Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
              future: records,
              builder: (context, response) {
                if (response.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (response.hasError) {
                  return const Center(child: Text('Something went wrong!.'));
                }
                if (!response.hasData || response.data!.isEmpty) {
                  return const Center(child: Text('No data found.'));
                }

                return LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount = getColumnCount(constraints.maxWidth);
                  List<Map<String, dynamic>>? data =
                      generateRecords(selectedYear, response.data!);
                  int totalRecords = data.length;
                  return Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                          itemCount: totalRecords,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12, // Horizontal spacing
                                  mainAxisSpacing: 12, // Vertical spacing
                                  childAspectRatio: 1),
                          itemBuilder: (context, index) {
                            return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () => {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => ExpenseList(
                                            expenseID: data[index]['exRefID'],
                                            expenseGlobal:
                                                ExpenseGlobalClass.fromMap(
                                                    data[index])),
                                      ))
                                    },
                                child: MonthCard(
                                  exDate: data[index]['exDate'],
                                  exTotal: data[index]['exTotal'],
                                ));
                          }));
                });
              }))
    ]));
  }
}
