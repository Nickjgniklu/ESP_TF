# ESP_TF
1. run create.sf to update source this library just restructures the espressif tensorflow repo (https://github.com/espressif/tflite-micro-esp-examples) to be arduino compatible

## examples
https://github.com/Nickjgniklu/esp_mnist
## notes
ESP_NN support
Building with #define ESP_NN will enable espressif ansci layer implementations
### example for PIO
	-DCONFIG_IDF_TARGET_ESP32S3 -DCONFIG_NN_OPTIMIZED -DCONFIG_IDF_TARGET_ARCH_XTENSA are currently not working but will be required for esp32s3 optimizations
```
build_flags = 
	-std=gnu++17
	-DCORE_DEBUG_LEVEL=5
	-DESP_NN
	-DCONFIG_IDF_TARGET_ESP32S3
	-DCONFIG_NN_OPTIMIZED
	-DCONFIG_IDF_TARGET_ARCH_XTENSA
```
## TODO
# Revalidate arduino versions
# mark versions 1.0.2 1.0.3 as bad releases
