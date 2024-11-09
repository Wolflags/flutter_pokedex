import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/colors/type_color.dart';

Widget buildTypeWidget(Map<String, dynamic> typeInfo) {
  final typeName = typeInfo['pokemon_v2_type']['name'];
  return Padding(
    padding: const EdgeInsets.only(right: 4.0),
    child: Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: getTypeColor(typeName),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: getTypeColor(typeName).withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SvgPicture.asset(
          'assets/icons/$typeName.svg',
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );
}