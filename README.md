# GameOfLife

[Conway's Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life)

```julia
  Pkg.clone("https://github.com/goropikari/GameOfLife.jl")
  using GameOfLife
  
  row, col = 30, 100
  d = Gol(row, col, isperiodic=true, generations=100)
  game(d)
```

Glider gun sample
```julia
  Pkg.test("GameOfLife")
```
