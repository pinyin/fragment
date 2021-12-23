import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

// TODO test named subtrees

void main() {
  group('Fragments', () {
    testWidgets('should rebuild subtree whose keys are updated',
        (tester) async {
      var buildCount = 0;
      final builtKeys = <Iterable?>[];
      final builtValues = <int?>[];
      final FragmentBuilder builder = (prevValue, prevKeys) {
        buildCount++;
        builtKeys.add(prevKeys);
        builtValues.add(prevValue);
        return buildCount;
      };
      await tester.pumpWidget(TestFragments(
        builder: builder,
        items: [
          KeyAndGroup(1, [1, 1]),
          KeyAndGroup(2, [2, 1]),
          KeyAndGroup(1, [1, 2]),
          KeyAndGroup(2, [2, 1]),
          KeyAndGroup(1, [1, 1]),
          KeyAndGroup(1, [1, 3]),
        ],
      ));
      expect(buildCount, 6);
      expect(builtKeys, [null, null, null, null, null, null]);
      expect(builtValues, [null, null, null, null, null, null]);
      builtKeys.clear();
      builtValues.clear();

      await tester.pumpWidget(TestFragments(
        builder: builder,
        items: [
          KeyAndGroup(1, [1, 1]),
          KeyAndGroup(2, [2, 1]),
          KeyAndGroup(2, [2, 1]),
          KeyAndGroup(1, [1, 1]),
          KeyAndGroup(1, [1, 3]),
        ],
      ));
      expect(buildCount, 8);
      expect(builtKeys, [
        [1, 2],
        [1, 1]
      ]);
      expect(builtValues, [3, 5]);
      builtKeys.clear();
      builtValues.clear();

      await tester.pumpWidget(TestFragments(
        builder: builder,
        items: [
          KeyAndGroup(1, [1, 1]),
          KeyAndGroup(2, [2, 1]),
          KeyAndGroup(2, [2, 2]),
          KeyAndGroup(1, [1, 1]),
          KeyAndGroup(1, [1, 3]),
        ],
      ));
      expect(buildCount, 9);
      expect(builtKeys, [
        [2, 1],
      ]);
      expect(builtValues, [4]);
      builtKeys.clear();
      builtValues.clear();
    });
  });
}

class TestFragments<A, B, C> extends StatefulWidget {
  final FragmentBuilder builder;
  final Iterable<KeyAndGroup> items;

  const TestFragments({required this.builder, required this.items}) : super();

  @override
  _TestFragmentsState createState() => _TestFragmentsState();
}

class KeyAndGroup {
  final Object group;
  final Iterable keys;

  KeyAndGroup(this.group, this.keys);
}

class _TestFragmentsState extends State<TestFragments> with Fragments {
  @override
  Widget build(BuildContext context) {
    widget.items.forEach((element) {
      fragment<dynamic>((prevValue, prevKeys) {
        return widget.builder(prevValue, prevKeys);
      }, deps: element.keys, group: element.group);
    });

    return Container();
  }
}
