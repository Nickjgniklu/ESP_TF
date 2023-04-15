echo "preclean"
rm -r ./src/
rm -fr tflite-micro-esp-examples
rm -fr esp-nn

echo "cloning espressif tensorflow examples"
git clone --recurse-submodules https://github.com/espressif/tflite-micro-esp-examples.git

echo "Making tensorflow files structured for PIO/Arduino"
mkdir ./src/
cp -r ./tflite-micro-esp-examples/components/tflite-lib/tensorflow/ ./src/tensorflow/
cp -r ./tflite-micro-esp-examples/components/tflite-lib/third_party/flatbuffers/include/flatbuffers/ ./src/
sed -i 's/utility.h/utility/g' ./src/flatbuffers/base.h
cp -r ./tflite-micro-esp-examples/components/tflite-lib/third_party/gemmlowp/fixedpoint/ ./src/  
cp -r ./tflite-micro-esp-examples/components/tflite-lib/third_party/gemmlowp/internal/ ./src/
cp -r ./tflite-micro-esp-examples/components/tflite-lib/third_party/kissfft/ ./src/  
cp -r ./tflite-micro-esp-examples/components/tflite-lib/third_party/ruy/ruy/ ./src/
cp -a ./src/kissfft/tools/. ./src/kissfft/
rm -r ./src/kissfft/tools/
find ./src/tensorflow/ -type f -exec sed -i -e 's/#include "kiss_fft.c"/#include "kissfft\/kiss_fft.c"/g' {} \;
find ./src/tensorflow/ -type f -exec sed -i -e 's/#include "kiss_fft.h"/#include "kissfft\/kiss_fft.h"/g' {} \;
find ./src/tensorflow/ -type f -exec sed -i -e 's/#include "tools\/kiss_fftr.c"/#include "kissfft\/kiss_fftr.c"/g' {} \;
find ./src/tensorflow/ -type f -exec sed -i -e 's/#include "tools\/kiss_fftr.h"/#include "kissfft\/kiss_fftr.h"/g' {} \;

echo "Use esp-nn kernals"
#replace standard kernals with esp nn
cp -a ./src/tensorflow/lite/micro/kernels/esp_nn/. ./src/tensorflow/lite/micro/kernels/
#add ESP_NN define
sed -i 's/#define TENSORFLOW_LITE_C_COMMON_H_/#define TENSORFLOW_LITE_C_COMMON_H_\n#define ESP_NN 1/g' ./src/tensorflow/lite/c/common.h

echo "Making esp-nn files structured for PIO/Arduino"
mkdir ./src/esp-nn

cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/activation_functions/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/basic_math/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/common/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/convolution/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/fully_connected/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/pooling/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/src/softmax/. ./src/esp-nn/
cp -a  ./tflite-micro-esp-examples/components/esp-nn/include/. ./src/esp-nn/
# make esp_nn includes work
find ./src/esp-nn/ -type f -exec sed -i -e 's/#include <common_functions.h>/#include "common_functions.h"/g' {} \;
find ./src/esp-nn/ -type f -exec sed -i -e 's/#include <esp_nn_defs.h>/#include "esp_nn_defs.h"/g' {} \;
#find ./src/esp-nn/ -type f -exec sed -i -e 's/#include <esp_nn.h>/#include "esp_nn.h"/g' {} \;
find ./src/tensorflow/ -type f -exec sed -i -e 's/#include <esp_nn.h>/#include "esp-nn\/esp_nn.h"/g' {} \;

echo "Clean up"
#clean up 
rm -fr tflite-micro-esp-examples
rm -fr esp-nn

echo "Libary update done."