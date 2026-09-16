# Export newton-raphson.jl to a static HTML page (newton-raphson.html).
#
#   julia --project=@pluto -e 'import Pkg; Pkg.add("Pluto")'   # once
#   julia --project=@pluto export.jl
#
# newton-raphson.jl is a plain Julia script.  This turns it into a Pluto
# notebook (one cell per top-level expression, markdown cells folded), runs it
# in a temporary directory, and writes the static export next to the source.

import Pluto

src = joinpath(@__DIR__, "newton-raphson.jl")
out = joinpath(@__DIR__, "newton-raphson.html")

# Split the script into cells at top-level expression boundaries, keeping the
# comments that precede each expression with it (so a `# hide` line just
# above a function folds that function, not the cell before it).
lines = readlines(src)
starts = [ex.line for ex in Meta.parseall(join(lines, "\n")).args if ex isa LineNumberNode]
ends = [starts[2:end] .- 1; length(lines)]
# move trailing comment/blank lines from each chunk to the start of the next
for i in 1:length(starts)-1
    while ends[i] >= starts[i] && (isempty(strip(lines[ends[i]])) || startswith(strip(lines[ends[i]]), "#"))
        ends[i] -= 1
    end
    starts[i+1] = ends[i] + 1
end
cells = map(zip(starts, ends)) do (a, b)
    chunk = lines[a:b]
    while !isempty(chunk) && isempty(strip(chunk[1])); popfirst!(chunk); end
    while !isempty(chunk) && isempty(strip(chunk[end])); pop!(chunk); end
    code = join(chunk, "\n")
    body = something(findfirst(l -> !startswith(strip(l), "#"), chunk), 1)
    Pluto.Cell(; code, code_folded=startswith(chunk[body], "md\"") || occursin(r"#\s*hide\b", code))
end

tmp = mktempdir()
nbpath = joinpath(tmp, basename(src))
notebook = Pluto.Notebook(cells, nbpath)
Pluto.save_notebook(notebook)

session = Pluto.ServerSession()
notebook = Pluto.SessionActions.open(session, nbpath; run_async=false)

errors = [c for c in notebook.cells if c.errored]
isempty(errors) || error("cells errored:\n" * join((c.code * "\n=> " * string(get(c.output.body, :msg, c.output.body)) for c in errors), "\n---\n"))

write(out, Pluto.generate_html(notebook))
Pluto.SessionActions.shutdown(session, notebook)
println("wrote ", out, " (", round(filesize(out) / 1e6; digits=1), " MB)")
