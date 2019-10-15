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
include("experiment.jl")

# =========================================================================== #

# Setting the data
iname = "pb_1000rnd0300.dat"
fname1 = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/DM-META/Data/"
fname2 = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data/"
fname3 = "C:/Users/Théo/Documents/GitHub/DM-META/Data/"
fname4 = "/comptes/E165088T/Documents/TPinfo/Metaheuristiques/DM-META/Data/"
#fname = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data/pb_1000rnd0700.dat"  # path for a standard config on macOS
cost, matrix = loadSPP(string(fname4,iname))

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
fnames = getfname(target4)
cd("..")
@time begin
#z, x = greedyRandomizedConstruction(0.7,cost, matrix)
z1,x = reactiveGraspIter(100,cost,matrix)
z2,x = grasp(0.6, 33, cost, matrix)
end
println(z1)
println(z2)




