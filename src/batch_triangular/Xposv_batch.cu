/**
 * @copyright (c) 2012- King Abdullah University of Science and
 *                      Technology (KAUST). All rights reserved.
 **/


/**
 * @file src/batch_triangular/Xpotrs_batch.cu

 * KBLAS is a high performance CUDA library for subset of BLAS
 *    and LAPACK routines optimized for NVIDIA GPUs.
 * KBLAS is provided by KAUST.
 *
 * @version 3.0.0
 * @author Ali Charara
 * @date 2018-11-14
 **/

#include <stdlib.h>
#include <stdio.h>
#include <cuda.h>
#include <cuda_runtime.h>
#include <cuda_runtime_api.h>
#include "cublas_v2.h"
#include <typeinfo>

#include "kblas.h"
#include "kblas_struct.h"
#include "kblas_operators.h"
#include "kblas_defs.h"
#include "kblas_common.h"
#include "workspace_queries.ch"

//==============================================================================================
#include "Xblas_core.ch"
#include "Xhelper_funcs.ch"
#include "Xposv_batch_drivers.cuh"

//==============================================================================================
//Non-Strided form

int Xposv_batch_offset( kblasHandle_t handle,
                        char side, char uplo,
                        const int m, const int n,
                        TYPE** A, int A_row_off, int A_col_off, int lda,
                        TYPE** B, int B_row_off, int B_col_off, int ldb,
                        int batchCount,
                        int *info_array)
{
  KBlasWorkspaceState ws_needed;
  posv_batch_wsquery_core<false>( m, n, side,
                                  batchCount,
                                  (kblasWorkspaceState_t)&ws_needed);

  if( !ws_needed.isSufficient( &(handle->work_space.allocated_ws_state) ) ){
    return KBLAS_InsufficientWorkspace;
  }

  return Xposv_batch_core<TYPE, TYPE**, false>(
                          handle,
                          side, uplo,
                          m, n,
                          (TYPE**)A, A_row_off, A_col_off, lda, (long)0,
                          (TYPE**)B, B_row_off, B_col_off, ldb, (long)0,
                          batchCount,
                          info_array);
}

// workspace needed: ??
// A, B: host pointer to array of device pointers to device buffers
int kblas_posv_batch( kblasHandle_t handle,
                      char side, char uplo,
                      const int m, const int n,
                      TYPE** A, int lda,
                      TYPE** B, int ldb,
                      int batchCount,
                      int *info_array)
{
  return Xposv_batch_offset(handle,
                            side, uplo,
                            m, n,
                            A, 0, 0, lda,
                            B, 0, 0, ldb,
                            batchCount,
                            info_array);
}


// workspace needed: ??
// A, B: host pointer to array of device pointers to device buffers
extern "C"
int kblasXposv_batch( kblasHandle_t handle,
                      char side, char uplo,
                      const int m, const int n,
                      TYPE** A, int lda,
                      TYPE** B, int ldb,
                      int batchCount,
                      int *info_array)
{
  return Xposv_batch_offset(handle,
                            side, uplo,
                            m, n,
                            A, 0, 0, lda,
                            B, 0, 0, ldb,
                            batchCount,
                            info_array);
}
//==============================================================================================
//Strided form


int Xposv_batch_offset( kblasHandle_t handle,
                        char side, char uplo,
                        const int m, const int n,
                        TYPE* A, int A_row_off, int A_col_off, int lda, long strideA,
                        TYPE* B, int B_row_off, int B_col_off, int ldb, long strideB,
                        int batchCount,
                        int *info_array)
{
  KBlasWorkspaceState ws_needed;
  posv_batch_wsquery_core<true>( m, n, side,
                                 batchCount,
                                 (kblasWorkspaceState_t)&ws_needed);

  if( !ws_needed.isSufficient( &(handle->work_space.allocated_ws_state) ) ){
    return KBLAS_InsufficientWorkspace;
  }

  return Xposv_batch_core<TYPE, TYPE*, true>(
                          handle,
                          side, uplo,
                          m, n,
                          (TYPE*)A, A_row_off, A_col_off, lda, strideA,
                          (TYPE*)B, B_row_off, B_col_off, ldb, strideB,
                          batchCount,
                          info_array);
}


// workspace needed: ??
// A, B: host pointer to array of device pointers to device buffers
int kblas_posv_batch( kblasHandle_t handle,
                      char side, char uplo,
                      const int m, const int n,
                      TYPE* A, int lda, long strideA,
                      TYPE* B, int ldb, long strideB,
                      int batchCount,
                      int *info_array)
{
  return Xposv_batch_offset(handle,
                            side, uplo,
                            m, n,
                            A, 0, 0, lda, strideA,
                            B, 0, 0, ldb, strideB,
                            batchCount,
                            info_array);
}


// workspace needed: device pointers
// A, B: host pointer to device buffers
extern "C"
int kblasXposv_batch_strided(kblasHandle_t handle,
                             char side, char uplo,
                             const int m, const int n,
                             TYPE* A, int lda, long strideA,
                             TYPE* B, int ldb, long strideB,
                             int batchCount,
                             int *info_array)
{
  return Xposv_batch_offset(handle,
                            side, uplo,
                            m, n,
                            A, 0, 0, lda, strideA,
                            B, 0, 0, ldb, strideB,
                            batchCount,
                            info_array);
}
