module FormsPreprocessors
using DataFrames, DataFramesMeta, Missings, Parameters, CSV

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
    Dict([val1 => val2 for (val1, val2) ∈ zip(vec1,vec2)])
end




export apply_dict, convert_answer!, gen_conversion_dict
end
