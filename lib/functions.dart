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

String investAmountFormatting(int a) {
  if (a < 1000) {
    return a.toString();
  } else if (a >= 1000 && a < 1000000) {
    String res = (a / 1000).toString();
    if ((a % 1000) != 0) {
      res = res.substring(0, res.indexOf('.') + 2);
      return res + ' K';
    }
    return double.parse(res).floor().toString() + ' K';
  } else if (a >= 1000000 && a < 1000000000) {
    String res = (a / 1000000).toString();
    if ((a % 1000000) != 0) {
      res = res.substring(0, res.indexOf('.') + 2);
      return res + ' M';
    }

    return double.parse(res).floor().toString() + ' M';
  } else if (a >= 1000000000 && a < 1000000000000) {
    String res = (a / 1000000000).toString();
    if ((a % 1000000000) != 0) {
      res = res.substring(0, res.indexOf('.') + 2);

      return res + ' B';
    }
    return double.parse(res).floor().toString() + ' B';
  } else {
    return a.toString()[0];
  }
}
