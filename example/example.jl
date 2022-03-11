using CSV, DataFrames, DataFramesMeta, Revise, Chain
using FormsPreprocessors

d = CSV.read("./example/sample_data.csv", DataFrame)

rename!(d, ["timestamp", "Gender", "Age", "Alcohol", "Fruit", "Price",
    "Lastvisit_SM", "Lastvisit_CVS", "Lastvisit_DS", "LastVisit_Glos",
    "Studied_English", "Studied_Math", "Studied_Science", "Studied_Arts", "Studied_Programming"])

ns = Symbol.(names(d))

# You can create pipeline using Chain.jl

cvd = @chain d begin
    # First of all, split MA answers
    split_ma_col!(_, :Fruit)
    split_ma_col!(_, :Alcohol)
    split_ma_col!(_, :Studied_English)
    split_ma_col!(_, :Studied_Math)
    split_ma_col!(_, :Studied_Science)
    split_ma_col!(_, :Studied_Arts)
    split_ma_col!(_, :Studied_Programming)
    # recode irregular answers to "other"
    recode_others(_, :Gender, :newGender, ["Male", "Female"])
    recode_others(_, :Alcohol, :newAlcohol, 
        ["Beer", "Cidre", "Cognac", "Wine", "Whisky", "None"])
    recode_others(_, :Fruit, :newFruit, 
        ["Apple", "Apricot", "Grape", "Lemon", "Melon", "Orange", "Peach", "None"])
    # recode some values
    recode(_, :Age, :newAge, ["-19", "20-34", "35-49", "50-"], ["Teen", "1", "2", "3"])
    # concatenate two fields
    direct_product(_, :newGender, :newAge, :VRSection; delim="-")
    # classify number values
    discretize(_, :Price, [200, 600, 1000]; newcodes=["N", "L", "M", "H"])
    # recode SA Matrix answers to identical values
    recode_matrix(_, ns[7:10], 
        ["Within a week", "Within a month", "Within 3 months", "More than 3 months ago", "Never"],
        ["Recent", "Recent", "Silent", "Silent", "Never"])
    # one-hot encoding for MA answers
    onehot(_, :newAlcohol; 
        ordered_answers = ["Beer", "Cidre", "Cognac", "Wine", "Whisky", "other", "None"])
    onehot(_, :newFruit; 
        ordered_answers=  ["Apple", "Apricot", "Grape", "Lemon", 
            "Melon", "Orange", "Peach", "other", "None"])
end