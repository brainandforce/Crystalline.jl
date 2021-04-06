using Crystalline, Test
using LinearAlgebra: dot

# ---------------------------------------------------------------------------------------- #
# test print with nicely printed diff on failures (from https://github.com/invenia/PkgTemplates.jl/blob/master/test/runtests.jl)
using DeepDiffs: deepdiff
function print_diff(a, b)
    old = Base.have_color
    @eval Base have_color = true
    try
        println(deepdiff(a, b))
    finally
        @eval Base have_color = $old
    end
end

function test_show(expected::AbstractString, observed::AbstractString)
    if expected == observed
        @test true
    else
        print_diff(expected, observed)
        @test :expected == :observed
    end
end
test_tp_show(v, observed::AbstractString) = test_show(repr(MIME"text/plain"(), v), observed)

# ---------------------------------------------------------------------------------------- #

@testset "`show` overloads" begin
# -------------------------------
# DirectBasis
# -------------------------------
Rs = DirectBasis([1,0,0], [0,1,0], [0,0,1]) # cubic
str = """
      DirectBasis{3} (cubic):
         [1.0, 0.0, 0.0]
         [0.0, 1.0, 0.0]
         [0.0, 0.0, 1.0]"""
test_tp_show(Rs, str)

Rs = DirectBasis([1,0,0], [-0.5, √(3)/2, 0.0], [0, 0, 1.5]) # hexagonal
str = """
      DirectBasis{3} (hexagonal):
         [1.0, 0.0, 0.0]
         [-0.5, 0.8660254037844386, 0.0]
         [0.0, 0.0, 1.5]"""
test_tp_show(Rs, str)
Rs′ = directbasis(183, Val(3))
@test Rs[1] ≈ Rs′[1] && Rs[2] ≈ Rs′[2]
@test abs(dot(Rs[1], Rs′[3])) < 1e-14
@test abs(dot(Rs[2], Rs′[3])) < 1e-14
@test abs(dot(Rs[3], Rs′[3])) > 1e-1

# -------------------------------
# SymOperation
# -------------------------------
str = """
      1 ──────────────────────────────── (x,y,z)
       ┌ 1  0  0 ╷ 0 ┐
       │ 0  1  0 ┆ 0 │
       └ 0  0  1 ╵ 0 ┘"""
test_tp_show(S"x,y,z", str)

str = """
      {-3₋₁₋₁₁⁺|0,½,⅓} ──────── (z,-x+1/2,y+1/3)
       ┌  0  0  1 ╷   0 ┐
       │ -1  0  0 ┆ 1/2 │
       └  0  1  0 ╵ 1/3 ┘"""
test_tp_show(S"z,-x+1/2,y+1/3", str)

str = """
      3⁻ ───────────────────────────── (-x+y,-x)
       ┌ -1  1 ╷ 0 ┐
       └ -1  0 ╵ 0 ┘"""
test_tp_show(S"y-x,-x", str)

str = """
      3-element Vector{SymOperation{3}}:
       1
       2₀₁₁
       {3₁₁₁⁻|0,0,⅓}"""
test_tp_show([S"x,y,z", S"-x,z,y", S"y,z,x+1/3"], str)

# -------------------------------
# MultTable
# -------------------------------
str = """
      6×6 MultTable{3}:
      ───────┬──────────────────────────────────────────
             │     1  3₀₀₁⁺  3₀₀₁⁻   2₀₀₁  6₀₀₁⁻  6₀₀₁⁺
      ───────┼──────────────────────────────────────────
           1 │     1  3₀₀₁⁺  3₀₀₁⁻   2₀₀₁  6₀₀₁⁻  6₀₀₁⁺
       3₀₀₁⁺ │ 3₀₀₁⁺  3₀₀₁⁻      1  6₀₀₁⁻  6₀₀₁⁺   2₀₀₁
       3₀₀₁⁻ │ 3₀₀₁⁻      1  3₀₀₁⁺  6₀₀₁⁺   2₀₀₁  6₀₀₁⁻
        2₀₀₁ │  2₀₀₁  6₀₀₁⁻  6₀₀₁⁺      1  3₀₀₁⁺  3₀₀₁⁻
       6₀₀₁⁻ │ 6₀₀₁⁻  6₀₀₁⁺   2₀₀₁  3₀₀₁⁺  3₀₀₁⁻      1
       6₀₀₁⁺ │ 6₀₀₁⁺   2₀₀₁  6₀₀₁⁻  3₀₀₁⁻      1  3₀₀₁⁺
      ───────┴──────────────────────────────────────────
      """
