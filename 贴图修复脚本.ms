(
missingMapfiles = #()--缺失贴图文件路径
missingFilenames = #()--缺失贴图文件名及其扩展名
selectedFilePath = "F:\\模型整理原始素材\\2024.11.28\\Evermotion Archmodels Vol 201\\Evermotion Archmodels Vol 201\\textures"--查找的文件路径
newFilePath = #()--新的贴图路径
mapfile = ()--临时变量
missingNameAndPathList=#()--丢失文件结构列表
struct missingNameAndPath(
	fileName,
	filePath
)
fn replaceMapInstances map newMap =(
				-- Wraps replaceInstances function to fix bug which sometimes duplicates replaced nodes in
				-- SME (Slate Material Editor)
				-- Get node count per SME view, so that the views where no duplicate node is created
				-- don't have to be checked.
				smeNodeCount = (for i = 1 to sme.GetNumViews() collect ((sme.getView i).GetNumNodes()))
				-- Replaces nodes "reference" member that is pointing to map to point to newMap
				replaceInstances map newMap
				-- Since nodes with the newMap reference can be in multiple SME views, we have to check
				-- all of them.
				for viewIndex = 1 to sme.GetNumViews() do (
					mapSmeView = sme.GetView viewIndex
					mapNode = mapSmeView.GetNodeByRef newMap
					if mapNode != undefined and smeNodeCount[viewIndex] < mapSmeView.GetNumNodes() do (

						-- The duplicate nodes can obtain some of the connections to the dependent nodes,
						-- therefore we have to reconnect the dependent nodes to the mapNode before
						-- deleting the duplicates. Even though we also check nodes without direct
						-- connection to the mapNode or its duplicates (which is in this case
						-- unnecessary), it doesn't have a huge negative performance impact.
						dependents = refs.dependents newMap
						dependentNodes = for d in dependents where (dependentNode = mapSmeView.GetNodeByRef d) != undefined collect dependentNode
						for dependentNode in dependentNodes do (
							for propertyName in (getPropNamesFixed dependentNode) do (
									property = getProperty dependentNode.reference propertyName

									-- Remove and return the connection to the newMap reference: this will
									-- connect only the mapNode (i.e. node previously containing the replaced
									-- map) instead of randomly connecting one of the duplicate nodes.
									if (isKindOf property arrayParameter) then (
										-- if the property is an array, it's only a shallow copy and the
										-- values stored in the array are references.
										for i = 1 to property.count do (
											if property[i] == newMap do (
												property[i] = undefined
												property[i] = newMap
											)
										)
									) else if property == newMap do (
										setProperty dependentNode.reference propertyName undefined
										setProperty dependentNode.reference propertyName newMap
									)
								)
							)

						-- Setting selection to the newMap will also select all the duplicate nodes,
						-- which then can be easily deleted after unselecting the mapNode.
						mapSmeView.SetSelectedNodes newMap
						mapNode.selected = false
						mapSmeView.DeleteSelection()
					)
				)
)
fn innitList =
(
	missingMapfiles = #()--缺失贴图文件路径
	missingFilenames = #()--缺失贴图文件名及其扩展名
	newFilePath = #()--新的贴图路径
	mapfile = ()--临时变量
	missingNameAndPathList=#()--丢失文件结构列表
)
fn getNewPathFromSelectPathAndFileName selectedPath  missingFilename = 
(
	local file = ()
	file = getFiles (selectedPath +"\\"+ missingFilename) recurse:true
	append newFilePath file
	file[1]
)
fn creatNewBitMap mapPath =
(
	local r = BitmapTexture filename:(mapPath as name)
	--print("MyClassOf" + (classOf r)as string)
	return r
)
fn getmissingBitMap =
(
	--得到丢失贴图的信息并保存在missingMapfiles missingFilenames missingNameAndPathList
   fn addmap mapfile =
   (
		local mapfileN=mapfile as name
		local index=finditem missingMapfiles mapfileN
		if index == 0 do
		(
			append missingFilenames (filenameFromPath mapfile)--设置FileName
			append missingMapfiles mapfile--设置FilePath
			append missingNameAndPathList (missingNameAndPath fileName:(filenameFromPath mapfile) filePath:mapfile)--设置文件结构列表
		)
	)
   enumeratefiles addmap #missing
   --end
   --依旧列表信息替换材质实例
   for map in getclassinstances Bitmaptexture do
   (
	   if(map.filename!=undefined) do
		(
			print(map.filename)
			if(findItem missingMapfiles map.filename!=0 ) do	--map.filename返回带有扩展名的完整路径
			(
				newfilename = filenameFromPath map.filename
				local newpath = getNewPathFromSelectPathAndFileName selectedFilePath newfilename
				newMap = creatNewBitMap newpath
				replaceMapInstances map newMap
			)
		)
	)
	--end
)
getmissingBitMap()
)
