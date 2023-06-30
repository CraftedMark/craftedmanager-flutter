import 'package:flutter/material.dart';

import '../assets/ui.dart';

class StatusColor{
  static Color getColor(String status){
    Color color;
    switch (status) {
      case 'Processing - Pending Payment':
        {
          color = UIConstants.ORDER_TILE_ORANGE;
          break;
        }
      case 'Processing - Paid':
        {
          color = UIConstants.ORDER_TILE_ORANGE;
          break;
        }
      case 'In Production':
        {
          color = UIConstants.ORDER_TILE_GREEN;
          break;
        }
      case 'Ready to Pickup/ Ship':
        {
          color = UIConstants.ORDER_TILE_BLUE;
          break;
        }
      case 'Delivered / Shipped':
        {
          color = UIConstants.ORDER_TILE_ORANGE;
          break;
        }
      case 'Completed':
        {
          color = UIConstants.ORDER_TILE_GREY;
          break;
        }
      case 'Archived':
        {
          color = UIConstants.ORDER_TILE_GREY;
          break;
        }
      case 'Cancelled':
        {
          color = UIConstants.ORDER_TILE_RED;
          break;
        }

      default:
        color = UIConstants.ORDER_TILE_GREEN;
    }
    return color;
  }
}