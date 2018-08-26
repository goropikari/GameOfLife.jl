module GameOfLife

import REPL
using REPL.TerminalMenus
export Gol, game, game2, glidergun

mutable struct Gol
    state::Matrix{Int8}
    isperiodic::Bool
    generations::Int
end

function Gol(n::Int,
             m::Int = n;
             isperiodic::Bool = true,
             generations::Int = 100)
    state = rand(Int8[0,1], n, m)

    return Gol(state, isperiodic, generations)
end

"count the number of live neighbors"
function determine_neighbor_state(d::Gol, i::Integer, j::Integer)
    n, m = size(d.state)
    neighbor = [(p,q) for p in -1:1 for q in -1:1 if !(p == 0 && q == 0)]
    total = Int8(0)
    if d.isperiodic # periodic
        for idx in 1:8
            total += d.state[mod1(i + neighbor[idx][1], n), mod1(j + neighbor[idx][2], m)]
        end
    else # non-periodic
        for idx in 1:8
            if !(i + neighbor[idx][1] <= 0 || j + neighbor[idx][2] <= 0 || i + neighbor[idx][1] > n || j + neighbor[idx][2] > m)
                total += d.state[i + neighbor[idx][1], j + neighbor[idx][2]]
            end
        end
    end

    return total
end

"update cells"
function next_generation(d::Gol)
    n, m = size(d.state)
    next_state = zeros(Int8, n, m)
    for col in 1:m
        for row in 1:n
            if d.state[row, col] == one(d.state[row, col]) # live
                if determine_neighbor_state(d, row, col) in Int8[2, 3]
                    next_state[row, col] = Int8(1)
                end
            else # dead
                if determine_neighbor_state(d, row, col) == Int8(3)
                    next_state[row, col] = Int8(1)
                end
            end
        end
    end
    return next_state
end

"show state"
function Base.show(d::Gol)
    n, m = size(d.state)
    for i in 1:n
        for j in 1:m
            if d.state[i,j] == zero(d.state[i,j])
                print(" ")
            else
                printstyled("X", color=:light_blue, bold=true)
            end
        end
        println()
    end
end

"""
    game(d::Gol; tstep=0.1)
simulation start
"""
function game(d::Gol; tstep=0.1)
    sleep(0.1)
    show(d);
    n = length(string(d.generations))
    for iter in 1:d.generations
       d.state = next_generation(d)
       sleep(tstep)
       run(`clear`)
       show(d)
       print("\nGeneration: ", lpad(iter, n))
       sum(d.state) == 0 && break
    end
end

"""
    game(;t=0.1, gen=100)
"""
function game(;t=0.1, gen=100)
    row, col = displaysize(stdout)
    d = Gol(row, col, isperiodic=true, generations=gen)
    game(d, tstep=t)
end

"""
    glidergun(n::Integer = 20, m::Integer = 36; generations=250)
glider gun sample
"""
function glidergun(n::Integer = 20, m::Integer = 36; generations=250)
    d = Gol(n, m, isperiodic=false, generations=generations)
    d.state = zeros(Int8, n, m)
    gliderpos = Tuple{Int8,Int8}[(5,1),(6,1),(5,2),(6,2),(5,11),(6,11),(7,11),(4,12),(8,12),(3,13),(9,13),(3,14),(9,14),(6,15),(4,16),(8,16),(5,17),(6,17),(7,17),(6,18),(3,21),(4,21),(5,21),(3,22),(4,22),(5,22),(2,23),(6,23),(1,25),(2,25),(6,25),(7,25),(3,35),(4,35),(3,36),(4,36)]
    for pos in gliderpos
        d.state[pos...] = Int8(1)
    end
    return d
end



boardsize = ["(20, 20)", "(20, 40)", "(30, 30)", "(30, 40)", "(40, 40)", "(40, 80)", "(100, 200)"]
boardsize_dict = Dict(zip(1:length(boardsize), eval.(Meta.parse.(boardsize))))
menu = RadioMenu(boardsize, pagesize=4)
function game2()
    choice = request("Choose your favorite field size (row, column):", menu)
    col, row = boardsize_dict[choice]
    println()
    periodic_condition = request("Choose boundary condition:",
                                RadioMenu(["Periodic", "Non periodic"],
                                pagesize=2))
    condition = ifelse(isone(periodic_condition), true, false)

    print("\nThe number of generations: ")
    num_generation = Meta.parse(readline())
    @assert isinteger(num_generation)

    game(Gol(col, row, isperiodic=condition, generations=num_generation))
    return nothing
end

end # module