test_tp_show(MultTable(pointgroup("6")), str)

str = """
      4×4 MultTable{3}:
      ──────────────┬────────────────────────────────────────────────────────
                    │            1  {2₀₁₀|0,0,½}            -1  {m₀₁₀|0,0,½}
      ──────────────┼────────────────────────────────────────────────────────
                  1 │            1  {2₀₁₀|0,0,½}            -1  {m₀₁₀|0,0,½}
       {2₀₁₀|0,0,½} │ {2₀₁₀|0,0,½}             1  {m₀₁₀|0,0,½}            -1
                 -1 │           -1  {m₀₁₀|0,0,½}             1  {2₀₁₀|0,0,½}
       {m₀₁₀|0,0,½} │ {m₀₁₀|0,0,½}            -1  {2₀₁₀|0,0,½}             1
      ──────────────┴────────────────────────────────────────────────────────
      """
test_tp_show(MultTable(spacegroup(13)), str)

# -------------------------------
# KVec
# -------------------------------
for v in (KVec, RVec)
    test_tp_show(v("0,0,.5+u"), "[0.0, 0.0, 0.5+α]")
    test_tp_show(v("1/2+α,β+α,1/4"), "[0.5+α, α+β, 0.25]")
    test_tp_show(v("β,-α"), "[β, -α]")
    @test repr(MIME"text/plain"(), v("y,γ,u")) == repr(MIME"text/plain"(), v("β,w,x"))
end

# -------------------------------
# AbstractGroup
# -------------------------------
str = """
      PointGroup{3} #21 (6) with 6 operations:
       1 ──────────────────────────────── (x,y,z)
       3₀₀₁⁺ ───────────────────────── (-y,x-y,z)
       3₀₀₁⁻ ──────────────────────── (-x+y,-x,z)
       2₀₀₁ ─────────────────────────── (-x,-y,z)
       6₀₀₁⁻ ───────────────────────── (y,-x+y,z)
       6₀₀₁⁺ ────────────────────────── (x-y,x,z)"""
test_tp_show(pointgroup("6", Val(3)), str)

str = """
      SpaceGroup{3} #213 (P4₁32) with 24 operations:
       1 ──────────────────────────────── (x,y,z)
       {2₀₀₁|½,0,½} ─────────── (-x+1/2,-y,z+1/2)
       {2₀₁₀|0,½,½} ─────────── (-x,y+1/2,-z+1/2)
       {2₁₀₀|½,½,0} ─────────── (x+1/2,-y+1/2,-z)
       3₁₁₁⁺ ──────────────────────────── (z,x,y)
       {3₋₁₁₋₁⁺|½,½,0} ──────── (z+1/2,-x+1/2,-y)
       {3₋₁₁₁⁻|½,0,½} ───────── (-z+1/2,-x,y+1/2)
       {3₋₁₋₁₁⁺|0,½,½} ──────── (-z,x+1/2,-y+1/2)
       3₁₁₁⁻ ──────────────────────────── (y,z,x)
       {3₋₁₁₁⁺|0,½,½} ───────── (-y,z+1/2,-x+1/2)
       {3₋₁₋₁₁⁻|½,½,0} ──────── (y+1/2,-z+1/2,-x)
       {3₋₁₁₋₁⁻|½,0,½} ──────── (-y+1/2,-z,x+1/2)
       {2₁₁₀|¾,¼,¼} ──────── (y+3/4,x+1/4,-z+1/4)
       {2₋₁₁₀|¾,¾,¾} ───── (-y+3/4,-x+3/4,-z+3/4)
       {4₀₀₁⁻|¼,¼,¾} ─────── (y+1/4,-x+1/4,z+3/4)
       {4₀₀₁⁺|¼,¾,¼} ─────── (-y+1/4,x+3/4,z+1/4)
       {4₁₀₀⁻|¾,¼,¼} ─────── (x+3/4,z+1/4,-y+1/4)
       {2₀₁₁|¼,¾,¼} ──────── (-x+1/4,z+3/4,y+1/4)
       {2₀₋₁₁|¾,¾,¾} ───── (-x+3/4,-z+3/4,-y+3/4)
       {4₁₀₀⁺|¼,¼,¾} ─────── (x+1/4,-z+1/4,y+3/4)
       {4₀₁₀⁺|¾,¼,¼} ─────── (z+3/4,y+1/4,-x+1/4)
       {2₁₀₁|¼,¼,¾} ──────── (z+1/4,-y+1/4,x+3/4)
       {4₀₁₀⁻|¼,¾,¼} ─────── (-z+1/4,y+3/4,x+1/4)
       {2₋₁₀₁|¾,¾,¾} ───── (-z+3/4,-y+3/4,-x+3/4)"""
