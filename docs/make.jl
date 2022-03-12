using Documenter, FormsPreprocessors

makedocs(
    sitename = "FormsPreprocessors",
    pages = Any[
        "Home" => "index.md",
        "References" => "references.md"
    ],
    modules = [FormsPreprocessors]
    )

deploydocs(
    repo = "github.com/pleochroite/FormsPreprocessors.jl.git"
)