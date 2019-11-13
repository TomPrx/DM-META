include("src.jl")
#using Plots
using PyPlot

function z(x, cost)
    zsum =0
    for i in 1:length(x)
        zsum+= cost[i]*x[i]
    end
    return zsum
end

function swap(xCur,zCur,pack,nbPacked,nbUnpacked, full, cost,M)
    nbUnpackedRandom = nbUnpacked
    move = false
    m, n = size(M)
    rap = nbUnpacked / (nbPacked*n*n)
    prob = rap
    xSwap=xCur
    while !move && nbUnpackedRandom > 0 && nbPacked > 0
        rdmAdd = rand((nbPacked+1):(nbPacked+nbUnpackedRandom))
        obj = pack[rdmAdd]
        if (tryAdd(obj, full, M)) # on peut ajouter l'objet
            xSwap[obj] = 1
            zCur += cost[obj]
            move = true
            rdmDrop = rand(1:nbPacked)
            drop = pack[rdmDrop]
            xSwap[drop] = 0
            zCur=zCur-cost[drop]
            # on échange les objets du swap dans le pack
            tmp = pack[rdmDrop]
            pack[rdmDrop] = obj
            pack[rdmAdd] = tmp
            #mise a jour de full apres le drop
            for k=1:m
                if M[k, drop] == 1
                    full[k] = 0
                end
            end
            #mise a jour de full apres le add
            for j=1:m
                if M[j,obj] == 1
                    full[j] = 1
                end
            end
            move = true
        else
            # on place le dernier objet selectionne a la fin du tableau
            tmp = pack[nbPacked+nbUnpackedRandom]
            pack[nbPacked+nbUnpackedRandom] = pack[rdmAdd]
            pack[rdmAdd] = tmp
            nbUnpackedRandom -= 1
            prob = prob + rap*(nbUnpacked - nbUnpackedRandom)
            if ( rand() < prob)
                nbUnpackedRandom += 0
            end
        end
    end
    # si move = false, on n'a pas réussi à swap
    if (!move && nbPacked > 0)
        rdm = rand(1:nbPacked)
        drop = pack[rdm]
        xSwap[drop] = 0
        zCur -= cost[drop]
        tmp = pack[nbPacked]
        pack[nbPacked] = drop
        pack[rdm] = tmp
        nbPacked -= 1
        nbUnpacked += 1
        #mise a jour de full apres le drop
        for k=1:m
            if M[k, drop] == 1
                full[k] = 0
            end
        end
    end
    return xSwap, zCur, pack, nbPacked, nbUnpacked, full
end

function addOrElseDrop(xCur, zCur, pack, nbPacked, nbUnpacked, full, cost, M)
    m, n = size(M)
    rap = nbUnpacked / (nbPacked*n*n)
    prob = rap
    nbUnpackedRandom = nbUnpacked
    #nbPackedRandom = nbPacked
    move = false
    zPack=0
    addOrDrop = rand()
    for i in 1:nbPacked
        zPack=zPack+cost[pack[i]]
    end
    cpt = 0
    while !move && nbUnpackedRandom > 0
        cpt +=1
        rdm = rand((nbPacked+1):(nbPacked+nbUnpackedRandom))
        obj = pack[rdm]
        if (tryAdd(obj, full, M)) # on peut ajouter l'objet
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
            for j=1:m
                if M[j,obj] == 1
                    full[j] = 1
                end
            end
            move = true
        else
            # on place le dernier objet selectionne a la fin du tableau
            tmp = pack[nbPacked+nbUnpackedRandom]
            pack[nbPacked+nbUnpackedRandom] = pack[rdm]
            pack[rdm] = tmp
            nbUnpackedRandom -= 1
            prob = prob + rap*(nbUnpacked - nbUnpackedRandom)
            if ( rand() < prob)
                nbUnpackedRandom = 0
            end
        end
    end
    # si move = false, on a reussi à ajouter aucun objet
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
        #mise a jour de full apres le drop
        for k=1:m
            if M[k, obj] == 1
                full[k] = 0
            end
        end
    end
    return xCur, zCur, pack, nbPacked, nbUnpacked, full
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

