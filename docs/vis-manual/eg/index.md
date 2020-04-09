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
- For these data measured by IoT devices, create a DynamoDB table in "[1] DynamoDB construction procedure" and write the data to the table. In addition, you can create a graph in real time by setting in [4] About the graph screen.