<img width="768" src="https://github.com/openwrt/openwrt/blob/main/include/logo.png"/>

## 特别提示 [![](https://img.shields.io/badge/-个人免责声明-FFFFFF.svg)](#特别提示-)

- **本人不对任何人因使用本固件所遭受的任何理论或实际的损失承担责任！**
- **本固件禁止用于任何商业用途，请务必严格遵守国家互联网使用相关法律规定！**

## 项目说明 [![](https://img.shields.io/badge/-项目基本介绍-FFFFFF.svg)](#项目说明-)

基于 [breeze303/openwrt-ci](https://github.com/breeze303/openwrt-ci) fork，面向 **兆能 M2（ZN-M2）** 单设备的云编译仓库。

- **设备**：兆能 M2（ZN-M2，Qualcomm IPQ6000 / IPQ6018 平台）
- **固件默认管理地址**：`10.10.10.1`（LAN 10.10.10.0/24） 默认用户：`root` 默认密码：`password`
- **源码**：[LiBwrt/LibWrt](https://github.com/LiBwrt/LibWrt)（`main-nss` 分支，内核 6.12，NSS 硬件加速）
- **特性**：
  - 纯有线使用（无 WiFi 驱动，适合弱电箱场景）
  - 内置 passwall + homeproxy（科学插件）
  - NSS 硬件加速（NAT/路由硬件卸载）
  - 512MB 内存档位（改装机）
  - USB 全功能（USB3 / DWC3 / 网卡驱动 / 4G 模块 / 存储）

## 固件下载 [![](https://img.shields.io/badge/-编译状态及下载链接-FFFFFF.svg)](#固件下载-)

| 设备 | 编译状态 | 固件下载 |
| :-------------: | :-------------: | :-------------: |
| [![](https://img.shields.io/badge/ZN--M2-NOWIFI-PASSWALL-32C955.svg?logo=openwrt)](https://github.com/katriyda/openwrt-ci/actions/workflows/IPQ60XX-6.12-NOWIFI.yml) | [![](https://github.com/katriyda/openwrt-ci/actions/workflows/IPQ60XX-6.12-NOWIFI.yml/badge.svg)](https://github.com/katriyda/openwrt-ci/actions/workflows/IPQ60XX-6.12-NOWIFI.yml) | [![](https://img.shields.io/badge/下载-链接-blueviolet.svg?logo=hack-the-box)](https://github.com/katriyda/openwrt-ci/releases/IPQ60XX-6.12-NOWIFI) |

## 定制固件 [![](https://img.shields.io/badge/-项目基本编译教程-FFFFFF.svg)](#定制固件-)

1. 修改 `configs/ipq60xx-6.12-nowifi.config` 添加或删除插件（只编译 zn_m2 一台设备）
2. 如需修改默认 IP、添加或删除插件包以及一些其他设置请在 `libwrt.sh` 文件内修改
3. 点击 `Actions` → `IPQ60XX-6.12-NOWIFI` → `Run workflow` 即可开始编译
4. 编译大概需要 3-5 小时，编译完成后在仓库 [Releases](https://github.com/katriyda/openwrt-ci/releases) 对应 Tag 标签内下载固件

<a href="#readme">
<img src="https://img.shields.io/badge/-返回顶部-FFFFFF.svg" title="返回顶部" align="right"/>
</a>
