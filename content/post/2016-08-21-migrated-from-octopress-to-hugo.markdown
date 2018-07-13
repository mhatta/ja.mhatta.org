+++
author = ""
comments = true
date = "2016-08-21T06:42:10+09:00"
description = "ブログの静的生成システムをOctopressからHugoへ移行した。"
draft = false
featured = false
image = ""
menu = ""
share = true
slug = "migrated-from-octopress-to-hugo"
tags = ["octopress", "hugo", "blogging"]
title = "OctopressからHugoへ移行"

+++
ブログの静的生成システムをOctopressからHugoへ移行した。

[2012年から](http://ja.mhatta.org/blog/2012/10/21/toying-with-octopress/)だから[Octopress](http://octopress.org/)は4年使っていることになるのだが、最近では記事生成の遅さにいらつくことが多く（かといって[isolate/integrateを使う](http://gam0022.net/blog/2013/09/28/speed-up-octopress-site-generation/)のも面倒くさいし）、加えてパッケージではなくレポジトリでしか公開されていないのでアップデートがしにくい上、最近ではどうもプロジェクトの動き自体が鈍いようだったので（いつまでたっても3.0は公式リリースされないし）、思い切って[Hugo](https://gohugo.io/)へ移行してみた。ふだんはPythonを使っているので最初は[Pelican](http://blog.getpelican.com/)を考えたのだが、まあ流行り物ということで。PelicanもHugoもDebianのパッケージになっているので導入は楽である。[ドキュメント](https://gohugo.io/overview/introduction/)も[テーマ](http://themes.gohugo.io/)もそこそこ揃っている。まあテーマに関しては、現状質量共にOctopressや他のポピュラーなブログ・システムには及びもつかないが…。

記事コンテンツはしょせんMarkdownなのでそのままコピーしても大したことはないと思うが、Octopressとは日付のフォーマットなどが微妙に違うし、画像など静的なコンテンツもあるので、Hugoに用意されているJekyllからのインポータを使うとよい。

```
$ hugo import jekyll octopressdir/source hugodir
```

とかすると、octopressdirの内容が適当に変換されてhugodirに入る。当然Octopress固有のタグ等は使えないので、あとは適当に手で直す。特にcatgegoriesは使えないのでtagsにしないといけない。ちなみにHugoはMarkdownのプロセッサに[Blackfriday](https://github.com/russross/blackfriday)を使っているので、例えばGitHub Flavored Markdownとは微妙に文法が違う。

Hugoは[TOML](https://github.com/toml-lang/toml)だけではなく[YAML](http://yaml.org/)も理解するので、サイト全体の設定はOctopressの_config.yamlをある程度流用できる。まあこの際すべてTOMLで書き直した方がよいと思うが。日本語主体のブログであれば、config.tomlに

```
languageCode = "ja"
hasCJKLanguage = "true"
```

あたりを入れておくとよい。`enableRobotsTXT = "true"`も指定しておくとrobots.txtを自動生成してくれる。

Hugoは特に指定しないと[front matter](https://jekyllrb.com/docs/frontmatter/)の`title`を記事URLに使うのだが、タイトルが日本語というかマルチバイトの場合アレなので、urlか[slug](https://codex.wordpress.org/Glossary#Slug)を自分で書いて直接指定することになると思う。Octopressと同じURLを維持したい場合は、個々の記事のfront matterに

```
url = /blog/2016/08/21/migrated-from-octopress-to-hugo/
```

等とフルで書くか、config.tomlに

```
[permalinks]
  post = "/blog/:year/:month/:day/:slug/"
```

と書いた上で、記事のfront matterで

```
slug = "migrated-from-octopress-to-hugo"
```

のように書けばよい。

テーマに関しては、とりあえず

```
$ git clone --depth 1 --recursive https://github.com/spf13/hugoThemes.git themes
```

として既存のものを全部落としてきて、`hugo --theme テーマ名`でいろいろ試してみるとよい。テーマ名は`themes/`以下のディレクトリ名。細かなカスタマイズはconfig.tomlの中で`[params]`ブロックの中に書くことになるが、パラメータはテーマ依存が多いので、最終的にはテーマの中を覗かないとどうにもならないだろう。

で、あとは

```
$ hugo
```

でコンテンツが生成される。生成結果は`public`ディレクトリ以下に入るので、この中身を好きなところへ持っていけばいいわけですね。ちなみにカバー画像等は`static`ディレクトリ以下に入れればよい。このへんは`hugo import jekyll`を使えば勝手にやってくれる。

なお、フィードのURLはatom.xmlではなくindex.xmlになるので注意。

動的プレビューは

```
$ hugo server
```

として`http://localhost:1313`にアクセスすればよい。`-w`オプションをつけなくてもファイル更新には自動追従するようだ。

今から思えばOctopressは`rake`タスクがよくできていて、大概のジョブを手軽にこなすことができたのだが、現状Hugoはいろいろと手動である。例えばデプロイは、Octopressの場合適切に設定すればあとは`rake deploy`か`rake gen_deploy`一発だったが、私のように相変わらずレンサバに置いている場合、rsyncあたりを使って

```
$ rsync -azr --delete -e ssh public/* server.example.org:/path/to/wwwdir
```

とかすることになる。本来はGitHub Pagesに置いて[Wercker](http://wercker.com/)でも使えということなんでしょうが…。

スピードに関しては、55記事あるうちのサイトの場合、timeで測定すると

   Name     | Time
   ---------|-------
   Hugo     |0:00.86
   Octopress|0:12.26

となる。何だこれはという速さ。
