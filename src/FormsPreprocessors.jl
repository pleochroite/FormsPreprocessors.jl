module FormsPreprocessors
using Revise, DataFrames, DataFramesMeta, Missings, Parameters, CSV

function apply_dict(dict, x::Vector{String})
    [apply_dict(dict, el) for el ∈ x]
end

function apply_dict(dict, x::Vector{Union{String,Missing}})
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

function convert_answer!(df, key, dict)
    @transform!(df, $key = map(x -> apply_dict(dict, x), $key))
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

function renaming_dict(vec1::Vector{String}, vec2::Union{Vector{Any}, Vector{String}} = [], other = "other")
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

function recode!(df, key, vec_from::Vector{String}, vec_to::Union{Vector{Any}, Vector{String}}=[], other="other")
    renamer = renaming_dict(vec_from, vec_to, other)
    convert_answer!(df, key, renamer)
end

function split_ma(x, delim=";")
    ismissing(x) ? missing : split(x,delim)
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

function onehot(d, key; ordered_answers=[])
	col = d[:,key]
	dummy_cols = []

    if length(ordered_answers) == 0
        ordered_answers = col |> skipmissing |>
        Itarators.flatten |> unique
    end

    if length(ordered_answers) > length(unique(ordered_answers))
        throw(ArgumentError("Duplicate values detected. Please check: $(ordered_answers)"))
    end

	for ans ∈ ordered_answers
		dummy = answers_to_dummy(ans, col)
		push!(dummy_cols, dummy)
	end

	prefix = String(key)
	colnames = prefix .* "_" .* ordered_answers
	DataFrame(dummy_cols, colnames)
end

export recode!
end
