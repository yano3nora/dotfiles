# git

## Overview

Git の global config を管理する。

```txt
git/gitconfig -> ~/.gitconfig
git/gitignore_global -> ~/.gitignore_global
git/hooks/pre-commit -> <this repo>/.git/hooks/pre-commit
```

## Notes

`dots link` で symlink される。
個人名やメールアドレスなど、公開 repo に載せる前提で問題ない値だけを書く。

## Hooks

`git/hooks/pre-commit` はこの repo 自身の pre-commit。
gitleaks で stage した内容を scan し、secret があれば commit を止める。
理由: 公開 repo なので、commit した時点で漏洩になる。
gitleaks は `mise/mac.toml` と `mise/win.toml` で入る。
他の repo には効かせない。理由: `core.hooksPath` は repo ごとの hook を潰す。

```sh
# 誤検知を抑えるときは、該当行に gitleaks:allow を書く
# https://github.com/gitleaks/gitleaks#additional-configuration
```
