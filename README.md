# TeamFitness

## 説明

チームの健康をGithub上のいろんな情報から判断できたらな〜と思って試行錯誤中。

Github APIを使って、メトリクスとしてコメント数などを評価します（予定）。

現状はプルリクとコメント情報取得するだけです。
リファクタリングとかしてないオレオレスクリプトなので綺麗にしていただけると泣いて喜びます。


## 使い方

1. .netrcがなければ作る

  ```
  $ touch ~/.netrc
  $ chmod or-g ~/.netrc
  ```

2. 中にGithubのアカウント情報を記述

  ```
  machine api.github.com
    login defunkt
    password c0d3b4ssssss!
  ```

3. API経由で情報を取得する

  ```
  fitness = TeamFitness.new('upinetree/team-fitness')
  fitness.fetch                       #=> PR, コメントを取得（現状closedのPRに紐づくもののみ）
  fitness.pull_requests               #=> 取得済みのPR
  fitness.comments                    #=> 取得済みのコメント（PR, Commit, File Changed 全部）
  fitness.export_csv_to('filename')   #=> csv形式で出力
  fitness.import_csv_from('filename') #=> csv形式で出力
  ```

まとめて取ってくる荒っぽいスクリプトを`script/fetch_batch.rb`に置いたので参考までに。

r言語で可視化するスクリプトは`r`フォルダ配下に置いてあります。


### Two-Factor Authentication の場合

毎回通すの面倒なのでOAuthを使う

1. ブラウザでGitHubにログインして、

  `Account Setting -> Applications -> Personal Access Tokens -> Create new token`

  できたTokenをコピーしておく

2. .netrcにTokenを記述

  ```
  machine api.github.com
    login defunkt
    password <your 40 char token>
  ```

