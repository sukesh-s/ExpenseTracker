import 'package:ept/utils/localize.dart';
import 'package:ept/utils/utils.dart';
import 'package:flutter/material.dart';

class ExpenseListGroup extends StatelessWidget {
  final Map<String, dynamic> records;
  final void Function(ExpenseClass params) onSelectList;
  final void Function(ExpenseClass params) onDelete;
  const ExpenseListGroup(
      {super.key,
      required this.records,
      required this.onSelectList,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(records['week'] as String,
                style: const TextStyle(
                  color: Colors.white70,
                )),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                color: const Color(0xff1e1e1e),
                borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...records['data'].map<Widget>((record) {
                    int index = records['data'].indexOf(record);
                    return Column(
                      children: [
                        Dismissible(
                            background: Container(
                                alignment: Alignment.centerRight,
                                child: const Icon(Icons.delete,
                                    color: Colors.redAccent)),
                            direction: DismissDirection.endToStart,
                            key: ValueKey(index),
                            confirmDismiss: (direction) async {
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xff1e1e1e),
                                    title: const Text('Confirm',
                                        style: TextStyle(color: Colors.white)),
                                    content: Text(
                                        getLocalizedString(
                                            'delete_confirmation'),
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text(
                                            getLocalizedString(
                                                'delete_confirmation_cancel'),
                                            style: const TextStyle(
                                                color: Colors.greenAccent)),
                                      ),
                                      TextButton(
                                        onPressed: () => {
                                          Navigator.of(context).pop(true),
                                          onDelete(
                                            ExpenseClass(
                                                elAmount:
                                                    record['elAmount'] as int,
                                                elLastUpdate:
                                                    record['elLastUpdate']
                                                        as String,
                                                elRefId:
                                                    record['elRefId'] as String,
                                                elComment: record['elComment']
                                                    as String,
                                                elID: record['elID'] as int),
                                          )
                                        },
                                        child: Text(
                                            getLocalizedString(
                                                'delete_confirmation_yes'),
                                            style: const TextStyle(
                                                color: Colors.redAccent)),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return result ?? false;
                            },
                            onDismissed: (direction) => {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Record ${record['elComment']} deleted'))),
                                },
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: InkWell(
                                    onTap: () => {
                                          onSelectList(
                                            ExpenseClass(
                                                elAmount:
                                                    record['elAmount'] as int,
                                                elLastUpdate:
                                                    record['elLastUpdate']
                                                        as String,
                                                elRefId:
                                                    record['elRefId'] as String,
                                                elComment: record['elComment']
                                                    as String,
                                                elID: record['elID'] as int,
                                                elCategory: record['elCategory']
                                                    as String),
                                          )
                                        },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                            child: Text(
                                                record['elComment'] as String,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ))),
                                        Text(formatPrice(record['elAmount']),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ))
                                      ],
                                    )))),
                        if (index != records['data'].length - 1)
                          const Divider(
                            thickness: 0.3,
                          )
                        else
                          const Divider(
                            thickness: 0.4,
                          )
                      ],
                    );
                  }).toList(),
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('₹${formatPrice(records['total'])}',
                              style: const TextStyle(color: Colors.greenAccent))
                        ],
                      ))
                ],
              ),
            ),
          )
        ]));
  }
}
