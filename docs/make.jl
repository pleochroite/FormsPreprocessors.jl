using Documenter, FormsPreprocessors
#using Weave

makedocs(
    sitename = "FormsPreprocessors",
    pages = Any[
        "Home" => "index.md",
        #"Tutorial" => "tutorial.jmd",
        "References" => "references.md"
    ],
    modules = [FormsPreprocessors]
    )

#weave("tutorial.jmd", doctype="github")

deploydocs(
    repo = "github.com/pleochroite/FormsPreprocessors.jl.git"
)