function saMeta(x0, z0, t0, L, alpha, tmin, full, cost, M, nbRechauf,tRechauf, optimum, displayPlot)
    deb = time()
    move=1
    cptR=0
    xCur = deepcopy(x0)
    zCur = z0
    xBest = deepcopy(x0)
    zBest = z0
    t = t0
    plateau = 1
    packCur, nbPackedCur, nbUnpackedCur = packs(x0)
    allZ = []
    proba = []
    cpt = [0,0,0,0] # A++ A+ A- R
    iter = 0
    testx = []
    allSolutions = []
    bestSolutions = []
    allTemp = []
    while t > tmin
        iter += 1
        if move==1
            newX, newZ, newPack, nbPacked, nbUnpacked, newFull = addOrElseDrop(copy(xCur), zCur, copy(packCur), nbPackedCur, nbUnpackedCur, copy(full), cost, M)
            zPack=0
            for i in 1:nbPacked
                zPack=zPack+cost[newPack[i]]
            end
        end
        if move==2
            newX, newZ, newPack, nbPacked, nbUnpacked, newFull = swap(copy(xCur), zCur, copy(packCur), nbPackedCur, nbUnpackedCur, copy(full), cost, M)
            zPack=0
            for i in 1:nbPacked
                zPack=zPack+cost[newPack[i]]
            end
        end
        push!(allZ, newZ)
        delta = newZ - zCur
        if ((delta > 0) || (rand() < exp(delta/t))) #  cas (A+ ou A-)
            packCur=newPack
            nbPackedCur=nbPacked
            nbUnpackedCur=nbUnpacked
            xCur = newX
            zCur = newZ
            packCur = newPack
            full = newFull
            if (newZ > zBest) # cas A++
                xBest = newX
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
        push!(allSolutions, zCur)
        push!(bestSolutions, zBest)
        push!(allTemp, t)
        if (plateau == L)
            t = t*alpha
            plateau = 0
        end
        plateau += 1
        if (t<tmin && cptR<nbRechauf)
            println("réchauffe, on change de mouvement !")
            vanilla = time()
            println("zBest avant réchaud : ",zBest)
            t=tRechauf
            cptR+=1
            move=2
        end
    end
    ext = time()
    println(cpt)
    if (displayPlot)
        plotSa(iter, allSolutions, bestSolutions, allTemp, optimum)
    end
    vanilla = vanilla - deb
    ext = ext - deb
    println("Time au moment du réchaud : $(vanilla), Time après le réchaud : $(ext)")
    return xBest, zBest
end

function sa(t0, L, alpha, tmin, cost, M, optimum, displayPlot)
    z, x, full, pack = construct(cost, M)
    m, n = size(M)
    println("Construction : $(z)")
    sumz = 0
    for i in 1:n
        sumz += cost[i]*x[i]
    end
    println("Nombre d'objets : $(n)")
    println("Nombre de contraintes : $(m)")
    xBest, zBest = saMeta(x, z, t0, L, alpha, tmin, full, cost, M,1 ,floor(t0/10), optimum, displayPlot)
    sumz = 0
    println("zBest après le réchaud : $(zBest)")
    return xBest, zBest
end

function plotSa(iter, allSolutions, bestSolutions, allTemp, optimum)
    #Plot solutions
    figure("SaSolutions",figsize=(6,6))
    title("SA : allSolutions, bestSolutions, optimalSolution")
    xlabel("Itérations")
    ylabel("z")
    ylim(0, optimum+2)
    x=collect(1:iter)
    y=[]
    for i in 1:iter
        push!(y,optimum)
    end
    plot(x, allSolutions)
    plot(x, bestSolutions)
    plot(x, y)
    #Plot temperature
    figure("SaTemperature",figsize=(6,6))
    title("SA : temperature")
    xlabel("Itérations")
    ylabel("z")
    plot(x, allTemp)
end
