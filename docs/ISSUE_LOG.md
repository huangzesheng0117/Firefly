# next-hop.tech 问题记录

本文件记录已经确认并修复的站点故障。修改页面结构、导航或部署配置前，应先检查这里的历史问题与防回归要求。

## 2026-07-29：主页与文章页之间跳转明显变慢

### 状态

- 已修复并部署。
- 修复提交：`cb2b845 fix: speed up cross-layout navigation`
- 涉及文件：
  - `astro.config.mjs`
  - `public/_headers`

### 现象

- 打开 `https://next-hop.tech/` 时，用户主观感受到的等待时间比前一天明显增加。
- 从主页进入 `/posts/`，或从文章相关页面返回主页时，同站点跳转也会出现明显停顿。
- 直接请求主页和文章页时，Cloudflare 返回 `HTTP 200`，缓存预热后的 TTFB 约为 `0.15–0.24s`。这说明主要问题不在源站或 Cloudflare Worker 的服务端执行时间，而在浏览器端导航流程和资源缓存策略。

### 根因一：Swup 容器不匹配

站点存在两套页面结构：

- 专业版主页 `src/pages/[...page].astro` 直接使用 `Layout`。
- 文章列表、文章正文等内页使用 `MainGridLayout`。

内页的 Swup 配置要求以下容器同时存在：

```text
#banner-overlay-container
#banner-dim-container
#swup-container
#left-sidebar-dynamic
#right-sidebar-dynamic
#floating-toc-wrapper
```

这些容器存在于内页，但不存在于专业版主页。主页和内页之间的链接仍被 Swup 拦截后，会先请求目标页面并尝试局部替换；容器匹配失败后才报错或回退，因此产生不必要的等待。

#### 容易重复出现的错误

`@swup/astro` 集成层的配置项是 `ignore`，不是底层 Swup 实例的 `ignoreVisit`。如果在 `astro.config.mjs` 中误写：

```js
swup({
	ignoreVisit: () => true,
});
```

该配置会被集成层静默忽略，构建仍可能成功，但浏览器中的行为不会改变。

#### 当前正确处理

在 `astro.config.mjs` 的 `swup()` 配置中使用集成层支持的 `ignore`：

```js
ignore: (targetUrl) => {
	const normalizePath = (pathname) =>
		pathname.replace(/\/+$/, "") || "/";
	const currentPath = normalizePath(window.location.pathname);
	const targetPath = normalizePath(
		new URL(targetUrl, window.location.href).pathname,
	);

	return currentPath === "/" || targetPath === "/";
},
```

效果：

- 主页与任意内页之间使用浏览器原生导航，避免不可能成功的局部替换。
- 容器结构一致的内页之间继续使用 Swup。

### 根因二：指纹静态资源缺少长期浏览器缓存

部署前，`/_astro/*` 下带内容哈希的 JS、CSS、字体和优化图片也返回：

```text
Cache-Control: public, max-age=0, must-revalidate
```

这会让浏览器重复验证本可安全长期缓存的资源，放大首次打开和页面切换时的网络开销。

#### 当前正确处理

`public/_headers` 必须保留：

```text
/_astro/*
  Cache-Control: public, max-age=31536000, immutable
```

注意：

- 该规则只应用于文件名带内容哈希的 `/_astro/*` 资源。
- 不要给普通 HTML 页面设置一年 `immutable`，否则发布新版本后用户可能长期看到旧页面。
- 修改 `_headers` 后必须重新构建并部署；只修改本地文件不会影响线上响应头。

### 验证方法

#### 1. 静态检查与生产构建

```powershell
pnpm check
pnpm build
git diff --check
```

#### 2. 确认忽略规则进入构建产物

不能只看 `astro.config.mjs`，还要检查最终生成的 JS：

```powershell
rg -n "ignoreOption|location.pathname|data-no-swup" dist/_astro -g "*.js"
```

期望结果：Swup 初始化脚本中包含主页路径判断，并在 `ignoreVisit` 的最终实现里调用该判断。

如果源码有规则而 `dist/_astro` 没有，说明使用了集成层不支持的配置项，不能继续部署。

#### 3. Cloudflare 部署预检

```powershell
pnpm exec wrangler deploy --dry-run
```

#### 4. 线上响应与缓存验证

```powershell
curl.exe -sS -D - -o NUL https://next-hop.tech/
curl.exe -sS -D - -o NUL https://next-hop.tech/posts/
curl.exe -sS -D - -o NUL https://next-hop.tech/_astro/<当前构建的指纹文件>
```

期望结果：

- 主页和文章页返回 `HTTP 200`。
- 缓存预热后 HTML 通常显示 `CF-Cache-Status: HIT`。
- `/_astro/*` 响应包含：

```text
Cache-Control: public, max-age=31536000, immutable
```

#### 5. 记录请求阶段耗时

```powershell
curl.exe -sS -o NUL `
  -w "status=%{http_code} dns=%{time_namelookup}s connect=%{time_connect}s ttfb=%{time_starttransfer}s total=%{time_total}s`n" `
  https://next-hop.tech/posts/
```

发布后的本机复测结果：

- 主页缓存命中后的总响应约 `0.165–0.176s`。
- 文章页缓存命中后的总响应约 `0.162–0.178s`。
- 新版本首次请求可能为 `MISS`，不能用单次冷缓存结果判断长期性能。

### 防回归检查清单

修改主页、布局、导航或 Swup 配置时，必须检查：

1. 当前页面与目标页面是否都包含 `containers` 中声明的全部元素。
2. 跨不同布局体系的链接是否已绕过 Swup，或两边是否已统一容器结构。
3. `@swup/astro` 的选项是否是该集成实际支持的选项；不要直接照搬底层 Swup 配置名。
4. `pnpm build` 后，规则是否真实存在于 `dist/_astro` 产物中。
5. `public/_headers` 是否仍被复制为 `dist/_headers`。
6. 线上指纹资源是否仍返回一年 `immutable` 缓存。
7. 至少实际测试一次 `/` → `/posts/` 和 `/posts/` → `/`。
8. 先区分 DNS、连接、TTFB、静态资源加载和浏览器端导航耗时，再决定是否需要调整 Cloudflare、DNS 或图片资源。

### 不应采用的排查捷径

- 不能因为“感觉打开慢”就直接更换 Cloudflare IP 或 DNS；先确认是服务端 TTFB、浏览器缓存还是前端导航问题。
- 不能只依赖 `pnpm build` 成功判断 Swup 配置有效；不支持的配置项也可能静默通过构建。
- 不能把所有页面都设置为长期不可变缓存。
- 不能只测试刷新页面，还必须测试同站点页面之间的点击跳转。

### 参考资料

- [Swup options](https://swup.js.org/options/)
- [Cloudflare Workers Static Assets：自定义响应头](https://developers.cloudflare.com/workers/static-assets/headers/)
