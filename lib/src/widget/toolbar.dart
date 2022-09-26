import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Toolbar extends StatefulWidget {
  const Toolbar({super.key});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black, width: 1))),
        child: SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Leading(), Trailing()],
            )));
  }
}

class Leading extends StatefulWidget {
  const Leading({super.key});

  @override
  State<Leading> createState() => _LeadingState();
}

class _LeadingState extends State<Leading> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Trailing extends StatefulWidget {
  const Trailing({super.key});

  @override
  State<Trailing> createState() => _TrailingState();
}

class _TrailingState extends State<Trailing> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: TextField(
            decoration: InputDecoration(
            border: OutlineInputBorder(),
          hintText: "Search",
          prefixIcon: Icon(Icons.search)
        )));
  }
}
