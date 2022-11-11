
"""
Implement a Branch and Bound algorithm to solve MILPs of the following form:

min         x'q
x₁ ∈ ℝⁿ¹
x₂ ∈ ℤⁿ²
x = [x₁; x₂]
s.t.        l ≤ Ax ≤ u

Returns named tuple (; x1, x2)
"""
function solve_milp_bb(n1, n2, q, A, l, u)
    # TODO solve me 
    return (; x1=zeros(Float64, n1), x2=zeros(Int, n2)) 
end
