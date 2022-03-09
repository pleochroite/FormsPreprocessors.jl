module FormsPreprocessors
using Revise, DataFrames, DataFramesMeta, Missings, Parameters, CSV

const MaybeString = Union{Missing,String}
const MaybeReal = Union{Missing,Real}
const StringOrEmptyVector = Union{Vector{Any},Vector{String}}

function apply_dict(dict, x::Vector{T} where {T<:MaybeString})
    [apply_dict(dict, el) for el ∈ x]
end

function apply_dict(dict, x::MaybeString)
    if ismissing(x)
        missing
    elseif x ∈ keys(dict)
        dict[x]
    else
        x
    end
end

function convert_answer!(df::DataFrame, key, dict)
    @transform!(df, $key = map(x -> apply_dict(dict, x), $key))
end

function convert_answer(df::DataFrame, key, newcol, dict)
    _r = map(x -> apply_dict(dict, x), df[:,key])
    rename!(DataFrame(x1 = _r), [newcol])
end

function conversion_dict(vec1, vec2)
    if length(vec1) > length(unique(vec1))
        throw(error("Some keys appear multiple times. $(vec1)"))
    elseif length(vec1) != length(vec2)
        @warn "Lengths of two vectors are not identical. $(min(length(vec1), length(vec2))) entries generated."
    elseif length(vec1) == 0
        @error "Both vectors are empty. An empty Dict generated."
    end
    Dict([val1 => val2 for (val1, val2) ∈ zip(vec1, vec2)])
end

function renaming_dict(vec1::Vector{String}, vec2::T where {T<:StringOrEmptyVector} = [], other = "other")
    n = length(vec1) - length(vec2)
    if n < 0
        throw(error("Key vector is shorter than value vector."))
    elseif n == 0
        v = vec2
    else
        v = vcat(vec2, fill(other, n))
    end
    conversion_dict(vec1, v)
end

function recode!(df::DataFrame, key,
    vec_from::Vector{String}, vec_to::T where {T<:StringOrEmptyVector} = [], other = "other")
    renamer = renaming_dict(vec_from, vec_to, other)
    convert_answer!(df, key, renamer)
end

function recode(df::DataFrame, key, newkey,
    vec_from::Vector{String}, vec_to::T where {T<:StringOrEmptyVector} = [], other = "other")
    renamer = renaming_dict(vec_from, vec_to, other)
    convert_answer(df, key, newkey, renamer)
end


#function recode_matrix(df::DataFrame, keys::Vector{Symbol},
#    vec_from::Vector{String}, vec_to::T where {T<:StringOrEmptyVector} = [], other = "other";
#    prefix="r")

#    renamer = renaming_dict(vec_from, vec_to, other)

#    result = []
#    for key ∈ keys
#        converted = convert_answer(df, key, Symbol("$(prefix)_$(String(key))"), renamer)
#        push!(result, converted)
#    end




#end




function split_ma(x::T where {T<:MaybeString}, delim = ";")
    ismissing(x) ? missing : split(x, delim)
end

function answers_to_dummy(answer, col)
    results = []
    _split_col = split_ma.(col)
    for cell ∈ _split_col
        if ismissing(cell)
            push!(results, missing)
        else
            push!(results, answer ∈ cell ? "yes" : "no")
        end
    end
    results
end

function onehot(df::DataFrame, key; ordered_answers = [])
    col = df[:, key]
    _split_col = split_ma.(col)
    _appeared = _split_col |> skipmissing |> Iterators.flatten |> unique
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
    DataFrame(dummy_cols, colnames)
end

function concatenate(x1::MaybeString, x2::MaybeString; delim::String = ";")
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

function direct_product(df::DataFrame, col1, col2, newcol; delim = "_")

    if col1 == col2
        throw(ArgumentError("Passed identical columns."))
    elseif String(newcol) ∈ names(df)
        throw(ArgumentError("New column name $(newcol) already exists in the dataframe."))
    end

    r = DataFrame(cat = concatenate.(df[:, col1], df[:, col2]; delim = delim))
    rename!(r, [newcol])
end

function discretize(df::DataFrame, col, thresholds::Vector{T} where {T<:Real},
    newcol = "$(String(col))_d";
    newcodes = [])

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

    r = [find_range(val, _ranges) for val ∈ df[:, col]]
    _enc = DataFrame(x = map(x -> get_at(newcodes, x), r))

    result = hcat(df, _enc)
    rename!(result, vcat(names(df), newcol))
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


export recode!, recode, recode_matrix, onehot, concatenate, discretize, direct_product
end
