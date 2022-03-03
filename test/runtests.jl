using FormsPreprocessors
using Test
using DataFrames, DataFramesMeta

df = DataFrame(bt = ["A", "A", "O", "AB", "B", "B", "C"],
    rh = ["+", "-", "+", "+", "+", "+", "+"])
df_w_missing = DataFrame(bt = ["A", "A", "O", "AB", "B", missing, "B", "C", missing],
    rh = ["+", "-", missing, "+", "+", missing, "+", "+", missing])
bloodtype = Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "4"])


@testset "SurveyPreprocessors.jl" begin
    @testset "apply_dict" begin
        @test apply_dict(bloodtype, "A") == "1"
        @test apply_dict(bloodtype, "B") == "2"
        @test apply_dict(bloodtype, "O") == "3"
        @test apply_dict(bloodtype, "AB") == "4"
        @test apply_dict(bloodtype, "K") == "K"
        @test apply_dict(bloodtype, 'A') == 'A'
        @test apply_dict(bloodtype, :A) == :A
        @test apply_dict(bloodtype, 0) == 0
        @test apply_dict(bloodtype, missing) |> ismissing == true
    end

    @testset "convert_answer!" begin
        @testitem size(convert_answer!(df, :bt, bloodtype)) == (7, 2)
        @test convert_answer!(df, :bt, bloodtype).bt == ["1", "1", "3", "4", "2", "2", "C"]
        @test convert_answer!(df, :bt, bloodtype)[:, 2] == df[:,2]
        @test convert_answer!(df, :rh, bloodtype) == df
        @test isequal(convert_answer!(df_w_missing, :bt, bloodtype).bt, ["1", "1", "3", "4", "2", missing, "2", "C", missing])
    end

    @testset "gen_conversion_dict" begin
        ks = ["A", "B", "O", "AB"]
        vs = ["1", "2", "3", "4"]
        @test typeof(gen_conversion_dict(ks, vs)) == Dict{String, String}
        @test gen_conversion_dict(ks, vs) == bloodtype
        @test length(gen_conversion_dict(ks, vs[1:3])) == 3
    end


end