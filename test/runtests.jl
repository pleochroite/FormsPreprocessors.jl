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
        @test FormsPreprocessors.apply_dict(bloodtype, "A") == "1"
        @test FormsPreprocessors.apply_dict(bloodtype, "B") == "2"
        @test FormsPreprocessors.apply_dict(bloodtype, "O") == "3"
        @test FormsPreprocessors.apply_dict(bloodtype, "AB") == "4"
        @test FormsPreprocessors.apply_dict(bloodtype, "K") == "K"
        @test FormsPreprocessors.apply_dict(bloodtype, 'A') == 'A'
        @test FormsPreprocessors.apply_dict(bloodtype, :A) == :A
        @test FormsPreprocessors.apply_dict(bloodtype, 0) == 0
        @test FormsPreprocessors.apply_dict(bloodtype, missing) |> ismissing == true
    end

    @testset "apply_dict(Vector)" begin
        @test FormsPreprocessors.apply_dict(bloodtype, ["A", "B"]) == ["1", "2"]
        @test FormsPreprocessors.apply_dict(bloodtype, ["C", "D"]) == ["C", "D"]
        @test FormsPreprocessors.apply_dict(bloodtype, []) == []
        @test isequal(FormsPreprocessors.apply_dict(bloodtype, [missing, "A", "AB", "C"]), [missing, "1", "4", "C"])
    end

    @testset "convert_answer!" begin
        @test size(FormsPreprocessors.convert_answer!(gen_df(), :bt, bloodtype)) == (7, 2)
        @test FormsPreprocessors.convert_answer!(gen_df(), :bt, bloodtype).bt == ["1", "1", "3", "4", "2", "2", "C"]
        @test FormsPreprocessors.convert_answer!(gen_df(), :bt, bloodtype)[:, 2] == gen_df()[:,2]
        @test FormsPreprocessors.convert_answer!(gen_df(), :rh, bloodtype) == gen_df()
        @test isequal(FormsPreprocessors.convert_answer!(gen_df_missing(), :bt, bloodtype).bt, ["1", "1", "3", "4", "2", missing, "2", "C", missing])
        @test FormsPreprocessors.convert_answer!(gen_df_nest(), :bt, bloodtype) == df_nest_cv
        @test isequal(FormsPreprocessors.convert_answer!(gen_df_nest_missing(), :bt, bloodtype), df_nest_m_cv)
    end

    @testset "gen_conversion_dict" begin
        @test typeof(FormsPreprocessors.gen_conversion_dict(ks, vs)) == Dict{String, String}
        @test FormsPreprocessors.gen_conversion_dict(ks, vs) == bloodtype
        @test length(FormsPreprocessors.gen_conversion_dict(ks, vs[1:3])) == 3
        @test_logs (:warn, ) FormsPreprocessors.gen_conversion_dict(ks, vs[1:3])
        @test_logs (:warn, ) FormsPreprocessors.gen_conversion_dict(ks, [])
        @test length(FormsPreprocessors.gen_conversion_dict([], vs)) == 0
        @test FormsPreprocessors.gen_conversion_dict([], []) == Dict([])
        @test_logs (:error, ) FormsPreprocessors.gen_conversion_dict([], [])
        @test_throws ErrorException FormsPreprocessors.gen_conversion_dict(["A", "B", "A"], ["C", "D", "E"])
    end

    @testset "renaming_dict" begin
        @test FormsPreprocessors.renaming_dict(ks, vs) == bloodtype
        @test FormsPreprocessors.renaming_dict(ks, vs[1:3]) == Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "other"])
        @test FormsPreprocessors.renaming_dict(ks, vs[1:3], "その他") == Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "その他"])
        @test_throws ErrorException FormsPreprocessors.renaming_dict(ks[1:2], vs)
        @test_throws MethodError FormsPreprocessors.renaming_dict([], vs)
        @test FormsPreprocessors.renaming_dict(ks, []) == Dict(["A" => "other", "B" => "other", "O" => "other", "AB" => "other"])
        @test_throws MethodError FormsPreprocessors.renaming_dict([], [])
        @test_throws ErrorException FormsPreprocessors.renaming_dict(["A", "B", "A"], ["1", "2", "3"])
        @test_throws ErrorException FormsPreprocessors.renaming_dict(["A", "B", "A"], [])
        @test_throws ErrorException FormsPreprocessors.renaming_dict(["A", "B", "A"], ["1", "2", "1"])
        @test_throws MethodError FormsPreprocessors.renaming_dict("foo", ["1", "2", "3"])
        @test_throws MethodError FormsPreprocessors.renaming_dict(ks, "BA", "OTHER")
        @test_throws MethodError FormsPreprocessors.renaming_dict("FOO", "BAR")
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


    sent = "abc;def;ghi;jklm"
    qbf = "A quick brown fox jumps over the lazy dog."

    @testset "split_ma" begin
        @test FormsPreprocessors.split_ma("ab,cd,e", ",") == ["ab", "cd", "e"]
        @test FormsPreprocessors.split_ma(sent) == ["abc", "def", "ghi", "jklm"]
        @test FormsPreprocessors.split_ma("abcdefghij", "fg") == ["abcde", "hij"]
        @test FormsPreprocessors.split_ma(qbf) == [qbf]
        @test FormsPreprocessors.split_ma("", ",") == [""]
        @test FormsPreprocessors.split_ma(";;;;") == ["", "", "", "", ""]
        @test ismissing(FormsPreprocessors.split_ma(missing))
        @test_throws MethodError FormsPreprocessors.split_ma(43, ",")
        @test_throws MethodError FormsPreprocessors.split_ma(:symbol, ",")
        @test_throws MethodError FormsPreprocessors.split_ma(["ABCD", ","])
        @test isequal(FormsPreprocessors.split_ma.(["A;B;C;D", "EFG", missing]),
            [["A", "B", "C", "D"], ["EFG"], missing])
        @test_throws MethodError FormsPreprocessors.split_ma([missing])
    end


end