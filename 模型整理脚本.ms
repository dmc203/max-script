rollout ModelUtilities "Model Utilities" width:180 height:180
(
    button btn_setPivot "设置轴心到地面中心" width:150 height:30 align:#center
    button btn_moveToOrigin "移动到原点" width:150 height:30 align:#center
    button btn_resetRotation "Reset Rotation" width:150 height:30 align:#center
    button btn_collapseByMaterial "Collapse by Material" width:150 height:30 align:#center
	-- 文本框用于显示当前选定的文件路径
    editText filePathEdit "选择文件" width:120 height:20 align:#center
    -- 按钮用于打开文件选择对话框
    button browseBtn "选择文件夹..." width:100 height:30
    -- 修复按钮
    button repairBtn "修复贴图文件" width:120 height:30
	
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
	
	--获取选中物体的最外层节点
	fn recursiveGetParent currentObj parents = -- 递归获取父级物体
	(
		if currentObj != undefined do (
			local parentObj = currentObj.parent  -- 获取当前对象的父级
			if parentObj != undefined then (
				if findItem parents parentObj == 0 then
					append parents parentObj  -- 将父级添加到列表中
				recursiveGetParent parentObj parents  -- 递归调用以获取上一级的父级
			)
			else if parentObj == undefined then
			(
				if findItem parents currentObj == 0 then
					append parents currentObj  --将父级添加到列表中
			)
		)
		
	)
	fn getAllParents objs =
	(
		local parents = #()  -- 创建一个空数组来存储父级物体
		for obj in objs do
		(
			recursiveGetParent obj parents  -- 开始递归从传入的对象开始
		)
		return parents 
	)

	fn getOuterFatherNode objs = 
	(
		objs = getAllParents(objs)
		local outerHeads=#()
		for obj in objs do
		(
			if obj.parent==undefined do(
				append outerHeads obj
			)
		)
		outerHeads
	)
	--

	
	--从物体数组中返回边界框
	-- 手动实现 max 功能
	fn myMax a b = 
	(
		if a > b then a else b
	)

	-- 手动实现 min 功能
	fn myMin a b = 
	(
		if a < b then a else b
	)
	fn getMAxAndMinPointFromObjArray objs = 
	(
		local maxpoint = [1e-30,1e-30,1e-30]
		local minpoint = [1e+30,1e+30,1e+30]
		for obj in objs do
		(
			maxpoint.x = myMax maxpoint.x obj.max.x 
			maxpoint.y = myMax maxpoint.y obj.max.y 
			maxpoint.z = myMax maxpoint.z obj.max.z 
			minpoint.x = myMin minpoint.x obj.min.x
			minpoint.y = myMin minpoint.y obj.min.y
			minpoint.z = myMin minpoint.z obj.min.z
		)
		#(maxpoint,minpoint)
	)
	--
	
    fn setPivotToBottomCenter objs = 
    (
		local obj = getOuterFatherNode objs
		print (obj)
		local MaxAndMin = getMAxAndMinPointFromObjArray objs
        maxPoint = MaxAndMin[1]
		minPoint = MaxAndMin[2]
		
        local centerX = (maxPoint.x + minPoint.x) / 2
        local centerY = (maxPoint.y + minPoint.y) / 2
        local bottomZ = minPoint.z
		print(minPoint)
        obj.pivot = [centerX, centerY, bottomZ]
    )
    
    on btn_setPivot pressed do
    (
        if selection.count > 0 then
			setPivotToBottomCenter selection
        else (messagebox "Please select one object.")
    )
    
    on btn_moveToOrigin pressed do
    (
        if selection.count > 0 then
		(
			setPivotToBottomCenter selection
			obj.pos = [0,0,0]
		)
            
        else (messagebox "Please select at least one object.")
    )
    
    on btn_resetRotation pressed do
    (
        if selection.count > 0 then
        (
            for obj in selection do
            (
                obj.rotation.controller = Euler_XYZ()
                obj.rotation.x_rotation = 0
                obj.rotation.y_rotation = 0
                obj.rotation.z_rotation = 0
            )
        )
        else (messagebox "Please select at least one object.")
    )
    
	-- 点击浏览按钮时执行的函数
    on browseBtn pressed do 
    (
        selectedFile = getSavePath caption:"选择文件夹"
        if selectedFile != undefined then
            filePathEdit.text = selectedFile  -- 更新文本框内容
    )
    -- 点击修复按钮时执行的函数
    on repairBtn pressed do 
    (
        local searchDir = getDir
        local textureFiles = getmissingFile
        
        for f in textureFiles do 
        (
            local matFound = false
            
            for obj in geometry where obj.material != undefined do 
            (
                if classOf obj.material == StandardMaterial or classOf obj.material == VRayMtl or classOf obj.material == CoronaMtl then 
                (
                    local texMap = getProperty obj.material #diffuseMap
                    
                    if texMap != undefined and texMap.filename == f then 
                    (
                        matFound = true
                        texMap.filename = filePathEdit.text  -- 替换为用户选择的新文件路径
                    )
                )
            )
            
            if matFound do print ("Updated texture for material using file: " + f)
        )
        messageBox "Textures repaired successfully!"
    )
    
    on btn_collapseByMaterial pressed do
    (
        if selection.count > 0 then
        (
            local objsByMat = #()
            for obj in selection do
            (
                local matID = findItem objsByMat obj.material
                if matID == 0 then
                (
                    append objsByMat #(obj.material, #(obj))
                )
                else
                (
                    append objsByMat[matID][2] obj
                )
            )
            
            for matGroup in objsByMat do
            (
                if matGroup[2].count > 1 then
                (
                    local newObj = convertToMesh (meshop.attach matGroup[2] matGroup[2][1])
                    newObj.material = matGroup[1]
                )
            )
        )
        else (messagebox "Please select at least one object.")
    )
)

createDialog ModelUtilities 300 300 style:#(#style_titlebar,#style_sysmenu,#style_resizing,#style_minimizebox,#style_maximizebox)
