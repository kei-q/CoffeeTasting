# CoffeeTasting


# 使用しているもの

- ace
- coffeescript.js
- socketstream
- redis

# 構築

macとcentosは動作確認済み
以下の手順はmac用

```sh
$ npm install -g socketstream
$ brew install redis

# redis起動
$ redis-server

$ hub clone keqh/coffeetasting
$ cd coffeetasting
$ socketstream s
```
