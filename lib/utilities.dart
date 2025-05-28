//Convertis la hauteur en coodonnées
double heighToCoordinate(double height, double totalHeight) {
  double position = 1 - 2 * (height / totalHeight);
  return position;
}

// converts some deltaX value in pixels into alignment units
// deltaX / totalwidth = result / 2
double deltaXToCoordinate(double deltaX, double totalwidth) {
  double result = 2 * (deltaX / totalwidth);
  return result;
}
