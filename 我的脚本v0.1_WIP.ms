--try(destroyDialog theNewFloater) catch()
(
---------------------------------------------------变量------------------------------------------------
	
	global bitMaps = #() --Class:BitMap
	global mapFile = #() --Class:stringName
	persistent global assetPath
	global nowPage = 1
	global allPage = 0
	global nowButtonIndex = 0
	global imageButtonList =#()
	if(assetPath == undefined) then assetPath = ()
-------------------------------------------------全局变量----------------------------------------------
---------------------------------------------------方法------------------------------------------------
	--*
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
	--替换物体
	fn ReplaceObj oldObj newObj = 
	(
		if(newObj!=undefined)then
		(
			if (classOf oldObj == PolyMeshObject or 
				classOf oldObj== Editable_mesh or 
				classOf oldObj == Editable_Poly or
				classOf oldObj == Dummy or
				classOf oldObj == Editable_Patch or
				classOf oldObj == NURBS_曲面) then
			(
				newObj.position = oldObj.position
				-- 设置旋转（需要转换为四元数或保持为欧拉角）
				newObj.rotation =oldObj.rotation
				-- 设置缩放
				newObj.scale = oldObj.scale
				print (newObj.transform as string + oldObj.transform as string )
				--newObj.transform = oldObj.transform
				delete oldObj
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
	/*
	--*
	--替换并设置Transform信息
	fn ReplaceAndSetTransform newOjb oldObj = 
	(
		local tempPos = oldObj.position
		local tempRo = oldObj.rotation
		local tempSc = oldObj.scale
		ReplaceObj newObj oldObj	--oldObj被被删除
		SetTransformInfo obj tempPostempRo tempSc
	)
	fn ReplaceAndSetPos newOjb oldObj = 
	(
		local tempPos = oldObj.position
		ReplaceObj newObj oldObj	--oldObj被被删除
		SetTransformInfoPos obj tempPos
	)
	fn ReplaceAndSetRotation newOjb oldObj = 
	(
		local tempRo = oldObj.rotation
		ReplaceObj newObj oldObj	--oldObj被被删除
		SetTransformInfoRoation obj tempRo
	)
	fn ReplaceAndSetScale newOjb oldObj = 
	(
		local tempSc = oldObj.scale
		ReplaceObj newObj oldObj	--oldObj被被删除
		SetTransformInfoScale obj tempSc
	)
	--end替换并设置Transform信息
	--*
	*/
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
	--从选择的组中的到最外层父节点
	fn getOuterFatherNode objs =
	(
		local f =#()
		for o in objs do
		(
			if(o.parent==undefined) then
			(
				append f o
				--print("从选择的组中的到最外层父节点"+((classof o) as string))
			)	
		)
		f
	)
	--end从选择的组中的到最外层父节点
	--*
	--类型检查器
	fn classCheck obj =
	(
		if (classOf obj == PolyMeshObject or 
		classOf obj == Editable_mesh or 
		classOf obj == Editable_Poly or
		classOf obj == Dummy or
		classOf obj == Editable_Patch or
		classOf obj == NURBS_曲面) then
		(
			true
		)
		else 
			false
	)
	--end类型检查器
	--*
	--从路径和文件名搜索文件
	fn getNewPathFromSelectPathAndFileName assetPath  maxName = 
	(
		local file = ()
		file = getFiles (assetPath +"\\"+  maxName) recurse:false
		--append newFilePath files
		--print("NewPath:"+file as string)
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
			mergeMAXFile filePath
			
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
					--progressEnd()                  -- 最后结束进度条显示
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
						imageButtonList[i].iconSize = [80,80]
						if(bitMaps[mapIndex]!=undefined) then
							imageButtonList[i].images = #(bitMaps[mapIndex], undefined, 1,1,1,1,1 )
						else
						(
							local blackimage = bitmap 64 64 color:black
							imageButtonList[i].images = #(blackimage, undefined, 1,1,1,1,1 )
						)
						--print(bitMaps[mapIndex])
					)
					else
					(
						imageButtonList[i].iconSize = [80,80]
						local blackimage = bitmap 64 64 color:black
						imageButtonList[i].images = #(blackimage, undefined, 1,1,1,1,1 )
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
			bitmapImage.images = #(bitMaps[mapIndex], undefined, 1,1,1,1,1 )
		)
		
	)
	--end页面图像更新
	--*

----------------------------------------------------------------end方法-----------------------------------------------------
-------------------------------------------------------------------展卷栏-------------------------------------------------------
	rollout pengpai1 "模型替换"
	(
		button btnSelectPath "选择资产路径加载模型" width:380 height:20 align:#center
		button btnReplaceModel "替换模型" pos:[40,65] width:100 height:30 align:#cente
		button btnGetFileFromAsset "从路径选取并替换模型" pos:[40,30] width:100 height:30 align:#cente
		button bitmapImage  pos:[260,28] width:80 height:80 bitmap:(bitmap 128 128 color:black) pixelAspect:2
		--label selectedModel "被替换模型" pos:[80,65] style_sunkenedge:true width:80 height:30 align:#center
		label tag "已选中模型：" pos:[185,60]
		--label assetModel "资产库模型" pos:[240,65] style_sunkenedge:true width:80 height:30 align:#center
		GroupBox bitmapGroup "图片预览" pos:[10,110] width:380 height:380 
		button bitmap1 "无文件" pos:[25 ,130] width:80 height:80
		button bitmap2 "无文件" pos:[115,130] width:80 height:80
		button bitmap3 "无文件" pos:[205,130] width:80 height:80
		button bitmap4 "无文件" pos:[295,130] width:80 height:80
		
		button bitmap5 "无文件" pos:[25 ,220] width:80 height:80
		button bitmap6 "无文件" pos:[115,220] width:80 height:80
		button bitmap7 "无文件" pos:[205,220] width:80 height:80 
		button bitmap8 "无文件" pos:[295,220] width:80 height:80 
		
		button bitmap9  "无文件" pos:[25 ,310] width:80 height:80
		button bitmap10 "无文件" pos:[115,310] width:80 height:80
		button bitmap11 "无文件" pos:[205,310] width:80 height:80
		button bitmap12 "无文件" pos:[295,310] width:80 height:80
		
		button bitmap13 "无文件" pos:[25 ,400] width:80 height:80 
		button bitmap14 "无文件" pos:[115,400] width:80 height:80
		button bitmap15 "无文件" pos:[205,400] width:80 height:80
		button bitmap16 "无文件" pos:[295,400] width:80 height:80
		
		button lastPage "<--上一页" pos:[60,520] width:100 height:30
		button nextPage "下一页-->" pos:[240,520] width:100 height:30
		button PageIndexButton "1/1" pos:[170,520] width:60 height:30
		--progressbar progress_bar_item pos:[20,500] height:20 width:360 color:(color 255 100 100) orient:#horizontal
		
		fn ReplaceNode fileP = 
		(
			if(selection.count==0) then
				messageBox "请在场景内选择被替换的物体"
			else
				(
					if(fileP != undefined) then 
					(
						--print("找到max文件")
						local selectionFathers = getOuterFatherNode selection
						--print("找到最外层节点"+selectionFathers as string)
						
					)
					if (selectionFathers.count > 1) then
					(
						messageBox "请选择在同一组内的物体"
					)
					else
					(
						local oldObj = selectionFathers[1]
						local classFlag=true
						for obj in selection while (classFlag == true) do
						(
							classFlag = (classCheck obj)and classFlag
							
						)
						--print(classFlag)
						if(classFlag) then --类型判断
						(
							local newObjs = (MergeMaxFileAndReturnObjects fileP)
							if(newObjs!=undefined)then
							(
								local success=()
								local tempArry = getOuterFatherNode newObjs--判断合并max文件是否为整组
								print ("tempArry"+tempArry as string)
								if (tempArry.count>1) then
								(
									local myGroup = group newObjs
									local newObj = tempArry[1]
									success = ReplaceObj oldObj myGroup
								)
								else
								(
									local newObj = tempArry[1]
									success = ReplaceObj oldObj newObjs[1]
									
								)
								if(success!=true) then
								(
									delete newObjs
								)
								else
									(
										select newObjs
										actionMan.executeAction 0 "50001"  -- Tools: 选择并移动
									)
							)
						)
						else
						(	local unsupportList = #()
							for obj in selection do
							(
								if(classCheck obj == false) then
									append unsupportList (classof obj)
							)
							messageBox ("场景中被替换的物体存在不支持类型,不支持的类型为：" + unsupportList as string+"\n如果可以请尝试转化为可编辑网格")
						)
					)
					
				)
		)
		-- rollout 打开事件
		on pengpai1 open do
		(
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
				LoadBitmapsFromDirectory assetPath
				allPage = ((bitMaps.count/16)as integer)+1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)

		)
		--资产路径选择
		on btnSelectPath pressed do
		(
			filePath = getSavePath caption:"选择文件"
			if(filePath !=undefined) then
			(
				trimedPath = TrimStringWithEllipsis filePath (btnSelectPath.width/9) --依据width/9为长度裁剪字符串
				btnSelectPath.text = trimedPath
				assetPath = filePath
				LoadBitmapsFromDirectory assetPath
				allPage = ((bitMaps.count/16)as integer)+1
				nowPage = 1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)
		)
		--end资产路径选择
		--页面更新逻辑
		on nextPage pressed do
		(
			
			if((nowPage+1) <= allPage) do
			(
				nowPage+=1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
				
			)
			--print (allPage)
		)
		on lastPage pressed do
		(
			if((nowPage-1) > 0) do
			(
				nowPage-=1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)
		)
		--end页面更新逻辑
		
		--模型替换方法
		on btnReplaceModel pressed do
		(
			local mapindex = (nowPage-1)*16+nowButtonIndex
			print(mapindex)
			local mapPath = getElementFromArry mapFile mapindex--判断索引位置的图像路径是否存在
			print (mapFile.count)
			--print("替换按钮被点击mapPath："+(mapPath as string)+"  nowButtonIndex:"+(nowButtonIndex as string))
			if(mapPath!=undefined) then
			(
				print("mapPath存在可以寻找对应模型")
				local fileN = ((getFilenameFile mapPath)+".max")
				--print(fileN as string)
				local fileP = getNewPathFromSelectPathAndFileName assetPath fileN
				if(fileP!=undefined) then
				--print(fileP as string)
					ReplaceNode fileP
				else
					messageBox "未找到图片所对应的模型"
			)
		)
		--end替换方法
		--从路径选取模型
		on btnGetFileFromAsset pressed do 
		(
			if(assetPath!= undefined ) then 
				local fileP = getOpenFileName caption:"选择替换模型" types:"全部文件(*.*)|*.*|max文件(.max)|*.max" filename:assetPath
			else
				local fileP = getOpenFileName caption:"选择替换模型" types:"全部文件(*.*)|*.*|max文件(.max)|*.max"
			--print(assetPath)
			if(fileP!=undefined) then
				ReplaceNode fileP
		)
		--end从路径选取模型
		--图片按钮方法
		on bitmap1 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap1 1
				nowButtonIndex = 1
			)
		)

		on bitmap2 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap2 2
				nowButtonIndex = 2
			)
		)

		on bitmap3 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap3 3
				nowButtonIndex = 3
			)
		)

		on bitmap4 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap4 4
				nowButtonIndex = 4
			)
		)

		on bitmap5 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap5 5
				nowButtonIndex = 5
			)
		)

		on bitmap6 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap6 6
				nowButtonIndex = 6
			)
		)

		on bitmap7 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap7 7
				nowButtonIndex = 7
			)
		)

		on bitmap8 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap8 8
				nowButtonIndex = 8
			)
		)

		on bitmap9 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap9 9
				nowButtonIndex = 9
			)
		)

		on bitmap10 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap10 10
				nowButtonIndex = 10
			)
		)

		on bitmap11 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap11 11
				nowButtonIndex = 11
			)
		)

		on bitmap12 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap12 12
				nowButtonIndex = 12
			)
		)

		on bitmap13 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap13 13
				nowButtonIndex = 13
			)
		)

		on bitmap14 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap14 14
				nowButtonIndex = 14
			)
		)

		on bitmap15 pressed do
		(
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap15 15
				nowButtonIndex = 16
			)
		)
		on bitmap16 pressed do 
		( 
			undo off(
				updateSelectedModelButtonImage bitmapImage bitmap16 16
				nowButtonIndex = 16
			)
		)
		--end图片按钮方法
	--*
	)
	--rollout pengpai2 "相机管理"
	--(
	--	listbox camLlist
	--)
-------------------------------------------------------------------endUI-------------------------------------------------------
theNewFloater = newRolloutFloater "Grinning" 410 600--rollout宽度为RolloutFloater的宽度-10
addRollout pengpai1 theNewFloater
)

--createDialog mainRollot 400 600
