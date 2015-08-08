CMAKE_MINIMUM_REQUIRED(VERSION 2.8)
project(project_name)

FIND_PACKAGE(ArrayFire REQUIRED)
INCLUDE_DIRECTORIES(${ArrayFire_INCLUDE_DIRS})

FILE(GLOB SOURCE "*.cpp")
ADD_LIBRARY(FOO_CORE OBJECT ${SOURCE})

# Build benchmarks linking specifically with designated backends
if(${ArrayFire_CPU_FOUND})
    MESSAGE(STATUS "ArrayFire CPU backend found. Enabling CPU benchmark")
    ADD_EXECUTABLE(foo-cpu $<TARGET_OBJECTS:FOO_CORE>)
    TARGET_LINK_LIBRARIES(foo-cpu ${ArrayFire_CPU_LIBRARIES}
        ${CMAKE_THREAD_LIBS_INIT})
ENDIF()

if(${ArrayFire_OpenCL_FOUND})
    FIND_PACKAGE(OpenCL REQUIRED)
    MESSAGE(STATUS "ArrayFire OpenCL backend found. Enabling OpenCL benchmark")
    ADD_EXECUTABLE(foo-opencl $<TARGET_OBJECTS:FOO_CORE>)
    TARGET_LINK_LIBRARIES(foo-opencl ${ArrayFire_OpenCL_LIBRARIES}
        ${OpenCL_LIBRARIES} ${CMAKE_THREAD_LIBS_INIT})
ENDIF()

if(${ArrayFire_CUDA_FOUND})
    FIND_PACKAGE(CUDA REQUIRED)
    FIND_PACKAGE(NVVM REQUIRED)
    MESSAGE(STATUS ${CUDA_TOOLKIT_ROOT_DIR})
    MESSAGE(STATUS "ArrayFire CUDA found. Enabling CUDA benchmark")
    ADD_EXECUTABLE(foo-cuda $<TARGET_OBJECTS:FOO_CORE>)
    TARGET_LINK_LIBRARIES(foo-cuda ${ArrayFire_CUDA_LIBRARIES}
        ${CMAKE_THREAD_LIBS_INIT} ${CUDA_LIBRARIES} ${NVVM_LIB})
ENDIF()
