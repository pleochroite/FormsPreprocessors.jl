var documenterSearchIndex = {"docs":
[{"location":"references/","page":"References","title":"References","text":"DocTestSetup = quote\n    using DataFrames\n    using FormsPreprocessors\nend","category":"page"},{"location":"references/","page":"References","title":"References","text":"Modules=[FormsPreprocessors]\nOrder=[:function, :type]","category":"page"},{"location":"references/#FormsPreprocessors.direct_product-Tuple{DataFrames.DataFrame, Any, Any, Any}","page":"References","title":"FormsPreprocessors.direct_product","text":"direct_product(df, col1, col2, newcol)\n\nConcatenates values of col1 and col2, which is stored in newcol.\n\nExample\n\ndf = DataFrame(q1 = [\"young\", \"old\", \"young\", \"young\"],     q2 = [\"no\", \"no\", \"no\", \"yes\"])\n\ndirect_product(df, :q1, :q2, :q1xq2)\n\noutput\n\nRow  │ q1      q2      q1xq2   \n     │ String  String  String  \n─────┼─────────────────────────\n1    │ young     no      young_no\n2    │ old      no      old_no\n3    │ young     no      young_no\n4    │ young     yes     young_yes\n\nIf either value is missing, the other value itself is stored. If either value is \"\", the other value with delim is stored.\n\nExample\n\ndf = DataFrame(q1 = [\"young\", missing, \"young\", \"\"],     q2 = [\"no\", \"no\", missing, \"yes\"])\n\ndirect_product(df, :q1, :q2, :q1xq2)\n\nOutput\n\nRow  │ q1       q2       q1xq2  \n     │ String?  String?  String \n─────┼──────────────────────────\n1    │ young      no       young_no\n2    │ missing  no       no\n3    │ young      missing  young\n4    │          yes      _yes\n\n\n\n\n\n","category":"method"},{"location":"references/#FormsPreprocessors.discretize","page":"References","title":"FormsPreprocessors.discretize","text":"discretize(df, key, thresholds, newcol=\"class_$(String(key))\"; newcodes=[])\n\nClassify numerical answers to classes defined by thresholds. The number of classes is length(thresholds) + 1, because the ranges to be  (-Inf, thresholds[1]), [thresholds[1], thresholds[2]), ..., [thresholds[end], Inf]. Therefore, the length of newcodes must be length(thresholds) + 1.\n\nExample\n\ndf = DataFrame(expense=[100, 250, 300, 1000, 150])\n\ndiscretize(df, :expense, [100, 300, 500]; newcodes=[\"No\", \"Low\", \"Middle\", \"High\"])\n\nOutput\n\nRow  │ expense  class_expense \n     │ Int64    String        \n─────┼────────────────────────\n1    │     100  Low\n2    │     250  Low\n3    │     300  Middle\n4    │    1000  High\n5    │     150  Low\n\n\n\n\n\n","category":"function"},{"location":"references/#FormsPreprocessors.onehot-Tuple{DataFrames.DataFrame, Any}","page":"References","title":"FormsPreprocessors.onehot","text":"onehot(df, key; ordered_answers=[])\n\nPerforms one-hot encoding on key column. The column is expected to be of vectors, as split_ma_col! generates. If you want to sort columns generated, specify ordered_answers. If not ordered_answers specified, columns are ordered by value appearance.\n\nExample\n\ndf = DataFrame(item=[\"Apple;Orange\", \"Tomato\", \"Tomato;Pepper\"]) onehot(df, :item; ordered_answers=[\"Tomato\", \"Pepper\", \"Apple\", \"Orange\"])\n\noutput\n\nRow  │ item                  item_Tomato  item_Pepper  item_Apple  item_Orange \n     │ Array…                Any          Any          Any         Any         \n─────┼─────────────────────────────────────────────────────────────────────────────────────\n1    │ [\"Apple\", \"Orange\"]   no           no           yes         yes\n2    │ [\"Tomato\"]            yes          no           no          no\n3    │ [\"Tomato\", \"Pepper\"]  yes          yes          no          no\n\n\n\n\n\n","category":"method"},{"location":"references/#FormsPreprocessors.recode","page":"References","title":"FormsPreprocessors.recode","text":"recode(df, key, newkey, vec_from, vec_to=[]; other=\"other\")\n\nRecodes values in key column with values in vec_from into corresponding vec_to values,  which are stored in newkey column. Items not in vec_from keep original values.  If vec_to is shorter than vec_from, the last values are recoded to other. If you want to recode all irregular answers such as 'other:______' to others,  use recode_others. If you want to recode columns with common choices such as choices to matrix type  question, use recode_matrix\n\nExample\n\ndf = DataFrame(item = [\"Apple\", \"Orange\", \"Tomato\", \"Pepper\"])\n\nrecode(df, :item, :newitem, [\"Apple\", \"Orange\", \"Pepper\"], [\"Fruit\", \"Fruit\"])\n\noutput\n\nRow  │ item    newitem \n     │ String  String  \n─────┼─────────────────\n1    │ Apple   Fruit\n2    │ Orange  Fruit\n3    │ Tomato  Tomato\n4    │ Pepper  other\n\nYou can recode values stored in a column of vectors which can be generated using split_ma_col!(@ref).\n\n!!! Note     If you recode a column of vectors, single-value answer must be vectorized,      as split_ma_col!(@ref) does.\n\nExample\n\ndf = DataFrame(item = [[\"Apple\", \"Orange\"], [\"Tomato\"], [\"Tomato\", \"Pepper\"]])\n\nrecode(df, :item, :newitem, [\"Tomato\", \"Pepper\"], [\"Vegitable\", \"Spice\"])\n\noutput\n\nRow  │ item                  newitem                \n     │ Array…                Array…                 \n─────┼──────────────────────────────────────────────\n1    │ [\"Apple\", \"Orange\"]   [\"Apple\", \"Orange\"]\n2    │ [\"Tomato\"]            [\"Vegitable\"]\n3    │ [\"Tomato\", \"Pepper\"]  [\"Vegitable\", \"Spice\"]\n\nSee also recode_others(@ref), recode_matrix(@ref)\n\n\n\n\n\n","category":"function"},{"location":"references/#FormsPreprocessors.recode_matrix","page":"References","title":"FormsPreprocessors.recode_matrix","text":"recode_matrix(df, keys, vec_from, vec_to=[]; other=\"other\", prefix=\"r\")\n\nRecodes values of vec_from in keys columns to vec_to values. New values from column :foo are stored in corresponding column named :prefix_foo. \n\nExample\n\ndf = DataFrame(q1=[\"Strongly agree\", \"Disagree\", \"Agree\", \"Neutral\", \"Strongly disagree\"],      q2 = [\"Disagree\", \"Strongly disagree\", \"Neutral\", \"Agree\", \"Agree\"])\n\nrecode_matrix(df, [:q1, :q2], [\"Strongly agree\", \"Agree\", \"Disagree\", \"Strongly disagree\"],  [\"t2b\", \"t2b\", \"b2b\", \"b2b\"])\n\noutput\n\nRow  │ q1                 q2                 r_q1     r_q2    \n     │ String             String             String   String  \n─────┼────────────────────────────────────────────────────────\n1    │ Strongly agree     Disagree           t2b      b2b\n2    │ Disagree           Strongly disagree  b2b      b2b\n3    │ Agree              Neutral            t2b      Neutral\n4    │ Neutral            Agree              Neutral  t2b\n5    │ Strongly disagree  Agree              b2b      t2b\n\nSee also recode(@ref)\n\n\n\n\n\n","category":"function"},{"location":"references/#FormsPreprocessors.recode_others-Tuple{DataFrames.DataFrame, Any, Any, Vector{String}}","page":"References","title":"FormsPreprocessors.recode_others","text":"recode_others(df, key, newkey, regular_answers; other=\"other\")\n\nRecodes all appeared values in key column but in regular_answers into other,  which are stored in newkey column.\n\nExample\n\ndf = DataFrame(item = [\"Apple\", \"Orange\", \"Tomato\", \"Pepper\"])\n\nrecode_others(df, :item, :newitem, [\"Apple\", \"Orange\"])\n\noutput\n\nRow  │ item    newitem \n     │ String  String  \n─────┼─────────────────\n1    │ Apple   Apple\n2    │ Orange  Orange\n3    │ Tomato  other\n4    │ Pepper  other\n\nSee also recode\n\n\n\n\n\n","category":"method"},{"location":"references/#FormsPreprocessors.split_ma_col!-Tuple{DataFrames.DataFrame, Any}","page":"References","title":"FormsPreprocessors.split_ma_col!","text":"split_ma_col!(df, key; delim=\";\")\n\nMutates key columns with values of \"delim-concatenated\" MA answers into column with vectors.\n\nExample\n\ndf = DataFrame(item=[\"Apple;Orange\", \"Tomato\", \"Tomato;Pepper\"]) splitmacol!(df, :item)\n\noutput\n\nRow  │ item                              \n     │ Array…                            \n─────┼───────────────────────────────────\n1    │ [\"Apple\", \"Orange\"]\n2    │ [\"Tomato\"]\n3    │ [\"Tomato\", \"Pepper\"]\n\n\n\n\n\n","category":"method"},{"location":"#FormsPreprocessors.jl","page":"Home","title":"FormsPreprocessors.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A preprocessor for Google Forms CSV.","category":"page"},{"location":"#Package-Features","page":"Home","title":"Package Features","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Recodes values into new ones, including answers into \"others\"\nMultiple recoding for matrix-type SA question\nSplits \"delimiter-concatenated\" MA answers into vector\nOne-hot encoding a column of split vectors\nConverts numerical answers into classes\nConcatenate two column values into one","category":"page"}]
}
