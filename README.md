# 🌸 手势花朵 + ❤️ 手势爱心 — 双手粒子交互

通过摄像头同时识别**双手**：左手张开 → 花朵粒子绽放，右手张开 → 爱心粒子绽放；两只手一起向镜头靠近、不断「放大」时，画面会自动推进到粒子内部，形成钻进粒子云团的效果。

## 技术栈

| 层 | 技术 |
|---|---|
| 3D 粒子渲染 | **Three.js**（已本地化到 `libs/three/`） |
| 手势识别 | **MediaPipe Hands**（已本地化到 `libs/hands/`，含 wasm） |
| 运行环境 | 原生 HTML/CSS/JS，PWA（可添加到手机主屏幕） |

> 依赖已全部下载到本地，不再依赖 unpkg / jsdelivr CDN，国内网络和手机上加载更稳。

## 目录结构

```
hand-flower/
├── index.html               主页面（HTML/CSS/JS 全在里面）
├── manifest.webmanifest     PWA 配置（应用名/图标/全屏）
├── sw.js                    Service Worker 离线缓存
├── icons/                   应用图标（192/512/180/maskable）
├── libs/
│   ├── three/three.module.js
│   └── hands/               MediaPipe Hands 的 js + wasm + data + tflite 模型
│       ├── hand_landmark_lite.tflite   （当前使用，约 2MB）
│       ├── hand_landmark_full.tflite   （备用高精度，约 5.5MB，默认不加载）
│       └── hands_solution_*.wasm / *.data
├── make_icons.py            图标生成脚本（改样式后重跑）
├── upload.bat               一键推送到 GitHub Pages
└── README.md
```

> 关键坑：MediaPipe 是通过 `locateFile` 去取 `hand_landmark_lite.tflite`（单数 hand_）。少这个文件不会报「文件缺失」，而是把 404 页面当模型喂进去，报 `model identifier 'CTYP'`，最后整个识别不可用。

## 电脑上本地预览

```bash
cd hand-flower
python -m http.server 8080
```

浏览器打开 `http://localhost:8080`（localhost 属于安全上下文，可以用摄像头）。

## 📱 发到手机上用（推荐：GitHub Pages + 添加到主屏幕）

手机浏览器**只在 HTTPS 下允许开摄像头**，所以用 `http://电脑IP:8080` 在手机上是打不开摄像头的。最省事的做法是放到 GitHub Pages：

### 第 1 步：在 GitHub 建一个空仓库

打开 https://github.com/new

- Repository name 填 `hand-flower`
- 选 **Public**
- **不要**勾选 README / .gitignore / license
- 点 Create repository

### 第 2 步：双击 `upload.bat`

脚本会自动初始化仓库、提交并推送。过程中可能弹出浏览器让你登录 GitHub，点 **Authorize** 即可。

### 第 3 步：开启 GitHub Pages

打开 https://github.com/zhangshengdong86-arch/hand-flower/settings/pages

- Source 选 `Deploy from a branch`
- Branch 选 `main`，目录选 `/ (root)`
- 点 Save

等 1 分钟左右，访问：

```
https://zhangshengdong86-arch.github.io/hand-flower/
```

### 第 4 步：添加到主屏幕

- **Android Chrome**：右上角菜单 → 添加到主屏幕
- **iPhone Safari**：分享按钮 → 添加到主屏幕

之后从桌面图标打开就是全屏应用，没有浏览器地址栏。

> 第一次打开需要下载约 14MB 资源（Three.js 1.3MB + MediaPipe wasm 6MB + 资源包 4.3MB + 轻量模型 2MB），耐心等加载圈转完；Service Worker 会缓存，之后秒开且可离线使用。

## 手势操作

| 手势 | 效果 |
|---|---|
| ✋ **左手张开** | 左侧花朵粒子向外绽放 |
| ✊ **左手握拳** | 花朵收拢为花苞 |
| ✋ **右手张开** | 右侧爱心粒子绽放 |
| ✊ **右手握拳** | 爱心收拢 |
| 👆 **移动食指** | 对应形状跟随指尖位置 |
| 🔍 **手靠近镜头（放大）** | 镜头推进，粒子在 z 轴展开成立体云团，可以直接钻进粒子内部 |
| 🚪 **手离开镜头** | 镜头自动退回，形状原地缓慢呼吸 |

> 若发现左右手对应的形状反了，把 `index.html` 里的 `SWAP_HANDEDNESS` 改成 `false` 即可。

## 效果说明

- **花朵（左手）**：5 片花瓣，粉色渐变粒子，贝塞尔曲线形状，花心深粉→尖端浅粉
- **爱心（右手）**：2200 个红色系粒子，使用心形参数曲线 `x=16sin³t, y=13cos t−5cos2t−2cos3t−cos4t`，表面 + 内部填充
- **飘散光点**：200 个浮游粒子，跟随双手平均位置
- **手指光环**：食指指尖周围的光晕环（花朵/爱心各自独立）
- **进入粒子内部**：手在画面中越大，镜头越推进（z 6 → 1.4），粒子同时在 z 轴展开成立体云团，镜头被粒子包围
- **背景星空**：600 颗暗色星空粒子
- **Additive Blending**：所有粒子使用叠加混合，产生发光效果
- **摄像头小窗**：右下角实时预览（镜像）

## 更新代码后

改了 `index.html` 或样式后：

1. 本地刷新测试
2. 把 `sw.js` 第一行的 `CACHE` 版本号 +1（例如 `hand-flower-v1` → `hand-flower-v2`），否则手机上会一直用旧缓存
3. 双击 `upload.bat` 重新推送

## 性能

总粒子数约 5000（花朵 2150 + 爱心 2200 + 光点/光环/星空约 900），桌面端 60fps；中端手机约 30–50fps。