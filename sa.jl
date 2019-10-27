include("src.jl")


function canAdd(obj, xCur, M) # return true if we can add obj to xCur, false otherwise
    m, n = size(M)
    res = true
    i = 1

    while res && i <= m
        if (M[i, obj] == 1)
            j = 1
            while res && j <= n
                res = (M[i,j]*xCur[j] == 0)
                j += 1
            end
        end
        i += 1
    end
    return res
end

function z(x, cost)
    zsum =0
    for i in 1:length(x)
        zsum+= cost[i]*x[i]
    end
    return zsum
end

function swap(xCur,zCur,pack,nbPacked,nbUnpacked,cost,M)
    nbUnpackedRandom = nbUnpacked
    move = false
    print(nbPacked,"    ",nbUnpacked)
    while !move && nbUnpackedRandom > 0
        rdmAdd = rand((nbPacked+1):(nbPacked+nbUnpackedRandom))
        rdmDrop = rand(1:nbPacked)
        print(rdmAdd)
        print(rdmDrop)
        obj = pack[rdmAdd]
        drop = pack[rdmDrop]
        xSwap=deepcopy(xCur)
        xSwap[drop] = 0
        zSwap=zCur-cost[drop]
        if (canAdd(obj, xSwap, M)) # on peut ajouter l'objet
            #println("add")
            xSwap[obj] = 1
            zSwap += cost[obj]
            move = true
            # on échange les objets du swap dans le pack
            tmp = pack[rdmDrop]
            pack[rdmDrop] = obj
            pack[rdmAdd] = tmp
            move = true
            xCur=deepcopy(xSwap)
            zCur=zSwap
        else
            # on place le dernier objet selectionne a la fin du tableau
            tmp = pack[nbPacked+nbUnpackedRandom]
            pack[nbPacked+nbUnpackedRandom] = pack[rdmAdd]
            pack[rdmAdd] = tmp
            nbUnpackedRandom -= 1
        end
    end
    # si move = false, on n'a pas réussi à swap
    if (!move && nbPacked > 0)
        #println("drop")
        rdm = rand(1:nbPacked)
        obj = pack[rdm]
        xCur[obj] = 0
        zCur -= cost[obj]
        tmp = pack[nbPacked]
        pack[nbPacked] = obj
        pack[rdm] = tmp
        nbPacked -= 1
        nbUnpacked += 1
    end
    return deepcopy(xCur), zCur, deepcopy(pack), nbPacked, nbUnpacked
end

function addOrElseDrop(xCur, zCur, pack, nbPacked, nbUnpacked, cost, M)
    nbUnpackedRandom = nbUnpacked
    #nbPackedRandom = nbPacked
    move = false
    while !move && nbUnpackedRandom > 0
        rdm = rand((nbPacked+1):(nbPacked+nbUnpackedRandom))
        obj = pack[rdm]
        if (canAdd(obj, xCur, M)) # on peut ajouter l'objet
            #println("add")
            xCur[obj] = 1
            zCur += cost[obj]
            move = true
            # on ajoute l'objet à ceux qui sont packed
            tmp = pack[nbPacked+1]
            pack[nbPacked+1] = obj
            # on met à jour la taille du pack
            nbPacked += 1
            nbUnpacked -= 1
            pack[rdm] = tmp
            move = true
        else
            # on place le dernier objet selectionne a la fin du tableau
            tmp = pack[nbPacked+nbUnpackedRandom]
            pack[nbPacked+nbUnpackedRandom] = pack[rdm]
            pack[rdm] = tmp
            nbUnpackedRandom -= 1
        end
    end
    # si move = false, on n'a reussi à ajouter aucun objet
    if (!move && nbPacked > 0)
        #println("drop")
        rdm = rand(1:nbPacked)
        obj = pack[rdm]
        xCur[obj] = 0
        zCur -= cost[obj]
        tmp = pack[nbPacked]
        pack[nbPacked] = obj
        pack[rdm] = tmp
        nbPacked -= 1
        nbUnpacked += 1
    end
    return deepcopy(xCur), zCur, deepcopy(pack), nbPacked, nbUnpacked
