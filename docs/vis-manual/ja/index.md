---
layout: vis-manual
title: IoT.kyoto VISの使い方
description: 初めてIoT.kyoto VISを触る型のためのマニュアルです。基本的な機能についてはこちらを参考ください。
author: IoT.kyoto
---

## 目次

### [[ステップ 0] 事前準備](#step0)

### [[ステップ 1] DynamoDB テーブルを構築する](#step1)

### [[ステップ 2] IAM Access Key を取得する](#step2)

### [[ステップ 3] IoT.kyoto VIS のアカウントを使ってログインする](#step3)

### [[ステップ 4] グラフ画面で可視化する](#step4)

### [[付録 1] グラフ設定を変更する](#option1)

### [[付録 2] しきい値の設定をする](#option2)

### [[付録 3] 過去データを検索する](#option3)

### [[付録 4] csv をダウンロードする](#option4)

### [[付録 5] グラフを並び替える](#option5)

### [[付録 6] グラフを削除する](#option6)

## [ステップ 0] 事前準備 <a name="step0"></a>

### 事前に準備するもの

-   IoT デバイス(計測する値を出力します)
-   AWS アカウント

### 1. IoT.kyoto VIS 　構成例

IoT.kyoto VIS を活用する際の構成例として以下があります

IoT.kyoto VIS ではデータが Amazon DynamoDB に存在していることが前提となります

![全体構成図](../../images/vis-manual/ja/whole_image.png)

### 2. IoT.kyoto VIS を使用するために必要なデータ

(例)温度と照度を出力する IoT デバイスの場合に必要なデータ

