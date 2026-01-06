# Giải thích theo **Riverpod 2.x** (chuẩn hiện nay).

---

## 1️⃣ `ref.watch()`

### 👉 Lắng nghe provider & **tự động rebuild**

```dart
final state = ref.watch(recordingProvider);
```

### Dùng khi:

* UI cần **rebuild khi state thay đổi**
* Logic phụ thuộc vào provider khác

### Đặc điểm

* 🔄 Rebuild khi provider đổi
* ⚠️ Không dùng trong callback (`onPressed`, `initState`…)

---

## 2️⃣ `ref.read()`

### 👉 Đọc giá trị **1 lần**, không rebuild

```dart
ref.read(recordingProvider.notifier).start();
```

### Dùng khi:

* Gọi method
* Trigger action
* Event handler

### Đặc điểm

* ❌ Không lắng nghe
* ✅ Dùng an toàn trong callback

---

## 3️⃣ `ref.listen()`

### 👉 Nghe provider để **làm side-effect**

```dart
ref.listen(recordingProvider, (prev, next) {
  if (!prev!.isRecording && next.isRecording) {
    showToast("Start recording");
  }
});
```

### Dùng khi:

* Show dialog
* Snackbar
* Navigation
* Log
* Analytics

### Đặc điểm

* ❌ Không rebuild UI
* ✅ Dùng cho side-effect

---

## 4️⃣ `ref.listenManual()`

### 👉 Listen nhưng **tự quản lý lifecycle**

```dart
final sub = ref.listenManual(recordingProvider, (prev, next) {
  print(next);
});

// dispose khi cần
sub.close();
```

### Dùng khi:

* Nghe provider trong service
* Không gắn với widget lifecycle

---

## 5️⃣ `ref.invalidate()`

### 👉 **Reset provider** (dispose + tạo lại)

```dart
ref.invalidate(recordingProvider);
```

### Dùng khi:

* Logout
* Reset form
* Clear cache
* Reload data

📌 Provider sẽ được recreate **lần tiếp theo khi watch/read**

---

## 6️⃣ `ref.refresh()`

### 👉 Vừa **invalidate + đọc lại ngay**

```dart
ref.refresh(userProvider);
```

### So với `invalidate`

| Method       | Behavior                |
| ------------ | ----------------------- |
| `invalidate` | reset, chờ lần dùng sau |
| `refresh`    | reset + chạy lại ngay   |

---

## 7️⃣ `ref.onDispose()`

### 👉 Đăng ký cleanup logic

```dart
ref.onDispose(() {
  controller.dispose();
});
```

### Dùng khi:

* Dispose controller
* Cancel timer
* Close stream
* Cleanup resource

---

## 8️⃣ `ref.keepAlive()` (AutoDispose)

### 👉 Ngăn provider bị dispose

```dart
final provider = StateNotifierProvider.autoDispose<...>((ref) {
  ref.keepAlive();
  return MyNotifier();
});
```

### Dùng khi:

* Muốn giữ state khi chuyển screen
* Cache data tạm

---

## 9️⃣ `ref.exists()`

### 👉 Kiểm tra provider đã từng được tạo chưa

```dart
if (ref.exists(userProvider)) {
  ...
}
```

### Dùng khi:

* Logic nâng cao
* Debug / conditional behavior

---

## 🔟 `ref.dependsOn()`

### 👉 Khai báo **dependency tường minh**

```dart
ref.dependsOn(authProvider);
```

### Dùng khi:

* Provider cần rebuild khi provider khác đổi
* Nhưng **không cần giá trị**

---

## 1️⃣1️⃣ `ref.container`

### 👉 Truy cập `ProviderContainer`

```dart
ref.container.read(otherProvider);
```

### Dùng khi:

* Advanced usage
* Testing
* Custom container

---

## 1️⃣2️⃣ `ref.mounted`

### 👉 Kiểm tra provider còn sống hay không

```dart
if (!ref.mounted) return;
```

### Dùng khi:

* Async logic
* Tránh set state khi provider đã dispose

---

## 🧠 Bảng tổng hợp nhanh

| Method       | Mục đích         |
| ------------ | ---------------- |
| `watch`      | Rebuild UI       |
| `read`       | Gọi action       |
| `listen`     | Side-effect      |
| `invalidate` | Reset provider   |
| `refresh`    | Reset + chạy lại |
| `onDispose`  | Cleanup          |
| `keepAlive`  | Giữ state        |
| `mounted`    | Safe async       |
| `container`  | Advanced         |
| `dependsOn`  | Dependency       |
| `exists`     | Kiểm tra tồn tại |

---
