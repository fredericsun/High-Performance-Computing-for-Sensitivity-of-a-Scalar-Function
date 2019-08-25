cmake_minimum_required (VERSION 3.8)

set(CMAKE_CUDA_HOST_COMPILER $ENV{CU_CCBIN} CACHE PATH "Cuda host compiler dir")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -lm")

project(FinalProject LANGUAGES C CUDA)
add_executable(jacobian jacobian.cu f_eval.cuh)
add_executable(jacobian_cpu jacobian_cpu.c f_eval.h)
add_executable(generate matrix.c)
# For linking ...
# Specify target & libraries to link it with
#target_link_libraries( problem1 -lfoobar )
