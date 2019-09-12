
x = 3
y = 3
w = 5
h = 3
# flat matrix  length w x h
a = repeat([1 2 3], w * h)


a[x+(y-1)*w, :] = [3, 3, 3]

println(x + (y - 1) * w)
show(reshape([x for x in eachrow(a)], w, h) |> transpose)
