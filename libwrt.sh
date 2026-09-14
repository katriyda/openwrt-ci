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
# ---- momo feed：nikkinikki OpenWrt-momo（基于 sing-box 的透明代理）----
# 源追加到 feeds.conf.default 后单独 update+install（workflow 的 feeds update -a 早于本脚本执行）
echo "src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main" >> feeds.conf.default
./scripts/feeds update momo
./scripts/feeds install -a -p momo

# ---- mimic feed：hack3ric/mimic（eBPF 把 UDP 伪装成 TCP；hysteria2 ≥2.12 内置集成）----
# 只登记 feed（仓库极小），是否编译由 .config 的 CONFIG_PACKAGE_mimic / kmod-mimic 决定
echo "src-git mimic https://github.com/hack3ric/mimic;openwrt" >> feeds.conf.default
./scripts/feeds update mimic
./scripts/feeds install -a -p mimic

# ---- hysteria 钉住到 v2.12.2（mimic 集成自 2.12.0 起；immortalwrt/packages 停滞在 2.7.0）----
# 仅当选中 CONFIG_PACKAGE_hysteria 时才参与编译；feed 追上后下方 sed 匹配不到旧串，钉住自动失效
# 版本/HASH 来源：HyNetworks/hysteria tag app/v2.12.2（apernet→HyNetworks 同仓库，tarball 逐字节一致）
sed -i 's#PKG_VERSION:=2.7.0#PKG_VERSION:=2.12.2#' feeds/packages/net/hysteria/Makefile
sed -i 's#PKG_HASH:=3cac6adeccdac7cc8b353948e3cead1eb8606aa8ce74dac4853d821a22ceeba7#PKG_HASH:=8db04a112e73685a1e5916d5d4d3df3ed897dbabc3e639fda4880b7ca9a7d18e#' feeds/packages/net/hysteria/Makefile
sed -i 's#codeload.github.com/apernet/hysteria#codeload.github.com/HyNetworks/hysteria#' feeds/packages/net/hysteria/Makefile