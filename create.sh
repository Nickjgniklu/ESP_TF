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
# Drop the esp_nn/ originals now that they have been copied over the standard
# kernels. Leaving them in place compiles every kernel twice and both copies
# define the same symbols (Register_CONV_2D, mul_total_time, ...). PlatformIO
# archives the library so the duplicate is simply never extracted, but Arduino
# links every library object directly and fails with "multiple definition".
rm -r ./src/tensorflow/lite/micro/kernels/esp_nn/

# The esp-nn kernels mix designated and positional initializers, e.g.
#   data_dims_t d = {.width = w, .height = h, .channels = c, 1};
# GCC allows that as an extension under -std=gnu++17, which is why PlatformIO
# builds fine, but it is an error in C++20 and the arduino-esp32 core compiles
# at -std=gnu++2b. Name the trailing fields so the library builds under both.
find ./src/tensorflow/lite/micro/kernels/ -maxdepth 1 -name "*.cc" -exec sed -i \
  -e 's/\(\.channels = [^,]*\), 1$/\1, .extra = 1/' \
  -e 's/\(\.height = [^,]*\), 0, 0}/\1, .channels = 0, .extra = 0}/' {} \;

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
# Guard all ESP32-S3 specific sources behind ARCH_ESP32_S3.
# The .c files are guarded as well as the .S files: they reference the assembly
# symbols unconditionally, so on any build system that links library objects
# directly instead of archiving them they would be pulled into the link and
# fail with "undefined reference" once the .S bodies are preprocessed away.
find ./src/esp-nn/ -type f \( -iname "*esp32s3.S" -o -iname "*esp32s3.c" \) -exec sed -i '1s/^/#ifdef ARCH_ESP32_S3\n/;$a\\n#endif' {} \;

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
