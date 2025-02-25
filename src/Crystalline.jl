module Crystalline

# dependencies
using LinearAlgebra
using StaticArrays
using DelimitedFiles
using JLD2
using PrettyTables
using Combinatorics           # → `find_isomorphic_parent_pointgroup` in pointgroup.jl
using Requires
using Reexport
using DocStringExtensions
import Graphs

using Base: OneTo, @propagate_inbounds

import Base: getindex, setindex!,      # → iteration/AbstractArray interface
             IndexStyle, size, copy,   # ⤶
             iterate,
             string, isapprox, zero,
             readuntil, show, summary,
             *, +, -, ==, ImmutableDict,
             isone, one,
             convert, parent,
             position,                 # cf. https://github.com/JuliaLang/julia/issues/33799
             sort!
import LinearAlgebra: inv


# include submodules
include("SquareStaticMatrices.jl")
using .SquareStaticMatrices # exports `SSqMatrix{D,T}`

# include vendored SmithNormalForm.jl package from ../.vendor/
include("../.vendor/SmithNormalForm/src/SmithNormalForm.jl")
using .SmithNormalForm
import .SmithNormalForm: smith, Smith # TODO: remove explicit import when we update SmithNormalForm
export smith, Smith # export, so that loading Crystalline effectively also provides SmithNormalForm

@reexport using Bravais
import Bravais: primitivize, conventionalize, cartesianize, transform, centering
using Bravais: stack, all_centeringtranslations, centeringtranslation

# included files and exports
include("constants.jl")
export MAX_SGNUM, MAX_SUBGNUM, ENANTIOMORPHIC_PAIRS

include("utils.jl") # useful utility methods (seldom needs exporting)
export splice_kvpath, interpolate_kvpath

include("types.jl") # defines useful types for space group symmetry analysis
export SymOperation,                        # types
       DirectBasis, ReciprocalBasis,
       Reality, REAL, PSEUDOREAL, COMPLEX,
       MultTable, LGIrrep, PGIrrep,
       KVec, RVec,
       BandRep, BandRepSet,
       SpaceGroup, PointGroup, LittleGroup,
       CharacterTable,
       # operations on ...
       matrix, xyzt,                        # ::SymOperation
       getindex, rotation, translation, 
       issymmorph,
       num, order, operations,              # ::AbstractGroup
       klabel, characters,                  # ::AbstractIrrep
       classcharacters,
       label, reality, group,
       israyrep,                            # ::LGIrrep
       isspecial, translations,
       dim, parts,                          # ::KVec & RVec
       irreplabels, klabels,                # ::BandRep & ::BandRepSet 
       isspinful

include("show.jl") # custom printing for structs defined in src/types.jl

include("notation.jl")
export schoenflies, iuc, centering, seitz, mulliken

include("orders.jl")

include("symops.jl") # symmetry operations for space, plane, and line groups
export @S_str, spacegroup, compose,
       issymmorph, littlegroup, orbit,
       pointgroup,
       reduce_ops,
       issubgroup, isnormal,
       generate, generators

include("conjugacy.jl") # construction of conjugacy classes
export classes, is_abelian

include("wyckoff.jl") # wyckoff positions and site symmetry groups
export wyckoffs, WyckoffPosition,
       multiplicity,
       SiteGroup, sitegroup, cosets,
       findmaximal

include("symeigs2irrep.jl") # find irrep multiplicities from symmetry eigenvalue data
export find_representation

include("pointgroup.jl") # symmetry operations for crystallographic point groups
export pointgroup, pgirreps,
       PG_IUCs, find_isomorphic_parent_pointgroup

include("irreps_reality.jl")
export calc_reality, realify

