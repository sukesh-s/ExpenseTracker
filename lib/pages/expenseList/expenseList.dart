import 'package:ept/database/database.dart';
import 'package:ept/pages/expenseList/components/expenseDropDown.dart';
import 'package:ept/pages/expenseList/components/expenseListGroup.dart';
import 'package:ept/utils/localize.dart';
import 'package:ept/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';

class ExpenseList extends StatefulWidget {
  final String expenseID;
  final ExpenseGlobalClass? expenseGlobal;
  const ExpenseList({super.key, required this.expenseID, this.expenseGlobal});

  @override
  State<ExpenseList> createState() => _ExpenseList();
}

class _ExpenseList extends State<ExpenseList> {
  final _db = DatabaseHelper();
  Future<List<Map<String, dynamic>>>? expenseRecords;
  String? selectedCategory;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController amount = TextEditingController();
  final TextEditingController comments = TextEditingController();

  @override
  void initState() {
    fetchInitRecords();
    super.initState();
  }

  void fetchInitRecords() {
    setState(() {
      expenseRecords = _db.getExpenseList(widget.expenseID);
    });
  }

  void submitExpenseForm(BuildContext context, FormActionType actionType,
      ExpenseClass? expenseEditParams) async {
    if (_formKey.currentState!.validate()) {
      String comment = comments.text;
      int totalAmount = int.parse(amount.text);
      final params = ExpenseClass(
          elAmount: totalAmount,
          elLastUpdate: DateTime.now().toString(),
          elRefId: widget.expenseID,
          elComment: comment,
          elID: expenseEditParams?.elID,
          elCategory: selectedCategory);
      Navigator.pop(context);
      _formKey.currentState!.reset();
      amount.clear();
      comments.clear();
      setState(() {
        selectedCategory = null;
      });
      upsertDetails(actionType, params);
    }
  }

  void upsertDetails(FormActionType actionType, ExpenseClass expense) async {
    try {
      await _db.upsertExpenseList(actionType, expense);
      fetchInitRecords();
      _db.updateExpenseGlobalTotalAmount(widget.expenseID);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(actionType == FormActionType.add
                ? getLocalizedString('expense_added')
                : actionType == FormActionType.update
                    ? getLocalizedString('expense_updated')
                    : getLocalizedString('expense_deleted'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  openBottomSheet(
      BuildContext context, FormActionType actionType, ExpenseClass? expense) {
    showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        context: context,
        isDismissible: true,
        enableDrag: true,
        backgroundColor: Colors.black,
        builder: (context) {
          return KeyboardAvoider(
              child: SingleChildScrollView(
            child: SizedBox(
              height: 400,
              child: Form(
                key: _formKey,
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: amount,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            labelText: getLocalizedString('form_label_amount'),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return getLocalizedString(
                                  'form_error_amount_empty');
                            }
                            final amount = int.tryParse(value);
                            if (amount == null || amount <= 0) {
                              return getLocalizedString(
                                  'form_error_amount_invalid');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ExpenseDropdown(
                          initialValue: selectedCategory,
                          items: expenseCategories,
                          labelText: getLocalizedString('form_label_category'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return getLocalizedString(
                                  'form_error_category_empty');
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: comments,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                          decoration: InputDecoration(
                              labelText:
                                  getLocalizedString('form_label_comments')),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return getLocalizedString(
                                  'form_error_comments_empty');
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              submitExpenseForm(context, actionType, expense),
                          child: Text(actionType == FormActionType.add
                              ? getLocalizedString('form_button_add')
                              : getLocalizedString('form_button_update')),
                        ),
                      ],
                    )),
              ),
            ),
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          getLocalizedString('expenseListTitle'),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: expenseRecords,
        builder: (context, response) {
          final ConnectionState waitingStatus = response.connectionState;
          bool hasError = response.hasError;
          bool hasNoData = !response.hasData ||
              response.data == null ||
              response.data!.isEmpty;

          // Show loading, error, or empty states
          if (waitingStatus == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (hasError) {
            return Center(
              child: Text(
                getLocalizedString('something_went_wrong'),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (hasNoData) {
            return Center(
              child: Text(
                getLocalizedString('no_expense_found'),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          // Safely process data only when it is available
          final expenseList =
              response.data!.map((map) => ExpenseClass.fromMap(map)).toList();
          var groupByWeek2 = groupByWeek(expenseList);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: groupByWeek2.length,
                  itemBuilder: (context, index) {
                    final record = groupByWeek2[index];
                    return ExpenseListGroup(
                      records: record,
                      onSelectList: (ExpenseClass params) {
                        amount.text = params.elAmount.toString();
                        comments.text = params.elComment ?? '';
                        setState(() {
                          selectedCategory = params.elCategory;
                        });
                        Future.delayed(Duration.zero, () {
                          openBottomSheet(
                              context, FormActionType.update, params);
                        });
                      },
                      onDelete: (ExpenseClass params) {
                        upsertDetails(FormActionType.delete, params);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white70,
        onPressed: () {
          openBottomSheet(context, FormActionType.add, null);
        },
        child: const Icon(Icons.add),
      ),
    ));
  }
}
