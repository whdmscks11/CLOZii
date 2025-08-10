import 'package:carrot_login/widget/custom_button.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  bool isCheckedAll = false;
  bool isMainChecked = false;
  bool isOptionalChecked = false;
  bool isListOpen = false;
  String? _selectedOption;

  void _toggleAll() {
    setState(() {
      isCheckedAll = !isCheckedAll;
      if (isCheckedAll) {
        isMainChecked = true;
        isOptionalChecked = true;
      } else {
        isMainChecked = false;
        isOptionalChecked = false;
      }
    });
  }

  void _toggleMain() {
    setState(() {
      isMainChecked = !isMainChecked;
      if (isMainChecked && isOptionalChecked) {
        isCheckedAll = true;
      } else {
        isCheckedAll = false;
      }
    });
  }

  void _toggleOptional() {
    setState(() {
      isOptionalChecked = !isOptionalChecked;
      if (isMainChecked && isOptionalChecked) {
        isCheckedAll = true;
      } else {
        isCheckedAll = false;
      }
    });
  }

  void _openDropDownList() {
    setState(() {
      isListOpen = !isListOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 8.0,
            bottom: 30.0,
            left: 12.0,
            right: 12.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    highlightColor: Colors.transparent,
                    onPressed: _toggleAll,
                    icon: Icon(
                      isCheckedAll
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_off_rounded,
                      color: isCheckedAll ? Colors.amber[800] : Colors.grey,
                    ),
                  ),
                  Text('Accept All Terms and Conditions'),
                ],
              ),
              Divider(indent: 10.0, endIndent: 20.0),
              Row(
                children: [
                  IconButton(
                    onPressed: _toggleMain,
                    icon: Icon(
                      Icons.check,
                      color: isMainChecked ? Colors.amber[800] : Colors.grey,
                    ),
                  ),
                  Text('(Required) Terms and Conditions'),
                  IconButton(
                    onPressed: _openDropDownList,
                    icon: Icon(
                      isListOpen ? Icons.expand_more : Icons.chevron_right,
                    ),
                  ),
                ],
              ),
              if (isListOpen)
                Column(
                  children: [
                    Align(
                      alignment: AlignmentGeometry.xy(-0.32, 0),
                      child: Text(
                        '(Required) Terms and Conditions',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Align(
                      alignment: AlignmentGeometry.xy(-0.32, 0),
                      child: Text(
                        '(Required) Terms and Conditions',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(height: 14.0),
                    Align(
                      alignment: AlignmentGeometry.xy(-0.32, 0),
                      child: Text(
                        '(Required) Terms and Conditions',
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              Row(
                children: [
                  IconButton(
                    onPressed: _toggleOptional,
                    icon: Icon(
                      Icons.check,
                      color: isOptionalChecked
                          ? Colors.amber[800]
                          : Colors.grey,
                    ),
                  ),
                  Text('(Required) Terms and Conditions'),
                ],
              ),
              Divider(indent: 10.0, endIndent: 20.0),
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 13.0,
                        top: 13.0,
                        bottom: 5.0,
                      ),
                      child: Text('Verify Your Age'),
                    ),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: '18_up',
                        groupValue: _selectedOption,
                        activeColor: Colors.amber[800],
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                      ),
                      Text('I am 18 years old or above'),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: '18_down',
                        groupValue: _selectedOption,
                        activeColor: Colors.amber[800],
                        onChanged: (value) {
                          setState(() {
                            _selectedOption = value;
                          });
                        },
                      ),
                      Text('I am 18 years old or above'),
                    ],
                  ),
                  CustomButton(text: 'Start', onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ListTile(
//   splashColor: Colors.transparent,
//   onTap: _toggleAll,
//   leading: Icon(
//     isCheckedAll
//         ? Icons.check_circle_rounded
//         : Icons.radio_button_off_rounded,
//     color: isCheckedAll ? Colors.amber[800] : Colors.grey,
//   ),
//   title: Text('Accept All Terms and Conditions'),
// ),