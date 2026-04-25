import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

abstract class BaseAsyncNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  final ApiService apiService;
  final String endpoint;

  BaseAsyncNotifier(this.apiService, this.endpoint) : super(const AsyncValue.loading()) {
    fetchData();
  }

  /// يجب على الـ Classes التي ترث هذا الكلاس توفير دالة التحويل
  T fromJson(Map<String, dynamic> json);

  /// دالة لتحويل العنصر إلى JSON للإرسال للـ API
  Map<String, dynamic> toJson(T item) {
    throw UnimplementedError('يرجى تطبيق دالة toJson إذا كنت تريد استخدام addItem أو updateItem');
  }

  /// جلب البيانات (GET)
  Future<void> fetchData({Map<String, dynamic>? queryParams}) async {
    state = const AsyncValue.loading();
    try {
      final response = await apiService.get(endpoint, query: queryParams);
      
      // قد يرجع الـ API البيانات مباشرة كمصفوفة أو داخل مفتاح (مثل 'data')
      List<dynamic> dataList = [];
      if (response.data is List) {
        dataList = response.data;
      } else if (response.data is Map && response.data['data'] is List) {
        dataList = response.data['data'];
      }
      
      final items = dataList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
      state = AsyncValue.data(items);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e.toString(), stackTrace);
    }
  }

  /// إضافة عنصر (POST)
  Future<bool> addItem(T item) async {
    try {
      final response = await apiService.post(endpoint, data: toJson(item));
      
      Map<String, dynamic> responseData;
      if (response.data is List) {
         responseData = response.data.first;
      } else {
         responseData = response.data;
      }

      final newItem = fromJson(responseData);
      
      // تحديث الحالة المحلية
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, newItem]);
      } else {
        await fetchData();
      }
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  /// تحديث عنصر (PUT)
  Future<bool> updateItem(dynamic id, T item) async {
    try {
      await apiService.put('$endpoint/$id', data: toJson(item));
      // الأفضل جلب البيانات من جديد لضمان التزامن
      await fetchData();
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  /// حذف عنصر (DELETE)
  Future<bool> deleteItem(dynamic id) async {
    try {
      await apiService.delete('$endpoint/$id');
      await fetchData();
      return true;
    } catch (e) {
      throw e.toString();
    }
  }
}
