# Add project specific ProGuard rules here.
-keep class com.eastlakestudio.luduan.data.models.** { *; }
-keepclassmembers,allowobfuscation class * {
  @kotlinx.serialization.SerialName <fields>;
}
