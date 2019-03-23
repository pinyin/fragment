import 'package:flutter/widgets.dart';

import 'fragments.dart';

/// A widget to cache [builder] with [deps]
/// The builder will be called only when [deps] is different (not shallowly equal)
/// from the previous [deps].
class Fragment extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Iterable deps;

  const Fragment({@required this.builder, @required this.deps, Key key})
      : super(key: key);

  @override
  _FragmentState createState() => _FragmentState();
}

class _FragmentState extends State<Fragment> with Fragments {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // skip first didChangeDependencies call, which always runs after initState
    if (didInitialized) hasContextUpdate = true;
    didInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final result = fragment(
      builder: () => widget.builder(context),
      deps: hasContextUpdate ? [buildCount] : widget.deps,
    );
    hasContextUpdate = false;
    buildCount++;
    return result;
  }

  int buildCount = 0;
  bool didInitialized = false;
  bool hasContextUpdate = false;
}
