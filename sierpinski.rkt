#lang logo

to sierpinski :size
  to inner :size
    left 60 fd :size rt 60
    repeat 3 [
      if :size > 3 [inner :size / 2]
      pd fd :size pu rt 120
    ] left 60 bk :size rt 60
  end
  pd repeat 3 [fd :size left 120] ; outer edge
  pu inner :size / 2
end

sierpinski 100
