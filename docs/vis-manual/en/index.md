---
layout: vis-manual
title: How to use IoT.kyoto VIS
description: It is a manual for the type that touches IoT.kyoto VIS for the first time. Please refer to here for basic functions.
---

## Contents

### [[Step 0] Advance preparation](#step0)

### [[Step 1] Create a DynamoDB table](#step1)

### [[Step 2] Get IAM Access Key](#step2)

### [[Step 3] Login with your IoT.kyoto VIS account](#step3)

### [[Step 4] Create a graph](#step4)

### [[Option 1] Change graph settings](#option1)

### [[Option 2] Set thresholds](#option2)

### [[Option 3] Search past data](#option3)

### [[Option 4] Download data in CSV file](#option4)

### [[Option 5] Rearrange panels](#option5)

### [[Option 6] Delete graph](#option6)

## [Step 0] Advance preparation <a name="step0"></a>

### Things to prepare in advance

-   IoT device (outputs the measured value)
-   AWS account

### 1. IoT.kyoto VIS configuration example

The following is a configuration example with IoT.kyoto VIS; note that your data has to be in Amazon DynamoDB in order to use IoT.kyoto VIS.

![Overall configuration diagram](../../images/vis-manual/en/whole_image.png)

### 2. Data required to use IoT.kyoto VIS

Below shows the data required for IoT devices that output temperature and illuminance, as an example.

