package com.eastlakestudio.luduan.ui.theme

import androidx.compose.ui.graphics.Color

// 自适应亮/暗色（对应 iOS 的 ColorExtensions）
val CinnabarRed = Color(0xC73921) // 朱砂红
val CinnabarRedDark = Color(0xE05A30)
val BambooGreen = Color(0x78923F) // 竹青绿
val BambooGreenDark = Color(0x82B04A)
val PaperWhite = Color(0xF8F6EC) // 宣纸白
val PaperWhiteDark = Color(0x1A1714) // 墨卷底
val XuanBlack = Color(0x1C1C22) // 玄青黑
val XuanBlackDark = Color(0xEBE8D2) // 象牙白
val CardSurface = Color(0xFFFFFF)
val CardSurfaceDark = Color(0x2B2622)
val CloudGold = Color(0xD4A04A) // 祥云金
val CloudGoldDark = Color(0xEBA858)
val BorderAncient = Color(0xD1C7B3)
val BorderAncientDark = Color(0x61562A)

// 运行时自适应取色
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.Composable

@Composable
fun adaptiveCinnabar() = if (isSystemInDarkTheme()) CinnabarRedDark else CinnabarRed
@Composable
fun adaptiveBamboo() = if (isSystemInDarkTheme()) BambooGreenDark else BambooGreen
@Composable
fun adaptivePaper() = if (isSystemInDarkTheme()) PaperWhiteDark else PaperWhite
@Composable
fun adaptiveXuan() = if (isSystemInDarkTheme()) XuanBlackDark else XuanBlack
@Composable
fun adaptiveCard() = if (isSystemInDarkTheme()) CardSurfaceDark else CardSurface
@Composable
fun adaptiveGold() = if (isSystemInDarkTheme()) CloudGoldDark else CloudGold
@Composable
fun adaptiveBorder() = if (isSystemInDarkTheme()) BorderAncientDark else BorderAncient
