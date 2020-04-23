---
layout: default
title: IoT.kyoto VISの使い方
---

# IoT.kyoto VIS の使い方

## 目次

### [[ステップ 0] 事前準備](#step0)

### [[ステップ 1] DynamoDB 構築手順](#step1)

### [[ステップ 2] IAM Access Key を取得する](#step2)

### [[ステップ 3] サインイン画面について](#step3)

### [[ステップ 4] グラフ画面について](#step4)

## [ステップ 0] 事前準備 <a name="step0"></a>

### 事前に準備するもの

-   IoT デバイス(計測する値を出力します)
-   AWS アカウント

### [0-1] IoT.kyoto VIS 　構成例

![全体構成図](../../images/vis-manual/whole_image.png)

### [0-2] IoT.kyoto VIS を使用するために必要なデータ

(例)温度と照度を出力する IoT デバイスの場合に必要なデータ

-   **IoT デバイスを識別する ID とタイムスタンプは必須です**
-   下表の場合、temperature と light は IoT デバイスから出力される計測対象の値です
-   IoT デバイスで計測したこれらのデータは「[[ステップ 1] DynamoDB 構築](#step1)」で DynamoDB のテーブルを作成後、
    テーブルにデータを書き込みます。さらに「[[ステップ 4] グラフ画面について](##[ステップ4]-グラフ画面について)」で設定することで、
    リアルタイムでグラフ化することができます。

| deviceID | time                | temperature | light |
| -------- | ------------------- | ----------- | ----- |
| 01       | 2016-03-04 10:17:44 | 25.6        | 103   |
| 02       | 2016-03-04 10:17:44 | 22.1        | 216   |
| 01       | 2016-03-04 10:17:45 | 25.8        | 98    |
| 02       | 2016-03-04 10:17:45 | 21.9        | 210   |

タイムスタンプは書き 6 種類の内いずれかをお使いください。画面表示辞に UTC は JST に自動変換されます。

```txt
[JST]
　YYYY-MM-DD hh:mm:ss
　YYYY/MM/DD hh:mm:ss
　YYYY-MM-DDThh:mm:ss.sss+0900
[UTC]
　YYYY-MM-DDThh:mm:ssZ
　UNIXタイムスタンプ(整数10桁)
　UNIXタイムスタンプ(整数13桁)
```

### [0-3] DynamoDB にデータを書き込む方法

-   デバイス ID／タイムスタンプ／計測値を下記のように JSON 形式で書き出します。csv は利用できません。

```json
{"light": 164, "ID": "id000", "time_sensor": "2016-03-28 15:16:48"}
{"light": 692, "ID": "id000", "time_sensor": "2016-03-28 15:16:49"}
```

-   下記のような方法で JSON を DynamoDB に書き込みます。[実装例](https://iot.kyoto/integration_case/)も参照して下さい。
    -   API を利用する
    -   各種言語向けの SDK を利用する
    -   [AWS CLI](https://aws.amazon.com/jp/cli/)を利用する
    -   AWS IoT や Lambda などの AWS のサービスを経由して書き込む
    -   fluentd などのミドルウェアを利用する
    -   DataSpider などの ETL ツールを利用する(JSON でなくても OK)
-   API/SDK ついては[AWS の開発者用リソース](https://aws.amazon.com/jp/dynamodb/developer-resources/)を参照して下さい

## [ステップ 1]DynamoDB 構築手順<a name="step1"></a>

### 1. AWS マネジメントコンソールにサインインします

-   [AWS マネジメントコンソール](https://console.aws.amazon.com/)にログインします
-   マネジメントコンソールの「サービスの検索」欄に、「dynamo」と入力し、「DynamoDB」をクリックする

![dynamoDBコンソールへの接続方法](../../images/vis-manual/access_to_dynamo.png)

### 2. リージョンを確認します

-   得に他のリージョンを選ぶ理由がない場合は[アジアパシフィック(東京)]を選択してください。

![リージョンの確認](../../images/vis-manual/check_region.png)

### 3. DynamoDB のコンソール画面で[デーブルの作成]を選択します

![リージョンの確認](../../images/vis-manual/select_create_table.png)

### 4. テーブル名に任意の名前をつけます

![リージョンの確認](../../images/vis-manual/setting_table_name.png)

### 5. プライマリキーのパーティションキーに任意の名前をつけます

-   データ型は IoT デバイスが出力する値に合わせて「文字列」または「数値」を選んでください
-   IoT デバイスの特定に分かりやすい名前を付けてください

![リージョンの確認](../../images/vis-manual/setting_partitionkey.png)

### 6. [ソートキーの追加]のチェックボックスを選択してチェックを入れます

![リージョンの確認](../../images/vis-manual/check_sortkey.png)

### 7. プライマリキーのソートキーに任意の名前をつけてください

-   時間の特定に分かりやすい名前を付けてください
-   データ型は IoT デバイスが出力する値に合わせて「文字列」または「数値」を選んでください

![リージョンの確認](../../images/vis-manual/setting_sortkey.png)

### 8. テーブル設定の[デフォルト設定の使用]のチェックボックスを選択してチェックを外します

<!-- メモ：この設定いらんくない？デフォルト5だし... -->

![リージョンの確認](../../images/vis-manual/check_out_default_table.jpg)

### 9. プロビジョニングされたキャパシティの[読み込み容量ユニット]と[書き込み容量ユニット]のチェックを外してユニット数を設定してください

<!-- メモ：この設定いらんくない？オートスケールさせない理由とは...？ -->
<!-- メモ：送信頻度にもよるし一概には言えないのでやっぱりこの設定(以下略) -->

-   IoT デバイス 2 ～ 3 個までなら「読み込み容量ユニット」が 5、「書き込み容量ユニット」が 5 で足ります
    -   [作成]をクリックしてテーブル作成は完了です
