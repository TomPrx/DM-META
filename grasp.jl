function remove!(tab, e)
    new = Array{Int64}(undef,length(tab)-1)
    j= 1
    b = false
    for i=1:(length(tab))
        b = (tab[i]==e) || b
        if tab[i] != e && j <length(tab)
            new[j] = tab[i]
            j+=1
        end
    end
    if b
        return new
    else
        return tab
    end
end

function minMaxUtil(util, cand, nCand) # return the min and max utility of cand between 1and nCand
    # util[cand[1]] is the utility of the candidate 1
    min = util[cand[1]][1]
    max = util[cand[1]][1]
    for i = 2:nCand
        if min > util[cand[i]][1]
            min = util[cand[i]][1]
        end
        if max < util[cand[i]][1]
            max = util[cand[i]][1]
        end
    end
    return min, max
end

function buildRcl(util, cand, nCand, limit) # Return the rcl from the utilities of the candidates between and the limit
# cand[1] and cand[nCand]
    rcl = []
    for i=1:nCand
        if util[cand[i]][1] >= limit
            push!(rcl, cand[i])
        end
    end
    return rcl
end

function randomSelect(rcl)
    return rcl[rand(1:(length(rcl)),1)[1]]
end

function grasp(alpha, nIter, cost, M)

    for i=1:nIter 
        z, x = greedyRandomizedConstruction(alpha, cost, u, M)
        newz, newx = localSearchImprovement(z, x, cost, M)
    end
    return newz, newx
end


function greedyRondomizedConstruction(alpha, cost, M,non)
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
        z+= cost[e]
        #update candidates
        candidates = remove!(candidates,e)
        
    end
end

function calculUtil(cost, M)
    m,n=size(M)
    occ= zeros(n)
    for i=1:n
        for j=1:m
            occ[i]+= M[j,i]
        end
    end
    u= Array{Tuple{Float64,Int64}}(undef,n)
    for i=1:n
        u[i]= (cost[i] / occ[i], i)
    end
    return u
end

function greedyRondomizedConstruction(alpha, cost, M)
    m, n = size(M)
    cand = Array{Int64}(undef,n) # liste des candidats, on s'interesse à ceux entre 1 et nCand
    # initialisation de cand
    for i=1:n
        cand[i]= i
    end
    nCand = n # nombre de candidats à regarder
    z = 0 # initialisation de la fonction objectif
    x = zeros(n) # initialisation des objets
    util = calculUtil(cost, M)
    while nCand > 0   

        #Build RCL, the restricted candidate list      
        min, max = minMaxUtil(util, cand, nCand)
        print(min,max,alpha)
        limit= min + alpha* (max - min)
        rcl = buildRcl(util, cand, nCand, limit)

        # Select an element e from the RCL at random
        elem = randomSelect(rcl)

        # Incorporate e into the solution
        x[elem] = 1
        z+= cost[elem]
        
        # Update the candidate set C
        i= 1
        while cand[i] != elem
            i+= 1
        end
        tmp = cand[i]
        cand[i] = cand[nCand]
        cand[nCand] = tmp
        nCand = nCand - 1

        # parcourt des contraintes dans la colonne de l'objet ajoute
        for i=1:m 
            # test si l'objet ajoute apparait dans la contrainte
            if M[i,elem] == 1
                # parcourt des objets d'une contrainte (si l'objet ajoute apparait)
                for j=1:n 
                    if M[i,j] == 1
                        # on retire l'objet j des candidats
                        k= 1
                        while cand[k] != j && k <= nCand
                            k+= 1
                        end
                        if k <= nCand # vrai si l'objet n'a pas deja ete enleve
                            tmp = cand[k]
                            cand[k] = cand[nCand]
                            cand[nCand] = tmp
                            nCand = nCand - 1
                        end
                    end
                end            
            end
        end
    end
end
