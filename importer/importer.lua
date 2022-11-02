importer={}
importer.__index = importer

function importer:import(functionsToImport)
	assert(functionsToImport:len()>0,"specify what you want to import")
	local impr = {}
	setmetatable(impr,importer)
	impr.scripts=functionsToImport
	return impr
end

function importer:from(script)
	local res=getResourceFromName(script)
	assert(res,"script doesnt exists")
	local functions=res:getExportedFunctions()
	assert(#functions>0,"script must contain exports")
	local importThis={}
	if(self.scripts=="*")then
		importThis=functions
	else
		local tbsplit=split(self.scripts,",")
		for i,v in ipairs(functions)do
			for ii,vv in ipairs(tbsplit)do
				if(string.find(v,vv))then
					table.insert(importThis,v)
				end
			end
		end
	end
	for i,v in ipairs(importThis)do
		_G[v]=function(...)
			return call(res,v,...)
		end
	end
end

function import(...)
	return importer:import(...)
end