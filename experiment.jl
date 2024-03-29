# --------------------------------------------------------------------------- #
# Perform a numerical experiment (with a fake version of GRASP-SPP)

include("grasp.jl")

function graspSPP(fname, alpha, nbIterationGrasp, cost, M)

    zconstruction = zeros(Int64,nbIterationGrasp)
    zamelioration = zeros(Int64,nbIterationGrasp)
    zbest = zeros(Int64,nbIterationGrasp)
    zbetter=0
    move= 1

    for i=1:nbIterationGrasp
        z, x, full, pack = greedyRandomizedConstruction(alpha, cost, M)
        zconstruction[i] = z # # livrable du DM2
        zb, xb, full, pack = amelioration(z, x, full, pack, cost, M, move)
        zamelioration[i] = zb # livrable du DM2
        println(z - zb)
        zbetter = max(zbetter, zamelioration[i])
        zbest[i] = zbetter
    end
    return zconstruction, zamelioration, zbest
end

function plotRunGrasp(iname,zinit, zls, zbest)
    figure("Examen d'un run",figsize=(6,6)) # Create a new figure
    title("GRASP-SPP | \$z_{Init}\$  \$z_{LS}\$  \$z_{Best}\$ | " * iname)
    xlabel("Itérations")
    ylabel("valeurs de z(x)")
    ylim(0, maximum(zbest)+2)

    nPoint = length(zinit)
    x=collect(1:nPoint)
    xticks([1,convert(Int64,ceil(nPoint/4)),convert(Int64,ceil(nPoint/2)), convert(Int64,ceil(nPoint/4*3)),nPoint])
    plot(x,zbest, linewidth=2.0, color="green", label="meilleures solutions")
    plot(x,zls,ls="",marker="^",ms=2,color="green",label="toutes solutions améliorées")
    plot(x,zinit,ls="",marker=".",ms=2,color="red",label="toutes solutions construites")
    vlines(x, zinit, zls, linewidth=0.5)
    legend(loc=4, fontsize ="small")
end

function plotAnalyseGrasp(iname, x, zmoy, zmin, zmax)
    figure("bilan tous runs",figsize=(6,6)) # Create a new figure
    title("GRASP-SPP | \$z_{min}\$  \$z_{moy}\$  \$z_{max}\$ | " * iname)
    xlabel("Itérations (pour nbRunGrasp)")
    ylabel("valeurs de z(x)")
    ylim(0, zmax[end]+2)

    nPoint = length(x)
    intervalle = [reshape(zmoy,(1,nPoint)) - reshape(zmin,(1,nPoint)) ; reshape(zmax,(1, nPoint))-reshape(zmoy,(1,nPoint))]
    xticks(x)
    errorbar(x,zmoy,intervalle,lw=1, color="black", label="zMin zMax")
    plot(x,zmoy,linestyle="-", marker="o", ms=4, color="green", label="zMoy")
    legend(loc=4, fontsize ="small")
end

function plotCPUt(allinstance, tmoy)
    figure("bilan CPUt tous runs",figsize=(6,6)) # Create a new figure
    title("GRASP-SPP | tMoy")
    ylabel("CPUt moyen (s)")

    xticks(collect(1:length(allinstance)), allinstance, rotation=60, ha="right")
    margins(0.15)
    subplots_adjust(bottom=0.15,left=0.21)
    plot(collect(1:length(allinstance)),tmoy,linestyle="--", lw=0.5, marker="o", ms=4, color="blue", label="tMoy")
    legend(loc=4, fontsize ="small")
end


# Simulation d'une experimentation numérique  --------------------------

#Pkg.add("PyPlot") # Mandatory before the first use of this package
using PyPlot

