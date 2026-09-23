function d = laplace_det(A)
% LAPLACE_DET  Determinant by cofactor expansion along the first row.
%   d = laplace_det(A) computes det(A) recursively, straight from the
%   textbook definition. Cost is O(n!) -- do not use for n much past 10.
%   Compare with det(A), which uses LU factorization at O(n^3).

n = size(A, 1);
if n == 1
    d = A(1, 1);
    return
end

d = 0;
for j = 1:n
    M = A(2:end, [1:j-1, j+1:n]);       % delete row 1 and column j
    d = d + (-1)^(1+j) * A(1, j) * laplace_det(M);
end
end
