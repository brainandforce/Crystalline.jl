# Bravais.jl

Bravais types, basis systems, and transformations between conventional and primitive settings.

## API

```@meta
CurrentModule = Bravais
```

### Types
```@docs
DirectBasis
ReciprocalBasis
DirectPoint
ReciprocalPoint
```

### Crystal systems & Bravais types
```@docs
crystalsystem
bravaistype
centering
```

### Basis construction
```@docs
crystal
directbasis
reciprocalbasis
```

### Transformations
```@docs
primitivebasismatrix
transform(::DirectBasis, ::AbstractMatrix{<:Real})
transform(::ReciprocalBasis, ::AbstractMatrix{<:Real})
transform(::DirectPoint, ::AbstractMatrix{<:Real})
transform(::ReciprocalPoint, ::AbstractMatrix{<:Real})
primitivize(::Union{AbstractBasis, AbstractPoint}, ::Union{Char, <:Integer})
primitivize(::DirectBasis, ::Union{Char, <:Integer})
primitivize(::ReciprocalBasis, ::Union{Char, <:Integer})
primitivize(::DirectPoint, ::Union{Char, <:Integer})
primitivize(::ReciprocalPoint, ::Union{Char, <:Integer})
conventionalize(::Union{AbstractBasis, AbstractPoint}, ::Union{Char, <:Integer})
conventionalize(::DirectBasis, ::Union{Char, <:Integer})
conventionalize(::ReciprocalBasis, ::Union{Char, <:Integer})
conventionalize(::DirectPoint, ::Union{Char, <:Integer})
conventionalize(::ReciprocalPoint, ::Union{Char, <:Integer})
```

## Crystalline.jl extensions of Bravais.jl functions

```@meta
CurrentModule = Crystalline
```

### `SymOperation`
```@docs
transform(::SymOperation, ::AbstractMatrix{<:Real}, ::Union{AbstractVector{<:Real}, Nothing}, ::Bool=true)
primitivize(::SymOperation, ::Char, ::Bool)
conventionalize(::SymOperation, ::Char, ::Bool)
```

### `AbstractFourierLattice`
```@docs
primitivize(::AbstractFourierLattice, ::Char)
conventionalize(::AbstractFourierLattice, ::Char)
```

### `AbstractVec`
```@docs
transform(::Crystalline.AbstractVec, ::AbstractMatrix{<:Real})
primitivize(::Crystalline.AbstractVec, ::Char)
conventionalize(::Crystalline.AbstractVec, ::Char)
```