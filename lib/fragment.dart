library fragment;

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

mixin Fragments<W extends StatefulWidget> on State<W> {
  T fragment<T>(T factory(), Iterable deps) {
    if (_isCurrentCacheReusable<T>(deps)) {
      final cached = _subtrees[_subtreeCursor.current].widget as T;
      _subtreeCursor.current++;
      return cached;
    }
    if (_subtreeCursor.current >= _subtrees.length)
      _subtrees.length = _subtreeCursor.current + 1;
    final newWidget = factory();
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

  bool _isCurrentCacheReusable<T>(Iterable deps) {
    if (_subtreeCursor.current >= _subtrees.length ||
        _subtrees[_subtreeCursor.current].widget is! T) {
      return false;
    }
    return _shallowEquals(deps, _subtrees[_subtreeCursor.current].deps);
  }

  final _Ref<int> _subtreeCursor = _Ref(0);
  final List<_Subtree> _subtrees = <_Subtree>[];
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
