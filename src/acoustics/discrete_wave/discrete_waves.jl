discrete_system(ω::AbstractFloat, source::AbstractSource, material::Material; kws...) = discrete_system(ω::AbstractFloat, source::AbstractSource, material::Material, Symmetry(source,material); kws...)
