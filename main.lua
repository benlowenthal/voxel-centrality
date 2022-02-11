#include "brandes.lua"

local scale = 0.1
local samples = GetInt("savegame.mod.samples", 500)
local threshold = GetInt("savegame.mod.threshold", 50) / 100
local minShape = GetInt("savegame.mod.minshape", 1000)
local crosses = {}
local voxelCounts = {} --if these change, we know we have to check the shape's centrality
local queue = {}
local current = {}

function init()
	current.routine = coroutine.create(function () end)
	current.shape = 0

	--warmup random number gen
	math.randomseed(GetTime())
	math.random(); math.random(); math.random()

	local i = 0
	for _,h in pairs(FindShapes(nil, true)) do
		local n = GetShapeVoxelCount(h)
		if n > minShape and not IsBodyDynamic(GetShapeBody(h)) then
			voxelCounts[h] = n
			i = i + 1
		end
	end
	DebugPrint(i.." shapes found")
end

function tick(dt)
	coroutine.resume(current.routine)

	--start next coroutine if queue has anything
	if coroutine.status(current.routine) == "dead" and next(queue) ~= nil then
		current = table.remove(queue, 1)
		coroutine.resume(current.routine)
	end

	UpdateVoxelCounts()
	
	for key=1, #crosses do
        local crs = crosses[key]
		DebugCross(crs.pos, crs.colour[1], crs.colour[2], crs.colour[3])
	end
end

function UpdateVoxelCounts()
	for h,n in pairs(voxelCounts) do
		--detect change in shape
		local newN = GetShapeVoxelCount(h)
		if newN ~= n then
			if newN > minShape and not IsBodyDynamic(GetShapeBody(h)) then
				voxelCounts[h] = newN

				process = {}
				process.routine = CreateCoroutine(h)
				process.shape = h

				--if same shape updated, skip existing coroutine
				if h == current.shape then
					current.routine = coroutine.create(function () end)
				end

				--if h in queue somewhere then skip that too
				for i,p in pairs(queue) do
					if p.shape == h then
						table.remove(queue, i)
					end
				end
				
				table.insert(queue, process)
			else
				voxelCounts[h] = nil
			end
		end
	end

	for _,h in pairs(FindShapes(nil, true)) do
		local n = GetShapeVoxelCount(h)
		if voxelCounts[h] == nil and n > minShape and not IsBodyDynamic(GetShapeBody(h)) then
			voxelCounts[h] = n
		end
	end
end

function CreateCoroutine(shape)
	return coroutine.create(function ()
		local v = {}
		local a = {}

		local x, y, z = GetShapeSize(shape)
		local step = math.ceil(math.pow((x*y*z) / samples, 1/3))

		DebugPrint("step: "..step)
		for i = 0, x-1, step do
			for j = 0, y-1, step do
				for k = 0, z-1, step do
					--avoid tables as indices
					local vec = Encode(Vec(i, j, k))
					local nb = GetNeighbours(shape, i, j, k, step)
	
					if next(nb) ~= nil then
						v[#v+1] = vec
						a[vec] = nb
					end
				end
			end
		end
		
		crosses = {}
		local body = GetShapeBody(shape)
		local n = #v
		local center = ShapeApproxCenter(v, 25)
		local transform = GetShapeWorldTransform(shape)
		local max = {}
		local maxv = 0
		
		for K,val in pairs(ASBrandes(v, a, 50, 2)) do
			local k = Decode(K)
			local worldPos = VecAdd(transform.pos, QuatRotateVec(transform.rot, VecScale(k, scale)))
		
			--weight based on distance from center
			local dist = VecSub(worldPos, center)
			local norm = val + (VecLength(Vec(dist[1]/x, dist[2]/y, dist[3]/z)) / 10) - (dist[2]/(y * 7.5)) -- 10, 7.5
			norm = norm * math.pow(voxelCounts[shape], 1/3) / 11

			if norm >= 0 and not IsBodyDynamic(body) then
				if norm > 1 then
					MakeHole(worldPos, scale*step*2, scale*step*2, scale*step*2)
					table.insert(crosses, {["pos"]=worldPos, ["colour"]=Vec(1,0,0)})
				else
					table.insert(crosses, {["pos"]=worldPos, ["colour"]=Vec(norm,norm,norm)})
				end
			end
		
			if norm > maxv then
				max = k
				maxv = norm
			end
		end
		
		DebugPrint(Encode(max).." centr="..maxv..", count="..#v)
	end)
end

function ShapeApproxCenter(V, s)
	local ctr = Vec(0,0,0)
	local t = GetShapeWorldTransform(s)
	for i = 1,s do
		ctr = VecAdd(ctr, Decode(V[math.floor(i*#V/s)]))
	end

	ctr = VecScale(ctr, 1 / s)
	return VecAdd(t.pos, QuatRotateVec(t.rot, VecScale(ctr, scale)))
end
