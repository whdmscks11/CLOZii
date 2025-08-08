import 'dart:async';

import 'package:carrot_login/data/dummydata.dart';
import 'package:carrot_login/widget/address_list_tile.dart';
import 'package:carrot_login/widget/custom_button.dart';
import 'package:carrot_login/widget/search_field.dart';
import 'package:flutter/material.dart';

class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  Timer? _debouncer;

  List<String> _filteredAddress = dummyAddress;

  void _onSearchTextTyped(String text) {
    setState(() {
      if (_debouncer?.isActive ?? false) _debouncer?.cancel();

      _debouncer = Timer(const Duration(milliseconds: 500), () {
        // 실제 검색/필터링 로직
        _filterAddress(text);
      });
    });
  }

  void _filterAddress(String text) {
    setState(() {
      _filteredAddress = dummyAddress
          .where((addr) => addr.contains(text))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: SearchField(onchanged: _onSearchTextTyped)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CustomButton(
              icon: Icons.my_location_outlined,
              text: 'Search from current location',
              onTap: () {},
            ),
            const SizedBox(height: 18.0),
            Container(
              padding: EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NearBy Areas',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: _filteredAddress.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredAddress.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Container(
                            padding: EdgeInsets.only(left: 8.0),
                            child: AddressListTile(
                              address: _filteredAddress[index],
                            ),
                          ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Text('No search results found.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debouncer?.cancel();
    super.dispose();
  }
}
