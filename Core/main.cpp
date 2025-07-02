/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "cmsis_os.h"
#include "stm32746g_discovery.h"
#include "sine_model.h"
#include "lcd.h"
#include "tensorflow/lite/micro/kernels/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/version.h"
#include "uart_utils.h"
/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
namespace
 {
 tflite::ErrorReporter* error_reporter = nullptr;
 const tflite::Model* model = nullptr;
 tflite::MicroInterpreter* interpreter = nullptr;
 TfLiteTensor* input = nullptr;
 TfLiteTensor* output = nullptr;
 
 // Create an area of memory to use for input, output, and intermediate arrays.
 // Finding the minimum value for your model may require some trial and error.
 constexpr uint32_t kTensorArenaSize = 2 * 1024;
 alignas(16) static uint8_t tensor_arena[kTensorArenaSize];
 }// namespace
 

 extern const float INPUT_RANGE = 2.f * 3.14159265359f;

 const uint16_t INFERENCE_PER_CYCLE = 70;

// UART handler declaration
UART_HandleTypeDef DebugUartHandler;

#if defined ( __ICCARM__ ) /*!< IAR Compiler */
#pragma location=0x2004c000
ETH_DMADescTypeDef  DMARxDscrTab[ETH_RX_DESC_CNT]; /* Ethernet Rx DMA Descriptors */
#pragma location=0x2004c0a0
ETH_DMADescTypeDef  DMATxDscrTab[ETH_TX_DESC_CNT]; /* Ethernet Tx DMA Descriptors */

#elif defined ( __CC_ARM )  /* MDK ARM Compiler */

__attribute__((at(0x2004c000))) ETH_DMADescTypeDef  DMARxDscrTab[ETH_RX_DESC_CNT]; /* Ethernet Rx DMA Descriptors */
__attribute__((at(0x2004c0a0))) ETH_DMADescTypeDef  DMATxDscrTab[ETH_TX_DESC_CNT]; /* Ethernet Tx DMA Descriptors */

#elif defined ( __GNUC__ ) /* GNU Compiler */

ETH_DMADescTypeDef DMARxDscrTab[ETH_RX_DESC_CNT] __attribute__((section(".RxDecripSection"))); /* Ethernet Rx DMA Descriptors */
ETH_DMADescTypeDef DMATxDscrTab[ETH_TX_DESC_CNT] __attribute__((section(".TxDecripSection")));   /* Ethernet Tx DMA Descriptors */
#endif

ETH_TxPacketConfig TxConfig;


/* USER CODE BEGIN PV */

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
static void system_clock_config(void);
static void cpu_cache_enable(void);
static void error_handler(void);
static void uart1_init(void);
void handle_output(tflite::ErrorReporter* error_reporter, float x_value, float y_value);

/* USER CODE BEGIN PFP */

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */
  BSP_LED_Init(LED_GREEN);

  // Turn on the LED to indicate system clock configuration success
  //BSP_LED_On(LED_GREEN);
  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/
  cpu_cache_enable();

  
  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  BSP_LED_On(LED_GREEN);
  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  system_clock_config();
 
  /* Configure the peripherals common clocks */
  //PeriphCommonClock_Config();  //Maybe this should be commented out

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

 // Initialize UART1
 uart1_init();
 // Initialize LCD
 LCD_Init();


 static tflite::MicroErrorReporter micro_error_reporter;
 error_reporter = &micro_error_reporter;


 // Map the model into a usable data structure. This doesn't involve any
 // copying or parsing, it's a very lightweight operation.
 model = tflite::GetModel(sine_model);
// Print the address of model in hex
  char buffer[128];
  sprintf(buffer, "Allocation address: 0x%08lX\r\n", (unsigned long)(uintptr_t)model);
  PrintToUart(buffer);
  sprintf(buffer, "Allocation address: 0x%08lX\r\n", (unsigned long)(uintptr_t)sine_model);
  PrintToUart(buffer);
  sprintf(buffer, "Allocation address: 0x%08lX\r\n", (unsigned long)(uintptr_t)tensor_arena);
  PrintToUart(buffer);

  char byte_buffer[128];
