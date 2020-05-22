
import 'package:flutter/material.dart';


double windowHeight;
double windowWidth;

double sizeCoeff = 0.9;


double windowRelWidth (double relwidth) {
  return relwidth*windowWidth;
}

double windowRelHeight (double relheight) {
  return relheight*windowHeight;
}

double widgetRelWidth (BuildContext context, relwidth) {
  return relwidth*MediaQuery.of(context).size.width;
}

double widgetRelHeight (BuildContext context, relheight) {
  return relheight*MediaQuery.of(context).size.height;
}