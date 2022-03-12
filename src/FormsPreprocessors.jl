module FormsPreprocessors
using Revise, DataFrames, DataFramesMeta, Missings, Parameters, CSV

const MaybeString = Union{Missing,String}
const MaybeReal = Union{Missing,Real}
const StringOrEmptyVector = Union{Vector{Any},Vector{String}}

function apply_dict(dict, x::AbstractVector)
    [apply_dict(dict, el) for el ∈ x]
end


function apply_dict(dict, x)
    if ismissing(x)
        missing
    elseif x ∈ keys(dict)
        dict[x]
    else
        x
    end
end

function convert_answer(df::DataFrame, key, newcol, dict)
    _r = map(x -> apply_dict(dict, x), df[:, key])
    rename!(DataFrame(x1 = _r), [newcol])
end

function conversion_dict(vec1, vec2)
    if length(vec1) > length(unique(vec1))
        throw(ArgumentError("Some keys appear multiple times. $(vec1)"))
    elseif length(vec1) != length(vec2)
        @warn "Lengths of two vectors are not identical. $(min(length(vec1), length(vec2))) entries generated."
    elseif length(vec1) == 0
        @error "Both vectors are empty. An empty Dict generated."
    end
    Dict([val1 => val2 for (val1, val2) ∈ zip(vec1, vec2)])
end

function renaming_dict(vec1, vec2::T where {T<:StringOrEmptyVector} = [], other = "other")
    n = length(vec1) - length(vec2)
    if n < 0
        throw(ArgumentError("Key vector is shorter than value vector."))
    elseif n == 0
        v = vec2
    else
        v = vcat(vec2, fill(other, n))
    end
    conversion_dict(vec1, v)
end


"""
    recode(df, key, newkey, vec_from, vec_to=[]; other="other")

Recodes values in `key` column with values in `vec_from` into corresponding `vec_to` values, 
which are stored in `newkey` column.
Items not in `vec_from` keep original values. 
If `vec_to` is shorter than `vec_from`, the last values are recoded to `other`.
If you want to recode all irregular answers such as 'other:______' to `other`s, 
use [`recode_others`](@ref).
If you want to recode columns with common choices such as choices to matrix type 
question, use [`recode_matrix`](@ref).

# Example

```
julia> df = DataFrame(item = ["Apple", "Orange", "Tomato", "Pepper"])
julia> recode(df, :item, :newitem, ["Apple", "Orange", "Pepper"], ["Fruit", "Fruit"])
4x2 DataFrame
Row  │ item    newitem 
     │ String  String  
─────┼─────────────────
1    │ Apple   Fruit
2    │ Orange  Fruit
3    │ Tomato  Tomato
4    │ Pepper  other
```

You can recode values stored in a column of vectors which can be generated using
[`split_ma_col!`](@ref).

!!! Note

    If you recode a column of vectors, single-value answer must be vectorized, 
    as [`split_ma_col!`](@ref) does.


# Example

```
julia> df = DataFrame(item = [["Apple", "Orange"], ["Tomato"], ["Tomato", "Pepper"]])
julia> recode(df, :item, :newitem, ["Tomato", "Pepper"], ["Vegitable", "Spice"])
3x2 DataFrame
Row  │ item                  newitem                
     │ Array…                Array…                 
─────┼──────────────────────────────────────────────
1    │ ["Apple", "Orange"]   ["Apple", "Orange"]
2    │ ["Tomato"]            ["Vegitable"]
3    │ ["Tomato", "Pepper"]  ["Vegitable", "Spice"]
```

See also [`recode_others`](@ref), [`recode_matrix`](@ref)
"""
function recode(df::DataFrame, key, newkey,
    vec_from::AbstractVector, vec_to::T where {T<:StringOrEmptyVector} = [];
    other = "other", replace = false)

    renamer = renaming_dict(vec_from, vec_to, other)
    result = convert_answer(df, key, newkey, renamer)

    return hcat(df, result)
end


"""
    recode_others(df, key, newkey, regular_answers; other="other")

Recodes all appeared values in `key` column but in `regular_answers` into `other`, 
which are stored in `newkey` column.

# Example

```
julia> df = DataFrame(item = ["Apple", "Orange", "Tomato", "Pepper"])
julia> recode_others(df, :item, :newitem, ["Apple", "Orange"])

Row  │ item    newitem 
     │ String  String  
─────┼─────────────────
1    │ Apple   Apple
2    │ Orange  Orange
3    │ Tomato  other
4    │ Pepper  other
```

See also [`recode`](@ref) 

"""
function recode_others(df::DataFrame, key, newkey,
    regular_answers::Vector{String}; other = "other", replace = false)

    col = collect(df[!, key])
    _appeared = col |> flat |> skipmissing |> unique
    renamed_from = setdiff(_appeared, regular_answers)

    return recode(df, key, newkey, renamed_from, []; other = other)
