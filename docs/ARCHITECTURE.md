# Hungry Hub 架构说明

## Pixso 来源

| 分类 | 页面 ID | 在项目中的用途 |
| --- | --- | --- |
| Cover | `97:98` | 确认套件封面与品牌 |
| Design | `0:1` | 39 个界面状态及各自的浅色、深色画板 |
| Component | `13:967` | 登录、验证码和按钮的状态参考 |
| Assets | `141:180` | 引导插画与食物、店铺、支付图像 |
| Style guide | `141:389` | Poppins、橙色 `#F07A10`、颜色和图标参考 |

MCP 用于读取页面、图层和画板，并导出独立图片。首页的 Flutter 导出用于核对组件边界与尺寸。应用使用 Flutter 布局和可交互控件，截图由 Android 上渲染的应用产生。两版画板的对应见 [截图索引](SCREENS.md)。

## 目录

```text
lib/
├── main.dart              # 启动与系统栏
├── app.dart               # MaterialApp、浅深主题、应用入口和底部导航
├── core/
│   ├── hub_state.dart     # 会话、购物车、主题、支付与地址选择
│   └── ui.dart            # 共用页面容器、按钮、输入、单选项和导航
├── data/
│   └── catalog.dart       # 菜品、餐厅、配送地址与价格格式
└── features/
    ├── auth.dart          # 启动、引导、登录注册、验证与重设密码
    ├── discover.dart      # 首页、搜索、附近餐厅、热门、菜品详情和通知
    ├── account.dart       # 个人中心、偏好和账号资料
    └── checkout.dart      # 购物车、支付方式、配送地址与订单确认
assets/
├── images/                # Pixso 导出的独立素材
└── fonts/                 # Poppins 与 OFL 许可
android/                   # Android 构建入口
test/                      # 交互回归测试
integration_test/          # 在 Android 上遍历全部界面状态
test_driver/               # 将设备截图写入工作区
tool/capture.ps1           # 复用已运行的模拟器并恢复视口配置
docs/
├── ARCHITECTURE.md
├── SCREENS.md
└── screenshots/            # Android 应用实拍，按浅色、深色分目录
```

## 导航与状态

`HungryHubApp` 提供主题和 `HubScope`。注册或登录完成后进入 `BrowseShell`，底部导航切换首页、搜索、购物车、附近餐厅和个人中心。热门列表、详情、账号偏好和结账步骤通过 Flutter `Navigator` 入栈。表单输入与筛选条件由各功能页管理。

`HubState` 使用 Flutter 自带的 `ChangeNotifier`。购物车以菜品为键保存数量，价格统一用整数美分计算，配送费在非空购物车中为 $3.59。确认订单清空购物车并更新本地通知。密码与验证码仅在当前页面校验，账号资料和订单在进程内保存。

## 实现范围

- 附近餐厅使用 Pixso 地图素材和可点击标记，支持本地名称查找和详情。
- 登录、验证码、配送与支付为演示流程。图片中的信用卡是设计素材。
- 账号页使用示例邮箱并遮盖密码，订单金额随所选菜品数量实时变化。
- Android 使用设备的状态栏与返回操作。其余平台可复用 Dart 页面，项目提供 Android 构建入口。
