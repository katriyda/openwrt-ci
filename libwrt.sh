rm -rf package/emortal/luci-app-athena-led
git clone --depth=1 https://github.com/NONGFAH/luci-app-athena-led package/luci-app-athena-led
chmod +x package/luci-app-athena-led/root/etc/init.d/athena_led package/luci-app-athena-led/root/usr/sbin/athena-led
# 修改默认管理地址为 10.10.10.1（LAN 10.10.10.0/24）
sed -i 's/192.168.1.1/10.10.10.1/g' package/base-files/files/bin/config_generate
# 设备名称 LibWrt 改为 ZN-M2
sed -i "s/hostname='LibWrt'/hostname='ZN-M2'/g" package/base-files/files/bin/config_generate
# 默认中文语言
sed -i "s/option lang auto/option lang zh_cn/g" feeds/luci/modules/luci-base/root/etc/config/luci
# 默认 argon 主题
sed -i "s#option mediaurlbase /luci-static/bootstrap#option mediaurlbase /luci-static/argon#g" feeds/luci/modules/luci-base/root/etc/config/luci
# ---- sing-box 钉住到 v1.13.19（上游最新稳定）----
# 背景：immortalwrt/packages 自 07-06 停更于 1.12.25；当 feed 追上 1.13.x 后
# 下方 sed 匹配不到旧版本串，钉住自然失效、回归 feed 滚动（不报错）。
# 版本/HASH 来源：xiaorouji/openwrt-passwall-packages（同维护者，同一上游 tarball）。
# 归档：archive/20260818-singbox-1.13.19/
sed -i 's#PKG_VERSION:=1.12.25#PKG_VERSION:=1.13.19#' feeds/packages/net/sing-box/Makefile
sed -i 's#PKG_HASH:=881435f07b5ab8170ccf3cb69e87130759521dc0ed1ae4bfeacbe7772a93a158#PKG_HASH:=abc2f4805b3fd088c18a5694b51fed6f0e1d06632fae98029d6bf7bd79a1b3a2#' feeds/packages/net/sing-box/Makefile