end

function flat(vec)
    result = []
    for v ∈ vec
        if ismissing(v)
            push!(result, missing)
        elseif typeof(v) <: AbstractString
            push!(result, v)
        elseif typeof(v) <: AbstractVector
            result = vcat(result, flat(v))
        else
            # ToDo: catch other possible scenarios
            throw(ArgumentError("Flattening failed."))
        end
    end
    result
end


"""
    recode_matrix(df, keys, vec_from, vec_to=[]; other="other", prefix="r")

Recodes values of `vec_from` in `keys` columns to `vec_to` values.
New values from column :foo are stored in corresponding column named :`prefix`_foo. 

# Example

```
julia> df = DataFrame(q1=["Strongly agree", "Disagree", "Agree", "Neutral", "Strongly disagree"], 
    q2 = ["Disagree", "Strongly disagree", "Neutral", "Agree", "Agree"])
julia> recode_matrix(df, [:q1, :q2], ["Strongly agree", "Agree", "Disagree", "Strongly disagree"], 
["t2b", "t2b", "b2b", "b2b"])
5x4 DataFrame
Row  │ q1                 q2                 r_q1     r_q2    
     │ String             String             String   String  
─────┼────────────────────────────────────────────────────────
1    │ Strongly agree     Disagree           t2b      b2b
2    │ Disagree           Strongly disagree  b2b      b2b
3    │ Agree              Neutral            t2b      Neutral
4    │ Neutral            Agree              Neutral  t2b
5    │ Strongly disagree  Agree              b2b      t2b
```

See also [`recode`](@ref)
"""
function recode_matrix(df::DataFrame, keys::Vector{Symbol},
    vec_from::Vector{String}, vec_to::T where {T<:StringOrEmptyVector} = [],
    ; other = "other", prefix = "r", replace = false)

    newcolnames = "$(prefix)" .* "_" .* String.(keys)
    colliding_names = intersect(names(df), newcolnames)

    if colliding_names ≠ []
        throw(ArgumentError("New column name already exists in the dataframe."))
    end

    renamer = renaming_dict(vec_from, vec_to, other)

    result = DataFrame()
    for key ∈ keys
        converted = convert_answer(df, key, Symbol("$(prefix)_$(String(key))"), renamer)
        result = hcat(result, converted)
    end

    return hcat(df, result)
end


function split_ma(x, delim = ";")
    ismissing(x) ? missing : split(x, delim)
end

"""
    split_ma_col!(df, key; delim=";")

Mutates `key` columns with values of "`delim`-concatenated" MA answers into column with vectors.

# Example

```
julia> df = DataFrame(item=["Apple;Orange", "Tomato", "Tomato;Pepper"])
julia> split_ma_col!(df, :item)
3x1 DataFrame
Row  │ item                              
     │ Array…                            
─────┼───────────────────────────────────
1    │ ["Apple", "Orange"]
2    │ ["Tomato"]
3    │ ["Tomato", "Pepper"]
```
"""
function split_ma_col!(df::DataFrame, key; delim = ";")
    return transform!(df, key => ByRow(x -> split_ma.(x, delim)) => key)
end

function answers_to_dummy(answer, col)
    results = []
    for cell ∈ col
        if ismissing(cell)
            push!(results, missing)
        else
            push!(results, answer ∈ cell ? "yes" : "no")
        end
    end
    results
end


"""
    onehot(df, key; ordered_answers=[])

Performs one-hot encoding on `key` column.
The column is expected to be of vectors, as `split_ma_col!` generates.
If you want to sort columns generated, specify `ordered_answers`.
If not `ordered_answers` specified, columns are ordered by value appearance.

# Example
```
julia> df = DataFrame(item=["Apple;Orange", "Tomato", "Tomato;Pepper"])
julia> onehot(df, :item; ordered_answers=["Tomato", "Pepper", "Apple", "Orange"])
3x5 DataFrame
Row  │ item                  item_Tomato  item_Pepper  item_Apple  item_Orange 
     │ Array…                Any          Any          Any         Any         
─────┼─────────────────────────────────────────────────────────────────────────────────────
1    │ ["Apple", "Orange"]   no           no           yes         yes
2    │ ["Tomato"]            yes          no           no          no
3    │ ["Tomato", "Pepper"]  yes          yes          no          no
```
"""
function onehot(df::DataFrame, key; ordered_answers = [])

    col = collect(df[!, key])
    _appeared = col |> flat |> skipmissing |> unique
    appeared = filter(x -> x ≠ "" && !(ismissing(x)), _appeared)

    if length(ordered_answers) == 0
        ordered_answers = appeared
    end

    if setdiff(appeared, ordered_answers) ≠ []
        throw(ArgumentError("Some input are missing from ordered_answers. Please check: $(setdiff(appeared, ordered_answers))"))
    end

    if length(ordered_answers) > length(unique(ordered_answers))
        throw(ArgumentError("Duplicate values detected. Please check: $(ordered_answers)"))
    end

    dummy_cols = []
    for ans ∈ ordered_answers
        dummy = answers_to_dummy(ans, col)
        push!(dummy_cols, dummy)
    end

    prefix = String(key)
    colnames = prefix .* "_" .* ordered_answers
    result = DataFrame(dummy_cols, colnames)

    return hcat(df, result)
