import 'package:flutter/widgets.dart';

import 'fragments.dart';

typedef FragmentFunc<T> = T Function(FragmentBuilder<T> builder,
    {required Iterable deps, Object? group});

class Fragment extends StatefulWidget {
  final Widget Function(BuildContext context, FragmentFunc fragment) builder;

  const Fragment(this.builder, {Key? key}) : super(key: key);

  @override
  _FragmentState createState() => _FragmentState();
}

class _FragmentState extends State<Fragment> with Fragments {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, fragment);
  }
}
