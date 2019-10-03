# --------------------------------------------------------------------------- #

# construit la solution x0 à partir de cout des objets et de la matrice des contraintes
function construct(cost, M)
    m, n = size(M)
    full= zeros(Int64,m)
    pack = [] #stock les indices des objets dans le pack
    occ= zeros(n)
    z= 0
    x= zeros(n)
    # Calcul utilite
    for i=1:n
        for j=1:m
            occ[i]+= M[j,i]
        end
    end
    u= Array{Tuple{Float64,Int64}}(undef,n)
    for i=1:n
        u[i]= (cost[i] / occ[i], i)
    end
    sort!(u, rev=true)
    #ajout 1er objet
    obj= u[1][2]
        x[obj]= 1
    push!(pack,obj)
    z+= cost[obj]

    for i=1:m
        full[i] = M[i,obj]
    end
    # Debut construction
    for i=2:n
        obj= u[i][2]
        b= true
        j= 1
        while b && j <= m
                b = !( (full[j] == 1) && (M[j,obj] == 1) )
                j+= 1
        end

        #Ajout de l'objet possible
        if b
            x[obj]= 1
            z+= cost[obj]
            push!(pack,obj)
            for j=1:m
                if M[j,obj] == 1
                    full[j] = 1
                end
            end
        end
    end
    return z, x, full, pack
end

# essaye d'ajouter l'objet toAdd dans x
function tryAdd(toAdd, z, x , full, pack, cost, M) # return true si on peut add toAdd dans le pack
    m, n= size(M)
    c= true
    k= 1
    while c && k <= m
        c= ! ( (full[k] == 1) && (M[k,toAdd] == 1) )
        k+= 1
    end
    return c
end

# explore le voisinage de la solution x en descente profonde avec un mouvement 1-1
# full : tableau pour savoir si une contrainte est pleine , pack : les objets actuellement dans le pack, z : la valeur actuelle de la fonction objectif
function OneOneMove(z, x , full, pack, cost, M)
    m, n= size(M)
    add = false #vrai si on peut ajouter un objet
    i= 1
    copy= full
    toAdd= 0
    toRemove = 0
    ind= 0
    while !add && i<= length(pack)
        ind= i
        toRemove= pack[i] #l'objet qu'on essaye de retirer
        full= deepcopy(copy)
        # Maj du tableau après avoir retire pack[i]
        for k=1:m
            if M[k, toRemove] == 1
                full[k] = 0
            end
        end
        j= 1
        while !add && j<= n #on choisit un objet qu'on essaye d'ajouter
            toAdd= j
            if x[toAdd] == 0 && (cost[toRemove] < cost[toAdd]) #l'objet n'est pas dans le pack et il a une meilleur valeur que celui que l'on retire
                add= tryAdd(j, z, x , full, pack, cost, M)
            end
            j+= 1
        end
        i+= 1
    end
    if add
        pack[ind] = toAdd
        x[toAdd]= 1
        x[toRemove]= 0
        z= z - cost[toRemove] + cost[toAdd]
        for j=1:m
            if M[j,toAdd] == 1
                full[j] = 1
            end
        end
    end
    return z, x, full, pack
end


function amelioration(z, x, full, pack, cost, M,move)
    m, n = size(M)
    #newz, x, full, pack= oneonemove2(z, x , full, pack, cost, M)
    if move==1
        println("Amélioration avec OneOneMove")
        newz, x, full, pack = OneOneMove(z, x , full, pack, cost, M)
    else
        println("Amélioration avec zero one")
        newz, x, full, pack = zerone(z, x , full, pack, cost, M)
    end
    println(newz)
    while (z < newz)
        z= newz
        #newz, x, full, pack= oneonemove2(z, x , full, pack, cost, M)
        if move==1
            println("Amélioration avec OneOneMove")
            newz, x, full, pack = OneOneMove(z, x , full, pack, cost, M)
        else
            println("Amélioration avec zero one")
            newz, x, full, pack = zerone(z, x , full, pack, cost, M)
        end
            println(newz)
    end
    return newz, x, full, pack
end

# explore le voisinage de la solution x en descente profonde avec un mouvement 0-1
function zerone(z,x,full,pack,cost,M)
    m,n=size(M)
    copy= full
    full= deepcopy(copy)
    add=false #vrai si on peut ajouter un objet
    j=1
    toAdd= 0
    ind= 0
    while !add && j<= n #on choisit un objet qu'on essaye d'ajouter
        toAdd= j
        if x[toAdd] == 0  #l'objet n'est pas dans le pack
            add= tryAdd(j, z, x , full, pack, cost, M)
        end
        j+= 1
    end
    if add
        push!(pack,toAdd)
        #pack[ind] = toAdd
        x[toAdd]= 1
        z= z + cost[toAdd]
        for j=1:m
            if M[j,toAdd] == 1
                full[j] = 1
            end
        end
    end
    return z, x, full, pack
end
