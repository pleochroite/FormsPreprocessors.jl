using Documenter, FormsPreprocessors

using Weave
weave("./docs/src/tutorial.jmd", doctype="github")

makedocs(
    sitename = "FormsPreprocessors",
    pages = Any[
        "Home" => "index.md",
        "Tutorial" => "tutorial.md",
        "References" => "references.md"
    ],
    modules = [FormsPreprocessors]
    )



deploydocs(
    repo = "github.com/pleochroite/FormsPreprocessors.jl.git"
)