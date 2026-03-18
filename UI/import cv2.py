# ================= THÔNG TIN CHƯƠNG TRÌNH =================
# File đầu ra:
# - noisy_image.png      : Ảnh sau khi thêm nhiễu salt & pepper
# - noisy_hex.txt        : File hex (1 pixel = 1 dòng) dùng cho Verilog


# Thư viện & dependency sử dụng:
# - tkinter              : Tạo giao diện người dùng (UI)
# - cv2 (OpenCV)         : Đọc/ghi ảnh, xử lý ảnh cơ bản
# - numpy                : Xử lý mảng và tính toán số học
# - PIL (Pillow)         : Hiển thị ảnh trong giao diện
# - skimage (scikit-image): Tính SSIM (độ tương đồng cấu trúc ảnh)
# - math                 : Hỗ trợ các phép toán (sqrt, ...)
#
# Lưu ý:
# - Cần cài thêm: pip install opencv-python numpy pillow scikit-image
import tkinter as tk
from tkinter import filedialog, messagebox
import cv2
import numpy as np
from PIL import Image, ImageTk
from skimage.metrics import structural_similarity as ssim
import math

# ================= QUÁ TRÌNH XỬ LÝ ẢNH =================

def read_gray(path):
    img = cv2.imread(path, cv2.IMREAD_GRAYSCALE)
    if img is None: return None
    h, w = img.shape
    if h > 512 or w > 512:
        scaling = 512 / max(h, w)
        img = cv2.resize(img, (int(w * scaling), int(h * scaling)))
    return img

def image_to_hex_file(img, filename):
    with open(filename, "w", encoding="utf-8") as f:
        for row in img:
            for pixel in row:
                f.write(f"{pixel:02x}\n")

# ================= TÍNH TOÁN CHỈ SỐ =================

def compute_snr(original, noisy):
    orig_f = original.astype(np.float64)
    noisy_f = noisy.astype(np.float64)
    
    signal_power = np.mean(orig_f ** 2)
    noise_power = np.mean((orig_f - noisy_f) ** 2)
    
    if noise_power == 0: return float('inf')
    return 10 * np.log10(signal_power / noise_power)

def run_compare():
    global original, compare_img
    if original is None or compare_img is None: 
        result_label.config(text="Đang chờ ảnh để so sánh...")
        return
    
    if original.shape != compare_img.shape:
        result_label.config(text="Lỗi: Kích thước 2 ảnh không khớp nhau!")
        return

    mse = np.mean((original.astype(np.float64) - compare_img.astype(np.float64)) ** 2)
    psnr = 10 * np.log10((255.0**2)/mse) if mse != 0 else float('inf')
    snr = compute_snr(original, compare_img)
    ssim_val = ssim(original, compare_img)
    
    result_label.config(
        text=f"MSE={mse:.1f} | PSNR={psnr:.1f}dB | SNR={snr:.1f}dB | SSIM={ssim_val:.3f}"
    )

# ================= GIAO DIỆN & LOGIC =================

def show(img, panel):
    if img is None: return
    img_pil = Image.fromarray(img)
    img_tk = ImageTk.PhotoImage(img_pil.resize((260, 260)))
    panel.config(image=img_tk)
    panel.image = img_tk

def load_original():
    global original
    path = filedialog.askopenfilename(title="Chọn Ảnh Gốc")
    if path:
        original = read_gray(path)
        show(original, panel_orig)
        status.config(text=f"Đã tải ảnh gốc: {original.shape[1]}x{original.shape[0]}")
        if compare_img is not None:
            run_compare()

def generate_noise():
    global original, noisy
    if original is None: 
        messagebox.showwarning("Lỗi", "Vui lòng tải ảnh gốc trước!")
        return
    noisy = original.copy()
    h, w = noisy.shape
    num = int(0.05 * h * w / 2)
    for _ in range(num):
        noisy[np.random.randint(0, h), np.random.randint(0, w)] = 255
        noisy[np.random.randint(0, h), np.random.randint(0, w)] = 0
    
    cv2.imwrite("noisy_image.png", noisy) 
    image_to_hex_file(noisy, "noisy_hex.txt") 
    
    show(noisy, panel_noise)
    status.config(text="Đã xuất file Hex. Đang chờ ảnh kết quả để so sánh.")

