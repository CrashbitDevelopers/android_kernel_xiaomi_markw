#!/bin/bash

export ARCH=arm64

ROOT_DIR=$(pwd)
OUT_DIR=$ROOT_DIR/out
BUILDING_DIR=$OUT_DIR/kernel_obj

JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
DATE=`date +%m-%d-%H:%M`

CROSS_COMPILER=//home/android/system/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-5.4.1/bin/aarch64-linux-android-

ANYKERNEL_DIR=$ROOT_DIR/misc/anykernel2
TEMP_DIR=$OUT_DIR/temp

DEFCONFIG=defconfig

FUNC_PRINT()
{
		echo ""
		echo "=============================================="
		echo $1
		echo "=============================================="
		echo ""
}

FUNC_CLEAN()
{
		FUNC_PRINT "Limpiando compilaciones anteriores"
		rm -rf $OUT_DIR
		mkdir $OUT_DIR
		mkdir -p $BUILDING_DIR
		mkdir -p $TEMP_DIR
}

FUNC_COMPILE_KERNEL()
{
		FUNC_PRINT "Iniciando compilación"
		make -C $ROOT_DIR O=$BUILDING_DIR $DEFCONFIG 
		make -C $ROOT_DIR O=$BUILDING_DIR -j$JOB_NUMBER ARCH=arm64 CROSS_COMPILE=$CROSS_COMPILER
		FUNC_PRINT "Finalizando compilación"
}


FUNC_PACK()
{
		FUNC_PRINT "Iniciando empaquetado"
		cp -r $ANYKERNEL_DIR/* $TEMP_DIR
		cp $BUILDING_DIR/arch/arm64/boot/Image.gz-dtb $TEMP_DIR/zImage-dtb
		cd $TEMP_DIR
		zip -r9 mKernel.zip ./*
		mv mKernel.zip $OUT_DIR/mKernel-$DATE.zip
		cd $ROOT_DIR
		FUNC_PRINT "Finalizando empaquetado"
}

START_TIME=`date +%s`
FUNC_CLEAN
FUNC_COMPILE_KERNEL
FUNC_PACK
END_TIME=`date +%s`

let "ELAPSED_TIME=$END_TIME-$START_TIME"
echo "El tiempo de compilado fue de $ELAPSED_TIME segundos"
