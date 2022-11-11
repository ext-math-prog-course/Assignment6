
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
    # todo 
    return (; x1=zeros(Float64, n1), x2=zeros(Int, n2)) 
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
    # todo, fix
    n1 = n2 = 0
    q = zeros(n1+n2)
    A = spzeros(0, n1+n2)
    l = zeros(0)
    u = zeros(0)
    return (; n1, n2, q, A, l, u)
end
