using Weave

filename = normpath("./docs/src/tutorial.jmd")

weave(filename, out_path = "./examples/", doctype = "md2html")