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


export apply_dict, convert_answer!
end
