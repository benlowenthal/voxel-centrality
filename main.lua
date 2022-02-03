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
		DebugCross(crs.pos, crs.value, crs.value, crs.value)
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
				process.count = newN

				--if same shape updated, skip existing coroutine
				if h == current.shape then
					current = process
				else
					table.insert(queue, process)
				end
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
		local n = current.count
		local center = ShapeApproxCenter(v, 25)
		local max = {}
		local maxv = 0
			
		for K,val in pairs(ASBrandes(v, a, 50, 2)) do
			local k = Decode(K)
		
			--weight based on distance from center / torque
			local dist = VecSub(k, center)
			local norm = val - (dist[2]/(y * 7.5)) + (VecLength(Vec(dist[1]/x, dist[2]/y, dist[3]/z)) / 10)
			
			if norm >= 0 and not IsBodyDynamic(body) then
				local transform = GetShapeWorldTransform(shape)
				local worldPos = VecAdd(transform.pos, QuatRotateVec(transform.rot, VecScale(k, scale)))
				table.insert(crosses, {["pos"]=worldPos, ["value"]=norm*5})
		
				if norm > threshold then
					MakeHole(worldPos, scale*step, scale*step, scale*step)
				end
			end
		
			if norm > maxv then
				max = k
				maxv = norm
			end
		end
		
		DebugPrint(Encode(max).." centr="..maxv..", count="..n)
	end)
end

function ShapeApproxCenter(V, s)
	local ctr = Vec(0,0,0)
	for i = 1,s do
		ctr = VecAdd(ctr, Decode(V[math.floor(i*#V/s)]))
	end

	return VecScale(ctr, 1 / s)
end
