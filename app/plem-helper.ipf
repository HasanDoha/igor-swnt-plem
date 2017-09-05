﻿#pragma TextEncoding = "UTF-8"		// For details execute DisplayHelpTopic "The TextEncoding Pragma"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma IgorVersion = 6.20 // use sdfr

static StrConstant cstrPLEMd2maps 	= ":maps"
static StrConstant cstrPLEMd2info 	= ":INFO"
static StrConstant cstrPLEMd2chirality = ":CHIRALITY"
static StrConstant cstrPLEMd2originals = ":ORIGINAL"

static Function/DF returnDataFolderReference(strDataFolder)
	String strDataFolder
	NewDataFolder/O $strDataFolder
	DFREF myDFR = $strDataFolder
	if(DataFolderRefStatus(myDFR) == 0) // DFR is invalid
		Abort "Data Folder could not be created"
	endif
	return myDFR
End

// Function returns DataFolder reference to package root.
static Function/DF returnPackageRoot()
	DFREF dfrPackage = returnDataFolderReference(cstrPLEMd2root)
	return dfrPackage
End

// Function returns DataFolder reference to base directory where maps are stored
static Function/DF returnMapsFolder()
	DFREF dfrPackage = returnPackageRoot()
	DFREF dfrMaps = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps)
	return dfrMaps
End

// Function returns DataFolder reference to base directory of map specified by strMap
Function/DF returnMapFolder(strMap)
	String strMap
	if(strlen(strMap) == 0)
		Abort "Can not create such a folder"
	endif
	DFREF dfrMaps = returnMapsFolder()
	DFREF dfrMap = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap)
	return dfrMap
End

// Function returns DataFolder reference to current map's info folder where NVAR and SVAR are saved
static Function/DF returnMapInfoFolder(strMap)
	String strMap
	if(strlen(strMap) == 0)
		abort
	endif
	DFREF dfrMap = returnMapFolder(strMap)
	DFREF dfrInfo = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap + cstrPLEMd2info)
	return dfrInfo
End

// Function returns DataFolder reference to current map's info folder where NVAR and SVAR are saved
Function/DF returnMapChiralityFolder(strMap)
	String strMap
	DFREF dfrMap = returnMapFolder(strMap)
	DFREF dfrChirality = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap + cstrPLEMd2chirality)
	return dfrChirality
End

// Function returns DataFolder reference where original data is stored
Function/DF returnMapOriginalFolder(strMap)
	String strMap
	DFREF dfrMap = returnMapFolder(strMap)
	DFREF dfrOriginal = returnDataFolderReference(cstrPLEMd2root + cstrPLEMd2maps + ":" + strMap + cstrPLEMd2originals)
	return dfrOriginal
End

// Function returns value of Global String "name" in "dataFolder"
static Function/S getGstring(name, dataFolder)
	String name
	DFREF dataFolder
	SVAR/Z/SDFR=dataFolder myVar = $name
	if(!SVAR_EXISTS(myVar))
		String/G dataFolder:$name = ""
		return ""
	else
		return myVar
	endif
End

// Function returns value of Global (numeric) Variable "name" in "dataFolder"
static Function getGvar(name, dataFolder)
	String name
	DFREF dataFolder
	NVAR/Z/SDFR=dataFolder myVar = $name
	if(!NVAR_EXISTS(myVar))
		Variable/G dataFolder:$name = NaN
		return NaN
	else
		return myVar
	endif
End

// Wrapper Functions for creating Waves
Constant PLEMd2WaveTypeDouble   = 0
Constant PLEMd2WaveTypeUnsigned = 1
Constant PLEMd2WaveTypeText     = 2

