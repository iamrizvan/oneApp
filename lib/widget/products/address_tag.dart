import 'package:flutter/material.dart';

class AddressTag extends StatelessWidget {
  final String address;

  AddressTag(this.address);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.purpleAccent, width: 1.5),
          borderRadius: BorderRadius.circular(4.0)),
      child: Text(address),
    );
  }
}
