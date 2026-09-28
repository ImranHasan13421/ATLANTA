import os
from PIL import Image

src_path = r"C:\Users\imran\.gemini\antigravity-ide\brain\64b0c30c-45b1-4ba7-b4d0-5ac8a749357f\.user_uploaded\media_1790599788388.jpg"
base_dir = r"F:\EzzeAi\ATLANTA"

print(f"Loading source image: {src_path}")
img = Image.open(src_path).convert("RGBA")
print(f"Source image size: {img.size}")

# 1. Save in-app asset images
assets_dir = os.path.join(base_dir, "assets", "images")
os.makedirs(assets_dir, exist_ok=True)
logo_png = os.path.join(assets_dir, "atlanta_logo.png")
img.save(logo_png, "PNG", quality=100)
print(f"Saved in-app asset: {logo_png}")

# Also save a 512x512 version
img_512 = img.resize((512, 512), Image.Resampling.LANCZOS)
img_512.save(os.path.join(assets_dir, "atlanta_logo_512.png"), "PNG")

# 2. Android Mipmaps
android_res = os.path.join(base_dir, "android", "app", "src", "main", "res")
android_sizes = {
    "mipmap-mdpi": (48, 48),
    "mipmap-hdpi": (72, 72),
    "mipmap-xhdpi": (96, 96),
    "mipmap-xxhdpi": (144, 144),
    "mipmap-xxxhdpi": (192, 192),
}
for folder, size in android_sizes.items():
    target_dir = os.path.join(android_res, folder)
    os.makedirs(target_dir, exist_ok=True)
    target_file = os.path.join(target_dir, "ic_launcher.png")
    resized = img.resize(size, Image.Resampling.LANCZOS)
    resized.save(target_file, "PNG")
    print(f"Saved Android {folder}: {size}")

# 3. Windows .ico
windows_icon_path = os.path.join(base_dir, "windows", "runner", "resources", "app_icon.ico")
ico_sizes = [(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
img.save(windows_icon_path, format="ICO", sizes=ico_sizes)
print(f"Saved Windows app_icon.ico with multi-resolutions: {ico_sizes}")

# 4. Web Icons & Favicon
web_dir = os.path.join(base_dir, "web")
web_icons_dir = os.path.join(web_dir, "icons")
os.makedirs(web_icons_dir, exist_ok=True)

favicon_path = os.path.join(web_dir, "favicon.png")
img.resize((48, 48), Image.Resampling.LANCZOS).save(favicon_path, "PNG")

for name, size in [
    ("Icon-192.png", (192, 192)),
    ("Icon-512.png", (512, 512)),
    ("Icon-maskable-192.png", (192, 192)),
    ("Icon-maskable-512.png", (512, 512)),
]:
    target = os.path.join(web_icons_dir, name)
    img.resize(size, Image.Resampling.LANCZOS).save(target, "PNG")
    print(f"Saved Web {name}: {size}")

# 5. iOS AppIcon
ios_dir = os.path.join(base_dir, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
if os.path.exists(ios_dir):
    ios_sizes = {
        "Icon-App-20x20@1x.png": (20, 20),
        "Icon-App-20x20@2x.png": (40, 40),
        "Icon-App-20x20@3x.png": (60, 60),
        "Icon-App-29x29@1x.png": (29, 29),
        "Icon-App-29x29@2x.png": (58, 58),
        "Icon-App-29x29@3x.png": (87, 87),
        "Icon-App-40x40@1x.png": (40, 40),
        "Icon-App-40x40@2x.png": (80, 80),
        "Icon-App-40x40@3x.png": (120, 120),
        "Icon-App-60x60@2x.png": (120, 120),
        "Icon-App-60x60@3x.png": (180, 180),
        "Icon-App-76x76@1x.png": (76, 76),
        "Icon-App-76x76@2x.png": (152, 152),
        "Icon-App-83.5x83.5@2x.png": (167, 167),
        "Icon-App-1024x1024@1x.png": (1024, 1024),
    }
    for filename, size in ios_sizes.items():
        target = os.path.join(ios_dir, filename)
        img.resize(size, Image.Resampling.LANCZOS).save(target, "PNG")
        print(f"Saved iOS {filename}: {size}")

print("All app logos and launcher icons generated successfully!")
