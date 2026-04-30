# AI 健身助手

一款基于 AI 大模型的健身规划与饮食计划生成 App。

## 功能特点

- 🏋️ AI 生成个性化每周健身计划
- 🥗 AI 生成科学饮食计划
- 🎨 卡通可爱 UI 风格
- 📸 计划导出为精美图片
- 🎭 多款内置背景模板
- 🔧 支持多种 OpenAI 兼容 API

## 快速开始

### 1. 安装 Flutter

确保已安装 Flutter SDK 3.x 或更高版本：
```bash
flutter --version
```

### 2. 安装依赖

```bash
cd fitness_app
flutter pub get
```

### 3. 运行 App

```bash
flutter run
```

### 4. 构建 APK

```bash
flutter build apk --release
```

生成的 APK 位于 `build/app/outputs/flutter-apk/app-release.apk`

## API 配置

支持所有 OpenAI 兼容接口，常用配置：

| 服务商 | API 地址 | 模型名 |
|--------|---------|--------|
| DeepSeek | https://api.deepseek.com/v1 | deepseek-chat |
| 通义千问 | https://dashscope.aliyuncs.com/compatible-mode/v1 | qwen-turbo |
| ChatGPT | https://api.openai.com/v1 | gpt-3.5-turbo |

## 项目结构

```
lib/
├── main.dart              # 入口
├── app.dart               # App 配置和主题
├── config/                # 配置
├── models/                # 数据模型
├── services/              # API 和工具服务
├── providers/             # 状态管理
├── screens/               # 页面
└── widgets/               # 可复用组件
```
