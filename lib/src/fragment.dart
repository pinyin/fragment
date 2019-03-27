import 'package:flutter/widgets.dart';
import 'package:fragment/src/utils.dart';

/// A widget to cache [builder] with [deps]
/// The builder will be called only when [deps] is different (not shallowly equal)
/// from the previous [deps].
class Fragment<T extends Widget> extends StatelessWidget {
  final T Function(BuildContext context) builder;
  final Iterable deps;

  const Fragment({@required this.builder, @required this.deps, Key key})
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
  T build(BuildContext context) {
    return builder(context);
  }
}
