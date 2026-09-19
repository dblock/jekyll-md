# jekyll-md

[![Test](https://github.com/dblock/jekyll-md/actions/workflows/test.yml/badge.svg)](https://github.com/dblock/jekyll-md/actions/workflows/test.yml)

A Jekyll plugin that serves a clean Markdown version of every page, for AI agents and other machine readers.

For every rendered HTML page, `jekyll-md` writes a sibling `.md` file (e.g. `/about/index.html` -> `/about.md`) and adds a `<link rel="alternate" type="text/markdown">` tag to the page's `<head>` so agents can discover it.

## Installation

Add this line to your Jekyll site's `Gemfile`:

```ruby
group :jekyll_plugins do
  gem 'jekyll-md'
end
```

And then run `bundle install`.

> [!NOTE]
> This plugin requires a custom Ruby gem and therefore cannot run in GitHub Pages' default build (which only allows a fixed [whitelist of plugins](https://pages.github.com/versions/)). Deploy via a [GitHub Actions workflow](https://jekyllrb.com/docs/continuous-integration/github-actions/) that runs `bundle exec jekyll build` instead (GitHub Pages' "GitHub Actions" build type), and it will work.

## Usage

No configuration is required to get started; every rendered HTML page gets a Markdown counterpart.

### Configuring the CSS selector

By default (no `selector` configured), `jekyll-md` converts the entire `<body>` of the page, including navigation, headers, footers, and anything else on the page. This is simple but rarely what you want for a real site: it dumps your header/nav/footer HTML into every single `.md` file.

Set `selector` to a CSS selector that scopes the conversion to just your content, e.g. the wrapper `div` around `{{ content }}` in your layout:

```yaml
md:
  selector: "#markdown-content"
```

```html
<!-- _layouts/post.html -->
<article>
  <div id="markdown-content">
    {{ content }}
  </div>
</article>
```

You can override the selector for an individual page via front matter:

```yaml
---
md_selector: "#post-body"
---
```

### Other configuration

```yaml
md:
  enabled: true              # master on/off switch, default true
  selector: "#markdown-content" # CSS selector to convert; default nil (convert the entire page)
  strip: [script, style]    # elements always removed from the selected content before conversion
  link: true                 # inject <link rel="alternate" type="text/markdown"> into <head>, default true
  exclude:                   # array of URL glob patterns to skip entirely
    - /404.html
    - /assets/**
```

### Per-page front matter

```yaml
---
md: false          # opt this page out of Markdown generation entirely
md_link: false     # generate the .md file, but don't add the <link> tag to this page
md_selector: "#x"  # override the selector for this page only
---
```

### Avoiding clobbering hand-authored Markdown pages

If a page at the derived destination path already exists after Jekyll writes the site (for example, you hand-author `/tags.md` yourself from a data-driven Liquid template), `jekyll-md` will not overwrite it.

## How it works

`jekyll-md` hooks into two points in the Jekyll build:

1. `:pages`/`:documents`, `:post_render` — after a page's layout and Liquid have fully rendered, inject the `<link rel="alternate">` tag into its `<head>`.
2. `:site`, `:post_write` — after Jekyll has written the whole site to disk, walk every page and document, extract the configured selector (or the whole `<body>`) from its rendered HTML, convert it to Markdown, and write it next to the HTML output.

## Development

```bash
bundle install
bundle exec rake
```

## Similar Projects

### jekyll-llms

[jekyll-llms](https://github.com/skatkov/jekyll-llms) generates Markdown sidecars from each page's **source** — your original Markdown/HTML file, with Liquid resolved but otherwise untouched — plus an `llms.txt` index.

`jekyll-md` instead converts the page's **final, fully rendered HTML output** (after layouts, includes, and Liquid have all run) back into Markdown, using [reverse_markdown](https://github.com/xijo/reverse_markdown). This matters if your pages/posts contain inline HTML (`<a>`, `<img>`, tables, embeds, etc.) mixed into Markdown source, or use includes/layouts to build up their content: converting the rendered HTML turns all of that into clean Markdown syntax, instead of leaking raw HTML tags into the served `.md`. It also means every generated page gets a `.md` counterpart, not just posts and pages with Markdown source — including tag pages, pagination pages, and any other page your site generates.

The tradeoff is that `jekyll-md` doesn't generate an `llms.txt` index. If you want both, you can run both plugins together.

## Contributing

Pull requests are welcome.

## Copyright and License

MIT License, see [LICENSE](LICENSE.md) for details.
