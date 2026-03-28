# Releasing DOTIW

There are no hard rules about when to release dotiw. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

## Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [GitHub Actions](https://github.com/radar/distance_of_time_in_words/actions) for all supported platforms.

Add a date to this release in [CHANGELOG.md](CHANGELOG.md).

```
## 5.5.1 (2026/03/28)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md lib/dotiw/version.rb
git commit -m "Preparing for release, 5.5.1."
git push origin master
```

Release.

```
rake release
```

This builds the gem, creates and pushes a git tag, and pushes the gem to [RubyGems](https://rubygems.org/gems/dotiw).

```
dotiw 5.5.1 built to pkg/dotiw-5.5.1.gem.
Tagged v5.5.1.
Pushed git commits and tags.
Pushed dotiw 5.5.1 to rubygems.org.
```

Create a GitHub release for the tag using the `gh` CLI, passing the CHANGELOG entries for this version as the release notes.

```
gh release create v5.5.1 --title "5.5.1" --notes "$(sed -n '/^## 5.5.1/,/^## /p' CHANGELOG.md | sed '$d')"
```

## Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
## 5.5.2 (Next)

* Your contribution here.
```

Increment the patch version number in [lib/dotiw/version.rb](lib/dotiw/version.rb).

Commit your changes.

```
git add CHANGELOG.md lib/dotiw/version.rb
git commit -m "Preparing for next developer iteration, 5.5.2."
git push origin master
```
