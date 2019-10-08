using StatsBase

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
        z, x = greedyRandomizedConstruction(alpha, cost, M)
        newz, newx = localSearchImprovement(z, x, cost, M)
    end
    return newz, newx
end

function reactiveGraspTime(nbSecondes, cost, M)
    alphaTab=[0.20,0.50,0.75,0.9,1.0]
    alphaIndice=collect(1:length(alphaTab))
    println(alphaIndice)
    alphaRand=rand(1:length(alphaTab)) #indice du alpha chosit aléatoirement
    alpha=alphaTab[alphaRand]
    zAvg=zeros(length(alphaTab)) # initialisation des moyennes à 0
    q=zeros(length(alphaTab)) # initialisation des qk
    p=[0.2,0.2,0.2,0.2,0.2] # initialisation des pk : probabilité pour chaque alpha
    move = 1
    debut=time()
    temps=0
    zmax = []
    zls = []
    zinit = []
    z, x, full, pack = greedyRandomizedConstruction(alpha, cost, M)
    push!(zinit, z)
    zbest, xbest, full, pack = amelioration(z, x, full, pack, cost, M, move)
    PireZ=z
    MeilleurZ=zbest
    zSomme=zeros(length(alphaTab))
    zAvg[alphaRand]=zbest # zAvg est égal aux différentes valeurs de z pour alpha k
    push!(zls, zbest)
    push!(zmax, zbest)
    Nalpha=0
    while temps < nbSecondes
        Nalpha=Nalpha+1
        if (Nalpha%20==0)
            println("////////////////////")
            println("probabilités !")
            println(p)
            qSomme=0
            println("Moyenne / CPT")
            for i in 1:length(alphaTab)
                average=zAvg[i]/zSomme[i]
                println(zAvg[i])
                println(zSomme)
                q[i]=(average-PireZ)/(MeilleurZ-PireZ)
                println(i)
                println("q")
                println(q)
                qSomme=qSomme+q[i]
            end
            println("SOMME DES Q")
            println(qSomme)
            for i in 1:length(alphaTab)
                p[i]=q[i]/qSomme
            end
            println("probabilités !")
            println(p)
            println(sum(p))
            alphaRand=sample(alphaIndice, Weights(p))
            alpha=alphaTab[alphaRand]
            println("Nouveau Alpha !")
            println(alpha)
        end
        alphaRand=sample(alphaIndice, Weights(p))
        alpha=alphaTab[alphaRand]
        z, x, full, pack = greedyRandomizedConstruction(alpha, cost, M)
        push!(zinit, z)
        newz, newx, full, pack = amelioration(z, x, full, pack, cost, M, move)
        if (z<PireZ)
            PireZ=z
        end
        zAvg[alphaRand]=zAvg[alphaRand]+newz # que l'on divisera plus tard par zSomme
        zSomme[alphaRand] += 1
        push!(zls, newz)
        if zbest < newz
            zbest = newz
            xbest = newx
            MeilleurZ=zbest
        end
        push!(zmax, zbest)
        maintenant=time()
        temps=maintenant-debut
    end
    return zbest, xbest, zinit, zls, zmax
end


function graspTime(alpha, nbSecondes, cost, M)
    move = 1
    debut=time()
    temps=0
    zmax = []
    zls = []
    zinit = []
    z, x, full, pack = greedyRandomizedConstruction(alpha, cost, M)
    push!(zinit, z)
    zbest, xbest, full, pack = amelioration(z, x, full, pack, cost, M, move)
    push!(zls, zbest)
    push!(zmax, zbest)
    while temps < nbSecondes
        z, x, full, pack = greedyRandomizedConstruction(alpha, cost, M)
        push!(zinit, z)
        newz, newx, full, pack = amelioration(z, x, full, pack, cost, M, move)
        println(newz - z)
        push!(zls, newz)
        if zbest < newz
            zbest = newz
            xbest = newx
        end
        push!(zmax, zbest)
        maintenant=time()
        temps=maintenant-debut
    end
    return zbest, xbest, zinit, zls, zmax
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

function greedyRandomizedConstruction(alpha, cost, M)
    #println("Construction")
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
    full= zeros(Int64,m)
    pack = []
    while nCand > 0

        #Build RCL, the restricted candidate list
        min, max = minMaxUtil(util, cand, nCand)
        limit= min + alpha* (max - min)
        rcl = buildRcl(util, cand, nCand, limit)

        # Select an element e from the RCL at random
        elem = randomSelect(rcl)

        # Incorporate e into the solution
        x[elem] = 1
        push!(pack,elem)
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
                full[i] = 1
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
    return z, x, full, pack
end
