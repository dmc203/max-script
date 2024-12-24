--0000-2024.12.6 15.49
--try(destroyDialog theNewFloater) catch()
(
---------------------------------------------------����------------------------------------------------
	
	global bitMaps = #() --Class:BitMap
	global mapFile = #() --Class:stringName
	persistent global assetPath
	global subAssetFolders
	global selectedSubPath
	global nowPage = 1
	global allPage = 0
	global nowButtonIndex = 0
	global imageButtonList =#()
	if(assetPath == undefined) then assetPath = ()
-------------------------------------------------ȫ�ֱ���----------------------------------------------
---------------------------------------------------����------------------------------------------------
	--*
	--
	fn vectorDivide v1 v2 =
	(
		--����Ƿ���ͼ���зǷ��������类���
		if (v2.x == 0 or v2.y == 0 or v2.z == 0) then
		(
			throw "Division by zero in one of the vector components."
		)
		else
		(
			[v1.x / v2.x, v1.y / v2.y, v1.z / v2.z]
		)
	)
	--
	--����Transform��Ϣ
	fn SetTransformInfo obj pos ro sc =
	(
		if obj != undefined then 
		(
			-- ����λ��
			obj.position = pos
			
			-- ������ת����Ҫת��Ϊ��Ԫ���򱣳�Ϊŷ���ǣ�
			obj.rotation = ro
			
			-- ��������
			obj.scale = sc
		)
	)
	fn SetTransformInfoPos obj pos =
	(
		if obj != undefined then 
		(
			-- ����λ��
			obj.position = pos
		)
	)
	fn SetTransformInfoRotation obj ro =
	(
		if obj != undefined then 
		(
			-- ������ת
			obj.rotation = ro
		)
	)
	fn SetTransformInfoScale obj newScale =
	(
		if obj != undefined then 
		(
			-- ����λ����
			obj.scale = sc
		)
	)
	--end����Transform��Ϣ
	--*
	--���ͼ����
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
	--end���ͼ����
	--�滻����
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
				messageBox("δ�ҵ�����ĸ��ڵ������Ƿ�ѡ������")
				false
			)
			else
			(
				messageBox("��֧�������볢��ת��Ϊ�ɱ༭�����")
				false
			)
		)
	)
	--end�滻����

	--��������ѡȡԪ��
	fn getElementFromArry arry index =
	(
		if(index<=arry.count and index>0) then
			arry[index]
		else 
			undefined
	)
	--end��������ѡȡԪ��
	--*
	--��ȡѡ������������ڵ�
	fn recursiveGetParent currentObj parents = -- �ݹ��ȡ��������

	(
		if currentObj != undefined do (
			local parentObj = currentObj.parent  -- ��ȡ��ǰ����ĸ���
			if parentObj != undefined then (
				if findItem parents parentObj == 0 then
					append parents parentObj  -- ���������ӵ��б���
				recursiveGetParent parentObj parents  -- �ݹ�����Ի�ȡ��һ���ĸ���
			)
			else if parentObj == undefined then
			(
				if findItem parents currentObj == 0 then
					append parents currentObj  --���������ӵ��б���
			)
		)
		
	)
	fn getAllParents objs =
	(
		local parents = #()  -- ����һ�����������洢��������
		for obj in objs do
		(
			recursiveGetParent obj parents  -- ��ʼ�ݹ�Ӵ���Ķ���ʼ
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
	
	--����ѡ�����еõ����������
	fn getOuterObjFormSelection objs =
	(
		objs = objs as Array
		local fathers = #()
		if(objs.count>1)then
		(
			for obj in objs do
			(
				if(obj.parent!=undefined)then--���obj�ĸ���û�ж�����ôobj����������
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
	--��ѡ������
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
	--��·�����ļ��������ļ�
	fn getNewPathFromSelectPathAndFileName asset  maxName = 
	(
		local file = ()
		file = getFiles (asset +"\\"+ maxName) recurse:false
		--append newFilePath files
		--print("NewPath:"+file as string)
		file[1]
	)
	--end��·�����ļ��������ļ�
	--*
	--��·������max�ļ����������������б�
	fn MergeMaxFileAndReturnObjects filePath =
	(
		-- ����ļ��Ƿ����
		if doesFileExist filePath then 
		(
			-- ��ȡ��ǰ�����еĶ�������
			local initialObjectCount = objects.count
			
			local oldObj = (geometry as Array)
			-- �ϲ��µ� .max �ļ�
			mergeMAXFile filePath
			
			-- ����һ���������洢�ºϲ��Ķ���
			local newObjects = #()
			
			-- �������ж����ҵ���������Щ
			for obj in geometry do
			(
				if (findItem oldObj obj == 0 )then 
					append newObjects obj
			)
			
			--print ("�ϲ��ļ�:" + filePath)
			newObjects  -- ���غϲ���Ķ����б�
		)
		else
		(
			
			undefined  -- ����δ�����Ա�ʾʧ��
			messageBox("�ļ�������: " + filePath)
		)
	)
	--end��·������max�ļ������������б�
	--*
	--����·���е�����λͼ�ļ�
	fn LoadBitmapsFromDirectory directoryPath =
	(
		undo off(
			bitMaps = #()
			-- ���Ŀ¼�Ƿ����
			if(directoryPath!=undefined)then
			if doesFileExist directoryPath then 
			(
				-- ��ȡĿ¼�е������ļ���
				local files = getFiles (directoryPath + "\\*.*")
				
				-- ֧�ֵ�λͼ��չ���б�
				local bitmapExtensions = #(".jpg", ".jpeg", ".png", ".bmp", ".tga", ".tiff")
				if (files.count > 0) then
				(
					-- �洢�Ѽ��ص�λͼ����
					--local loadedBitmaps = #()
					--local loadedCount = 0
					
					--progressStart "����Ԥ��ͼ�У�"   
					
					-- ����ÿ���ļ�
					for file in files do
					(
						-- ��ȡ�ļ���չ����ת��ΪСд�Ա�ƥ��
						local fileExtension = toLower (getFilenameType file)
						
						-- ������չ���Ƿ���֧���б���
						if findItem bitmapExtensions fileExtension > 0 then 
						(
							local map1 = bitmap 256 256 filename:file
							local map2 = openBitMap file
							
							copy map2 map1
							append mapFile file 
							append bitMaps map1          
							free map2     
							
							--�ͷż��ص�ԭͼ��
							--loadedCount += 1             -- �����Ѽ��ؼ���
							--progressUpdate ((loadedCount / files.count) * 100) -- ���½�����
						)
					)
				)
			)
			else 
			(
				messageBox("·��������:" + directoryPath)
			)
		)
	)
	--end����·���е�����λͼ�ļ�
	--*
	--������������������б�
	fn GetCamerasInScene = 
	(
		local cameraList = #()  -- ��ʼ��һ�����������洢�������
		
		-- ���������е����ж���
		for obj in objects do
		(
			-- �������Ƿ�Ϊ������ͣ�����Ŀ������������
			if superclassof obj == Camera then
			(
				append cameraList obj  -- ������������ӵ��б���
			)
		)
		return cameraList  -- ���ذ�������������б�
	)
	--end����������������б�
	--*
	--�ӻ�����Ⱦ
	fn RenderFromCurrentCamera = 
	(
		-- ��ȡ��ǰ���ͼ�Ķ���
		local activeView = viewport.getCamera()
		
		if activeView != undefined and superclassof activeView == Camera then
		(
			-- ������Ⱦ����Ϊ��ǰ���
			render camera:activeView
			
			--print ("�ӻ�����Ⱦ " + activeView.name)
		)
		else
		(
			--print "û�л���������"
		)
	)
	--end�ӻ�����Ⱦ
	--*
	--�ü��ַ���
	fn TrimStringWithEllipsis inputStr maxLength =
	(
		-- ����������
		if maxLength <= 0 do
		(
			""
		)
		if inputStr!=undefined then
		(
			-- ��������ַ����ĳ���С�ڻ������󳤶ȣ��򷵻�ԭ�ַ���
			if (inputStr.count <= maxLength) then
			(
				return inputStr
			)
			-- �ü��ַ���������ʡ�Ժ�
			local trimmedStr = (substring inputStr 1 (maxLength - 3))+"..." -- ����3���ַ�����ʡ�Ժ�
			trimmedStr
		)
		else 
		(
			undefined
		)
			

	)
	--end�ü��ַ���
	--*
	--����button��icon
	fn updateButtonIcon imageButtonList =
	(
		undo off(
			if(imageButtonList!=undefined) do
			--Ϊbutton����λͼ
				for i = 1 to 16 do
				(
					local mapIndex = (nowPage-1)*16+i
					--local mapIndex=1
					if(bitMaps.count>=mapIndex) then
					(
						--print (classof (bitMaps[mapIndex]))
						--imageButtonList[i].images = #(bitMaps[mapIndex],undefined, 1,1,1,1,1)
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
					(						local blackimage = bitmap 64 64 color:black
						imageButtonList[i].images = #(blackimage, undefined, 1,1,1,1,1 )
					)
				)
		)
	)
	--end����button��icon
	--*
	--ҳ����������
	fn updatePageIndex pageIndexButton =
	(
		pageIndexButton.text  = (nowPage as string)+"/"+(allPage as string)
	)
	--endҳ����������
	--*
	--ҳ��ͼ�����
	fn updateSelectedModelButtonImage bitmapImage button i=
	(
		--print(classof button)
		
		local mapIndex = (nowPage-1)*16+i
		if(mapIndex<=bitMaps.count) then
		(
			bitmapImage.images = #(bitMaps[mapIndex], undefined, 1,1,1,1,1 )
		)
		
	)
	--endҳ��ͼ�����
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
		-- ȷ�������·�����ڲ���һ���ļ���
		if doesFileExist folderPath and (getDirectories (folderPath + "\\*")) != undefined then
		(
			local folderList = getDirectories (folderPath + "\\*") -- ��ȡ�������ļ���
			local folderNames = for folder in folderList collect (getFilenameFile (trimRight folder "\\"))
			return folderNames
		)
		else
		(
			format "�ṩ��·����Ч����һ���ļ���: %\n" folderPath
			return #() -- ���ؿ�����
		)
	)
	--ѡ�������б��Ƿ�Ϊ�����鲢ѡ����������
	fn isGroupValid objs =
	(
		outerNode = getOuterObjFormSelection objs
		getOuterObjFormSelection objs
		if(outerNode.count>1)then
			false
		else
		(
			--if(isGroupHead outerNode[1]==true)then
			--(
			--	setGroupOpen outerNode[1] false
			--)
			true
		)
	)
	--�滻��ǩ���ѡ�������б��Ƿ������滻����
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
					messageBox("ѡ�з�ʽ�Ƿ�")
					false
				)
			)
			else
				true
		)
		else
			messageBox("ReplaceFlag���������δ����")
	)
	--
------------------------------------------------------------------end����-----------------------------------------------------
-------------------------------------------------------------------չ����-------------------------------------------------------
	rollout pengpai1 "ģ���滻"
	(
		button btnSelectPath "ѡ���ʲ�·������ģ��" width:380 height:20 align:#center
		dropdownlist dirList "����Ŀ¼" width:380 height:20 align:#center
		button btnReplaceModel "�滻" pos:[40,115] width:100 height:30 align:#cente
		button btnGetFileFromAsset "��·��ѡȡģ�Ͳ��滻" pos:[40,80] width:100 height:30 align:#cente
		button bitmapImage pos:[300,78] width:80 height:80 bitmap:(bitmap 128 128 color:black) pixelAspect:2
		--label selectedModel "���滻ģ��" pos:[80,115] style_sunkenedge:true width:80 height:30 align:#center
		checkbox sizeClampCheckBox "�ߴ�ǯ��" pos:[140,125]
		dropdownlist xyzClamp pos:[210,122] width:40 height:20 items:#("x","y","z") visible:false
		label tag "�滻ģ�ͣ�" pos:[235,100]
		--label assetModel "�ʲ���ģ��" pos:[240,115] style_sunkenedge:true width:80 height:30 align:#center
		GroupBox bitmapGroup "ͼƬԤ��" pos:[10,160] width:380 height:380
		button bitmap1 "���ļ�" pos:[25,180] width:80 height:80
		button bitmap2 "���ļ�" pos:[115,180] width:80 height:80
		button bitmap3 "���ļ�" pos:[205,180] width:80 height:80
		button bitmap4 "���ļ�" pos:[295,180] width:80 height:80

		button bitmap5 "���ļ�" pos:[25,270] width:80 height:80
		button bitmap6 "���ļ�" pos:[115,270] width:80 height:80
		button bitmap7 "���ļ�" pos:[205,270] width:80 height:80
		button bitmap8 "���ļ�" pos:[295,270] width:80 height:80

		button bitmap9 "���ļ�" pos:[25,360] width:80 height:80
		button bitmap10 "���ļ�" pos:[115,360] width:80 height:80
		button bitmap11 "���ļ�" pos:[205,360] width:80 height:80
		button bitmap12 "���ļ�" pos:[295,360] width:80 height:80

		button bitmap13 "���ļ�" pos:[25,450] width:80 height:80
		button bitmap14 "���ļ�" pos:[115,450] width:80 height:80
		button bitmap15 "���ļ�" pos:[205,450] width:80 height:80
		button bitmap16 "���ļ�" pos:[295,450] width:80 height:80
		
		button lastPage "<--��һҳ" pos:[60,545] width:100 height:30
		button nextPage "��һҳ-->" pos:[240,545] width:100 height:30
		button PageIndexButton "1/1" pos:[170,545] width:60 height:30
		--
		-- �ֶ�ʵ�� max ����
		fn myMax a b = 
		(
			if a > b then a else b
		)

		-- �ֶ�ʵ�� min ����
		fn myMin a b = 
		(
			if a < b then a else b
		)
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
			if ClampAxis=="x" then
				coefficient = coefficientVector.x
			else if ClampAxis=="y" then
				coefficient = coefficientVector.y
			else if ClampAxis=="z" then
				coefficient = coefficientVector.z
			else
				messageBox("δ֪����δ�ҵ���")
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
		fn ReplaceNode fileP = 
		(
			selectionBake = selection as Array
			if(selection.count==0) then
				messageBox "���ڳ�����ѡ���滻������"
			else if(ReplaceFlag selection)then
			(
				--print("�ҵ�max�ļ�")
				local selectionFathers = getOuterObjFormSelection selection
				--print("�ҵ������ڵ�"+selectionFathers as string)
				if(selectionFathers.count > 1) then
				(
					messageBox "��ѡ����ͬһ���ڵ�����"
				)
				else
				(
					local oldObj = selectionFathers[1]
					local oldObjs = selection
					--�ر��������жϵ��û�
					if(isOpenGroupHead oldObj == true)then
					(
						setGroupOpen oldObj false
						select oldObj
						oldObjs = selection
					)
					
					local classFlag = true
					for obj in selection while (classFlag == true) do
					(
						classFlag = (classCheck obj)and classFlag
					)
					--print(classFlag)
					if(classFlag) then --�����ж�
					(
						local newObjs = (MergeMaxFileAndReturnObjects fileP)
						if(newObjs!=undefined )then--���û�ѡ��ģ��ʱ
							if(newObjs.count!=0)then--���û�û��ѡ������ʱ
							(
								local success=()
								local newObj = getOuterFatherNode newObjs --�ж������ڵ�����
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
										--��Ҫ����������Ҫ����������������
										local newObjExtnets = getExtentsFromObjArray newObjs
										print("newObjExtnets"+ newObjExtnets as string)
										local oldObjExtnets = getExtentsFromObjArray oldObjs
										print("oldObjExtnets"+ oldObjExtnets as string)
										--��Ҫ����������Ҫ����������������
										sizeClamp oldObj newObj oldObjExtnets newobjExtnets
										print("ת��ǰ�������extent:"+ newObjExtnets as string)
										print("ת��ǰ�������extent:"+ oldObjExtnets as string)
										print("ת�����������extent:"+ (getExtentsFromObjArray newObjs)as string)
									)
									delete oldObj
								)
								else if(newObj.count>1)then
								(
									print("2")
									local myGroup = group newObjs
									success = ReplaceObj oldObj myGroup
									
									if(sizeClampCheckBox.checked)then
									(
										--��Ҫ����������Ҫ����������������
										local newObjExtnets = getExtentsFromObjArray newObjs
										print("newObjExtnets"+ newObjExtnets as string)
										local oldObjExtnets = getExtentsFromObjArray oldObjs
										print("oldObjExtnets"+ oldObjExtnets as string)
										--��Ҫ������������
										sizeClamp oldObj myGroup oldObjExtnets newobjExtnets
										print("ת��ǰ�������extent:"+ newObjExtnets as string)
										print("ת��ǰ�������extent:"+ oldObjExtnets as string)
										print("ת�����������extent:"+ (getExtentsFromObjArray newObjs)as string)
									)
									--
									delete oldObj
								)
								if(success!=true) then
								(
									--print("�滻ʧ��")
									--print(oldObj)
									--print(tempArry)
									delete newObjs
									select selectionBake
								)
								else
								(
									select newObjs
									actionMan.executeAction 0 "50001"  -- Tools: ѡ���ƶ�
								)
							)
					)
					else
					(	
						local unsupportList = #()
						for obj in selection do
						(
							if(classCheck obj == false) then
								append unsupportList (classof obj)
						)
						messageBox ("�����б��滻��������ڲ�֧������,��֧�ֵ�����Ϊ��" + unsupportList as string+"\n��������볢��ת��Ϊ�ɱ༭����")
					)
				)
			)
			
		)
		-- rollout ���¼�
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
				trimedPath = TrimStringWithEllipsis assetPath (btnSelectPath.width/9) --����width/9Ϊ���Ȳü��ַ���
				btnSelectPath.text = trimedPath
				LoadBitmapsFromDirectory (getSelectedSubPath ())
				allPage = ((bitMaps.count/16)as integer)+1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)
		)
		--�ߴ�ǯ�ƿ����¼�
		on sizeClampCheckBox changed theState do
		(
			xyzClamp.visible = theState
		)
		--
		--�ʲ�·��ѡ��
		on btnSelectPath pressed do
		(
			assetPath = getSavePath caption:"ѡ���ļ�"
			if(assetPath != undefined) then
			(
				trimedPath = TrimStringWithEllipsis assetPath (btnSelectPath.width/9) --����width/9Ϊ���Ȳü��ַ���
				btnSelectPath.text = trimedPath
				--print("Load")
				LoadBitmapsFromDirectory (getSelectedSubPath())
				allPage = ((bitMaps.count/16)as integer)+1
				nowPage = 1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)
		)
		--end�ʲ�·��ѡ��
		on dirList selected index do
		(
			LoadBitmapsFromDirectory (getSelectedSubPath())
			allPage = ((bitMaps.count/16)as integer)+1
			nowPage = 1
			updatePageIndex PageIndexButton
			updateButtonIcon imageButtonList
		)
		--ҳ������߼�
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
			if((nowPage-1) > 0) do
			(
				nowPage-=1
				updatePageIndex PageIndexButton
				updateButtonIcon imageButtonList
			)
		)
		--endҳ������߼�
		
		--ģ���滻����
		on btnReplaceModel pressed do
		(
			undo off(
				local mapindex = (nowPage-1)*16+nowButtonIndex
				--print(mapindex)
				local mapPath = getElementFromArry mapFile mapindex--�ж�����λ�õ�ͼ��·���Ƿ����
				--print (mapFile.count)
				--print("�滻��ť�����mapPath��"+(mapPath as string)+"  nowButtonIndex:"+(nowButtonIndex as string))
				if(mapPath!=undefined) then
				(
					--print("mapPath���ڿ���Ѱ�Ҷ�Ӧģ��")
					local fileN = ((getFilenameFile mapPath)+".max")
					--print(fileN as string)
					
					local fileP = getNewPathFromSelectPathAndFileName selectedSubPath fileN
					--print("fileP:" + fileP as string)
					if(fileP!=undefined) then
					--print(fileP as string)
						ReplaceNode fileP
					else
						messageBox "δ�ҵ�ͼƬ����Ӧ��ģ��"
				)
			)
		)
		--end�滻����
		--��·��ѡȡģ��
		on btnGetFileFromAsset pressed do 
		(
			if(assetPath!= undefined ) then 
				local fileP = getOpenFileName caption:"ѡ���滻ģ��" types:"ȫ���ļ�(*.*)|*.*|max�ļ�(.max)|*.max" filename:assetPath
			else
				local fileP = getOpenFileName caption:"ѡ���滻ģ��" types:"ȫ���ļ�(*.*)|*.*|max�ļ�(.max)|*.max"
			--print(assetPath)
			if(fileP!=undefined) then
				ReplaceNode fileP
		)
		--end��·��ѡȡģ��
		--ͼƬ��ť����
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
		--endͼƬ��ť����
	--*
	)
-------------------------------------------------------------------endUI-------------------------------------------------------
	theNewFloater = newRolloutFloater "Grinning" 410 600--rollout����ΪRolloutFloater�Ŀ���-10
	addRollout pengpai1 theNewFloater 
)

--createDialog mainRollot 400 600