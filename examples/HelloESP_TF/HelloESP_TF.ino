// Minimal ESP_TF sketch: registers the esp-nn accelerated kernels so the
// library is compiled and linked. See the README for the build flags that
// enable ESP_NN and the ESP32-S3 optimizations.
#include <ESP_TF.h>
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_interpreter.h"

static tflite::MicroMutableOpResolver<4> resolver;

void setup() {
  Serial.begin(115200);
  resolver.AddConv2D();
  resolver.AddDepthwiseConv2D();
  resolver.AddFullyConnected();
  resolver.AddSoftmax();
  Serial.println("ESP_TF ops registered");
}

void loop() {}
