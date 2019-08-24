Note: I never got this working due to lack of time, but it does contain a reusable pattern/example for accessing a multi-dimensional array in assembly:


The logical representation of:
intMatrix = 
{
   {1, 2, 3, 4},
   {5, 6, 7, 8},
   {9, 10, 11, 12}
   {13, 14, 15, 16}
};

In ASM is:
intMatrix db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16

Assume intMatrix is at mem addr 0 and db width is 1
The formula for accessing sub-offsets is:

mem offset of intMatrix[f][x] =
memAddr(intMatrix) + (width(childArr) * f)  + (sizeof(db) * x)

intMatrix[0][3] = 0 + (4 * 0) + (1 * 3) = mem address offset 3

therefore (&intMatrix + 3) contains the starting addresss of the number 4


