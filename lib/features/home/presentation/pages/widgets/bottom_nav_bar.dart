
import 'package:flutter/material.dart';
import 'package:user/core/theme/app_colors.dart';



class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
      height: isSmallScreen ? 95 : 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -3),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Changed from spaceAround
          children: [
            Expanded(child: _bottomItem(Icons.home_filled, "Home", 0, isSmallScreen: isSmallScreen)),
            Expanded(child: _bottomItem(Icons.calendar_month, "Admission", 1, isSmallScreen: isSmallScreen)),
            Expanded(
              child: _bottomItem(Icons.add, "ECard", 2,
                isSpecial: true,
                isSmallScreen: isSmallScreen,
              ),
            ),
            Expanded(child: _bottomItem(Icons.description_outlined, "Records", 3, isSmallScreen: isSmallScreen)),
            Expanded(child: _bottomItem(Icons.person_outline, "Profile", 4, isSmallScreen: isSmallScreen)),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem(
      IconData icon,
      String title,
      int index, {
        bool isSpecial = false,
        bool isSmallScreen = false,
      }) {
    final isSelected = currentIndex == index;

    if (isSpecial) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              child: Container(
                width: isSmallScreen ? 44 : 50,
                height: isSmallScreen ? 44 : 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                    colors: [
                      Color(0xff1F6BFF),
                      Color(0xff0057FF),
                    ],
                  )
                      : const LinearGradient(
                    colors: [
                      Color(0xffA0A0A0),
                      Color(0xff808080),
                    ],
                  ),
                  boxShadow: isSelected && !isSmallScreen
                      ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : null,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 28,
                ),
              ),
            ),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xff1F6BFF) : Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xff1F6BFF) : Colors.grey.shade500,
            size: isSmallScreen ? 20 : 22,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xff1F6BFF) : Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}