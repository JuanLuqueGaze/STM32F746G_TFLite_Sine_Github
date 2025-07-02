// filepath: c:\Users\gie-5\STM32CubeIDE\workspace_1.17.0\STM32F746G_TFLite_WakeWord\Core\uart_utils.h
#ifndef UART_UTILS_H_
#define UART_UTILS_H_
#include "tensorflow/lite/c/common.h"
void PrintToUart(const char* message);
const char* TfLiteStatusToString(TfLiteStatus status);
#endif  // UART_UTILS_H_