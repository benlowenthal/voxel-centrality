--adapted from pseudocode in "path centrality: a new centrality measure in social networks"
--by the university of south florida, in which they propose a new centrality algorithm but i don't use it :D
function ASBrandes(V, A, T, c)
    local C = {}    --centrality
    local RS = {}   --running sum
    local F = {}    --flags
    local k = {}    --pivot count

    local P = {} --pred
    local d = {} --dist
    local e = {} --delta
    local g = {} --sigma

    local n = #V

    --pairs and ipairs have a unnecessary overhead for large indexed tables
    for key=1,n do
        local v = V[key]
        C[v] = 0
        RS[v] = 0
        F[v] = false
    end

    local yieldBuffer = GetInt("savegame.mod.iterations")
    for i = 1,T do
        local s = V[math.random(n)]

        for key=1,n do
            local v = V[key]
            P[v] = {}
            d[v] = -1
            e[v] = 0
            g[v] = 0
        end

        g[s] = 1
        d[s] = 0

        if i % yieldBuffer == 0 then
            coroutine.yield()
        end

        local S = {} --stack
        local Q = {} --queue
        Q[1] = s

        --bfs
        while next(Q) ~= nil do
            local v = table.remove(Q, 1)            
            S[#S+1] = v     --table.insert(S, v)
            
            for key=1, #A[v] do
                local w = A[v][key]
                if d[w] < 0 then
                    d[w] = d[v] + 1
                    Q[#Q+1] = w     --table.insert(Q, w)
                end

                if d[w] == d[v] + 1 then
                    g[w] = g[w] + g[v]
                    P[w][#P[w]+1] = v   --table.insert(P[w], v)
                end
            end
        end

        --back pass
        while next(S) ~= nil do
            local w = S[#S] --table.remove(S)
            S[#S] = nil

            --if #S % (n/20) == 0 then
            --    coroutine.yield()
            --end

            for _,v in pairs(P[w]) do
                e[v] = e[v] + (g[v]/g[w]) * (1 + e[w])
            end

            if w ~= s and not F[w] then
                RS[w] = RS[w] + e[w]
                if RS[w] > c * n then
                    k[w] = i
                    C[w] = (n / k[w]) * RS[w]
                    F[w] = true
                end
            end
        end

        --set unflagged centralities
        for key=1,n do
            local v = V[key]
            if not F[v] then
                k[v] = T
                C[v] = (n / k[v]) * RS[v]
            end
        end
    end

    --normalise
    local Cnorm = {}
    for K,val in pairs(C) do
        Cnorm[K] = val / ((n-1)*(n-2)*0.5)
	end

    return Cnorm
end

function GetNeighbours(shape, x, y, z, step)
    local n = {}
    local xmax,ymax,zmax = GetShapeSize(shape)

    if x+step < xmax and GetShapeMaterialAtIndex(shape,x+step,y,z) ~= "" then
        n[#n+1] = Encode(Vec(x+step,y,z)) --table.insert(n, Encode(Vec(x+1,y,z)))
    end
    if y+step < ymax and GetShapeMaterialAtIndex(shape,x,y+step,z) ~= "" then
        n[#n+1] = Encode(Vec(x,y+step,z)) --table.insert(n, Encode(Vec(x,y+1,z)))
    end
    if z+step < zmax and GetShapeMaterialAtIndex(shape,x,y,z+step) ~= "" then
        n[#n+1] = Encode(Vec(x,y,z+step)) --table.insert(n, Encode(Vec(x,y,z+1)))
    end

    if x-step >= 0 and GetShapeMaterialAtIndex(shape,x-step,y,z) ~= "" then
        n[#n+1] = Encode(Vec(x-step,y,z)) --table.insert(n, Encode(Vec(x-1,y,z)))
    end
    if y-step >= 0 and GetShapeMaterialAtIndex(shape,x,y-step,z) ~= "" then
        n[#n+1] = Encode(Vec(x,y-step,z)) --table.insert(n, Encode(Vec(x,y-1,z)))
    end
    if z-step >= 0 and GetShapeMaterialAtIndex(shape,x,y,z-step) ~= "" then
        n[#n+1] = Encode(Vec(x,y,z-step)) --table.insert(n, Encode(Vec(x,y,z-1)))
    end

    return n
end

function Encode(vec)
	return table.concat(vec, ",")
end

function Decode(vec)
    --no split func :(
    local v = {}
    for str in string.gmatch(vec, "([^,]+)") do
        v[#v+1] = str   --table.insert(v, str)
    end
    return v
end