function simulation()
    #allinstance      =  ["pb_1000rnd0100.dat","pb_200rnd1500.dat", "pb_2000rnd0500.dat", "pb_100rnd1000.dat"]
    allinstance = ["didactic.dat", "pb_1000rnd0100.dat", "pb_100rnd0500.dat", "pb_2000rnd0100.dat", "pb_200rnd0100.dat",
                    "pb_2000rnd0700.dat", "pb_200rnd1300.dat", "pb_500rnd0100.dat", "pb_500rnd0700.dat", "pb_100rnd0100.dat", "pb_1000rnd0700.dat"]
    res = [30, 67, 639, 40, 416, 1004, 571, 323, 1141, 372, 2260]
    nbInstances       =  length(allinstance)
    nbRunGrasp        =  5   # nombre de fois que la resolution GRASP est repetee
    nbIterationGrasp  =  100  # nombre d'iteration que compte une resolution GRASP
    nbDivisionRun     =  10   # nombre de division que compte une resolution GRASP

    zinit = zeros(Int64, nbIterationGrasp) # zero
    zls   = zeros(Int64, nbIterationGrasp) # zero
    zbest = zeros(Int64, nbIterationGrasp) # zero

    x     = zeros(Int64, nbDivisionRun)
    zmax  = Matrix{Int64}(undef,nbInstances , nbDivisionRun); zmax[:] .= typemin(Int64)  # -Inf entier
    zmoy  = zeros(Float64, nbInstances, nbDivisionRun) # zero
    zmin  = Matrix{Int64}(undef,nbInstances , nbDivisionRun) ; zmin[:] .= typemax(Int64)  # +Inf entier
    tmoy  = zeros(Float64, nbInstances)  # zero

    # calcule la valeur du pas pour les divisions
    for division=1:nbDivisionRun
        x[division] = convert(Int64, ceil(nbIterationGrasp / nbDivisionRun * division))
    end

    println("Experimentation GRASP-SPP avec :")
    println("  nbInstances       = ", nbInstances)
    println("  nbRunGrasp        = ", nbRunGrasp)
    println("  nbIterationGrasp  = ", nbIterationGrasp)
    println("  nbDivisionRun     = ", nbDivisionRun)
    println(" ")
    cpt = 0
    fname1 = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/DM-META/Data/"
    # run non comptabilise (afin de produire le code compile)
    #graspSPP(allinstance[1], 0.85, 1, cost, M)
zbetter = zeros(nbInstances)
    for instance = 1:nbInstances
        # les instances sont traitees separement
        cost, M = loadSPP(string(fname1,allinstance[instance]))
        print("  ",allinstance[instance]," : ")
        for runGrasp = 1:nbRunGrasp
            # une instance sera resolue nbrungrasp fois

            start = time() # demarre le compteur de temps
            alpha = 0.2
            #zinit, zls, zbest = graspSPP(allinstance[instance], alpha, nbIterationGrasp, cost, M)
            zb, xb, zinit, zls, zbest, zsum = reactiveGraspIter(nbIterationGrasp, cost, M)
            zbetter[instance] = zb
            tutilise = time()-start # arrete et releve le compteur de temps
            cpt+=1; print(cpt%10)
            #println("zMoy")
            #println(zsum)
            println("zMoy%")
            println(zsum/zb*100)
            # mise a jour des resultats collectes
            for division=1:nbDivisionRun
                zmax[instance,division] = max(zbest[x[division]], zmax[instance,division])
                zmin[instance,division] = min(zbest[x[division]], zmin[instance,division])
                zmoy[instance,division] =  zbest[x[division]] + zmoy[instance,division]
            end #division
            tmoy[instance] = tmoy[instance] + tutilise

        end #run
        for division=1:nbDivisionRun
             zmoy[instance,division] =  zmoy[instance,division] /  nbRunGrasp
        end #division
        tmoy[instance] = tmoy[instance] / nbRunGrasp

    end #instance

    #Pkg.add("PyPlot") # Mandatory before the first use of this package
    println(" ");println("  Graphiques de synthese")
#    using PyPlot
    for i=1:nbInstances
    #plotRunGrasp(allinstance[i], zinit, zls, zbest)
    #plotAnalyseGrasp(allinstance[i], x, zmoy[i,:], zmin[i,:], zmax[i,:] )
end
        zperc = zeros(nbInstances)
        for i=1:nbInstances
            zperc[i]=zmoy[i,1]
            for j=1:nbDivisionRun
                if (zperc[i] < zmoy[i,j])
                    zperc[i] = zmoy[i,j]
                end
            end
            zperc[i] = zperc[i]/res[i]
        end
        println(" ")
        println("zmoy")
        println(zmoy)
        println("tmoy")
        println(tmoy)
        println("zperc")
        println(zperc)
    plotCPUt(allinstance, tmoy)
end
