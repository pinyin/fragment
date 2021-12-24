# fragment

Prevent unnecessary build() calls in StatefulWidget and its subtrees in a readable way.

If you know React, you may consider this as an alternative for `shouldComponentUpdate` or `useMemo` in Flutter.

## Usage

```dart

// Add a mixin to your state and call `fragment` method in the build method of your state
class _SState extends State<S>
    with Fragments /* This mixin is necessary when using the fragment method interface, not the Fragment widget one */ {
  String text;

  @override
  Widget build(BuildContext context) {
    // You may use the method interface fragment
    return fragment((prevTextWidget, prevKeys) { // previous result & previous deps. Both null on the first run
      return Text(text); // widgets subtree to cache
    }, deps: [text]); // values used in subtree. 
    // or the widget interface Fragment
    return Fragment((context, fragment) {
      return fragment((prevTextWidget, prevKeys) {
        // note the fragment function is now provided by Fragment widget
        // works like above but caches per Fragment widget
        return Text(text);
      }, deps: [text]);
    });
    // to preserve Text widget across builds, until text is updated again.
  }
}
```

The `Text` widget will be cached, until `text` is updated to a different string.

`deps` accepts an `Iterable`, so you can declare multiple dependencies for your fragment.

For most situations, `fragment` would be called multiple times in one `build` call, in that case, `deps` are compared in
calling order: first `fragment` call would compare its `deps` to previous build's first `fragment` call's `deps`, etc.

`fragment` also accepts an additional named parameter `group`, the above logic runs for each group independently, see
documents for more details.

## Q & A

Q: 

What's the difference between the mixin API `fragment` and the widget API `Fragment`?

A:

Sadly, there's probably no prefect way to cache a widget's subtrees. Each of them has its own pros and cons.

The mixin API `fragment` allows you to return anything from your builder: a `List`, a `PreferredSizeWidget`, a builder
function... which makes it the only way to go in some situations like caching
a [Material AppBar](https://docs.flutter.io/flutter/material/AppBar-class.html), where the parent widget `Scaffold` is
expecting [a special subtype of `Widget`](https://docs.flutter.io/flutter/material/Scaffold/appBar.html) instead of
a `Widget` .

The widget API `Fragment` also has its own pros: you can use context in your builder and everything would work as
expected, e.g. when you want to use `InheritedModel` in your subtree, or to respect
Flutter's [widget update logic](https://api.flutter.dev/flutter/foundation/Key-class.html) for caches instead of
depending on the order of calling `fragment`.

TL;DR: use `Fragment` widget when you want to use context in your subtree, use `fragment` when you want to cache
something other than a `Widget`.

## Future Plans

Add more tests.