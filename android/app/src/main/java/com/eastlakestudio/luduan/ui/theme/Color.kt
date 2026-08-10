package com.eastlakestudio.luduan.ui.theme
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val CinnabarRed = Color(0xFFC73C1E); val CinnabarRedDark = Color(0xFFE05A30)
val BambooGreen = Color(0xFF78923F); val BambooGreenDark = Color(0xFF82B04A)
val PaperWhite = Color(0xFFF8F6EC); val PaperWhiteDark = Color(0xFF1A1714)
val XuanBlack = Color(0xFF1C1C22); val XuanBlackDark = Color(0xFFEBE8D2)
val CardSurface = Color(0xFFFFFFFF); val CardSurfaceDark = Color(0xFF2B2622)
val CloudGold = Color(0xFFD4A04A); val CloudGoldDark = Color(0xFFEBA858)
val BorderAncient = Color(0xFFD1C7B3); val BorderAncientDark = Color(0xFF61562A)

@Composable fun adaptiveCinnabar() = if (isSystemInDarkTheme()) CinnabarRedDark else CinnabarRed
@Composable fun adaptiveBamboo() = if (isSystemInDarkTheme()) BambooGreenDark else BambooGreen
@Composable fun adaptivePaper() = if (isSystemInDarkTheme()) PaperWhiteDark else PaperWhite
@Composable fun adaptiveXuan() = if (isSystemInDarkTheme()) XuanBlackDark else XuanBlack
@Composable fun adaptiveCard() = if (isSystemInDarkTheme()) CardSurfaceDark else CardSurface
@Composable fun adaptiveGold() = if (isSystemInDarkTheme()) CloudGoldDark else CloudGold
@Composable fun adaptiveBorder() = if (isSystemInDarkTheme()) BorderAncientDark else BorderAncient
