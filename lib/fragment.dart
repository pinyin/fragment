library fragment;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

class Fragment extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Iterable deps;

  const Fragment({Key key, this.builder, this.deps}) : super(key: key);

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
      () => widget.builder(context),
      hasContextUpdate ? [random.nextDouble()] : widget.deps,
    );
    hasContextUpdate = false;
    return result;
  }

  final random = Random();
  bool didInitialized = false;
  bool hasContextUpdate = false;
}

mixin Fragments<W extends StatefulWidget> on State<W> {
  T fragment<T>(T factory(), Iterable deps) {
    if (_isCurrentCacheReusable<T>(deps)) {
      final cached = _subtrees[_subtreeCursor.current].widget as T;
      _subtreeCursor.current++;
      return cached;
    }
    if (_subtreeCursor.current >= _subtrees.length)
      _subtrees.length = _subtreeCursor.current + 1;
    _shouldDisableContext.current = true;
    final newWidget = factory();
    _shouldDisableContext.current = false;
    _subtrees[_subtreeCursor.current] = _Subtree(newWidget, deps);
    _subtreeCursor.current++;
    return newWidget;
  }

  @override
  @mustCallSuper
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    _subtreeCursor.current = 0;
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subtreeCursor.current = 0;
  }

  @override
  @mustCallSuper
  void setState(VoidCallback fn) {
    super.setState(fn);
    _subtreeCursor.current = 0;
  }

  @override
  BuildContext get context {
    /// This will NOT prevent accessing `context` in current closure, which is passed to `build`
    /// as a parameter. Only works with this.context access.
    /// Leaving it here until we find a better solution. TODO
    if (_shouldDisableContext.current)
      throw 'To prevent unexpected behavior, context access inside fragment is disabled.\n'
          'Please consider using the Fragment widget instead.';
    return super.context;
  }

  bool _isCurrentCacheReusable<T>(Iterable deps) {
    if (_subtreeCursor.current >= _subtrees.length ||
        _subtrees[_subtreeCursor.current].widget is! T) {
      return false;
    }
    return _shallowEquals(deps, _subtrees[_subtreeCursor.current].deps);
  }

  final _Ref<int> _subtreeCursor = _Ref(0);
  final List<_Subtree> _subtrees = <_Subtree>[];
  final _Ref<bool> _shouldDisableContext = _Ref(false);
}

@immutable
class _Subtree {
  final Object widget;
  final Iterable deps;

  _Subtree(this.widget, this.deps);
}

final _shallowEquals = IterableEquality().equals;

class _Ref<T> {
  _Ref(T init) : current = init;
  T current;
}
