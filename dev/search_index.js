var documenterSearchIndex = {"docs":
[{"location":"references/","page":"References","title":"References","text":"DocTestSetup = quote\n    using DataFrames\n    using FormsPreprocessors\nend","category":"page"},{"location":"references/#FormsPreprocessors-Reference","page":"References","title":"FormsPreprocessors Reference","text":"","category":"section"},{"location":"references/","page":"References","title":"References","text":"Modules=[FormsPreprocessors]\nOrder=[:function, :type]","category":"page"},{"location":"references/#FormsPreprocessors.direct_product-Tuple{DataFrames.DataFrame, Any, Any, Any}","page":"References","title":"FormsPreprocessors.direct_product","text":"direct_product(df, col1, col2, newcol)\n\nConcatenates values of col1 and col2, which is stored in newcol.\n\nExample\n\njulia> df = DataFrame(q1 = [\"young\", \"old\", \"young\", \"young\"],\n    q2 = [\"no\", \"no\", \"no\", \"yes\"])\njulia> direct_product(df, :q1, :q2, :q1xq2)\n\nRow  │ q1      q2      q1xq2   \n     │ String  String  String  \n─────┼─────────────────────────\n1    │ young     no      young_no\n2    │ old      no      old_no\n3    │ young     no      young_no\n4    │ young     yes     young_yes\n\nIf either value is missing, the other value itself is stored. If either value is \"\", the other value with delim is stored.\n\nExample\n\njulia> df = DataFrame(q1 = [\"young\", missing, \"young\", \"\"],\n    q2 = [\"no\", \"no\", missing, \"yes\"])\njulia> direct_product(df, :q1, :q2, :q1xq2)\n4x3 DataFrame\nRow  │ q1       q2       q1xq2  \n     │ String?  String?  String \n─────┼──────────────────────────\n1    │ young      no       young_no\n2    │ missing  no       no\n3    │ young      missing  young\n4    │          yes      _yes\n\n\n\n\n\n","category":"method"},{"location":"references/#FormsPreprocessors.discretize","page":"References","title":"FormsPreprocessors.discretize","text":"discretize(df, key, thresholds, newcol=\"class_$(String(key))\"; newcodes=[])\n\nClassify numerical answers to classes defined by thresholds. The number of classes is length(thresholds) + 1, because the ranges to be  (-Inf, thresholds[1]), [thresholds[1], thresholds[2]), ..., [thresholds[end], Inf]. Therefore, the length of newcodes must be length(thresholds) + 1.\n\nExample\n\njulia> df = DataFrame(expense=[100, 250, 300, 1000, 150])\njulia> discretize(df, :expense, [100, 300, 500]; newcodes=[\"No\", \"Low\", \"Middle\", \"High\"])\n5x2 DataFrame\nRow  │ expense  class_expense \n     │ Int64    String        \n─────┼────────────────────────\n1    │     100  Low\n2    │     250  Low\n3    │     300  Middle\n4    │    1000  High\n5    │     150  Low\n\n\n\n\n\n","category":"function"},{"location":"references/#FormsPreprocessors.onehot-Tuple{DataFrames.DataFrame, Any}","page":"References","title":"FormsPreprocessors.onehot","text":"onehot(df, key; ordered_answers=[])\n\nPerforms one-hot encoding on key column. The column is expected to be of vectors, as split_mc_col! generates. If you want to sort columns generated, specify ordered_answers. If not ordered_answers specified, columns are ordered by value appearance.\n\nExample\n\njulia> df = DataFrame(item=[\"Apple;Orange\", \"Tomato\", \"Tomato;Pepper\"])\njulia> onehot(df, :item; ordered_answers=[\"Tomato\", \"Pepper\", \"Apple\", \"Orange\"])\n3x5 DataFrame\nRow  │ item                  item_Tomato  item_Pepper  item_Apple  item_Orange \n     │ Array…                Any          Any          Any         Any         \n─────┼─────────────────────────────────────────────────────────────────────────────────────\n1    │ [\"Apple\", \"Orange\"]   no           no           yes         yes\n2    │ [\"Tomato\"]            yes          no           no          no\n3    │ [\"Tomato\", \"Pepper\"]  yes          yes          no          no\n\n\n\n\n\n","category":"method"},{"location":"references/#FormsPreprocessors.recode","page":"References","title":"FormsPreprocessors.recode","text":"recode(df, key, newkey, vec_from, vec_to=[]; other=\"other\")\n\nRecodes values in key column with values in vec_from into corresponding vec_to values,  which are stored in newkey column. Items not in vec_from keep original values.  If vec_to is shorter than vec_from, the last values are recoded to other. If you want to recode all irregular answers such as 'other:______' to others,  use recode_others. If you want to recode columns with common choices such as choices to matrix type  question, use recode_matrix.\n\nExample\n\njulia> df = DataFrame(item = [\"Apple\", \"Orange\", \"Tomato\", \"Pepper\"])\njulia> recode(df, :item, :newitem, [\"Apple\", \"Orange\", \"Pepper\"], [\"Fruit\", \"Fruit\"])\n4x2 DataFrame\nRow  │ item    newitem \n     │ String  String  \n─────┼─────────────────\n1    │ Apple   Fruit\n2    │ Orange  Fruit\n3    │ Tomato  Tomato\n4    │ Pepper  other\n\nYou can recode values stored in a column of vectors which can be generated using split_mc_col!.\n\n!!! Note\n\nIf you recode a column of vectors, single-value answer must be vectorized, \nas [`split_mc_col!`](@ref) does.\n\nExample\n\njulia> df = DataFrame(item = [[\"Apple\", \"Orange\"], [\"Tomato\"], [\"Tomato\", \"Pepper\"]])\njulia> recode(df, :item, :newitem, [\"Tomato\", \"Pepper\"], [\"Vegitable\", \"Spice\"])\n3x2 DataFrame\nRow  │ item                  newitem                \n     │ Array…                Array…                 \n─────┼──────────────────────────────────────────────\n1    │ [\"Apple\", \"Orange\"]   [\"Apple\", \"Orange\"]\n2    │ [\"Tomato\"]            [\"Vegitable\"]\n3    │ [\"Tomato\", \"Pepper\"]  [\"Vegitable\", \"Spice\"]\n\nSee also recode_others, recode_matrix\n\n\n\n\n\n","category":"function"},{"location":"references/#FormsPreprocessors.recode_matrix","page":"References","title":"FormsPreprocessors.recode_matrix","text":"recode_matrix(df, keys, vec_from, vec_to=[]; other=\"other\", prefix=\"r\")\n\nRecodes values of vec_from in keys columns to vec_to values. New values from column :foo are stored in corresponding column named :prefix_foo. \n\nExample\n\njulia> df = DataFrame(q1=[\"Strongly agree\", \"Disagree\", \"Agree\", \"Neutral\", \"Strongly disagree\"], \n    q2 = [\"Disagree\", \"Strongly disagree\", \"Neutral\", \"Agree\", \"Agree\"])\njulia> recode_matrix(df, [:q1, :q2], [\"Strongly agree\", \"Agree\", \"Disagree\", \"Strongly disagree\"], \n[\"t2b\", \"t2b\", \"b2b\", \"b2b\"])\n5x4 DataFrame\nRow  │ q1                 q2                 r_q1     r_q2    \n     │ String             String             String   String  \n─────┼────────────────────────────────────────────────────────\n1    │ Strongly agree     Disagree           t2b      b2b\n2    │ Disagree           Strongly disagree  b2b      b2b\n3    │ Agree              Neutral            t2b      Neutral\n4    │ Neutral            Agree              Neutral  t2b\n5    │ Strongly disagree  Agree              b2b      t2b\n\nSee also recode\n\n\n\n\n\n","category":"function"},{"location":"references/#FormsPreprocessors.recode_others-Tuple{DataFrames.DataFrame, Any, Any, Vector{String}}","page":"References","title":"FormsPreprocessors.recode_others","text":"recode_others(df, key, newkey, regular_answers; other=\"other\")\n\nRecodes all appeared values in key column but in regular_answers into other,  which are stored in newkey column.\n\nExample\n\njulia> df = DataFrame(item = [\"Apple\", \"Orange\", \"Tomato\", \"Pepper\"])\njulia> recode_others(df, :item, :newitem, [\"Apple\", \"Orange\"])\n\nRow  │ item    newitem \n     │ String  String  \n─────┼─────────────────\n1    │ Apple   Apple\n2    │ Orange  Orange\n3    │ Tomato  other\n4    │ Pepper  other\n\nSee also recode \n\n\n\n\n\n","category":"method"},{"location":"references/#FormsPreprocessors.split_mc_col!-Tuple{DataFrames.DataFrame, Any}","page":"References","title":"FormsPreprocessors.split_mc_col!","text":"split_mc_col!(df, key; delim=\";\")\n\nMutates key columns with values of \"delim-concatenated\" MA answers into column with vectors.\n\nExample\n\njulia> df = DataFrame(item=[\"Apple;Orange\", \"Tomato\", \"Tomato;Pepper\"])\njulia> split_mc_col!(df, :item)\n3x1 DataFrame\nRow  │ item                              \n     │ Array…                            \n─────┼───────────────────────────────────\n1    │ [\"Apple\", \"Orange\"]\n2    │ [\"Tomato\"]\n3    │ [\"Tomato\", \"Pepper\"]\n\n\n\n\n\n","category":"method"},{"location":"manual/#Manual","page":"Manual","title":"Manual","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"FormsPreprocessors is a tiny preprocessing tool for questionnaire data (such as one obtained using Google Forms) to convert 'raw' data to ready-to-analyze style.  It provides functions of recoding, one-hot encoding, concatenating columns, and splitting multiple choice(MC) responses. Let's see how to use it.","category":"page"},{"location":"manual/#Reading-a-Data","page":"Manual","title":"Reading a Data","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"As FormsPreprocessors is built on the sholder of DataFrames.jl, read data into a DataFrame.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"julia> using DataFrames, DataFramesMeta, Chain, CSV\n\njulia> using FormsPreprocessors\n\njulia> d = CSV.read(\"../../example/sample_data.csv\", DataFrame)\n20×15 DataFrame\n Row │ timestamp                    Gender             Age      Alcohol        ⋯\n     │ String31                     String31           String7  String?        ⋯\n─────┼──────────────────────────────────────────────────────────────────────────\n   1 │ 2022/03/10 1:19:08 ?? GMT+9  Male               -19      missing        ⋯\n   2 │ 2022/03/10 1:19:58 ?? GMT+9  Female             20-34    Cidre;Cognac\n   3 │ 2022/03/10 1:20:27 ?? GMT+9  Non-binary         35-49    Beer;Whisky\n   4 │ 2022/03/10 1:21:05 ?? GMT+9  Male               -19      missing\n   5 │ 2022/03/10 1:21:49 ?? GMT+9  Prefer not to say  50-      Beer           ⋯\n   6 │ 2022/03/10 1:22:26 ?? GMT+9  Asexual            -19      missing\n   7 │ 2022/03/10 1:25:04 ?? GMT+9  Female             20-34    Beer;Cidre\n   8 │ 2022/03/10 1:25:38 ?? GMT+9  Female             35-49    Sake\n  ⋮  │              ⋮                       ⋮             ⋮                    ⋱\n  14 │ 2022/03/10 1:33:09 ?? GMT+9  Male               35-49    Cidre;Cognac;W ⋯\n  15 │ 2022/03/10 1:33:52 ?? GMT+9  Male               20-34    Sake\n  16 │ 2022/03/10 1:34:49 ?? GMT+9  Female             20-34    None\n  17 │ 2022/03/10 1:35:28 ?? GMT+9  Female             50-      Beer;Cidre;Win\n  18 │ 2022/03/10 1:36:11 ?? GMT+9  Female             35-49    Beer;Cidre;Cog ⋯\n  19 │ 2022/03/10 1:36:30 ?? GMT+9  Female             -19      missing\n  20 │ 2022/03/10 1:37:04 ?? GMT+9  Male               20-34    Beer\n                                                   12 columns and 5 rows omitted","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Google Forms data often contains whitespaces and brackets in field names, we recommend to rename them.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"rename!(d, [\"timestamp\", \"Gender\", \"Age\", \"Alcohol\", \"Fruit\", \"Price\",\n    \"Lastvisit_SM\", \"Lastvisit_CVS\", \"Lastvisit_DS\", \"LastVisit_Glos\",\n    \"Studied_English\", \"Studied_Math\", \"Studied_Science\", \"Studied_Arts\", \"Studied_Programming\"])","category":"page"},{"location":"manual/#Split-MC-answers","page":"Manual","title":"Split MC answers","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"MC response is concatenated with \";\" in Google Forms data as you see in the Alcohol column.  First, we need to split these responses into vectors for the processes following.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"split_mc_col!(d, :Alcohol)","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Of course, you can use pipe so to split all MC columns.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"@chain d begin\n    split_mc_col!(_, :Fruit)\n    split_mc_col!(_, :Alcohol)\n    split_mc_col!(_, :Studied_English)\n    split_mc_col!(_, :Studied_Math)\n    split_mc_col!(_, :Studied_Science)\n    split_mc_col!(_, :Studied_Arts)\n    split_mc_col!(_, :Studied_Programming)\nend","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"note: \nNote that split_mc_col! mutates the column specified. When split_mc_col! is applied to a vectorized column, the column remains unchanged. Functions other than split_mc_col! append new columns to original DataFrame.","category":"page"},{"location":"manual/#Recoding-open-responses","page":"Manual","title":"Recoding open responses","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"Next, it is typical to recode open responses to one value, say, \"other\", because open responses for \"other:______\" form are stored as respondent input. ","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"Note that fourth argument for recode_others is a vector of responses which you want to keep unchanged. All appeared values but in the vector will be recoded into other=\"other\".","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"    recode_others(d, :Alcohol, :newAlcohol, \n        [\"Beer\", \"Cidre\", \"Cognac\", \"Wine\", \"Whisky\", \"None\"])","category":"page"},{"location":"manual/#Recoding-choices-to-arbitrary-values","page":"Manual","title":"Recoding choices to arbitrary values","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"If you want to recode values to new ones, use recode of which fourth argument vec_from is a vector of raw values, and fifth vec_to is a vector of recoded ones. It recodes as vec_from[1] => vec_to[1], vec_from[2] => vec_to[2], .... If vec_to is shorter than vec_from, the leftovers in vec_from are recoded to other. Therefore, all appeared values but in vec_from remain unchanged, which is contrary to preceding recode_others.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"recode(d, :Age, :newAge, [\"-19\", \"20-34\", \"35-49\", \"50-\"], [\"Teen\", \"Young\", \"Middle\", \"Old\"])","category":"page"},{"location":"manual/#Recoding-matrix-type-single-responses","page":"Manual","title":"Recoding matrix-type single responses","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"recode_matrix supports recoding multiple columns using identical conversion dictionary. ","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"ns = Symbol.(names(d))\nrecode_matrix(d, ns[7:10], \n    [\"Within a week\", \"Within a month\", \"Within 3 months\", \"More than 3 months ago\", \"Never\"],\n    [\"Recent\", \"Recent\", \"Silent\", \"Silent\", \"Never\"])","category":"page"},{"location":"manual/#Concatenating-multiple-values","page":"Manual","title":"Concatenating multiple values","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"You can obtain concatenation of two responses, such as \"Male-Young\", \"Female-Old\", using direct_product. ","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"direct_product(d, :Gender, :Age, :GenderxAge; delim=\"-\")","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"20×16 DataFrame\n Row │ timestamp                    Gender             Age      Alcohol    \n    ⋯\n     │ String31                     String31           String7  String?    \n    ⋯\n─────┼─────────────────────────────────────────────────────────────────────\n─────\n   1 │ 2022/03/10 1:19:08 ?? GMT+9  Male               -19      missing    \n    ⋯\n   2 │ 2022/03/10 1:19:58 ?? GMT+9  Female             20-34    Cidre;Cogna\nc\n   3 │ 2022/03/10 1:20:27 ?? GMT+9  Non-binary         35-49    Beer;Whisky\n   4 │ 2022/03/10 1:21:05 ?? GMT+9  Male               -19      missing\n   5 │ 2022/03/10 1:21:49 ?? GMT+9  Prefer not to say  50-      Beer       \n    ⋯\n   6 │ 2022/03/10 1:22:26 ?? GMT+9  Asexual            -19      missing\n   7 │ 2022/03/10 1:25:04 ?? GMT+9  Female             20-34    Beer;Cidre\n   8 │ 2022/03/10 1:25:38 ?? GMT+9  Female             35-49    Sake\n  ⋮  │              ⋮                       ⋮             ⋮                \n    ⋱\n  14 │ 2022/03/10 1:33:09 ?? GMT+9  Male               35-49    Cidre;Cogna\nc;W ⋯\n  15 │ 2022/03/10 1:33:52 ?? GMT+9  Male               20-34    Sake\n  16 │ 2022/03/10 1:34:49 ?? GMT+9  Female             20-34    None\n  17 │ 2022/03/10 1:35:28 ?? GMT+9  Female             50-      Beer;Cidre;\nWin\n  18 │ 2022/03/10 1:36:11 ?? GMT+9  Female             35-49    Beer;Cidre;\nCog ⋯\n  19 │ 2022/03/10 1:36:30 ?? GMT+9  Female             -19      missing\n  20 │ 2022/03/10 1:37:04 ?? GMT+9  Male               20-34    Beer\n                                                   13 columns and 5 rows om\nitted","category":"page"},{"location":"manual/#One-hot-encoding","page":"Manual","title":"One-hot encoding","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"Now, MC responses are stored in columns in vector-form, which need to be encoded in order for us to visualize and analyze. One hot encoding is one of the most simple way of encoding. One column of N possible responses is encoded to N columns of yes/no values.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"warning: Warning\nWhen keyword argument ordered_answers is not specified, the order of resulting columns is \"appearance order\", which is often undesirable. ","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"    onehot(d, :newAlcohol; \n        ordered_answers = [\"Beer\", \"Cidre\", \"Cognac\", \"Wine\", \"Whisky\", \"other\", \"None\"])","category":"page"},{"location":"manual/#Classifying-numerical-responses","page":"Manual","title":"Classifying numerical responses","text":"","category":"section"},{"location":"manual/","page":"Manual","title":"Manual","text":"Function discretize offers classification of numerical response. Specified border values as third argument, it automatically converts to the ranges be (-Inf, thresholds[1]), [thresholds[1], thresholds[2]), ..., [thresholds[end], Inf).  So, the length of class names should be length(thresholds) + 1. If class names not specified, they will be concatenation of border values.","category":"page"},{"location":"manual/","page":"Manual","title":"Manual","text":"discretize(d_a, :Price, [200, 600, 1000]; newcodes=[\"N\", \"L\", \"M\", \"H\"])","category":"page"},{"location":"#FormsPreprocessors.jl","page":"Home","title":"FormsPreprocessors.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A preprocessor for Google Forms CSV.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"#Package-Features","page":"Home","title":"Package Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Recodes values into new ones, including answers into \"others\"\nMultiple recoding for matrix-type SA question\nSplits \"delimiter-concatenated\" MA answers into vector\nOne-hot encoding a column of split vectors\nConverts numerical answers into classes\nConcatenate two column values into one","category":"page"}]
}
