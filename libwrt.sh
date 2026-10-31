# 备份 workflow 传入的原始配置：./scripts/feeds install 会触发 OpenWrt 的配置流程，
# 把还没纳入包数据库的自定义 feed 包（momo/mimic）从 .config 里删掉（静默，无 warning）。
# 备份必须放在任何 feeds 操作之前，否则后面 make defconfig 拿到的已经是不含这些包的配置。
echo "DIAG pre: .config momo=$(grep -c '^CONFIG_PACKAGE_momo=y' .config || true) mimic=$(grep -c '^CONFIG_PACKAGE_mimic=y' .config || true)"
cp .config .config.seed
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

# ---- 自定义 feed：mimic 先装、momo 最后装 ----
# 源追加到 feeds.conf.default 后单独 update+install（workflow 的 feeds update -a 早于本脚本执行）

# mimic feed：hack3ric/mimic（eBPF 把 UDP 伪装成 TCP；hysteria2 ≥2.12 内置集成）
# 是否编译由 .config 的 CONFIG_PACKAGE_mimic / kmod-mimic 决定
echo "src-git mimic https://github.com/hack3ric/mimic;openwrt" >> feeds.conf.default
./scripts/feeds update mimic
./scripts/feeds install -a -p mimic

# momo feed：nikkinikki OpenWrt-momo（基于 sing-box 的透明代理）
echo "src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main" >> feeds.conf.default
./scripts/feeds update momo
./scripts/feeds install -a -p momo

echo "DIAG after-feeds: .config momo=$(grep -c '^CONFIG_PACKAGE_momo=y' .config || true) mimic=$(grep -c '^CONFIG_PACKAGE_mimic=y' .config || true); seed momo=$(grep -c '^CONFIG_PACKAGE_momo=y' .config.seed || true)"

# ---- 恢复原始配置后 defconfig ----
# 上面 feeds 操作已把 .config 里的自定义包删掉；恢复备份再跑 defconfig，
# 此时 feed 已注册、包已链接，kconfig 能解析到 PACKAGE_momo/PACKAGE_mimic。
cp .config.seed .config
make defconfig >/tmp/dc.log 2>&1 || { echo "FATAL: make defconfig failed" >&2; tail -20 /tmp/dc.log >&2; exit 1; }
echo "DIAG after-defconfig: momo=$(grep -c '^CONFIG_PACKAGE_momo=y' .config || true) mimic=$(grep -c '^CONFIG_PACKAGE_mimic=y' .config || true) fw4=$(grep -c '^CONFIG_PACKAGE_firewall4=y' .config || true)"
rm -f .config.seed

# ---- 断言：自定义 feed 的包必须真的被 make defconfig 保留 ----
# 不满足就让整轮在几分钟内失败，而不是跑到产物阶段才发现包缺失
for sym in PACKAGE_momo PACKAGE_luci-app-momo PACKAGE_mimic PACKAGE_kmod-mimic; do
    grep -qx "CONFIG_${sym}=y" .config || { echo "FATAL: CONFIG_${sym} not selected after defconfig (feed link lost?)" >&2; exit 1; }
done
echo "custom package check: OK"
