import 'package:flutter/material.dart';

import '../assets/ui.dart';

class StatusColor{
  static Color getColor(String status){
    Color color;
    switch (status) {
      case 'Processing - Pending Payment':
        {
          color = UIConstants.ORANGE;
          break;
        }
      case 'Processing - Paid':
        {
          color = UIConstants.ORANGE;
          break;
        }
      case 'In Production':
        {
          color = UIConstants.GREEN;
          break;
        }
      case 'Ready to Pickup/ Ship':
        {
          color = UIConstants.BLUE;
          break;
        }
      case 'Delivered / Shipped':
        {
          color = UIConstants.ORANGE;
          break;
        }
      case 'Completed':
        {
          color = UIConstants.GREY;
          break;
        }
      case 'Archived':
        {
          color = UIConstants.GREY;
          break;
        }
      case 'Cancelled':
        {
          color = UIConstants.RED;
          break;
        }

      default:
        color = UIConstants.GREEN;
    }
    return color;
  }
}