using RegLS
using Base.Test

srand(0)

m, n = 200, 500
r = 5
s = 0.1

B_orig = randn(m, r)*randn(r, n) + 0.1*randn(m, n)
M = rand(m, n);
M = 1.0*(M .<= s)
B = M.*B_orig
L = Ladj = X -> M.*X
g = IndBallRank(r)
x0 = zeros(m, n)
verb = 0
maxit = 10000
tol = 1e-6

@printf("Solving matrix completion (m = %d, n = %d)\n", m, n)

@time x_ista, info = solve(L, Ladj, B, g, x0, PG(verbose = verb, tol = tol))
@test info.iterations < maxit

@time x_zerofpr, info = solve(L, Ladj, B, g, x0, ZeroFPR(verbose = verb, tol = tol))
@test info.iterations < maxit