test_tp_show(spacegroup(213, Val(3)), str)

str = """
      SiteGroup{2} #17 at 2b = [0.333333, 0.666667] with 6 operations:
       1 ────────────────────────────────── (x,y)
       {3⁺|1,1} ──────────────────── (-y+1,x-y+1)
       {3⁻|0,1} ───────────────────── (-x+y,-x+1)
       {m₁₁|1,1} ──────────────────── (-y+1,-x+1)
       m₁₀ ───────────────────────────── (-x+y,y)
       {m₀₁|0,1} ────────────────────── (x,x-y+1)"""
sg = spacegroup(17,Val(2))
wps = get_wycks(17, Val(2))
test_tp_show(SiteGroup(sg, wps[end-1]), str)

# -------------------------------
# LGIrrep
# -------------------------------
str = """
LGIrrep{3}: #16 (P222) at Γ = [0.0, 0.0, 0.0]
Γ₁ ─┬─────────────────────────────────────────────
    ├─ 1: ──────────────────────────────── (x,y,z)
    │     1.0
    │
    ├─ 2₁₀₀: ─────────────────────────── (x,-y,-z)
    │     1.0
    │
    ├─ 2₀₁₀: ─────────────────────────── (-x,y,-z)
    │     1.0
    │
    ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
    │     1.0
    └─────────────────────────────────────────────
Γ₂ ─┬─────────────────────────────────────────────
    ├─ 1: ──────────────────────────────── (x,y,z)
    │     1.0
    │
    ├─ 2₁₀₀: ─────────────────────────── (x,-y,-z)
    │     -1.0
    │
    ├─ 2₀₁₀: ─────────────────────────── (-x,y,-z)
    │     -1.0
    │
    ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
    │     1.0
    └─────────────────────────────────────────────
Γ₃ ─┬─────────────────────────────────────────────
    ├─ 1: ──────────────────────────────── (x,y,z)
    │     1.0
    │
    ├─ 2₁₀₀: ─────────────────────────── (x,-y,-z)
    │     1.0
    │
    ├─ 2₀₁₀: ─────────────────────────── (-x,y,-z)
    │     -1.0
    │
    ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
    │     -1.0
    └─────────────────────────────────────────────
Γ₄ ─┬─────────────────────────────────────────────
    ├─ 1: ──────────────────────────────── (x,y,z)
    │     1.0
    │
    ├─ 2₁₀₀: ─────────────────────────── (x,-y,-z)
    │     -1.0
    │
    ├─ 2₀₁₀: ─────────────────────────── (-x,y,-z)
    │     1.0
    │
    ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
    │     -1.0
    └─────────────────────────────────────────────"""
test_tp_show(get_lgirreps(16)["Γ"], str)

str = """
Γ₅ ─┬─────────────────────────────────────────────
    ├─ 1: ──────────────────────────────── (x,y,z)
    │     ⎡ 1.0+0.0im  0.0+0.0im ⎤
    │     ⎣ 0.0+0.0im  1.0+0.0im ⎦
    │
    ├─ {2₁₀₀|0,½,¼}: ─────────── (x,-y+1/2,-z+1/4)
    │     ⎡ 1.0+0.0im   0.0+0.0im ⎤
    │     ⎣ 0.0+0.0im  -1.0+0.0im ⎦
    │
    ├─ {2₀₁₀|0,½,¼}: ─────────── (-x,y+1/2,-z+1/4)
    │     ⎡ -1.0+0.0im  0.0+0.0im ⎤
    │     ⎣  0.0+0.0im  1.0+0.0im ⎦
    │
    ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
    │     ⎡ -1.0+0.0im   0.0+0.0im ⎤
    │     ⎣  0.0+0.0im  -1.0+0.0im ⎦
    │
    ├─ -4₀₀₁⁺: ───────────────────────── (y,-x,-z)
    │     ⎡  0.0+0.0im  1.0+0.0im ⎤
    │     ⎣ -1.0+0.0im  0.0+0.0im ⎦
    │
    ├─ -4₀₀₁⁻: ───────────────────────── (-y,x,-z)
    │     ⎡ 0.0+0.0im  -1.0+0.0im ⎤
    │     ⎣ 1.0+0.0im   0.0+0.0im ⎦
    │
    ├─ {m₁₁₀|0,½,¼}: ─────────── (-y,-x+1/2,z+1/4)
    │     ⎡  0.0+0.0im  -1.0+0.0im ⎤
    │     ⎣ -1.0+0.0im   0.0+0.0im ⎦
    │
    ├─ {m₋₁₁₀|0,½,¼}: ──────────── (y,x+1/2,z+1/4)
    │     ⎡ 0.0+0.0im  1.0+0.0im ⎤
    │     ⎣ 1.0+0.0im  0.0+0.0im ⎦
    └─────────────────────────────────────────────"""
