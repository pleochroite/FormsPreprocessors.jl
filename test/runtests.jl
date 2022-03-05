using FormsPreprocessors
using Test
using DataFrames, DataFramesMeta

function df()
    DataFrame(bt = ["A", "A", "O", "AB", "B", "B", "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])
end

function df_missing()
    DataFrame(bt = ["A", "A", "O", "AB", "B", missing, "B", "C", missing],
        rh = ["+", "-", missing, "+", "+", missing, "+", "+", missing])
end

function df_nest()
    DataFrame(bt = ["A", ["A", "AB"], "O", ["AB", "B", "B"], "K", "B", "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])
end

function df_nest_missing()
    DataFrame(bt = ["A", ["A", "M"], "O", ["AB", missing, "B"], "K", missing, "C"],
        rh = ["+", "-", "+", "+", "+", "+", "+"])
end

function df_multibyte()
    DataFrame(id = collect(1:6),
        作家名 = ["太宰 治", "宮沢 賢治", "夏目 漱石", "芥川 竜之介", "中島 敦", "夢野 久作"],
        作品名 = ["走れメロス", ["〔雨ニモマケズ〕", "銀河鉄道の夜"], 
            ["こころ", "吾輩は猫である", "夢十夜"], "羅生門", "山月記", missing])
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

    name_kanji =  ["太宰 治", "宮沢 賢治", "夏目 漱石", "芥川 竜之介", "中島 敦", "夢野 久作"]
    name_hiragana = ["だざい おさむ", "みやざわ けんじ", "なつめ そうせき", 
        "あくたがわ りゅうのすけ", "なかじま あつし", "ゆめの きゅうさく"]
    name_to_hiragana = Dict(["太宰 治" => "だざい おさむ", "宮沢 賢治" => "みやざわ けんじ", "夏目 漱石" => "なつめ そうせき",
        "芥川 竜之介" => "あくたがわ りゅうのすけ", "中島 敦" => "なかじま あつし", "夢野 久作" => "ゆめの きゅうさく"])


    work_kanji = ["走れメロス", "夢十夜", "羅生門"]
    work_hiragana = ["はしれめろす", "ゆめじゅうや", "らしょうもん"]
    work_to_hiragana = Dict(["走れメロス" => "はしれめろす", "夢十夜" => "ゆめじゅうや", "羅生門" => "らしょうもん"])

    
    @testset "apply_dict(MaybeString)" begin
        @test FormsPreprocessors.apply_dict(bloodtype, "A") == "1"
        @test FormsPreprocessors.apply_dict(bloodtype, "B") == "2"
        @test FormsPreprocessors.apply_dict(bloodtype, "O") == "3"
        @test FormsPreprocessors.apply_dict(bloodtype, "AB") == "4"
        @test FormsPreprocessors.apply_dict(bloodtype, "K") == "K"
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, 'A') == 'A'
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, :A) == :A
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, 0) == 0
        @test FormsPreprocessors.apply_dict(bloodtype, missing) |> ismissing == true

        @test FormsPreprocessors.apply_dict(name_to_hiragana, "宮沢 賢治") == "みやざわ けんじ"
        @test FormsPreprocessors.apply_dict(name_to_hiragana, "梶井 基次郎") == "梶井 基次郎"
    end

    @testset "apply_dict(Vector)" begin
        @test FormsPreprocessors.apply_dict(bloodtype, ["A", "B"]) == ["1", "2"]
        @test FormsPreprocessors.apply_dict(bloodtype, ["C", "D"]) == ["C", "D"]
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, [])
        @test isequal(FormsPreprocessors.apply_dict(bloodtype, [missing, "A", "AB", "C"]), [missing, "1", "4", "C"])
        @test isequal(FormsPreprocessors.apply_dict(bloodtype, [missing]), [missing])
        
        @test FormsPreprocessors.apply_dict(name_to_hiragana, ["中島 敦", "夢野 久作"]) == 
            ["なかじま あつし", "ゆめの きゅうさく"]
        @test FormsPreprocessors.apply_dict(name_to_hiragana, ["梶井 基次郎", "三好 達治", "夏目 漱石"]) ==
            ["梶井 基次郎", "三好 達治", "なつめ そうせき"]
    end

    @testset "apply_dict(Other types)" begin
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, [1, 2, 3, 4])
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, [:id, :name, :birthday])
        @test_throws MethodError FormsPreprocessors.apply_dict(bloodtype, [missing, :id, 1])
    end

    @testset "convert_answer!" begin
        @test size(FormsPreprocessors.convert_answer!(df(), :bt, bloodtype)) == (7, 2)
        @test FormsPreprocessors.convert_answer!(df(), :bt, bloodtype).bt == ["1", "1", "3", "4", "2", "2", "C"]
        @test FormsPreprocessors.convert_answer!(df(), :bt, bloodtype)[:, 2] == df()[:,2]
        @test FormsPreprocessors.convert_answer!(df(), :rh, bloodtype) == df()
        @test isequal(FormsPreprocessors.convert_answer!(df_missing(), :bt, bloodtype).bt, ["1", "1", "3", "4", "2", missing, "2", "C", missing])
        @test FormsPreprocessors.convert_answer!(df_nest(), :bt, bloodtype) == df_nest_cv
        @test isequal(FormsPreprocessors.convert_answer!(df_nest_missing(), :bt, bloodtype), df_nest_m_cv)
        @test isequal(FormsPreprocessors.convert_answer!(df_multibyte(), :作家名, name_to_hiragana).作家名, 
            name_hiragana)
        @test isequal(FormsPreprocessors.convert_answer!(df_multibyte(), :作品名, work_to_hiragana).作品名,
            ["はしれめろす", ["〔雨ニモマケズ〕", "銀河鉄道の夜"], 
            ["こころ", "吾輩は猫である", "ゆめじゅうや"], "らしょうもん", "山月記", missing])
    end

    @testset "conversion_dict" begin
        @test typeof(FormsPreprocessors.conversion_dict(ks, vs)) == Dict{String, String}
        @test FormsPreprocessors.conversion_dict(ks, vs) == bloodtype
        @test length(FormsPreprocessors.conversion_dict(ks, vs[1:3])) == 3
        @test_logs (:warn, ) FormsPreprocessors.conversion_dict(ks, vs[1:3])
        @test_logs (:warn, ) FormsPreprocessors.conversion_dict(ks, [])
        @test length(FormsPreprocessors.conversion_dict([], vs)) == 0
        @test FormsPreprocessors.conversion_dict([], []) == Dict([])
        @test_logs (:error, ) FormsPreprocessors.conversion_dict([], [])
        @test_throws ErrorException FormsPreprocessors.conversion_dict(["A", "B", "A"], ["C", "D", "E"])
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

        # testing multibyte vectors
        @test FormsPreprocessors.renaming_dict(name_kanji, name_hiragana) == name_to_hiragana
    end

    @testset "recode!" begin
        @test recode!(df(), :bt, ks, vs) == df_cv
        @test isequal(recode!(df_missing(), :bt, ks, vs), df_missing_cv)
        @test recode!(df_nest(), :bt, ks, vs) == df_nest_cv
        @test isequal(recode!(df_nest_missing(), :bt, ks, vs), df_nest_m_cv)
        @test recode!(df(), :bt, ks, ["1", "2", "3"]).bt == ["1", "1", "3", "other", "2", "2", "C"]
        @test isequal(recode!(df_missing(), :bt, ks, vs[1:3]).bt, 
            ["1", "1", "3", "other", "2", missing, "2", "C", missing])
        @test isequal(recode!(df_nest_missing(), :bt, ks, vs[1:3]).bt,
            ["1", ["1", "M"], "3", ["other", missing, "2"], "K", missing, "C"])
        @test isequal(recode!(df_nest_missing(), :bt, ks).bt, 
            ["other", ["other", "M"], "other", ["other", missing, "other"], "K", missing, "C"])
        
        @test recode!(df(), :bt, ks, vs[1:3], "no answer").bt == ["1", "1", "3", "no answer", "2", "2", "C"]

        # testing multibyte data
        @test recode!(df_multibyte(), :作家名, name_kanji, name_hiragana).作家名 == name_hiragana
        @test isequal(recode!(df_multibyte(), :作品名, work_kanji, work_hiragana[1:2], "その他").作品名, 
            ["はしれめろす", ["〔雨ニモマケズ〕", "銀河鉄道の夜"],
            ["こころ", "吾輩は猫である", "ゆめじゅうや"], "その他", "山月記", missing])
    end


    sent = "abc;def;ghi;jklm"
    qbf = "A quick brown fox jumps over the lazy dog."
    sent_multibyte = "天下後世をいかにせばやなど、何彼につけて呼ぶ人あるを見たる時、こは自己をいかにせばやの意なるべしと、われは思へり。"

    @testset "split_ma" begin
        @test FormsPreprocessors.split_ma("ab,cd,e", ",") == ["ab", "cd", "e"]
        @test FormsPreprocessors.split_ma(sent) == ["abc", "def", "ghi", "jklm"]
        @test FormsPreprocessors.split_ma("abcdefghij", "fg") == ["abcde", "hij"]
        @test FormsPreprocessors.split_ma(qbf) == [qbf]
        @test FormsPreprocessors.split_ma(sent_multibyte, "、") == 
            ["天下後世をいかにせばやなど", "何彼につけて呼ぶ人あるを見たる時",
                "こは自己をいかにせばやの意なるべしと", "われは思へり。"]
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

    function df_fruit()
        DataFrame(fruit = ["apple;orange", "orange;melon;lemon",
            "apple", "lemon;apple", "kiwi;melon", "kiwi;apple;orange"],
            price = [250, 890, 150, 240, 800, 350])
    end

    function df_fruit_missing()
        DataFrame(fruit = ["apple;orange", "orange;melon;lemon",
            "apple", missing, "kiwi;melon", "kiwi;apple;orange"],
        price = [250, 890, 150, missing, 800, 350])
    end

    function df_fruit_empty()
        DataFrame(fruit = ["apple;orange", "orange;melon;lemon",
            "apple", "lemon;apple", "", "kiwi;apple;orange"],
        price = [250, 890, 150, 150, 0, 350])
    end

    function df_fruit_missing_empty()
        DataFrame(fruit = ["apple;orange", "orange;melon;lemon",
            "", "lemon;apple", missing, "kiwi;apple;orange"],
        price = [250, 890, 0, 240, missing, 350])
    end

    function df_fruit_multibyte()
        DataFrame(果物 = ["りんご;みかん", "みかん;メロン;レモン",
            "", "レモン;りんご", missing, "キウィ;りんご;みかん"],
            価格 = [250, 890, 0, 240, missing, 350])
    end

    @testset "answers_to_dummy" begin
        @test FormsPreprocessors.answers_to_dummy("apple", df_fruit().fruit) == ["yes", "no", "yes", "yes", "no", "yes"]
        @test_throws MethodError FormsPreprocessors.answers_to_dummy("orange", df_fruit().price)
        @test_throws ArgumentError FormsPreprocessors.answers_to_dummy("kiwi", df_fruit().store)
        @test isequal(FormsPreprocessors.answers_to_dummy("orange", df_fruit_missing().fruit), 
            ["yes", "yes", "no", missing, "no", "yes"])
        @test FormsPreprocessors.answers_to_dummy("kiwi", df_fruit_empty().fruit) == 
            ["no", "no", "no", "no", "no", "yes"]
        @test isequal(FormsPreprocessors.answers_to_dummy("orange", df_fruit_missing_empty().fruit), 
            ["yes", "yes", "no", "no", missing, "yes"])
        @test isequal(FormsPreprocessors.answers_to_dummy("みかん", df_fruit_multibyte().果物),
            ["yes", "yes", "no", "no", missing, "yes"])
        @test_throws MethodError FormsPreprocessors.answers_to_dummy("apple", [["apple"], "apple"])
    end

    @testset "onehot" begin

        ord = ["orange", "apple", "lemon", "kiwi", "melon"]

        @test onehot(df_fruit(), :fruit; ordered_answers=ord)[:,1] ==
            ["yes", "yes", "no", "no", "no", "yes"]
        @test onehot(df_fruit(), :fruit)[:,1] == ["yes", "no", "yes", "yes", "no", "yes"]
        @test size(onehot(df_fruit(), :fruit)) == (6,5)

        r_empty = onehot(df_fruit_empty(), :fruit; ordered_answers=ord)
        @test size(r_empty) == (6, 5)
        @test all(x -> (x == "no"), r_empty[5,:])
        @test all(x -> !(ismissing(x)), r_empty[2,:])
        
        r_missing = onehot(df_fruit_missing(), :fruit, ordered_answers=ord)
        @test size(r_missing) == (6, 5)
        @test all(x -> ismissing(x), r_missing[4,:])
        @test all(x -> !(ismissing(x)), r_missing[5,:])
        
        r_empty_missing = onehot(df_fruit_missing_empty(), :fruit, ordered_answers=ord)
        @test size(r_empty_missing) == (6, 5)
        @test all(x -> ismissing(x), r_empty_missing[5,:])
        @test all(x -> !(ismissing(x)), r_empty_missing[1,:])
        @test all(x -> (x == "no"), r_empty_missing[3,:])

        r_empty_missing_apricot = onehot(df_fruit_missing_empty(), :fruit, ordered_answers=vcat(ord, "apricot"))
        @test size(r_empty_missing_apricot) == (6, 6)
        @test all(x -> ismissing(x), r_empty_missing_apricot[5,:])
        @test all(x -> !(ismissing(x)), r_empty_missing_apricot[1,:])
        @test all(x -> (x == "no"), r_empty_missing_apricot[3,:])
        @test isequal(r_empty_missing_apricot[:,6], ["no", "no", "no", "no", missing, "no"])

        r_multibyte = onehot(df_fruit_multibyte(), :果物; 
            ordered_answers=["みかん", "りんご", "レモン", "メロン", "キウィ", "あんず"])
        @test size(r_multibyte) == (6, 6)
        @test all(x -> ismissing(x), r_multibyte[5,:])
        @test collect(r_multibyte[1,:]) == ["yes", "yes", "no", "no", "no", "no"]
        @test all(x -> (x == "no"), r_multibyte[3,:])
        @test isequal(r_multibyte[:,6], ["no", "no", "no", "no", missing, "no"])

        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :fruit;
            ordered_answers = ["apple", "lemon", "melon"])
        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :fruit;
            ordered_answers = ["apple", "apple", "lemon", "melon", "orange"])
        @test_throws MethodError onehot(df_fruit_missing_empty(), :price; 
            ordered_answers = ord)
        @test_throws MethodError onehot(df_fruit_missing_empty(), :price;
            ordered_answers = [])
        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :store)
    end

    @testset "concatenate" begin
        @test concatenate("Apple", "Orange", delim=",") == "Apple,Orange"
        @test concatenate("Apple", "Orange") == "Apple;Orange"
        @test concatenate("Apple", missing, delim=",") == "Apple"
        @test concatenate("Apple", missing) == "Apple"
        @test concatenate(missing, "Orange", delim=",") == "Orange"
        @test concatenate(missing, "Orange") == "Orange"
        @test ismissing(concatenate(missing, missing; delim=","))
        @test ismissing(concatenate(missing, missing))
        @test concatenate("", "Orange"; delim=",") == ",Orange"
        @test concatenate("Apple", ""; delim=",") == "Apple,"
        @test concatenate("", ""; delim="@") == "@"
        @test concatenate("蘋果", "芒果";delim="和") == "蘋果和芒果"
        @test concatenate("蘋果", "芒果";delim="纊") == "蘋果纊芒果"

    end

    
end