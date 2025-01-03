--0000-2024.12.6 15.49
--try(destroyDialog theNewFloater) catch()
(
---------------------------------------------------变量------------------------------------------------
	global bitMaps = #() --Class:BitMap
	global mapFile = #() --Class:stringName
	persistent global assetPath
	global subAssetFolders
	global selectedSubPath
	global nowPage = 1
	global allPage = 0
	global nowPressedButtonIndex = 0
	global imageButtonList =#()
	global nowSelectedFilePath = ()
	global pengpaiInstance = undefined
	if(assetPath == undefined) then assetPath = ()
-------------------------------------------------全局变量----------------------------------------------
---------------------------------------------------方法------------------------------------------------
	--*
	fn vectorDivide v1 v2 =
	(
		--检查是否试图进行非法操作，如被零除
		if (v2.x == 0 or v2.y == 0 or v2.z == 0) then
		(
			throw "Division by zero in one of the vector components."
		)
		else
		(
			[v1.x / v2.x, v1.y / v2.y, v1.z / v2.z]
		)
	)
	--设置Transform信息
	fn SetTransformInfo obj pos ro sc =
	(
		if obj != undefined then 
		(
			-- 设置位置
			obj.position = pos
			
			-- 设置旋转（需要转换为四元数或保持为欧拉角）
			obj.rotation = ro
			
			-- 设置缩放
			obj.scale = sc
		)
	)
	fn SetTransformInfoPos obj pos =
	(
		if obj != undefined then 
		(
			-- 设置位置
			obj.position = pos
		)
	)
	fn SetTransformInfoRotation obj ro =
	(
		if obj != undefined then 
		(
			-- 设置旋转
			obj.rotation = ro
		)
	)
	fn SetTransformInfoScale obj newScale =
	(
		if obj != undefined then 
		(
			-- 设置位缩放
			obj.scale = sc
		)
	)
	--end设置Transform信息
	--*
	--类型检查器
	fn classCheck obj =
	(
		if (superClassOf obj == GeometryClass or 
			superClassOf obj == light or
				classOf obj== Dummy) then
		(
			true
		)
		else 
			false
	)
	--end类型检查器
	--替换物体
	fn ReplaceObj oldObj newObj = 
	(
		if(newObj!=undefined)then
		(
			
			if ((classCheck oldObj)==true) then
			(	newObj.transform = oldObj.transform	
				if(oldObj.parent!=newObj)then
					newObj.parent = oldObj.parent
				else
					messageBox("oldObj.parent==newObj")
				print (newObj.transform as string +"\n"+ oldObj.transform as string )
				--newObj.transform = oldObj.transform
				oldObj.parent=undefined
				--print("oldObj.parent:"+oldObj.parent as string)
				true
			)
			else if(oldObj==undefined) then
			(
				messageBox("未找的物体的根节点请检查是否选中物体")
				false
			)
			else
			(
				messageBox("不支持类型请尝试转换为可编辑多边形")
				false
			)
		)
	)
	--end替换物体

	--从数组中选取元素
	fn getElementFromArry arry index =
	(
		if(index<=arry.count and index>0) then
			arry[index]
		else 
			undefined
	)
	--end从数组中选取元素
	--*
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
	--*
	--从所选物体中得到最外层物体
	fn getOuterObjFormSelection objs =
	(
		objs = objs as Array
		local fathers = #()
		if(objs.count>1)then
		(
			for obj in objs do
			(
				if(obj.parent!=undefined)then --如果obj的父级没有定义那么obj就是最外层的
				(
					if(findItem objs obj.parent ==0 )then
					append fathers obj
				)
				else
					append fathers obj
			)
		)
		else
			append fathers objs[1]
		fathers
	)
	--

	--*
	--从选中物体
	fn getOuterGroupHead objs = 
	(
		local groupHeads=#()
		local outerHeads=#()
		for obj in objs do
		(
			if(isGroupHead obj)then
				append groupHeads obj
		)
		for groupHead in groupHeads do
		(
			if(groupHead.parent!=undefined)then
			(
				if((findItem groupHeads groupHead.parent)==0)then
				(
					append outerHeads groupHead
				)
			)
			else
			(
				append outerHeads groupHead
			)
		)
		outerHeads
	)
	--从路径和文件名搜索文件
	fn SerchWithPathAndFileName path  fileName = 
	(
		local file = ()
		file = getFiles (path +"\\"+ fileName) recurse:false

		print("asset:"+ path as string +"   fileName："+ fileName as string)
		print("拼接后使用GetFile的路径：" + file as string)
		file[1]
	)
	--end从路径和文件名搜索文件
	--*
	--从路径加载max文件并返回新增物体列表
	fn MergeMaxFileAndReturnObjects filePath =
	(
		-- 检查文件是否存在
		if doesFileExist filePath then 
		(
			-- 获取当前场景中的对象数量
			local initialObjectCount = objects.count
			
			local oldObj = (geometry as Array)
			-- 合并新的 .max 文件
			mergeMAXFile filePath #mergeDups #useMergedMtlDups quiet:true
			
			-- 创建一个数组来存储新合并的对象
			local newObjects = #()
			
			-- 遍历所有对象，找到新增的那些
			for obj in geometry do
			(
				if (findItem oldObj obj == 0 )then 
					append newObjects obj
			)
			
			--print ("合并文件:" + filePath)
			newObjects  -- 返回合并后的对象列表
		)
		else
		(
			
			undefined  -- 返回未定义以表示失败
			messageBox("文件不存在: " + filePath)
		)
	)
	--end从路径加载max文件并返回物体列表
	--*
	--加载路径中的所有位图文件
	fn LoadBitmapsFromDirectory directoryPath =
	(
		undo off(
			bitMaps = #()
			-- 检查目录是否存在
			if(directoryPath!=undefined)then
			if doesFileExist directoryPath then 
			(
				-- 获取目录中的所有文件名
				local files = getFiles (directoryPath + "\\*.*")
				
				-- 支持的位图扩展名列表
				local bitmapExtensions = #(".jpg", ".jpeg", ".png", ".bmp", ".tga", ".tiff")
				if (files.count > 0) then
				(
					-- 存储已加载的位图材质
					--local loadedBitmaps = #()
					--local loadedCount = 0
					
					--progressStart "加载预览图中："   
					
					-- 遍历每个文件
					for file in files do
					(
						-- 获取文件扩展名并转换为小写以便匹配
						local fileExtension = toLower (getFilenameType file)
						
						-- 检查该扩展名是否在支持列表中
						if findItem bitmapExtensions fileExtension > 0 then 
						(
							local map1 = bitmap 256 256 filename:file
							local map2 = openBitMap file
							
							copy map2 map1
							append mapFile file 
							append bitMaps map1          
							free map2
							--释放加载的原图像
							--loadedCount += 1             -- 更新已加载计数
							--progressUpdate ((loadedCount / files.count) * 100) -- 更新进度条
						)
					)
				)
			)
			else 
			(
				messageBox("路径不存在:" + directoryPath)
			)
		)
	)
	--end加载路径中的所有位图文件
	--*
	--遍历场景并返回相机列表
	fn GetCamerasInScene = 
	(
		local cameraList = #()  -- 初始化一个空数组来存储相机对象
		
		-- 遍历场景中的所有对象
		for obj in objects do
		(
			-- 检查对象是否为相机类型（包括目标和自由相机）
			if superclassof obj == Camera then
			(
				append cameraList obj  -- 将相机对象添加到列表中
			)
		)
		return cameraList  -- 返回包含所有相机的列表
	)
	--end遍历场景返回相机列表
	--*
	--从活动相机渲染
	fn RenderFromCurrentCamera = 
	(
		-- 获取当前活动视图的对象
		local activeView = viewport.getCamera()
		
		if activeView != undefined and superclassof activeView == Camera then
		(
			-- 设置渲染参数为当前相机
			render camera:activeView
			
			--print ("从活动相机渲染 " + activeView.name)
		)
		else
		(
			--print "没有活动相机被设置"
		)
	)
	--end从活动相机渲染
	--*
	--裁剪字符串
	fn TrimStringWithEllipsis inputStr maxLength =
	(
		-- 检查输入参数
		if maxLength <= 0 do
		(
			""
		)
		if inputStr!=undefined then
		(
			-- 如果输入字符串的长度小于或等于最大长度，则返回原字符串
			if (inputStr.count <= maxLength) then
			(
				return inputStr
			)
			-- 裁剪字符串并添加省略号
			local trimmedStr = (substring inputStr 1 (maxLength - 3))+"..." -- 留出3个字符用于省略号
			trimmedStr
		)
		else 
		(
			undefined
		)
			

	)
	--end裁剪字符串
	--*
	--设置button的icon
	fn updateButtonIcon imageButtonList =
	(
		undo off(
			if(imageButtonList!=undefined) do
			--为button设置位图
				for i = 1 to 16 do
				(
					local mapIndex = (nowPage-1)*16+i
					--local mapIndex=1
					if(bitMaps.count>=mapIndex) then
					(
						--print (classof (bitMaps[mapIndex]))
						--imageButtonList[i].images = #(bitMaps[mapIndex],undefined, 1,1,1,1,1)
						if(bitMaps[mapIndex] != undefined) then
							try(imageButtonList[i].images = #(bitMaps[mapIndex], undefined, 1,1,1,1,1 )) 
								catch(print("贴图加载异常"))
						else
						(
							local blackimage = bitmap 64 64 color:black
							try(imageButtonList[i].images = #(blackimage, undefined, 1,1,1,1,1 ))
								catch(print("贴图加载异常"))
						)
						--print(bitMaps[mapIndex])
					)
					else
					(						local blackimage = bitmap 64 64 color:black
						try(imageButtonList[i].images = #(blackimage, undefined, 1,1,1,1,1 ))
							catch()
					)
				)
		)
	)
	--end设置button的icon
	--*
	--页面索引更新
	fn updatePageIndex pageIndexButton =
	(
		pageIndexButton.text  = (nowPage as string)+"/"+(allPage as string)
	)
	--end页面索引更新
	--*
	--页面图像更新
	fn updateSelectedModelButtonImage bitmapImage button i=
	(
		--print(classof button)
		
		local mapIndex = (nowPage-1)*16+i
		if(mapIndex<=bitMaps.count) then
		(
			try(bitmapImage.images = #(bitMaps[mapIndex], undefined, 1,1,1,1,1 ))
				catch(print("贴图加载异常"))
		)
		
	)
	--end页面图像更新
	--*
	fn isGrouped objs = 
	(
		local GroupFlag = true
		for obj in objs do
			GroupFlag = ((isGroupMember obj) and true)
		GroupFlag
	)
	
	fn setSubAssetPath myasset folderName =
	(
		local finalPath = myasset +"\\"+ folderName
		finalPath
	)
	
	fn getSubfolders folderPath = 
	(
		-- 确保传入的路径存在并是一个文件夹
		if doesFileExist folderPath and (getDirectories (folderPath + "\\*")) != undefined then
		(
			local folderList = getDirectories (folderPath + "\\*") -- 获取所有子文件夹
			local folderNames = for folder in folderList collect (getFilenameFile (trimRight folder "\\"))
			return folderNames
		)
		else
		(
			format "提供的路径无效或不是一个文件夹: %\n" folderPath
			return #() -- 返回空数组
		)
	)
	--选中物体列表是否为完整组并选中整组物体
	fn isGroupValid objs =
	(
		outerNode = getOuterObjFormSelection objs
		getOuterObjFormSelection objs
		if(outerNode.count>1)then
			false
		else
		(
			if(isGroupHead outerNode[1]==true)then
			(
				setGroupOpen outerNode[1] false
			)
			true
		)
	)
	--替换标签检查选中物体列表是否满足替换条件
	fn ReplaceFlag objs =
	(
		
		if(objs!=undefined)then
		(
			if(objs.count>1)then
			(
				if(isGroupValid objs)then
					true
				else
				(
					messageBox("选中方式非法")
					false
				)
			)
			else
				true
		)
		else
			messageBox("ReplaceFlag：传入参数未定义")
	)
	--
	fn remainder a b =
	(
		-- 定义两个数字
		local a = 10.0
		local b = 3.0
		-- 计算商的整数部分
		local quotient = floor(a / b)
		-- 计算余数
		local remainder = a - (quotient * b)
	)
------------------------------------------------------------------end方法-----------------------------------------------------
-------------------------------------------------------------------展卷栏-------------------------------------------------------
	
	
	rollout fission "裂变窗口"
	(
		dropdownlist FissionMethod "映射关系"items:#("x","y","z")
		listbox listbox1 "原物体列表" pos:[20,50] width:100 height:10--height=140
		listbox listbox2 "裂变物体列表" pos:[180,50] width:100 height:10--height=140
		button  AddToOriginObjList "添加原物体" pos:[20,200] width:100 height:40
		button AddToFissionObjList "添加裂变物体" pos:[180,200]width:100 height:40
		button AddAllToFissionObjList "添加目录下的所有物体" pos:[180,240]width:100 height:40	
		button StartFission "开始裂变" align:#center width:60 height:30
		local originObjs = #() --物体列表
		local originObjsName = #() --物体名字列表
		---------------------------------每种裂变对应关系需要的数据结构---------------------------------
		--方法1，一对多，每次对所有被裂变的物体进行裂变，选择了最多裂变物体的模型为基准产生裂变方案数量
		--local M1_selectedIndex = 0
		locaL M1_fissionObjsPathsArray = #(#())
		locaL M1_fissionObjsNameArray = #(#())
		--end方法1
		---------------------------------end每种裂变对应关系需要的数据结构---------------------------------

		--------------------------------------执行器需要的裂变数据-------------------------------------
		local objPairsArray =#()
		--------------------------------------end执行器需要的裂变数据-------------------------------------
		--物体对结构，通过物体对列表
		struct objPair (objs , filePath)
		local objPairList = #()
		--构建物体对方法
		fn MakeObjPair originObjs newObjPath =
		(
			objPair objs:objs filePath:filePath
			objPair
		)
		--物体对列表构建器，返回每次替换时需要替换的物体对列表的列表
		fn ObjPairArrayMaker oldObjs newObjs =
		(
			case FissionMethod.selection of
			(
				--执行M1
				1:
				(
					for i=1 to originObjs.count do (
						for fissionobj in M1_fissionObjsPathsArray[i] do (
							MakeObjPair originObjs[i] fissionobj
						)
					)
				)
			)
		)
		--添加原物体方法
		fn addOriginObj objs = 
		(
			case FissionMethod.selection of
			(
				1:
				(
					if(objs.count==0)then
						messagebox"请选择物体"
					else(
						local selectionFathers = getOuterObjFormSelection objs
						if(selectionFathers.count>1)then
							messagebox"请选择在同一组内的物体"
						else
						(
							if(findItem originObjs selectionFathers[1] == 0) then
							(
								append originObjs selectionFathers[1]
								append originObjsName selectionFathers[1].name as string
								listbox1.items = originObjsName	
							)
						)
					)
				)
			)
		)
		fn deleteObjInfo num = 
		(
			case FissionMethod.selection of
			(
				1:
				(
					--print(originObjsName as string)
					if(originObjsName[num] != undefined and originObjsName[num] != #())then
					(
						deleteItem originObjsName num
						deleteItem originObjs num
					)
					if(M1_fissionObjsPathsArray[num] != undefined and M1_fissionObjsPathsArray[num] != #())then
					(
						deleteItem M1_fissionObjsPathsArray num
						deleteItem M1_fissionObjsNameArray num
						listbox1.items = originObjsName
					)
					if(listbox1.selection>0)then
					(
						if(M1_fissionObjsNameArray[listbox1.selection]==undefined)then
						M1_fissionObjsNameArray[listbox1.selection]=#()
						listbox2.items = M1_fissionObjsNameArray[listbox1.selection]
					)
					else
						listbox2.items = #()
				)
			)
			
		)
		--添加裂变物体方法
		fn addFissionObj filePath =
		(
			case FissionMethod.selection of
			(
				--执行M1
				1:
				(
					--通过名称列表找到物体实例
					--判断数量，防止超过M1_fissionObjsPathsArray的范围
					if(listbox1.selection>0)then
					(
							--从pengpaiInstance得到当前所选物体的路径
							--得到路径后将信息处理后添加到裂变信息列表
							--创建数组
							if(M1_fissionObjsPathsArray[listbox1.selection] == undefined)then
								M1_fissionObjsPathsArray[listbox1.selection] = #()
							if(M1_fissionObjsNameArray[listbox1.selection] == undefined)then
								M1_fissionObjsNameArray[listbox1.selection] = #()
							--判断是否重复存在
							if(finditem M1_fissionObjsPathsArray[listbox1.selection] filePath == 0)then
							(
								append M1_fissionObjsPathsArray[listbox1.selection] filePath
								append M1_fissionObjsNameArray[listbox1.selection] ((getFilenameFile filePath) as string)
								--同时更新列表内容
								listbox2.items = M1_fissionObjsNameArray[listbox1.selection]
							)
							else
							(
								messagebox"请勿重复添加物体"
							)
					)
				)
			)
		)
		fn addAllFissionObj =
		(
			case FissionMethod.selection of
			(
				1:
				(
					local mapfiles = pengpaiInstance.getAllFilePath()
					for myfile in mapfiles do
					(
						if(findItem M1_fissionObjsPathsArray myfile==0) then
						(
							append M1_fissionObjsPathsArray[listbox1.selection] myfile
							append M1_fissionObjsNameArray[listbox1.selection] ((getFilenameFile myfile) as string)
						)
					)
					listbox2.items = M1_fissionObjsNameArray[listbox1.selection]
				)
			)
		)
		--选择器,根据列表信息返回对应的执行器需要的数据
		fn Selecter = 
		(

		)
		--执行器，根据物体对列表的列表逐步执行物体替换
		fn Executor =
		(

		)
		on listbox1 selected num do
		(
			if(num>0)then
			(
				case FissionMethod.selection of
				(
					--执行M1
					1:
					(
						--判断裂变物体路径数组在num下的项是否定义
						if(M1_fissionObjsPathsArray[num]!=undefined)then
							listbox2.items = M1_fissionObjsNameArray[num]
						else
							listbox2.items = #()
						--判断所选物体是否任然存在
						print(originObjs[num])
						if(isDeleted  originObjs[num]==true)then
							deleteObjInfo num
						else
							select originObjs[num]
					)
				)
			)
			
		)
		on listbox1 rightClick num do
		(
			
			deleteObjInfo num
		)
		on AddToOriginObjList pressed do
		(
			print("添加原物体被点击")
			addOriginObj selection
		)
		on AddToFissionObjList pressed do
		(
			print("添加到裂变被点击")
			local filePath = pengpaiInstance.getNowSelectedFilePath()
			if(filePath!=undefined)then
			(
				addFissionObj filePath
			)
			else
			(
				messageBox"裂变模型不存在请检查路径模型"
			)
		)
		on AddAllToFissionObjList pressed do
		(
			print("全选按钮被点击")
			addAllFissionObj()
		)
		on fission close do
		(
			pengpaiInstance.btnOpenFission.state = off
		)
	)
	rollout pengpai1 "模型替换"
	(
		button btnSelectPath "选择资产路径" width:380 height:20 align:#center
		dropdownlist dirList "子目录" width:380 height:20 align:#center
		button btnReplaceModel "替换" pos:[40,115] width:100 height:30 align:#cente
		checkbutton  btnOpenFission "打开裂变窗口" pos:[40,80] width:100 height:30 align:#cente
		button bitmapImage pos:[300,78] width:80 height:80 bitmap:(bitmap 128 128 color:black) pixelAspect:2
		checkbox sizeClampCheckBox "尺寸钳制" pos:[140,125] 
		dropdownlist xyzClamp pos:[210,122] width:50 height:20 items:#("x轴","y轴","z轴") enabled:false
		label tag "替换模型：" pos:[235,100]
		--label assetModel "资产库模型" pos:[240,115] style_sunkenedge:true width:80 height:30 align:#center
		GroupBox bitmapGroup "图片预览" pos:[10,160] width:380 height:380
		button bitmap1 "无文件" pos:[25,180] width:80 height:80
		button bitmap2 "无文件" pos:[115,180] width:80 height:80
		button bitmap3 "无文件" pos:[205,180] width:80 height:80
		button bitmap4 "无文件" pos:[295,180] width:80 height:80

		button bitmap5 "无文件" pos:[25,270] width:80 height:80
		button bitmap6 "无文件" pos:[115,270] width:80 height:80
		button bitmap7 "无文件" pos:[205,270] width:80 height:80
		button bitmap8 "无文件" pos:[295,270] width:80 height:80

		button bitmap9 "无文件" pos:[25,360] width:80 height:80
		button bitmap10 "无文件" pos:[115,360] width:80 height:80
		button bitmap11 "无文件" pos:[205,360] width:80 height:80
		button bitmap12 "无文件" pos:[295,360] width:80 height:80

		button bitmap13 "无文件" pos:[25,450] width:80 height:80
		button bitmap14 "无文件" pos:[115,450] width:80 height:80
		button bitmap15 "无文件" pos:[205,450] width:80 height:80
		button bitmap16 "无文件" pos:[295,450] width:80 height:80
		
		button lastPage "<--上一页" pos:[60,545] width:100 height:30
		button nextPage "下一页-->" pos:[240,545] width:100 height:30
		button PageIndexButton "1/1" pos:[170,545] width:60 height:30
		--
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
		--得到路径的总体数组
		fn getExtentsFromObjArray objs = 
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
			local enxtent = maxpoint - minpoint
			
		)
		fn sizeClamp oldObj newObj oldExtnets newExtnets = 
		(
			local coefficientVector = vectorDivide oldExtnets newExtnets
			local coefficient=1.0
			local ClampAxis = xyzClamp.items[xyzClamp.selection]
			--print("ClampAxis:" + ClampAxis)
			if ClampAxis=="x轴" then
				coefficient = coefficientVector.x
			else if ClampAxis=="y轴" then
				coefficient = coefficientVector.y
			else if ClampAxis=="z轴" then
				coefficient = coefficientVector.z
			else
			(
				messageBox("未知错误未找到轴")
				0
			)
			print("coefficient" + coefficient as string)
			newObj.scale *= coefficient
		)
		fn getSelectedSubPath =
		(
			subAssetFolders = getSubfolders assetPath
			--print (subAssetFolders as string)
			if(subAssetFolders.count>0)then
			(
				dirList.items = subAssetFolders
				selectedSubPath = assetPath +"\\"+ dirList.items[dirList.selection]
				selectedSubPath
			)
		)
		fn ReplaceNode selectedObjs fileP = 
		(
			selectionBake = selectedObjs as Array
			if(ReplaceFlag selectedObjs)then
			(
				local selectionFathers = getOuterObjFormSelection selectedObjs
				if(selectionFathers.count > 1) then
				(
					messageBox "请选择在同一组内的物体"
				)
				else
				(
					local oldObj = selectionFathers[1]
					local oldObjs = selectedObjs
					--关闭组用于判断当用户
					if(isOpenGroupHead oldObj == true)then
					(
						setGroupOpen oldObj false
						select oldObj
						oldObjs = selectedObjs
					)
					local classFlag = true
					for obj in selectedObjs while (classFlag == true) do
					(
						classFlag = (classCheck obj)and classFlag
					)
					--print(classFlag)
					if(classFlag) then --类型判断
					(
						local newObjs = (MergeMaxFileAndReturnObjects fileP)
						if(newObjs!=undefined )then --当用户选择模型时
							if(newObjs.count!=0)then --当用户没有选择跳过时
							(
								local success=()
								local newObj = getOuterFatherNode newObjs --判断最外层节点数量
								local GroupFlag = isGrouped newObjs
								print ("newObj" + newObj as string)
								print ("oldObj" + oldObj as string)
								print ("newObjs" + newObjs as string)
								--print(classOf newObjs)
								if (newObj.count == 1) then
								(
									print("1")
									success = ReplaceObj oldObj newObj[1]
									if(sizeClampCheckBox.checked)then
									(
										--需要传入所有需要参与计算的物体数组
										local newObjExtnets = getExtentsFromObjArray newObjs
										local oldObjExtnets = getExtentsFromObjArray oldObjs
										--需要传入所有需要参与计算的物体数组
										sizeClamp oldObj newObj oldObjExtnets newobjExtnets
										print("转化前新物体的extent:"+ newObjExtnets as string)
										print("转化前旧物体的extent:"+ oldObjExtnets as string)
										print("转化后新物体的extent:"+ (getExtentsFromObjArray newObjs)as string)
									)
									undo on(
										delete oldObj
									)
								)
								else if(newObj.count>1)then
								(
									print("2")
									local myGroup = group newObjs
									success = ReplaceObj oldObj myGroup
									
									if(sizeClampCheckBox.checked)then
									(
										--需要传入所有需要参与计算的物体数组
										local newObjExtnets = getExtentsFromObjArray newObjs
										print("newObjExtnets"+ newObjExtnets as string)
										local oldObjExtnets = getExtentsFromObjArray oldObjs
										print("oldObjExtnets"+ oldObjExtnets as string)
										--需要传入完整的组
										sizeClamp oldObj myGroup oldObjExtnets newobjExtnets
										print("转化前新物体的extent:"+ newObjExtnets as string)
										print("转化前旧物体的extent:"+ oldObjExtnets as string)
										print("转化后新物体的extent:"+ (getExtentsFromObjArray newObjs)as string)
									)
									--
									undo on(
										delete oldObj
									)
								)
								if(success!=true) then
								(
									delete newObjs
									select selectionBake
								)
								else
								(
									select newObjs
									actionMan.executeAction 0 "50001"  -- Tools: 选择并移动
								)
							)
					)
					else
					(	
						local unsupportList = #()
						for obj in selectedObjs do
						(
							if(classCheck obj == false) then
								append unsupportList (classof obj)
						)
						messageBox ("场景中被替换的物体存在不支持类型,不支持的类型为：" + unsupportList as string+"\n如果可以请尝试转化为可编辑网格")
					)
				)
			)
			
		)
		fn getMapFileIndex = 
		(
			
			local mapindex = (nowPage-1)*16+nowPressedButtonIndex
		)
		fn getNowSelectedFilePath = 
		(
			local mapindex = getMapFileIndex()
			local mapPath = getElementFromArry mapFile mapindex
			print("当前索引下的位图文件")
			print(mapPath)
			nowSelectedFilePath = mapPath
			if(mapPath!=undefined) then
			(
				print("正在通过位图名称寻找max文件")
				local fileN = ((getFilenameFile mapPath)+".max")
				local fileP = SerchWithPathAndFileName selectedSubPath fileN
				print("文件路径如下:")
				print(fileP)
				fileP
			)
			else
			(
				undefined
			)
				
		)
		fn getAllFilePath = 
		(
			local mapArray =#()
			for mapPath in mapFile do
			(
				print("当前索引下的位图文件")
				print(mapPath)
				if(mapPath!=undefined) then
				(
					print("正在通过位图名称寻找max文件")
					local fileN = ((getFilenameFile mapPath)+".max")
					local fileP = SerchWithPathAndFileName selectedSubPath fileN
					print("文件路径如下:")
					print(fileP)
					if(fileP!=undefined)then
						append  mapArray fileP
						
				)
			)
			mapArray
		)
		fn setAllPage =
		(
			if(mod bitMaps.count 16 == 0) then
				allPage = ((bitMaps.count/16)as integer)
			else
				allPage = ((bitMaps.count/16)as integer) + 1
		)
		-- rollout 打开事件
		on pengpai1 open do
		(
			undo off(
				append imageButtonList bitmap1
				append imageButtonList bitmap2
				append imageButtonList bitmap3
				append imageButtonList bitmap4
				append imageButtonList bitmap5
				append imageButtonList bitmap6
				append imageButtonList bitmap7
				append imageButtonList bitmap8
				append imageButtonList bitmap9
				append imageButtonList bitmap10
				append imageButtonList bitmap11
				append imageButtonList bitmap12
				append imageButtonList bitmap13
				append imageButtonList bitmap14
				append imageButtonList bitmap15
				append imageButtonList bitmap16
				if(assetPath !=undefined and assetPath !="")then
				(
					trimedPath = TrimStringWithEllipsis assetPath (btnSelectPath.width/9) --依据width/9为长度裁剪字符串
					btnSelectPath.text = trimedPath
					LoadBitmapsFromDirectory (getSelectedSubPath ())
					setAllPage()
					updatePageIndex PageIndexButton
					updateButtonIcon imageButtonList
				)
			)
		)

		--尺寸钳制开关事件
		on sizeClampCheckBox changed theState do
		(
			xyzClamp.enabled = theState
		)
		--
		--资产路径选择
		on btnSelectPath pressed do
		(
			undo off(
				assetPath = getSavePath caption:"选择文件"
				if(assetPath != undefined) then
				(
					trimedPath = TrimStringWithEllipsis assetPath (btnSelectPath.width/9) --依据width/9为长度裁剪字符串
					btnSelectPath.text = trimedPath
					--print("Load")
					LoadBitmapsFromDirectory (getSelectedSubPath())
					setAllPage()
					nowPage = 1
					updatePageIndex PageIndexButton
					updateButtonIcon imageButtonList
				)
			)
		)
		--end资产路径选择
		on dirList selected index do
		(
			undo off(
				LoadBitmapsFromDirectory (getSelectedSubPath())
				setAllPage()
				nowPage = 1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)
		)
		--页面更新逻辑
		on nextPage pressed do
		(
			undo off(
				if((nowPage+1) <= allPage) do
				(
					nowPage+=1
					updatePageIndex PageIndexButton
					updateButtonIcon imageButtonList
					
				)
			--print (allPage)
			)
		)
		on lastPage pressed do
		(
			undo off(
				if((nowPage-1) > 0) do
				(
					nowPage-=1
					updatePageIndex PageIndexButton
					updateButtonIcon imageButtonList
				)
			)
		)
		--end页面更新逻辑
		
		--模型替换方法
		on btnReplaceModel pressed do
		(
			undo off(
				if(selection.count==0) then
					messageBox "请在场景内选择被替换的物体"
				else
				(
					--得到图片对应的max文件
					local fileP = getNowSelectedFilePath()
					if(fileP!=undefined) then
					(
						--print(fileP as string)
						ReplaceNode selection fileP
					)
					else
					(
						print("未找到图片对应模型")
						messageBox "未找到图片所对应的模型"
					)
				)	
			)
		)
		--end替换方法
		--裂变窗口
		on btnOpenFission changed state do
		(
			if state == on then
				CreateDialog fission 300 400 style:#(#style_titlebar,#style_sysmenu,#style_minimizebox,#style_maximizebox) parent:pengpai1.hwnd 
			else
				DestroyDialog fission
		)
		--end裂变窗口
		--图片按钮方法
		on bitmap1 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap1 1
				nowPressedButtonIndex = 1
			)
		)

		on bitmap2 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap2 2
				nowPressedButtonIndex = 2
			)
		)

		on bitmap3 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap3 3
				nowPressedButtonIndex = 3
			)
		)

		on bitmap4 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap4 4
				nowPressedButtonIndex = 4
			)
		)

		on bitmap5 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap5 5
				nowPressedButtonIndex = 5
			)
		)

		on bitmap6 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap6 6
				nowPressedButtonIndex = 6
			)
		)

		on bitmap7 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap7 7
				nowPressedButtonIndex = 7
			)
		)

		on bitmap8 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap8 8
				nowPressedButtonIndex = 8
			)
		)

		on bitmap9 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap9 9
				nowPressedButtonIndex = 9
			)
		)

		on bitmap10 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap10 10
				nowPressedButtonIndex = 10
			)
		)

		on bitmap11 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap11 11
				nowPressedButtonIndex = 11
			)
		)

		on bitmap12 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap12 12
				nowPressedButtonIndex = 12
			)
		)

		on bitmap13 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap13 13
				nowPressedButtonIndex = 13
			)
		)

		on bitmap14 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap14 14
				nowPressedButtonIndex = 14
			)
		)

		on bitmap15 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap15 15
				nowPressedButtonIndex = 15
			)
		)
		on bitmap16 pressed do 
		( 
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap16 16
				nowPressedButtonIndex = 16
			)
		)
		--end图片按钮方法
	--*
	)
-------------------------------------------------------------------endUI-------------------------------------------------------
	
	theNewFloater = newRolloutFloater "Grinning" 420 610--rollout宽度为RolloutFloater的宽度-10
	pengpaiInstance = pengpai1
	addRollout pengpaiInstance theNewFloater 
	
)

--createDialog mainRollot 400 600
