import 'package:flutter/material.dart';

class YearPickerHome extends StatefulWidget {
  final int? selectedYear;
  final void Function(int) onSelectYear;
  const YearPickerHome(
      {super.key, this.selectedYear, required this.onSelectYear});

  @override
  _YearPickerHomeState createState() => _YearPickerHomeState();
}

class _YearPickerHomeState extends State<YearPickerHome> {
  int? selectedYear;
  final int startYear = 2000;
  final int endYear = 2100;
  @override
  void initState() {
    selectedYear = widget.selectedYear;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select a Year',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: endYear - startYear + 1,
              itemBuilder: (context, index) {
                final year = startYear + index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedYear = year;
                    });
                    widget.onSelectYear(year);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedYear == year
                          ? Colors.white
                          : const Color(0xff1e1e1e),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      year.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            selectedYear == year ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
