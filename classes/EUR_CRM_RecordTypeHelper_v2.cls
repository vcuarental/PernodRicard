/**    A cache class to avoid unnecessary
    *  queries for RT ids <=> Developer Names
    *
    *  Usage:
    *      RecordTypeHelper rh = new RecordTypeHelper();
    *      Id pharmId = rh.getRTByDevName('Account','Pharmacy');
    *
    *      if no RecordType with this name exists for this object, a null is returned
    *
    *  @author:  PZ - Customertimes
    *  @created: 23.08.16
    *  @version: 0.1
 */
public with sharing class EUR_CRM_RecordTypeHelper_v2 {

    public static List<EUR_CRM_Record_Type_Map__mdt> rtMapsForTest = new List<EUR_CRM_Record_Type_Map__mdt>();
    public static List<EUR_CRM_Record_Type_List__mdt> rtListsForTest = new List<EUR_CRM_Record_Type_List__mdt>();
    public static List<EUR_CRM_RecordTypeMultilevelMap__mdt> rtMultilevelMapsForTest = new List<EUR_CRM_RecordTypeMultilevelMap__mdt>();
    public static List<EUR_CRM_RecordTypeMultivalueMap__mdt> rtMultivalueMapsForTest = new List<EUR_CRM_RecordTypeMultivalueMap__mdt>();

    private static Map<String, Map<String, Set<String>>> settingsMultivalueMapByClassAndVarName {
        get {
            if (settingsMultivalueMapByClassAndVarName == null) { settingsMultivalueMapByClassAndVarName = getSettingsMultivalueMapByClassAndVarName(); }
			return settingsMultivalueMapByClassAndVarName;
        }
		set;
    }

    private static Map<String, Map<String, Map<String, String>>> settingsMultilevelMapByClassAndVarName {
        get {
            if (settingsMultilevelMapByClassAndVarName == null) {
                settingsMultilevelMapByClassAndVarName = getSettingsMultilevelMapByClassAndVarName(); }
            return settingsMultilevelMapByClassAndVarName;
        }
        set;
    }

    private static Map<String, Map<String, String>> settingsMapByClassAndVarName {
        get {
            if (settingsMapByClassAndVarName == null) {
                settingsMapByClassAndVarName = getSettingsMapByClassAndVariableName(); }
            return settingsMapByClassAndVarName;
        }
        set;
    }

    private static Map<String, Set<String>> settingsSetByClassAndVarName {
            get {
                if (settingsSetByClassAndVarName == null) {
                    settingsSetByClassAndVarName = getSettingsSetByClassAndVarName(); }
                return settingsSetByClassAndVarName;
            }
            set;
        }

    // map of Object type <=> Recordtype id <=> _DeveloperName_
    private static Map<Schema.sObjectType, Map<Id, RecordType>> objRTMap = new Map<Schema.sObjectType, Map<Id, RecordType>>();

    public static Map<Id, RecordType> getAvailableObjectRecordTypes (String sObjType){
        Map<Id,RecordType> availableRecordTypes = new Map<Id,RecordType>();
        Set<Id> recordTypeInfoId = new Set<Id>();
        Schema.sObjectType objT = getsObjectToken(sObjType);

        for (RecordTypeInfo recordTypeInfo : objT.getDescribe().getRecordTypeInfos()){
            if(recordTypeInfo.isAvailable() && !recordTypeInfo.isMaster()){
                recordTypeInfoId.add(recordTypeInfo.getRecordTypeId());
            }
        }
        availableRecordTypes = new Map<Id, RecordType>([SELECT Id, DeveloperName, toLabel(Name), Description, isActive FROM RecordType WHERE Id IN :recordTypeInfoId]);
        return availableRecordTypes.isEmpty() ? null : availableRecordTypes;
    }

    public static Map<Id, RecordType> getObjectRts(String sObjType){
        Schema.sObjectType objT = getsObjectToken(sObjType);
        Map<Id, RecordType> rtsForType = objRTMap.get(objT);
        if(rtsForType == null){
            rtsForType = new Map<Id, RecordType>([SELECT Id, DeveloperName, toLabel(Name), Description, isActive FROM RecordType WHERE sObjectType = : sObjType]);
            objRTMap.put(objT, rtsForType);
        }
        return rtsForType;
    }

    public static Id getRTByDevName(String sObjType, String developerName){
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        for(Id rtId: rtsForType.keySet()){
            RecordType thisType = rtsForType.get(rtId);
            if(thisType.DeveloperName.equalsIgnoreCase(developerName)){
                return thisType.Id;
            }
        }
        return null;
    }


    /* Get map of all record types for this sObjectType
    *  Returns a defensive copy to avoid mutations to the cache
    *
    *  @param  sObjType             - sObject type token
    *  @return Map<Id, RecordType>  - map id <=> record type for this object
    */
    public Map<Id, RecordType> getObjectRts(Schema.sObjectType sObjType){
        if(sObjType == null){
            return null;
        }
        Map<Id, RecordType> rtsForType = objRTMap.get(sObjType);
        if(rtsForType == null){
            rtsForType = new Map<Id, RecordType>([SELECT Id, DeveloperName, toLabel(Name), isActive, Description FROM RecordType WHERE sObjectType = : sObjType.getDescribe().getName()]);
            objRTMap.put(sObjType, rtsForType);
        }
        return rtsForType.deepClone();
    }
    /* Convert developer name of the sObject to its token
    *
    *  @param  sObjTypeName         - API name of an object
    *  @return Schema.sObjectType   - sObject type token
    */
    private static Schema.sObjectType getsObjectToken(String sObjTypeName){
        Schema.sObjectType t = Schema.getGlobalDescribe().get(sObjTypeName);
        return t;
    }
    /* Get map of all record types for this sObjectType
    *  Returns a defensive copy to avoid mutations to the cache
    *
    *  @param  sObjTypeName         - API name of an object
    *  @return Map<Id, RecordType>  - map id <=> record type for this object
    */
    public Map<Id, RecordType> getObjectRtz(String sObjTypeName){
        return getObjectRts(getsObjectToken(sObjTypeName));
    }
    /* Returns flag to indicate that a record type for this object
    *  with this name exists
    *
    *  @param  sObjTypeName         - API name of an object
    *  @param  rtDevName            - API name of the record type
    *  @return Boolean              - flag if exists
    */
    public Boolean isValidRT(String sObjTypeName, String rtDevName){
        return isValidRT(getsObjectToken(sObjTypeName),rtDevName);
    }
    /* Returns flag to indicate that a record type for this object
    *  with this name exists
    *
    *  @param  sObjType             - sObject type token
    *  @param  rtDevName            - API name of the record type
    *  @return Boolean              - flag if exists
    */
    public Boolean isValidRT(Schema.sObjectType sObjType, String rtDevName){
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        for(Id rtId :rtsForType.keySet()){
            RecordType thisRT = rtsForType.get(rtId);
            if(thisRT.DeveloperName.equalsIgnoreCase(rtDevName)){
                return true;
            }
        }
        return false;
    }
    /* Returns Id of the record type for this object that matches
    *  this name. If no such record type is found, a null is returned
    *
    *  @param  sObjType             - sObject type token
    *  @param  rtDevName            - API name of the record type
    *  @return Boolean              - record type Id
    */
    public Id getRTByDevName(Schema.sObjectType sObjType, String rtDevName){
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        for(Id rtId: rtsForType.keySet()){
            RecordType thisType = rtsForType.get(rtId);
            if(thisType.DeveloperName.equalsIgnoreCase(rtDevName)){
                return thisType.Id;
            }
        }
        return null;
    }
    /* Returns Id of the record type for this object that matches
    *  this name. If no such record type is found, a null is returned
    *
    *  @param  sObjTypeName         - API name of an object
    *  @param  rtDevName            - API name of the record type
    *  @return Id                   - record type Id
    */
    public Id getRTByDevNamez(String sObjTypeName, String rtDevName){
        return getRTByDevName(getsObjectToken(sObjTypeName),rtDevName);
    }
    /* Returns Ids of the record types for this object that contain
    *  the provided string. If no such record types are found, an empty
    *  set is returned
    *
    *  @param  sObjType             - sObject type token
    *  @param  rtDevName            - API name of the record type
    *  @return Set<Id>              - Ids of record types
    */
    public Set<Id> getSimilarRTsbyDevName(Schema.sObjectType sObjType, String rtDevName){
        Set<Id> matchIds = new Set<Id>();
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        for(Id rtId: rtsForType.keySet()){
            RecordType thisType = rtsForType.get(rtId);
            if(thisType.DeveloperName.containsIgnoreCase(rtDevName)){
                matchIds.add(thisType.Id);
            }
        }
        return matchIds;
    }
    /* Returns Ids of the record types for this object that contain
    *  the provided string. If no such record types are found, an empty
    *  set is returned
    *
    *  @param  sObjTypeName         - API name of an object
    *  @param  rtDevName            - API name of the record type
    *  @return Set<Id>              - Ids of record types
    */
    public Set<Id> getSimilarRTsbyDevName(String sObjTypeName, String rtDevName){
        return getSimilarRTsbyDevName(getsObjectToken(sObjTypeName),rtDevName);
    }
    /* Returns the Id of the record type for this object if this
    *  record type's name is similar to the provided record type's name
    *  with/without the spacer and flip-word
    *  Usage:
    *           getFlippedRTById('Account', 0a1616546fda46, 'temporary','_');
    *
    *           should return the Id of the record type with the name 'Pharmacy_temporary'
    *           if the provided Id was for the record type with the name 'Pharmacy'.
    *           Likewise other way around.
    *
    *  @param  sObjType             - sObject type token
    *  @param  recTypeId            - Id of the Record Type to name-flip
    *  @param  flipWord             - the word appended to the record type name
    *  @param  spacer               - the separator between the flipword and the base name of the record type
    *  @return Id                   - Id of the found record type
    */
    public Id getFlippedRTById(Schema.sObjectType sObjType, Id recTypeId, String flipWord, String spacer){
        Id matchId;
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        RecordType hit = rtsForType.get(recTypeId);
        if(hit != null){
            String hitDName = hit.DeveloperName;
            String searchDName = '';
            // only for terminating suffixes
            if(!hitDName.endsWithIgnoreCase(flipWord)){
                // append flipWord
                searchDName = hitDName+spacer+flipWord;
            } else {
                // trim flipWord
                searchDName = hitDName.substringBefore(spacer+flipWord);
            }
            if(!String.isEmpty(searchDName)){
                matchId = getRTByDevName(sObjType, searchDName);
            } else {
                // return original rectype id
                matchId = recTypeId;
            }
        }
        return matchId;
    }
    /* Returns the Id of the record type for this object if this
    *  record type's name is similar to the provided record type's name
    *  with/without the spacer and flip-word
    *
    *  @param  sObjTypeName         - sObject type name
    *  @param  recTypeId            - Id of the Record Type to name-flip
    *  @param  flipWord             - the word appended to the record type name
    *  @param  spacer               - the separator between the flipword and the base name of the record type
    *  @return Id                   - Id of the found record type
    */
    public Id getFlippedRTById(String sObjTypeName, Id recTypeId, String flipWord, String spacer){
        return getFlippedRTById(getsObjectToken(sObjTypeName),recTypeId,flipWord,spacer);
    }

    /* Returns the Ids of the record types for this object that
    *  match the provided list of developer names
    *
    *  @param  sObjType             - sObject type token
    *  @param  devNames             - list of Ids to match
    *  @return Map<Id, String>      - map of matched record types
    */
    public Map<Id, String> getRTsByDevNames(final Schema.sObjectType sObjType,final List<String> devNames){
        Map<Id, String> toReturn = new Map<Id, String>();
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        for(Id rtId: rtsForType.keySet()){
            RecordType thisType = rtsForType.get(rtId);
            for(String devName: devNames){
                if(thisType.DeveloperName.equalsIgnoreCase(devName)){
                    toReturn.put(thisType.Id, thisType.DeveloperName);
                }
            }
        }
        return toReturn.clone();
    }
    /* Returns the Id of the record type for this object that
    *  matches the developer name
    *
    *  @param  sObjType             - sObject type token
    *  @param  rtId                 - id to find
    *  @return String               - developer name
    */
    public String getRTNameById(final Schema.sObjectType sObjType,Id rtId){
        Map<Id, RecordType> rtsForType = getObjectRts(sObjType);
        return rtsForType.get(rtId).DeveloperName;
    }
    /* Returns the Id of the record type for this object that
    *  matches the developer name
    *
    *  @param  sObjName             - sObject type name
    *  @param  rtId                 - id to find
    *  @return String               - developer name
    */
    public String getRTNameById(final String sObjName,Id rtId){
        Map<Id, RecordType> rtsForType = getObjectRtz(sObjName);
        return rtsForType.get(rtId).DeveloperName;
    }

    public static Map<String, String> getSettingsMap(String className, String variableName) {
        if ( ! (settingsMapByClassAndVarName.containsKey(className + variableName))) {
            return new Map<String, String>();
        }
        return settingsMapByClassAndVarName.get(className + variableName);
    }

    public static Set<String> getSettingsSet(String className, String variableName) {
        if ( ! (settingsSetByClassAndVarName.containsKey(className + variableName))) {
            return new Set<String>();
        }
        return settingsSetByClassAndVarName.get(className + variableName);
    }

    public static Map<String, Map<String, String>> getSettingsMultilevelMap(String className, String variableName) {
        if ( ! settingsMultilevelMapByClassAndVarName.containsKey(className + variableName)) {
            return new Map<String, Map<String, String>>();
        }
        return settingsMultilevelMapByClassAndVarName.get(className + variableName);
    }

    public static Map<String, Set<String>> getSettingsMultivalueMap(String className, String variableName) {
        if ( ! settingsMultivalueMapByClassAndVarName.containsKey(className + variableName)) {
            return new Map<String, Set<String>>();
        }
        return settingsMultivalueMapByClassAndVarName.get(className + variableName);
    }


    /* ========================================================= */
    /*      High Level Helpers
    /* ========================================================= */
    public static Map<String, Map<String, Boolean>> getBooleanByStringByString(Map<String, Map<String, String>> strByStrByStr) {
        Map<String, Map<String, Boolean>> boolByStrByStr = new Map<String, Map<String, Boolean>>();
        for (String parentStr : strByStrByStr.keySet()) {
            Map<String, String> childMap = strByStrByStr.get(parentStr);
            for (String childStr : childMap.keySet()) {
                if (boolByStrByStr.containsKey(parentStr)) {
                    boolByStrByStr.get(parentStr).put(childStr, Boolean.valueOf(childMap.get(childStr)));
                } else {
                    boolByStrByStr.put(parentStr, new Map<String, Boolean>{ childStr => Boolean.valueOf(childMap.get(childStr))});
                }
            }
        }
        return boolByStrByStr;
    }

    public static Map<String, Map<String, Integer>> getIntegerByStringByString(Map<String, Map<String, String>> strByStrByStr) {
        Map<String, Map<String, Integer>> integerByStrByStr = new Map<String, Map<String, Integer>>();
        for (String parentStr : strByStrByStr.keySet()) {
            Map<String, String> childMap = strByStrByStr.get(parentStr);
            for (String childStr : childMap.keySet()) {
                if (integerByStrByStr.containsKey(parentStr)) {
                    integerByStrByStr.get(parentStr).put(childStr, Integer.valueOf(childMap.get(childStr)));
                } else {
                    integerByStrByStr.put(parentStr, new Map<String, Integer>{ childStr => Integer.valueOf(childMap.get(childStr))});
                }
            }
        }
        return integerByStrByStr;
    }

	private static Map<String, Map<String, Set<String>>> getSettingsMultivalueMapByClassAndVarName() {
		List<EUR_CRM_RecordTypeMultivalueMap__mdt> rtMultivalueMaps = selectRTMultivalueMaps();
		if (rtMultivalueMaps.isEmpty()) { return new Map<String, Map<String, Set<String>>>(); }

		Map<String, Map<String, Set<String>>> settingsByKeyByClassAndVarName = new Map<String, Map<String, Set<String>>>();
		for (EUR_CRM_RecordTypeMultivalueMap__mdt multivalueMap : rtMultivalueMaps) {
			if ( ! isRtMultivalueMapValid(multivalueMap)) { continue; }

            List<String> splValues = multivalueMap.EUR_CRM_Value__c.trim().split('\\s*[,;]\\s*');
            Set<String> values = new Set<String>();
            values.addAll(splValues);
			String customKey = multivalueMap.EUR_CRM_Class_name__c + multivalueMap.EUR_CRM_Variable_name__c;

            if (settingsByKeyByClassAndVarName.containsKey(customKey)) {
                if (settingsByKeyByClassAndVarName.get(customKey).containsKey(multivalueMap.EUR_CRM_Key__c)) {
                    settingsByKeyByClassAndVarName.get(customKey).get(multivalueMap.EUR_CRM_Key__c).addAll(values);
                } else {
                    settingsByKeyByClassAndVarName.get(customKey).put(multivalueMap.EUR_CRM_Key__c, values);
                }
            } else {
                settingsByKeyByClassAndVarName.put(customKey, new Map<String, Set<String>>{ multivalueMap.EUR_CRM_Key__c => values});
            }
		}
		return settingsByKeyByClassAndVarName;

	}

    private static Map<String, Map<String, Map<String, String>>> getSettingsMultilevelMapByClassAndVarName() {
        List<EUR_CRM_RecordTypeMultilevelMap__mdt> rtMultilevelMaps = selectRTMultilevelMaps();
        if (rtMultilevelMaps.isEmpty()) { return new Map<String, Map<String, Map<String, String>>>(); }

        Map<String, Map<String, Map<String, String>>> validSettingByChildByParentSettingByClassAndVarName = new Map<String, Map<String, Map<String, String>>>();

        for (EUR_CRM_RecordTypeMultilevelMap__mdt multilevelMap : rtMultilevelMaps) {
            if ( ! isRtMultilevelMapValid(multilevelMap)) { continue; }
            String customKey = multilevelMap.EUR_CRM_Class_name__c + multilevelMap.EUR_CRM_Variable_name__c;
            if (validSettingByChildByParentSettingByClassAndVarName.containsKey(customKey)) {

                if (validSettingByChildByParentSettingByClassAndVarName.get(customKey).containsKey(multilevelMap.EUR_CRM_Parent_Key__c)) {
                    validSettingByChildByParentSettingByClassAndVarName.get(customKey).get(multilevelMap.EUR_CRM_Parent_Key__c)
                        .put(multilevelMap.EUR_CRM_Child_Key__c, multilevelMap.EUR_CRM_Value__c);
                } else {
                    validSettingByChildByParentSettingByClassAndVarName.get(customKey)
                        .put(multilevelMap.EUR_CRM_Parent_Key__c, new Map<String, String>{
                            multilevelMap.EUR_CRM_Child_Key__c => multilevelMap.EUR_CRM_Value__c
                    });
                }
            } else {
                validSettingByChildByParentSettingByClassAndVarName.put(
                    customKey, new Map<String, Map<String, String>>{
                        multilevelMap.EUR_CRM_Parent_Key__c => new Map<String, String>{
                            multilevelMap.EUR_CRM_Child_Key__c => multilevelMap.EUR_CRM_Value__c
                        }
                    });
            }
        }
        return validSettingByChildByParentSettingByClassAndVarName;
    }

    private static Map<String, Map<String, String>> getSettingsMapByClassAndVariableName() {
        List<EUR_CRM_Record_Type_Map__mdt> rtMaps = selectRtMaps();
        if (rtMaps.isEmpty()) { return new Map<String, Map<String, String>>(); }

        Map<String, Map<String, String>> validRTByRTByVarClassAndVarName = new Map<String, Map<String, String>>();

        for (EUR_CRM_Record_Type_Map__mdt rtMap : rtMaps) {
            if ( ! isRtMapValid(rtMap)) { continue; }
            String customKey = rtMap.EUR_CRM_Class_name__c + rtMap.EUR_CRM_Variable_name__c;
            if (validRTByRTByVarClassAndVarName.containsKey(customKey)) {
                validRTByRTByVarClassAndVarName.get(customKey).put(rtMap.EUR_CRM_Key__c, rtMap.EUR_CRM_Value__c);
            } else {
                validRTByRTByVarClassAndVarName.put(customKey, new Map<String, String>{
                            rtMap.EUR_CRM_Key__c => rtMap.EUR_CRM_Value__c
                        });
            }
        }
        return validRTByRTByVarClassAndVarName;
    }

    private static Map<String, Set<String>> getSettingsSetByClassAndVarName() {
        List<EUR_CRM_Record_Type_List__mdt> rtLists = selectRTLists();
        if (rtLists.isEmpty()) { return new Map<String, Set<String>>(); }

        Map<String, Set<String>> rtsByClassAndVarName = new Map<String, Set<String>>();
        for (EUR_CRM_Record_Type_List__mdt rtList : rtLists) {
            if ( ! isRtListValid(rtList)) { continue; }

            List<String> splRts = rtList.EUR_CRM_Valid_Record_Types__c.trim().split('\\s*[,;]\\s*');
            Set<String> rts = new Set<String>();
            rts.addAll(splRts);
            String customKey = rtList.EUR_CRM_Class_name__c + rtList.EUR_CRM_Variable_name__c;
            if (rtsByClassAndVarName.containsKey(customKey)) {
                rtsByClassAndVarName.get(customKey).addAll(rts);
            } else {
                rtsByClassAndVarName.put(customKey, rts);
            }
        }
        return rtsByClassAndVarName;
    }


    /* ========================================================= */
    /*      Low Level Helpers
    /* ========================================================= */
	private static Boolean isRtMultivalueMapValid(EUR_CRM_RecordTypeMultivalueMap__mdt multivalueMap) {
		return String.isNotBlank(multivalueMap.EUR_CRM_Class_name__c)
			&& String.isNotBlank(multivalueMap.EUR_CRM_Variable_name__c)
			&& String.isNotBlank(multivalueMap.EUR_CRM_Key__c)
			&& String.isNotBlank(multivalueMap.EUR_CRM_Value__c)
			;
	}

    private static Boolean isRtMultilevelMapValid(EUR_CRM_RecordTypeMultilevelMap__mdt multilevelMap) {
        return String.isNotBlank(multilevelMap.EUR_CRM_Class_name__c)
            && String.isNotBlank(multilevelMap.EUR_CRM_Variable_name__c)
            && String.isNotBlank(multilevelMap.EUR_CRM_Parent_Key__c)
            && String.isNotBlank(multilevelMap.EUR_CRM_Child_Key__c)
            && String.isNotBlank(multilevelMap.EUR_CRM_Value__c)
            ;
    }

    private static Boolean isRtMapValid(EUR_CRM_Record_Type_Map__mdt rtMap) {
        return String.isNotBlank(rtMap.EUR_CRM_Class_name__c)
            && String.isNotBlank(rtMap.EUR_CRM_Variable_name__c)
            && String.isNotBlank(rtMap.EUR_CRM_Key__c)
            && String.isNotBlank(rtMap.EUR_CRM_Value__c)
            ;
    }

    private static Boolean isRtListValid(EUR_CRM_Record_Type_List__mdt rtList) {
        return String.isNotBlank(rtList.EUR_CRM_Class_name__c)
            && String.isNotBlank(rtList.EUR_CRM_Variable_name__c)
            && String.isNotBlank(rtList.EUR_CRM_Valid_Record_Types__c)
            ;
    }


    /* ========================================================= */
    /*      Makers
    /* ========================================================= */
    public static List<EUR_CRM_RecordTypeMultivalueMap__mdt> makeMultivalueMapsForTest(String className, String variableName, Map<String, Set<String>> valuesByKey) {
        List<EUR_CRM_RecordTypeMultivalueMap__mdt> multilevelMaps = new List<EUR_CRM_RecordTypeMultivalueMap__mdt>();
        for (String key : valuesByKey.keySet()) {
            multilevelMaps.add(makeMultivalueMap(className, variableName, key, valuesByKey.get(key)));
        }
        return multilevelMaps;
    }

    public static List<EUR_CRM_RecordTypeMultilevelMap__mdt> makeMultilevelMapsForTest(String className, String variableName, Map<Object, Map<Object, Object>> objByObjByObj) {
        List<EUR_CRM_RecordTypeMultilevelMap__mdt> multilevelMaps = new List<EUR_CRM_RecordTypeMultilevelMap__mdt>();
        for (Object parKey : objByObjByObj.keySet()) {
            Map<Object, Object> childMap = objByObjByObj.get(parKey);
            for (Object childKey : childMap.keySet()) {
                EUR_CRM_RecordTypeMultilevelMap__mdt multilevelMap = makeMultilevelMap(className, variableName, String.valueOf(parKey),
                    String.valueOf(childKey), String.valueOf(childMap.get(childKey)));
                multilevelMaps.add(multilevelMap);
            }
        }
        return multilevelMaps;
    }

    public static EUR_CRM_Record_Type_List__mdt makeRtListForTest(String className, String variableName, Set<String> recordTypes) {
        return new EUR_CRM_Record_Type_List__mdt(
            EUR_CRM_Class_name__c = className
            ,   EUR_CRM_Variable_name__c = variableName
            ,   EUR_CRM_Valid_Record_Types__c = makeStringFromSet(recordTypes)
            ,   EUR_CRM_Is_Active__c = true
        );
    }

    public static List<EUR_CRM_Record_Type_Map__mdt> makeRtMapsForTest(String className, String varName, Map<String, String> mapToCreateCMT) {
        List<EUR_CRM_Record_Type_Map__mdt> rtMappingMaps = new List<EUR_CRM_Record_Type_Map__mdt>();
        for (String key : mapToCreateCMT.keySet()) {
            rtMappingMaps.add(makeRtMap(className, varName, key, mapToCreateCMT.get(key)));
        }
        return rtMappingMaps;
    }

    private static EUR_CRM_RecordTypeMultilevelMap__mdt makeMultilevelMap(String className, String variableName, String parKey, String childKey, String val) {
        return new EUR_CRM_RecordTypeMultilevelMap__mdt(
            EUR_CRM_Class_name__c = className
        ,   EUR_CRM_Variable_name__c = variableName
        ,   EUR_CRM_Parent_Key__c = parKey
        ,   EUR_CRM_Child_Key__c = childKey
        ,   EUR_CRM_Value__c = val
        ,   EUR_CRM_Is_Active__c = true
        );
    }

    private static EUR_CRM_RecordTypeMultivalueMap__mdt makeMultivalueMap(String className, String variableName, String key, Set<String> values) {
        return new EUR_CRM_RecordTypeMultivalueMap__mdt(
            EUR_CRM_Class_name__c = className
        ,   EUR_CRM_Variable_name__c = variableName
        ,   EUR_CRM_Key__c = key
        ,   EUR_CRM_Value__c = makeStringFromSet(values)
        ,   EUR_CRM_Is_Active__c = true
        );
    }

    private static EUR_CRM_Record_Type_Map__mdt makeRtMap(String className, String varName, String key, String val) {
        return new EUR_CRM_Record_Type_Map__mdt(
            EUR_CRM_Class_name__c =  className
            ,   EUR_CRM_Variable_name__c = varName
            ,   EUR_CRM_Key__c = key
            ,   EUR_CRM_Value__c = val
            ,   EUR_CRM_Is_Active__c = true
        );
    }

    private static String makeStringFromSet(Set<String> strings) {
        String res = '';
        for (String str : strings) {
            res = res + str + ',';
        }
        return res.removeEnd(',');
    }


    /* ========================================================= */
    /*      SOQL Selectors
    /* ========================================================= */
    private static List<EUR_CRM_Record_Type_Map__mdt> selectRtMaps() {
        if (Test.isRunningTest()) { return rtMapsForTest; }
        return [
            SELECT Id
                ,   EUR_CRM_Class_name__c
                ,   EUR_CRM_Variable_name__c
                ,   EUR_CRM_Key__c
                ,   EUR_CRM_Value__c
            FROM EUR_CRM_Record_Type_Map__mdt
            WHERE EUR_CRM_Is_Active__c = true
        ];
    }

    private static List<EUR_CRM_Record_Type_List__mdt> selectRTLists() {
        if (Test.isRunningTest()) { return rtListsForTest;}
        return [
            SELECT Id
                ,   EUR_CRM_Class_name__c
                ,   EUR_CRM_Variable_name__c
                ,   EUR_CRM_Valid_Record_Types__c
                ,   EUR_CRM_Is_Active__c
            FROM EUR_CRM_Record_Type_List__mdt
            WHERE EUR_CRM_Is_Active__c = true
        ];
    }

    private static List<EUR_CRM_RecordTypeMultilevelMap__mdt> selectRTMultilevelMaps() {
        if (Test.isRunningTest()) { return rtMultilevelMapsForTest; }
        return [
            SELECT Id
            ,	DeveloperName
            ,	EUR_CRM_Class_name__c
            ,	EUR_CRM_Variable_name__c
            ,	EUR_CRM_Parent_Key__c
            ,	EUR_CRM_Child_Key__c
            ,	EUR_CRM_Value__c
            ,	EUR_CRM_Is_Active__c
            FROM EUR_CRM_RecordTypeMultilevelMap__mdt
            WHERE EUR_CRM_Is_Active__c = true
        ];
    }

	private static List<EUR_CRM_RecordTypeMultivalueMap__mdt> selectRTMultivalueMaps() {
		if (Test.isRunningTest()) { return rtMultivalueMapsForTest; }
		return [
			Select DeveloperName
				, EUR_CRM_Class_name__c
				, EUR_CRM_Variable_name__c
				, EUR_CRM_Key__c
				, EUR_CRM_Value__c
			FROM EUR_CRM_RecordTypeMultivalueMap__mdt
			WHERE EUR_CRM_Is_Active__c = true
		];
	}
}