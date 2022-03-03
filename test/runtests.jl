using FormsPreprocessors
using Test
using DataFrames, DataFramesMeta

df = DataFrame(bt = ["A", "A", "O", "AB", "B", "B", "C"],
    rh = ["+", "-", "+", "+", "+", "+", "+"])
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
        @test size(convert_answer!(df, :bt, bloodtype), 1) == 7
        @test convert_answer!(df, :bt, bloodtype)[4, 1] == "4"
        @test convert_answer!(df, :bt, bloodtype)[7, 1] == "C"
        @test convert_answer!(df, :bt, bloodtype)[:, 2] == df[:,2]
    end


end