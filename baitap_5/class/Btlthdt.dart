/*
Bài 4: Xây dựng Hệ thống Quản lý Cửa hàng Bán điện thoại
Mô tả hệ thống:
Xây dựng một hệ thống quản lý cửa hàng bán điện thoại đơn giản, cho phép:
•	Quản lý thông tin điện thoại
•	Quản lý hóa đơn bán hàng
•	Tính toán doanh thu, lợi nhuận
Yêu cầu thiết kế:
1. Lớp DienThoai (Sản phẩm):
•	Thuộc tính private: 
o	Mã điện thoại (String)
o	Tên điện thoại (String)
o	Hãng sản xuất (String)
o	Giá nhập (double)
o	Giá bán (double)
o	Số lượng tồn kho (int)
o	Trạng thái (boolean - còn kinh doanh hay không)
•	Yêu cầu: 
o	Constructor đầy đủ tham số
o	Getter/setter cho tất cả thuộc tính với validation: 
	Mã điện thoại: không rỗng, định dạng "DT-XXX"
	Tên và hãng: không rỗng
	Giá nhập/bán: > 0, giá bán > giá nhập
	Số lượng tồn: >= 0
o	Phương thức tính lợi nhuận dự kiến
o	Phương thức hiển thị thông tin
o	Phương thức kiểm tra có thể bán không (còn hàng và đang kinh doanh)
2. Lớp HoaDon (Hóa đơn bán hàng):
•	Thuộc tính private: 
o	Mã hóa đơn (String)
o	Ngày bán (DateTime)
o	Điện thoại được bán (DienThoai)
o	Số lượng mua (int)
o	Giá bán thực tế (double)
o	Tên khách hàng (String)
o	Số điện thoại khách (String)
•	Yêu cầu: 
o	Constructor đầy đủ tham số
o	Getter/setter với validation: 
	Mã hóa đơn: không rỗng, định dạng "HD-XXX"
	Ngày bán: không sau ngày hiện tại
	Số lượng mua: > 0 và <= tồn kho
	Giá bán thực tế: > 0
	Thông tin khách: không rỗng, SĐT đúng định dạng
o	Phương thức tính tổng tiền
o	Phương thức tính lợi nhuận thực tế
o	Phương thức hiển thị thông tin hóa đơn
3. Lớp CuaHang (Quản lý):
•	Thuộc tính private: 
o	Tên cửa hàng (String)
o	Địa chỉ (String)
o	Danh sách điện thoại (List<DienThoai>)
o	Danh sách hóa đơn (List<HoaDon>)
•	Yêu cầu: 
o	Constructor với tên và địa chỉ
o	Các phương thức quản lý điện thoại: 
	Thêm điện thoại mới
	Cập nhật thông tin điện thoại
	Ngừng kinh doanh điện thoại
	Tìm kiếm điện thoại (theo mã, tên, hãng)
	Hiển thị danh sách điện thoại
o	Các phương thức quản lý hóa đơn: 
	Tạo hóa đơn mới (tự động cập nhật tồn kho)
	Tìm kiếm hóa đơn (theo mã, ngày, khách hàng)
	Hiển thị danh sách hóa đơn
o	Các phương thức thống kê: 
	Tính tổng doanh thu theo khoảng thời gian
	Tính tổng lợi nhuận theo khoảng thời gian
	Thống kê top điện thoại bán chạy
	Thống kê tồn kho
Yêu cầu testing:
Xây dựng lớp Test để kiểm thử các tính năng:
1.	Tạo và quản lý thông tin điện thoại: 
o	Thêm điện thoại mới
o	Cập nhật thông tin
o	Kiểm tra validation
2.	Tạo và quản lý hóa đơn: 
o	Tạo hóa đơn hợp lệ
o	Kiểm tra các ràng buộc (tồn kho, validation)
o	Tính toán tiền và lợi nhuận
3.	Thống kê báo cáo: 
o	Doanh thu theo thời gian
o	Lợi nhuận theo thời gian
o	Top bán chạy
o	Báo cáo tồn kho
Yêu cầu chung:
1.	Áp dụng tính đóng gói: 
o	Thuộc tính private
o	Getter/setter với validation
2.	Xử lý ngoại lệ: 
o	Validation dữ liệu
o	Kiểm tra tồn kho
o	Kiểm tra ràng buộc nghiệp vụ
3.	Clean code: 
o	Đặt tên biến/phương thức rõ ràng
o	Comment đầy đủ
o	Tổ chức code hợp lý
Gợi ý cách làm:
1.	Phân tích yêu cầu và thiết kế lớp
2.	Xây dựng từng lớp theo thứ tự: DienThoai → HoaDon → CuaHang
3.	Viết các phương thức cơ bản trước, nâng cao sau
4.	Tạo dữ liệu test và kiểm thử từng chức năng
Lưu ý: Đây là bài tập thực hành, sinh viên cần tự implement mã nguồn.


*/

import 'dart:convert';
import 'dart:io';

class DienThoai {
  String maDT;
  String tenDT;
  String hangSX;
  double giaNhap;
  double giaBan;
  int soLuongTon;
  bool trangThai;

  DienThoai(
    this.maDT,
    this.tenDT,
    this.hangSX,
    this.giaNhap,
    this.giaBan,
    this.soLuongTon,
    this.trangThai,
  );

  double tinhLoiNhuan() => giaBan - giaNhap;

  void hienThiThongTin() {
    print(
      "Mã: $maDT | Tên: $tenDT | Hãng: $hangSX | Giá nhập: $giaNhap | Giá bán: $giaBan | Tồn kho: $soLuongTon | ${trangThai ? 'Còn kinh doanh' : 'Ngừng kinh doanh'}",
    );
  }
}