-   **ID and timestamp are required.** ID identifies the connected IoT device, and timestamp identifies the time of measurement, recording etc of each data.
-   In the table below, "temperature" and "light" are the measured values output from the IoT device.
-   The data from the IoT device is transmitted and stored in DynamoDB table in [[Step 1] Create a DynamoDB table](#step1). In addition, you can make a line graph of the data in real time in [[Step 4] Create a graph](#step4).

    | deviceID | time                 | temperature | light |
    | -------- | -------------------- | ----------- | ----- |
    | 01       | 2016-03-04T10:17:44Z | 25.6        | 103   |
    | 02       | 2016-03-04T10:17:44Z | 22.1        | 216   |
    | 01       | 2016-03-04T10:17:45Z | 25.8        | 98    |
    | 02       | 2016-03-04T10:17:45Z | 21.9        | 210   |

-   Use one of the following timestamps. UTC time will be automatically converted to the local time zone you set when generating the graph.

```txt
[UTC]
  YYYY-MM-DDThh:mm:ssZ
  UNIX timestamp(Integer 10 digits)
  UNIX timestamp(Integer 13 digits)
[Others]
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

### 3. How to write data to a DynamoDB table

-   Export device ID / timestamp / measurement value in **JSON format** as below.
-   Convert to JSON format in case of CSV etc.

```json
{"light": 164, "ID": "id000", "time_sensor": "2016-03-28 15:16:48"}
{"light": 692, "ID": "id000", "time_sensor": "2016-03-28 15:16:49"}
```

-   Write data to a DynamoDB table by the following method. (Please also refer to [Implementation example](https://iot.kyoto/integration_case/))
    -   Use API.
    -   Use SDK for various languages.
    -   Use [AWS CLI](https://aws.amazon.com/jp/cli/).
    -   Write via AWS services such as AWS IoT and Lambda.
    -   Use middleware such as Fluentd.
    -   Use an ETL tool such as DataSpider (OK even if it is not JSON).
-   Please refer to [AWS developer resources](https://aws.amazon.com/jp/dynamodb/developer-resources/) for API / SDK.

## [Step 1]Create a DynamoDB table<a name="step1"></a>

### 1. Sign in to the AWS Management Console.

-   Log in to the [AWS Management Console](https://console.aws.amazon.com/).
-   Enter "dynamo" in the "Find Services" field of the AWS Management Console and select "DynamoDB".

![How to connect to the dynamoDB console](../../images/vis-manual/en/access_to_dynamo.png)

### 2. Check your AWS region.

-   Select the region nearest to you unless you have a reason to choose another.

![Check the region](../../images/vis-manual/en/check_region.png)

### 3. Press [Create table] in the DynamoDB console.

![create table](../../images/vis-manual/en/select_create_table.png)

### 4. Enter any name in the table name field.

![Determine table name](../../images/vis-manual/en/setting_table_name.png)

### 5. Enter any name for the partition key of the primary key.

-   This key should contain a value that identifies an IoT device from which the data is transmitted.
-   Enter the key name of which value is used to identify an IoT device.
-   Select "Character string" or "Numeric value" as its data type according to the output value format of your IoT device.

![Set partition key](../../images/vis-manual/en/setting_partitionkey.png)

### 6. Check the [Add sort key] box.

![Add sort key](../../images/vis-manual/en/check_sortkey.png)

### 7. Enter any name for the sort key of the primary key.

-   This key should contain time data such as data transmission time.
-   Enter the key name that contains time data sent from your IoT device.
-   Select "Character string" or "Numeric value" as its data type according to the output value format of your IoT device.

![Sort key setting](../../images/vis-manual/en/setting_sortkey.png)


### 8. Make sure the box [Use default settings] is checked. Press [Create].

-   The table will ne generated by pressing [Create].

![Creation of the Dynamodb table](../../images/vis-manual/en/create_dynamodb_end.png)

## [Step 2]Get IAM Access Key<a name="step2"></a>

Here we will be generating an access key that are granted access to table information of all DynamoDB tables and their data. If you want to narrow down the permission, please refer to the procedure [here](#create_custom_key).

### 1. Open the Identity and Access Management (IAM) console.

-   Enter "IAM" in the "Find Services" field of the AWS Management Console and select "IAM".

![IAM console selection](../../images/vis-manual/en/open_iam.png)

### 2. Select [Users] to open it. Press [Add User] to create a user with any name.

![Add user](../../images/vis-manual/en/select_add_user.png)

-   Check the box of [Programmatic access].
-   Press [Next: Permissions].

![Create user](../../images/vis-manual/en/create_user.png)

### 3. Set access authority.

-   Select [Attach existing policies directly].
-   Check the [AmazonDynamoDBReadOnlyAccess] policy and press [Next Step].

![Policy selection](../../images/vis-manual/en/select_policy.png)

### 4. Enter [Add Tag] as desired and press [Next: Review].

### 5. If there is no probrem with the content, press [Create user].

-   After creating the account, a CSV file that contains the user's authentication information will be generated; press [Download .csv] and download the file.

    <span style="color: red;">※If you forget to download the CSV file, you may have to recreate the authentication information, so be sure to download it.</span>

![New user confirmation](../../images/vis-manual/en/verification_create_user.png)

![csv download](../../images/vis-manual/en/download_csv.png)

## ※How to create an Access Key with limited privileges<a name="create_custom_key"></a>

If you have already generated the access key, proceed to [Step 3](#step3).

### 1. Open the Identity and Access Management (IAM) console.

-   Enter "IAM" in the "Find Services" field of the AWS Management Console and select "IAM".

![IAM console selection](../../images/vis-manual/en/open_iam.png)

### 2. Select "Policies" to open it. Press "Create policy".

![Policy creation screen](../../images/vis-manual/en/select_create_policy.png)

### 3. Create a policy that grants read-only permissions for a specific DynamoDB table.

-   Select DynamoDB from [Select Service].
    ![Service selection](../../images/vis-manual/en/select_service.png)
-   Enter `getItem` in [Filter action] and check the box of `GetItem`.
    ![Select action (getItem)](../../images/vis-manual/en/check_get_item.png)
-   Enter `query` in [Filter action] and check the box of `Query`.
    ![Select action (query)](../../images/vis-manual/en/check_query.png)
-   Enter `describeTable` in [Filter action] and check the box of  `DescribeTable`.
    ![Select Action (describeTable)](../../images/vis-manual/en/check_describe_table.png)
-   Select Resources and press [Add ARN].
    ![Resource selection](../../images/vis-manual/en/select_resource.png)
-   Fill in the required information and press [Add].
    ![Enter ARN](../../images/vis-manual/en/input_arn.png)
-   Confirm your entry and press [Review policy].
    ![Select Confirm Policy](/../../images/vis-manual/en/setting_all_policy.png)
-   Enter any policy name and press [Create policy].
    ![Policy creation completed](../../images/vis-manual/en/complete_create_policy.png)

### 4. Select [Users] to open it. Press [Add User] to create a user with any name.

![Add user](../../images/vis-manual/en/select_add_user.png)

-   Check the box of [Programmatic access].
-   Press [Next: Permissions].

![Create user](../../images/vis-manual/en/create_user.png)

### 5. Set access authority.

-   Select [Attach existing policies directly].
-   Check the box of the policy created in 3 and select [Next: Tags].
-   Attaching the policy above may allow you to retrieve data from a specific DynamoDB table.

![Policy selection](../../images/vis-manual/en/select_custom_policy.png)

### 6. Enter [Add Tag] as desired and press [Next: Review].

### 7. If there is no probrem with the content, press [Create user].

-   After creating the account, a CSV file that contains the user's authentication information will be generated; press [Download .csv] and download the file.

    <span style="color: red;">Note: if you forget to download the CSV file, you may have to recreate the authentication information, so be sure to download it.</span>

![New user confirmation](../../images/vis-manual/en/verification_create_custom_user.png)

![csv download](../../images/vis-manual/en/download_csv.png)

## [Step 3] Login with your IoT.kyoto VIS account<a name="step3"></a>

<span style="color: red;">
Note: IoT.kyoto VIS does not support Internet Explorer; use modern browsers such as Google Chrome and Firefox.

### 0. Access [IoT.kyoto VIS](https://vis2.iot.kyoto){:target="\_blank"}].

![VIS login screen](../../images/vis-manual/en/vis_login.png)

1. [Sign In]: sign in from here after completion of registration.
   (You can also use the login information registered on the old VIS site here.)

2. [Create Account]: if you do not have an account, please create one from here.
3. [Forgot your password?]: if you forget your account password, please reissue your password here.

### 1. Create an account

#### 1.1. Press [Create Account] to go to the registration page.

![VIS new registration screen](../../images/vis-manual/en/create_account.png)

#### 1.2. Enter your email address, ID and password.

If you prefer your ID to be the same as the email address, check "I prefer to use my email address as my ID".

Accept the terms of service by checking "Agree with the Terms" and press [Register]; a confirmation email will be sent to the email address you entered.

<span style="color: red;">Note: when setting the password, set it to 8 characters or more, including both uppercase and lowercase letters, and a number; an error may occur if this condition is not met.</span>

#### 1.3. Wait for the verification email to arrive.

Click the link in the email to complete registration.

### 2. If you forget your password

#### 2.1. Press [Forgot your password?].

#### 2.2. Enter your ID and press the [Reset Password].

![Authentication code transmission screen](../../images/vis-manual/en/send_code.png)

A verification code will be sent to the registered email address.

<span style="color: red;">Note: your ID is required to reset the password.</span>

#### 2.3 Reset the password using the verification code in the email.

Enter the verification code in the form and set a new password.

Press [Reset Password] to complete the password reset.

![Password reset](../../images/vis-manual/en/reset_password.png)

## [Step 4] Create a graph<a name="step4"></a>

![Graph screen menu](../../images/vis-manual/en/vis_menu.png)

1. [General Settings]: change time zone and language settings
2. [IoT.kyoto]: move to [IoT.kyoto](https://iot.kyoto){:target="\_blank"}
3. [How to Use]: move to this page
4. [Log out]: log out
5. [Add Graph]: add a graph
6. [Rearrange panels]: sort the graphs (if there are more than one)
7. [Change graph size]: show the graphs in two columns or one column

### 1. Add a graph

#### 1.1. Press the [Add graph] icon.

![Add Graph](../../images/vis-manual/en/select_add_graph.png)

### 2. Set the credential.

-   Enter the access key and the secret key created in [[Step 2] Get IAM Access Key](#step2).
-   Enter any name for the credential store name.

    <span style="color: red;">Note: if you specify a name that you have already registered, it may be overwritten.</span>

-   For Region, select the region in which the DynamoDB table is created. Press [Next].

![new credential setting](../../images/vis-manual/en/new_credential_setting.png)

-   If you want to use credentials you already registered, select [Existing credentials].
-   Select the credentials you want to use. Press [Next].

![existing credential setting](../../images/vis-manual/en/existing_credential.png)

### 3. Enter the table name.

-   Enter a name of the table with data you want to visualize.
-   Press [Check connection].
-   Make sure the displayed partition key and sort key of the table are correct. 
-   Press [Next].

<span style="color: red;">Note: if the error message "Please check the table name" is shown, the table name you entered was not found. Make sure the table name is correct.</span>

<span style="color: red;">Note: if the error message "Please check the credential set in Step1." is shown, it is possible that the authentication information is incorrect or the credential does not have sufficient permissions to access data. Please check each and if necessary, refer to [[Step 2] Get IAM Access Key](#step2).</span>

|![input table name](../../images/vis-manual/en/input_table_name.png)|![confirm table info](../../images/vis-manual/en/confirm_table_info.png)|

### 4. Set the date and time format of sensor data.

-   Select [Unix] or [Others].
-   For [Unix], select either 13 digits (when the timestamp includes milliseconds) or 10 digits (when milliseconds not included), then Press [Next].
-   For [Others], select each part of the timestamp according to the format of the date and time data sent from the IoT device, then press [Done].
-   If the time zone is not specified within the date and time, set (b) to "(empty)" and select the time zone of the sensor data date and time in [Local time zone].
-   If the format looks correct, press [Next].

![format setting](../../images/vis-manual/en/select_format.png)
![select format](../../images/vis-manual/en/select_time_format.png)
![confirm format](../../images/vis-manual/en/confirm_time_format.png)

### 5. Check the settings and save.

-   After checking the settings, press [Save].

![confirm graph setting](../../images/vis-manual/en/graph_setting_confirm.png)

### 6. Select the sensor you want to display.

-   After returning to the graph screen, select the sensor data which you want to see as a graph from the selector shown in the below image.

![select sensor](../../images/vis-manual/en/select_partitionkey_value.png)

#### When there is no sensor to display

-   Select [Add] in the selector.
-   Enter a value of the partition key you want to be graphed in the form and press [Add].
-   Press [Cancel] to return to the selector and check the box of the key you just added.

![add partition key](../../images/vis-manual/en/add_partition_key.png)

### 7. Select the display target key you want to display and draw a graph.

-   press the [Reload target keys] icon.
-   The graph is drawn by selecting the item of the graph you want to display from the options displayed next to the display target key.

Note: graph may not be created if the latest data is older than the time range set in the graph setting (default is 5 minutes).

![update target keys](../../images/vis-manual/en/select_update_display_keys.png)
![draw graph](../../images/vis-manual/en/display_graph.png)

## [Option 1] Change graph settings<a name="option1"></a>

Here we will show you how to set the graph title and update frequency.

### 1. Go to the graph setting.

-   Press the [Settings] (gear) icon on the graph panel of which you want to change settings.

![graph setting icon](../../images/vis-manual/en/select_graph_setting.png)

-   Select [Manual Setting] on the setting panel.

![manual setting](../../images/vis-manual/en/select_manual_setting.png)

-   Open [Graph Display] tab.

![graph display setting](../../images/vis-manual/en/open_draw_graph_setting.png)

### 2. Change settings.

![graph display setting overall](../../images/vis-manual/en/draw_graph_setting_over_all.png)

1. You can change the title displayed at the top of the graph panel.

2. You can change the interval to update the graph data.

    The minimum value is 1 second. Decreasing the value may narrow the graph drawing width.

3. You can change the time range of data on the graph.

    If you choose "5 min." for instance, the data within 5 minutes of the current time is targeted for the graph drawing.

4. You can change the date and time format to be displayed on the horizontal axis of the graph.

5. You can set the range of the vertical axis.

    If "off" is selected, the scale is automatically chosen.

6. You can change how to connect the graph data.

7. Selectable partition key can be deleted/added.

8. Selectable display target keys can be deleted/added.

## [Option 2] Set thresholds<a name="option2"></a>

### 1. Go to the threshold setting.

-   Press the [Setting] (gear) icon on the graph panel of which you want to set thresholds.

![Graph setting selection](../../images/vis-manual/en/select_graph_setting.png)

-   Open the [Thresholds] tab from the setting screen

![Threshold setting selection](../../images/vis-manual/en/select_alert_setting.png)

### 2. Set thresholds for a target key.

-   Select the target key for which you want to set thresholds from the display target keys.
-   Switch to enable / disable the upper and lower thresholds, and enter threshold values.
-   If you want to send an alert email, enter email addresses in [Alert Email Address(es)]
    If you enter more than one email address, separate them with commas. Up to 5 emails can be registered.
-   After setting is done, press [Save].

![Threshold setting](../../images/vis-manual/en/setting_alert.png)

### You can check the error history.

-   The notification badge appears on the [Alarm History] button as the data with threshold setting exceeds or falls below the set value.

![Anomaly history batch](../../images/vis-manual/en/alert_batch.png)

-   Press [Alarm history] to check a list of alerting (up to 100 records).

![Alarm history](../../images/vis-manual/en/alert_history.png)

### You can receive email notifications by setting emails.

-   If you specify the alert mail destination in the threshold setting, you can receive an email* of the alert notification when the value exceeds / below the threshold.

    *In Japanese, sorry! English version coming soon.

    <span style="color: red;">Note: you can receive emails only while you are on the IoT.kyoto VIS page</span>

![Alert mail example](../../images/vis-manual/en/alert_mail.png)

## [Option 3] Search past data<a name="option3"></a>

### 1. Go to the past data search.

-   Press the [Search] (magnifying glass) icon on the graph panel of which you want to search past data.

![Search screen selection](../../images/vis-manual/en/select_search.png)

### 2. Fill in the search conditions.

-   Select the device and the target key you want to see the past data.
-   Specify the date and time of data.
    -   You can specify duration with "before" or "after" key, or by choosing a start and end of the period.
-   If you want to set the vertical axis range of the search result graph, set the range setting to "on" and enter numerical values.

![Enter search items](../../images/vis-manual/en/input_search_conditions.png)

### 3. Get the graph.

-   You can get the data and display the graph by pressing [Search].

![search results](../../images/vis-manual/en/search_result.png)

<span style="color: red;">Note: data acquisition may fail depending on the read capacity of the referenced DynamoDB table.</span>

<span style="color: red;"> In this case, please narrow the search target period or adjust the read capacity of the DynamoDB table.</span>

## [Option 4] Download data in CSV file<a name="option4"></a>

### 1. Go to the CSV download.

-   Press the [Download data as CSV] icon on the graph panel of which you want to download data as a CSV file.

![csv download selection](../../images/vis-manual/en/select_csv_download.png)

### 2. Specify the IoT device and the target period.

-   Select the device from the selector
-   Set the download target period
    -   You can specify duration with "before" or "after" key, or by choosing a start and end of the period.

![csv download condition entry](../../images/vis-manual/en/input_csv_download_conditions.png)

### 3. get a CSV file.

-   Press [Download] to get a CSV file of the data that meets the conditions you speficied.

![csv download result](../../images/vis-manual/en/csv_download_result.png)

<span style="color: red;">Note: data download may fail if number of record exceeds 100,000 or the data size is over 5MB.</span>

<span style="color: red;">In this case, please adjust the target period.</span>

<span style="color: red;">Note: depending on the read capacity of the target DynamoDB table, the data acquisition may fail even if the target data size does not exceed the limitations.</span>

<span style="color: red;">In that case, please adjust the target period or read capacity of DynamoDB table.</span>

## [Option 5] Rearrange panels<a name="option5"></a>

This feature is available only when you have multiple graph panels.

### 1. Switch to panels sort mode.

-   Press the [Rearrange Panels] (crossing arrows) icon at the top right of the page.

![Sort mode switching selection](../../images/vis-manual/en/select_move_graph.png)

### 2. Sort graph panels.

-   You can drag and drop a panel; drag inside a marked area which says [Drag here to rearrange panels].

![Graph move](../../images/vis-manual/en/drag_graph.png)

### 3. Exit sort mode.

-   End sorting mode by pressing either [End Rearrange Mode] on one of the graph panels or the [Rearrange panels] icon pressed in 1.

![End sort](../../images/vis-manual/en/quit_move_graph.png)

## [Option 6] Delete graph<a name="option6"></a>

### 1. Press the [Delete This Graph] button.

-   Press the [Delete this graph] (trash can) icon on the graph panel of which you want to delete.

![Graph delete selection](../../images/vis-manual/en/select_remove_graph.png)

### 2. Delete the graph.

-   The alert dialog pops up as you pressed the icon; if there is no problem in deleting, press [OK].

![Confirm graph deletion](../../images/vis-manual/en/confirm_remove_graph.png)

<span style="color: red;">Note: after confirmation, the settings of the graph may also be deleted.</span>
