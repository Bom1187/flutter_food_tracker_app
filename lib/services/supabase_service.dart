// ไฟลนี้ใช้สำหรับสร้างการทำงานต่างๆกับ supabase

// CRUD กับ Table->Database(PostgreSQL)->Supabase
// ipload/delete file กับ Bucket->Storage->Supabase

import 'dart:io';

import 'package:flutter_food_tracker_app/model/food.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // สร้าง instance/object/ตัวแทน ของ supabase
  final supabase = Supabase.instance.client;

  // สร้างคำสั่ง/เมธอดการทำงานต่างๆกับ supabase
  // เมธอดดึงข้ิมูลงานทั้งหมดจาก food_tb และ return ค่าที่ได้จากการดึงไปใช้งาน
  Future<List<Food>> getFoods() async {
    // ดึงข้อมูลงานทั้งหมดจาก food_tb
    final data = await supabase.from('food_tb').select('*');

    // return ค่าข้อมูลที่ได้จากการดึงไปใช้งาน
    return data.map((food) => Food.fromJson(food)).toList();
  }

  // เมธอดอัปโหลดไฟล์ไปยัง food_bk และ return ที่อยู่รูปภาพที่ได้จาการอัปโหลดไปใช้งาน
  Future<String?> uploadFile(File file) async {
    // สร้างชื่อไฟล์ใหม่ให้ไฟล์เพื่อไม่ให้ซ้ำกัน
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}-${file.path.split('/').last}';

    // อัพโหลดไปยัง food_bk
    await supabase.storage.from('food_bk').upload(fileName, file);

    // return ที่อยู่รูปภาพที่ได้จาการอัปโหลดไปใช้งาน
    return supabase.storage.from('food_bk').getPublicUrl(fileName);
  }

  // เมธอดเพื่มข้อมูลไปยัง food_tb
  Future insetFood(Food food) async {
    // เพิ่มไปยัง food_tb
    await supabase.from('food_tb').insert(food.toJson());
  }

  // เมธอดลบไฟล์ที่อัปโหลดไปยัง food_bk
  Future deleteFile(String fileName) async {
    // ลบไฟล์ที่อัปโหลดไปยัง food_bk
    // ก่อนลบให้ตัดเลือกแค่ชื่อไฟล์ ไม่เอาที่อยู่ไฟล์
    fileName = fileName.split('/').last;
    await supabase.storage.from('food_bk').remove([fileName]);
  }

  // เมธอดแก้ไขข้อมูลใน food_tb
  Future updateFood(String id, Food food) async {
    // เพิ่มไปยัง food_tb
    await supabase.from('food_tb').update(food.toJson()).eq('id', id);
  }

  // เมธอดลบข้อมูลใน food_tb
  Future deleteFood(String id) async {
    // เพิ่มไปยัง food_tb
    await supabase.from('food_tb').delete().eq('id', id);
  }
}
