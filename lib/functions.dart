String formatNumber(int a) {
  String res = a.toString();

  if (a < 10000) return res;

  int num = res.length;

  // res = (a/1000).floor().toString() + "," + (a%1000).toString();

  if (num % 2 == 0) {
    for (int i = 1; i < num; i = i + 2) {
      res = res.substring(0, i) + "," + res.substring(i);
      i++;
    }
  } else {
    for (int i = 2; i < num; i = i + 2) {
      res = res.substring(0, i) + "," + res.substring(i);
      i++;
    }
  }
  return res;
}
