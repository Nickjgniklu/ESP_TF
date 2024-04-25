# ESP_TF
1. run create.sf to update source this library just restructures the espressif tensorflow repo (https://github.com/espressif/tflite-micro-esp-examples) to be arduino compatible

## Examples
https://github.com/Nickjgniklu/esp_mnist
## Notes
### ESP_NN support

Building with #define ESP_NN will enable espressif ansi layer implementations

Example for PlatformIO:
```
build_flags = 
	-std=gnu++17
	-DCORE_DEBUG_LEVEL=5
	-DESP_NN
```
### ESP32_S3
Building with ESP_NN, CONFIG_NN_OPTIMIZED,and ARCH_ESP32_S3 will enable ESP_32S3 specific optimizations. 

Example for PlatformIO:
```
build_flags = 
	-std=gnu++17
	-DCORE_DEBUG_LEVEL=5
	-DESP_NN
	-DCONFIG_NN_OPTIMIZED
	-DARCH_ESP32_S3
```
## TODO
# Revalidate arduino versions
# mark versions 1.0.2 1.0.3 as bad releases
