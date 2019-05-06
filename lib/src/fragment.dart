import 'package:flutter/widgets.dart';
import 'package:fragment/src/utils.dart';

/// A widget to cache [builder] with [deps]
/// The builder will be called only when [deps] is different (not shallowly equal)
/// from the previous [deps].
class Fragment<T extends Widget> extends StatefulWidget {
  final T Function(BuildContext context, T prev) builder;
  final Iterable deps;

  const Fragment(this.builder, {this.deps = const [], Key key})
      : super(key: key);

  @override
  operator ==(Object other) {
    if (other is Fragment<T>) {
      return shallowEquals(deps, other.deps);
    }
    return false;
  }

  @override
  int get hashCode => deps.hashCode;

  @override
  _FragmentState createState() => _FragmentState();
}

class _FragmentState<T extends Widget> extends State<Fragment<T>> {
  T prev;

  @override
  Widget build(BuildContext context) {
    prev = widget.builder(context, prev);
    return prev;
  }
}