sprintf(byte_buffer, "First 30 bytes of tensor_arena:\r\n");
PrintToUart(byte_buffer);

for (int i = 0; i < 30; ++i) {
    sprintf(byte_buffer, "0x%02X ", tensor_arena[i]);
    PrintToUart(byte_buffer);
    // Optional: print a newline every 16 bytes for readability
    if ((i + 1) % 16 == 0) {
        PrintToUart("\r\n");
    }
}
PrintToUart("\r\n");


if(model->version() != TFLITE_SCHEMA_VERSION)
 {
   TF_LITE_REPORT_ERROR(error_reporter,
                          "Model provided is schema version %d not equal "
                          "to supported version %d.",
                          model->version(), TFLITE_SCHEMA_VERSION);
     return 0;
 }

 // This pulls in all the operation implementations we need.
 static tflite::ops::micro::AllOpsResolver resolver;

 // Build an interpreter to run the model with.
 static tflite::MicroInterpreter static_interpreter(model, resolver, tensor_arena, kTensorArenaSize, error_reporter);
 interpreter = &static_interpreter;

 // Allocate memory from the tensor_arena for the model's tensors.
 TfLiteStatus allocate_status = interpreter->AllocateTensors();
 if (allocate_status != kTfLiteOk)
 {
     TF_LITE_REPORT_ERROR(error_reporter, "AllocateTensors() failed");
     return 0;
 }

 // Obtain pointers to the model's input and output tensors.
 input = interpreter->input(0);
 output = interpreter->output(0);

 float unitValuePerDevision = INPUT_RANGE / static_cast<float>(INFERENCE_PER_CYCLE);

  while (1)
  {
    	    // Calculate an x value to feed into the model
          for(uint16_t inferenceCount = 0; inferenceCount <= INFERENCE_PER_CYCLE; inferenceCount++)
          {
            float x_val = static_cast<float>(inferenceCount) * unitValuePerDevision;
  
            // Place our calculated x value in the model's input tensor
            input->data.f[0] = x_val;
  
            // Run inference, and report any error
            TfLiteStatus invoke_status = interpreter->Invoke();
            if (invoke_status != kTfLiteOk)
            {
                TF_LITE_REPORT_ERROR(error_reporter, "Invoke failed on x_val: %f\n", static_cast<float>(x_val));
                return 0;
            }
  
            // Read the predicted y value from the model's output tensor
            float y_val = output->data.f[0];
            // Plot the results in the LCD screen
            handle_output(error_reporter, x_val, y_val);
          }


  }
}


void handle_output(tflite::ErrorReporter* error_reporter, float x_value, float y_value)
 {
 	// Log the current X and Y values
 	TF_LITE_REPORT_ERROR(error_reporter, "x_value: %f, y_value: %f\n", x_value, y_value);
 
 	// A custom function can be implemented and used here to do something with the x and y values.
 	// In my case I will be plotting sine wave on an LCD.
 	LCD_Output(x_value, y_value);
 }
 

/**
  * @brief System Clock Configuration
  * @retval None
  */
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



/**
  * @brief USART1 Initialization Function
  * @param None
  * @retval None
  */
static void uart1_init(void)
{
    /*##-1- Configure the UART peripheral ######################################*/
 	/* Put the USART peripheral in the Asynchronous mode (UART Mode)
 	   UART configured as follows:
 	      - Word Length = 8 Bits
 	      - Stop Bit = One Stop bit
 	      - Parity = None
 	      - BaudRate = 9600 baud
 	      - Hardware flow control disabled (RTS and CTS signals)
 	 */
 
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
    if(HAL_UART_Init(&DebugUartHandler) != HAL_OK)
    {
        error_handler();
    }

}

static void error_handler(void)
 {
  const char* error_msg = "Error occurred. Entering error handler.\n";
  HAL_UART_Transmit(&DebugUartHandler, (uint8_t*)error_msg, strlen(error_msg), HAL_MAX_DELAY);
  BSP_LED_On(LED_GREEN);
  while (1);
 }



/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
 static void cpu_cache_enable(void)
{
    // Enable I-Cache
    SCB_EnableICache();
    // Enable D-Cache
    SCB_EnableDCache();
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
