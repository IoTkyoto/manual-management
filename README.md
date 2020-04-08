## デバッグ環境の整え方

以下 mac における github pages のデバッグ環境の構築方法

### 前提条件

-   ruby の環境が用意されている(確認済みバージョンは 2.7.0)

### 環境構築

1. `sudo gem install bundler` を実行する
2. `sudo bundler install` を実行して Jekyll の更新を行う

### デバッグコマンド

以下のコマンドを実行してローカルでページのデバッグができる

```sh
bundle exec jekyll serve
```

コマンドを実行すると `Server address` が表示される。
そこに表示されるアドレスへアクセスするとローカル内で確認ができる