end

function packs(x) # crée un tableau où
    # les nbPacked 1er objets sont ceux pour lesquels x[i] = 1
    # les nbUnpacked suivants sont ceux pour lesquels x[i] = 0
    packed = []
    unpacked = []
    for i in 1:length(x)
        if (x[i] == 1)
            push!(packed,i)
        else
            push!(unpacked,i)
        end
    end
    nbPacked = length(packed)
    nbUnpacked = length(unpacked)
    packed = append!(packed, unpacked)
    return packed, nbPacked, nbUnpacked
end

function saMeta(x0, z0, t0, L, alpha, tmin, cost, M, nbRechauf,tRechauf)
    move=2
    cptR=0
    xCur = deepcopy(x0)
    zCur = z0
    xBest = deepcopy(x0)
    zBest = z0
    t = t0
    plateau = 1
    pack, nbPacked, nbUnpacked = packs(x0)
    allZ = []
    proba = []
    cpt = [0,0,0,0] # A++ A+ A- R
    iter = 0
    testx = []
    while t > tmin
        iter += 1
        if move==1
            newX, newZ, pack, nbPacked, nbUnpacked = addOrElseDrop(copy(xCur), copy(zCur), copy(pack), nbPacked, nbUnpacked, cost, M)
        end
        if move==2
            newX, newZ, pack, nbPacked, nbUnpacked = swap(copy(xCur), copy(zCur), copy(pack), nbPacked, nbUnpacked, cost, M)
        end
        push!(allZ, newZ)
        delta = newZ - zCur
        if iter == 1
            println("delta : $(delta)")
            println("newZ : $newZ")
            println("zCur : $(zCur)")
            push!(testx, zCur - z(xCur,cost))
        end
        if ((delta > 0) || (rand() < exp(delta/t))) #  cas (A+ ou A-)
            xCur = deepcopy(newX)
            zCur = newZ
            if (newZ > zBest) # cas A++
                xBest = deepcopy(newX)
                zBest = newZ
                cpt[1] += 1
            else
                if (delta > 0 ) #cas A+
                    cpt[2] += 1
                else # cas A-
                    cpt[3] += 1
                    push!(proba, exp(delta/t))
                end
            end
        else # cas R
            cpt[4] += 1
        end
        if (plateau == L)
            t = t*alpha
            plateau = 0
        end
        plateau += 1
        if (t<tmin && cptR<nbRechauf)
            t=tRechauf
            cptR+=1
            move=2
        end
    end
    #println(allZ)
    println(cpt)
    println(allZ[1])
    println(sum(proba)/length(proba))
    return xBest, zBest
end

function sa(t0, L, alpha, tmin, cost, M)
    z, x, full, pack = construct(cost, M)
    m, n = size(M)
    packed = sum(x)
    println("Construction : $(z)")
    sumz = 0
    for i in 1:n
        sumz += cost[i]*x[i]
    end
    println("Construction : $(sumz)")
    println("Nombre d'objets : $(n)")
    println("Nombre de contraintes : $(m)")
    println("Nombre d'objets packed : $(packed)")
    xBest, zBest = saMeta(x, z, t0, L, alpha, tmin, cost, M,1,100)
    sumz = 0
    for i in 1:n
        sumz += cost[i]*xBest[i]
    end
    println("SA : $(zBest)")
    println("SA : $(sumz)")
    packed = sum(xBest)
    println("Nombre d'objets packed : $(packed)")
end

function test()
    A = [0 1 0 0; 1 0 1 0; 1 0 0 1; 1 0 0 0]
    x = [0, 0, 0, 1]
    println(canAdd(1, x, A))
    println(canAdd(2, x, A))
    println(canAdd(3, x, A))
    println(canAdd(4, x, A))
end
