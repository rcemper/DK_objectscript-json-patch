Class Grongier.JSON.Utils
{

ClassMethod Patch(pResourceObj As %Library.DynamicObject, tPatchObj As %Library.DynamicObject, Output pUpdated As %Boolean) As %Status
{
	Set tSC = $$$OK
	
	Set pUpdated = 0
	
	Try {
		
		Set tPatchObjIter = tPatchObj.%GetIterator()
		While tPatchObjIter.%GetNext(.tKey, .tVal) {
			do {
				Set tOp = tVal.op
				Set tPath = tVal.path
				Set tFrom = tVal.from
				Set tValue = tVal.value
				If tValue'="" {
					Set tValueTypeOf = tVal.%GetTypeOf("value")
				} Else {
					Set tValueTypeOf = ""
				}
				Set tErrPrefix = "Patch '"_tOp_"' operation "
				
				If tOp="" {
					Set tErr = "Patch operation op not specified"
					
				} ElseIf (",add,remove,replace,copy,move,test," '[ (","_tOp_",")) {
					Set tErr = "Patch operation invalid op '"_tOp_"' specified"
					
				} ElseIf tPath="" {
					Set tErr = tErrPrefix_"has no path specified"
					
				} ElseIf (tPath="/")||(tPath'["/")||(($Extract(tPath,*-1,*)="/-")&&('((tOp="add")||(tOp="move")||(tOp="copy")))) {
					Set tErr = tErrPrefix_"has invalid path '"_tPath_"' specified"
					
				} ElseIf (tValue="")&&('((tOp="remove")||(tOp="move")||(tOp="copy"))) {
					Set tErr = tErrPrefix_"has no value specified"
					
				} ElseIf ((tOp="copy")||(tOp="move"))&&(tFrom="") {
					Set tErr = tErrPrefix_"has no from specified"
					
				} ElseIf (tFrom'="")&&((tFrom="/")||(tFrom'["/")) {
					Set tErr = tErrPrefix_"has invalid from '"_tFrom_"' specified"
					
				} ElseIf (tOp="move")&&($Piece(tPath,"/",1,$Length(tFrom,"/"))=tFrom) {
					Set tErr = tErrPrefix_"invalid move from '"_tFrom_"' to the same or child path"
					
				} ElseIf tPath="/id" {
					Set tErr = tErrPrefix_"on resource id is not allowed"
					
				} Else {
					Set tErr = ""
				}
				If tErr'="" {
					Set tSC = $$$ERROR($$$GeneralError, tErr)
					Quit
				}
				
				// Attempts to patch versionId and/or lastUpdated are ignored.
				If (tPath="/meta/versionId")||(tPath="/meta/lastUpdated") Continue
				
				Set tPathLen = $Length(tPath,"/")
				
				For i = 2:1:tPathLen {
					Set tPathPiece(i)=$Piece(tPath,"/",i)
					// Only the last piece of the path can be "-".
					If (tPathPiece(i)="-")&&(i<tPathLen) {
						Set tSC = $$$ERROR($$$GeneralError, tErrPrefix_"has invalid path '"_tPath_"' specified")
						Quit
					}
				}
				If $$$ISERR(tSC) Quit
				
				Set tFromLen = $Length(tFrom,"/")
				
				For i = 2:1:tFromLen {
					Set tFromPiece(i)=$Piece(tFrom,"/",i)
					// From cannot have array pointer of "-".
					If tFromPiece(i)="-" {
						Set tSC = $$$ERROR($$$GeneralError, tErrPrefix_"has invalid from '"_tFrom_"' specified")
						Quit
					}
				}
				If $$$ISERR(tSC) Quit
				
				Set tTargetIsArray = ((tPathPiece(tPathLen)?1N.N)||(tPathPiece(tPathLen)="-"))
				
				If tOp="add" {
					Set tPrevPathData=""
					Set tPathData = pResourceObj
					// Turn tPathData into the target property. The target property
					// does not have to already exist, but its parents need to exist.
					For j = 2:1:(tPathLen-1) {
						Set tPrevPathData = tPathData
						Set tPathData = tPathData.%Get(tPathPiece(j))
						If tPathData="" {
							If (j=(tPathLen-1))&&(tTargetIsArray) {
								// If the target is an array but there is no array
								// object there, go ahead and initialize one now.
								Set tArrObj = ##class(%Library.DynamicArray).%New()
								Do tPrevPathData.%Set(tPathPiece(j), tArrObj)
								Set tPathData = tPrevPathData.%Get(tPathPiece(j))
							} Else {
								Set tSC = $$$ERROR($$$GeneralError, tErrPrefix_"path '"_tPath_"' not found in resource")
								Quit
							}
						}
					}
					If $$$ISERR(tSC) Quit
					
					If tPathPiece(tPathLen)?1N.N {
						// If the target array element is within the current array
						// bound then shuffle out the array elements that are after
						// the target array index.
						Do ShuffleOut(.tPathPiece, .tPathLen, .tPathData, .tErrPrefix, .tPath, .tStatus)
						If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
						Do tPathData.%Set(tPathPiece(tPathLen), tValue)
					} ElseIf tPathPiece(tPathLen)="-" {
						// Insert at the end of the array.
						Do tPathData.%Push(tValue)
					} Else {
						// Path is not for an array element, just set the primitive or object.
						Do tPathData.%Set(tPathPiece(tPathLen), tValue)
					}
					Set pUpdated = 1
					
					
				} ElseIf tOp="remove" {
					Set tPathData = pResourceObj
					// Turn tPathData into the data at the target location. The target location must already exist.
					Do GetLocationData(.tPathPiece, .tPathLen, .tPathData, .tPathDataTypeOf, .tPrevPathData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
					
					Set tPathData = tPrevPathData
					Do tPathData.%Remove(tPathPiece(tPathLen))
					Set pUpdated = 1
					
					
				} ElseIf tOp="replace" {
					Set tPathData = pResourceObj
					// Turn tPathData into the data at the target location. The target location must already exist.
					Do GetLocationData(.tPathPiece, .tPathLen, .tPathData, .tPathDataTypeOf, .tPrevPathData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
					
					Set tPathData = tPrevPathData
					Do tPathData.%Set(tPathPiece(tPathLen), tValue)
					Set pUpdated = 1
					
					
				} ElseIf tOp="copy" {
					Set tFromData = pResourceObj
					// Turn tFromData into the data at the from location. The from location must already exist.
					Do GetLocationData(.tFromPiece, .tFromLen, .tFromData, .tFromDataTypeOf, .tPrevFromData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
					
					Set tPathData = pResourceObj
					// Turn tPathData into the data at the parent of the target location data.
					// The parent of the target location must already exist.
					Do GetLocationData(.tPathPiece, tPathLen-1, .tPathData, .tPathDataTypeOf, .tPrevPathData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
					
					If tPathPiece(tPathLen)?1N.N {
						// If the target array element is within the current array
						// bound then shuffle out the array elements that are after
						// the target array index.
						Do ShuffleOut(.tPathPiece, .tPathLen, .tPathData, .tErrPrefix, .tPath, .tStatus)
						If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
						If (tFromDataTypeOf="object")||(tFromDataTypeOf="array") {
							Set tStr = tFromData.%ToJSON()
							Set tNewObj = ##class(%Library.DynamicObject).%FromJSON(tStr)
							Do tPathData.%Set(tPathPiece(tPathLen), tNewObj)
						} Else {
							Do tPathData.%Set(tPathPiece(tPathLen), tFromData, tFromDataTypeOf)
						}
					} ElseIf tPathPiece(tPathLen)="-" {
						// Insert at the end of the array.
						Do tPathData.%Push(tFromData)
					} Else {
						If (tFromDataTypeOf="object")||(tFromDataTypeOf="array") {
							Set tStr = tFromData.%ToJSON()
							Set tNewObj = ##class(%Library.DynamicObject).%FromJSON(tStr)
							Do tPathData.%Set(tPathPiece(tPathLen), tNewObj)
						} Else {
							Do tPathData.%Set(tPathPiece(tPathLen), tFromData, tFromDataTypeOf)
						}
					}
					Set pUpdated = 1
					
					
				} ElseIf tOp="move" {
					Set tFromData = pResourceObj
					// Turn tFromData into the data at the from location. The from location must already exist.
					Do GetLocationData(.tFromPiece, .tFromLen, .tFromData, .tFromDataTypeOf, .tPrevFromData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
									
					Set tPathData = pResourceObj
					// Turn tPathData into the data at the parent of the target location data.
					// The parent of the target location must already exist.
					Do GetLocationData(.tPathPiece, tPathLen-1, .tPathData, .tPathDataTypeOf, .tPrevPathData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
					
					// Save and remove the from data.
					Set tSaveFromData = tFromData
					Do tPrevFromData.%Remove(tFromPiece(tFromLen))
					
					If tPathPiece(tPathLen)?1N.N {
						// If the target array element is within the current array
						// bound then shuffle out the array elements that are after
						// the target array index.
						Do ShuffleOut(.tPathPiece, .tPathLen, .tPathData, .tErrPrefix, .tPath, .tStatus)
						If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
						Do tPathData.%Set(tPathPiece(tPathLen), tSaveFromData)
					} ElseIf tPathPiece(tPathLen)="-" {
						// Insert at the end of the array.
						Do tPathData.%Push(tSaveFromData)
					} Else {
						Do tPathData.%Set(tPathPiece(tPathLen), tSaveFromData)
					}
					Set pUpdated = 1
					
					
				} ElseIf tOp="test" {
					Set tPathData = pResourceObj
					// Turn tPathData into the data at the target location. The target location must already exist.
					Do GetLocationData(.tPathPiece, .tPathLen, .tPathData, .tPathDataTypeOf, .tPrevPathData, .tErrPrefix, .tPath, .tStatus)
					If 'tStatus Set tSC = $$$ERROR($$$GeneralError, tStatus) Quit
					
					// %GetTypeOf is part of comparing primitives (e.g., "true" does not match true).
					Set tPathTypeOf = tPrevPathData.%GetTypeOf(tPathPiece(tPathLen))
					
					If '$IsObject(tPathData) {
						Set tPathDataJSONStr = tPathData
					} Else {
						Set tPathDataJSONStr = tPathData.%ToJSON()
					}
					If '$IsObject(tValue) {
						Set tValueJSONStr = tValue
					} Else {
						Set tValueJSONStr = tValue.%ToJSON()
					}
					
					If (tPathDataJSONStr'=tValueJSONStr)||(tPathTypeOf'=tValueTypeOf) {
						Set tSC = $$$ERROR($$$GeneralError, tErrPrefix_"of path '"_tPath_"' for value '"_tValueJSONStr_"' failed")
					}
				}
			} While 0 
            
		}
		
	} Catch eException {
		Set tSC = eException.AsStatus()
	}
	
	Quit tSC
	
GetLocationData(pieces, len, data, typeof, prevData, errPrefix, path, status)
	Set prevData = ""
	Set status = 1
	For j = 2:1:len {
		Set prevData = data
		Set typeof = data.%GetTypeOf(pieces(j))
		Set data = data.%Get(pieces(j))
		If data="" {
			Set status = errPrefix_"path '"_path_"' not found in resource"
			Quit
		}
	}
	Quit
	
ShuffleOut(pieces, len, data, errPrefix, path, status)
	Set status = 1
	Set size = data.%Size()
	//write !,"pieces(len)="_pieces(len)_"  size="_size,!
	If pieces(len)'>(size-1) {
		For j = (size-1):-1:pieces(len) {
			Do data.%Set(j+1,data.%Get(j))
		}
	} ElseIf pieces(len)>size {
		// Path cannot be beyond the end of the existing array.
		Set status = errPrefix_"path '"_path_"' is past end of existing array"
		Quit
	}
	Quit
}

}