test_tp_show(get_lgirreps(122)["Γ"][end], str)

str = """
Γ₆ ─┬─────────────────────────────────────────────
    ├─ 1: ──────────────────────────────── (x,y,z)
    │     1.0
    │
    ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
    │     -1.0
    │
    ├─ 3₀₀₁⁺: ───────────────────────── (-y,x-y,z)
    │     1.0exp(-0.6666666666666667iπ)
    │
    ├─ 3₀₀₁⁻: ──────────────────────── (-x+y,-x,z)
    │     1.0exp(0.6666666666666667iπ)
    │
    ├─ 6₀₀₁⁺: ────────────────────────── (x-y,x,z)
    │     1.0exp(-0.3333333333333333iπ)
    │
    ├─ 6₀₀₁⁻: ───────────────────────── (y,-x+y,z)
    │     1.0exp(0.3333333333333333iπ)
    └─────────────────────────────────────────────"""
test_tp_show(get_lgirreps(168)["Γ"][end], str)

# -------------------------------
# PGIrrep
# -------------------------------
str = """
Γ₄Γ₆ ─┬─────────────────────────────────────────────
      ├─ 1: ──────────────────────────────── (x,y,z)
      │     ⎡ 1.0+0.0im  0.0+0.0im ⎤
      │     ⎣ 0.0+0.0im  1.0+0.0im ⎦
      │
      ├─ 3₀₀₁⁺: ───────────────────────── (-y,x-y,z)
      │     ⎡ -0.5+0.866im   0.0+0.0im ⎤
      │     ⎣  0.0+0.0im    -0.5-0.866im ⎦
      │
      ├─ 3₀₀₁⁻: ──────────────────────── (-x+y,-x,z)
      │     ⎡ -0.5-0.866im   0.0+0.0im ⎤
      │     ⎣  0.0+0.0im    -0.5+0.866im ⎦
      │
      ├─ 2₀₀₁: ─────────────────────────── (-x,-y,z)
      │     ⎡ -1.0+0.0im   0.0+0.0im ⎤
      │     ⎣  0.0+0.0im  -1.0+0.0im ⎦
      │
      ├─ 6₀₀₁⁻: ───────────────────────── (y,-x+y,z)
      │     ⎡ 0.5-0.866im  0.0+0.0im ⎤
      │     ⎣ 0.0+0.0im    0.5+0.866im ⎦
      │
      ├─ 6₀₀₁⁺: ────────────────────────── (x-y,x,z)
      │     ⎡ 0.5+0.866im  0.0+0.0im ⎤
      │     ⎣ 0.0+0.0im    0.5-0.866im ⎦
      └─────────────────────────────────────────────"""
pgirs = get_pgirreps("6")
pgirs′ = realify(pgirs)
test_tp_show(realify(pgirs)[end], str)
@test summary(pgirs) == "6-element Vector{PGIrrep{3}}"
@test summary(pgirs′) == "4-element Vector{PGIrrep{3}}"

# -------------------------------
# CharacterTable
# -------------------------------
str = """
CharacterTable{3}: #21 (6)
───────┬────────────────────
       │ Γ₁  Γ₂  Γ₃Γ₅  Γ₄Γ₆
───────┼────────────────────
     1 │  1   1     2     2
 3₀₀₁⁺ │  1   1    -1    -1
 3₀₀₁⁻ │  1   1    -1    -1
  2₀₀₁ │  1  -1     2    -2
 6₀₀₁⁻ │  1  -1    -1     1
 6₀₀₁⁺ │  1  -1    -1     1
───────┴────────────────────
"""
test_tp_show(CharacterTable(pgirs′), str)

