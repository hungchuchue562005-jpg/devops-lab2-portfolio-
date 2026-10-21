# Đẩy image hiện có lên Docker Hub và kiểm tra chạy lại

## 1. Kết quả kiểm tra dự án

Ứng dụng hiện chạy đúng: `curl http://localhost:3000` trả về **HTTP 200** và JSON có `message: "Hello from Docker!"`.

| Thành phần | Giá trị thực tế |
|---|---|
| Docker | 29.6.2 |
| Container | `devops-lab2-container` |
| Image | `node:24-alpine3.24` |
| Image ID | `sha256:d32cdf619f63fe0471182d08996dd516c6275bb5fd31ae06e55a570bd9e1ad43` |
| Thư mục làm việc | `/app` |
| Lệnh chạy ứng dụng | `node service.js` |
| Cổng | `3000:3000` |
| Mã nguồn | Thư mục `configs` trên máy được mount read-only vào `/app` |

**Kết luận:** container chạy thành công, nhưng image đang dùng chỉ chứa môi trường Node.js. Mã ứng dụng nằm trong thư mục mount, chưa nằm trong image. Quy trình bên dưới giữ nguyên cách chạy này: image từ Docker Hub + thư mục `configs` hiện có → ứng dụng hoạt động.

Nếu yêu cầu là **chỉ pull image rồi chạy trên máy không có mã nguồn**, trạng thái hiện tại chưa đáp ứng. Cần một bước đóng gói ứng dụng riêng; hướng dẫn này không tự ý thực hiện bước đó.

## 2. Kiểm tra trước khi push

Chạy các lệnh trong **cùng một cửa sổ Terminal trên macOS**. Không chạy script setup hoặc build lại.

```bash
cd '/Users/redstore/Documents/devops-lab2-portfolio-'
docker --version
docker ps
docker images
curl --fail --include http://localhost:3000
```

Phải thấy container `devops-lab2-container` và HTTP 200. Nếu container đang dừng, chạy `docker start devops-lab2-container`, rồi kiểm tra lại.

## 3. Đăng nhập và gắn tag cho image hiện có

Ảnh Docker Hub xác nhận username là `hungpm5625`. Bấm **Create a Repository**, chọn namespace `hungpm5625`, nhập repository name `devops-lab2-runtime`, chọn quyền hiển thị phù hợp rồi bấm **Create**.

```bash
HUB_USER='hungpm5625'
HUB_IMAGE="$HUB_USER/devops-lab2-runtime:lab2-20261021"

docker login --username "$HUB_USER"
```

Hoàn tất đăng nhập theo hướng dẫn trong Terminal. Không gửi mật khẩu hoặc access token vào chat.

```bash
SOURCE_IMAGE_ID="$(docker container inspect --format '{{.Image}}' devops-lab2-container)"
docker tag "$SOURCE_IMAGE_ID" "$HUB_IMAGE"
docker image inspect "$SOURCE_IMAGE_ID" "$HUB_IMAGE" --format '{{.Id}}'
```

Hai dòng ID phải giống nhau. `docker tag` chỉ thêm tên cho image hiện có, không build hoặc thay đổi nội dung image.

## 4. Push rồi pull từ Docker Hub

```bash
docker push "$HUB_IMAGE"
```

Chỉ tiếp tục khi push thành công. Ghi lại `digest: sha256:...` ở cuối kết quả và kiểm tra tag `lab2-20261021` trong repository trên Docker Hub.

```bash
docker pull "$HUB_IMAGE"
PULLED_IMAGE_ID="$(docker image inspect --format '{{.Id}}' "$HUB_IMAGE")"
if [ "$SOURCE_IMAGE_ID" = "$PULLED_IMAGE_ID" ]; then
  echo 'PASS: image sau pull trùng image ban đầu'
else
  echo 'FAIL: image khác nhau; dừng tại đây'
fi
```

Digest của lần pull phải trùng digest của lần push, và phép so sánh ID phải báo `PASS`. Không tiếp tục nếu một kiểm tra thất bại. Docker có thể báo `Image is up to date` vì các layer đã có trên máy; lệnh pull vẫn kiểm tra image trên registry. Không cần xóa image cũ.

## 5. Chạy container từ image đã pull và kiểm tra

Tạm dừng container gốc để dùng lại đúng cổng `3000:3000`. Giữ nguyên thư mục mount, chế độ read-only, thư mục `/app`, entrypoint mặc định và lệnh `node service.js`.

```bash
docker stop devops-lab2-container

docker run -d --pull=never \
  --name devops-lab2-hub-verify \
  -p 3000:3000 \
  --mount "type=bind,source=$PWD/configs,target=/app,readonly" \
  --workdir /app \
  "$HUB_IMAGE" node service.js

docker ps --filter name=devops-lab2-hub-verify
docker logs --tail 10 devops-lab2-hub-verify
curl --fail --silent --show-error --include --max-time 10 http://localhost:3000
docker container inspect devops-lab2-hub-verify --format '{{.Image}}'
```

Nếu container vừa khởi động chưa kịp nhận kết nối, đợi vài giây rồi chạy lại lệnh curl.

Kết quả đạt yêu cầu cho **cách chạy hiện tại**:

- Container kiểm tra ở trạng thái `Up`, sử dụng cổng `3000:3000`.
- Image ID của container kiểm tra trùng `SOURCE_IMAGE_ID`.
- HTTP trả về `200 OK`, `Content-Type: application/json`.
- JSON có `message: "Hello from Docker!"`, `lab: "DevOps Lab 2 — Lean Principle"`, `node_version: "v24.19.0"`, `platform: "linux"` và timestamp mới.

## 6. Khôi phục container ban đầu

Sau khi kiểm tra xong, hoặc nếu bước chạy container kiểm tra gặp lỗi, thực hiện:

```bash
docker stop devops-lab2-hub-verify
docker rm devops-lab2-hub-verify
docker start devops-lab2-container
curl --fail --include http://localhost:3000
```

Nếu container kiểm tra chưa được tạo, hai lệnh đầu có thể báo `No such container`; tiếp tục lệnh start container gốc. Không xóa container gốc hoặc image gốc.

## Phạm vi và trạng thái thực hiện

- Không sửa source code, Dockerfile, Compose, package.json hoặc cấu hình môi trường.
- Không đổi cổng, lệnh ứng dụng hoặc logic; không build lại image.
- Đã kiểm tra container gốc hoạt động và trả HTTP 200.
- **Chưa thực hiện push/pull trong phiên làm việc này.** Username `hungpm5625` đã được xác nhận từ ảnh; repository hướng dẫn sử dụng là `devops-lab2-runtime`. Các bước 3–6 ở trên là hướng dẫn để chạy trong Terminal, chưa phải kết quả đã thực hiện.
- Máy khác cần có thư mục `configs` tương ứng; image hiện tại là `linux/arm64`, chưa được kiểm chứng trên kiến trúc khác.

Tham khảo: [Docker — tag và push image](https://docs.docker.com/docker-hub/repos/manage/hub-images/push/), [Docker — bind mounts](https://docs.docker.com/engine/storage/bind-mounts/).
