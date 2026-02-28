import 'package:flutter/material.dart';

typedef ItemTapCallback = void Function(String item, BuildContext context);

class ScanList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final IconData icon;
  final Function(Map<String, dynamic> item, BuildContext context)? onTap;
  final bool disableLoading;

  const ScanList(
      {required this.items,
      required this.icon,
      Key? key,
      this.onTap,
      this.disableLoading = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double sizeHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, i) {
          return Container(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.black,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    icon,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
                title: Text(
                  items[i]['name'] ?? items[i]['ssid'],
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
                onTap: () {
                  if (onTap != null) {
                    onTap!(items[i], context);
                  }
                },
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(
          height: sizeHeight * 0.01,
        ),
      ),
    );
  }
}
