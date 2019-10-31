# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("src.jl")
include("grasp.jl")
include("sa.jl")
#include("experiment.jl")

# =========================================================================== #

# Setting the data
optimums = Dict(
"didactic" => 30,
"pb_1000rnd0100.dat" => 67,
"pb_100rnd0500.dat" => 639,
"pb_2000rnd0100.dat" => 40,
"pb_200rnd0100.dat" => 416,
"pb_2000rnd0700.dat" => 1811,
"pb_200rnd1300.dat" => 571,
"pb_500rnd0100.dat" => 323,
"pb_500rnd0700.dat" => 1141,
"pb_100rnd0100.dat" => 372,
"pb_1000rnd0700.dat" => 2260
)

iname = "pb_100rnd0100.dat"
optimum = optimums[iname]
fname1 = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/DM-META/Data/"
fname2 = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data/"
fname3 = "C:/Users/Théo/Documents/GitHub/DM-META/Data/"
fname4 = "/comptes/E165088T/Documents/TPinfo/Metaheuristiques/DM-META/Data/"
#fname = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data/pb_1000rnd0700.dat"  # path for a standard config on macOS
cost, matrix = loadSPP(string(fname1,iname))

#println("GLPK")
# Proceeding to the optimization
#solverSelected = GLPK.Optimizer
#ip, ip_x = setSPP(solverSelected, cost, matrix)
#println("Solving...");
#@time begin
#optimize!(ip)
#end

 #Displaying the results
#println("z  = ", objective_value(ip))
#print("x  = "); println(value.(ip_x))

#println("Jump")
# Proceeding to the optimization
#solverSelected = GLPK.Optimizer
#ip, ip_x = setSPP(solverSelected, cost, matrix)
#println("Solving...");
#@time begin
#optimize!(ip)
#end

 #Displaying the results

# =========================================================================== #

# Collecting the names of instances to solve
target1 = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/DM-META/Data"
target2 = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data"            # path for a standard config on macOS
target3 = "C:/Users/Théo/Documents/GitHub/DM-META/Data"
target4 = "/comptes/E165088T/Documents/TPinfo/Metaheuristiques/DM-META/Data"
fnames = getfname(target1)
cd("..")
#@time begin
#z, x = greedyRandomizedConstruction(0.7,cost, matrix)
#z,x, zinit, zls, zbest = reactiveGraspTime(0.2,cost,matrix)
#z,x, zinit, zls, zbest = graspTime(0.85,1,cost,matrix)
#end
#println(z)
#println(length(zinit))
#println(length(zbest))
#println(length(zls))
#simulation()
#plotRunGrasp(iname,zinit, zls, zbest)

#
#@time begin
#    z, x, full, pack = amelioration(z, x, full, pack, cost, matrix, 1)
#end
#println(z)

#@time begin
#    z, x, full, pack = amelioration(z, x, full, pack, cost, matrix,2)
#end
#println(z)

m, n = size(matrix)
@time begin
    t0 = 300; L = n*1.5; alpha= 0.95; tmin = 20
    sa(t0, L, alpha, tmin, cost, matrix, optimum)
end

println("TEST")
