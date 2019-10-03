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

# =========================================================================== #

# Setting the data
fname = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data/didactic.dat"
#fname = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data/pb_1000rnd0700.dat"  # path for a standard config on macOS
cost, matrix = loadSPP(fname)

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
#target = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data"
target = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data"            # path for a standard config on macOS
fnames = getfname(target)
cd("..")
@time begin
z, x, full, pack= greedyRondomizedConstruction(0.7,cost, matrix)
end
println(z)

#
#@time begin
#    z, x, full, pack = amelioration(z, x, full, pack, matrix, 1)
#end
#println(z)

#@time begin
#    z, x, full, pack = amelioration(z, x, full, pack, matrix,2)
#end
#println(z)
