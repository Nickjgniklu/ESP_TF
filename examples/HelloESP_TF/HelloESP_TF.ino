// ESP_TF MNIST demo: loads a real, trained digit-classifier model and runs
// inference on a handful of real MNIST test images (bundled in
// test_images.h), no camera or network required. See the README for the
// build flags that enable ESP_NN and the ESP32-S3 optimizations - this
// sketch runs unmodified with any of them.
//
// Model and test harness adapted from https://github.com/Nickjgniklu/esp_mnist
#include <ESP_TF.h>
#include "mnist_model.h"
#include "all_ops_resolver.h"
#include "test_images.h"

#include "tensorflow/lite/micro/tflite_bridge/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

namespace {
  const tflite::Model *model = nullptr;
  tflite::MicroInterpreter *interpreter = nullptr;
  constexpr int kTensorArenaSize = 35 * 1024;
  uint8_t tensor_arena[kTensorArenaSize];
}

// Returns the index of the highest-scoring class.
int predictedClass(TfLiteTensor *output) {
  int best = 0;
  for (int i = 1; i < 10; i++) {
    if (output->data.int8[i] > output->data.int8[best]) best = i;
  }
  return best;
}

void setup() {
  Serial.begin(115200);
  delay(3000);
  Serial.println("ESP_TF MNIST demo starting");

  model = tflite::GetModel(mnist_model);
  if (model->version() != TFLITE_SCHEMA_VERSION) {
    Serial.printf("Model schema version %d != supported version %d\n",
                  model->version(), TFLITE_SCHEMA_VERSION);
    return;
  }

  CREATE_ALL_OPS_RESOLVER(op_resolver)
  static tflite::MicroInterpreter static_interpreter(
      model, op_resolver, tensor_arena, kTensorArenaSize);
  interpreter = &static_interpreter;

  if (interpreter->AllocateTensors() != kTfLiteOk) {
    Serial.println("AllocateTensors() FAILED");
    return;
  }
  Serial.printf("AllocateTensors OK, arena used: %d / %d bytes\n",
                interpreter->arena_used_bytes(), kTensorArenaSize);

  TfLiteTensor *input = interpreter->input(0);
  int correct = 0;

  for (int i = 0; i < kNumTestImages; i++) {
    memcpy(input->data.int8, kTestImages[i], 28 * 28);

    uint32_t start = millis();
    TfLiteStatus invoke_status = interpreter->Invoke();
    uint32_t elapsed = millis() - start;

    if (invoke_status != kTfLiteOk) {
      Serial.printf("image %d: invoke FAILED\n", i);
      continue;
    }

    int predicted = predictedClass(interpreter->output(0));
    int expected = kTestImageLabels[i];
    bool pass = predicted == expected;
    if (pass) correct++;

    Serial.printf("image %d: expected %d, predicted %d, %lu ms - %s\n", i,
                  expected, predicted, elapsed, pass ? "PASS" : "FAIL");
  }

  Serial.printf("%d/%d correct\n", correct, kNumTestImages);
  Serial.println("ESP_TF MNIST demo done");
}

void loop() {}
