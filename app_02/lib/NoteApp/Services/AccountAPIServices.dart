import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/Account.dart';

class AccountAPIService {
  static final AccountAPIService instance = AccountAPIService._init();
  // Thay <your-username> bằng username GitHub của bạn
  final String baseUrl = 'https://my-json-server.typicode.com/khanhvan-cmd/notetaikhoan';

  // Danh sách nội bộ để lưu trữ tài khoản
  List<Account> _localAccounts = [];

  AccountAPIService._init() {
    // Khởi tạo dữ liệu tài khoản từ API
    _initializeAccounts();
  }

  // Khởi tạo dữ liệu tài khoản từ API
  Future<void> _initializeAccounts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/accounts'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        _localAccounts = jsonList.map((json) => Account.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load accounts: ${response.statusCode}');
      }
    } catch (e) {
      // Nếu API không hoạt động, sử dụng dữ liệu mặc định
      _localAccounts = [
        Account(
          id: 1,
          userId: 1,
          username: "admin",
          password: "admin123",
          status: "active",
          lastLogin: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
        ),
        Account(
          id: 2,
          userId: 2,
          username: "user1",
          password: "user123",
          status: "active",
          lastLogin: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
        ),
      ];
    }
  }

  // Create - Thêm account mới (dùng cho đăng ký)
  Future<Account> createAccount(Account account) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accounts'),
        headers: {'Content-Type': 'application/json'},
        body: account.toJSON(),
      );

      if (response.statusCode == 201) {
        final newAccount = Account.fromJSON(response.body);
        _localAccounts.add(newAccount);
        return newAccount;
      } else {
        throw Exception('Failed to create account: ${response.statusCode}');
      }
    } catch (e) {
      // Mô phỏng thêm tài khoản vào danh sách nội bộ
      final newAccount = account.copyWith(
        id: _localAccounts.length + 1,
        userId: _localAccounts.length + 1,
      );
      _localAccounts.add(newAccount);
      return newAccount;
    }
  }

  // Read - Đọc tất cả accounts
  Future<List<Account>> getAllAccounts() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/accounts'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        _localAccounts = jsonList.map((json) => Account.fromMap(json)).toList();
        return _localAccounts;
      } else {
        throw Exception('Failed to load accounts: ${response.statusCode}');
      }
    } catch (e) {
      // Nếu API không hoạt động, trả về danh sách nội bộ
      return _localAccounts;
    }
  }

  // Read - Đọc account theo id
  Future<Account?> getAccountById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/accounts/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Account.fromMap(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get account: ${response.statusCode}');
      }
    } catch (e) {
      // Tìm trong danh sách nội bộ
      return _localAccounts.firstWhere((account) => account.id == id, orElse: () => null as Account);
    }
  }

  // Read - Đọc account theo userId
  Future<Account?> getAccountByUserId(int userId) async {
    try {
      return _localAccounts.firstWhere((account) => account.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Update - Cập nhật account
  Future<Account> updateAccount(Account account) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/accounts/${account.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(account.toMap()),
      );

      if (response.statusCode == 200) {
        final updatedAccount = Account.fromMap(jsonDecode(response.body));
        final index = _localAccounts.indexWhere((a) => a.id == updatedAccount.id);
        if (index != -1) {
          _localAccounts[index] = updatedAccount;
        }
        return updatedAccount;
      } else {
        throw Exception('Failed to update account: ${response.statusCode}');
      }
    } catch (e) {
      // Mô phỏng cập nhật trong danh sách nội bộ
      final index = _localAccounts.indexWhere((a) => a.id == account.id);
      if (index != -1) {
        _localAccounts[index] = account;
      }
      return account;
    }
  }

  // Delete - Xoá account
  Future<bool> deleteAccount(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/accounts/$id'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        _localAccounts.removeWhere((account) => account.id == id);
        return true;
      } else {
        throw Exception('Failed to delete account: ${response.statusCode}');
      }
    } catch (e) {
      // Mô phỏng xóa trong danh sách nội bộ
      _localAccounts.removeWhere((account) => account.id == id);
      return true;
    }
  }

  // Đăng nhập - Xác thực tài khoản
  Future<Account?> login(String username, String password) async {
    final accounts = await getAllAccounts();
    try {
      final account = accounts.firstWhere(
            (account) => account.username == username && account.password == password && account.status == 'active',
      );

      // Cập nhật thời gian đăng nhập gần nhất
      final updatedAccount = account.copyWith(lastLogin: DateTime.now().toIso8601String());
      await updateAccount(updatedAccount);

      return updatedAccount;
    } catch (e) {
      return null;
    }
  }

  // Kiểm tra tài khoản tồn tại (dùng cho đăng ký)
  Future<bool> isUsernameExists(String username) async {
    final accounts = await getAllAccounts();
    return accounts.any((account) => account.username == username);
  }
}