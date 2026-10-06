# CMake version
cmake_minimum_required(VERSION 3.28.1)

include(CMakePrintHelpers)

include(GCC.cmake)
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_SOURCE_DIR}/GCC.cmake)

# Khai báo tên dự án
project(embeddat_Project)

# Build the executable based on the source files
add_executable(main main.c)

message("\n")
message(${CMAKE_CURRENT_SOURCE_DIR})
message(${CMAKE_CURRENT_BINARY_DIR})
message(WARNING "Thu vien A khong tim thấy, dung thu vien B")
cmake_print_variables("embeddat am learning CMake with Hula Embedded on Youtube \n")
cmake_print_variables(CMAKE_C_COMPILER CMAKE_CXX_COMPILER CMAKE_ASM_COMPILER CMAKE_OBJCOPY CMAKE_SIZE_UTIL)

message("\n")
