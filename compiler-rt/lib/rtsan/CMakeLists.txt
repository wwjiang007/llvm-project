include_directories(..)

set(RTSAN_CXX_SOURCES
  rtsan.cpp
  rtsan_context.cpp
  rtsan_diagnostics.cpp
  rtsan_flags.cpp
  rtsan_interceptors_posix.cpp
  rtsan_stats.cpp
  rtsan_suppressions.cpp
  )

set(RTSAN_PREINIT_SOURCES
  rtsan_preinit.cpp)

set(RTSAN_HEADERS
  rtsan.h
  rtsan_checks.inc
  rtsan_assertions.h
  rtsan_context.h
  rtsan_diagnostics.h
  rtsan_flags.h
  rtsan_flags.inc
  rtsan_stats.h
  rtsan_suppressions.h
  )

set(RTSAN_DEPS)

set(RTSAN_CFLAGS
  ${COMPILER_RT_COMMON_CFLAGS}
  ${COMPILER_RT_CXX_CFLAGS}
  -DSANITIZER_COMMON_NO_REDEFINE_BUILTINS)
set(RTSAN_LINK_FLAGS ${COMPILER_RT_COMMON_LINK_FLAGS})
set(RTSAN_DYNAMIC_LIBS
  ${COMPILER_RT_UNWINDER_LINK_LIBS}
  ${SANITIZER_CXX_ABI_LIBRARIES}
  ${SANITIZER_COMMON_LINK_LIBS})

append_rtti_flag(OFF RTSAN_CFLAGS)

if(APPLE)
  add_compiler_rt_object_libraries(RTRtsan
    OS ${SANITIZER_COMMON_SUPPORTED_OS}
    ARCHS ${RTSAN_SUPPORTED_ARCH}
    SOURCES ${RTSAN_CXX_SOURCES}
    ADDITIONAL_HEADERS ${RTSAN_HEADERS}
    CFLAGS ${RTSAN_CFLAGS}
    DEPS ${RTSAN_DEPS})
else()
  add_compiler_rt_object_libraries(RTRtsan
    ARCHS ${RTSAN_SUPPORTED_ARCH}
    SOURCES ${RTSAN_CXX_SOURCES}
    ADDITIONAL_HEADERS ${RTSAN_HEADERS}
    CFLAGS ${RTSAN_CFLAGS}
    DEPS ${RTSAN_DEPS})
  add_compiler_rt_object_libraries(RTRtsan_preinit
    ARCHS ${RTSAN_SUPPORTED_ARCH}
    SOURCES ${RTSAN_PREINIT_SOURCES}
    ADDITIONAL_HEADERS ${RTSAN_HEADERS}
    CFLAGS ${RTSAN_CFLAGS})
endif()

set(RTSAN_COMMON_RUNTIME_OBJECT_LIBS
  RTInterception
  RTSanitizerCommon
  RTSanitizerCommonLibc
  RTSanitizerCommonCoverage
  RTSanitizerCommonSymbolizer)

append_list_if(COMPILER_RT_HAS_LIBDL dl RTSAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBRT rt RTSAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBM m RTSAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBPTHREAD pthread RTSAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBLOG log RTSAN_DYNAMIC_LIBS)

add_compiler_rt_component(rtsan)

if (APPLE)
  add_weak_symbols("sanitizer_common" WEAK_SYMBOL_LINK_FLAGS)
  set(RTSAN_LINK_FLAGS ${RTSAN_LINK_FLAGS} ${WEAK_SYMBOL_LINK_FLAGS})

  add_compiler_rt_runtime(clang_rt.rtsan
    SHARED
    OS ${SANITIZER_COMMON_SUPPORTED_OS}
    ARCHS ${RTSAN_SUPPORTED_ARCH}
    OBJECT_LIBS RTRtsan
                ${RTSAN_COMMON_RUNTIME_OBJECT_LIBS}
    LINK_FLAGS ${RTSAN_LINK_FLAGS}
    LINK_LIBS ${RTSAN_DYNAMIC_LIBS}
    PARENT_TARGET rtsan)
else()
  add_compiler_rt_runtime(clang_rt.rtsan
    STATIC
    ARCHS ${RTSAN_SUPPORTED_ARCH}
    OBJECT_LIBS RTRtsan_preinit
                RTRtsan
                ${RTSAN_COMMON_RUNTIME_OBJECT_LIBS}
    LINK_FLAGS ${RTSAN_LINK_FLAGS}
    CFLAGS ${RTSAN_CFLAGS}
    PARENT_TARGET rtsan)
endif()

if(COMPILER_RT_INCLUDE_TESTS)
  add_subdirectory(tests)
endif()
