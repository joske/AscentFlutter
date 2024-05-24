class Gradeinfo {
  final String grade;
  final int osCount;
  final int flCount;
  final int rpCount;
  final int tpCount;

  Gradeinfo(this.grade, this.osCount, this.flCount, this.rpCount, this.tpCount);

  int getTotal() {
    return osCount + flCount + rpCount + tpCount;
  }
}