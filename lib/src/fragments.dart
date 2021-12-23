import 'package:flutter/widgets.dart';
import 'package:fragment/src/utils.dart';

typedef FragmentBuilder<T> = T Function(T? prevValue, Iterable? prevDeps);

/// A mixin to add to your [State]
mixin Fragments<W extends StatefulWidget> on State<W> {
  /// Create a cached subtree.
  ///
  /// [builder] will be called only when [deps] is different from [deps]
  /// provided in previous build (defined by IterableEquality().equals).
  ///
  /// [deps] would be compared in order, e.g. the first [fragment] call in
  /// current build compares its [deps] with the first [fragment] call in
  /// previous build, the second [fragment] call to previous' second, etc.
  ///
  /// If [group] is provided, [fragment]s within the same [group] (defined by
  /// [==]) would be compared with the above logic.
  ///
  /// If current build is the first pass or the cached value is not of type [V],
  /// builder would be called with null [prevValue] and [prevDeps].
  @protected
  T fragment<T>(FragmentBuilder<T> builder,
      {required Iterable deps, Object? group}) {
    _didPrepareBuild = false;

    group ??= const Object();
    final Iterator<_Cached>? prevDepsIter =
        _cursors[group] ??= _previous[group]?.iterator;

    final _Cached? cached =
        prevDepsIter?.moveNext() != null ? prevDepsIter?.current : null;
    if (cached is _Cached<T> && shallowEquals(cached.deps, deps)) {
      (_next[group] ??= []).add(cached);
      return cached.value;
    }

    final value =
        builder(cached?.value is T ? cached?.value : null, cached?.deps);
    (_next[group] ??= []).add(_Cached(deps, value));
    return value;
  }

  @override
  void reassemble() {
    _prepareBuild();
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    _prepareBuild();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(oldWidget) {
    _prepareBuild();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void setState(fn) {
    _prepareBuild();
    super.setState(fn);
  }

  bool _didPrepareBuild = false;

  void _prepareBuild() {
    if (_didPrepareBuild) return;
    _didPrepareBuild = true;

    _previous.clear();
    _previous.addAll(_next);
    _next.clear();
    _cursors.clear();
  }

  final _next = Map<Object, List<_Cached>>();
  final _previous = Map<Object, List<_Cached>>();
  final _cursors = Map<Object, Iterator<_Cached>?>();
}

class _Cached<V> {
  final Iterable deps;
  final V value;

  _Cached(this.deps, this.value);
}
