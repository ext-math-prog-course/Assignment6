
"""
Use JuMP to solve the following MILP:

min         x'q
x₁ ∈ ℝⁿ¹
x₂ ∈ ℤⁿ²
x = [x₁; x₂]
s.t.        l ≤ Ax ≤ u

Returns named tuple (; x1, x2)
"""
function solve_milp_jump(n1, n2, q, A, l, u)
    model = Model(HiGHS.Optimizer)
    m = length(l)
    @variable(model, x1[1:n1])
    @variable(model, x2[1:n2], Int)
    @variable(model, l[i]≤s[i=1:m]≤u[i])
    @constraint(model, con, A*[x1;x2]-s .== 0)
    @objective(model, Min, q'*[x1; x2])
    optimize!(model)
    return (; x1=value.(x1), x2=value.(x2)) 
end

"""
Formulate the burrito optimization problem from class
into standard form. Specifically, find 
n1, n2, q, A, l, and u, such that the burrito
optimization problem is expressed as a problem
solvable by "solve_milp_jump".

Here n1 = 0, since all variables are integer variables.
The vector of variables should be assumed to be arranged
as the following (using variable names from lecture).
Note that m = number of truck locations
          n = number of buildings
This format will be required for testing purposes.
[ x₁ ... xₘ y₁₁ ... y₁ₘ y₂₁ ... y₂ₘ ... yₙₘ ]

returns named tuple (; n1, n2, q, A, l, u).
"""
function burrito_to_standard_form(d, α, f, r, k)
    n, m = size(α)
    num_vars = m*(n+1)
    A = spzeros((m+1)*n+num_vars, num_vars)
    for j = 1:m
        for i = 1:n
            A[(j-1)*n+i, j] = 1.0
            A[(j-1)*n+i, j+i*m] = -1.0
        end
    end
    for i = 1:n
        A[n*m+i,m*i+1:m*(i+1)] .= 1.0
    end
    A[(m+1)*n+1:end,:] = I(num_vars)
    u = [fill(Inf, n*m); ones(n); ones(num_vars)]
    l = [zeros(n*m); fill(-Inf, n); zeros(num_vars)]
    q = zeros(num_vars)
    q[1:m] .= -f
    for i = 1:n
        for j = 1:m
            q[i*m+j] = (r-k)*α[i,j]*d[i]
        end
    end
    q *= -1.0
    n1 = 0
    n2 = n*m+m
    return (; n1, n2, q, A, l, u)
end
