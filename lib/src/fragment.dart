import 'package:flutter/widgets.dart';
import 'package:fragment/src/utils.dart';

/// A widget to cache [builder] with [keys]
/// The builder will be called only when [keys] is different (not shallowly equal)
/// from the previous [keys].
class Fragment<T extends Widget> extends StatefulWidget {
  final T Function(BuildContext context, T prev, Iterable prevKeys) builder;
  final Iterable keys;

  const Fragment(this.builder, {Key key, this.keys = const []})
      : super(key: key);

  @override
  operator ==(Object other) {
    if (other is Fragment<T>) {
      return shallowEquals(keys, other.keys);
    }
    return false;
  }

  @override
  int get hashCode => keys.hashCode;

  @override
  _FragmentState createState() => _FragmentState();
}

class _FragmentState<T extends Widget> extends State<Fragment<T>> {
  T prev;
  Iterable prevKeys;

  @override
  Widget build(BuildContext context) {
    prev = widget.builder(context, prev, prevKeys);
    prevKeys = widget.keys;
    return prev;
  }
}
