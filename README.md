# TeamFitness

## 説明

チームの健康をGithub上のいろんな情報から判断できたらな〜と思って試行錯誤中。

Github APIを使って、メトリクスとしてコメント数などを評価します（予定）。

現状はコメント取得するだけです。


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

3. TeamFitnessを使う

  ```
  fitness = TeamFitness.new('upinetree/team-fitness')
  fitness.fetch                 #=> PRを取得（現状closedのみ）
  fitness.comments              #=> コメント取得（PR, Commit, File Changed 全部）
  fitness.export_to('filename') #=> csv形式で出力
  ```


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