# Large parts of the functionality in special_representation_domain_kpoints.jl should not be
# in the core module, but belongs in a build file or similar. For now, the main goal of the
# file hasn't been achieved and the other methods are non-essential. So, we skip it.
#= 
# TODO: The `const ΦNOTΩ_KVECS_AND_MAPS = _ΦnotΩ_kvecs_and_maps_imdict()` call takes 15 s
#       precompile. It is a fundamentally awful idea to do it this way.
using CSV                     # → special_representation_domain_kpoints.jl
include("special_representation_domain_kpoints.jl")
export ΦnotΩ_kvecs
=#

include("littlegroup_irreps.jl")
export lgirreps, littlegroups

include("lattices.jl")
export ModulatedFourierLattice,
       getcoefs, getorbits, levelsetlattice,
       modulate, normscale, normscale!

include("compatibility.jl")
export subduction_count

include("bandrep.jl")
export bandreps, matrix, classification, nontrivial_factors, basisdim

include("deprecations.jl")
export get_littlegroups, get_lgirreps, get_pgirreps, WyckPos, kvec, wyck, kstar

include("subperiodic.jl")
export SubperiodicGroup, subperiodicgroup

include("grouprelations/grouprelations.jl")
export maximal_subgroups, minimal_supergroups

# ---------------------------------------------------------------------------------------- #
# EXTENSIONS AND JLD-FILE INITIALIZATION
if !isdefined(Base, :get_extension)
    using Requires # load extensions via Requires.jl on Julia versions <v1.9
end

## __init__
# - open .jld2 data files, so we don't need to keep opening/closing them
# - optional code-loading, using Requires.

# store the opened jldfiles in `Ref{..}`s for type-stability's sake (need `Ref` since we
# need to mutate them in `__init__` but cannot use `global const` in a function, cf.
# https://github.com/JuliaLang/julia/issues/13817)
const LGIRREPS_JLDFILES = ntuple(_ -> Ref{JLD2.JLDFile{JLD2.MmapIO}}(), Val(3))
const LGS_JLDFILES      = ntuple(_ -> Ref{JLD2.JLDFile{JLD2.MmapIO}}(), Val(3))
const PGIRREPS_JLDFILE  = Ref{JLD2.JLDFile{JLD2.MmapIO}}()

const DATA_DIR = joinpath(dirname(@__DIR__), "data")

function __init__()
    # open `LGIrrep` and `LittleGroup` data files for read access on package load (this
    # saves a lot of time compared to `jldopen`ing each time we call e.g. `lgirreps`,
    # where the time for opening/closing otherwise dominates)
    for D in (1,2,3)
        global LGIRREPS_JLDFILES[D][] =
            JLD2.jldopen(DATA_DIR*"/irreps/lgs/$(D)d/irreps_data.jld2", "r")
        global LGS_JLDFILES[D][] =
            JLD2.jldopen(DATA_DIR*"/irreps/lgs/$(D)d/littlegroups_data.jld2", "r")
    end
    global PGIRREPS_JLDFILE[] = # only has 3D data; no need for tuple over dimensions
            JLD2.jldopen(DATA_DIR*"/irreps/pgs/3d/irreps_data.jld2", "r")

    # ensure we close files on exit
    atexit(() -> foreach(jldfile -> close(jldfile[]), LGIRREPS_JLDFILES))
    atexit(() -> foreach(jldfile -> close(jldfile[]), LGS_JLDFILES))
    atexit(() -> close(PGIRREPS_JLDFILE[]))

    # load extensions via Requires.jl on Julia versions <v1.9
    @static if !isdefined(Base, :get_extension)
        @require PyPlot = "d330b81b-6aea-500a-939a-2ce795aea3ee" begin  
            include("../ext/CrystallinePyPlotExt.jl") # loads PyPlot and Meshing
            export mesh_3d_levelsetlattice
        end
        @require GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2" begin
            include("../ext/CrystallineGraphMakieExt.jl")
        end
    end
end

# precompile statements
if Base.VERSION >= v"1.4.2"
    include("precompile.jl")
    _precompile_()
end

end # module
