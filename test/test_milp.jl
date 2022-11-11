@testset "burrito jump" begin
    rng = MersenneTwister(10)
    N = 5
    M = 3
    f = 10.0
    r = 8.0
    k = 5.5

    sols = [[0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0],
            [0,1,1,0,0,1,0,0,1,0,0,1,0,1,0,0,1,0],
            [0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1],
            [0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0], 
            [1,0,0,1,0,0,1,0,0,1,0,0,1,0,0,1,0,0]]
    for i = 1:5
        ret = burrito_to_standard_form(10*rand(rng, N), rand(rng, N, M), f, r, k)
        opt = solve_milp_jump(ret...)
        @test opt.x2 ≈ sols[i]
    end
end

@testset "random milp jump" begin
    rng = MersenneTwister(10)
    sols = [[-1.8815098183869863, 5.0],
            [5.0, -5.0, -4.92078632925399, -2.0, 0.999999999999998, 5.0],
            [5.0, -5.0, 0.9122182091789625, -5.0, -5.0],
            [0.3774421219554629, 5.0],
            [2.465909319665757, -5.0, -5.0, -5.0, 5.0, -5.0]]

    for i = 1:5
        n1 = rand(rng, 1:3)
        n2 = rand(rng, 1:3)
        q = randn(rng, n1+n2)
        A = randn(rng, 1, n1+n2)
        A = [A; I(n1+n2)]
        l = [randn(rng, 1); -5*ones(n1+n2)]
        u = [l[1] .+ 3.0; 5*ones(n1+n2)]
        opt = solve_milp_jump(n1, n2, q, A, l, u)
        @test [opt.x1; opt.x2] ≈ sols[i]
    end
end

@testset "milp b&b" begin
    rng = MersenneTwister(4)
    for i = 1:5
        n1 = rand(rng, 1:3)
        n2 = rand(rng, 1:3)
        q = randn(rng, n1+n2)
        A = randn(rng, 1, n1+n2)
        A = [A; I(n1+n2)]
        l = [randn(rng, 1); -5*ones(n1+n2)]
        u = [l[1] .+ 3.0; 5*ones(n1+n2)]
        opt1 = solve_milp_jump(n1, n2, q, A, l, u)
        opt2 = solve_milp_bb(n1, n2, q, A, l, u)
        @test [opt1.x1; opt1.x2] ≈ [opt2.x1; opt2.x2]
    end
    
end
