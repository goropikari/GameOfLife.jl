# GameOfLife

[Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)

```julia
using Pkg
Pkg.pkg"add https://github.com/goropikari/GameOfLife.jl"
using GameOfLife
game()

row,col = 20, 30
game(Gol(row, col, isperiodic=true, generations=50))
```

Glider gun sample
```julia
Pkg.test("GameOfLife")
```
