#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#              克隆所有第三方插件源码到 package/
#
# Copyright (c) 2019-2024 P3TERX
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

echo "=========================================="
echo "  diy-part1: 克隆第三方插件"
echo "=========================================="

# ===================== Athena LED（雅典娜点阵屏驱动）=====================
# Rust 写的守护进程 + LuCI 前端
echo ">>> 克隆 athena-led (unraveloop)..."
rm -rf package/athena-led
git clone --depth 1 https://github.com/unraveloop/JDC-AX6600-Athena-LED-Controller.git /tmp/athena_src
mkdir -p package/athena
cp -r /tmp/athena_src/athena-led package/athena/athena-led
cp -r /tmp/athena_src/luci-app-athena-led package/athena/luci-app-athena-led
rm -rf /tmp/athena_src
echo "    ✓ athena-led + luci-app-athena-led"

# ===================== iStore 应用商店 =====================
echo ">>> 克隆 iStore..."
rm -rf package/luci-app-store
git clone --depth 1 https://github.com/linkease/istore.git package/luci-app-store
echo "    ✓ luci-app-store"

# ===================== OpenAppFilter 应用过滤（锁 v6.1.8）=====================
echo ">>> 克隆 OpenAppFilter @ v6.1.8..."
rm -rf package/OpenAppFilter
git clone --depth 1 --branch v6.1.8 https://github.com/destan19/OpenAppFilter.git package/OpenAppFilter
echo "    ✓ OpenAppFilter"

# ===================== Gecoos AC 控制器 =====================
echo ">>> 克隆 Gecoos AC..."
rm -rf package/luci-app-gecoosac
git clone --depth 1 https://github.com/laipeng668/luci-app-gecoosac.git package/luci-app-gecoosac
echo "    ✓ luci-app-gecoosac"

# ===================== Harbor File 文件管理器 =====================
echo ">>> 克隆 Harbor File..."
rm -rf package/luci-app-harbor-file
git clone --depth 1 https://github.com/destan19/luci-app-harbor-file.git package/luci-app-harbor-file
echo "    ✓ luci-app-harbor-file"

# ===================== 更新并安装插件源 =====================
echo ">>> ./scripts/feeds update -a"
./scripts/feeds update -a

echo ">>> ./scripts/feeds install -a"
./scripts/feeds install -a

echo "=========================================="
echo "  diy-part1 完成"
echo "=========================================="
