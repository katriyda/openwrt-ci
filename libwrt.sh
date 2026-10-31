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
# 顺序有实际影响：9-14 之后 mimic 成为最后一个 feed 操作，momo 随即从 .config 消失（见 archive 记录）。
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

# ---- 两遍 defconfig：第一遍补齐依赖符号，第二遍保住自定义包 ----
# configs/*.config 是片段式配置（不含 CONFIG_IPV6、CONFIG_PACKAGE_libc 等由 defconfig
# 补默认的符号）。单遍 defconfig 时 kconfig 先解析到 PACKAGE_momo，它的
# `depends on PACKAGE_firewall4` 链条（firewall4 又 depends on IPV6）在第一遍还没定型，
# CONFIG_PACKAGE_momo=y / mimic=y 就被静默丢弃（无任何 warning），断言随即失败。
# 第一遍把 .config 规范化；第二遍前恢复原始配置再跑，依赖已明确，包即被保留。
cp .config .config.seed
make defconfig >/tmp/dc1.log 2>&1 || { echo "FATAL: make defconfig failed (pass 1)" >&2; tail -20 /tmp/dc1.log >&2; exit 1; }
echo "DIAG pass1: momo=$(grep -c '^CONFIG_PACKAGE_momo=y' .config) fw4=$(grep -c '^CONFIG_PACKAGE_firewall4=y' .config) ipv6=$(grep -c '^CONFIG_IPV6=y' .config) libc=$(grep -c '^CONFIG_PACKAGE_libc=y' .config)"
cp .config.seed .config
make defconfig >/tmp/dc2.log 2>&1 || { echo "FATAL: make defconfig failed (pass 2)" >&2; tail -20 /tmp/dc2.log >&2; exit 1; }
echo "DIAG pass2: momo=$(grep -c '^CONFIG_PACKAGE_momo=y' .config) fw4=$(grep -c '^CONFIG_PACKAGE_firewall4=y' .config) ipv6=$(grep -c '^CONFIG_IPV6=y' .config) libc=$(grep -c '^CONFIG_PACKAGE_libc=y' .config)"
echo "DIAG cpi: momo_nodes=$(grep -c 'config PACKAGE_momo$' tmp/.config-package.in) mimic_nodes=$(grep -c 'config PACKAGE_mimic$' tmp/.config-package.in)"
echo "DIAG pkg.in momo block:"; grep -n -A14 'config PACKAGE_momo$' tmp/.config-package.in | head -20
echo "DIAG pkg.in firewall4 block:"; grep -n -A8 'config PACKAGE_firewall4$' tmp/.config-package.in | head -12
echo "DIAG .config after pass2:"; grep -n 'PACKAGE_momo\|PACKAGE_luci-app-momo\|PACKAGE_mimic=\|PACKAGE_kmod-mimic' .config || true
echo "DIAG dc2 log tail:"; tail -10 /tmp/dc2.log
rm -f .config.seed

# ---- 断言：自定义 feed 的包必须真的被 make defconfig 保留 ----
# 不满足就让整轮在几分钟内失败，而不是跑到产物阶段才发现包缺失
for sym in PACKAGE_momo PACKAGE_luci-app-momo PACKAGE_mimic PACKAGE_kmod-mimic; do
    grep -qx "CONFIG_${sym}=y" .config || { echo "FATAL: CONFIG_${sym} not selected after defconfig (feed link lost?)" >&2; exit 1; }
done
echo "custom package check: OK"
