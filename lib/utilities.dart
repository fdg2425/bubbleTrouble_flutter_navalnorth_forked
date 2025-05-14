//Convertis la hauteur en coodonnées
double heighToCoordinate(double height, double totalHeight) {
  double position = 1 - 2 * (height / totalHeight);
  return position;
}
