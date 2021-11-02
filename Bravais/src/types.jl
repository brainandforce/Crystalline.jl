# --- DirectBasis and ReciprocalBasis for crystalline lattices ---
"""
    AbstractBasis <: StaticVector{D, SVector{D,Float64}}

Abstract supertype of a `D`-dimensional basis in `D`-dimensional space.
"""
abstract type AbstractBasis{D, T} <: StaticVector{D, SVector{D, T}} end
for (T, space_type) in zip((:DirectBasis, :ReciprocalBasis), ("direct", "reciprocal"))
    @eval begin
        @doc """
            $($T){D} <: AbstractBasis{D}

        A wrapper type over `D` distinct `D`-dimensional vectors (given as a
        `SVector{D, SVector{D,Float64}}`), defining a lattice basis in $($space_type)
        space.
        """
        struct $T{D} <: AbstractBasis{D, Float64}
            vs::SVector{D, SVector{D, Float64}}
            $T{D}(vs::SVector{D, SVector{D, Float64}}) where D = new{D}(vs)
            $T(vs::SVector{D, SVector{D, Float64}}) where D    = new{D}(vs)
        end
    end
    @eval function convert(::Type{$T{D}}, Vs::StaticVector{D, <:StaticVector{D, <:Real}}) where D
        $T{D}(convert(SVector{D, SVector{D, Float64}}, Vs))
    end
    @eval $T{D}(Vs::NTuple{D, SVector{D, Float64}}) where D = $T{D}(SVector{D}(Vs))
    @eval $T(Vs::NTuple{D, SVector{D, Float64}}) where D = $T{D}(Vs)
    @eval $T{D}(Vs::NTuple{D, NTuple{D, Real}}) where D = $T{D}(SVector{D, Float64}.(Vs))
    @eval $T(Vs::NTuple{D, NTuple{D, Real}}) where D = $T{D}(Vs)
    @eval $T{D}(Vs::NTuple{D, AbstractVector{<:Real}}) where D = $T{D}(Vs...)
    @eval $T(Vs::NTuple{D, AbstractVector{<:Real}}) where D = $T{D}(Vs...)
    @eval $T{D}(Vs::AbstractVector{<:AbstractVector{<:Real}}) where D = $T{D}(Vs...)
    @eval $T(Vs::AbstractVector{<:AbstractVector{<:Real}}) = $T(Vs...)
    @eval $T{D}(Vs::AbstractVector{<:Real}...) where D = $T{D}(convert(SVector{D, SVector{D, Float64}}, Vs))
    @eval $T(Vs::AbstractVector{<:Real}...) = $T{length(Vs)}(Vs...)
    @eval $T{D}(Vs::StaticVector{D, <:Real}...) where D = $T{D}(Vs) # resolve ambiguities w/
    @eval $T(Vs::StaticVector{D, <:Real}...) where D = $T{D}(Vs)    # `::StaticArray` methods
end

parent(Vs::AbstractBasis) = Vs.vs
# define the AbstractArray interface for DirectBasis{D}
@propagate_inbounds getindex(Vs::AbstractBasis, i::Int) = parent(Vs)[i]
size(::AbstractBasis{D}) where D = (D,)
IndexStyle(::Type{<:AbstractBasis}) = IndexLinear()

_angle(rA, rB) = acos(dot(rA, rB) / (norm(rA) * norm(rB)))
function angles(Rs::AbstractBasis{D}) where D
    D == 1 && return nothing
    γ = _angle(Rs[1], Rs[2])
    D == 2 && return γ
    if D == 3
        α = _angle(Rs[2], Rs[3])
        β = _angle(Rs[3], Rs[1])
        return α, β, γ
    end
    _throw_invaliddim(D)
end

"""
    stack(Vs::AbstractBasis)

Return a matrix `[Vs[1] Vs[2] .. Vs[D]]` from `Vs::AbstractBasis{D}`, i.e. the matrix whose
columns are the basis vectors in `Vs`. 
"""
stack(Vs::AbstractBasis) = reduce(hcat, parent(Vs))
# TODO: At some point, this should hopefully no longer be necessary to do manually (and
# `stack` may end up exported by Base): https://github.com/JuliaLang/julia/issues/21672


# ---------------------------------------------------------------------------------------- #

abstract type AbstractPoint{D, T} <: StaticVector{D, T} end

parent(p::AbstractPoint) = p.v

@propagate_inbounds getindex(v::AbstractPoint, i::Int) = parent(v)[i]
size(::AbstractPoint{D}) where D = (D,)
IndexStyle(::Type{<:AbstractPoint}) = IndexLinear()

for (PT, BT, space_type) in zip((:DirectPoint, :ReciprocalPoint),
                                (:DirectBasis, :ReciprocalBasis),
                                ("direct", "reciprocal"))
    @eval begin
        @doc """
            $($PT){D} <: AbstractPoint{D}

        A wrapper type over an `SVector{D, Float64}`, defining a single point in
        `D`-dimensional $($space_type) space. 
        
        The coordinates of a $($PT) are generally assumed specified relative to an
        associated $($BT).
        """
        struct $PT{D} <: AbstractPoint{D, Float64}
            v::SVector{D, Float64}
            $PT{D}(v::SVector{D, Float64}) where {D} = new{D}(v)
            $PT(v::SVector{D, Float64}) where {D} = new{D}(v)
        end
        @eval function convert(::Type{$PT{D}}, v::AbstractVector{<:Real}) where D
            $PT{D}(convert(SVector{D, Float64}, v))
        end
        @eval convert(::Type{$PT{D}}, v::$PT{D}) where D = v
        @eval $PT{D}(v::NTuple{D, Real}) where D = $PT{D}(convert(SVector{D, Float64}, v))
        @eval $PT(v::NTuple{D, Real}) where D = $PT{D}(v)
        @eval $PT(vᵢ::Real...) = $PT(vᵢ)
    end
end