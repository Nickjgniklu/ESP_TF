#include <cstdint>

#include "tensorflow/lite/experimental/microfrontend/lib/kiss_fft_common.h"

#define FIXED_POINT 16
namespace kissfft_fixed16 {
#include "kissfft/kiss_fft.c"
#include "kissfft/kiss_fftr.c"
}  // namespace kissfft_fixed16
#undef FIXED_POINT
