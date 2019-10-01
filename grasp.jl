include "src.jl"

function grasp(alpha, nIter, cost, M)

    for i=1:nIter 
        z, x = greedyRandomizedConstruction(alpha, cost, u, M)
        newz, newx = localSearchImprovement(z, x, cost, M)
    end
    return newz, newx
end

function greedyRondomizedConstruction(alpha, cost, M)
    candidates = Array{Int64}(undef,n)
    for i=1:n
        candidates[i]= i
    end
    for i=1:n
        for j=1:m
            occ[i]+= B[j,i]
        end
    end
    utility= Array{Tuple{Float64,Int64}}(undef,n)
    for i=1:n
        utility[i]= (cost[i] / occ[i], i)
    end
    sort!(utility, rev=true)    
    m, n = size(M)
    z= 0 
    x= zeros(n)

    while length(candidates) > 0
        max = utility[1][1]
        min = utility[length(utility)][1]
        limit= min + alpha* (max - min)
        i= 1
        rcl = []
        while utility[i][1] >= limit 
            push!(rcl, utility[i][2]) 
            i+= 1
        end
        e= rcl[rand(1:(length(rcl)),1)[1]]
        x[e]= 1
        z+= cost(e)
        #update candidates
        
    end
