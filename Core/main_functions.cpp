/* Copyright 2018 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include "main_functions.h"
#include "cmsis_os.h"
#include "uart_utils.h"
#include "stm32746g_discovery.h"
#include "micro_features_micro_model_settings.h"
#include "lcd.h"
#include "tensorflow/lite/micro/kernels/micro_ops.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "../tensorflow/tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/version.h"
#include "no_micro_features_data.h"
#include "yes_micro_features_data.h"
#include "unknown_micro_features_data.h"
#include "tensorflow/lite/core/api/flatbuffer_conversions.h"

#include <sys/unistd.h>
// Model declaration
namespace {
  tflite::ErrorReporter* error_reporter = nullptr;
  const tflite::Model* model = nullptr;
  tflite::MicroInterpreter* interpreter = nullptr;
  TfLiteTensor* model_input = nullptr;
  FeatureProvider* feature_provider = nullptr;
  RecognizeCommands* recognizer = nullptr;
  int32_t previous_time = 0;
  int count = 1;
  // Create an area of memory to use for input, output, and intermediate arrays.
  // The size of this will depend on the model you're using, and may need to be
  // determined by experimentation.
  constexpr int kTensorArenaSize = 20 * 1024;
  alignas(16) static uint8_t tensor_arena[kTensorArenaSize]; //This is done to avoid errors in the model
  }  // namespace



UART_HandleTypeDef DebugUartHandler;



  // This is the setup function, executed once at startup.
  void setup() {

    HAL_Init();
  /* USER CODE BEGIN 1 */
  BSP_LED_Init(LED_GREEN);

  // Turn on the LED to indicate system clock configuration success
  //BSP_LED_On(LED_GREEN);
  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/
  cpu_cache_enable();

  
  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  //HAL_Init();

  BSP_LED_On(LED_GREEN);
  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  //system_clock_config();

  uart1_init(); //Initialize the uart
  PrintToUart("UART Initialized\r\n"); //Debug message for the UART initialization
  

  // Tensorflow code, instantiate the error reporter to report errors to the UART
  static tflite::MicroErrorReporter micro_error_reporter;
  error_reporter = &micro_error_reporter;



  model = tflite::GetModel(g_tiny_conv_micro_features_model_data);

  if (model->version() != TFLITE_SCHEMA_VERSION) {
    PrintToUart("Version is not correct\r\n");
    error_handler();
    return;
  }
  else
  {
    PrintToUart("Model assigned correctly\r\n");
  }

  static tflite::MicroMutableOpResolver<4> micro_mutable_op_resolver;
  TfLiteStatus BuiltinOperator_StatusDebug_0 = micro_mutable_op_resolver.AddReshape();
  TfLiteStatus BuiltinOperator_StatusDebug_1 = micro_mutable_op_resolver.AddFullyConnected();
  TfLiteStatus BuiltinOperator_StatusDebug_2 = micro_mutable_op_resolver.AddConv2D();
  TfLiteStatus BuiltinOperator_StatusDebug_3 = micro_mutable_op_resolver.AddSoftmax();

  static tflite::MicroInterpreter static_interpreter(
        model, micro_mutable_op_resolver, tensor_arena, kTensorArenaSize);
    interpreter = &static_interpreter;

  TfLiteStatus allocate_status = interpreter->AllocateTensors();
  if (allocate_status != kTfLiteOk) {
    PrintToUart("AllocateTensors() failed\r\n");
    error_handler();
  }
  else{
   // PrintToUart("AllocateTensors() succeeded\r\n");
  }

  // Get information about the memory area to use for the model's input.

  model_input = interpreter->input(0);
  const int kFlatInputSize = 49 * 40;
 // PrintToUart(buffer);
