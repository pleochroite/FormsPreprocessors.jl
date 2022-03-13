using Documenter, FormsPreprocessors

using Weave
weave("./docs/src/manual.jmd", doctype="github")

makedocs(
    sitename = "FormsPreprocessors",
    pages = Any[
        "Home" => "index.md",
        "Manual" => "manual.md",
        "References" => "references.md"
    ],
    modules = [FormsPreprocessors]
    )



deploydocs(
    repo = "github.com/pleochroite/FormsPreprocessors.jl.git"
)