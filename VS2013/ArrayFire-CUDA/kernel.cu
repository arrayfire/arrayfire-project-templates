#include <arrayfire.h>

using namespace af;

#include <stdio.h>

#define divup(x,y) (x%y) ? ((x+y-1)/y) : (x/y)

#define CUDA(call) do {                                         \
        cudaError_t _e = (call);                                \
        if (_e == cudaSuccess) break;                           \
        fprintf(stderr, __FILE__":%d: cuda error: %s (%d)\n",   \
                __LINE__, cudaGetErrorString(_e), _e);          \
        exit(-1);                                               \
        } while (0)


// generate millions of random elements
static int elements = 1e5;

static int reduction_cpu(const int *input)
{
    int sum = 0;
    for (int i = 0; i < elements; ++i) {
        sum += input[i];
    }
    return sum;
}

static int reduction_af(const array input)
{
    return sum<int>(input);
}

__global__ void reduction_kernel(int *d_odata, const int *d_idata, const int n)
{
    extern __shared__ int smem[];
    smem[threadIdx.x] = 0;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n)
        smem[threadIdx.x] = d_idata[idx];
    __syncthreads();
    for (int c = blockDim.x / 2; c > 0; c /= 2)
    {
        if (threadIdx.x < c)
            smem[threadIdx.x] += smem[threadIdx.x + c];
        __syncthreads();
    }
    if (threadIdx.x == 0)
        d_odata[blockIdx.x] = smem[0];
}

static int reduction_cuda(const int *d_idata)
{
    // TODO determine numBlocks and numThreads
    int numThreads = 512;
    int numBlocks = divup(elements, numThreads);

    // allocate device memory and data
    int *d_odata = NULL;
    CUDA(cudaMalloc((void **)&d_odata, numBlocks*sizeof(int)));

    // Call your reduce kernel(s) with the right parameters
    // INPUT:       d_idata
    // OUTPUT:      d_odata
    // (1) reduce across all elements
    reduction_kernel << <numBlocks, numThreads, sizeof(int) * numThreads >> >(d_odata, d_idata, elements);
    CUDA(cudaDeviceSynchronize());
    // (2) reduce across all blocks
    int gpu_result = 0;
    size_t block_bytes = numBlocks * sizeof(int);
    int *h_blocks = (int *)malloc(block_bytes);
    CUDA(cudaMemcpy(h_blocks, d_odata, block_bytes, cudaMemcpyDeviceToHost));
    for (int i = 0; i < numBlocks; ++i)
        gpu_result += h_blocks[i];

    // cleanup
    CUDA(cudaFree(d_odata));
    free(h_blocks);

    return gpu_result;
}

int main(int argc, char* argv[])
{
    try {
        // perform timings and calculate error from reference PI
        info();

        // Create random array on device
        array input = (randu(elements) * 100).as(s32);

        // Do redution using ArrayFire
        int sum_af = reduction_af(input);
        printf("arrayfire result = %d\n", sum_af);

        // Copy device array to host and get a pointer
        std::vector<int> h_input(input.elements());
        input.host(&h_input.front());
        // Do reduction using CPU
        int sum_cpu = reduction_cpu(&h_input.front());
        printf("cpu result       = %d\n", sum_cpu);

        // Get device pointer. No copy
        int *d_input = input.device<int>();
        // Do reduction on CUDA
        int sum_cuda = reduction_cuda(d_input);
        printf("cuda result      = %d\n", sum_cuda);
    }
    catch (af::exception& e) {
        fprintf(stderr, "%s\n", e.what());
        throw;
    }

#ifdef WIN32 // pause in Windows
    if (!(argc == 2 && argv[1][0] == '-')) {
        printf("hit [enter]...");
        getchar();
    }
#endif
    return 0;
}