class HoaDon {
  String maHD;
  DateTime ngayBan;
  DienThoai dienThoai;
  int soLuongMua;
  double giaBanThucTe;
  String tenKH;
  String soDienThoaiKH;

  HoaDon(
    this.maHD,
    this.ngayBan,
    this.dienThoai,
    this.soLuongMua,
    this.giaBanThucTe,
    this.tenKH,
    this.soDienThoaiKH,
  );

  double tinhTongTien() => soLuongMua * giaBanThucTe;
  double tinhLoiNhuanThucTe() =>
      soLuongMua * (giaBanThucTe - dienThoai.giaNhap);

  void hienThiThongTin() {
    print(
      "Mã hóa đơn: $maHD | Ngày: $ngayBan | Khách hàng: $tenKH | Số điện thoại: $soDienThoaiKH | Điện thoại: ${dienThoai.tenDT} | Số lượng: $soLuongMua | Tổng tiền: \${tinhTongTien()} | Lợi nhuận: \${tinhLoiNhuanThucTe()}",
    );
  }
}

class CuaHang {
  String tenCH;
  String diaChi;
  List<DienThoai> dsDienThoai = [];
  List<HoaDon> dsHoaDon = [];

  CuaHang(this.tenCH, this.diaChi);

  void themDienThoai(DienThoai dt) => dsDienThoai.add(dt);
  void hienThiDanhSachDienThoai() =>
      dsDienThoai.forEach((dt) => dt.hienThiThongTin());

  void taoHoaDon(HoaDon hd) {
    dsHoaDon.add(hd);
    hd.dienThoai.soLuongTon -= hd.soLuongMua;
  }

  void hienThiDanhSachHoaDon() {
    print("\nDANH SÁCH HÓA ĐƠN:");
    print(
      "---------------------------------------------------------------------------------------------",
    );
    print(
      "| Mã HD | Ngày | Khách hàng | SĐT | Điện thoại | SL | Tổng tiền | Lợi nhuận |",
    );
    print(
      "---------------------------------------------------------------------------------------------",
    );
    dsHoaDon.forEach((hd) {
      print(
        "| ${hd.maHD} | ${hd.ngayBan} | ${hd.tenKH} | ${hd.soDienThoaiKH} | ${hd.dienThoai.tenDT} | ${hd.soLuongMua} | ${hd.tinhTongTien()} | ${hd.tinhLoiNhuanThucTe()} |",
      );
    });
    print(
      "---------------------------------------------------------------------------------------------",
    );
  }

  void locHoaDonTheoNgay(DateTime tuNgay, DateTime denNgay) {
    var ketQua =
        dsHoaDon
            .where(
              (hd) =>
                  hd.ngayBan.isAfter(tuNgay) && hd.ngayBan.isBefore(denNgay),
            )
            .toList();
    ketQua.forEach((hd) => hd.hienThiThongTin());
  }

  void locHoaDonTheoKhachHang(String tenKhach) {
    var ketQua =
        dsHoaDon
            .where(
              (hd) => hd.tenKH.toLowerCase().contains(tenKhach.toLowerCase()),
            )
            .toList();
    ketQua.forEach((hd) => hd.hienThiThongTin());
  }

  void xuatHoaDonCSV(String filePath) {
    var file = File(filePath);
    var csv =
        "Mã hóa đơn, Ngày, Khách hàng, Số điện thoại, Điện thoại, Số lượng, Tổng tiền, Lợi nhuận\n";
    dsHoaDon.forEach((hd) {
      csv +=
          "${hd.maHD},${hd.ngayBan},${hd.tenKH},${hd.soDienThoaiKH},${hd.dienThoai.tenDT},${hd.soLuongMua},${hd.tinhTongTien()},${hd.tinhLoiNhuanThucTe()}\n";
    });
    file.writeAsStringSync(csv);
    print("Xuất hóa đơn ra $filePath thành công!");
  }

  void xuatHoaDonJSON(String filePath) {
    var file = File(filePath);
    var jsonData =
        dsHoaDon
            .map(
              (hd) => {
                "maHD": hd.maHD,
                "ngayBan": hd.ngayBan.toString(),
                "tenKH": hd.tenKH,
                "soDienThoaiKH": hd.soDienThoaiKH,
                "dienThoai": hd.dienThoai.tenDT,
                "soLuongMua": hd.soLuongMua,
                "tongTien": hd.tinhTongTien(),
                "loiNhuan": hd.tinhLoiNhuanThucTe(),
              },
            )
            .toList();
    file.writeAsStringSync(jsonEncode(jsonData));
    print("Xuất hóa đơn ra $filePath thành công!");
  }
}

void main() {
  var cuaHang = CuaHang("Cửa hàng ABC", "123 Đà Nẵng");

  var dt1 = DienThoai(
    "DT-001",
    "iPhone 13",
    "Apple",
    15000000,
    20000000,
    10,
    true,
  );
  var dt2 = DienThoai(
    "DT-002",
    "Galaxy S21",
    "Samsung",
    12000000,
    18000000,
    5,
    true,
  );
  cuaHang.themDienThoai(dt1);
  cuaHang.themDienThoai(dt2);

  var hoaDon1 = HoaDon(
    "HD-001",
    DateTime.now(),
    dt1,
    2,
    20000000,
    "Nguyễn Thị Khánh Vân",
    "0123456789",
  );
  cuaHang.taoHoaDon(hoaDon1);

  cuaHang.hienThiDanhSachHoaDon();

  cuaHang.xuatHoaDonCSV("hoadon.csv");
  cuaHang.xuatHoaDonJSON("hoadon.json");
}
