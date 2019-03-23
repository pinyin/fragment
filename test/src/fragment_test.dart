import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

// TODO test context

void main() {
  group('Fragment', () {
    testWidgets('should rebuild subtree only when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
      ));
      await tester.pumpWidget(TestFragment(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
      ));
      expect(buildLog, [1, 2, 3, 1, 3, 2, 3]);
    });
  });
}

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

class _TestFragmentState extends State<TestFragment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Fragment(
          builder: (context) {
            context.widget;
            widget.reportBuild(1);
            return Container();
          },
          deps: [widget.key1],
        ),
        Fragment(
          builder: (context) {
            widget.reportBuild(2);
            return Container();
          },
          deps: [widget.key2],
        ),
        Fragment(
          builder: (context) {
            widget.reportBuild(3);
            return Container();
          },
          deps: [widget.key3],
        ),
      ],
    );
  }
}
