class ExchangeData {
  int? id;
  String? from_currency;
  String? to_currency;
  

  ExchangeData.fromJson(Map<String, dynamic> data) {
    id = data["id"];
    from_currency = data["from_currency"];
    to_currency = data["to_currency"];
  
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "from_currency": from_currency,
      "to_currency": to_currency,
    };
  }
}
