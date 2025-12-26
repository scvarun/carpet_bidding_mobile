String absValueStr(double value) {
  return absValue(value).toStringAsFixed(2);
}

double absValue(double value) {
  return (value / 100);
}

double realValue(double value) {
  return (value * 100);
}
