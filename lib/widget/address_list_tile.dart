import 'package:flutter/material.dart';

class AddressListTile extends StatelessWidget {
  const AddressListTile({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: -10.0),
      minTileHeight: 50.0,
      title: Align(alignment: Alignment.centerLeft, child: Text(address)),
      onTap: () {},
    );
  }
}
