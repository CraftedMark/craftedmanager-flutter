import 'dart:convert';

import 'package:crafted_manager/config.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

abstract class NotificationEventType {
  late String name;

  void _setName(String name) {
    this.name = name;
  }
}

class OrdersEvent extends NotificationEventType{
  OrdersEvent() {
   _setName(AppConfig.PUSH_NOTIFICATION_EVENTS[0]);
  }
}
class CustomersEvent extends NotificationEventType{
  CustomersEvent(){
    _setName(AppConfig.PUSH_NOTIFICATION_EVENTS[1]);
  }
}
class ProductsEvent extends NotificationEventType{
  ProductsEvent(){
    _setName(AppConfig.PUSH_NOTIFICATION_EVENTS[2]);
  }
}
class EmployeesEvent extends NotificationEventType{
  EmployeesEvent(){
    _setName(AppConfig.PUSH_NOTIFICATION_EVENTS[3]);
  }
}
class UnknownEvent extends NotificationEventType{
  UnknownEvent(){
    _setName(AppConfig.PUSH_NOTIFICATION_EVENTS[4]);
  }
}

NotificationEventType createEventFromNotification(OSNotificationReceivedEvent notificationEvent){
  const String customDataKey = 'a';

  try{
    final customData = jsonDecode(notificationEvent.notification.rawPayload?['custom']) ;
    final event =  customData[customDataKey]['event'];

    if(event == AppConfig.PUSH_NOTIFICATION_EVENTS[0]){
      return OrdersEvent();
    }
    else if(event == AppConfig.PUSH_NOTIFICATION_EVENTS[1]){
      return CustomersEvent();
    }
    else if (event == AppConfig.PUSH_NOTIFICATION_EVENTS[2]){
      return ProductsEvent();
    }
    else if (event == AppConfig.PUSH_NOTIFICATION_EVENTS[3]){
      return EmployeesEvent();
    }
  }
  catch(e){
    print("Error while received notification parse: $e");
  }
  return UnknownEvent();
}