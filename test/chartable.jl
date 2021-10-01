using Crystalline, Test, LinearAlgebra

if !isdefined(Main, :LGIRSDIM)
    LGIRSDIM = Tuple(get_lgirreps.(1:MAX_SGNUM[D], Val(D)) for D in 1:3)
end

@testset "CharacterTable and orthogonality theorems" begin
    @testset "Little group irreps" begin
    for LGIRS in LGIRSDIM # ... D in 1:3
        for lgirsd in LGIRS
            for lgirs in values(lgirsd)
                ct = CharacterTable(lgirs)
                χs = characters(ct) # matrix of characters; each row is a different representation
                Nₒₚ = length(operations(ct))

                # 1ˢᵗ orthogonality theorem:    ∑ᵢ|χᵢ⁽ᵃ⁾|² = Nₒₚ⁽ᵃ⁾
                @test all(n->isapprox.(n, Nₒₚ, atol=1e-14), sum(abs2, χs, dims=1))

                # 2ⁿᵈ orthogonality theorem:    ∑ᵢχᵢ⁽ᵃ⁾*χᵢ⁽ᵝ⁾ = δₐᵦNₒₚ⁽ᵃ⁾ 
                @test χs'*χs ≈ Nₒₚ*I
            end
        end
    end # for LGIRS in LGIRSDIM
    end # @testset "Little group irreps"

    @testset "Point group irreps" begin
        for D in 1:3
            for pgiuc in PGS_IUCs[D]
                pgirs = get_pgirreps(pgiuc, Val(D))
                ct = CharacterTable(pgirs)
                χs = characters(ct) # matrix of characters; each row is a different representation
                Nₒₚ = length(operations(ct))

                # 1ˢᵗ orthogonality theorem:    ∑ᵢ|χᵢ⁽ᵃ⁾|² = Nₒₚ⁽ᵃ⁾
                @test all(n->isapprox.(n, Nₒₚ, atol=2e-14), sum(abs2, χs, dims=1))

                # 2ⁿᵈ orthogonality theorem:    ∑ᵢχᵢ⁽ᵃ⁾*χᵢ⁽ᵝ⁾ = δₐᵦNₒₚ⁽ᵃ⁾ 
                @test χs'*χs ≈ Nₒₚ*I
            end
        end
    end

    @testset "Indexing" begin
        pgirs = get_pgirreps("m-3m", Val(3))
        ct = CharacterTable(pgirs)
        χs = characters(ct)

        @test ct[3] == χs[3]
        @test ct[:,3] == χs[:,3]
        @test ct[2,:] == χs[2,:]
        @test ct' == χs'
        @test ct'*ct ≈ χs'*χs # may differ since one dispatches to generic matmul, the other to BLAS
        @test size(ct) == size(χs)
    end
end