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

  @override
  BuildContext get context {
    _buildContext.current ??= _ContextProxy(
        () => super.context, () => this._fragmentDepth.current > 0);

    return _buildContext.current;
  }

  final _Ref<BuildContext> _buildContext = _Ref(null);
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

class _ContextProxy implements BuildContext {
  final BuildContext Function() _getContext;
  final bool Function() _shouldThrow;

  _ContextProxy(this._getContext, this._shouldThrow);

  BuildContext get _context {
    if (_shouldThrow())
      throw 'To prevent unexpected behavior, accessing context inside fragment is disabled. \n'
          'Please consider using the Fragment widget instead or use context from out of builder.';
    return this._getContext();
  }

  @override
  InheritedElement ancestorInheritedElementForWidgetOfExactType(
      Type targetType) {
    return _context.ancestorInheritedElementForWidgetOfExactType(targetType);
  }

  @override
  RenderObject ancestorRenderObjectOfType(TypeMatcher matcher) {
    return _context.ancestorRenderObjectOfType(matcher);
  }

  @override
  State<StatefulWidget> ancestorStateOfType(TypeMatcher matcher) {
    return _context.ancestorStateOfType(matcher);
  }

  @override
  Widget ancestorWidgetOfExactType(Type targetType) {
    return _context.ancestorWidgetOfExactType(targetType);
  }

  @override
  RenderObject findRenderObject() {
    return _context.findRenderObject();
  }

  @override
  InheritedWidget inheritFromElement(InheritedElement ancestor,
      {Object aspect}) {
    return _context.inheritFromElement(ancestor);
  }

  @override
  InheritedWidget inheritFromWidgetOfExactType(Type targetType,
      {Object aspect}) {
    return _context.inheritFromWidgetOfExactType(targetType);
  }

  @override
  BuildOwner get owner => _context.owner;

  @override
  State<StatefulWidget> rootAncestorStateOfType(TypeMatcher matcher) {
    return _context.rootAncestorStateOfType(matcher);
  }

  @override
  Size get size => _context.size;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
    _context.visitAncestorElements(visitor);
  }

  @override
  void visitChildElements(visitor) {
    _context.visitChildElements(visitor);
  }

  @override
  Widget get widget => _context.widget;
}
