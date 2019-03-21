import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fragment/fragment.dart';

void main() {
  group('Fragments', () {
    testWidgets('should rebuild subtree only when deps are not identical',
        (tester) async {
      final buildLog = <int>[];
      await tester.pumpWidget(FragmentContainer(
        reportBuild: (v) => buildLog.add(v),
        key1: 1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(FragmentContainer(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: 3,
      ));
      await tester.pumpWidget(FragmentContainer(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: 2,
        key3: -3,
      ));
      await tester.pumpWidget(FragmentContainer(
        reportBuild: (v) => buildLog.add(v),
        key1: -1,
        key2: -2,
        key3: 3,
      ));
      expect(buildLog, [1, 2, 3, 1, 3, 2, 3]);
    });
  });
}

class FragmentContainer extends StatefulWidget {
  final Function(int) reportBuild;
  final int key1;
  final int key2;
  final int key3;

  const FragmentContainer(
      {Key key, this.reportBuild, this.key1, this.key2, this.key3})
      : super(key: key);

  @override
  _FragmentContainerState createState() => _FragmentContainerState();
}

class _FragmentContainerState extends State<FragmentContainer> with Fragments {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        fragment(() {
          widget.reportBuild(1);
          return Container();
        }, [widget.key1]),
        fragment(() {
          widget.reportBuild(2);
          return Container();
        }, [widget.key2]),
        fragment(() {
          widget.reportBuild(3);
          return Container();
        }, [widget.key3]),
      ],
    );
  }
}
