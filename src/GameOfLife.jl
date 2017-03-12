module GameOfLife
export Gol, game, glidergun

type Gol
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
    n,m = size(d.state)
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
    n,m = size(d.state)
    for i in 1:n
        for j in 1:m
            if d.state[i,j] == zero(d.state[i,j])
                print(" ")
            else
                print_with_color(:blue, "X")
            end
        end
        println()
    end
end

"simulation start"
function game(d::Gol)
    sleep(0.1)
    show(d); 
    for iter in 1:d.generations
       d.state = next_generation(d)
       sleep(0.1)
       run(`clear`)
       show(d)
       sum(d.state) == 0 && break
    end
end

"glider gun sample"
function glidergun(n::Integer = 20, m::Integer = 36; generations=250)
    d = Gol(n, m, isperiodic=false, generations=generations)
    d.state = zeros(Int8, n, m)
    gliderpos = Tuple{Int8,Int8}[(5,1),(6,1),(5,2),(6,2),(5,11),(6,11),(7,11),(4,12),(8,12),(3,13),(9,13),(3,14),(9,14),(6,15),(4,16),(8,16),(5,17),(6,17),(7,17),(6,18),(3,21),(4,21),(5,21),(3,22),(4,22),(5,22),(2,23),(6,23),(1,25),(2,25),(6,25),(7,25),(3,35),(4,35),(3,36),(4,36)]
    for pos in gliderpos
        d.state[pos...] = Int8(1)
    end
    return d
end

end # module