-   **IoT デバイスを識別する ID とタイムスタンプは必須です**
-   下表の場合、temperature と light は IoT デバイスから出力される計測対象の値です
-   IoT デバイスで計測したこれらのデータは「[[ステップ 1] DynamoDB 構築](#step1)」で DynamoDB のテーブルを作成後、
    テーブルにデータを書き込みます。さらに「[[ステップ 4] グラフ画面で可視化する](#step4)」で設定することで、
    リアルタイムでグラフ化することができます。

    | deviceID | time                 | temperature | light |
    | -------- | -------------------- | ----------- | ----- |
    | 01       | 2016-03-04T10:17:44Z | 25.6        | 103   |
    | 02       | 2016-03-04T10:17:44Z | 22.1        | 216   |
    | 01       | 2016-03-04T10:17:45Z | 25.8        | 98    |
    | 02       | 2016-03-04T10:17:45Z | 21.9        | 210   |

-   タイムスタンプは下記の内いずれかをお使いください。画面表示時に UTC は 設定されたタイムゾーン に自動変換されます。

    **TODO: 新しいものに変更する**

```txt
[UTC]
  YYYY-MM-DDThh:mm:ssZ
  UNIXタイムスタンプ(整数10桁)
  UNIXタイムスタンプ(整数13桁)
[それ以外]
  YYYY-MM-DD hh:mm:ss
  YYYY-MM-DD hh:mm:ss.sss
  YYYY-MM-DDThh:mm:ss+hhmm
  YYYY-MM-DDThh:mm:ss+hh:mm
  YYYY-MM-DDThh:mm:ss.sss+hhmm
  YYYY-MM-DDThh:mm:ss.sss+hh:mm
  YYYY/MM/DD hh:mm:ss
  YYYY/MM/DD hh:mm:ss.sss
  YYYY/MM/DDThh:mm:ss+hhmm
  YYYY/MM/DDThh:mm:ss+hh:mm
  YYYY/MM/DDThh:mm:ss.sss+hhmm
  YYYY/MM/DDThh:mm:ss.sss+hh:mm
```

### 3. DynamoDB にデータを書き込む方法

-   デバイス ID／タイムスタンプ／計測値を下記のように **JSON 形式**で書き出します
-   csv 等の場合は JSON 形式に変換する必要があります

```json
{"light": 164, "ID": "id000", "time_sensor": "2016-03-28 15:16:48"}
{"light": 692, "ID": "id000", "time_sensor": "2016-03-28 15:16:49"}
```

-   下記のような方法で データ を DynamoDB に書き込みます([実装例](https://iot.kyoto/integration_case/)も参考にしてください)
    -   API を利用する
    -   各種言語向けの SDK を利用する
    -   [AWS CLI](https://aws.amazon.com/jp/cli/)を利用する
    -   AWS IoT や Lambda などの AWS のサービスを経由して書き込む
    -   fluentd などのミドルウェアを利用する
    -   DataSpider などの ETL ツールを利用する(JSON でなくても OK)
-   API/SDK ついては[AWS の開発者用リソース](https://aws.amazon.com/jp/dynamodb/developer-resources/)を参照して下さい

## [ステップ 1]DynamoDB テーブルを構築する<a name="step1"></a>

### 1. AWS マネジメントコンソールにサインインします

-   [AWS マネジメントコンソール](https://console.aws.amazon.com/)にログインします
-   マネジメントコンソールの「サービスの検索」欄に、「dynamo」と入力し、「DynamoDB」を選択します

![dynamoDBコンソールへの接続方法](../../images/vis-manual/ja/access_to_dynamo.png)

### 2. リージョンを確認します

-   得に他のリージョンを選ぶ理由がない場合は[アジアパシフィック(東京)]を選択してください。

![リージョンの確認](../../images/vis-manual/ja/check_region.png)

### 3. DynamoDB のコンソール画面で[デーブルの作成]を選択します

![テーブルの作成](../../images/vis-manual/ja/select_create_table.png)

### 4. テーブル名に任意の名前を入力します

![テーブル名の決定](../../images/vis-manual/ja/setting_table_name.png)

### 5. プライマリキーのパーティションキーに任意の名前を入力します

-   IoT デバイスを識別する値が入るキーになります
-   IoT デバイスが送信するキー名に沿った名前を入力してください
-   データ型は IoT デバイスが出力する値に合わせて「文字列」または「数値」を選んでください

![パーティションキーの設定](../../images/vis-manual/ja/setting_partitionkey.png)

### 6. [ソートキーの追加]のチェックボックスにチェックを入れます

![ソートキー追加](../../images/vis-manual/ja/check_sortkey.png)

### 7. プライマリキーのソートキーに任意の名前を入力します

-   データの送信時刻など時刻が入ります
-   IoT デバイスが送信する送信時間のキー名に沿った名前を入力してください
-   データ型は IoT デバイスが出力する値に合わせて「文字列」または「数値」を選んでください

![ソートキーの設定](../../images/vis-manual/ja/setting_sortkey.png)

## [ステップ 2]IAM Access Key を取得する<a name="step2"></a>

ここで作成するアクセスキーにはすべての DynamoDB テーブルのレコードとテーブル情報を取得することができる権限を付与します。テーブルを絞りたい場合は[こちら](#create_custom_key)の手順を参考にしてください。

### 1. Identity and Access Management(IAM)コンソールを開いてください

-   マネジメントコンソールの「サービスの検索」欄に、「IAM」と入力し「IAM」を選択します

![IAMコンソールの選択](../../images/vis-manual/ja/open_iam.png)

### 2. [ユーザー]を選択して開き、[ユーザーを追加]をクリックし、任意の名前でユーザーを作成します

![ユーザーを追加](../../images/vis-manual/ja/select_add_user.png)

-   [プログラムによるアクセス]のチェックボックスにチェックを入れます
-   [次のステップ]を選択します

![ユーザーの作成](../../images/vis-manual/ja/create_user.png)

### 3. アクセス権限の設定を行います

-   [既存のポリシーを直接アタッチ]を選択します
-   [AmazonDynamoDBReadOnlyAccess]ポリシーにチェックをいれて[次のステップ]を選択します

![ポリシーの選択](../../images/vis-manual/ja/select_policy.png)

### 4. [タグの追加]は任意で入力し、[次のステップ]を選択します

### 5. 内容を確認し問題がなければ[ユーザーの作成]ボタンを選択してアカウントを作成します

-   アカウント作成後、認証情報が記載された csv ファイルをダウンロードします

    <span style="color: red;">※ここでダウンロードを忘れると再度認証情報の発行が必要になるので必ずダウンロードしてください</span>

![新規ユーザー確認](../../images/vis-manual/ja/verification_create_user.png)

![csvダウンロード](../../images/vis-manual/ja/download_csv.png)

## ※テーブルを絞った権限を付与した Access Key の作成方法<a name="create_custom_key"></a>

Access Key の発行が完了している場合は[ステップ 3](#step3)に進んでください

### 1. Identity and Access Management(IAM)コンソールを開いてください

-   マネジメントコンソールの「サービスの検索」欄に、「IAM」と入力し「IAM」を選択します

![IAMコンソールの選択](../../images/vis-manual/ja/open_iam.png)

### 2. [ポリシー]を選択して開き、[ポリシーの作成]を選択します

![ポリシー作成画面](../../images/vis-manual/ja/select_create_policy.png)

### 3. 特定の DynamoDB テーブルの読み取り専用権限を付与したポリシーを作成します

-   [サービスを選択]から DynamoDB を選択します
    ![サービスの選択](../../images/vis-manual/ja/select_service.png)
-   [フィルタアクション]に`getItem`と入力し`GetItem`のチェックボックスにチェックを入れます
    ![アクションの選択(getItem)](../../images/vis-manual/ja/check_get_item.png)
-   [フィルタアクション]に`query`と入力し`Query`のチェックボックスにチェックを入れます
    ![アクションの選択(query)](../../images/vis-manual/ja/check_query.png)
-   [フィルタアクション]に`describeTable`と入力し`DescribeTable`のチェックボックスにチェックを入れます
    ![アクションの選択(describeTable)](../../images/vis-manual/ja/check_describe_table.png)
-   [リソース]を選択し[ARN の追加]ボタンを選択します
    ![リソースの選択](../../images/vis-manual/ja/select_resource.png)
-   必要情報を記入後[追加]ボタンを選択します
    ![ARNの入力](../../images/vis-manual/ja/input_arn.png)
-   入力内容を確認し[ポリシーの確認]を選択します
    ![ポリシーの確認を選択](/../../images/vis-manual/ja/setting_all_policy.png)
-   任意のポリシー名を入力して[ポリシーの作成]を選択します
    ![ポリシー作成完了](../../images/vis-manual/ja/complete_create_policy.png)

### 4. [ユーザー]を選択して開き[ユーザーを追加]を選択し、任意の名前でユーザーを作成します

![ユーザーを追加](../../images/vis-manual/ja/select_add_user.png)

-   [プログラムによるアクセス]のチェックボックスにチェックを入れます
-   [次のステップ]をクリックします

![ユーザーの作成](../../images/vis-manual/ja/create_user.png)

### 5. アクセス権限の設定を行います

-   [既存のポリシーを直接アタッチ]を選択します
-   3 で作成したポリシーのチェックボックスにチェックを入れて[次のステップ]を選択します
-   先程のポリシーをアタッチすることで特定の DynamoDB からデータを取得することが許可されます

![ポリシーの選択](../../images/vis-manual/ja/select_custom_policy.png)

### 6. [タグの追加]は任意で入力し、[次のステップ]を選択します

### 7. 内容を確認し問題がなければ[ユーザーの作成]ボタンを選択してアカウントを作成します

-   アカウント作成後、認証情報が記載された csv ファイルをダウンロードします

    <span style="color: red;">※ここでダウンロードを忘れると再度認証情報の発行が必要になるので必ずダウンロードしてください</span>

![新規ユーザー確認](../../images/vis-manual/ja/verification_create_custom_user.png)

![csvダウンロード](../../images/vis-manual/ja/download_csv.png)

## [ステップ 3] IoT.kyoto VIS のアカウントを使ってログインする<a name="step3"></a>

### 0. [IoT.kyoto VIS](https://vis2.iot.kyoto){:target="\_blank"}を開きます

![VISログイン画面](../../images/vis-manual/ja/vis_login.png)

1. サインイン：新規登録を終えたあとはここからサインインしてください
   (旧 VIS サイトで登録されたログイン情報もこちらで利用することができます)

2. 新規登録：アカウントを保有していない場合はこちらからアカウント作成をしてください
3. パスワードを忘れた方はこちら：アカウントのパスワードを忘れた場合はこちらからパスワードの再発行を実施してください

### 1. アカウントの作成をします

#### 1.1. 「新規登録」ボタンを選択すると新規登録画面が表示されます

![VIS新規登録画面](../../images/vis-manual/ja/create_account.png)

#### 1.2. メールアドレスと ID、パスワードをそれぞれ入力します

ID がメールアドレスと同様で問題なければ「メールアドレスと同じものを ID として利用する」のチェックボックスにチェックを入れます

利用規約を確認、同意にチェックを入れた後、「登録」ボタンを選択すると設定したメールアドレスに確認メールが届きます。

<span style="color: red;">※パスワードを設定する際は大文字、小文字、数字をそれぞれ含め 8 文字以上に設定してください。この条件を満たさない場合はエラーになります。</span>

#### 1.3. 設定したメールアドレスに認証メールが届くのを待ちます

メール内のリンクをクリックすると登録完了です

### 2. パスワードを忘れてしまった場合

#### 2.1. 「パスワードを忘れた方はこちら」を選択します

![認証コード送信画面](../../images/vis-manual/ja/send_code.png)

#### 2.2. ID を入力して「パスワードをリセットする」ボタンを選択します

登録したメールアドレスに認証コードが送信されます

<span style="color: red;">※ID を忘れた場合はパスワードの再設定はできませんのでご注意ください</span>

#### 2.3 メールに記載された認証コードを使ってパスワードのリセットをします

送信された認証コードをフォームに入力し、新しいパスワードを設定します

「パスワードを設定する」ボタンを選択するとパスワードの再設定完了です

![パスワードリセット](../../images/vis-manual/ja/reset_password.png)

## [ステップ 4] グラフ画面で可視化する<a name="step4"></a>

![グラフ画面メニュー](../../images/vis-manual/ja/vis_menu.png)

1. ユーザー設定：タイムゾーンや言語の設定ができます
2. web サイト：[IoT.kyoto](https://iot.kyoto){:target="\_blank"}のページに遷移します
3. マニュアル：本ページに遷移します
4. ログアウト：ログアウトします
5. グラフ追加：グラフを追加します
6. グラフ並べ替え：グラフが複数ある場合、グラフの並び替えをします
7. グラフ表示方法切り替え：グラフを 2 列に並べたり、1 列に並べたりできます

### 1. グラフを追加します

#### 1.1. 「グラフ追加」アイコンを選択します

**新しい設定フローに則って新しくマニュアルを作成します**

## [付録 1] グラフ設定を変更する<a name="option1"></a>

**設定フローの修正完了後対応します**

## [付録 2] しきい値の設定をする<a name="option2"></a>

### 1. しきい値設定画面を開きます

-   しきい値を設定したいグラフ画面の[歯車アイコン]を選択します

![グラフ設定選択](../../images/vis-manual/ja/select_graph_setting.png)

-   設定画面から[閾値設定]タブを開きます

![閾値設定選択](../../images/vis-manual/ja/select_alert_setting.png)

### 2. 設定したい項目にしきい値を設定します

-   表示対象キーからしきい値を設定したい項目を選択します
-   設定したい項目(上限/下限)のスイッチを切り替え、数値を設定します
-   アラートメールを送信する場合は[アラートメール送信先]にメールアドレスを入力してください
    複数指定する場合はカンマで区切ってください(最大 5 件まで登録できます)
-   設定項目の入力が完了したら[保存]ボタンを選択します

![閾値設定](../../images/vis-manual/ja/setting_alert.png)

### 異常履歴の確認ができます

-   設定したしきい値を上回る/下回ると異常履歴に通知が来ます

![異常履歴バッチ](../../images/vis-manual/ja/alert_batch.png)

-   [異常履歴]ボタンを選択すると設定したしきい値を上回った/下回った履歴を確認することができます(最大 100 件)

![異常履歴](../../images/vis-manual/ja/alert_history.png)

### メール設定をすることでメール通知を受け取ることができます

-   しきい値設定にてアラートメール送信先を指定するとしきい値を上回った/下回ったときにメール通知を受け取ることができます

    <span style="color: red;">※IoT.kyoto VIS 画面を開いている間のみメールを受け取ることができます</span>

![アラートメール例](../../images/vis-manual/ja/alert_mail.png)

## [付録 3] 過去データを検索する<a name="option3"></a>

### 1. 過去データ検索画面を開きます

-   過去データを検索したいグラフ画面の[虫眼鏡アイコン]を選択します

![検索画面選択](../../images/vis-manual/ja/select_search.png)

### 2. 検索事項を記入します

-   検索したいデバイスや表示対象キーの選択をします
-   検索したい日時の指定をします
    -   日時指定では指定した日時「以前」「以後」と「期間指定」の選択が可能です
-   検索結果のグラフの縦軸レンジを設定したい場合はレンジ設定を「on」にして数値を設定します

![検索事項入力](../../images/vis-manual/ja/input_search_conditions.png)

### 3. グラフを取得します

-   [検索]ボタンを選択することでデータを取得しグラフを表示することができます

![検索結果](../../images/vis-manual/ja/search_result.png)

<span style="color: red;">※参照している DynamoDB テーブルの読み込みキャパシティ状況によってデータ取得に失敗することがあります</span>

<span style="color: red;">その際は検索対象期間を狭くしたり DynamoDB テーブルの読み込みキャパシティの調整を実施してください</span>

## [付録 4] csv をダウンロードする<a name="option4"></a>

### 1. csv ダウンロード画面を開きます

-   csv のダウンロードをしたいグラフ画面の[ダウンロードアイコン]を選択します

![csvダウンロード選択](../../images/vis-manual/ja/select_csv_download.png)

### 2. ダウンロードしたいデバイスと対象期間を指定します

-   ダウンロードしたいデバイスをセレクタから選択します
-   ダウンロード対象期間を設定します
    -   対象期間の設定では指定した日時「以前」「以後」と「期間指定」の選択が可能です

![csvダウンロード条件記入](../../images/vis-manual/ja/input_csv_download_conditions.png)

### 3. csv ファイルを取得します

-   [ダウンロード]ボタンを選択することで指定された条件のデータの csv ファイルを取得することができます

![csvダウンロード結果](../../images/vis-manual/ja/csv_download_result.png)

<span style="color: red;">※取得対象データが 100,000 件あるいは 5MB を超える場合はダウンロードできません</span>

<span style="color: red;">その場合は対象期間を調整してください</span>

<span style="color: red;">※取得対象データが 100,000 件、5MB に収まっていても対象の DynamoDB テーブルの読み込みキャパシティの状況によってデータの取得に失敗することがあります</span>

<span style="color: red;">その場合は対象期間を調整したり DynamoDB テーブルの読み込みキャパシティを調整してください</span>

## [付録 5] グラフを並び替える<a name="option5"></a>

## [付録 6] グラフを削除する<a name="option6"></a>
