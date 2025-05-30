; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-- -mattr=sse2    | FileCheck %s --check-prefixes=SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-- -mattr=sse4.2  | FileCheck %s --check-prefixes=SSE,SSE42
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx     | FileCheck %s --check-prefixes=AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx2    | FileCheck %s --check-prefixes=AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-- -mattr=avx512f | FileCheck %s --check-prefixes=AVX,AVX512F

define void @foo(<4 x float> %in, ptr %out) {
; SSE2-LABEL: foo:
; SSE2:       # %bb.0:
; SSE2-NEXT:    cvttps2dq %xmm0, %xmm0
; SSE2-NEXT:    pand {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    por {{\.?LCPI[0-9]+_[0-9]+}}(%rip), %xmm0
; SSE2-NEXT:    movd %xmm0, (%rdi)
; SSE2-NEXT:    retq
;
; SSE42-LABEL: foo:
; SSE42:       # %bb.0:
; SSE42-NEXT:    cvttps2dq %xmm0, %xmm0
; SSE42-NEXT:    pshufb {{.*#+}} xmm0 = xmm0[0,4,8,u,u,u,u,u,u,u,u,u,u,u,u,u]
; SSE42-NEXT:    movl $255, %eax
; SSE42-NEXT:    pinsrb $3, %eax, %xmm0
; SSE42-NEXT:    movd %xmm0, (%rdi)
; SSE42-NEXT:    retq
;
; AVX-LABEL: foo:
; AVX:       # %bb.0:
; AVX-NEXT:    vcvttps2dq %xmm0, %xmm0
; AVX-NEXT:    vpshufb {{.*#+}} xmm0 = xmm0[0,4,8,u,u,u,u,u,u,u,u,u,u,u,u,u]
; AVX-NEXT:    movl $255, %eax
; AVX-NEXT:    vpinsrb $3, %eax, %xmm0, %xmm0
; AVX-NEXT:    vmovd %xmm0, (%rdi)
; AVX-NEXT:    retq
  %t0 = fptosi <4 x float> %in to <4 x i32>
  %t1 = trunc <4 x i32> %t0 to <4 x i16>
  %t2 = shufflevector <4 x i16> %t1, <4 x i16> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %t3 = trunc <8 x i16> %t2 to <8 x i8>
  %t4 = shufflevector <8 x i8> %t3, <8 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %t5 = insertelement <4 x i8> %t4, i8 -1, i32 3
  store <4 x i8> %t5, ptr %out
  ret void
}

define <16 x i64> @catcat(<4 x i64> %x) {
; SSE-LABEL: catcat:
; SSE:       # %bb.0:
; SSE-NEXT:    movq %rdi, %rax
; SSE-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[0,1,0,1]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,2,3]
; SSE-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[0,1,0,1]
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE-NEXT:    movdqa %xmm1, 112(%rdi)
; SSE-NEXT:    movdqa %xmm1, 96(%rdi)
; SSE-NEXT:    movdqa %xmm3, 80(%rdi)
; SSE-NEXT:    movdqa %xmm3, 64(%rdi)
; SSE-NEXT:    movdqa %xmm0, 48(%rdi)
; SSE-NEXT:    movdqa %xmm0, 32(%rdi)
; SSE-NEXT:    movdqa %xmm2, 16(%rdi)
; SSE-NEXT:    movdqa %xmm2, (%rdi)
; SSE-NEXT:    retq
;
; AVX1-LABEL: catcat:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vshufps {{.*#+}} xmm1 = xmm0[0,1,0,1]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm1, %ymm4
; AVX1-NEXT:    vshufps {{.*#+}} xmm1 = xmm0[2,3,2,3]
; AVX1-NEXT:    vinsertf128 $1, %xmm1, %ymm1, %ymm1
; AVX1-NEXT:    vperm2f128 {{.*#+}} ymm0 = ymm0[2,3,2,3]
; AVX1-NEXT:    vmovddup {{.*#+}} ymm2 = ymm0[0,0,2,2]
; AVX1-NEXT:    vshufpd {{.*#+}} ymm3 = ymm0[1,1,3,3]
; AVX1-NEXT:    vmovaps %ymm4, %ymm0
; AVX1-NEXT:    retq
;
; AVX2-LABEL: catcat:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpermpd {{.*#+}} ymm1 = ymm0[1,1,1,1]
; AVX2-NEXT:    vpermpd {{.*#+}} ymm2 = ymm0[2,2,2,2]
; AVX2-NEXT:    vpermpd {{.*#+}} ymm3 = ymm0[3,3,3,3]
; AVX2-NEXT:    vbroadcastsd %xmm0, %ymm0
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: catcat:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    # kill: def $ymm0 killed $ymm0 def $zmm0
; AVX512F-NEXT:    vpmovsxbq {{.*#+}} zmm1 = [0,0,0,0,1,1,1,1]
; AVX512F-NEXT:    vpermpd %zmm0, %zmm1, %zmm2
; AVX512F-NEXT:    vpmovsxbq {{.*#+}} zmm1 = [2,2,2,2,3,3,3,3]
; AVX512F-NEXT:    vpermpd %zmm0, %zmm1, %zmm1
; AVX512F-NEXT:    vmovaps %zmm2, %zmm0
; AVX512F-NEXT:    retq
  %cat1 = shufflevector <4 x i64> %x, <4 x i64> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
  %cat2 = shufflevector <8 x i64> %cat1, <8 x i64> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %r = shufflevector <16 x i64> %cat2, <16 x i64> undef, <16 x i32> <i32 0, i32 4, i32 8, i32 12, i32 1, i32 5, i32 9, i32 13, i32 2, i32 6, i32 10, i32 14, i32 3, i32 7, i32 11, i32 15>
  ret  <16 x i64> %r
}

define <16 x i64> @load_catcat(ptr %p) {
; SSE-LABEL: load_catcat:
; SSE:       # %bb.0:
; SSE-NEXT:    movq %rdi, %rax
; SSE-NEXT:    movdqa (%rsi), %xmm0
; SSE-NEXT:    movdqa 16(%rsi), %xmm1
; SSE-NEXT:    pshufd {{.*#+}} xmm2 = xmm0[0,1,0,1]
; SSE-NEXT:    pshufd {{.*#+}} xmm0 = xmm0[2,3,2,3]
; SSE-NEXT:    pshufd {{.*#+}} xmm3 = xmm1[0,1,0,1]
; SSE-NEXT:    pshufd {{.*#+}} xmm1 = xmm1[2,3,2,3]
; SSE-NEXT:    movdqa %xmm1, 112(%rdi)
; SSE-NEXT:    movdqa %xmm1, 96(%rdi)
; SSE-NEXT:    movdqa %xmm3, 80(%rdi)
; SSE-NEXT:    movdqa %xmm3, 64(%rdi)
; SSE-NEXT:    movdqa %xmm0, 48(%rdi)
; SSE-NEXT:    movdqa %xmm0, 32(%rdi)
; SSE-NEXT:    movdqa %xmm2, 16(%rdi)
; SSE-NEXT:    movdqa %xmm2, (%rdi)
; SSE-NEXT:    retq
;
; AVX1-LABEL: load_catcat:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vbroadcastsd (%rdi), %ymm0
; AVX1-NEXT:    vbroadcastsd 8(%rdi), %ymm1
; AVX1-NEXT:    vbroadcastsd 16(%rdi), %ymm2
; AVX1-NEXT:    vbroadcastsd 24(%rdi), %ymm3
; AVX1-NEXT:    retq
;
; AVX2-LABEL: load_catcat:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vbroadcastsd (%rdi), %ymm0
; AVX2-NEXT:    vbroadcastsd 8(%rdi), %ymm1
; AVX2-NEXT:    vbroadcastsd 16(%rdi), %ymm2
; AVX2-NEXT:    vbroadcastsd 24(%rdi), %ymm3
; AVX2-NEXT:    retq
;
; AVX512F-LABEL: load_catcat:
; AVX512F:       # %bb.0:
; AVX512F-NEXT:    vbroadcasti64x4 {{.*#+}} zmm1 = mem[0,1,2,3,0,1,2,3]
; AVX512F-NEXT:    vpmovsxbq {{.*#+}} zmm0 = [0,4,0,4,1,5,1,5]
; AVX512F-NEXT:    vpermq %zmm1, %zmm0, %zmm0
; AVX512F-NEXT:    vpmovsxbq {{.*#+}} zmm2 = [2,6,2,6,3,7,3,7]
; AVX512F-NEXT:    vpermq %zmm1, %zmm2, %zmm1
; AVX512F-NEXT:    retq
  %x = load <4 x i64>, ptr %p
  %cat1 = shufflevector <4 x i64> %x, <4 x i64> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 0, i32 1, i32 2, i32 3>
  %cat2 = shufflevector <8 x i64> %cat1, <8 x i64> undef, <16 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %r = shufflevector <16 x i64> %cat2, <16 x i64> undef, <16 x i32> <i32 0, i32 4, i32 8, i32 12, i32 1, i32 5, i32 9, i32 13, i32 2, i32 6, i32 10, i32 14, i32 3, i32 7, i32 11, i32 15>
  ret  <16 x i64> %r
}

; Use weird types to make sure we do not miscompile a case where
; the source ops are not an even multiple size of the result.

define <4 x i32> @cat_ext_straddle(ptr %px, ptr %py) {
; SSE-LABEL: cat_ext_straddle:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps 16(%rdi), %xmm0
; SSE-NEXT:    unpcklpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; SSE-NEXT:    retq
;
; AVX-LABEL: cat_ext_straddle:
; AVX:       # %bb.0:
; AVX-NEXT:    vmovaps 16(%rdi), %xmm0
; AVX-NEXT:    vunpcklpd {{.*#+}} xmm0 = xmm0[0],mem[0]
; AVX-NEXT:    retq
  %x = load <6 x i32>, ptr %px
  %y = load <6 x i32>, ptr %py
  %cat = shufflevector <6 x i32> %x, <6 x i32> %y, <12 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7, i32 8, i32 9, i32 10, i32 11>
  %ext = shufflevector <12 x i32> %cat, <12 x i32> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  ret <4 x i32> %ext
}
