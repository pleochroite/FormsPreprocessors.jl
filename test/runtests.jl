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

    name_kanji = ["太宰 治", "宮沢 賢治", "夏目 漱石", "芥川 竜之介", "中島 敦", "夢野 久作"]
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
        @test FormsPreprocessors.apply_dict(bloodtype, 'A') == 'A'
        @test FormsPreprocessors.apply_dict(bloodtype, :A) == :A
        @test FormsPreprocessors.apply_dict(bloodtype, 0) == 0
        @test FormsPreprocessors.apply_dict(bloodtype, missing) |> ismissing == true

        @test FormsPreprocessors.apply_dict(name_to_hiragana, "宮沢 賢治") == "みやざわ けんじ"
        @test FormsPreprocessors.apply_dict(name_to_hiragana, "梶井 基次郎") == "梶井 基次郎"
    end

    @testset "apply_dict(Vector)" begin
        @test FormsPreprocessors.apply_dict(bloodtype, ["A", "B"]) == ["1", "2"]
        @test FormsPreprocessors.apply_dict(bloodtype, ["C", "D"]) == ["C", "D"]
        @test FormsPreprocessors.apply_dict(bloodtype, []) == []
        @test isequal(FormsPreprocessors.apply_dict(bloodtype, [missing, "A", "AB", "C"]), [missing, "1", "4", "C"])
        @test isequal(FormsPreprocessors.apply_dict(bloodtype, [missing]), [missing])

        @test FormsPreprocessors.apply_dict(name_to_hiragana, ["中島 敦", "夢野 久作"]) ==
              ["なかじま あつし", "ゆめの きゅうさく"]
        @test FormsPreprocessors.apply_dict(name_to_hiragana, ["梶井 基次郎", "三好 達治", "夏目 漱石"]) ==
              ["梶井 基次郎", "三好 達治", "なつめ そうせき"]
    end

    @testset "apply_dict(Other types)" begin
        @test FormsPreprocessors.apply_dict(bloodtype, [1, 2, 3, 4]) == [1, 2, 3, 4]
        @test FormsPreprocessors.apply_dict(bloodtype, [:id, :name, :birthday]) == [:id, :name, :birthday]
        @test isequal(FormsPreprocessors.apply_dict(bloodtype, [missing, :id, 1]), [missing, :id, 1])
    end

    @testset "convert_answer" begin
        @test isequal(FormsPreprocessors.convert_answer(df_missing(), :bt, :newbt, bloodtype).newbt, ["1", "1", "3", "4", "2", missing, "2", "C", missing])
        @test isequal(FormsPreprocessors.convert_answer(df_nest_missing(), :bt, :newbt, bloodtype).newbt,
            df_nest_m_cv.bt)
        @test isequal(FormsPreprocessors.convert_answer(df_multibyte(), :作家名, :作家名よみがな, name_to_hiragana).作家名よみがな,
            name_hiragana)
        @test isequal(FormsPreprocessors.convert_answer(df_multibyte(), :作品名, :作品名よみがな, work_to_hiragana).作品名よみがな,
            ["はしれめろす", ["〔雨ニモマケズ〕", "銀河鉄道の夜"],
                ["こころ", "吾輩は猫である", "ゆめじゅうや"], "らしょうもん", "山月記", missing])
        @test_throws MethodError FormsPreprocessors.convert_answer([[1 2]; [3 4]], :bt, :newbt, bloodtype)
    end

    @testset "conversion_dict" begin
        @test typeof(FormsPreprocessors.conversion_dict(ks, vs)) == Dict{String,String}
        @test FormsPreprocessors.conversion_dict(ks, vs) == bloodtype
        @test length(FormsPreprocessors.conversion_dict(ks, vs[1:3])) == 3
        @test_logs (:warn,) FormsPreprocessors.conversion_dict(ks, vs[1:3])
        @test_logs (:warn,) FormsPreprocessors.conversion_dict(ks, [])
        @test length(FormsPreprocessors.conversion_dict([], vs)) == 0
        @test FormsPreprocessors.conversion_dict([], []) == Dict([])
        @test_logs (:error,) FormsPreprocessors.conversion_dict([], [])
        @test_throws ArgumentError FormsPreprocessors.conversion_dict(["A", "B", "A"], ["C", "D", "E"])
    end

    @testset "renaming_dict" begin
        @test FormsPreprocessors.renaming_dict(ks, vs) == bloodtype
        @test FormsPreprocessors.renaming_dict(ks, vs[1:3]) == Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "other"])
        @test FormsPreprocessors.renaming_dict(ks, vs[1:3], "その他") == Dict(["A" => "1", "B" => "2", "O" => "3", "AB" => "その他"])
        @test_throws ArgumentError FormsPreprocessors.renaming_dict(ks[1:2], vs)
        @test_throws ArgumentError FormsPreprocessors.renaming_dict([], vs)
        @test FormsPreprocessors.renaming_dict(ks, []) == Dict(["A" => "other", "B" => "other", "O" => "other", "AB" => "other"])
        @test FormsPreprocessors.renaming_dict([], []) == Dict([])
        @test_throws ArgumentError FormsPreprocessors.renaming_dict(["A", "B", "A"], ["1", "2", "3"])
        @test_throws ArgumentError FormsPreprocessors.renaming_dict(["A", "B", "A"], [])
        @test_throws ArgumentError FormsPreprocessors.renaming_dict(["A", "B", "A"], ["1", "2", "1"])
        @test_throws ArgumentError FormsPreprocessors.renaming_dict("foo", ["1", "2", "3"])
        @test_throws MethodError FormsPreprocessors.renaming_dict(ks, "BA", "OTHER")
        @test_throws MethodError FormsPreprocessors.renaming_dict("FOO", "BAR")

        # testing multibyte vectors
        @test FormsPreprocessors.renaming_dict(name_kanji, name_hiragana) == name_to_hiragana
    end

    @testset "recode" begin
        @test size(recode(df(), :bt, :newkey, ks, vs)) == (7, 3)
        @test recode(df(), :bt, :newkey, ks, vs).newkey == df_cv.bt
        @test isequal(recode(df_nest_missing(), :bt, :newkey, ks, vs).newkey, df_nest_m_cv.bt)
        @test isequal(recode(df_nest_missing(), :bt, :newkey, ks, vs[1:3]).newkey,
            ["1", ["1", "M"], "3", ["other", missing, "2"], "K", missing, "C"])
        @test isequal(recode(df_nest_missing(), :bt, :newkey, ks).newkey,
            ["other", ["other", "M"], "other", ["other", missing, "other"], "K", missing, "C"])

        @test recode(df(), :bt, :newkey, ks, vs[1:3]; other = "no answer").newkey ==
              ["1", "1", "3", "no answer", "2", "2", "C"]

        # testing multibyte data
        @test recode(df_multibyte(), :作家名, :作家名よみがな, name_kanji, name_hiragana).作家名よみがな == name_hiragana
        @test isequal(recode(df_multibyte(), :作品名, :作品名よみがな, work_kanji, work_hiragana[1:2], other = "その他").作品名よみがな,
            ["はしれめろす", ["〔雨ニモマケズ〕", "銀河鉄道の夜"],
                ["こころ", "吾輩は猫である", "ゆめじゅうや"], "その他", "山月記", missing])
    end

    @testset "recode_others" begin
        @test recode_others(df(), :bt, :newbt, ks[1:2]).newbt ==
              ["A", "A", "other", "other", "B", "B", "other"]

        d_ma = DataFrame(bt = ["A", ["A", "B", "O"], "O", ["AB", "A"], "B",
                missing, ["B", "K"], "C", missing],
            rh = ["+", "-", missing, "+", "+", missing, "+", "+", missing])
        @test isequal(recode_others(d_ma, :bt, :newbt, ks[1:2]).newbt,
            ["A", ["A", "B", "other"], "other", ["other", "A"], "B",
                missing, ["B", "other"], "other", missing])
    end

    @testset "flat" begin
        @test FormsPreprocessors.flat(["AB", "BC", "CA"]) == ["AB", "BC", "CA"]
        @test FormsPreprocessors.flat([["AB", "M"], "K"]) == ["AB", "M", "K"]
        @test isequal(FormsPreprocessors.flat(["A", [missing, "AB"], "CD", missing]),
            ["A", missing, "AB", "CD", missing])
    end



    function df_matrix()
        DataFrame(q1 = ["1st", "2nd", "3rd", "2nd", "5th"],
            q2 = ["2nd", "3rd", "4th", "4th", "2nd"])
    end

    function df_matrix_missing()
        DataFrame(q1 = ["1st", missing, "3rd", "2nd", "5th"],
            q2 = ["2nd", "3rd", missing, "4th", "2nd"])
    end

    v_from = ["1st", "2nd", "4th", "5th", "3rd"]
    v_to = ["top2", "top2", "bottom2", "bottom2"]

    @testset "recode_matrix" begin
        @test recode_matrix(df_matrix(), [:q1, :q2], v_from, v_to; prefix = "box")[:, 3:4] ==
              DataFrame(box_q1 = ["top2", "top2", "other", "top2", "bottom2"],
            box_q2 = ["top2", "other", "bottom2", "bottom2", "top2"])
        @test isequal(recode_matrix(df_matrix_missing(), [:q1, :q2], v_from, v_to; prefix = "box")[:, 3:4],
            DataFrame(box_q1 = ["top2", missing, "other", "top2", "bottom2"],
                box_q2 = ["top2", "other", missing, "bottom2", "top2"]))
        @test_throws ArgumentError recode_matrix(rename!(df_matrix_missing(), [:q1, :r_q1]), [:q1, :r_q1], v_from, v_to)
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
        DataFrame(fruit = [["apple", "orange"], ["orange", "melon", "lemon"],
                ["apple"], ["lemon", "apple"], ["kiwi", "melon"], ["kiwi", "apple", "orange"]],
            price = [250, 890, 150, 240, 800, 350])
    end

    function df_fruit_missing()
        DataFrame(fruit = [["apple", "orange"], ["orange", "melon", "lemon"],
                ["apple"], missing, ["kiwi", "melon"], ["kiwi", "apple", "orange"]],
            price = [250, 890, 150, missing, 800, 350])
    end

    function df_fruit_empty()
        DataFrame(fruit = [["apple", "orange"], ["orange", "melon", "lemon"],
                ["apple"], ["lemon", "apple"], [""], ["kiwi", "apple", "orange"]],
            price = [250, 890, 150, 150, 0, 350])
    end

    function df_fruit_missing_empty()
        DataFrame(fruit = [["apple", "orange"], ["orange", "melon", "lemon"],
                [""], ["lemon", "apple"], missing, ["kiwi", "apple", "orange"]],
            price = [250, 890, 0, 240, missing, 350])
    end

    function df_fruit_multibyte()
        DataFrame(果物 = [["りんご", "みかん"], ["みかん", "メロン", "レモン"],
                [""], ["レモン", "りんご"], missing, ["キウィ", "りんご", "みかん"]],
            価格 = [250, 890, 0, 240, missing, 350])
    end

    @testset "answers_to_dummy" begin
        @test FormsPreprocessors.answers_to_dummy("apple", df_fruit().fruit) == ["yes", "no", "yes", "yes", "no", "yes"]
        @test FormsPreprocessors.answers_to_dummy("orange", df_fruit().price) ==
              ["no", "no", "no", "no", "no", "no"]
        @test_throws ArgumentError FormsPreprocessors.answers_to_dummy("kiwi", df_fruit().store)
        @test isequal(FormsPreprocessors.answers_to_dummy("orange", df_fruit_missing().fruit),
            ["yes", "yes", "no", missing, "no", "yes"])
        @test FormsPreprocessors.answers_to_dummy("kiwi", df_fruit_empty().fruit) ==
              ["no", "no", "no", "no", "no", "yes"]
        @test isequal(FormsPreprocessors.answers_to_dummy("orange", df_fruit_missing_empty().fruit),
            ["yes", "yes", "no", "no", missing, "yes"])
        @test isequal(FormsPreprocessors.answers_to_dummy("みかん", df_fruit_multibyte().果物),
            ["yes", "yes", "no", "no", missing, "yes"])
    end

    @testset "onehot" begin

        ord = ["orange", "apple", "lemon", "kiwi", "melon"]

        @test onehot(df_fruit(), :fruit; ordered_answers = ord)[:, 3] ==
              ["yes", "yes", "no", "no", "no", "yes"]
        @test onehot(df_fruit(), :fruit)[:, 3] == ["yes", "no", "yes", "yes", "no", "yes"]
        @test size(onehot(df_fruit(), :fruit)) == (6, 7)

        r_empty = onehot(df_fruit_empty(), :fruit; ordered_answers = ord)
        @test size(r_empty) == (6, 7)
        @test all(x -> (x == "no"), r_empty[5, 3:end])
        @test all(x -> !(ismissing(x)), r_empty[2, 3:end])

        r_missing = onehot(df_fruit_missing(), :fruit, ordered_answers = ord)
        @test size(r_missing) == (6, 7)
        @test all(x -> ismissing(x), r_missing[4, 3:end])
        @test all(x -> !(ismissing(x)), r_missing[5, 3:end])

        r_empty_missing = onehot(df_fruit_missing_empty(), :fruit, ordered_answers = ord)
        @test size(r_empty_missing) == (6, 7)
        @test all(x -> ismissing(x), r_empty_missing[5, 3:end])
        @test all(x -> !(ismissing(x)), r_empty_missing[1, 3:end])
        @test all(x -> (x == "no"), r_empty_missing[3, 3:end])

        r_empty_missing_apricot = onehot(df_fruit_missing_empty(), :fruit, ordered_answers = vcat(ord, "apricot"))
        @test size(r_empty_missing_apricot) == (6, 8)
        @test all(x -> ismissing(x), r_empty_missing_apricot[5, 3:end])
        @test all(x -> !(ismissing(x)), r_empty_missing_apricot[1, 3:end])
        @test all(x -> (x == "no"), r_empty_missing_apricot[3, 3:end])
        @test isequal(r_empty_missing_apricot[:, 8], ["no", "no", "no", "no", missing, "no"])

        r_multibyte = onehot(df_fruit_multibyte(), :果物;
            ordered_answers = ["みかん", "りんご", "レモン", "メロン", "キウィ", "あんず"])
        @test size(r_multibyte) == (6, 8)
        @test all(x -> ismissing(x), r_multibyte[5, 3:end])
        @test collect(r_multibyte[1, :]) == [["りんご", "みかん"], 250, "yes", "yes", "no", "no", "no", "no"]
        @test all(x -> (x == "no"), r_multibyte[3, 3:end])
        @test isequal(r_multibyte[:, 8], ["no", "no", "no", "no", missing, "no"])

        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :fruit;
            ordered_answers = ["apple", "lemon", "melon"])
        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :fruit;
            ordered_answers = ["apple", "apple", "lemon", "melon", "orange", "kiwi"])
        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :price;
            ordered_answers = ord)
        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :price;
            ordered_answers = [])
        @test_throws ArgumentError onehot(df_fruit_missing_empty(), :store)
    end

    @testset "concatenate" begin
        @test FormsPreprocessors.concatenate("Apple", "Orange", delim = ",") == "Apple,Orange"
        @test FormsPreprocessors.concatenate("Apple", "Orange") == "Apple;Orange"
        @test FormsPreprocessors.concatenate("Apple", missing, delim = ",") == "Apple"
        @test FormsPreprocessors.concatenate("Apple", missing) == "Apple"
        @test FormsPreprocessors.concatenate(missing, "Orange", delim = ",") == "Orange"
        @test FormsPreprocessors.concatenate(missing, "Orange") == "Orange"
        @test ismissing(FormsPreprocessors.concatenate(missing, missing; delim = ","))
        @test ismissing(FormsPreprocessors.concatenate(missing, missing))
        @test FormsPreprocessors.concatenate("", "Orange"; delim = ",") == ",Orange"
        @test FormsPreprocessors.concatenate("Apple", ""; delim = ",") == "Apple,"
        @test FormsPreprocessors.concatenate("", ""; delim = "@") == "@"
        @test FormsPreprocessors.concatenate("蘋果", "芒果"; delim = "和") == "蘋果和芒果"
        @test FormsPreprocessors.concatenate("蘋果", "芒果"; delim = "纊") == "蘋果纊芒果"
    end

    function df_fruit_g()
        DataFrame(fruit = ["apple;orange", "orange;melon;lemon",
                "apple", "lemon;apple", "kiwi;melon", "kiwi;apple;orange"],
            price = [250, 890, 150, 240, 800, 350],
            gender = ["male", "female", "male", "female", "male", "female"])
    end

    function df_fruit_empty_g()
        DataFrame(fruit = ["apple;orange", "orange;melon;lemon",
                "apple", "lemon;apple", "", "kiwi;apple;orange"],
            price = [250, 890, 150, 150, 0, 350],
            gender = ["male", "female", "male", "female", "male", "female"])
    end

    function df_fruit_missing_g()
        DataFrame(fruit = ["apple;orange", missing, "apple",
                missing, "kiwi;melon", "kiwi;apple;orange"],
            price = [250, 890, 150, missing, 800, 350],
            gender = ["male", "female", "male", missing, missing, "female"])
    end

    function df_fruit_missing_empty_g()
        DataFrame(fruit = ["apple;orange", missing, "",
                "lemon;apple", missing, "kiwi;apple;orange"],
            price = [250, 890, 0, 240, missing, 350],
            gender = ["male", "female", "male", "female", missing, missing])
    end

    function df_fruit_multibyte_g()
        DataFrame(果物 = ["りんご;みかん", missing, "",
                "レモン;りんご", missing, "キウィ;りんご;みかん"],
            価格 = [250, 890, 0, 240, missing, 350],
            性別 = ["男性", "女性", "男性", missing, missing, "女性"])
    end


    @testset "direct_product" begin
        @test direct_product(df_fruit_g(), :fruit, :gender, :newcol; delim = ",").newcol ==
              ["apple;orange,male", "orange;melon;lemon,female", "apple,male",
            "lemon;apple,female", "kiwi;melon,male", "kiwi;apple;orange,female"]
        @test direct_product(df_fruit_empty_g(), :fruit, :gender, :newcol; delim = ",").newcol ==
              ["apple;orange,male", "orange;melon;lemon,female", "apple,male",
            "lemon;apple,female", ",male", "kiwi;apple;orange,female"]
        @test isequal(direct_product(df_fruit_missing_g(), :fruit, :gender, :newcol; delim = ",").newcol,
            ["apple;orange,male", "female", "apple,male", missing, "kiwi;melon", "kiwi;apple;orange,female"])
        @test isequal(direct_product(df_fruit_missing_empty_g(), :fruit, :gender, :newcol; delim = ",").newcol,
            ["apple;orange,male", "female", ",male", "lemon;apple,female", missing, "kiwi;apple;orange"])
        @test isequal(direct_product(df_fruit_missing_empty_g(), :fruit, :gender, :newcol).newcol,
            ["apple;orange_male", "female", "_male", "lemon;apple_female", missing, "kiwi;apple;orange"])
        @test isequal(direct_product(df_fruit_missing_empty_g(), :gender, :fruit, :newcol).newcol,
            ["male_apple;orange", "female", "male_", "female_lemon;apple", missing, "kiwi;apple;orange"])
        @test isequal(direct_product(df_fruit_multibyte_g(), :果物, :性別, :新変数).新変数,
            ["りんご;みかん_男性", "女性", "_男性", "レモン;りんご", missing, "キウィ;りんご;みかん_女性"])

        @test_throws ArgumentError direct_product(df_fruit_missing_empty_g(), :gender, :gender, :double)
        @test_throws ArgumentError direct_product(df_fruit_g(), :fruit, :gender, :gender)
    end

    @testset "get_at" begin
        v = ["A", "B", "C", "D", "E"]
        @test FormsPreprocessors.get_at(v, 2) == "B"
        @test ismissing(FormsPreprocessors.get_at(v, missing))
        @test_throws BoundsError FormsPreprocessors.get_at(v, 6)
        @test_throws BoundsError FormsPreprocessors.get_at(v, 0)

        vm = [:A, :B, missing, :D]
        @test FormsPreprocessors.get_at(vm, 4) == :D
        @test ismissing(FormsPreprocessors.get_at(vm, 3))
        @test_throws BoundsError FormsPreprocessors.get_at(vm, 5)
        @test ismissing(FormsPreprocessors.get_at(vm, missing))
    end

    ranges = [(-Inf, 0), (0, 1), (1, 5 // 3), (5 // 3, 3.4), (3.4, 5), (5, Inf)]

    @testset "falls_in" begin
        @test FormsPreprocessors.falls_in(-1, ranges[1])
        @test !(FormsPreprocessors.falls_in(0, ranges[1]))
        @test FormsPreprocessors.falls_in(0, ranges[2])
        @test FormsPreprocessors.falls_in(3.45, ranges[5])

        @test FormsPreprocessors.falls_in(1.6666666666666666, ranges[3])
        @test FormsPreprocessors.falls_in(1.6666666666666667, ranges[4])
        @test FormsPreprocessors.falls_in(-Inf, ranges[1])
        @test FormsPreprocessors.falls_in(Inf, ranges[end])
    end

    @testset "find_range" begin
        @test FormsPreprocessors.find_range(-1, ranges) == 1
        @test FormsPreprocessors.find_range(0, ranges) == 2
        @test FormsPreprocessors.find_range(3.45, ranges) == 5
        @test FormsPreprocessors.find_range(5e4, ranges) == 6
        @test FormsPreprocessors.find_range(5 // 3, ranges) == 4

        @test ismissing(FormsPreprocessors.find_range(missing, ranges))
        @test FormsPreprocessors.find_range(-Inf, ranges) == 1
        @test FormsPreprocessors.find_range(Inf, ranges) == 6
    end

    prices = [100, 200, 300, 500]
    prices_perm = [500, 200, 100, 300]
    @testset "discretize" begin
        @test discretize(df_fruit(), :price, prices, "price_class";
            newcodes = ["N", "L", "M", "H", "VH"]).price_class == ["M", "VH", "L", "M", "VH", "H"]
        @test discretize(df_fruit_empty(), :price, prices, "price_class";
            newcodes = ["N", "L", "M", "H", "VH"]).price_class == ["M", "VH", "L", "L", "N", "H"]
        @test isequal(discretize(df_fruit_missing(), :price, prices, "price_class";
                newcodes = ["N", "L", "M", "H", "VH"]).price_class,
            ["M", "VH", "L", missing, "VH", "H"])
        @test isequal(discretize(df_fruit_missing_empty(), :price, prices, "price_class";
                newcodes = ["N", "L", "M", "H", "VH"]).price_class,
            ["M", "VH", "N", "M", missing, "H"])
        @test isequal(discretize(df_fruit_missing_empty(), :price, prices_perm),
            discretize(df_fruit_missing_empty(), :price, prices))

        @test isequal(discretize(df_fruit_multibyte(), :価格, prices, "価格区分";
                newcodes = ["無", "低", "中", "高", "超高"]).価格区分,
            ["中", "超高", "無", "中", missing, "高"])

        @test_throws ArgumentError discretize(df_fruit(), :price, [100, 200, 300, 200, 500])
        @test_throws ArgumentError discretize(df_fruit(), :price, prices, "fruit")
        @test_throws ArgumentError discretize(df_fruit(), :price, prices; newcodes = ["N", "L", "M", "H"])
    end



end