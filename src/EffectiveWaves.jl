# Loads all files
module EffectiveWaves

# Here are the main exported functions and types. Note there are other exported functions and types in files such as "effective_wave/export.jl" and "discrete_wave/export.jl"
export  EffectivePlaneWaveMode, EffectiveRegularWaveMode

export  DiscretePlaneWaveMode
export  MatchPlaneWaveMode # a combination of the Discrete and Effective modes
export  Material, Specie, Species, SetupSymmetry, number_density, volume_fraction
export  hole_correction_pair_correlation

# for MatchPlaneWaveMode
export  match_error, x_mesh_match

# for effective waves
export wavenumbers, wavenumber, asymptotic_monopole_wavenumbers, eigenvectors, azimuthal_to_planar_eigenvector, eigenvector_length
export WaveModes, WaveMode, wavemode_wienerhopf
export solve_boundary_condition, scattering_field, material_scattering_coefficients, material_scattered_waves

export dispersion_equation, dispersion_complex, eigensystem # supplies a matrix used for the disperision equation and effective eignvectors

export scattering_amplitudes_average

export  reflection_coefficient, reflection_coefficients, reflection_transmission_coefficients, planewave_amplitudes
export  effective_medium

# List of shorthand for some materials
export  Brick, IronArmco, LeadAnnealed, RubberGum, FusedSilica, GlassPyrex,
        ClayRock, WaterDistilled, Glycerol, Hexadecane, Acetone, Benzene,
        Nitrobenzene, OliveOil, SodiumNitrate, AirDry,
        LimeStone, Clay, Calcite, SilicaQuartz

import Base.isequal, Base.(==), Base.zero
import SpecialFunctions: besselj, hankelh1
import StaticArrays: SVector
import Statistics: mean, std

import IterTools: groupby

using Reexport
@reexport using MultipleScattering

import MultipleScattering: RegularSource, Acoustic

using RecipesBase, OffsetArrays, LinearAlgebra

# Heavy package
using Optim: optimize, Optim, FixedParameters, Options, LBFGS, Fminbox, NelderMead
# Below doesn't work on Julia 1.1
# @reexport using Optim: optimize, FixedParameters, Options, LBFGS, Fminbox, NelderMead
import Optim: simplexer

# Heavy package
# using ApproxFun: ApproxFun.(..), Fun, Segment, Domain, Chebyshev, DefiniteIntegral, LowRankFun, Interval

using Interpolations: interpolate, BSpline, Cubic, Line, OnGrid, scale
using HCubature: hcubature, hquadrature
using ClassicalOrthogonalPolynomials: Legendre

using MDBM

include("material_types.jl")
include("statistics.jl")
include("wave_types.jl")
include("specialfunctions.jl")

include("effective_wave/export.jl")
include("acoustics/export.jl")

include("match_waves/match_waves.jl")
include("match_waves/match_arrays.jl")
include("match_waves/reflection.jl")

include("plot/graphics.jl")
include("plot/plot.jl")

end # module
