import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/riverpod.dart';

final searchTextStateProvider = StateProvider<String>((ref) {
  print("setting hits");
  return "";
});

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
    return Column(
      children: [SearchField()],
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }
}

class SearchField extends ConsumerStatefulWidget {
  const SearchField({super.key});

  @override
  ConsumerState<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<SearchField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 200,
        child: TextField(
            onSubmitted: (value) {
              print("On submitted called");
              ref.read(searchTextStateProvider.notifier).state = value;
            },
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Search",
                prefixIcon: Icon(Icons.search))));
  }
}
