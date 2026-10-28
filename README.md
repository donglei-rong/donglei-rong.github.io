# Donglei (Ray) Rong · 学术个人主页

一个以 [AcadHomepage](https://github.com/RayeRen/acad-homepage.github.io) 为基础精简改编的英文 Jekyll 网站。白色背景、固定顶部锚点导航、桌面左侧个人信息栏与右侧学术内容，手机和平板自动适配。

目前收录 **25 篇英文期刊论文、6 篇 Highlights，其中 2026 年 6 篇期刊论文**。2026-10-28 已结合本人 Google Scholar、ORCID 和出版商提交的 Crossref DOI 记录核对，新增 Sustainability 论文并合并 Scholar 重复记录。仅收录已在英文期刊发表的文章，不计入中文期刊、会议论文、SSRN 或其他预印本。核对依据见 [_PUBLICATIONS_AUDIT.md](_PUBLICATIONS_AUDIT.md)。

论文按年份倒序分组，同年优先按已知出版日期倒序显示；没有完整日期时保留原有精度，不猜测月份或日期。作者显示完整姓名，`Donglei Rong` 自动加粗。每条论文共用纯文字模板，显示期刊、年份、卷期、页码或文章编号、DOI、可核对的 PDF / Paper / Code 等资源与 BibTeX。

已接入真实头像。**按最新要求，Highlights 和 All Publications 均采用一致的纯文字学术引用，不显示论文封面、研究图或占位图。** 既有论文素材及来源记录作为历史资源保留，当前论文模板不渲染或请求这些图片。历史来源见 [ASSET_SOURCES.md](ASSET_SOURCES.md)。

## 文件结构

```text
_data/
  profile.yml       # 姓名、身份、简介、研究兴趣、社交链接、头像和公开 CV
  publications.yml  # 唯一的论文数据源；Highlights 也来自这里
  publication_settings.yml # 英文期刊收录口径、核对日期和 Working Papers 开关
  working_papers.yml # 可公开的 Working Papers；当前为空，自动隐藏
  news.yml          # 新闻
  research.yml      # 三条研究主线
  projects.yml      # 项目、角色、资助项目编号
  appointments.yml  # 任职；博士后与教育分开
  education.yml     # 学历；保留 PolyU 正在读博的状态
  teaching.yml      # 助教、指导经历与教学兴趣
  awards.yml        # 奖励
  services.yml      # 编辑与审稿等服务
  navigation.yml    # 顶部导航
_layouts/default.html
_includes/          # 导航、个人信息栏、论文等 Liquid 组件
index.html          # 各模块的渲染与展示顺序
assets/
  css/main.css
  js/main.js        # 移动菜单、论文筛选；没有 JS 也能阅读全部内容
  images/           # 头像和网站图标
    publications/   # 论文缩略图
  files/            # 仅放审核过的公开文件
scripts/
  validate.rb       # 数据、链接、渲染结果与公开文件边界检查
  preview.ps1       # Windows 本地预览入口
_config.yml         # Jekyll、SEO、URL 与排除规则
.github/workflows/pages.yml
Gemfile / Gemfile.lock
LICENSE / NOTICE.md # 开源许可和改编说明
```

## 本地启动

**本机最方便的方式：在项目文件夹中双击 `Start-Preview.cmd`。** 它会检查预览服务，必要时启动 Jekyll，再打开浏览器；已经运行时直接打开已有预览。关闭浏览器后可以再次双击，电脑重启后也需要重新启动。本地地址 `http://127.0.0.1:4000/` 只有预览服务运行时才能访问，它不是已发布的线上网址。修改 `_data/*.yml` 并保存后，等待几秒再刷新浏览器即可。

推荐 Ruby **3.3** 和 Bundler。Windows 可安装 [RubyInstaller + Devkit](https://rubyinstaller.org/downloads/)，按安装器提示配置工具链；macOS/Linux 安装对应 Ruby 开发环境。

在项目根目录运行：

```sh
bundle config set --local path vendor/bundle
bundle install
bundle exec jekyll serve --host 127.0.0.1 --port 4000 --force_polling
```

浏览器访问 **http://127.0.0.1:4000/**。修改 YAML、HTML、CSS 后自动重建；修改 `_config.yml` 后需停止并重新运行服务。按 `Ctrl+C` 停止。

本次工作区已在忽略目录 `.tools/ruby/` 准备官方便携 Ruby，并将依赖保存在 `.tools/bundle/`，避免依赖临时目录。也可以直接在 PowerShell 运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\preview.ps1
```

上面 `ExecutionPolicy` 参数只适用于本次 PowerShell 进程，不修改系统设置。也可在已有允许执行本地脚本的终端运行 `./scripts/preview.ps1`。

Windows 路径或 UTF-8 编码遇到问题时，先设置当前会话：

```powershell
$env:RUBYOPT = '-EUTF-8:UTF-8'
```

本机还观察到便携 Ruby 在沙箱中对绝对路径 `Dir.glob` 返回空结果的问题，以及中文目录中的 Windows 路径编码问题。`scripts/jekyll.rb` 会统一 Windows 启动路径的编码，并仅在检测到 glob 异常时启用等价的 `base:` 路径兼容处理，再加载 Bundler 和真正的 Jekyll。本机手动构建可使用 `ruby scripts/jekyll.rb build`，构建后运行 `ruby scripts/validate.rb --built`；`preview.ps1` 已自动使用这一入口。GitHub Actions 在 Linux 上使用标准 Jekyll，不依赖该兼容处理。

依赖和便携工具均位于本机忽略目录，不应提交。换电脑后重新安装 Ruby、运行 `bundle install` 即可，不需要 Node、npm、服务器或任何付费 API。Windows 的原生 gem 编译器可能不支持中文路径，建议新克隆项目放在 `C:/sites/academic-homepage` 一类英文路径；本次工作区通过英文临时目录完成依赖编译，再将运行文件保存到项目的 `.tools/` 中，源码仍在原目录。

## 修改头像、个人介绍和主页链接

编辑 `_data/profile.yml`：

```yaml
name: Donglei (Ray) Rong
role: Postdoctoral Researcher
institution: Georgia Institute of Technology
email: drong8@gatech.edu
avatar: /assets/images/portrait.jpg
public_cv: ''
github: ''
```

将自己的头像保存为 `assets/images/portrait.jpg`。推荐正方形 JPG/WebP，约 400–800 像素，并压缩体积。`avatar: ''` 会显示中性的姓名缩写，不会请求缺失图片。

`bio_paragraphs` 是公开简介，每条是一段英文，支持 Markdown 链接和加粗。若不存在或为空，则回退到 `bio`；有 `bio_paragraphs` 时仅修改 `bio` 不会影响页面。

```yaml
bio_paragraphs:
  - >-
    I work at [Georgia Tech](https://www.gatech.edu/).
    My research focuses on **transportation safety**.
  - >-
    Add a second paragraph here.
```

研究兴趣修改 `research_interests`。修改 `google_scholar`、`researchgate`、`orcid`、`linkedin`、`github` 即可更换链接；空字符串的社交链接自动隐藏。邮箱只填地址，模板自动添加 `mailto:`。不要为缺失的 GitHub 账号填写猜测的用户名。

`profile.yml` 中的 `site_title` 控制首页浏览器标签标题。同时更新 `_config.yml` 的 `title`、`description` 和 `author`，它们用于 SEO / Open Graph。页面默认英文，不加载第三方追踪脚本或外部字体。

## 添加或修改论文

只需向 `_data/publications.yml` 添加一条，顺序不限，页面自动按 `year` 倒序分组：

```yaml
# 以下为结构示例；请替换全部占位内容后再保存到公开数据中。
- id: your-unique-paper-id
  title: '[Paper Title]'
  authors: D. Rong, [Author Name], and [Author Name]
  venue: '[Journal Name]'
  year: 2026
  type: journal             # 当前口径只允许 journal
  language: en
  publication_date: '2026'  # 实际已知精度：YYYY / YYYY-MM / YYYY-MM-DD
  volume: ''
  issue: ''
  pages: ''
  article_number: ''
  publication_status: published # published / online_first；均须已在期刊发表
  doi: '[Real DOI]'
  paper_url: 'https://doi.org/[Real DOI]'
  pdf_url: ''               # 可选，经确认可公开访问的论文 PDF
  selected: false           # true 时同时出现在 Highlights
  image: ''                # 可省略；历史素材字段，当前页面不显示论文图片
  image_alt: ''            # 描述真实论文图的内容
  image_kind: figure       # figure / article-preview / journal-cover
  image_source_url: ''     # 网上下载素材的公开来源页面
  image_asset_url: ''      # 可选，原始图片下载地址
  image_credit: ''         # 可选，来源或署名说明
  code_url: ''
  project_url: ''
  dataset_url: ''
  video_url: ''
  summary: ''              # 可选，支持 Markdown
  abstract: ''             # 可选，可折叠
  resources: []            # 可选扩展资源，见下
```

`id` 必须唯一，由小写字母、数字和连字符组成；DOI 也不得重复。`year` 用数字，`selected` 用 `true/false`，不要加引号。Highlights 和 All Publications 均不显示图片；添加新论文无需准备或填写任何图片字段。没有资源就留空，相应链接不会渲染。

头像当前为 `assets/images/portrait.webp`。`avatar_position`、`avatar_zoom` 和 `avatar_origin` 用 CSS 调整圆形取景，不修改照片内容；换成已经裁好的头像时将 `avatar_zoom` 改为 `1`、位置改为 `50% 50%`。历史论文素材保存在 `assets/images/publications/`，当前页面不显示或加载它们；保留的 `image_*` 字段只记录原素材及来源。

添加任意自定义资源：

```yaml
  resources:
    - label: Supplement
      url: https://example.org/replace-with-real-resource
```

`profile.yml` 中的 `publication_name` 和 `publication_name_variants` 控制姓名加粗，目前兼容完整姓名及 `D. Rong`、`D Rong`。作者名单和顺序以可核对的出版商 DOI 记录为依据。BibTeX 使用相同 YAML 数据，自动包含已知卷、期和页码/文章编号；未知字段留空。

`publication_date` 与 `year` 使用期刊正式出版年份：有分配卷期的记录优先采用该期出版日期；仅在线发表的期刊文章使用在线出版日期。`published_online` 可另存首次在线日期。发表在期刊上的在线文章可以计入；仅投稿、录用但尚无公开发表记录的稿件不计入。

`last_verified` 和 `metadata_source_url` 记录每条论文的核对日期与来源，方便以后更新。Scholar 同一 DOI 的重复记录只保留一篇，已正式发表文章的 SSRN 早期版本也不重复计数。网站不在运行时请求 Scholar 或 Crossref，无需 API 密钥。

## Working Papers 是否展示及如何添加

**按当前明确要求，主页仅收录英文期刊论文，不展示或计入 Working Papers、SSRN、其他预印本及会议论文。** 本次检索虽然找到了公开的 SSRN 记录，也已按此口径排除。

保留 `_data/working_papers.yml` 作为以后可选功能，当前为 `[]`；`publication_settings.yml` 中 `show_working_papers: false` 会同时关闭页面与导航。只有今后明确改变收录范围时，才将 `scope` 改为 `all_publications`、修改 `scope_label` 并启用此开关。Working Papers 始终独立计数，不进入已发表论文总数或 Highlights。当前不要往此文件复制私有 CV 的在审稿件。

以下仅为结构说明，不是实际科研成果。确认真实内容和公开链接后，用条目替换 `[]`：

```yaml
- id: your-public-preprint-id
  title: '[Actual manuscript title]'
  authors: D. Rong, [Actual coauthor names]
  year: 2026                # 公开预印本的实际年份
  status: preprint          # preprint / under_review；据实际状态填写
  preprint_url: 'https://[actual-public-preprint-link]'
  code_url: ''
  project_url: ''
  summary: ''               # 可选，1–2 句英文介绍
```

必须提供真实的公开预印本链接；可以使用 arXiv、TechRxiv 或机构存储库，不强制要求 DOI。`under_review` 只表示在审，不能写成 accepted/published。录用发表后，将该条移至 `publications.yml`，补齐正式期刊和 DOI，并从 Working Papers 移除，避免重复。

参考：[IEEE Author Center 的文章版本与预印本分享说明](https://journals.ieeeauthorcenter.ieee.org/become-an-ieee-journal-author/publishing-ethics/guidelines-and-policies/post-publication-policies/)。其他期刊应分别核对其现行政策。

## 添加 News

编辑 `_data/news.yml`，每条新闻如下，日期必须带引号、格式为 `YYYY.MM`：

```yaml
- date: '2026.10'
  text: '[Your verified news item in English.]'
  emoji: '🎉'                 # 可省略
  url: ''                     # 可选真实外链
  link_label: Read more       # 可省略
```

页面按年月倒序显示。新闻正文支持 Markdown，不需要编辑 HTML。不要推测论文录用月份。

## 更新其他经历和服务

直接编辑对应 `_data/*.yml`，原资料中的事实和角色均分开维护：

- `appointments.yml`：任职；`education.yml`：学历，`advisor` 和 `advisor_url` 维护导师及主页。PolyU 当前保持 `Ph.D. Candidate`，学位完成后再据实修改。
- `research.yml`：研究主线；`projects.yml`：项目。区分 `Principal Investigator` 与 `Project Participant`。
- `teaching.yml`：`experience` 是真实课程助教/指导经历，`interests` 是教学兴趣。独立的 Research Mentoring 学生列表已按修订建议移除；如以后添加 `mentoring` 列表会重新显示该子模块。
- `awards.yml`：`years` 是显示文本，`sort_year` 是排序所用数字；`public_note` 可显示简短说明。
- `services.yml`：支持 `editorial`、`journal_reviewing`、`conference_reviewing`、`program_committee`、`workshops` 和 `other`；没有内容的子类自动隐藏。后三类可使用 Markdown 字符串列表。

一个普通模块的 YAML 设为 `[]`，或删除对应数据，即可隐藏其内容及导航入口。`research` / `teaching` / `services` 是包含子字段的对象，应删除不需要的子列表，或删除整个文件来隐藏模块；同步检查导航。

## 上传和替换公开 CV

**当前 CV 下载入口默认隐藏。根目录的 `CV.pdf` 是私有源文件，不会自动复制或发布。**

1. 自行审核并生成适合公开的 PDF，移除私人电话、求职定制内容及其他不希望公开的信息。
2. 放到 `assets/files/Donglei_Rong_CV.pdf`。
3. 在 `_data/profile.yml` 设置 `public_cv: /assets/files/Donglei_Rong_CV.pdf`。
4. 重新构建并打开下载链接，确认内容正确。替换时覆盖同名 PDF 即可。

`assets/` 下的文件被视作明确准备公开的资源；不要往里面放原始文书或未经审核的 CV。

## 检查构建

```sh
bundle exec ruby scripts/validate.rb
bundle exec jekyll build --trace
bundle exec ruby scripts/validate.rb --built
```

检查会验证 YAML、论文必填字段、唯一 ID/DOI、链接格式、本地资源路径、论文数与 Highlights、姓名加粗、倒序排列、页内锚点、SEO，以及 `_site/` 的输出范围。它不会把期刊网站的防机器人响应误判为页面代码错误；DOI 实际可解析性需按期刊记录复核。

本项目已完成实际 Jekyll 4.4.1 构建，开发期间也检查过根目录与 `/academic-test` 子路径构建。2026-10-28 更新后为 25 个唯一 DOI、6 篇代表论文、2026 年 6 篇英文期刊论文；新增论文可由出版商 DOI 记录核对。浏览器检查覆盖桌面、390px 手机和开发时的 768px 平板视口，以及年份筛选、BibTeX 和移动菜单。手机和平板通过同源 iframe 提供实际 CSS 视口检查，没有模拟操作系统或触摸设备。首次真正的 GitHub Actions 部署仍需连接你自己的仓库执行。

测试子目录部署（可选）：

```sh
bundle exec jekyll build --baseurl /academic-test
```

此时本地路径检查需设置环境变量 `CHECK_BASEURL=/academic-test` 后运行 `--built`。最终重新运行普通构建恢复根域名版本。

## 发布到 GitHub Pages

本项目使用仓库 [donglei-rong/donglei-rong.github.io](https://github.com/donglei-rong/donglei-rong.github.io)，网站地址为 [https://donglei-rong.github.io/](https://donglei-rong.github.io/)。`main` 分支更新后由 GitHub Actions 构建和部署。后续可继续在当前对话维护这个项目：说明需要修改的内容，完成本地检查后更新同一仓库即可。以下步骤也可用于迁移到其他账号或重新部署。

本项目使用 **GitHub Actions 构建 Jekyll 4.4**，不使用旧版分支构建。这样可以保留当前依赖和验证步骤，最终发布的仍是纯静态网站。

1. 在自己的 GitHub 账号下创建公开仓库 **`YOUR_USERNAME.github.io`**，将 `YOUR_USERNAME` 换成真实用户名。为避免首次 push 冲突，创建时不勾选初始化 README。
2. 编辑 `_config.yml`：

   ```yaml
   url: https://YOUR_USERNAME.github.io
   baseurl: ''
   ```

   可同时设置 `author.url`。用户主页保持空 `baseurl`；普通项目仓库则使用 `baseurl: /repository-name`。工作流部署时也会从 Pages 自动读取实际域名和路径，用于 canonical、Open Graph 和 sitemap。

3. 在根目录执行：

   ```sh
   git init -b main
   git add .
   git status --short
   git commit -m "Build Donglei Rong academic homepage"
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_USERNAME.github.io.git
   git push -u origin main
   ```

   提交前查看 `git status`：应只有网站代码与公开数据；不能有原始 CV、求职陈述、资料包、`private-source/`、`.tools/` 或 `vendor/`。本项目的 `.gitignore` 已排除当前私有文件。如果仓库以前跟踪过私有文件，`.gitignore` 不能移除已有历史，应先处理历史再公开。

4. 仓库 **Settings → Pages → Build and deployment → Source** 选择 **GitHub Actions**。
5. 打开 **Actions**，查看 “Build and deploy academic homepage”。如果首次运行早于 Pages 配置而失败，在配置好后点击 **Re-run all jobs**，或在该工作流点击 **Run workflow**。
6. 构建和部署成功后访问 `https://YOUR_USERNAME.github.io/`。部署环境名为 `github-pages`，如仓库启用环境审批，需要自行通过审批。

`pages.yml` 只向 Pages 上传 `_site/`，PR 只构建验证，不发布。没有配置任何付费服务。当前 GitHub 用户名为 `donglei-rong`，主页仓库为 `donglei-rong.github.io`；GitHub Pages 的 Source 使用 GitHub Actions。

## 每次修改后更新线上网站

```sh
bundle exec ruby scripts/validate.rb
bundle exec jekyll build
bundle exec ruby scripts/validate.rb --built
git add _data assets index.html _includes _layouts _config.yml
git commit -m "Update academic homepage"
git push
```

如果同时修改其他代码文件，也将相应文件加入提交。push 到 `main` 自动触发构建和部署，无需上传 `_site/`。在 Actions 查看绿色结果后刷新网站，必要时强制刷新缓存。

## 内容与隐私约定

资料包、根目录原始 CV 与 Research/Teaching Statements 只作本地资料来源，已同时被 `.gitignore` 和 Jekyll 的 `exclude` 排除。公开构建额外检查只允许 `index.html`、`404.html`、`robots.txt`、`sitemap.xml` 和 `assets/`。资料包中的编辑备注不会输出到页面；页面不含私人电话、面向 University of Cincinnati 的申请内容、未公开稿件、虚构图片或代码链接。

YAML/Markdown 是可信的作者内容，支持 HTML；不要把未经审核的外部内容直接粘贴为站点模板。保持原始材料在本地或私有存储中，公开仓库只提交审核后的网站内容。

## 开源许可

保留 AcadHomepage 的 MIT 许可证及 Yi Ren 版权声明，页面底部保留模板署名。详细改编范围见 [NOTICE.md](NOTICE.md)。
