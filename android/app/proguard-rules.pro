# Keep all TensorFlow Lite classes
-keep class org.tensorflow.** { *; }

# Keep specific TensorFlow Lite GPU delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }

# Keep TensorFlow Lite GPU delegate factory and options classes
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options$GpuBackend { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }

# Keep GPU delegate options and its internal classes
-keep class org.tensorflow.lite.gpu.GpuDelegate$Options { *; }

# Keep annotations
-keepattributes *Annotation*