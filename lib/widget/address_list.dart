import 'package:flutter/material.dart';

class AddressList extends StatelessWidget {
  const AddressList({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        height: 40.0,
        child: Align(alignment: Alignment.centerLeft, child: Text(address)),
      ),
    );
  }
}
