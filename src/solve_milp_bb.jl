
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
    upper_bound = Inf
    lower_bound = -Inf
    
    # Initialize tree

    root = Node(LP(q,A,l,u,n1,n2))
    solve!(root)
    iters = 0
    while !optimal(root)
        branch!(root)
        update_bounds!(root)
        iters += 1
    end
    
    return (; x1=root.x[1:n1], x2=root.x[n1+1:end]) 
end

struct LP
    q::Vector{Float64}
    A::Matrix{Float64}
    l::Vector{Float64}
    u::Vector{Float64}
    n1::Int
    n2::Int
end

mutable struct Node
    lp::LP
    lower_bound::Float64
    upper_bound::Float64
    x::Vector{Float64}
    solved::Bool
    children::Vector{Node}
    Node(lp::LP) = begin new(lp, -Inf, Inf, zeros(1), false, Node[]) end
end

function update_bounds!(node::Node; tol=1e-6)
    if !optimal(node) && length(node.children) > 0
        map(n->update_bounds!(n; tol), node.children)
        node.lower_bound = minimum(child.lower_bound for child in node.children if child.solved)
        favorite = argmin(collect(child.lower_bound for child in node.children if child.solved))
        node.upper_bound = minimum(child.upper_bound for child in node.children if child.solved)
        node.x = node.children[favorite].x
        return
    end
end

function optimal(node::Node; tol=1e-6)
    return isapprox(node.lower_bound, node.upper_bound; atol=tol)
end

function solve!(node::Node; tol=1e-6)
    if !node.solved
        model = OSQP.Model()
        OSQP.setup!(model; q=node.lp.q, A=sparse(node.lp.A), l=node.lp.l, u=node.lp.u, verbose=false, eps_abs=1e-8, eps_rel=1e-8, polish=true)
        res = OSQP.solve!(model)
        if res.info.status_val != 1
            node.lower_bound = node.upper_bound = Inf
        else
            node.lower_bound = res.info.obj_val
            node.x = res.x
            n1 = node.lp.n1
            n2 = node.lp.n2
            if isapprox(res.x[n1+1:n1+n2] .% 1, zeros(n2); atol=tol) # all integers
                node.upper_bound = res.info.obj_val
            end
        end
        node.solved = true
    end
end


function branch!(node::Node)
    is_leaf = length(node.children) == 0 && !optimal(node)
    if is_leaf # eligible for branching
        n1 = node.lp.n1
        n2 = node.lp.n2
        supposed_integers = node.x[n1+1:end]
        least_integral = n1+argmin( abs.( abs.(supposed_integers .% 1) .- 0.5 ) )
        ei = zeros(1,n1+n2)
        ei[least_integral] = 1.0
        A_new = [node.lp.A; ei]
        l_new_1 = [node.lp.l; -Inf]
        u_new_1 = [node.lp.u; floor(node.x[least_integral])]
        l_new_2 = [node.lp.l; ceil(node.x[least_integral])]
        u_new_2 = [node.lp.u; Inf]
        node1 = Node(LP(node.lp.q, A_new, l_new_1, u_new_1, n1, n2))
        node2 = Node(LP(node.lp.q, A_new, l_new_2, u_new_2, n1, n2))
        solve!(node1)
        solve!(node2)
        push!(node.children, node1)
        push!(node.children, node2)
        return true
    else
        if length(node.children) > 0
            if branch!(node.children[1])
                return true
            else
                return branch!(node.children[2])
            end
        else
            return false # did not branch because not a leaf node
        end
    end
end
