using Crystalline, Test

if !isdefined(Main, :LGIRS′)
    LGIRS′ = parselittlegroupirreps() # parsed directly from ISOTROPY's files
end
if !isdefined(Main, :LGIRS)
    LGIRS  = get_lgirreps.(1:MAX_SGNUM[3], Val(3)) # loaded from our saved .jld2 files
end

@testset "Test equivalence of parsed and loaded LGIrreps" begin
    for sgnum in 1:230
        lgirsd′ = LGIRS′[sgnum] # parsed variant
        lgirsd  = LGIRS[sgnum]  # loaded variant

        @test length(lgirsd) == length(lgirsd′)
        for (kidx, (klab, lgirs)) in enumerate(lgirsd)
            lgirs′ = lgirsd′[klab]
            @test length(lgirs) == length(lgirs′)
            for (iridx, lgir) in enumerate(lgirs)
                lgir′ = lgirs′[iridx]
                # test that labels agree
                @test label(lgir) == label(lgir′)
                # test that little groups agree
                @test isapprox(kvec(lgir), kvec(lgir′))
                @test all(operations(lgir) .== operations(lgir′))
                # test that irreps agree
                for αβγ in (nothing, Crystalline.TEST_αβγ)
                    @test lgir(αβγ) == lgir′(αβγ)
                end
            end
        end
    end
end