# fragment

[![Build Status](https://travis-ci.com/pinyin/fragment.svg?branch=master)](https://travis-ci.com/pinyin/fragment)

Prevent unnecessary build() calls in StatefulWidget and its subtrees in a readable way.

If you know React, you may consider this as a `shouldComponentUpdate` alternate for Flutter.

## Usage

```dart

// Add a mixin to your state and call `fragment` method in the build method of your state
class _SState extends State<S> with Fragments {
  String text;

  @override
  Widget build(BuildContext context) {
    return fragment(() {
      return Text(text); // widgets subtree to cache
    }, deps: [text]); // values used in subtree. 
    // Text() will be preserved across builds unless text is updated
  }
}

// or use `Fragment` widget 
class _SState extends State<S> {
  String text;

  @override
  Widget build(BuildContext context) {
    return Fragment((context) {
      return Text(text);
    }, deps: [text]);
    // Text() will be preserved across builds unless text is updated
  }
}

```

Either way, the `Text` widget will be cached, until `text` is updated to a different string.

`deps` accepts an `Iterable`, so you can declare multiple dependencies for your fragment.

## API

The library comes with a mixin `Fragments` an a widget `Fragment`.

### Mixin API

After adding `Fragments` mixin to your `State`, you will get an additional method `fragment`: 

```dart

import 'package:fragment/fragment.dart';

// Create Widget like before 
class FragmentContainer extends StatefulWidget {
  final int key1;
  final int key2;
  final int key3;

  const FragmentContainer( {Key key, this.key1, this.key2, this.key3}) : super(key: key);

  @override
  _FragmentContainerState createState() => _FragmentContainerState();
}

// Create State with Fragments mixin
class _FragmentContainerState extends State<FragmentContainer> with Fragments {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        fragment( // use fragment method to cache a subtree
          () => Container(),
          deps: [widget.key1],
        ), 
        fragment(
          () => Container(),
          deps: [widget.key2],
        ), 
        fragment(
          () => Container(),
          deps: [widget.key3],
        ),
      ],
    );
  }
}

```

When one of `key1`, `key2` and `key3` updates, the other two `Container` widgets in other lines won't be recreated.

`fragment` method takes two parameters: a builder function which returns the target `Widget`, and an `Iterable` to determine when to call the builder. During each call, the `deps` parameter is compared with the `deps` parameter in previous call. If they are shallowly equal, current builder will be ignored and the cached widget is used as the return value of `fragment`, otherwise, the current builder gets called and its return value is cached and returned by `fragment`.

To know which previous `deps` should be used when comparing with the new one, the deps are added to a `List` to keep their order. All `fragment` calls in the same `State` instance must have consistent orders across different passes of `build` calls, so please don't use `fragment` in dynamic loops and conditionals.

`fragment` also accepts an experimental optional parameter `key`. Builders with the same `key` are considered as the same builder and excluded from no-key builders. Remember keyed builders are never released in the whole state lifecycle, so this may introduce weird bugs and should be used very carefully.

### Widget API

Import and use `Fragment` as a widget:

```dart

import 'package:fragment/fragment.dart';

class TestFragment extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;

  const TestFragment(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3})
      : super(key: key);

  @override
  _TestFragmentState createState() => _TestFragmentState();
}

class _TestFragmentState extends State<TestFragment> { // There's no need to add mixin
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Fragment(
          (context) => Container(),
          deps: [widget.key1],
        ),
        Fragment(
          (context) => Container(),
          deps: [widget.key2],
        ),
        Fragment(
          (context) => Container(),
          deps: [widget.key3],
        ),
      ],
    );
  }
}
```

This will give you a similar behavior like the mixin API. Since every `Fragment` is a normal `Widget`, there's no need to enforce consistent order between `Fragment` instances.

You can also use `Fragment` and `fragment` in the same `State`.

## Q & A

Q: 

What's the difference between the mixin API `fragment` and the widget API `Fragment`?

A:

Sadly, there's probably no prefect way to cache a widget's subtrees. Each of them have its own pros and cons.

The mixin API `fragment` allows you to return anything from your builder: a `List`, a `PreferredSizeWidget`, a builder function... which makes it the only way to go in some situations like caching a [Material AppBar](https://docs.flutter.io/flutter/material/AppBar-class.html), where the parent widget `Scaffold` is expecting [a special subtype of `Widget`](https://docs.flutter.io/flutter/material/Scaffold/appBar.html) instead of a `Widget` .

The widget API `Fragment` also has its own pros: you can use context in your builder and everything would work as expected, e.g. when you want to use `InheritedModel` in your subtree, the cached subtree will be rebuilt with the model, even if the corresponding `deps` are not changed.

TL;DR: use `Fragment` widget when you want to use context or have a dynamic number of fragments, use `fragment` when you want to make a your cached subtree.

## Future Plans

Add more tests.