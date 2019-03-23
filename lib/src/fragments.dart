import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

mixin Fragments<W extends StatefulWidget> on State<W> {
  T fragment<T>({@required T builder(), @required Iterable deps, Key key}) {
    if (key != null) {
      final isCacheReusable = _namedSubtrees.containsKey(key) &&
          _namedSubtrees[key].widget is T &&
          _shallowEquals(deps, _namedSubtrees[key].deps);
      if (isCacheReusable) {
        return _namedSubtrees[key].widget;
      }
      final newWidget = builder();
      _namedSubtrees[key] = _Subtree(newWidget, deps);
      return newWidget;
    } else {
      final isCursorLegal = _subtreeCursor.current < _anonymousSubtrees.length;
      final isCacheReusable = isCursorLegal &&
          _anonymousSubtrees[_subtreeCursor.current].widget is T &&
          _shallowEquals(deps, _anonymousSubtrees[_subtreeCursor.current].deps);
      if (isCacheReusable) {
        final cached = _anonymousSubtrees[_subtreeCursor.current].widget as T;
        _subtreeCursor.current++;
        return cached;
      }
      if (_subtreeCursor.current >= _anonymousSubtrees.length)
        _anonymousSubtrees.length = _subtreeCursor.current + 1;
      _shouldDisableContext.current = true;
      final newWidget = builder();
      _shouldDisableContext.current = false;
      _anonymousSubtrees[_subtreeCursor.current] = _Subtree(newWidget, deps);
      _subtreeCursor.current++;
      return newWidget;
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
  BuildContext get context {
    /// FIXME:
    /// This will NOT prevent accessing `context` in builder.
    /// It will only prevent `this.context` calls.
    /// Leaving the code here until we find a better solution.
    if (_shouldDisableContext.current)
      throw 'To prevent unexpected behavior, accessing context inside fragment is disabled. \n'
          'Please consider using the Fragment widget instead.';
    return super.context;
  }

  final _Ref<int> _subtreeCursor = _Ref(0);
  final Map<Key, _Subtree> _namedSubtrees = <Key, _Subtree>{};
  final List<_Subtree> _anonymousSubtrees = <_Subtree>[];
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
