#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#              配置 .config：选设备、关冲突 offload、启用 athena-led、默认设置
#
# Copyright (c) 2019-2024 P3TERX
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

echo "=========================================="
echo "  diy-part2: 配置 .config"
echo "=========================================="

# ===================== 备份当前 .config =====================
cp .config .config.backup

# ===================== 用 qosmio 的 NSS seed 打底 =====================
# qosmio 提供了针对 NSS 优化过的 seed 配置
echo ">>> 使用 qosmio NSS seed 作为基础..."
if [ -f nss-setup/config-nss.seed ]; then
  cp nss-setup/config-nss.seed .config.nss
  echo "    ✓ 找到 nss-setup/config-nss.seed"
else
  echo "    ⚠ 未找到 nss-setup/config-nss.seed，使用现有 .config"
fi

# ===================== 确保 RE-CS-02 设备被选中 =====================
echo ">>> 设置目标设备为 JDCloud RE-CS-02..."
# 先取消其他可能冲突的设备选项
sed -i 's/^CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_.*=y/# CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_xxx is not set/g' .config
# 选中 RE-CS-02
sed -i 's/^# CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_jdcloud_re-cs-02 is not set/CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_jdcloud_re-cs-02=y/' .config
# 确保平台选项打开
sed -i 's/^# CONFIG_TARGET_qualcommax is not set/CONFIG_TARGET_qualcommax=y/' .config
sed -i 's/^# CONFIG_TARGET_qualcommax_ipq60xx is not set/CONFIG_TARGET_qualcommax_ipq60xx=y/' .config
echo "    ✓ JDCloud RE-CS-02 已选中"

# ===================== 启用 athena-led =====================
echo ">>> 启用 athena-led..."
echo "" >> .config
echo "# === Athena LED (雅典娜点阵屏) ===" >> .config
echo "CONFIG_PACKAGE_athena-led=y" >> .config
echo "CONFIG_PACKAGE_luci-app-athena-led=y" >> .config
echo "    ✓ athena-led + luci-app-athena-led = y"

# ===================== 启用 iStore =====================
echo ">>> 启用 iStore..."
echo "" >> .config
echo "# === iStore 应用商店 ===" >> .config
echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
echo "CONFIG_PACKAGE_xz-utils=y" >> .config
echo "CONFIG_PACKAGE_curl=y" >> .config
echo "    ✓ luci-app-store"

# ===================== 启用 OpenAppFilter =====================
echo ">>> 启用 OpenAppFilter..."
echo "" >> .config
echo "# === OpenAppFilter 应用过滤 ===" >> .config
echo "CONFIG_PACKAGE_luci-app-openappfilter=y" >> .config
echo "CONFIG_PACKAGE_openappfilter=y" >> .config
echo "    ✓ luci-app-openappfilter + openappfilter"

# ===================== 启用 Gecoos AC =====================
echo ">>> 启用 Gecoos AC..."
echo "" >> .config
echo "# === Gecoos AC 控制器 ===" >> .config
echo "CONFIG_PACKAGE_luci-app-gecoosac=y" >> .config
echo "    ✓ luci-app-gecoosac"

# ===================== 启用 Harbor File =====================
echo ">>> 启用 Harbor File..."
echo "" >> .config
echo "# === Harbor File 文件管理器 ===" >> .config
echo "CONFIG_PACKAGE_luci-app-harbor-file=y" >> .config
echo "    ✓ luci-app-harbor-file"

# ===================== 关闭与 NSS 冲突的 offload =====================
echo ">>> 关闭与 NSS 冲突的软件 offload..."
sed -i 's/^CONFIG_PACKAGE_luci-app-flowoffload=y/# CONFIG_PACKAGE_luci-app-flowoffload is not set/' .config
sed -i 's/^CONFIG_PACKAGE_luci-app-sfe=y/# CONFIG_PACKAGE_luci-app-sfe is not set/' .config
sed -i 's/^CONFIG_PACKAGE_luci-app-sfe-flowoffload=y/# CONFIG_PACKAGE_luci-app-sfe-flowoffload is not set/' .config
echo "    ✓ flowoffload / sfe 已禁用（NSS 专属）"

# ===================== Rust 支持 =====================
echo ">>> 确保 Rust 支持开启..."
echo "" >> .config
echo "# === Rust (athena-led 需要) ===" >> .config
echo "CONFIG_RUST=y" >> .config
echo "    ✓ CONFIG_RUST=y"

# ===================== make defconfig 展开完整配置 =====================
echo ">>> make defconfig（展开完整配置）..."
make defconfig V=s

# ===================== 验证关键包是否入选 =====================
echo ""
echo "=========================================="
echo "  验证：关键包是否进入最终配置"
echo "=========================================="
for pkg in athena-led luci-app-athena-led luci-app-store luci-app-openappfilter luci-app-gecoosac luci-app-harbor-file; do
  if grep -q "^CONFIG_PACKAGE_${pkg}=y" .config; then
    echo "  ✅ CONFIG_PACKAGE_${pkg}=y"
  else
    echo "  ❌ CONFIG_PACKAGE_${pkg} 未找到！"
  fi
done

# 验证设备
if grep -q "^CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_jdcloud_re-cs-02=y" .config; then
  echo "  ✅ JDCloud RE-CS-02 设备已选中"
else
  echo "  ❌ JDCloud RE-CS-02 设备未选中！"
fi

echo "=========================================="
echo "  diy-part2 完成"
echo "=========================================="
