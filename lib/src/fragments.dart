import 'package:flutter/widgets.dart';

import 'utils.dart';

/// A mixin to add to your [State]
mixin Fragments<W extends StatefulWidget> on State<W> {
  /// Create a cached subtree.
  /// [builder] will be called only when [deps] is different (not shallowly equal)
  /// from the previous pass.
  T fragment<T>(T builder(), {Iterable deps = const [], Key key}) {
    final isAnonymous = key == null;

    // try use existing cache
    final isCacheReusable = isAnonymous
        ? _subtreeCursor.current < _anonymousSubtrees.length &&
            _anonymousSubtrees[_subtreeCursor.current].widget is T &&
            shallowEquals(deps, _anonymousSubtrees[_subtreeCursor.current].deps)
        : _namedSubtrees.containsKey(key) &&
            _namedSubtrees[key].widget is T &&
            shallowEquals(deps, _namedSubtrees[key].deps);
    if (isCacheReusable) {
      final cached = isAnonymous
          ? _anonymousSubtrees[_subtreeCursor.current].widget as T
          : _namedSubtrees[key].widget as T;
      if (isAnonymous) _subtreeCursor.current++;
      return cached;
    }

    // update cache
    try {
      // rebuild subtree
      _fragmentDepth.current++;
      final newWidget = builder();

      // save subtree to cache
      if (isAnonymous) {
        if (_subtreeCursor.current >= _anonymousSubtrees.length)
          _anonymousSubtrees.length = _subtreeCursor.current + 1;
        _anonymousSubtrees[_subtreeCursor.current] = _Subtree(newWidget, deps);
        _subtreeCursor.current++;
      } else {
        _namedSubtrees[key] = _Subtree(newWidget, deps);
      }

      return newWidget;
    } finally {
      _fragmentDepth.current--;
    }
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
  void reassemble() {
    _subtreeCursor.current = 0;
    _fragmentDepth.current = 0;
    _namedSubtrees.clear();
    _anonymousSubtrees.clear();
    super.reassemble();
  }

  final _Ref<int> _subtreeCursor = _Ref(0);
  final Map<Key, _Subtree> _namedSubtrees = <Key, _Subtree>{};
  final List<_Subtree> _anonymousSubtrees = <_Subtree>[];
  final _Ref<int> _fragmentDepth = _Ref(0);
}

@immutable
class _Subtree {
  final Object widget;
  final Iterable deps;

  _Subtree(this.widget, this.deps);
}

class _Ref<T> {
  _Ref(T init) : current = init;
  T current;
}
