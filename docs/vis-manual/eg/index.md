---
layout: default
title: How to use IoT.kyoto VIS
---

# How to use IoT.kyoto VIS

## [Step 0] Advance preparation

### Things to prepare in advance

- IoT device (outputs the value to be measured)
- AWS account

### [0-1] IoT.kyoto VIS configuration example

![Overall configuration diagram](../../images/vis-manual/whole_image.png)

### [0-2] Data required to use IoT.kyoto VIS

**For example, data required for IoT devices that output temperature and illuminance**

- **ID and timestamp to identify IoT device are required**
- In the case of the table below, temperature and light are the measurement target values output from IoT devices.
- IoTデバイスで計測したこれらのデータは「[1]DynamoDB構築手順」でDynamoDBのテーブルを作成後、テーブルにデータを書き込みます。さらに「[4]グラフ画面について」で設定することで、リアルタイムでグラフ化することができます。