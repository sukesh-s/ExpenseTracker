import 'package:ept/utils/utils.dart';
import 'package:flutter/material.dart';

enum UIType { primary, secondary }

class MonthCard extends StatelessWidget {
  final UIType type;
  final String? exDate;
  final int? exTotal;
  final String? exLastUpdate;

  const MonthCard(
      {super.key,
      this.type = UIType.primary,
      this.exDate,
      this.exTotal,
      this.exLastUpdate});

  @override
  Widget build(BuildContext context) {
    final Map<String, String> formattedPrice = formatNumber(exTotal!);
    return Container(
        decoration: BoxDecoration(
            color: const Color(0xff1e1e1e),
            borderRadius: BorderRadius.circular(10)),
        child: Padding(
            padding: const EdgeInsets.all(8),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatMonth(exDate!),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300)),
                  Text('₹',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[700],
                          fontWeight: FontWeight.w300))
                ],
              ),
              Text(formatDate(exDate!),
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                      flex: 1,
                      child: Text('${formattedPrice['value']}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.justify)),
                  Flexible(
                      flex: 0,
                      child: Text(
                        '${formattedPrice['notation']}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xff4a4a4a),
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.justify,
                      )),
                ],
              )
            ])));
  }
}
