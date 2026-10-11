#!/bin/bash

# Dừng và xóa các container cũ nếu đang tồn tại (để chạy lại script không bị lỗi trùng tên)
docker rm -f db-server app-container 2>/dev/null

echo "=== 1. Tạo Custom Bridge Network: app-net ==="
docker network create app-net

echo "=== 2. Tạo Named Volume: db-data ==="
docker volume create db-data

echo "=== 3. Khởi chạy Database Container (PostgreSQL) ==="
docker run -d \
  --name db-server \
  --network app-net \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=mydb \
  postgres:15-alpine

echo "=== 4. Khởi chạy Backend Container ==="
# Sử dụng alpine làm container giả lập backend để test kết nối
docker run -d \
  --name app-container \
  --network app-net \
  -e DB_HOST=db-server \
  -e DB_USER=postgres \
  -e DB_PASSWORD=secret \
  -e DB_NAME=mydb \
  alpine tail -f /dev/null

echo "=== 5. Kiểm tra hệ thống và Network ==="
docker network ls | grep app-net
docker volume ls | grep db-data

echo "=== 6. Kiểm tra DNS Resolution (Ping từ Backend sang DB) ==="
docker exec -it app-container ping -c 2 db-server

echo "=== 7. Kiểm tra Data Persistence (Kiểm tra dữ liệu qua các bước tái tạo) ==="
# Bước 7.1: Tạo bảng và chèn dữ liệu mẫu vào PostgreSQL
docker exec -it db-server psql -U postgres -d mydb -c "CREATE TABLE IF NOT EXISTS test_table (id SERIAL PRIMARY KEY, message TEXT);"
docker exec -it db-server psql -U postgres -d mydb -c "INSERT INTO test_table (message) VALUES ('Hello from persistent storage!');"

echo "Dữ liệu trước khi xóa container DB:"
docker exec -it db-server psql -U postgres -d mydb -c "SELECT * FROM test_table;"

# Bước 7.2: Xóa cứng container DB
echo "Xóa cứng container db-server..."
docker rm -f db-server

# Bước 7.3: Khởi chạy lại container DB gắn với volume cũ
echo "Khởi chạy lại container db-server mới gắn cùng Named Volume db-data..."
docker run -d \
  --name db-server \
  --network app-net \
  -v db-data:/var/lib/postgresql/data \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=mydb \
  postgres:15-alpine

# Đợi DB khởi động hoàn tất
sleep 3

echo "Dữ liệu sau khi tái tạo container DB (Xác minh Data Persistence thành công):"
docker exec -it db-server psql -U postgres -d mydb -c "SELECT * FROM test_table;"

