import 'package:carpet_app/models/order.dart';

String orderStatusTypesStr(ApiOrderStatusTypes type) {
  switch (type) {
    case ApiOrderStatusTypes.all:
      return 'All';
    case ApiOrderStatusTypes.new_enquiry:
      return 'New Enquiry';
    case ApiOrderStatusTypes.enquired:
      return 'Enquired';
    case ApiOrderStatusTypes.available:
      return 'Available';
    case ApiOrderStatusTypes.placed_order:
      return 'Placed Order';
    case ApiOrderStatusTypes.order_confirmed:
      return 'Order Confirmed';
    case ApiOrderStatusTypes.received_stock:
      return 'Received Stock';
    case ApiOrderStatusTypes.dispatched:
      return 'Dispatched';
    case ApiOrderStatusTypes.completed:
      return 'Completed';
    case ApiOrderStatusTypes.cancelled:
      return 'Cancelled';
    case ApiOrderStatusTypes.not_available:
      return 'Not Available';
    case ApiOrderStatusTypes.pending:
      return 'Pending';
  }
}
