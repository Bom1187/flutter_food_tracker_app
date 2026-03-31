// ไฟล์ที่สร้างเพื่อเก็บข้อมูลในใน table ที่เราจะทำงานด้วย
// ignore_for_file: non_constant_identifier_names

class Food {
  String? id;
  String? foodDate;
  String? foodMeal;
  int? foodPerson;
  String? foodName;
  int? foodPrice;
  String? foodImageUrl;

  Food({
    this.id,
    this.foodDate,
    this.foodMeal,
    this.foodPerson,
    this.foodName,
    this.foodPrice,
    this.foodImageUrl,
  });

//แปลงข้อมูลจาก server/cloud ซึ่งเป็น json มาเป็นข้อมูลที่จะใช้ในแอป
  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'],
        foodName: json['foodName'],
        foodDate: json['foodDate'],
        foodMeal: json['foodMeal'],
        foodPerson: json['foodPerson'],
        foodPrice: json['foodPrice'],
        foodImageUrl: json['foodImageUrl'],
      );

//แปลงข้อมูลจากในแอป json เพื่อส่งไปยัง server/cloud
  Map<String, dynamic> toJson() => {
        'foodName': foodName,
        'foodDate': foodDate,
        'foodMeal': foodMeal,
        'foodPerson': foodPerson,
        'foodPrice': foodPrice,
        'foodImageUrl': foodImageUrl,
      };
}
