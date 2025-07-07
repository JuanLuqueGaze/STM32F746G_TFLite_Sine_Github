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

#include "tensorflow/lite/micro/simple_memory_allocator.h"

#include <cstddef>
#include <cstdint>
#include "uart_utils.h"
#include "tensorflow/lite/micro/memory_helpers.h"

namespace tflite {

SimpleMemoryAllocator* CreateInPlaceSimpleMemoryAllocator(
    ErrorReporter* error_reporter, uint8_t* buffer, size_t buffer_size) {


// Print the entire tensor_arena content in hex
char buffer2[256];
/*
sprintf(buffer2, "Full tensor_arena content (%lu bytes):\r\n", (unsigned long)buffer_size);
PrintToUart(buffer2);

for (uint32_t i = 0; i < buffer_size; ++i) {
    sprintf(buffer2, "%02X ", buffer[i]);
    PrintToUart(buffer2);
    // Print a newline every 16 bytes for readability
    if ((i + 1) % 16 == 0) {
        PrintToUart("\r\n");
    }
}
PrintToUart("\r\n");*/




      char buffer3[128];
      PrintToUart("I am in Create in place simple memory allocator\r\n");
     SimpleMemoryAllocator tmp =
      SimpleMemoryAllocator(error_reporter, buffer, buffer_size);
      sprintf(buffer3, "Head is at: 0x%08lX\r\n", (unsigned long)(uintptr_t)tmp.GetHead());
      PrintToUart(buffer3);
      sprintf(buffer3, "Tail is at: 0x%08lX\r\n", (unsigned long)(uintptr_t)tmp.GetTail());
      PrintToUart(buffer3);
// Juan: Reserva memoria para un SimpleMemoryAllocator en la parte final del buffer
  SimpleMemoryAllocator* in_place_allocator =
      reinterpret_cast<SimpleMemoryAllocator*>(tmp.AllocateFromTail(
          sizeof(SimpleMemoryAllocator), alignof(SimpleMemoryAllocator)));
/*
  sprintf(buffer2, "Full tensor_arena content (%lu bytes):\r\n", (unsigned long)buffer_size);
PrintToUart(buffer2);

for (uint32_t i = 0; i < buffer_size; ++i) {
    sprintf(buffer2, "%02X ", buffer[i]);
    PrintToUart(buffer2);
    // Print a newline every 16 bytes for readability
    if ((i + 1) % 16 == 0) {
        PrintToUart("\r\n");
    }
}
PrintToUart("\r\n");*/
          
/*

  sprintf(buffer3, "Allocation size: %d; Allocation alignment: %d\r\n", sizeof(SimpleMemoryAllocator), alignof(SimpleMemoryAllocator));
  PrintToUart(buffer3);
  sprintf(buffer3, "In place allocator: 0x%08lX\r\n", (unsigned long)(uintptr_t)in_place_allocator);
  PrintToUart(buffer3);



  sprintf(buffer2, "Full tensor_arena content (%lu bytes):\r\n", (unsigned long)buffer_size);
PrintToUart(buffer2);

for (uint32_t i = 0; i < buffer_size; ++i) {
    sprintf(buffer2, "%02X ", buffer[i]);
    PrintToUart(buffer2);
    // Print a newline every 16 bytes for readability
    if ((i + 1) % 16 == 0) {
        PrintToUart("\r\n");
    }
}
PrintToUart("\r\n");*/

// Juan: aquí es donde se asigna contenido al tensor arena
// Si miramos en el simple memory allocator, vemos que en el private tiene estas cosas:
/* 

  ErrorReporter* error_reporter_;
  uint8_t* buffer_head_;
  uint8_t* buffer_tail_;
  uint8_t* head_;
  uint8_t* tail_;*/

  // Si miro las ultimas líneas del tensor arena, coinciden el error_reporter, el buffer_head_, el buffer_tail_, el head_ y el tail_ con los valores que tengo en el buffer
/*
sprintf(buffer2, "error_reporter_ pointer: %p\r\n", (void*)error_reporter);
PrintToUart(buffer2);*/
  *in_place_allocator = tmp;
/*
  sprintf(buffer2, "Full tensor_arena content (%lu bytes):\r\n", (unsigned long)buffer_size);
PrintToUart(buffer2);

for (uint32_t i = 0; i < buffer_size; ++i) {
    sprintf(buffer2, "%02X ", buffer[i]);
    PrintToUart(buffer2);
    // Print a newline every 16 bytes for readability
    if ((i + 1) % 16 == 0) {
        PrintToUart("\r\n");
    }
}
PrintToUart("\r\n");*/

  return in_place_allocator;
}

uint8_t* SimpleMemoryAllocator::AllocateFromHead(size_t size,
                                                 size_t alignment) {
  uint8_t* const aligned_result = AlignPointerUp(head_, alignment);
  const size_t available_memory = tail_ - aligned_result;
  if (available_memory < size) {
    TF_LITE_REPORT_ERROR(
        error_reporter_,
        "Failed to allocate memory. Requested: %u, available %u, missing: %u",
        size, available_memory, size - available_memory);
    return nullptr;
  }
  head_ = aligned_result + size;
  return aligned_result;
}

uint8_t* SimpleMemoryAllocator::AllocateFromTail(size_t size,
                                                 size_t alignment) {
    char buffer_ta[128];
    sprintf(buffer_ta, "Tail pointer: %p, I have to allocate %d size with %d alignment\r\n", (void*)tail_, size, alignment);

    PrintToUart(buffer_ta);                            
  uint8_t* const aligned_result = AlignPointerDown(tail_ - size, alignment);
  if (aligned_result < head_) {
    const size_t missing_memory = head_ - aligned_result;
    TF_LITE_REPORT_ERROR(
        error_reporter_,
        "Failed to allocate memory. Requested: %u, available %u, missing: %u",
        size, size - missing_memory, missing_memory);
    return nullptr;
  }
  tail_ = aligned_result;
  sprintf(buffer_ta, "After Simple Allocation Tail is at: 0x%08lX\r\n", (unsigned long)(uintptr_t)tail_);
  PrintToUart(buffer_ta);
  // Assume buffer is the start of your arena and buffer + buffer_size is the end
/*
  uint8_t* print_start =  tail_ - 10;
  uint8_t* print_end =  tail_ + 20;

  char mem_buffer[128];
  sprintf(mem_buffer, "Memory from tail_-10 to tail_+20:\r\n");
  PrintToUart(mem_buffer);

  for (uint8_t* ptr = print_start; ptr < print_end; ++ptr) {
      sprintf(mem_buffer, "0x%02X ", *ptr);
      PrintToUart(mem_buffer);
      if (((ptr - print_start + 1) % 16) == 0) {
          PrintToUart("\r\n");
      }
  }
  PrintToUart("\r\n");*/
  return aligned_result;
}

}  // namespace tflite
