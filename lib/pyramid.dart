import 'package:ascent/model/gradeinfo.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class PyramidScreen extends StatefulWidget {
  @override
  _PyramidScreenState createState() => _PyramidScreenState();
}

class _PyramidScreenState extends State<PyramidScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Grade Pyramid'),
        ),
        body: FutureBuilder<List<Gradeinfo>>(
            future: DatabaseHelper.getGradeInfos(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              return SingleChildScrollView(
                child: CustomPaint(
                  child: Container(),
                  painter: PyramidPainter(snapshot.data!),
                ),
              );
            }));
  }
}

class PyramidPainter extends CustomPainter {
  late List<Gradeinfo> grades;
  final Paint osPaint = Paint();
  final Paint flPaint = Paint();
  final Paint rpPaint = Paint();
  final Paint tpPaint = Paint();

  PyramidPainter(this.grades) {
    osPaint.color = Colors.black;
    flPaint.color = Colors.yellow;
    rpPaint.color = Colors.red;
    tpPaint.color = Colors.grey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var boxStart = 160;
    var availableWidth = size.width - boxStart;
    double scale = availableWidth / getMax(grades);
    double center = boxStart + availableWidth / 2;
    double rectHeight = 10;
    int count = 0;
    for (final gradeInfo in grades) {
      count++;
      String grade = gradeInfo.grade;
      int totalSize = gradeInfo.getTotal();
      int totalWidth = totalSize * scale.toInt();
      int osSize = gradeInfo.osCount;
      int osWidth = osSize * scale.toInt();
      int flSize = gradeInfo.flCount;
      int flWidth = flSize * scale.toInt();
      int rpSize = gradeInfo.rpCount;
      int rpWidth = rpSize * scale.toInt();
      int tpSize = gradeInfo.tpCount;
      int tpWidth = tpSize * scale.toInt();
      TextPainter painter =
          new TextPainter(text: new TextSpan(text: grade, style: new TextStyle(color: Colors.white)), textDirection: TextDirection.ltr);
      painter.layout();
      rectHeight = painter.height;
      painter.paint(canvas, Offset(5, count * rectHeight));
      painter =
          new TextPainter(text: new TextSpan(text: osSize.toString(), style: new TextStyle(color: Colors.white)), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(30, count * rectHeight));
      painter =
          new TextPainter(text: new TextSpan(text: flSize.toString(), style: new TextStyle(color: Colors.white)), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(60, count * rectHeight));
      painter =
          new TextPainter(text: new TextSpan(text: rpSize.toString(), style: new TextStyle(color: Colors.white)), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(90, count * rectHeight));
      painter =
          new TextPainter(text: new TextSpan(text: tpSize.toString(), style: new TextStyle(color: Colors.white)), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(120, count * rectHeight));
      painter = new TextPainter(
          text: new TextSpan(text: totalSize.toString(), style: new TextStyle(color: Colors.white)), textDirection: TextDirection.ltr);
      painter.layout();
      painter.paint(canvas, Offset(150, count * rectHeight));
      canvas.drawRect(Rect.fromLTRB(center - (totalWidth / 2), count * rectHeight, center + (totalWidth / 2), (count + 1) * rectHeight), new Paint());
      //OS
      canvas.drawRect(Rect.fromLTRB(center - (osWidth / 2), count * rectHeight, center + (osWidth / 2), (count + 1) * rectHeight), osPaint);
      //FL
      canvas.drawRect(
          Rect.fromLTRB(center - (osWidth / 2) - (flWidth / 2), count * rectHeight, center - (osWidth / 2), (count + 1) * rectHeight), flPaint);
      canvas.drawRect(
          Rect.fromLTRB(center + (osWidth / 2), count * rectHeight, center + (osWidth / 2) + (flWidth / 2), (count + 1) * rectHeight), flPaint);
      //RP
      canvas.drawRect(
          Rect.fromLTRB(center - (osWidth / 2) - (flWidth / 2) - (rpWidth / 2), count * rectHeight, center - (osWidth / 2) - (flWidth / 2),
              (count + 1) * rectHeight),
          rpPaint);
      canvas.drawRect(
          Rect.fromLTRB(center + (osWidth / 2) + (flWidth / 2), count * rectHeight, center + (osWidth / 2) + (flWidth / 2) + (rpWidth / 2),
              (count + 1) * rectHeight),
          rpPaint);
      //TP
      canvas.drawRect(
          Rect.fromLTRB(center - (osWidth / 2) - (flWidth / 2) - (rpWidth / 2) - (tpWidth / 2), count * rectHeight,
              center - (osWidth / 2) - (flWidth / 2) - (rpWidth / 2), (count + 1) * rectHeight),
          tpPaint);
      canvas.drawRect(
          Rect.fromLTRB(center + (osWidth / 2) + (flWidth / 2) + (rpWidth / 2), count * rectHeight,
              center + (osWidth / 2) + (flWidth / 2) + (rpWidth / 2) + (tpWidth / 2), (count + 1) * rectHeight),
          tpPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  int getMax(List<Gradeinfo> grades) {
    int max = 1;
    for (Gradeinfo g in grades) {
      if (g.getTotal() > max) {
        max = g.getTotal();
      }
    }
    return max;
  }
}
