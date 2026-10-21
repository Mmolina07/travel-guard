# ML Kit (OCR de recibos): solo se usa el modelo latino. El plugin
# referencia los de otros alfabetos, que no se incluyen; sin esto R8
# falla en el build release con "Missing classes".
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit arma sus componentes internos por reflexión: si R8 recorta o
# renombra estas clases, el OCR falla en release con un
# NullPointerException en mlkit_vision_common (en debug sí funcionaba).
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_** { *; }
-keep class com.google.android.gms.common.internal.** { *; }
-keep class com.google.firebase.components.** { *; }
