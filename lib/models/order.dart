class Order {
  int? id;
  String? label;
  double? totalPrice;
  double? discount;
  String? date;
  int? clientId;
  String? clientName;
  String? clientPhone;
  String? clientAddress;

  Order.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    label = data["label"];
    totalPrice = data["totalPrice"];
    discount = data["discount"];
    date = data["date"];
    clientId = data["clientId"];
    clientName = data["clientName"];
    clientPhone = data["clientPhone"];
    clientAddress = data["clientAddress"];
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "label": label,
      "totalPrice": totalPrice,
      "discount": discount,
       "date": date, 
      "clientId": clientId,
    };
  }
}
