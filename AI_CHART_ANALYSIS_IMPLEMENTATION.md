# 命盘 AI 分析功能实现说明

## 功能概述

在"盘"页面（`JingAstrolabeView`）中，点击12宫的中间区域时，触发 AI 分析用户命盘的功能。

## 实现方案

### 1. Swift 层修改（`JingAstrolabeView.swift`）

#### 1.1 Coordinator 扩展
- 添加 `webView` 弱引用，用于调用 JavaScript 函数
- 添加 `aiStreamTask` 用于管理 AI 流式请求任务
- 在 `userContentController(_:didReceive:)` 中添加 `analyzeChart` 动作处理

#### 1.2 AI 分析核心方法

**`startChartAnalysis(ownerName:chartJSON:)`**
- 取消之前的 AI 任务
- 验证 AI 配置（Base URL、API Key、模型）
- 解析命盘 JSON 数据
- 构建系统提示词
- 调用 `OpenAICompatibleStreamer.streamChatCompletion` 发起流式请求
- 每个 token 通过 `appendAIToken()` 回传给 WebView

**`buildSystemPrompt(ownerName:chartObject:)`**
- 从命盘 JSON 中提取：
  - 八字四柱（年月日时的天干地支）
  - 紫微斗数十二宫信息（宫位、主星、副星）
  - 命宫、身宫位置
  - 五行局、阴阳属性
  - 当前流年信息
- 构建完整的系统提示词，包含：
  - 专家角色定位
  - 基础命理规则（五行生克、十神、紫微斗数规则）
  - 用户命盘数据
  - 9 个分析维度的任务要求

**辅助方法**
- `appendAIToken(_:)`: 将 token 追加到 WebView 显示
- `callJSFunction(_:)`: 执行 JavaScript 代码
- `jsonString(_:)`: 安全转义字符串为 JSON 格式

#### 1.3 WebView 初始化修改
在 `makeUIView(context:)` 中保存 `webView` 引用到 `Coordinator`

### 2. JavaScript 层修改（注入脚本）

#### 2.1 中心点击触发逻辑
**`triggerCenterOracleEffect()` 函数重写**
- 检查是否有命盘数据
- 检查是否有 Native 消息桥接
- 显示 AI 分析 overlay
- 获取用户姓名和命盘 JSON
- 通过 `postToNativeStore` 发送 `analyzeChart` 消息给 Swift

#### 2.2 AI 分析 UI
**`ensureAIAnalysisOverlay()` 函数**
- 创建全屏 overlay（`#codex-ai-analysis-overlay`）
- 包含：
  - 顶部状态栏（显示"天机推演中…"等状态）
  - 关闭按钮
  - 可滚动内容区域（显示 AI 流式输出）
- 样式：深色背景、金色主题色、衬线字体

#### 2.3 AI 流式显示 API
**全局函数（供 Swift 调用）**

- `window.__codexAIStart()`: 开始 AI 分析，显示 overlay，清空内容
- `window.__codexAIAppendToken(token)`: 追加 token 到内容区，自动滚动到底部
- `window.__codexAIFinish()`: 分析完成，更新状态为"天机已现"
- `window.__codexAIError(message)`: 显示错误信息

### 3. 系统提示词内容

包含以下部分：

1. **角色定位**: 八字命理学、紫微斗数、姓名学专家
2. **基础规则**:
   - 五行生克关系
   - 天干生克关系
   - 十神定义和生克
   - 紫微斗数主星化忌/化权/化科规则
   - 辅佐星与煞星规则
3. **用户命盘数据**:
   - 性别、八字四柱
   - 紫微斗数命盘（五行局、阴阳、命宫、身宫、十二宫详情）
   - 当前流年信息
4. **分析任务**（9个维度）:
   1. 整体审视命局
   2. 分析日元强弱
   3. 剖析性格特征
   4. 推断事业发展
   5. 预测财富运势
   6. 研判婚姻情感
   7. 关注健康状况
   8. 洞察六亲关系
   9. 把握大运流年

## 数据流

```
用户点击中心区域
    ↓
JS: triggerCenterOracleEffect()
    ↓
JS: postToNativeStore({ action: 'analyzeChart', payload: { ownerName, chartJSON } })
    ↓
Swift: Coordinator.userContentController(_:didReceive:) 收到消息
    ↓
Swift: startChartAnalysis(ownerName:chartJSON:)
    ↓
Swift: buildSystemPrompt() 构建提示词
    ↓
Swift: OpenAICompatibleStreamer.streamChatCompletion() 流式请求
    ↓
Swift: appendAIToken() 每个 token 回传
    ↓
JS: window.__codexAIAppendToken(token) 追加显示
    ↓
Swift: callJSFunction("window.__codexAIFinish?.()")
    ↓
JS: 更新状态为"天机已现"
```

## 错误处理

1. **配置检查**:
   - 未配置 AI: 提示"未检测到可用 AI 配置"
   - 未选择模型: 提示"未选择模型"
   
2. **数据检查**:
   - 命盘数据解析失败: 提示"命盘数据解析失败"
   
3. **网络错误**:
   - 捕获 `OpenAICompatibleStreamer` 抛出的错误
   - 通过 `window.__codexAIError()` 显示错误描述

## 用户体验

1. **点击中心**: 立即显示 AI 分析 overlay，状态显示"天机推演中…"
2. **流式输出**: AI 回复逐字显示，自动滚动到底部
3. **完成提示**: 状态更新为"天机已现"
4. **关闭**: 点击"返回命盘"按钮关闭 overlay

## 技术特点

1. **流式响应**: 使用 `OpenAICompatibleStreamer` 实现流式输出，用户体验流畅
2. **消息桥接**: Swift 和 JavaScript 通过 `WKScriptMessageHandler` 双向通信
3. **安全转义**: 使用 `jsonString()` 方法安全转义字符串，避免注入攻击
4. **任务管理**: 使用 `Task` 和 `aiStreamTask` 管理异步任务，支持取消
5. **弱引用**: `Coordinator` 使用 `weak var webView` 避免循环引用

## 依赖

- `OpenAICompatibleStreamer`: 流式 AI 请求
- `AIConfigProvider`: AI 配置管理
- `ChartProfileStore`: 命盘档案存储
- `ChartResultStore`: 命盘结果存储

## 注意事项

1. 系统提示词中使用 Unicode 转义（`\u{201C}` 和 `\u{201D}`）表示中文引号，避免 Swift 字符串插值冲突
2. JS 函数使用可选链调用（`?.`），避免函数未定义时报错
3. AI 流式请求在后台线程执行，UI 更新通过 `@MainActor` 确保在主线程
4. WebView 引用使用 `weak` 避免内存泄漏
