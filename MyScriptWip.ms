try(closeRolloutFloater theNewFloater) catch()
(
	
	---------------------------------------------------变量----------------------------------------------
		global BitMaps = #() --Class:BitMap
		global MapFiles = #() --Class:stringName
		global assetPath = @"F:\脚本测试文件\资产"
		global subAssetFolders
		global selectedSubPath
		global nowPage = 1
		global allPage = 0
		global nowPressedButtonIndex = 0
		global imageButtonList =#()
		global nowSelectedFilePath = ()
		global PengPaiInstance = undefined
		global theNewFloater = undefined
		--模型标签
		global modelFlag = ()
		if(assetPath == undefined) then assetPath = ()
	-------------------------------------------------end变量---------------------------------------------
	---------------------------------------------------方法----------------------------------------------
		--增量保存脚本hou
		fn IncrementalSave numCopies =
		(
			-- 获取当前场景文件的完整路径检测是否保存文件
			local currentFilePath = maxFilePath + maxFileName
			
			-- 检查是否有打开的文件
			if currentFilePath == "" then
			(
				print "没有打开任何文件!"
				false
			)
			else
			(
				-- 分离文件名和扩展名
				local fileName = getFilenameFile(currentFilePath)
				local fileExt = getFilenameType(currentFilePath)
				local filesArray =#()
				-- 循环以生成增量保存
				for i = 1 to numCopies do
				(
					-- 构造新文件名，例如：MyScene_1.max, MyScene_2.max 等等
					local newFileName = (fileName + "_" + (i as string) + fileExt)
					local newFilePath = maxFilePath + newFileName
					
					-- 保存当前场景到新路径
					saveMaxFile newFilePath quiet:true
					append filesArray newFilePath
					print ("已保存: " + newFilePath)
				)
				filesArray
			)
			
		)
		--
		fn RenameAllDuplicatesObjName =
		(
			-- 创建一个空的数组来存储物体名称和计数
			local nameArray = #()
	
			-- 遍历场景中的所有几何对象
			local objs =#()
			for element in geometry do
				append objs element
			for element in helpers do
				append objs element
			for obj in objs do
			(
				-- 获取物体名称
				local objName = obj.name
	
				-- 查找该名称在 nameArray 中是否存在
				local found = false
				for i = 1 to nameArray.count do
				(
					if nameArray[i][1] == objName then
					(
						-- 如果找到，增加计数并设置 found 为 true
						nameArray[i][2] += 1
						found = true
						exit -- 找到后退出循环，不再继续查找
					)
					
				)
	
				-- 如果没有找到该名称，添加新条目到 nameArray 中
				if not found then 
				(
					append nameArray #(objName, 1) -- 名称和初始计数为 1 的数组元素
				)
			)
	
			-- 输出重名物体的信息
			local hasDuplicates = false
			for i = 1 to nameArray.count do
			(
				if nameArray[i][2] > 1 then 
				(
					print (nameArray[i][1] + " 重复出现了 " + (nameArray[i][2]) as string + " 次.")
					--重命名物体
					for j=1 to nameArray[i][2] do
					(
						(getNodeByName nameArray[i][1]).name = (nameArray[i][1]+ "_" + j as string)
						print (nameArray[i][1] + " 重命名为 " + nameArray[i][1]+ "_" + j as string)
					)
					hasDuplicates = true
				)
			)	
			if not hasDuplicates then 
			(
				hasDuplicates
				print "没有发现重名的物体。"
			)
			hasDuplicates
	
		)
		--
		--*向量除法
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
				(	
					newObj.transform = oldObj.transform	
					if(oldObj.parent!=newObj)then
						newObj.parent = oldObj.parent
					else
						messageBox("oldObj.parent==newObj")
					--print (newObj.transform as string +"\n"+ oldObj.transform as string )
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
		--获取选中物体得到最高级的父级物体
		fn RecursiveGetParent currentObj parents = -- 递归获取父级物体
		(
			if currentObj != undefined do (
				local parentObj = currentObj.parent  -- 获取当前对象的父级
				if parentObj != undefined then (
					if findItem parents parentObj == 0 then
						append parents parentObj  -- 将父级添加到列表中
					RecursiveGetParent parentObj parents  -- 递归调用以获取上一级的父级
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
				RecursiveGetParent obj parents  -- 开始递归从传入的对象开始
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
					if(isValidNode obj)then
					(
						if(obj.parent!=undefined) then --如果obj的父级没有定义那么obj就是最外层的
						(
							if(findItem objs obj.parent ==0) then
							append fathers obj
						)
						else
							append fathers obj
					)
				)
			)
			else
			(
				if(isValidNode objs[1])then
				(
					append fathers objs[1]
				)
			)
			fathers
		)
		--*
		--从路径和文件名搜索文件
		fn SerchWithPathAndFileName path  fileName = 
		(
			local file = ()
			local filePath = (path + fileName)
	
			if(path[path.count]=="\\")then
				file = getFiles (path + fileName) recurse:false
			else
				file = getFiles (path +"\\"+ fileName) recurse:false
			print("文件夹路径:" + path as string  + "  文件名称:" + fileName as string)
	
			print("拼接后的路径：" + file as string)
			file[1]
		)
	
		fn SerchMaxFileWithMapFile mapPath =
		(
			local fileN = ((getFilenameFile mapPath) + ".max")
			print("getFilenameFile-Max文件名"+fileN)
			local fileP = getFilenamePath mapPath
			print("getFilenamePath-Max文件路径"+fileP)
			SerchWithPathAndFileName fileP fileN
		)
		--end从路径和文件名搜索文件
		--*
		--从路径加载max文件并返回新增物体列表
		fn MergeMaxFileAndReturnObjects filePath =
		(
			--检查文件是否存在
			if(filePath != undefined)then
				if doesFileExist filePath then 
				(
					-- 获取当前场景中的对象数量
					local initialObjectCount = objects.count
					
					local oldObj = (geometry as Array)
					-- 合并新的 .max 文件
					undo off
					(
						mergeMAXFile filePath #mergeDups #useMergedMtlDups quiet:true
					)
					
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
				BitMaps = #()
				MapFiles = #()
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
						-- 遍历每个文件
						for file in files do
						(
							-- 获取文件扩展名并转换为小写以便匹配
							local fileExtension = toLower (getFilenameType file)
							
							-- 检查该扩展名是否在支持列表中
							if findItem bitmapExtensions fileExtension > 0 then 
							(
								local map1 = bitmap 128 128 filename:file
								local map2 = openBitMap file
								
								copy map2 map1
								append MapFiles file 
								append BitMaps map1          
								free map2
							)
						)
					)
				)
				else 
				(
					print("路径不存在:" + directoryPath)
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
			--获取当前活动视图的对象
			local activeView = viewport.getCamera()
			
			if activeView != undefined and superclassof activeView == Camera then
			(
				--设置渲染参数为当前相机
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
					if(BitMaps.count>=mapIndex) then
					(
						local blackimage = bitmap 64 64 color:black
						if(BitMaps[mapIndex] != undefined) then
							try(imageButtonList[i].images = #(BitMaps[mapIndex], undefined, 1,1,1,1,1 )) 
								catch(
									
									--imageButtonList[i].images = #(blackimage, undefined, 1,1,1,1,1 )
									print("贴图加载异常01")
									print(BitMaps[mapIndex])
									LoadBitmapsFromDirectory (pengpaiInstance.getSelectedSubPath())
								)
						else
						(
							--local blackimage = bitmap 64 64 color:black
							try(imageButtonList[i].images = undefined)
								catch(
										print(BitMaps[mapIndex])
										print("贴图加载异常02")
										LoadBitmapsFromDirectory (pengpaiInstance.getSelectedSubPath())
								)
						)
					)
					else
					(						
						try(imageButtonList[i].images = undefined)
							
							catch(
									print(BitMaps[mapIndex])
									print("贴图加载异常03")
									LoadBitmapsFromDirectory (pengpaiInstance.getSelectedSubPath())
							)
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
		fn updatePreviewImageButton previewImageButton i =
		(
			local mapIndex = (nowPage-1)*16+i
			if(i == 0)then
			(
				previewImageButton.images = undefined
				
			)
			else if(mapIndex<=BitMaps.count) then
			(
				try(previewImageButton.images = #(BitMaps[mapIndex], undefined, 1,1,1,1,1))
					catch(print("贴图加载异常04"))
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
		
		
		--选中物体列表是否为完整组并选中整组物体
		fn isGroupValid objs =
		(
			outerNode = getOuterObjFormSelection objs
			--getOuterObjFormSelection objs
			if(outerNode.count>1)then
				false
			else
			(
				if(isValidNode outerNode[1])then(
					if(isGroupHead outerNode[1]==true)then
					(
						setGroupOpen outerNode[1] false
					)
					true
				)
				else
				(
					false
				)
				
			)
		)
		--检查选中物体列表是否满足选中规则，单个物体，整组物体。
		fn SelectFlag objs =
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
				messageBox("SelectFlag：传入参数未定义")
		)
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
		--得到物体组的边界范围
		fn getExtentsFromObjArray objs = 
		(
			local maxpoint = [-1e+30,-1e+30,-1e+30]
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
		--渲染并保存文件方法
		fn renderAndSaveImage renderImage = 
		(
			-- 获取当前 Max 文件的路径和名称
			local currentFilePath = maxFilePath
			if currentFilePath != "" then
			(
				local directoryPath = maxFilePath  -- 获取目录路径
				local fileNameWithoutExtension = getFilenameFile maxFileName  -- 获取不带扩展名的文件名
				-- 构建输出路径，将渲染图像保存到与 Max 文件相同的目录下
				local outputPath = directoryPath + fileNameWithoutExtension + ".png"
				-- 渲染并保存到指定文件名
				renderImage = render outputfile:outputPath quiet:true 
				free renderImage
				print ("Rendered to " + outputPath)
			)
			else
			(
				print "请先保存当前场景文件！"
			)
		)
		--鼠标在某一ui控制器内部		
		fn mouseInFlag mousePosition controller =
		(
			local controllerPositon = controller.position
			local width = controller.width
			local height = controller.height
			local maxPoint = [controllerPositon.x + width ,controllerPositon.y+height]
			local minPoint = controllerPositon
			if(mousePosition<=maxPoint and mousePosition>=minPoint)then
			(
				true
			)
			else
			(
				false
			)
		)
		--从物体列表中得到物体的最大点和最小点
		fn getMaxAndMinPointFromObjArray objs = 
		(
			local maxpoint = [-1e+30,-1e+30,-1e+30]
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
		--从物体列表中得到物体的局部包围盒的最大点和最小点

		--得到物体的底面中心
		fn getBottomCenter objs = 
		(
			local MaxAndMin = getMaxAndMinPointFromObjArray objs
			maxPoint = MaxAndMin[1]
			minPoint = MaxAndMin[2]
			local x = (maxPoint.x + minPoint.x) / 2
			local y = (maxPoint.y + minPoint.y) / 2
			local z = minPoint.z
			[x, y, z]
		)
		--得到物体的顶面中心
		fn getUpperCenter objs = 
		(
			local MaxAndMin = getMaxAndMinPointFromObjArray objs
			maxPoint = MaxAndMin[1]
			minPoint = MaxAndMin[2]
			local x = (maxPoint.x + minPoint.x) / 2
			local y = (maxPoint.y + minPoint.y) / 2
			local z = maxPoint.z
			[x, y, z]
		)
		--得到物体的背面中心
		fn getBackCenter objs = 
		(
			local MaxAndMin = getMaxAndMinPointFromObjArray objs
			maxPoint = MaxAndMin[1]
			minPoint = MaxAndMin[2]
			
			local x = (maxPoint.x + minPoint.x) / 2
			local y = minPoint.y
			local z = (maxPoint.z + minPoint.z) / 2
			[x, y, z]
		)
	--------------------------------------------------end方法--------------------------------------------
	--------------------------------------------------UI类-----------------------------------------------
		rollout fission "裂变窗口"
		(
			dropdownlist FissionMethod "替换方式"items:#("同步循环替换")
			listbox listbox1 "原物体列表" pos:[20,50] width:100 height:10 tooltip:"该列表存放了场景中被裂变的物体名称" --height=140
			listbox listbox2 "裂变物体列表" pos:[180,50] width:100 height:10 tooltip:"该列表存放了用于裂变的被裂变的物体名称" --height=140
			button  AddToOriginObjList "添加原物体" pos:[20,200] width:100 height:40 tooltip:"将选中的场景模型添加到原物体列表\n点击前请在场景中选中模型"
			button AddToFissionObjList "添加裂变物体" pos:[180,200]width:100 height:40 tooltip:"将选中的资产模型添加到原物体列表\n点击前请在资产模型中选中物体"
			button AddAllToFissionObjList "添加目录下的所有物体" pos:[180,240]width:100 height:40 tooltip:"执行裂变操作"
			button StartFission "开始裂变" align:#center width:60 height:30
			dropdownlist modelFlagList "模型标签"pos:[120,50] width:60 align:#center items:#("地面","墙面","顶面")tooltip:"标记模型类型，替换时会根据模型类型确定替换轴"
			local originObjs = #() --物体列表
			local originObjsName = #() --物体名字列表
			local maxFissionNum = 0
			-----------------------------------每种裂变对应关系需要的数据结构---------------------------------
			--方法1，每次对所有被裂变的物体进行裂变，选择了最多裂变物体的模型为基准产生裂变方案数量
			--local M1_selectedIndex = 0
			locaL M1_fissionObjsPathsArray = #(#())
			locaL M1_fissionObjsNameArray = #(#())
			--end方法1
			---------------------------------end每种裂变对应关系需要的数据结构---------------------------------
			--------------------------------------执行器需要的裂变数据----------------------------------------
			local objPairsArray = #()
			local modelFlagIndexArray = #()
			-------------------------------------end执行器需要的裂变数据--------------------------------------
			--物体对结构，通过物体对列表
			struct objPair (obj , filePath , modelFlagIndex )
			--构建物体对方法
			fn MakeReplacePair originObjs newObjPath modelFlagIndex =
			(
				objPair obj:originObjs filePath:newObjPath modelFlagIndex:modelFlagIndex
			)
			--物体对列表构建器，返回每次替换时需要替换的物体对列表的列表
			fn ObjPairArrayMaker oldObjs newObjs modelFlagIndex =
			(
				case FissionMethod.selection of
				(
					--执行M1
					1:
					(
						for i=1 to originObjs.count do (
							for fissionObj in M1_fissionObjsPathsArray[i] do (
								MakeReplacePair originObjs[i] fissionObj modelFlagIndex
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
							else if(isValidNode selectionFathers[1])then
							(
								if(findItem originObjs selectionFathers[1] == 0) then
								(
									append originObjs selectionFathers[1]
									append originObjsName selectionFathers[1].name as string

									--如果为空则创建数组
									if(M1_fissionObjsPathsArray[originObjs.count] == undefined)then
									M1_fissionObjsPathsArray[originObjs.count] = #()
									if(M1_fissionObjsNameArray[originObjs.count] == undefined)then
									M1_fissionObjsNameArray[originObjs.count] = #()

									append modelFlagIndexArray modelFlagList.selection
									listbox1.items = originObjsName	
								)
							)
							else
							(
								messagebox"选中节点非法请重新选择"
							)
						)
					)
				)
			)
			fn deleteOObjInfo num = 
			(
				case FissionMethod.selection of
				(
					1:
					(
						if(originObjsName[num] != undefined and originObjsName[num] != #())then
						(
							deleteItem originObjsName num
							deleteItem originObjs num
							deleteItem modelFlagIndexArray num
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
						--如果为空则创建数组
						if(M1_fissionObjsPathsArray[listbox1.selection] == undefined)then
							M1_fissionObjsPathsArray[listbox1.selection] = #()
						if(M1_fissionObjsNameArray[listbox1.selection] == undefined)then
							M1_fissionObjsNameArray[listbox1.selection] = #()
						--判断是否重复存在
						if(finditem M1_fissionObjsPathsArray[listbox1.selection] filePath == 0)then
						(
							print("添加裂变物体成功")
							append M1_fissionObjsPathsArray[listbox1.selection] filePath
							append M1_fissionObjsNameArray[listbox1.selection] ((getFilenameFile filePath) as string)
							--同时更新列表内容
							listbox2.items = M1_fissionObjsNameArray[listbox1.selection]
						)
						else
						(
							print("裂变物体已存在请勿重复添加")
						)
					)
				)
			)
			fn addAllFissionObj =
			(
				if(listbox1.selection>0)then
				(
					local files = PengPaiInstance.getAllFilePath()
					print("全部文件: 如下")
					print(files)
					for myfile in files do
					(
						addFissionObj myfile
					)
				)
				else
				(
					print("没有选中原物体无法添加裂变物体")
				)
			)
			--删除裂变物体
			fn deleteFObjInfo num =
			(
				case FissionMethod.selection of
				(
					1:
					(
						if(M1_fissionObjsPathsArray[listbox1.selection][num] != undefined)then
						(
							deleteItem M1_fissionObjsPathsArray[listbox1.selection] num
							deleteItem M1_fissionObjsNameArray[listbox1.selection] num
							listbox2.items = M1_fissionObjsNameArray[listbox1.selection]
						)
					)
				)
			)
			--选择器,根据列表信息返回对应的执行器需要的数据
			fn Selecter = 
			(
				case FissionMethod.selection of
				(
					1:
					(
						local num = 0
						for i=1 to originObjs.count do
						(
							if(M1_fissionObjsPathsArray[i+num].count==0)then
							(
								
								deleteItem originObjs (i+num)
								deleteItem originObjsName (i+num)
								deleteItem M1_fissionObjsPathsArray (i+num)
								deleteItem M1_fissionObjsNameArray (i+num)
								deleteItem modelFlagIndexArray (i+num)
								num-=1
							)
						)
						--方法一执行最大次数，这影响了objPairsArray的长度
						local MaxNum = 0
						print(M1_fissionObjsPathsArray as string)
						for nameArray in M1_fissionObjsPathsArray do 
						(
							MaxNum = myMax nameArray.count MaxNum
						)
						maxFissionNum =  MaxNum
						print("MaxNum"+MaxNum as string)
						if(MaxNum>0)then
						(
							--每一个物体进行一次循环将其与其关联的裂变物体制成物体对并添加到物体对数组数组
							for i=1 to originObjs.count do
							--j为第j次裂变执行的物体对数组
							if(M1_fissionObjsPathsArray[i].count>0)then
							for j=1 to MaxNum do
							(
								if(objPairsArray[j] == undefined)then
									objPairsArray[j] = #()
								local pathCount = M1_fissionObjsPathsArray[i].count
								local index = mod j pathCount
								if(index==0)then
								(
									index = pathCount
								)
								--添加数据到第j次执行时的物体对数组
								append objPairsArray[j] (MakeReplacePair originObjsName[i] M1_fissionObjsPathsArray[i][index] modelFlagIndexArray[i])
							)
						)
					)
				)
			)
			--执行器，根据物体对列表的列表逐步执行物体替换
			fn Executor =
			(
				case FissionMethod.selection of
				(
					1:
					(
						--增量保存并返回文件名数组，为空则返回空数组
						
						if(maxFissionNum==0)then
						(
							messageBox("maxFissionNum为零裂变无法执行")
							true
						)
						else(
							local originalMaxFile = maxFilePath+maxFileName
							local MaxFileArray = IncrementalSave maxFissionNum		
							local sucFlg = true
							print("originalMaxFile"+originalMaxFile)
							if(MaxFileArray!=false)then
							(
								loadmaxFile MaxFileArray[1] quiet:true
								local renderImage
								--第一层循环确定max文件
								for i=1 to maxFissionNum do
								(
									-- 第二层循环用于替换物体
									for objPair in objPairsArray[i] do
									(
										local objFormNames = #()
										--通过物体名寻找物体找不到则返回undefined

										append objFormNames (getNodeByName objPair.obj)
										print("objName:" + objPair.obj)
										print("getNodeByName:" + (getNodeByName objPair.obj as string))
										if(objFormNames[1] != undefined)then
										(
											pengpaiInstance.modelFlagList.selection = objPair.modelFlagIndex
											pengpaiInstance.ReplaceNode objFormNames objPair.filePath
										)
										else
										(
											messagebox ("无法从物体名"+ (objPair.obj as string) +"称找到对应物体\n请勿在添加裂变列表后随意更改物体\n将返回原始文件")
											sucFlg = false
											break
										)
										--sleep 0.1
									)
									--替换出现失败后重新加载原始文件
									if(sucFlg==false)then
									(
										loadmaxFile originalMaxFile
									)
									else
									(
										RenameAllDuplicatesObjName()
										saveMaxFile MaxFileArray[i] quiet:true
										--renderAndSaveImage renderImage
										if(i+1<=maxFissionNum)then
											loadMaxFile MaxFileArray[i+1] quiet:true
									)
									
								)
								true
								
							)
							else
							(
								messageBox "请保存文件"
								local filename = getMAXSaveFileName()
								saveMaxFile filename quiet:true
								false
							)
							
						)
					)
				)
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
							if(isDeleted originObjs[num]==true or originObjs[num]==undefined)then
							(
								deleteOObjInfo num
								listbox1.items = originObjsName
							)
							else
							(
								--选中场景物体
								local o = getNodeByName originObjsName[num]
								select o
								--更换模型标签
								modelFlagList.selection = modelFlagIndexArray[num]
								print(modelFlagIndexArray as string)
							)
								
						)
					)
				)
				
			)
			on modelFlagList selected num do
			(
				if(listbox1.selection>0)then
					modelFlagIndexArray[listbox1.selection] = num
			)
			on listbox1 rightClick num do
			(
				listbox1.items = originObjsName
				deleteOObjInfo num
				
			)
			on listbox2 rightClick num do
			(
				print("列表2被右键点击")
				deleteFObjInfo num
			)
			on AddToOriginObjList pressed do
			(
				print("添加原物体被点击")
				addOriginObj selection
			)
			on AddToOriginObjList mouseMove pos do
			(
				print("鼠标悬停1")
			)
			on AddToFissionObjList pressed do
			(
				if(listbox1.selection>0)then
				(
					print("添加到裂变被点击")
					local filePath = PengPaiInstance.getNowSelectedFilePath()
					if(filePath!=undefined)then
					(
						addFissionObj filePath
					)
					else
					(
						messageBox"资产模型不存在或未选择资产模型"
					)
				)
				else
				(
					print("没有选中原物体裂变物体无法添加")
				)
				
			)
			on AddAllToFissionObjList pressed do
			(
				print("全选按钮被点击")
				addAllFissionObj()
			)
			on StartFission pressed do
			(
				local oc = okCancelBox "请检查渲染设置是否正确\n裂变后max文件会以\"_数字标号\"的形式重命名\n清确保不会有重名文件，否则重名文件会被替换并且不会有任何提示"
				if(oc==#ok)then
				(
					Selecter()
					print(objPairsArray.count)
					for i=1 to objPairsArray.count do
					(
						sleep 0.1
						format "这是第%次执行时的替换数据" i
						print("objPairsArray:"+objPairsArray as string)
						for objPair in objPairsArray[i] do
						(
							print("objPairsArray[]:" + objPairsArray[i] as string)
							print("obj" + objPair.obj as string)
							print("filePath"+objPair.filePath as string)
						)	
					)
					--Executor()执行成功返回true否则返回false
					if(Executor())then
						try(DestroyDialog fission)catch()
				)
			)
			on fission close do
			(
				PengPaiInstance.btnOpenFission.state = off
			)
		)
		rollout pengpai1 "模型替换"
		(
			button btnSelectPath "选择资产路径" width:380 height:20 align:#center toolTip:"选择资产目录，该资产目录应应包含若干子集目录"
			dropdownlist dirList "子目录" width:380 height:20 align:#center toolTip:"包含资产路径下的子目录"
			button btnReplaceModel "替换" pos:[40,115] width:100 height:30 align:#cente toolTip:"执行模型替换\n替换前请确保同时在资产模型和场景中选中模型"
			checkbutton  btnOpenFission "打开裂变窗口" pos:[40,80] width:100 height:30 align:#cente toolTip:"打开裂变窗口"
			button previewImage pos:[300,78] width:80 height:80 toolTip:"这里显示了您选中的资产模型"
			checkbox sizeClampCheckBox "尺寸钳制" pos:[140,125] toolTip:"在替换或者裂变模型时钳制模型大小" checked:true
			dropdownlist xyzClamp pos:[210,122] width:70 height:20 items:#("最小轴","x轴","y轴","z轴") enabled:true toolTip: "x轴：将资产模型在X轴方向的尺寸缩放至与场景模型的宽度一致\ny轴：将资产模型在X轴方向的尺寸缩放至与场景模型的宽度一致\nz轴：将资产模型在X轴方向的尺寸缩放至与场景模型的宽度一致\n最小轴:选择钳制后尺寸最小的轴"
			--新标签请在数组末尾添加
			dropdownlist modelFlagList "模型标签" pos:[150,80] width:70 height:20 items:#("地面","墙面","顶面")toolTip:"标记模型类型，替换时会根据模型类型确定替换轴"
			label tag "模型预览：" pos:[235,100]
			
			--label assetModel "资产库模型" pos:[240,115] style_sunkenedge:true width:80 height:30 align:#center
			GroupBox bitmapGroup "资产模型"  pos:[10,160] width:380 height:380
			button bitmap1 "空"pos:[25,180]  width:80 height:80
			button bitmap2 "空"pos:[115,180] width:80 height:80
			button bitmap3 "空"pos:[205,180] width:80 height:80
			button bitmap4 "空"pos:[295,180] width:80 height:80
	
			button bitmap5 "空"pos:[25,270]  width:80 height:80
			button bitmap6 "空"pos:[115,270] width:80 height:80
			button bitmap7 "空"pos:[205,270] width:80 height:80
			button bitmap8 "空"pos:[295,270] width:80 height:80
	
			button bitmap9 "空" pos:[25,360]  width:80 height:80
			button bitmap10"空" pos:[115,360] width:80 height:80
			button bitmap11"空" pos:[205,360] width:80 height:80
			button bitmap12"空" pos:[295,360] width:80 height:80
	
			button bitmap13"空" pos:[25,450] width:80 height:80
			button bitmap14"空" pos:[115,450] width:80 height:80
			button bitmap15"空" pos:[205,450] width:80 height:80
			button bitmap16"空" pos:[295,450] width:80 height:80
			
			button lastPage "<--上一页" pos:[60,545] width:100 height:30
			button nextPage "下一页-->" pos:[240,545] width:100 height:30
			button PageIndexButton "1/1" pos:[170,545] width:60 height:30
			--
			local renamed = false
			--模型标签替换方法
			--fn changeModelFlagList index =
			--(
				--modelFlag = modelFlagList.items[index]
				--modelFlagList.selection = index
				--print("modelFlag:" + modelFlag)
			--)
			fn sizeClamp oldObj newObj oldExtnets newExtnets = 
			(
				local coefficientVector = vectorDivide oldExtnets newExtnets
				local coefficient=1.0
				local ClampAxis = xyzClamp.items[xyzClamp.selection]
				--print("ClampAxis:" + ClampAxis)
				if ClampAxis=="最小轴" then
				(
					coefficient = myMin coefficientVector.x coefficientVector.y
					coefficient = myMin coefficient coefficientVector.z
				)
				else if ClampAxis=="x轴" then
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
				print("钳制系数：" + coefficient as string)
				newObj.scale *= coefficient
			)
			fn getSubfolders folderPath = 
			(
				-- 确保传入的路径存在并是一个文件夹
				if doesFileExist folderPath and (getDirectories (folderPath + "\\*")) != undefined then
				(
					local folderList = getDirectories (folderPath + "\\*") -- 获取所有子文件夹
					local folderNames = for folder in folderList collect (getFilenameFile (trimRight folder "\\"))
					folderNames
				)
				else
				(
					format "提供的路径无效或不是一个文件夹: %\n" folderPath
					#() -- 返回空数组
				)
			)
			fn getSelectedSubPath =
			(
				print("getSelectedSubPath：" + assetPath as string)
				subAssetFolders = getSubfolders assetPath
				--print (subAssetFolders as string)
				if(subAssetFolders.count>0)then
				(
					dirList.items = subAssetFolders
					print(dirList.items as string)
					print("dirList.selection"+dirList.selection as string)
					selectedSubPath = assetPath +"\\"+ dirList.items[dirList.selection]
					print("selectedSubPath:"+selectedSubPath)
					selectedSubPath
				)
				else if(subAssetFolders.count==0)then
				(
					dirList.items = #(("无文件"))
					print(dirList.items as string)
					print("dirList.selection"+dirList.selection as string)
					selectedSubPath = assetPath +"\\"+ dirList.items[dirList.selection]
					print("selectedSubPath:"+selectedSubPath)
				)
			)
			fn ReplaceNode selectedObjs fileP = 
			(
				undo off(
					selectionBake = selectedObjs as Array
					local selectionFathers = getOuterObjFormSelection selectedObjs
					local oldObj = selectionFathers[1]
					local oldObjs = selectedObjs as Array
					print("oldObj"+oldObj as string)
					print("oldObjs"+oldObjs as string)
				)
				--关闭组用于判断当用户选择打开组时的情况

				if(isOpenGroupHead oldObj == true)then
				(
					undo off(
						setGroupOpen oldObj false
						select oldObj
						selectedObjs = (selection as Array)
						oldObj = (getOuterObjFormSelection selectedObjs)[1]
						print("组头判断后信息变化")
						print("oldObj"+oldObj as string)
						print("oldObjs"+oldObjs as string)
						oldObjs = (selection as Array)
						selectionBake = (selection as Array)
					)
				)
				print("selectionFathers="+selectionFathers as string)
				undo off(
					local classFlag = true
				)

				for obj in selectedObjs while (classFlag == true) do
				(
					undo off(
						classFlag = (classCheck obj)and classFlag
					)
				)
				if(classFlag) then --类型判断
				(
					undo off(
						local newObjs = (MergeMaxFileAndReturnObjects fileP)
					)
					if(newObjs!=undefined )then --当用户选择模型时
						if(newObjs.count!=0)then --当用户没有选择跳过时
						(
							undo off(
								local success=()
								local newObj = getOuterFatherNode newObjs --判断最外层节点数量
								--local GroupFlag = isGrouped newObjs
								print ("newObj" + newObj as string)
								print ("oldObj" + oldObj as string)
								print ("newObjs" + newObjs as string)
							)
							--print(classOf newObjs)
							if (newObj.count == 1) then
							(
								undo off
								(
									print("加载的max文件只有一个物体")
									--物体质点设置
									if(modelFlagList.selection == 1)then
									(
										print("地面")
										oldObj.pivot = getBottomCenter oldObjs
										newObj[1].pivot = getBottomCenter newObjs
									)else if(modelFlagList.selection == 2)then
									(
										print("墙面")
										oldObj.pivot = getBackCenter oldObjs
										newObj[1].pivot = getBackCenter newObjs
									)else if(modelFlagList.selection ==3)then
									(
										print("顶")
										oldObj.pivot = getUpperCenter oldObjs
										newObj[1].pivot = getUpperCenter newObjs
									)
									--end物体质点设置
								)
								success = ReplaceObj oldObj newObj[1]
								if(sizeClampCheckBox.checked) then
								(
									undo off(
										--需要传入所有需要参与计算的物体数组
										local newObjExtnets = getExtentsFromObjArray newObjs
										local oldObjExtnets = getExtentsFromObjArray oldObjs
										--需要传入所有需要参与计算的物体数组
										sizeClamp oldObj newObj oldObjExtnets newobjExtnets
										print("转化前新物体的extent:"+ newObjExtnets as string)
										print("转化前旧物体的extent:"+ oldObjExtnets as string)
										print("转化后新物体的extent:"+ (getExtentsFromObjArray newObjs)as string)
									)
								)
							)
							else if(newObj.count>1) then
							(
								undo off(
									print("合并的max文件有多个物体")
									local myGroup = group newObjs
									--物体质点设置
									if(modelFlagList.selection == 1)then
									(
										print("地面")
										oldObj.pivot = getBottomCenter oldObjs
										myGroup.pivot = getBottomCenter newObjs
									)
									else if(modelFlagList.selection == 2)then
									(
										print("墙面")
										oldObj.pivot = getBackCenter oldObjs
										myGroup.pivot = getBackCenter newObjs
									)else if (modelFlagList.selection ==3) then
									(
										print("顶")
										oldObj.pivot = getUpperCenter oldObjs
										myGroup.pivot = getUpperCenter newObjs
									)
								)
								success = ReplaceObj oldObj myGroup

								--end物体质点设置
								undo off(
									if(sizeClampCheckBox.checked) then
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
								)
								--
							)
							if(success!=true) then
							(
								undo off
								(
									delete newObjs
									select selectionBake
								)
								
							)
							else
							(
								undo on(
									delete oldobj
								)
								undo off(
									select newObjs
									actionMan.executeAction 0 "50001"  -- 切换到选择移动工具
								)
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
			fn getMapFileIndex = 
			(
				local mapindex = (nowPage-1)*16+nowPressedButtonIndex
			)
			fn getNowSelectedFilePath = 
			(
				local mapindex = getMapFileIndex()
				local mapPath = getElementFromArry MapFiles mapindex
				print("当前索引下的位图文件")
				print(mapPath)
				nowSelectedFilePath = mapPath
				if(mapPath!=undefined) then
				(
					print("正在通过位图名称寻找max文件")
					local fileN = ((getFilenameFile mapPath)+".max")
					local fileP = SerchWithPathAndFileName selectedSubPath fileN
					fileP
				)
				else
				(
					undefined
				)
					
			)
			--搜索所有预览图像对应的max文件
			fn getAllFilePath = 
			(
				local mapArray =#()
				for mapPath in MapFiles do
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
						if(fileP!=undefined and findItem mapArray fileP==0)then
							append  mapArray fileP
	
					)
				)
				mapArray
			)
			fn setAllPage =
			(
				if(mod BitMaps.count 16 == 0) then
					allPage = ((BitMaps.count/16)as integer)
				else
					allPage = ((BitMaps.count/16)as integer) + 1
			)
			--物体数组是否满足替换条件
			fn ReplaceFlag objs =
			(
				if(selection.count==0) then
				(
					messageBox "请在场景内选择被替换的物体"
					false
				)		
				else if(SelectFlag objs)then
				(
					local selectionFathers = getOuterObjFormSelection objs
					if(selectionFathers.count > 1) then
					(
						messageBox "请选择在同一组内的物体"
						false
					)
					else
					(
						true
					)
				)
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
					if(assetPath != undefined and assetPath != "")then
					(
						trimedPath = TrimStringWithEllipsis assetPath (btnSelectPath.width/9) --依据width/9为长度裁剪字符串
						btnSelectPath.text = trimedPath
						LoadBitmapsFromDirectory (getSelectedSubPath())
						setAllPage()
						updatePageIndex PageIndexButton
						updateButtonIcon imageButtonList
						modelFlag = modelFlagList.items[1]
					)
				)
			)
			--尺寸钳制开关事件
			on sizeClampCheckBox changed theState do
			(
				undo off(
					xyzClamp.enabled = theState
				)
			)
			--
			--资产路径选择
			on btnSelectPath pressed do
			(
				undo off(
					local newAssetPath = getSavePath caption:"选择文件"
					--防止未选择文件返回空值
					if(newAssetPath!=undefined and newAssetPath!="")then
						assetPath = newAssetPath
					else
						print("选择文件为空")
					if(assetPath != undefined) then
					(
						trimedPath = TrimStringWithEllipsis assetPath (btnSelectPath.width/9) --依据width/9为长度裁剪字符串
						btnSelectPath.text = trimedPath
						dirList.selection = 1
						LoadBitmapsFromDirectory (getSelectedSubPath())
						setAllPage()
						nowPage = 1
						updatePageIndex PageIndexButton
						updateButtonIcon imageButtonList
						
					)
					else
					(

						print("assetPath为空")
						assetPath=()
					)
				)
			)
			--end资产路径选择
			on dirList selected index do
			(
				undo off(
					if (assetPath!=undefined and assetPath!="") then
					（
						LoadBitmapsFromDirectory (getSelectedSubPath())
						setAllPage()
						nowPage = 1
						updatePageIndex PageIndexButton
						updateButtonIcon imageButtonList
						updatePreviewImageButton previewImage 0
						nowPressedButtonIndex = 0
					）
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
					flag = ReplaceFlag selection
				)
				if(flag == true)then
				(
					--得到图片对应的max文件
					undo off(
						local fileP = getNowSelectedFilePath()
					)
					if(fileP != undefined) then
					(
						ReplaceNode selection fileP
					)
					else
					(
						undo off(
							print("文件未找到")
							messageBox"资产模型不存在或未选择资产模型"
						)
					)
				)
			)
			--end替换方法
			--裂变窗口
			on btnOpenFission changed state do
			(
				local currentFilePath = maxFilePath + maxFileName
				if(currentFilePath!="")then
				(
					if(renamed==false)then
					(
						RenameAllDuplicatesObjName()
						renamed=true
					)
					if state == on then
					(
						local dl = theNewFloater.pos[1];
						local dr = systemTools.GetScreenWidth() - theNewFloater.pos[1]-theNewFloater.size[1]
						local fissionWidth = 300
						local fissionHeight = 400
						--如果右边有空间创建在右边
						if(dr>fissionWidth)then
						(
							CreateDialog fission fissionWidth fissionHeight pos:[theNewFloater.pos[1] + theNewFloater.size[1]+5,theNewFloater.pos[2]] style:#(#style_titlebar,#style_sysmenu,#style_minimizebox,#style_maximizebox) parent:pengpai1.hwnd
						)
						--如果左边有空间创建在左边
						else if(dl>fissionWidth)then
						(
							CreateDialog fission fissionWidth fissionHeight pos:[theNewFloater.pos[1] - fissionWidth-1,theNewFloater.pos[2]] style:#(#style_titlebar,#style_sysmenu,#style_minimizebox,#style_maximizebox) parent:pengpai1.hwnd
						)
						--否则在中间创建
						else
						(
							CreateDialog fission fissionWidth fissionHeight style:#(#style_titlebar,#style_sysmenu,#style_minimizebox,#style_maximizebox) parent:pengpai1.hwnd
						)
					)
					else
						DestroyDialog fission
				)
				else
				(
					messageBox"请保存文件"
					btnOpenFission.state = false
				)
					
			)
			--end裂变窗口
			--图片按钮方法
			on bitmap1 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 1
					nowPressedButtonIndex = 1
				)
			)
	
			on bitmap2 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 2
					nowPressedButtonIndex = 2
				)
			)
	
			on bitmap3 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 3
					nowPressedButtonIndex = 3
				)
			)
	
			on bitmap4 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 4
					nowPressedButtonIndex = 4
				)
			)
	
			on bitmap5 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 5
					nowPressedButtonIndex = 5
				)
			)
	
			on bitmap6 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 6
					nowPressedButtonIndex = 6
				)
			)
	
			on bitmap7 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 7
					nowPressedButtonIndex = 7
				)
			)
	
			on bitmap8 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 8
					nowPressedButtonIndex = 8
				)
			)
			on bitmap9 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 9
					nowPressedButtonIndex = 9
				)
			)
	
			on bitmap10 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 10
					nowPressedButtonIndex = 10
				)
			)
	
			on bitmap11 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 11
					nowPressedButtonIndex = 11
				)
			)
	
			on bitmap12 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 12
					nowPressedButtonIndex = 12
				)
			)
	
			on bitmap13 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 13
					nowPressedButtonIndex = 13
				)
			)
	
			on bitmap14 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 14
					nowPressedButtonIndex = 14
				)
			)
	
			on bitmap15 pressed do
			(
				undo off(
					updatePreviewImageButton previewImage 15
					nowPressedButtonIndex = 15
				)
			)
			on bitmap16 pressed do 
			( 
				undo off(
					updatePreviewImageButton previewImage 16
					nowPressedButtonIndex = 16
				)
			)
		)
	-------------------------------------------------endUI类----------------------------------------------
		--实例化UI界面
		theNewFloater = newRolloutFloater "Grinning" 420 610--rollout宽度为RolloutFloater的宽度-10
		PengPaiInstance = pengpai1
		addRollout PengPaiInstance theNewFloater
	)
	
	--createDialog mainRollot 400 600
	