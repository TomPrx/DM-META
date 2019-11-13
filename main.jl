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
"didactic.dat" => 30,
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
#iname = "pb_100rnd0100.dat"
iname = "pb_1000rnd0700.dat"
optimum = optimums[iname]
fname1 = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/DM-META/Data/"
fname2 = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data/"
fname3 = "C:/Users/Théo/Documents/GitHub/DM-META/Data/"
fname4 = "/comptes/E165088T/Documents/TPinfo/Metaheuristiques/DM-META/Data/"
#fname = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/solveSPPv2/Data/pb_1000rnd0700.dat"  # path for a standard config on macOS
cost, matrix = loadSPP(string(fname1,iname))

 #Displaying the results

# =========================================================================== #

# Collecting the names of instances to solve
target1 = "F:/Users/Utilisateur/Documents/TAF/M1/Métaheuristiques/DM/DM-META/Data"
target2 = "/comptes/E15H043L/Documents/M1/S1/Méta/DM2/DM-META/Data"            # path for a standard config on macOS
target3 = "C:/Users/Théo/Documents/GitHub/DM-META/Data"
target4 = "/comptes/E165088T/Documents/TPinfo/Metaheuristiques/DM-META/Data"
fnames = getfname(target1)
cd("..")

m, n = size(matrix)
t0 = 25; L = n; alpha= 0.95; tmin = 1; displayPlot = true
sa(t0, L, alpha, tmin, cost, matrix, optimum, displayPlot)