def hex_to_image():
    global original, compare_img
    path = filedialog.askopenfilename(title="Chọn tệp Hex (Đầu ra)", filetypes=[("Text/Hex", "*.txt *.hex")])
    if not path: return

    try:
        pixel_list = []
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                val = line.strip()
                if val: pixel_list.append(int(val, 16))
        
        total = len(pixel_list)
        if original is not None:
            h, w = original.shape
        else:
            side = int(math.sqrt(total))
            h, w = side, side
        
        if len(pixel_list) != h * w:
            messagebox.showwarning("Cảnh báo kích thước", f"Tệp Hex có {len(pixel_list)} pixel, nhưng mong đợi {w}x{h}.")
            return

        compare_img = np.array(pixel_list, dtype=np.uint8).reshape((h, w))
        cv2.imwrite("verilog_output.png", compare_img)
        
        show(compare_img, panel_comp)
        
        run_compare() 
        status.config(text="Hệ thống sẵn sàng. Đã chuyển đổi tệp Hex và xuất kết quả so sánh.")
    except Exception as e:
        messagebox.showerror("Lỗi", f"Không thể đọc tệp Hex: {e}")

def load_manual_compare():
    global compare_img
    path = filedialog.askopenfilename(title="Chọn Ảnh Đã Xử Lý")
    if path:
        compare_img = read_gray(path)
        show(compare_img, panel_comp)
        
        run_compare() 
        status.config(text="Hệ thống sẵn sàng. Đã tải ảnh và xuất kết quả so sánh.")

# ================= BỐ CỤC GIAO DIỆN (UI) =================

root = tk.Tk()
root.title("Công Cụ Xử Lý Ảnh Verilog (Tạo Hex & Đo Lường)")
root.geometry("1150x550") 

original = compare_img = noisy = None

top = tk.Frame(root, bg="#e8e8e8", pady=5)
top.pack(fill="x")

tk.Button(top, text="1. Tải Ảnh Gốc", command=load_original).pack(side="left", padx=10, expand=True)
tk.Button(top, text="2. Thêm Nhiễu + Xuất Hex", command=generate_noise).pack(side="left", padx=10, expand=True)
tk.Button(top, text="3. Chuyển Hex -> Ảnh PNG Và So Sánh", command=hex_to_image).pack(side="left", padx=10, expand=True)
tk.Button(top, text="4. Tải Ảnh Cần So Sánh", command=load_manual_compare).pack(side="left", padx=10, expand=True)

status = tk.Label(root, text="Hệ thống sẵn sàng. Vui lòng tải ảnh.", font=("Arial", 10))
status.pack(pady=5)

img_frame = tk.Frame(root)
img_frame.pack(padx=10, pady=5, expand=True)

def make_panel(title):
    f = tk.Frame(img_frame)
    f.pack(side="left", padx=10)
    tk.Label(f, text=title, font=("Arial", 10, "bold")).pack()
    
    # SỬA LỖI Ở ĐÂY: Dùng một Frame cố định pixel để ép kích thước
    container = tk.Frame(f, width=260, height=260, bg="#e0e0e0")
    container.pack_propagate(False) # Ngăn không cho ruột bên trong làm phình to khung ngoài
    container.pack()
    
    p = tk.Label(container, bg="#e0e0e0") 
    p.pack(expand=True, fill="both")
    return p

panel_orig = make_panel("Ảnh Gốc (Tối đa 512x512)")
panel_noise = make_panel("Ảnh Nhiễu / Hex (Tối đa 512x512)")
panel_comp = make_panel("Ảnh Kết Quả / So Sánh")

result_frame = tk.Frame(root, bg="#d9d9d9", bd=2, relief="sunken")
result_frame.pack(fill="x", side="bottom", padx=20, pady=15)

result_label = tk.Label(
    result_frame, 
    text="Đang chờ ảnh để so sánh...", 
    font=("Arial", 20, "bold"),
    bg="#d9d9d9",
    fg="black",
    pady=10
)
result_label.pack()

root.mainloop()

