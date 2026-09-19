# Releasing Jekyll-Md

There're no hard rules about when to release jekyll-md. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [GitHub Actions](https://github.com/dblock/jekyll-md/actions) for all supported platforms.

Change "Next" in [CHANGELOG.md](CHANGELOG.md) to the current date.

```
### 0.2.0 (2026/09/19)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md
git commit -m "Preparing for release, 0.2.0."
git push origin main
```

Release.

```
$ rake release

jekyll-md 0.2.0 built to pkg/jekyll-md-0.2.0.gem.
Tagged v0.2.0.
Pushed git commits and tags.
Pushed jekyll-md 0.2.0 to rubygems.org.
```

Create a [GitHub release](https://github.com/dblock/jekyll-md/releases) for the new tag, using the corresponding CHANGELOG.md section as the release notes.

```
gh release create v0.2.0 --title "v0.2.0" --notes-file <(sed -n '/^### 0.2.0/,/^### /p' CHANGELOG.md | sed '1d;$d')
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
### 0.2.1 (Next)

* Your contribution here.
```

Increment the third version number in [lib/jekyll/md/version.rb](lib/jekyll/md/version.rb).

Run `bundle install` to update the Gemfile.lock.

Commit your changes.

```
git add CHANGELOG.md lib/jekyll/md/version.rb Gemfile.lock
git commit -m "Preparing for next development iteration, 0.2.1."
git push origin main
```
