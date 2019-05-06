import 'package:flutter/widgets.dart';

import 'utils.dart';

/// A mixin to add to your [State]
mixin Fragments<W extends StatefulWidget> on State<W> {
  /// Create a cached subtree.
  /// [builder] will be called only when [deps] is different (not shallowly equal)
  /// from the previous pass.
  T fragment<T>(T builder(T prev), {Iterable deps = const [], Key key}) {
    assert(_fragmentDepth.current == 0);
    final isAnonymous = key == null;

    // try use existing cache
    final bool hasCache = isAnonymous
        ? _subtreeCursor.current < _anonymousSubtrees.length &&
            _anonymousSubtrees[_subtreeCursor.current].value is T
        : _namedSubtrees.containsKey(key) && _namedSubtrees[key].value is T;

    final T cachedValue = hasCache
        ? isAnonymous
            ? _anonymousSubtrees[_subtreeCursor.current].value as T
            : _namedSubtrees[key].value as T
        : null;

    if (hasCache) {
      final cachedDeps = isAnonymous
          ? _anonymousSubtrees[_subtreeCursor.current].deps
          : _namedSubtrees[key].deps;

      if (shallowEquals(cachedDeps, deps)) {
        _subtreeCursor.current++;
        return cachedValue;
      }
    }

    // update cache
    try {
      // rebuild subtree
      _fragmentDepth.current++;
      final newWidget = builder(cachedValue);

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
  final Object value;
  final Iterable deps;

  _Subtree(this.value, this.deps);
}

class _Ref<T> {
  _Ref(T init) : current = init;
  T current;
}