end


function concatenate(x1, x2; delim::String = ";")
    if ismissing(x1) && ismissing(x2)
        missing
    elseif ismissing(x1)
        x2
    elseif ismissing(x2)
        x1
    else
        x1 * delim * x2
    end
end

"""
    direct_product(df, col1, col2, newcol)

Concatenates values of `col1` and `col2`, which is stored in `newcol`.

# Example

```
julia> df = DataFrame(q1 = ["young", "old", "young", "young"],
    q2 = ["no", "no", "no", "yes"])
julia> direct_product(df, :q1, :q2, :q1xq2)

Row  │ q1      q2      q1xq2   
     │ String  String  String  
─────┼─────────────────────────
1    │ young     no      young_no
2    │ old      no      old_no
3    │ young     no      young_no
4    │ young     yes     young_yes
```

If either value is missing, the other value itself is stored.
If either value is "", the other value with `delim` is stored.

# Example
```
julia> df = DataFrame(q1 = ["young", missing, "young", ""],
    q2 = ["no", "no", missing, "yes"])
julia> direct_product(df, :q1, :q2, :q1xq2)
4x3 DataFrame
Row  │ q1       q2       q1xq2  
     │ String?  String?  String 
─────┼──────────────────────────
1    │ young      no       young_no
2    │ missing  no       no
3    │ young      missing  young
4    │          yes      _yes
```
"""
function direct_product(df::DataFrame, col1, col2, newcol; delim = "_", replace = false)
    if col1 == col2
        throw(ArgumentError("Passed identical columns."))
    elseif String(newcol) ∈ names(df)
        throw(ArgumentError("New column name $(newcol) already exists in the dataframe."))
    end

    r = DataFrame(cat = concatenate.(df[:, col1], df[:, col2]; delim = delim))
    return hcat(df, rename!(r, [newcol]))
end

"""
    discretize(df, key, thresholds, newcol="class_\$(String(key))"; newcodes=[])

Classify numerical answers to classes defined by `thresholds`.
The number of classes is length(thresholds) + 1, because the ranges to be 
(-Inf, thresholds[1]), [thresholds[1], thresholds[2]), ..., [thresholds[end], Inf].
Therefore, the length of `newcodes` must be length(thresholds) + 1.

# Example
```
julia> df = DataFrame(expense=[100, 250, 300, 1000, 150])
julia> discretize(df, :expense, [100, 300, 500]; newcodes=["No", "Low", "Middle", "High"])
5x2 DataFrame
Row  │ expense  class_expense 
     │ Int64    String        
─────┼────────────────────────
1    │     100  Low
2    │     250  Low
3    │     300  Middle
4    │    1000  High
5    │     150  Low
```
"""
function discretize(df::DataFrame, key, thresholds::Vector{T} where {T<:Real},
    newcol = "class_$(String(key))";
    newcodes = [], replace = false)

    if length(thresholds) > length(unique(thresholds))
        throw(ArgumentError("Thresholds contain the same value."))
    elseif newcol ∈ names(df)
        throw(ArgumentError("New colname $(newcol) already exists in the dataframe."))
    end

    _thres = vcat(-Inf, sort(thresholds), Inf)
    _ranges = [(_thres[i], _thres[i+1]) for i ∈ 1:length(_thres)-1]

    if newcodes == []
        newcodes = ["$(r[1])-$(r[2])" for r ∈ _ranges]
    end

    if length(thresholds) + 1 ≠ length(newcodes)
        throw(ArgumentError("Length of new codes mismatches."))
    end

    _r = [find_range(val, _ranges) for val ∈ df[:, key]]
    result = DataFrame(x = map(x -> get_at(newcodes, x), _r))
    return hcat(df, rename!(result, [newcol]))
end

function get_at(vec, i::Union{Missing,Int})
    ismissing(i) ? missing : vec[i]
end

function falls_in(val::MaybeReal, range::Tuple{T,P} where {T<:Real,P<:Real})
    if ismissing(val)
        missing
    elseif range[2] == Inf
        range[1] ≤ val ≤ range[2]
    else
        range[1] ≤ val < range[2]
    end
end

function find_range(val::MaybeReal, ranges::Vector{Tuple{T,P}} where {T<:Real,P<:Real})
    result = falls_in.(val, ranges)
    all(x -> ismissing(x), result) ? missing : findfirst(result)
end


export split_ma_col!, recode, recode_matrix, recode_others, onehot, discretize, direct_product
end
