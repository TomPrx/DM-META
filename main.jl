# =========================================================================== #
# Compliant julia 1.x

# Using the following packages
using JuMP, GLPK
using LinearAlgebra

include("loadSPP.jl")
include("setSPP.jl")
include("getfname.jl")
include("src.jl")

# =========================================================================== #

# Setting the data
fname = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data/pb_1000rnd0700.dat"  # path for a standard config on macOS
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
target = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data"            # path for a standard config on macOS
fnames = getfname(target)

@time begin
z, x, full, pack= construct(cost, matrix)
end
println(z)

@time begin
    z, x, full, pack = amelioration(z, x, full, pack, matrix, 1)
end
println(z)

@time begin
    z, x, full, pack = amelioration(z, x, full, pack, matrix,2)
end
println(z)
