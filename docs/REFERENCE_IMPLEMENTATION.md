# 第二版视觉实现来源

第二版只移植与需求直接相关的视觉实现，没有整体替换现有
Firefly/Astro 站点结构。

## 参考仓库

- `MmzMing/my-blog`
  - 首页标题的排线思路参考 `src/components/layout/HomeHero.astro` 与
    `src/utils/hatch-effect.ts`。
  - 本站采用永久 CSS 排线文字，不再让 WebGL 着色器替换标题 DOM，避免刷新后
    排线效果消失。
  - “站点数据 / 能力矩阵”参考提交
    `8eb3be351e50ca6902c0c171b3e8c776d7487fc6` 中的
    `HomeDataLayer.astro`、`DataMetricCard.astro`、`LogoLoop.svelte`
    和 `home-data-layer.css`。
- `tianshihao2003/dumpling-theme`
  - 导航项尺寸和字重参考 `src/components/layout/DropdownMenu.astro`：
    `h-11`、`font-bold`、`px-5`。
  - 仓库默认字体配置并不等于线上站点的实际配置；线上页面最终加载
    `AaZongYiYuan-2.woff2`。
- `fqzlr/Firefly`
  - 线上导航元素的实际计算字体为 `AaZongYiYuan`，实际参数为
    `16px / 700`。
  - 居中导航布局参考 `src/components/layout/Navbar.astro`。

以上三个仓库均以 MIT License 发布。

## 字体

导航栏和中文正文使用两个参考站线上页面实际加载的 `AaZongYiYuan`
字体，并保留系统字体栈作为回退。导航项采用线上页面的 16px 字号与
700 字重；导航结构仍只保留本站需要的主页、文章和关于三个入口。

完整字体以同源静态资源 `public/assets/fonts/AaZongYiYuan-2.woff2`
提供。首屏导航另生成只含“主页、文章、关于”六个汉字的
`AaZongYiYuan-nav.woff2`（2.1 KB），并在 HTML 头部预加载；CSS 使用
`font-display: block`，避免加载阶段先显示系统字体再发生替换。

导航 DOM 采用“透明定位外壳 + 单一椭圆卡片 + 透明链接容器”三层结构。
旧主题仍需使用的 `#navbar` 保留在透明外壳上，卡片样式只应用于唯一的
`.network-navbar`，从而避免旧主题的 `#navbar > div` 规则给链接容器再套
一层矩形白框。

## 图片

专业网络工程图片来源和授权链接见 `docs/IMAGE_SOURCES.md`。
