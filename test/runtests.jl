using FormsPreprocessors
using Test
using DataFrames, DataFramesMeta

function gen_df()
    DataFrame(bt = ["A", "A", "O", "AB", "B", "B", "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])
end

function gen_df_missing()
    DataFrame(bt = ["A", "A", "O", "AB", "B", missing, "B", "C", missing],
        rh = ["+", "-", missing, "+", "+", missing, "+", "+", missing])
end

function gen_df_nest()
    DataFrame(bt = ["A", ["A", "AB"], "O", ["AB", "B", "B"], "K", "B", "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])
end

function gen_df_nest_missing()
    DataFrame(bt = ["A", ["A", "M"], "O", ["AB", missing, "B"], "K", missing, "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])
end

@testset "SurveyPreprocessors.jl" begin
    df_cv = DataFrame(bt = ["1", "1", "3", "4", "2", "2", "C"],
    rh = ["+", "-", "+", "+", "+", "+", "+"])

    df_missing_cv = DataFrame(bt = ["1", "1", "3", "4", "2", missing, "2", "C", missing],
        rh = ["+", "-", missing, "+", "+", missing, "+", "+", missing])

    df_nest_cv = DataFrame(bt = ["1", ["1", "4"], "3", ["4", "2", "2"], "K", "2", "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])

    df_nest_m_cv = DataFrame(bt = ["1", ["1", "M"], "3", ["4", missing, "2"], "K", missing, "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])

    bloodtype = Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "4"])

    ks = ["A", "B", "O", "AB"]
    vs = ["1", "2", "3", "4"]

    @testset "apply_dict(String)" begin
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

    @testset "apply_dict(Vector)" begin
        @test apply_dict(bloodtype, ["A", "B"]) == ["1", "2"]
        @test apply_dict(bloodtype, ["C", "D"]) == ["C", "D"]
        @test apply_dict(bloodtype, []) == []
        @test isequal(apply_dict(bloodtype, [missing, "A", "AB", "C"]), [missing, "1", "4", "C"])
    end

    @testset "convert_answer!" begin
        @test size(convert_answer!(gen_df(), :bt, bloodtype)) == (7, 2)
        @test convert_answer!(gen_df(), :bt, bloodtype).bt == ["1", "1", "3", "4", "2", "2", "C"]
        @test convert_answer!(gen_df(), :bt, bloodtype)[:, 2] == gen_df()[:,2]
        @test convert_answer!(gen_df(), :rh, bloodtype) == gen_df()
        @test isequal(convert_answer!(gen_df_missing(), :bt, bloodtype).bt, ["1", "1", "3", "4", "2", missing, "2", "C", missing])
        @test convert_answer!(gen_df_nest(), :bt, bloodtype) == df_nest_cv
        @test isequal(convert_answer!(gen_df_nest_missing(), :bt, bloodtype), df_nest_m_cv)
    end

    @testset "gen_conversion_dict" begin
        @test typeof(gen_conversion_dict(ks, vs)) == Dict{String, String}
        @test gen_conversion_dict(ks, vs) == bloodtype
        @test length(gen_conversion_dict(ks, vs[1:3])) == 3
        @test_logs (:warn, ) gen_conversion_dict(ks, vs[1:3])
        @test_logs (:warn, ) gen_conversion_dict(ks, [])
        @test length(gen_conversion_dict([], vs)) == 0
        @test gen_conversion_dict([], []) == Dict([])
        @test_logs (:error, ) gen_conversion_dict([], [])
        @test_throws ErrorException gen_conversion_dict(["A", "B", "A"], ["C", "D", "E"])
    end

    @testset "renaming_dict" begin
        @test renaming_dict(ks, vs) == bloodtype
        @test renaming_dict(ks, vs[1:3]) == Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "other"])
        @test renaming_dict(ks, vs[1:3], "その他") == Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "その他"])
        @test_throws ErrorException renaming_dict(ks[1:2], vs)
        @test_throws MethodError renaming_dict([], vs)
        @test renaming_dict(ks, []) == Dict(["A" => "other", "B" => "other", "O" => "other", "AB" => "other"])
        @test_throws MethodError renaming_dict([], [])
        @test_throws ErrorException renaming_dict(["A", "B", "A"], ["1", "2", "3"])
        @test_throws ErrorException renaming_dict(["A", "B", "A"], [])
        @test_throws ErrorException renaming_dict(["A", "B", "A"], ["1", "2", "1"])
        @test_throws MethodError renaming_dict("foo", ["1", "2", "3"])
        @test_throws MethodError renaming_dict(ks, "BA", "OTHER")
        @test_throws MethodError renaming_dict("FOO", "BAR")
    end

    @testset "recode!" begin
        @test recode!(gen_df(), :bt, ks, vs) == df_cv
        @test isequal(recode!(gen_df_missing(), :bt, ks, vs), df_missing_cv)
        @test recode!(gen_df_nest(), :bt, ks, vs) == df_nest_cv
        @test isequal(recode!(gen_df_nest_missing(), :bt, ks, vs), df_nest_m_cv)
        @test recode!(gen_df(), :bt, ks, ["1", "2", "3"]).bt == ["1", "1", "3", "other", "2", "2", "C"]
        @test isequal(recode!(gen_df_missing(), :bt, ks, vs[1:3]).bt, 
            ["1", "1", "3", "other", "2", missing, "2", "C", missing])
        @test isequal(recode!(gen_df_nest_missing(), :bt, ks, vs[1:3]).bt,
            ["1", ["1", "M"], "3", ["other", missing, "2"], "K", missing, "C"])
        @test isequal(recode!(gen_df_nest_missing(), :bt, ks).bt, 
            ["other", ["other", "M"], "other", ["other", missing, "other"], "K", missing, "C"])
    end


end