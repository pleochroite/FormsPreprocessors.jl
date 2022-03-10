using CSV, DataFrames, DataFramesMeta, Revise, Chain
using FormsPreprocessors

d = CSV.read("./example/sample_data.csv", DataFrame)

cols = names(d)

foo = recode(d, :Gender, :newGender, ["Prefer not to say", "Non-binary"],[], false)
foo.newGender