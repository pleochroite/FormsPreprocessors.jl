# FormsPreprocessors.jl

A preprocessor for Google Forms CSV.

```@contents
```

## Package Features

- Recodes values into new ones, including answers into "others"
- Multiple recoding for matrix-type single choice answers
- Splits "delimiter-concatenated" multiple choice answers into vectors
- One-hot encoding a column of split vectors
- Converts numerical answers into classes
- Concatenate two column values into one
