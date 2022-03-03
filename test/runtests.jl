using FormsPreprocessors
using Test
using DataFrames, DataFramesMeta

df = DataFrame(bt = ["A", "A", "O", "AB", "B", "B", "C"],
    rh = ["+", "-", "+", "+", "+", "+", "+"])
bloodtype = Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "4"])


@testset "SurveyPreprocessors.jl" begin
    @testset "convert_answers!" begin
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
end