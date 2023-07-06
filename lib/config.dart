
class AppConfig {
  AppConfig._();
  static const WOOSIGNAL_APP_KEY = "app_842c37c5a8066c3c8a8384b48ffc75";

  static const ONESIGNAL_REST_API_KEY = "MzVhNWRjN2ItZDVmZC00ZTZiLTk5NzYtNzc2NDEyMTU2NWM2";
  static const ONESIGNAL_APP_KEY = "fed52d24-522d-4653-ae54-3c23d0a735ac";
  static const ENABLE_WOOSIGNAL = false;

  static const ORDERED_ITEM_STATUSES = ['Pending', 'Started', 'In-Progress', 'Completed'];
  static const ORDER_STATUSES_WOOSIGNAL = [
    'pending',
    'processing',
    'on-hold',
    'completed',
    'cancelled',
    'refunded',
    'failed',
    'trash'
  ];
  static const ORDER_STATUSES_POSTGRES = [
    'Processing - Pending Payment',
    'Processing - Paid',
    'In Production',
    'Ready to Pickup/ Ship',
    'Delivered / Shipped',
    'Completed',
    'Archived',
    'Cancelled'
  ];
}