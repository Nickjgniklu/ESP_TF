echo "preclean"
rm -r ./src/
rm -fr esp-tflite-micro
rm -fr esp-nn

echo "cloning espressif tensorflow examples"
git clone --recurse-submodules https://github.com/espressif/esp-tflite-micro.git

echo "Making tensorflow files structured for PIO/Arduino"
mkdir ./src/
cp -r ./esp-tflite-micro/tensorflow/ ./src/tensorflow/
cp -r ./esp-tflite-micro/signal/ ./src/signal/
cp -r ./esp-tflite-micro/third_party/flatbuffers/include/flatbuffers/ ./src/
sed -i 's/utility.h/utility/g' ./src/flatbuffers/base.h
cp -r ./esp-tflite-micro/third_party/gemmlowp/fixedpoint/ ./src/  
cp -r ./esp-tflite-micro/third_party/gemmlowp/internal/ ./src/
cp -r ./esp-tflite-micro/third_party/kissfft/ ./src/  
cp -r ./esp-tflite-micro/third_party/ruy/ruy/ ./src/
cp -a ./src/kissfft/tools/. ./src/kissfft/
rm -r ./src/kissfft/tools/
find ./src/tensorflow/ ./src/signal/ -type f -exec sed -i -e 's/#include "kiss_fft.c"/#include "kissfft\/kiss_fft.c"/g' {} \;
find ./src/tensorflow/ ./src/signal/ -type f -exec sed -i -e 's/#include "kiss_fft.h"/#include "kissfft\/kiss_fft.h"/g' {} \;
find ./src/tensorflow/ ./src/signal/ -type f -exec sed -i -e 's/#include "tools\/kiss_fftr.c"/#include "kissfft\/kiss_fftr.c"/g' {} \;
find ./src/tensorflow/ ./src/signal/ -type f -exec sed -i -e 's/#include "tools\/kiss_fftr.h"/#include "kissfft\/kiss_fftr.h"/g' {} \;

echo "Use esp-nn kernals"
#replace standard kernals with esp nn
cp -a ./src/tensorflow/lite/micro/kernels/esp_nn/. ./src/tensorflow/lite/micro/kernels/

echo "Making esp-nn files structured for PIO/Arduino"
git clone --recurse-submodules https://github.com/espressif/esp-nn.git
mkdir ./src/esp-nn

cp -a  ./esp-nn/src/activation_functions/. ./src/esp-nn/
cp -a  ./esp-nn/src/basic_math/. ./src/esp-nn/
cp -a  ./esp-nn/src/common/. ./src/esp-nn/
cp -a  ./esp-nn/src/convolution/. ./src/esp-nn/
cp -a  ./esp-nn/src/fully_connected/. ./src/esp-nn/
cp -a  ./esp-nn/src/pooling/. ./src/esp-nn/
cp -a  ./esp-nn/src/softmax/. ./src/esp-nn/
cp -a  ./esp-nn/include/. ./src/esp-nn/
# make esp_nn includes work
find ./src/esp-nn/ -type f -exec sed -i -e 's/#include <common_functions.h>/#include "common_functions.h"/g' {} \;
find ./src/esp-nn/ -type f -exec sed -i -e 's/#include <esp_nn_defs.h>/#include "esp_nn_defs.h"/g' {} \;
#find ./src/esp-nn/ -type f -exec sed -i -e 's/#include <esp_nn.h>/#include "esp_nn.h"/g' {} \;
find ./src/tensorflow/ -type f -exec sed -i -e 's/#include <esp_nn.h>/#include "esp-nn\/esp_nn.h"/g' {} \;
find ./src/esp-nn/ -type f -iname "*esp32s3.S" -exec sed -i '1s/^/#ifdef ARCH_ESP32_S3\n/;$a\\n#endif' {} \;

# ESP32 requires TF_LITE_REMOVE_VIRTUAL_DELETE descrutors to be made public
sed -i '/TF_LITE_REMOVE_VIRTUAL_DELETE/d' ./src/tensorflow/lite/micro/memory_planner/linear_memory_planner.h
sed -i '/TF_LITE_REMOVE_VIRTUAL_DELETE/d' ./src/tensorflow/lite/micro/tflite_bridge/micro_error_reporter.h
sed -i '/TF_LITE_REMOVE_VIRTUAL_DELETE/d' ./src/tensorflow/lite/micro/memory_planner/greedy_memory_planner.h

sed -i 's/private:/TF_LITE_REMOVE_VIRTUAL_DELETE\n&/' ./src/tensorflow/lite/micro/memory_planner/linear_memory_planner.h
sed -i 's/private:/TF_LITE_REMOVE_VIRTUAL_DELETE\n&/' ./src/tensorflow/lite/micro/tflite_bridge/micro_error_reporter.h
sed -i 's/private:/TF_LITE_REMOVE_VIRTUAL_DELETE\n&/' ./src/tensorflow/lite/micro/memory_planner/greedy_memory_planner.h
# change all occurance of #ifndef TF_LITE_STATIC_MEMORY to #ifdef TF_LITE_NOT_STATIC_MEMORY
find ./src/ -type f -exec sed -i -e 's/#ifndef TF_LITE_STATIC_MEMORY/#ifdef TF_LITE_NOT_STATIC_MEMORY/g' {} \;
find ./src/ -type f -exec sed -i -e 's/#if !defined(TF_LITE_STATIC_MEMORY)/#if defined(TF_LITE_NOT_STATIC_MEMORY)/g' {} \;
find ./src/ -type f -exec sed -i -e 's/#ifdef TF_LITE_STATIC_MEMORY/#define TF_LITE_STATIC_MEMORY\n#ifdef TF_LITE_STATIC_MEMORY/g' {} \;




# Create header file for library
echo "// do not delete" > ./src/ESP_TF.h
echo "// placeholder for arduino library rules" >> ./src/ESP_TF.h

#clean up 
echo "Clean up"
rm -fr esp-tflite-micro
rm -fr esp-nn

echo "Libary update done."