str = """
CharacterTable{3}: #230 (Ia-3d at P = [0.5, 0.5, 0.5])
─────────────────┬──────────────────────
                 │     P₁      P₂    P₃
─────────────────┼──────────────────────
               1 │      2       2     4
    {2₁₀₀|0,0,½} │      0       0     0
    {2₀₁₀|½,0,0} │      0       0     0
    {2₀₀₁|0,½,0} │      0       0     0
           3₁₁₁⁺ │     -1      -1     1
           3₁₁₁⁻ │     -1      -1     1
  {3₋₁₁₁⁺|½,0,0} │   -1im    -1im   1im
  {3₋₁₁₁⁻|0,½,0} │    1im     1im  -1im
 {3₋₁₁₋₁⁻|0,½,0} │   -1im    -1im   1im
 {3₋₁₁₋₁⁺|0,0,½} │    1im     1im  -1im
 {3₋₁₋₁₁⁻|0,0,½} │   -1im    -1im   1im
 {3₋₁₋₁₁⁺|½,0,0} │    1im     1im  -1im
  {-4₁₀₀⁺|¼,¼,¾} │ -1+1im   1-1im     0
  {-4₁₀₀⁻|¾,¼,¼} │  1-1im  -1+1im     0
  {-4₀₁₀⁺|¾,¼,¼} │ -1+1im   1-1im     0
  {-4₀₁₀⁻|¼,¾,¼} │  1-1im  -1+1im     0
  {-4₀₀₁⁺|¼,¾,¼} │ -1+1im   1-1im     0
  {-4₀₀₁⁻|¼,¼,¾} │  1-1im  -1+1im     0
    {m₁₁₀|¾,¼,¼} │      0       0     0
   {m₋₁₁₀|¼,¼,¼} │      0       0     0
    {m₁₀₁|¼,¼,¾} │      0       0     0
   {m₋₁₀₁|¼,¼,¼} │      0       0     0
    {m₀₁₁|¼,¾,¼} │      0       0     0
   {m₀₋₁₁|¼,¼,¼} │      0       0     0
─────────────────┴──────────────────────
"""
test_tp_show(CharacterTable(get_lgirreps(230)["P"]), str)

# -------------------------------
# BandRepSet and BandRep
# -------------------------------
brs = bandreps(42, 3)
str = """
BandRepSet (#42): 6 BandReps, sampling 17 LGIrreps (spin-1 w/ TR)
────┬────────────────────────
    │ 4a  4a  4a  4a  8b  8b
    │ A₁  A₂  B₁  B₂  A   B
────┼────────────────────────
 Γ₁ │ 1   ·   ·   ·   1   ·
 Γ₂ │ ·   1   ·   ·   1   ·
 Γ₃ │ ·   ·   ·   1   ·   1
 Γ₄ │ ·   ·   1   ·   ·   1
 T₁ │ 1   ·   ·   ·   ·   1
 T₂ │ ·   1   ·   ·   ·   1
 T₃ │ ·   ·   ·   1   1   ·
 T₄ │ ·   ·   1   ·   1   ·
 Y₁ │ 1   ·   ·   ·   ·   1
 Y₂ │ ·   1   ·   ·   ·   1
 Y₃ │ ·   ·   ·   1   1   ·
 Y₄ │ ·   ·   1   ·   1   ·
 Z₁ │ 1   ·   ·   ·   1   ·
 Z₂ │ ·   1   ·   ·   1   ·
 Z₃ │ ·   ·   ·   1   ·   1
 Z₄ │ ·   ·   1   ·   ·   1
 L₁ │ 1   1   1   1   2   2
────┼────────────────────────
 ν  │ 1   1   1   1   2   2
────┴────────────────────────
  KVecs (maximal only): Γ, T, Y, Z, L"""
test_tp_show(brs, str)

test_tp_show(brs[1],   "1-band BandRep (A₁↑G at 4a):\n [Γ₁, T₁, Y₁, Z₁, L₁]")
test_tp_show(brs[end], "2-band BandRep (B↑G at 8b):\n [Γ₃+Γ₄, T₁+T₂, Y₁+Y₂, Z₃+Z₄, 2L₁]")

end # @testset