Function/WAVE createWave(dfr, strWave, [setWaveType])
	DFREF dfr
	String strWave
	Variable setWaveType

	setWaveType = ParamIsDefault(setWaveType) ? PLEMd2WaveTypeDouble : setWaveType

	WAVE/Z/SDFR=dfr wv = $strWave
	if(WaveExists(wv))
		return wv
	endif

	switch(setWaveType)
		case PLEMd2WaveTypeDouble:
			WAVE wv = createDoubleWave(dfr, strWave)
			break
		case PLEMd2WaveTypeUnsigned:
			WAVE wv = createUnsignedWave(dfr, strWave)
			break
		case PLEMd2WaveTypeText:
			WAVE wv = createTextWave(dfr, strWave)
			break
		default:
			WAVE wv = createDoubleWave(dfr, strWave)
	endswitch

	return wv
End

static Function/WAVE createDoubleWave(dfr, strWave)
	DFREF dfr
	String strWave

	Make/D/N=0 dfr:$strWave/WAVE=wv
	return wv
End

static Function/WAVE createUnsignedWave(dfr, strWave)
	DFREF dfr
	String strWave

	Make/I/U/N=0 dfr:$strWave/WAVE=wv
	return wv
End

static Function/WAVE createTextWave(dfr, strWave)
	DFREF dfr
	String strWave

	Make/T/N=0 dfr:$strWave/WAVE=wv
	return wv
End

// Function sets Global String "name" in "dataFolder" to "value"
static Function setGstring(name, value, dataFolder)
	String name, value
	DFREF dataFolder

	SVAR/Z/SDFR=dataFolder myVar = $name
	if(!SVAR_EXISTS(myVar))
		String/G dataFolder:$name
		SVAR/Z/SDFR=dataFolder myVar = $name
		if(!SVAR_EXISTS(myVar))
			Abort "Could not create global String"
		endif
	endif

	myVar = value
End

// Function sets Global Variable "name" in "dataFolder" to "value"
static Function setGvar(name, value, dataFolder)
	String name
	Variable value
	DFREF dataFolder

	NVAR/Z/SDFR=dataFolder myVar = $name
	if(!NVAR_EXISTS(myVar))
		Variable/G dataFolder:$name
		NVAR/Z/SDFR=dataFolder myVar = $name
		if(!NVAR_EXISTS(myVar))
			Abort "Could not create global Variable"
		endif
	endif

	myVar = value
End

// Abbreviated Functions for returning Variables from Package root.
Function/S getPackageString(name)
	String name
	DFREF dfrPackage = returnPackageRoot()
	return getGstring(name, dfrPackage)
End

Function getPackageVariable(name)
	String name
	DFREF dfrPackage = returnPackageRoot()
	return getGvar(name, dfrPackage)
End

Function setPackageString(name, value)
	String name, value
	DFREF dfrPackage = returnPackageRoot()
	setGstring(name, value, dfrPackage)
End

Function setPackageVariable(name, value)
	String name
	Variable value
	DFREF dfrPackage = returnPackageRoot()
	setGvar(name, value, dfrPackage)
End

// Abbreviated Functions for returning Variables from current map.
Function/S getMapString(strMap, var)
	String strMap, var
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	return getGstring(var, dfrInfo)
End

Function getMapVariable(strMap, var)
	String strMap, var
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	return getGvar(var, dfrInfo)
End

Function setMapString(strMap, var, value)
	String strMap, var, value
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	setGstring(var, value, dfrInfo)
End

Function setMapVariable(strMap, var, value)
	String strMap, var
	Variable value
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	setGvar(var, value, dfrInfo)
End

// Abbreviated Functions for returning Variables from CHIRALITY FOLDER
Function/S getAtlasString(strMap, var)
	String strMap, var
	DFREF dfrInfo = returnMapInfoFolder(strMap)
	return getGstring(var, dfrInfo)
End

Function getAtlasVariable(strMap, var)
	String strMap, var
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	return getGvar(var, dfrAtlas)
End

Function setAtlasString(strMap, var, value)
	String strMap, var, value
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	setGstring(var, value, dfrAtlas)
End

Function setAtlasVariable(strMap, var, value)
	String strMap, var
	Variable value
	DFREF dfrAtlas = returnMapChiralityFolder(strMap)
	setGvar(var, value, dfrAtlas)
End
