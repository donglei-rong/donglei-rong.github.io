# 开源来源与改编说明

本项目基于 [AcadHomepage](https://github.com/RayeRen/acad-homepage.github.io) 的 Jekyll 架构进行精简和改编，保留了 `masthead → sidebar → page` 双栏结构、布局组件分工与相关类名。`_layouts/default.html` 和 `_includes/masthead.html` 由上游对应组件改编，个人信息栏沿用上游组织方式。

上游版权：Copyright (c) 2022 Yi Ren，MIT License。完整许可证保留在 `LICENSE`。

视觉布局与论文图文排版参考 [MCZhi 学术主页](https://mczhi.github.io/) 及其[开源项目](https://github.com/MCZhi/MCZhi.github.io)。没有复制其个人资料、头像、论文图或研究内容。

为降低维护成本，本项目用本地 CSS Grid 和少量原生 JavaScript 替换上游 Susy、jQuery、图标字体和外部字体依赖；保留 Jekyll / Liquid / YAML 技术栈。CSS、交互、数据渲染与占位资源为本项目编写。无需远程主题即可构建。

个人学术资料来自用户提供的资料包。MIT 许可证适用于网站代码；不代表许可第三方重新使用个人肖像、CV 或论文中的第三方版权图片。
