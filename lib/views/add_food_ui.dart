import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_food_tracker_app/model/food.dart';
import 'package:flutter_food_tracker_app/services/supabase_service.dart';

class AddFoodUi extends StatefulWidget {
  const AddFoodUi({super.key});

  @override
  State<AddFoodUi> createState() => _AddFoodUiState();
}

class _AddFoodUiState extends State<AddFoodUi> {
  // สร้างตัวควบคุม textfield และตัวแปรที่ต้องเก็บข้อมูลตอนป้อนหรือเลือก เพื่อบันทึกไว้ใน task_tb
  TextEditingController foodNameController = TextEditingController();
  TextEditingController foodPriceController = TextEditingController();
  TextEditingController foodPersonController = TextEditingController();
  String? foodMeal = 'เช้า';
  TextEditingController foodDateController = TextEditingController();
  String? foodImageUrl = " ";

  // ตัวแปรเก็บไฟล์ที่ใช้อัพโหลด
  File? file;

  // เปิดกล้องถ่ายภาพ
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        file = File(picked.path);
      });
    }
  }

  // เปิดปฏิทินเลือกวันที่ และกำหนดวันที่
  DateTime? selectedDate;

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    // เอาค่าวันที่เลือกจากปกิทินไปกำหนดให้กับ taskDuedatecontroller
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        foodDateController.text =
            DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Food Tracker (Add Task)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 30,
            left: 45,
            right: 45,
            bottom: 50,
          ),
          child: Center(
            child: Column(
              children: [
                // ส่วนแสดงรูปและรูปกล้องเพื่อเปิดกล้อง
                file == null
                    ? InkWell(
                        onTap: () {
                          pickImage();
                        },
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          size: 150,
                          color: Colors.grey[300],
                        ),
                      )
                    : InkWell(
                        onTap: () {
                          pickImage();
                        },
                        child: Image.file(
                          file!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินอะไร',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                // กินทำอะไร
                TextField(
                  controller: foodNameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      hintText: 'เช่น KFC, Tee Noi'),
                ),
                SizedBox(height: 20),
                // เลือกกินมื้อไหน
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินมื้อไหน',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'เช้า';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            foodMeal == 'เช้า' ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.18,
                          40,
                        ),
                      ),
                      child: Text(
                        'เช้า',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'กลางวัน';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            foodMeal == 'กลางวัน' ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.22,
                          40,
                        ),
                      ),
                      child: Text(
                        'กลางวัน',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'เย็น';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            foodMeal == 'เย็น' ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.18,
                          40,
                        ),
                      ),
                      child: Text(
                        'เย็น',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          foodMeal = 'ว่าง';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            foodMeal == 'ว่าง' ? Colors.green : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.18,
                          40,
                        ),
                      ),
                      child: Text(
                        'ว่าง',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินเท่าไหร่',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                // กินเท่าไหร่
                TextField(
                  controller: foodPriceController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      hintText: 'เช่น 9999.99'),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินกี่คน',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                // ป้อนกินกี่คน
                TextField(
                  controller: foodPersonController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      hintText: 'เช่น 2, 5'),
                ),
                SizedBox(height: 20),
                // เลือกินเมื่อไหร่
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'กินเมื่อไหร่',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                TextField(
                  controller: foodDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    hintText: 'เช่น 2025-01-01',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () {
                    pickDate();
                  },
                ),
                SizedBox(height: 20),
                // ปุ่มบันทึก
                ElevatedButton(
                  onPressed: () {
                    // ตรวจสอบว่ามีข้อมูลหรือไม่
                    if (foodNameController.text.length == 0 ||
                        foodPriceController.text.length == 0 ||
                        foodPersonController.text.length == 0 ||
                        foodDateController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('กรุณากรอกข้อมูลให้ครบ'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                      return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      50,
                    ),
                  ),
                  child: Text(
                    'บันทึกข้อมูล',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // ปุ่มยกเลิก
                ElevatedButton(
                  onPressed: () {
                    // เคลียร์หน้าจอ
                    setState(() {
                      foodNameController.clear();
                      foodPriceController.clear();
                      foodPersonController.clear();
                      foodDateController.clear();
                      foodMeal = 'เช้า';
                      file = null;
                      foodImageUrl = '';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    fixedSize: Size(
                      MediaQuery.of(context).size.width,
                      50,
                    ),
                  ),
                  child: Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
