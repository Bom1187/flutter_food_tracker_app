import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_food_tracker_app/model/food.dart';
import 'package:flutter_food_tracker_app/services/supabase_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UpdateDeleteUi extends StatefulWidget {
  // สร้างตัวแปรเพื่อรับข้อมูลของรายกรายการทที่ถูกกดจากหน้า ShowAllFoodUi
  Food? food;

  // เอาตัวแปรที่สร้างมารับค่าที่ส่งมาจากหน้า ShowAllFoodUi
  UpdateDeleteUi({super.key, this.food});

  @override
  State<UpdateDeleteUi> createState() => _UpdateDeleteUiState();
}

class _UpdateDeleteUiState extends State<UpdateDeleteUi> {
  // สร้างตัวควบคุม textfield และตัวแปรที่ต้องเก็บข้อมูลตอนป้อนหรือเลือก เพื่อบันทึกไว้ใน food_tb
  TextEditingController foodNameController = TextEditingController();
  TextEditingController foodPriceController = TextEditingController();
  TextEditingController foodPersonController = TextEditingController();
  String? foodMeal = 'เช้า';
  TextEditingController foodDateController = TextEditingController();
  String? foodImageUrl = "";

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
  // เปิดปฏิทิน
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    // เอาค่าวันที่เลือกจากปกิทินไปกำหนดให้กับ foodDuedatecontroller
    if (picked != null) {
      setState(
        () {
          selectedDate = picked;
          foodDateController.text =
              DateFormat('yyyy-MM-dd').format(selectedDate!);
        },
      );
    }
  }

  // เมธอดอัปโหลดไฟล์และบันทึกข้อมูล
  Future<void> update() async {
    // varidate ui ว่าผู้ใช้งานป้อนข้อมูลต่างๆครบมั้ย
    if (foodNameController.text.isEmpty ||
        foodPriceController.text.isEmpty ||
        foodPersonController.text.isEmpty ||
        foodDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบ'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // สร้าง instance/object/ตัวแทนของ supabease service เพื่อใช้งานเมธอดต่างๆ ที่สร้างไว้ใน SupabaseService
    final service = SupabaseService();

    // ตรวจสอบว่ามีการถ่าย/เลือกรูปมั้ย ถ้ามีก็อัปโหลดไฟล์ไปยัง tasl_bk
    // แล้วเอา URL ของไฟล์ที่อัปโหลดเก็บในตัวแปรเพื่อใช้บันทึกใน food_tb
    if (file != null) {
      // ต้องตรวจสอบก่อนว่าเดิมทีแบ้วมีรูปอยู่หรือไม่ ถ้ามีให้ลบออกจาก storage ก่อน
      if (widget.food!.foodImageUrl != null) {
        // หากพิสูจน์เป็นจริงว่ามีรูปเดิมอยู่ให้ลบทิ้ง
        await service.deleteFile(widget.food!.foodImageUrl!);
      }

      // หาก file ไม่เท่ากับ null แปลว่าได้มีการถ่ายภาพ/เลือกรูป
      // อัปโหลดไฟล์ไปยัง food_bk
      foodImageUrl = await service.uploadFile(file!);
    }

    // บันทึกข้อมูลง food_tb
    // แพ็กข้อมูล
    final food = Food(
      foodName: foodNameController.text,
      foodPrice: int.parse(foodPriceController.text),
      foodPerson: int.parse(foodPersonController.text),
      foodDate: foodDateController.text,
      foodMeal: foodMeal,
      foodImageUrl: foodImageUrl,
    );

    // เรียกใช้เมธอด updateFood ใน SupabaseService เพื่อบันทึกข้อมูลลงไปใน supabase
    await service.updateFood(widget.food!.id!, food);

    // แจ้งผลการทำงาน (แสดงเป็น snackbar หรือ alertdialog)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกข้อมูลแก้ไข สำเร็จ'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // เมธอดลบข้อมูล
  Future<void> delete() async {
    // แสดง pop up ถามผู้ใช้ก่อนเพื่อยืนยันการลบข้อมูล
    await showDialog<void>(
      context: context,
      barrierDismissible: false, //เป็นการ disable การใช้งานปุ่ม < ใน android
      builder: (context) => AlertDialog(
        // หน้าตาของ pop up
        title: Text('ยืนยันการลบข้อมูล'),
        content: Text('คุณต้องการลบข้อมูลหรือไม่?'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ลบรูปออกจาก storage กรณีมีรูป
              // สร้าง instance/object/ตัวแทนของ supabease service เพื่อใช้งานเมธอดต่างๆ ที่สร้างไว้ใน SupabaseService
              final service = SupabaseService();

              // ลบรูปออกจาก supabase ถ้ามีรูป
              if (widget.food!.foodImageUrl != '') {
                // หากพิสูจน์เป็นจริงว่ามีรูปเดิมอยู่ให้ลบทิ้ง
                await service.deleteFile(widget.food!.foodImageUrl!);
              }

              // ลบข้อมูลออกจาก database
              await service.deleteFood(widget.food!.id!);

              // แสดงข้อความแจ้งผลการทำงาน
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ลบข้อมูลสำเร็จ'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // ปิด dialog
              Navigator.pop(context);
            },
            child: Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    foodNameController.text = widget.food!.foodName!;
    foodPriceController.text = widget.food!.foodPrice.toString();
    foodPersonController.text = widget.food!.foodPerson.toString();
    foodDateController.text = widget.food!.foodDate!;
    foodMeal = widget.food!.foodMeal!;
    foodImageUrl = widget.food!.foodImageUrl!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text(
          'Food Tracker (Add Food)',
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
                // file == null เดิมจากหน้า add food
                file != null
                    ? InkWell(
                        onTap: () {
                          pickImage();
                        },
                        child: Image.file(
                          file!,
                          width: 150,
                          height: 150,
                        ),
                      )
                    : foodImageUrl == ''
                        ? InkWell(
                            onTap: () {
                              pickImage();
                            },
                            child: Image.asset(
                              'assets/images/logo1.png',
                              width: 150,
                              height: 150,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              pickImage();
                            },
                            child: Image.network(
                              foodImageUrl!,
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
                    update().then((value) {
                      Navigator.pop(context);
                    });
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
                    'บันทึกแก้ไข',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // ปุ่มลบ
                ElevatedButton(
                  onPressed: () {
                    // ลบข้อมูล
                    setState(
                      () {
                        delete().then((value) {
                          Navigator.pop(context);
                        });
                      },
                    );
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
                    'ลบ',
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
    ;
  }
}
