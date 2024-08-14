#include <iostream>
#include <iomanip>
#include <cstdlib>
#include <ctime>
using namespace std;

__global__ void addKernel(int *dev_c, const int *dev_a, const int *dev_b){
    int a_idx = threadIdx.y * blockDim.x;
    int b_idx = threadIdx.x;
    int c_idx = a_idx + b_idx;
    int sum = 0;

    for(int i = 0; i < blockDim.x; i++, a_idx++, b_idx += blockDim.x)
        sum += dev_a[a_idx] * dev_b[b_idx]; 
    dev_c[c_idx] = sum;

    return;
}

int main(void){
    const int WIDTH = 5;
    int a[WIDTH][WIDTH], b[WIDTH][WIDTH], c[WIDTH][WIDTH];
    int *dev_a, *dev_b, *dev_c;

    srand((unsigned int)time(NULL));

    for(int i = 0; i < WIDTH; i++){
        for(int j = 0; j < WIDTH; j++){
            a[i][j] = rand() % 10;
            b[i][j] = rand() % 10;
        }
    }

    cudaMalloc((void **)&dev_a, WIDTH * WIDTH * sizeof(int));
    cudaMalloc((void **)&dev_b, WIDTH * WIDTH * sizeof(int));
    cudaMalloc((void **)&dev_c, WIDTH * WIDTH * sizeof(int));

    cudaMemcpy((void *)dev_a, (void *)a, WIDTH * WIDTH * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy((void *)dev_b, (void *)b, WIDTH * WIDTH * sizeof(int), cudaMemcpyHostToDevice);

    dim3 DimBlock(WIDTH, WIDTH);
    addKernel<<<1, DimBlock>>> (dev_c, dev_a, dev_b);

    cudaMemcpy((void *)c, (void *)dev_c, WIDTH * WIDTH * sizeof(int), cudaMemcpyDeviceToHost);

    cout << "Matrix Multiplication" << endl;
    for(int i = 0; i < WIDTH; i++){
        for(int j = 0; j < WIDTH; j++)  cout << setw(4) << a[i][j];
        (i == WIDTH / 2) ? cout << "  *" : cout << "   ";

        for(int j = 0; j < WIDTH; j++)  cout << setw(4) << b[i][j];
        (i == WIDTH / 2) ? cout << "  =" : cout << "   ";

        for(int j = 0; j < WIDTH; j++)  cout << setw(4) << c[i][j];
        cout << endl;
    }

    cudaFree(dev_a);
    cudaFree(dev_b);
    cudaFree(dev_c);
}