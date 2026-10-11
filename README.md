# Bài 4: Thiết lập Custom Network & Named Volume bằng Docker CLI

### Bước 1: Cấp quyền thực thi cho script

```bash
chmod +x commands.sh

```

### Bước 2: Chạy script tự động

```bash
./commands.sh

```

## Kiểm tra kết quả thủ công

1. **Kiểm tra Network và Volume:**

```bash
docker network ls | grep app-net
docker volume ls | grep db-data

```

2. **Kiểm tra cấu trúc mạng chi tiết:**

```bash
docker network inspect app-net

```

3. **Kiểm tra kết nối nội bộ (DNS resolution):**

```bash
docker exec -it app-container ping -c 2 db-server

```

_Kết quả mong đợi:_ Lệnh `ping` phân giải thành công tên `db-server` thành địa chỉ IP nội bộ của container cơ sở dữ liệu. 4. **Kiểm tra tính bền vững của dữ liệu (Data Persistence):**

- Dữ liệu lưu trong PostgreSQL được mount vào Named Volume `db-data`.
- Khi xóa container (`docker rm -f db-server`) và khởi chạy lại container mới sử dụng chung `db-data`, dữ liệu trong bảng `test_table` vẫn được giữ nguyên vẹn.
