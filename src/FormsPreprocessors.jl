module FormsPreprocessors
using Revise, DataFrames, DataFramesMeta, Missings, Parameters, CSV

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

function gen_conversion_dict(vec1, vec2)
    if length(vec1) != length(vec2)
        @warn "Lengths of two vectors are not identical. $(min(length(vec1), length(vec2))) entries generated."
    elseif length(vec1) == 0
        @error "Both vectors are empty."
    end
    Dict([val1 => val2 for (val1, val2) ∈ zip(vec1,vec2)])
end




export apply_dict, convert_answer!, gen_conversion_dict
end
