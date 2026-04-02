import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/model/food.dart';
import 'package:flutter_food_tracker_app/services/supabase_service.dart';
import 'package:flutter_food_tracker_app/views/add_food_ui.dart';
import 'package:flutter_food_tracker_app/views/update_delete_ui.dart';

class ShowAllFoodUi extends StatefulWidget {
  const ShowAllFoodUi({super.key});

  @override
  State<ShowAllFoodUi> createState() => _ShowAllFoodUiState();
}

class _ShowAllFoodUiState extends State<ShowAllFoodUi> {
  // สร้าง instance/object/ตัวแทน ของ supabaseService
  final service = SupabaseService();

  // สร้างตัวแปรเก็บข้อมูลที่ได้จากการดึงมาจาก supabase
  List<Food> foods = [];
  void loadFoods() async {
    final data = await service.getFoods();

    setState(() {
      foods = data;
    });
  }

  @override
  void initState() {
    super.initState();
    // เรียกใช้เมธอดเพื่อดึงข้อมูล ตอนหน้าจอถูกเปิดขึ้นมา
    loadFoods();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // appbar
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Food Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      // ปุ่มเปิดไปหน้าเพิ่ม food
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddFoodUi(),
            ),
          ).then((value) {
            // เมื่อกลับมาจากหน้า AddFood Ui ให้โหลดข้อมูลใหม่เพื่อแสดงอัปเดตล่าสุด
            loadFoods();
          });
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      // ตำแหน่งปุ่มเปิดไปหน้าเพิ่ม food
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // body ที่แสดง logo กับข้อมูลที่ดึงมาจาก supabase
      body: Center(
        child: Column(
          children: [
            // แสดง logo
            SizedBox(
              height: 40,
            ),
            Image.asset(
              'assets/images/logo1.png',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: 40,
            ),
            // ListView แสดลข้อมูลจาก food_tb จาก supabase
            Expanded(
              child: ListView.builder(
                // จำนวนรายการ
                itemCount: foods.length,
                // หน้าตาแต่ละรายการ
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                      bottom: 5,
                      left: 20,
                      right: 20,
                    ),
                    child: ListTile(
                      onTap: () {
                        // เปิดไปหน้า UpdateDeleteFoodUi แบบย้อนหลับได้
                        // และจะมีการส่งข้อมูลที่ถูกกับไปหน้า UpdateDeleteFoodUi
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateDeleteUi(
                              food: foods[index],
                            ),
                          ),
                        ).then(
                          (value) {
                            loadFoods();
                          },
                        );
                      },
                      leading: foods[index].foodImageUrl! != ''
                          ? Image.network(
                              foods[index].foodImageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/images/logo1.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                      title: Text(
                        'กิน: ${foods[index].foodName}',
                      ),
                      subtitle: Text(
                        'วันที่: ${foods[index].foodDate} '
                        'มื้อ: ${foods[index].foodMeal}',
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.red,
                      ),
                      tileColor:
                          index % 2 == 0 ? Colors.green[100] : Colors.green[50],
                      contentPadding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
