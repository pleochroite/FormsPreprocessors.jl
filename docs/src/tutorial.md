---
author: "schigy"
title: "Tutorial"
date: 2022-03-12
---


## Hello

FormsPreprocessors is a tiny preprocessing tool for questionnaire data (such as one obtained using 
Google Forms) to convert 'raw' data to ready-to-analyze style.
It provides functions of recoding, one-hot encoding, concatenating columns, and splitting multiple 
choice responses.

```julia
julia> using DataFrames, DataFramesMeta, Chain, CSV
Error: ArgumentError: Package Chain not found in current path:
- Run `import Pkg; Pkg.add("Chain")` to install the Chain package.


julia> using FormsPreprocessors

julia> d = CSV.read("./example/sample_data.csv", DataFrame)
Error: UndefVarError: CSV not defined
```
