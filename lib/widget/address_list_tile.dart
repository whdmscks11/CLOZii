import 'package:carrot_login/widget/terms_and_conditions.dart';
import 'package:flutter/material.dart';

class AddressListTile extends StatelessWidget {
  const AddressListTile({super.key, required this.address});

  final String address;

  void _onSelectAddress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TermsAndConditions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.only(left: -10.0),
      minTileHeight: 50.0,
      title: Align(alignment: Alignment.centerLeft, child: Text(address)),
      onTap: () => _onSelectAddress(context),
    );
  }
}