if (model_input->dims->size  != 2 ||
    model_input->dims->data[0] != 1 ||
    model_input->dims->data[1] != kFlatInputSize ||
    model_input->type          != kTfLiteInt8) {
        PrintToUart("Bad input tensor parameters in model\r\n");
        error_handler();
      }

  TfLiteTensor* input = interpreter->input(0);
  //static FeatureProvider static_feature_provider(kFeatureElementCount,
                                                model_input->data.uint8);
  //feature_provider = &static_feature_provider;
  /* RecognizeCommands is also a tflite class. It helps with the audio processing. It's a quite complex class, with status
  and structs inside. Later, we'll call some of them for debugging. */
 // static RecognizeCommands static_recognizer(error_reporter);
 // recognizer = &static_recognizer;

  previous_time = 0;

  }

  // The name of this function is important for Arduino compatibility.
  void loop() {
    // Fetch the spectrogram for the current time.
    // It might be failing because it doesn't get the timestamp correctly
    const int32_t current_time = 0;
    // I print the current time
    char buffer[64];
    sprintf(buffer, "Current time: %ld\r\n", current_time);
    PrintToUart(buffer);

    int how_many_new_slices = 0;

    // Here should be the main problem
/*
    TfLiteStatus feature_status = feature_provider->PopulateFeatureData(
        error_reporter, previous_time, current_time, &how_many_new_slices);
    if (feature_status != kTfLiteOk) {
      PrintToUart("Feature generation failed\r\n");
      error_handler();
      return;
    }*/

    previous_time = current_time;

    TfLiteTensor* input = interpreter->input(0);
    const uint8_t* features_data;
    switch (count) {
      case 1:
        features_data = g_no_data;
        count = 2;
        sprintf(buffer, "Using no.\r\n");
        PrintToUart(buffer);
        break;
      case 2:
        features_data = g_unknown_data;
        count = 3;
        sprintf(buffer, "Using unknown.\r\n");
        PrintToUart(buffer);
        break;
      case 3:
      default:
        features_data = g_yes_data;
        count = 1;
        sprintf(buffer, "Using yes.\r\n");
        PrintToUart(buffer);
        break;
    }



    for (size_t i = 0; i < input->bytes; ++i) {
      input->data.int8[i] = features_data[i];
    }

    // Run the model on this "No" input.
        char time_buffer[64];
      uint32_t start_tick = HAL_GetTick();
 sprintf(time_buffer, "Start Tick: %lu ms\r\n", start_tick);
    PrintToUart(time_buffer);
    // Run the model on this "No" input.
    TfLiteStatus invoke_status = interpreter->Invoke();

    uint32_t end_tick = HAL_GetTick();
    uint32_t inference_time_ms = end_tick - start_tick;

    sprintf(time_buffer, "Inference time: %lu ms\r\n", inference_time_ms);
    PrintToUart(time_buffer);



    if (invoke_status != kTfLiteOk) {
          PrintToUart("Invoke failed\n");
          error_handler();
    }

    // Get the output from the model, and make sure it's the expected size and type.
    TfLiteTensor* output = interpreter->output(0);

    // Print the output tensor values
  PrintToUart("Output Data:\r\n");
  for (size_t i = 0; i < output->bytes; ++i) {
    char out_buffer[16];
    sprintf(out_buffer, "%d ", safe_convert(output->data.int8[i]));
    PrintToUart(out_buffer);
    if ((i + 1) % 16 == 0) {
      PrintToUart("\r\n");
    }
    }
    PrintToUart("\r\n");



    const char* found_command = nullptr;
    uint8_t score = 0;
    uint8_t command_index;
    for (size_t i = 0; i < output->bytes; ++i) {
    if(safe_convert(output->data.int8[i]) > score) {
      score = safe_convert(output->data.int8[i]);
      command_index = i;
    }
    }

    switch (command_index)
    {
    case 0:
      found_command = "silence";
      break;
    case 1:
      found_command = "unknown";
      break;
    case 2:
      found_command = "yes";
      break;
    case 3:
      found_command = "no";
      break;
    default:
      found_command = "none";
      break;
    }

    



    // Print the recognized command, score, and whether it's a new command
    char result_buffer[128];
    sprintf(result_buffer, "Command: %s, Score: %u",
        found_command, score);
    PrintToUart(result_buffer);


    // Do something based on the recognized command. The default implementation
    // just prints to the error console, but you should replace this with your
    // own function for a real application.
    //RespondToCommand(error_reporter, current_time, found_command, score, is_new_command);



    PrintToUart("Loop completed\r\n");
  }


  void system_clock_config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};


  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

   // Enable HSE Oscillator and activate PLL with HSE as source
   RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
   RCC_OscInitStruct.HSEState       = RCC_HSE_ON;
   RCC_OscInitStruct.PLL.PLLState   = RCC_PLL_ON;
   RCC_OscInitStruct.PLL.PLLSource  = RCC_PLLSOURCE_HSE;
   RCC_OscInitStruct.PLL.PLLM       = 25;
   RCC_OscInitStruct.PLL.PLLN       = 400;
   RCC_OscInitStruct.PLL.PLLP       = RCC_PLLP_DIV2;
   RCC_OscInitStruct.PLL.PLLQ       = 9;
 
   if(HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    error_handler();
  }

  /** Activate the Over-Drive mode
  */
  if(HAL_PWREx_EnableOverDrive() != HAL_OK)
  {
    error_handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */

   // Initializes the CPU, AHB and APB busses clocks
  RCC_ClkInitStruct.ClockType      = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource   = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider  = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

  if(HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_6) != HAL_OK)
  {
    error_handler();
  }
}

static void uart1_init(void)
{
	DebugUartHandler.Instance        = DISCOVERY_COM1;
 	DebugUartHandler.Init.BaudRate   = 9600;
 	DebugUartHandler.Init.WordLength = UART_WORDLENGTH_8B;
 	DebugUartHandler.Init.StopBits   = UART_STOPBITS_1;
 	DebugUartHandler.Init.Parity     = UART_PARITY_NONE;
 	DebugUartHandler.Init.HwFlowCtl  = UART_HWCONTROL_NONE;
 	DebugUartHandler.Init.Mode       = UART_MODE_TX_RX;
 	DebugUartHandler.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;

 	if(HAL_UART_DeInit(&DebugUartHandler) != HAL_OK)
 	{
 		error_handler();
 	}
   else
  {
     PrintToUart("UART DeInit working correctly\r\n");
  }

 	if(HAL_UART_Init(&DebugUartHandler) != HAL_OK)
 	{
 	    error_handler();
 	}
  else
  {
      PrintToUart("UART Init working correctly\r\n");
 	}


}

static void error_handler(void)
 {
  const char* error_msg = "Error occurred. Entering error handler.\n";
  HAL_UART_Transmit(&DebugUartHandler, (uint8_t*)error_msg, strlen(error_msg), HAL_MAX_DELAY);
  BSP_LED_On(LED_GREEN);
  while (1);
 }


static void cpu_cache_enable(void){
  // Enable I-Cache
     SCB_EnableICache();

   /* USER CODE END Error_Handler_Debug */
     // Enable D-Cache
     SCB_EnableDCache();
    }


uint8_t safe_convert(int8_t signed_val) {
    uint8_t unsigned_val = (uint8_t)signed_val;
    return unsigned_val;
}
