public class ASI_CRM_UploadResourcesController {

 	@AuraEnabled
   	public List<ASI_CRM_Upload_Resources_Setting__mdt> uploadResourcesSettingList {get; set;}
    public static String loaderRecord = '';
    
    @AuraEnabled
    public static List<ASI_CRM_Upload_Resources_Setting__mdt> getUploadResourcesSetting(String uploadResourceId) {
        List<ASI_CRM_Upload_Resources_Setting__mdt> retrievedUploadResourcesSettingList = retrieveSettingData(uploadResourceId);
        loaderRecord = 'has load before';
        return retrievedUploadResourcesSettingList;
    }
    
    public class UploadResult {
        public Integer rowNumber;
        public String status;
        public String errormessage;
        public String internalstatus; //Done, DML Procesing
    }
    
    @AuraEnabled
    public static List<UploadResult> uploadContext(String jsonContext, 
                                                   String uploadResourceId, 
                                                   String recordId,
                                                   String sobjecttype) 
    {
        System.debug ('loaderRecord: '+loaderRecord);
        
        // Input
        System.debug ('INCOMIN DATA --------------------------------------------------------------------------------------------------------');
        System.debug ('jsonContext:' + jsonContext);
        System.debug ('uploadResourceId:' + uploadResourceId);
        System.debug ('recordId:' + recordId);
        System.debug ('sobjecttype:' + sobjecttype);
        
        List<UploadResult> uploadResultList = new List<UploadResult>();
        //if (true) {
        //	return uploadResultList;
        //}    
        boolean isProcessAll = true;
                                                       
        // Pre Process
        // -----------------------------------------------------------------------------------------------
        System.debug ('SETTING --------------------------------------------------------------------------------------------------------');
        List<Object> jsonObjectList = (List<Object>) JSON.deserializeUntyped(jsonContext);
        List<Object> filterJsonObjectList = new List<Object> ();
        List<ASI_CRM_Upload_Resources_Setting__mdt> retrievedUploadResourcesSettingList = retrieveSettingData(uploadResourceId);
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        Schema.SObjectType ctype = null;
       	Map<String, Schema.SobjectField> fmap = null;
        Map <String, Schema.SobjectField> sObjectFieldMap = new Map <String,  Schema.SobjectField> ();
        
        String objectName;
        String recordIdFieldName = sobjecttype;
        List<String> fieldList = new List<String> (); //ASI_CRM_Salesforce_Field_Name__c
        List<String> fieldKeyList = new List<String> (); //ASI_CRM_Salesforce_Field_Name__c(ASI_CRM_Config_Is_Record_Key__c)
        
        Set<String> systemKeySet = new Set<String> ();
        Map<String, String> systemKeyValueMap = new Map<String, String> ();
        
        Map<String, String> fieldKeyExcelKeyMap = new Map<String, String> (); //ASI_CRM_Salesforce_Field_Name__c, ASI_CRM_Excel_Column_Header__c
        Map<String, List<String>> fieldKeyValueMap = new Map<String, List<String>> ();
        Map<String, sObject> existingObjectMapByRecordKey = new Map<String, sObject> ();
        // Refernce Library
        List<String> referenceList = new List<String> ();
        Map<String, String> referenceFieldMap = new Map<String, String> ();
        Map<String, String> referenceObjectNameMap = new Map<String, String> ();
        
        Map<String, Map<String, sObject>> referenceSObjectAllMap = new Map<String, Map<String, sObject>>();
        Set<String> ignoreDataFieldSet = new Set<String> ();
        
        
        System.debug ('----- Load Config Setting -----');
        for (ASI_CRM_Upload_Resources_Setting__mdt perSetting : retrievedUploadResourcesSettingList) {
            System.debug ('Checking On Field: '+ perSetting);
            objectName = perSetting.ASI_CRM_Salesforce_Object_Name__c;
            fieldList.add(perSetting.ASI_CRM_Salesforce_Field_Name__c);			
            
            // Config Is Record Key
            if (perSetting.ASI_CRM_Config_Is_Record_Key__c == true) {
                fieldKeyList.add(perSetting.ASI_CRM_Salesforce_Field_Name__c);
                fieldKeyExcelKeyMap.put (perSetting.ASI_CRM_Salesforce_Field_Name__c, perSetting.ASI_CRM_Excel_Column_Header__c);
            }
            
            // Config Is Record 
            if (perSetting.ASI_CRM_Config_Is_Record_Id__c == true) {
               recordIdFieldName = perSetting.ASI_CRM_Salesforce_Field_Name__c;
            }
            
            // Config Lookup Object && Config Lookup Key
            if (String.isNotEmpty(perSetting.ASI_CRM_Config_Lookup_Key__c)){
                String relationFieldName;
                if (perSetting.ASI_CRM_Salesforce_Field_Name__c.contains('__c')){
                    relationFieldName = perSetting.ASI_CRM_Salesforce_Field_Name__c.replace('__c', '__r');
                } else {
                    relationFieldName = perSetting.ASI_CRM_Salesforce_Field_Name__c;
                }
				relationFieldName += '.'+perSetting.ASI_CRM_Config_Lookup_Key__c;
                fieldList.add(relationFieldName); 			// use the refernce key one
                fieldKeyList.remove(fieldKeyList.size()-1); // remove id one 
                fieldKeyList.add(relationFieldName);
                fieldKeyExcelKeyMap.put (relationFieldName, perSetting.ASI_CRM_Excel_Column_Header__c);
            	
            	referenceList.add(relationFieldName);
                referenceFieldMap.put(relationFieldName, perSetting.ASI_CRM_Config_Lookup_Key__c);
                referenceObjectNameMap.put(relationFieldName, perSetting.ASI_CRM_Config_Lookup_Object__c);
            }
            
            // Config Ignore When Null
            if (perSetting.ASI_CRM_Config_Ignore_When_Null__c == true) {
            	ignoreDataFieldSet.add(perSetting.ASI_CRM_Excel_Column_Header__c);
            }
            
            // System
            if (String.isEmpty(perSetting.ASI_CRM_Excel_Column_Header__c)) {
            	systemKeySet.add(perSetting.ASI_CRM_Salesforce_Field_Name__c);
                systemKeyValueMap.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, perSetting.ASI_CRM_Config_Default_Value__c);
            }
            
        }
        System.debug ('objectName: '+ objectName);
        System.debug ('fieldList: '+ fieldList);
        System.debug ('fieldKeyList: '+ fieldKeyList);
        System.debug ('----- Load Config Setting End -----');
        
        System.debug ('----- Checking Require Key Fields From Incoming Data -----');
        System.debug ('jsonObjectList: '+jsonObjectList.size());
        
        
        for (Integer i = 0; i < jsonObjectList.size(); i++) {
            System.debug ('jsonObject[' + i + '] -- '+jsonObjectList.get(i));
            Map<String, Object> singleJsonObject = (Map<String, Object>) jsonObjectList.get(i);
            
            boolean validJsonObject = true;
            for (String singleRecordKey : fieldKeyList) {
                String excelHeaderKey = fieldKeyExcelKeyMap.get(singleRecordKey);
                
               	// KEY NOT FOUND
                if (!singleJsonObject.containsKey(excelHeaderKey)
                    && !systemKeySet.contains(singleRecordKey)) {
                    System.debug ('['+ i +'] [Pre Process] ' + singleRecordKey + '-' +excelHeaderKey +' key is not found in data');
                    
                    // Remove this logic, now bypass record if key not found    
                    System.debug ('['+ i +'] record is skipped due to key not found');
                    validJsonObject = false;  
                    break;    
                    //return createUploadResultList (i,'fail', 
                    //                               '['+ i +'] [Pre Process] ' + singleRecordKey + '-' +excelHeaderKey +' key is not found in data',
                    //                               'done'); //error of key is not found
                
                // KEY VALUE NOT FOUND
                } else if (String.isEmpty (String.valueOf(singleJsonObject.get(excelHeaderKey)))
                          && !systemKeySet.contains(singleRecordKey)) {
                    System.debug ('['+ i +'] [Pre Process] ' + singleRecordKey + '-' +excelHeaderKey + ' value is not found in data');
                    
                    // Remove this logic, now bypass record if key not found
                    System.debug ('['+ i +'] record is skipped due to key value not found');
                    validJsonObject = false;  
                    break;          
                    //return createUploadResultList (i,'fail', 
                    //                               '['+ i +'] [Pre Process] ' + singleRecordKey + '-' +excelHeaderKey + ' value is not found in data',
                    //                               'done'); //error of value is not found
                
                // KEY AND KEY VALUE FOUND
                } else {
                    String keyValueForRecordKey;
                    if (systemKeySet.contains(singleRecordKey)) {
                        keyValueForRecordKey = systemKeyValueMap.get(singleRecordKey);
                    } else {
                        keyValueForRecordKey = String.valueOf(singleJsonObject.get(excelHeaderKey));
                    } 
                    
                    if (fieldKeyValueMap.containsKey(singleRecordKey)) {
                        fieldKeyValueMap.get(singleRecordKey).add(keyValueForRecordKey);
                    } else {
                        List<String> newValueList = new List<String>();
                        newValueList.add(keyValueForRecordKey);
                        fieldKeyValueMap.put(singleRecordKey, newValueList);
                    }
                    System.debug ('Just Add: ' +fieldKeyValueMap.get(singleRecordKey));
                }
            }
            
            if (validJsonObject) {
                filterJsonObjectList.add(jsonObjectList.get(i));
            }
        }
        System.debug ('----- Checking Require Key Fields From Incoming Data End -----');
        
        System.debug ('QUERY ON EXIST DATA (Record) --------------------------------------------------------------------------------------------------------');
        String queryField = String.join(fieldList, ',');
        String queryRecordConidtion = createQueryRecordCondition (recordIdFieldName, recordId);
        String queryKeyConidtion = createQueryKeyCondition (fieldKeyValueMap);
        String query = 'SELECT Id ,' + queryField 
            			+ ' FROM ' + objectName 
            			+ ' WHERE ' + queryRecordConidtion;
        if (queryKeyConidtion != null) {
            query += ' AND ( ' + queryKeyConidtion + ' ) ';
        }
        System.debug ('Generate Query: '+ query);
        List<sObject> existingObjectList = Database.query(query);
        
        if (existingObjectList != null && existingObjectList.size() > 0) {
            System.debug ('Find Reocrd Size: '+ existingObjectList.size());
            for (sObject existingObject : existingObjectList) {
                existingObjectMapByRecordKey.put (createRecordKey(fieldKeyList, existingObject), existingObject);
            }
        } else {
            System.debug ('No Reocrd Found.');
        }	
        for (String key : existingObjectMapByRecordKey.keySet()) {
            System.debug ('key: '+ key + ' - '+ existingObjectMapByRecordKey.get(key));
        }
        System.debug ('QUERY ON EXIST DATA (Record) END --------------------------------------------------------------------------------------------------------');
        
        System.debug ('QUERY ON EXIST DATA (Reference) --------------------------------------------------------------------------------------------------------');
        for (String reference : referenceList) {
            Map<String, sObject> referenceSObjectMap = new Map<String,sObject> ();
            String referenceQueryField = referenceFieldMap.get(reference); System.debug (referenceQueryField);
            String referenceObjectName = referenceObjectNameMap.get(reference); System.debug (referenceObjectName);
            Map<String, List<String>> referenceFieldKeyValueMap = new Map<String, List<String>> ();
            referenceFieldKeyValueMap.put (referenceFieldMap.get(reference), fieldKeyValueMap.get(reference));
            String referenceQueryRecordConidtion = createQueryKeyCondition(referenceFieldKeyValueMap);
            String referenceQuery = 'SELECT Id ,' + referenceQueryField 
            						+ ' FROM ' + referenceObjectName 
            						+ ' WHERE ' + referenceQueryRecordConidtion;
            System.debug ('Generate Reference Query: '+ referenceQuery);
            List<sObject> existingReferenceObjectList = Database.query(referenceQuery);
            
            if (existingReferenceObjectList != null && existingReferenceObjectList.size() > 0) {
                System.debug ('Find Reference: '+ reference + ' - '+ existingReferenceObjectList.size());
                for (sObject singleSObject : existingReferenceObjectList) {
                    String specificObjectKey = String.valueOf(singleSObject.get(referenceQueryField));
                    referenceSObjectMap.put (specificObjectKey, singleSObject);
                }
                referenceSObjectAllMap.put (reference, referenceSObjectMap);
                System.debug ('referenceSObjectMap: '+ referenceSObjectMap);
            } else {
            	System.debug ('No Reference Found.');
        	}   
        }
        System.debug ('referenceSObjectAllMap: '+ referenceSObjectAllMap);
        System.debug ('QUERY ON EXIST DATA (Reference) END --------------------------------------------------------------------------------------------------------');
        
        
        // Process
        // ------------------------------------------------------------------------------------------------
        System.debug ('Start Processing.... --------------------------------------------------------------------------------------------------------');
        List<sObject> sObjList = new List <sObject>();
        
        for (Integer i = 0; i < filterJsonObjectList.size(); i++) {
            boolean isExistRecord = false;
            boolean skipRecord = false;
           	String skipReason = '';
            
            // Process 1 - Prepare on Incoming Data
            System.debug ('Excel Row ['+i+']----------------------------------------------------------------------------------');
        	System.debug ('jsonObject['+ i + '] -- '+filterJsonObjectList.get(i));
            Map<String, Object> singleJsonObject = (Map<String, Object>) filterJsonObjectList.get(i);
            //for (String jsonObjectKey : singleJsonObject.keySet()) {
            //    System.debug ('@@@ '+jsonObjectKey + ' --> '+ singleJsonObject.get(jsonObjectKey));
            //}
            
            System.debug ('Object Type to be create : '+((ASI_CRM_Upload_Resources_Setting__mdt) (retrievedUploadResourcesSettingList.get(0))).ASI_CRM_Salesforce_Object_Name__c);
            //sObject sObj = Schema.getGlobalDescribe().get(retrievedUploadResourcesSettingList.get(0).ASI_CRM_Salesforce_Object_Name__c).newSObject();
            sObject sObj = null;
            
            String recordKey = determineKeyFromJson(fieldKeyList, fieldKeyExcelKeyMap, singleJsonObject, systemKeyValueMap);
            sObj = existingObjectMapByRecordKey.get(recordKey);
            if (sObj == null) {
            	System.debug ('recordKey not found: '+ recordKey + ', will create a new object for insert');
               	ctype = getSObjectTypeFromCache (ctype, globalDescribe ,retrievedUploadResourcesSettingList.get(0).ASI_CRM_Salesforce_Object_Name__c);
                sObj = ctype.newSObject();
            } else {
                System.debug ('recordKey is found: '+ recordKey + ', will use existing object for update');
               	isExistRecord = true;
            }
            
            // Process 2 - Field Handling for each record
            for (ASI_CRM_Upload_Resources_Setting__mdt perSetting : retrievedUploadResourcesSettingList) {
                System.debug ('Working on ['+perSetting.ASI_CRM_Salesforce_Field_Name__c+']----------------------------------------------------------');
                
                // Ignore Trigger
                if (perSetting.ASI_CRM_Config_Ignore_When_Null__c == true && perSetting.ASI_CRM_Validation_Is_Nullable__c == true) {
                	if (String.isEmpty(String.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c)))){
                  		skipRecord = true;
                        skipReason = 'Empty Field on ' + perSetting.ASI_CRM_Excel_Column_Header__c + ' , and will be ignore';
                        break;
                    }    
                }
                
                // Validation - Nullable
                if (perSetting.ASI_CRM_Config_Is_Record_Id__c == false && perSetting.ASI_CRM_Validation_Is_Nullable__c == false) {
                    if (String.isEmpty(String.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c)))){
                        String errorMessage =' cannot be found in this reocrd ';
                        System.debug ('['+ i +'] [Validaton] ' + perSetting.ASI_CRM_Excel_Column_Header__c + errorMessage + singleJsonObject);
                        
                        uploadResultList.add(createUploadResult (i,'fail', 
                                                                 '['+ i +'] [Validaton] ' + perSetting.ASI_CRM_Excel_Column_Header__c + errorMessage,
                                                                 'done'));
                        if (isProcessAll) {
                            List<UploadResult> batchResultList = createBatchUploadResult (i , filterJsonObjectList.size(), 'fail', '[Validation] stop due to one error when isAll ', 'done');
                            uploadResultList.addall(batchResultList);
                            return uploadResultList;
                        } else {
                            skipRecord = true;
                            skipReason = 'Validaion not passed ' + perSetting.ASI_CRM_Excel_Column_Header__c + ' , because nullable';
                            break;
                        }
                    }
                }
                
                // Validation - Regexp
                if (perSetting.ASI_CRM_Validation_Regexp__c != null) {
                    Pattern acceptPattern = Pattern.compile(perSetting.ASI_CRM_Validation_Regexp__c);
                    Matcher ableToMatch = acceptPattern.matcher(String.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c)));
                    if (!ableToMatch.matches()) {
                        String errorMessage = ' cannot pass the regular expression ';
                        System.debug ('['+ i +'] [Validaton] ' + perSetting.ASI_CRM_Validation_Regexp__c + ' - '
                                      	+ perSetting.ASI_CRM_Excel_Column_Header__c + errorMessage + singleJsonObject);
                        
                        uploadResultList.add(createUploadResult (i,'fail', 
                                                                 '['+ i +'] [Validaton] ' + perSetting.ASI_CRM_Excel_Column_Header__c + errorMessage,
                                                                 'done'));
                        if (isProcessAll) {
                            List<UploadResult> batchResultList = createBatchUploadResult (i , filterJsonObjectList.size(), 'fail', '[Validation] stop due to one error when isAll ', 'done');
                            uploadResultList.addall(batchResultList);
                            return uploadResultList;
                        } else {
                    		skipRecord = true;
                            skipReason = 'Validaion not passed ' + perSetting.ASI_CRM_Excel_Column_Header__c + ' , because regexp setting';
                            break;
                        }
                    }
                }
                
                // Data - Parent Record 
                if (perSetting.ASI_CRM_Config_Is_Record_Id__c) {
                    if (!isExistRecord) {
                    	sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, recordId);
                    }    
                    continue;
                }
                
                // Data - Other 
                if (singleJsonObject.containsKey(perSetting.ASI_CRM_Excel_Column_Header__c) 
                    || String.isNotEmpty(perSetting.ASI_CRM_Config_Default_Value__c)) {
                 	//Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
                    //Schema.SObjectType ctype = globalDescribe.get(retrievedUploadResourcesSettingList.get(0).ASI_CRM_Salesforce_Object_Name__c);
                    ctype = getSObjectTypeFromCache (ctype, globalDescribe ,retrievedUploadResourcesSettingList.get(0).ASI_CRM_Salesforce_Object_Name__c);
                    //Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap();
                    fmap = getSObjectFieldMapFromCache (fmap, ctype);
                    //Schema.SobjectField sof = fmap.get(perSetting.ASI_CRM_Salesforce_Field_Name__c);
                    Schema.SobjectField sof = getSObjectFieldFromCache(fmap, perSetting.ASI_CRM_Salesforce_Field_Name__c, sObjectFieldMap);
                    
                    System.debug (perSetting.ASI_CRM_Salesforce_Field_Name__c + '---> '+sof.getDescribe().getType());
                    String dataValue;
                    if (sof.getDescribe().getType() == Schema.DisplayType.REFERENCE
                       && String.isEmpty(perSetting.ASI_CRM_Config_Default_Value__c)) {
                        //String refKey = perSetting.ASI_CRM_Salesforce_Field_Name__c;
                        String refKey = '';
                        if (perSetting.ASI_CRM_Salesforce_Field_Name__c.contains('__c')){
                    		refKey = perSetting.ASI_CRM_Salesforce_Field_Name__c.replace('__c', '__r');
                		}
						refKey += '.'+perSetting.ASI_CRM_Config_Lookup_Key__c;
                        
                    	Map<String, sObject> referenceSObjectMap = referenceSObjectAllMap.get(refKey);
                      	if (String.isNotEmpty(perSetting.ASI_CRM_Config_Lookup_Object__c) 
                            && String.isNotEmpty(perSetting.ASI_CRM_Config_Lookup_Key__c)){
                      		sObject referencesSObject = referenceSObjectMap.get(String.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c)));
                        	dataValue = referencesSObject.id;
                       	} else {
                        	dataValue = String.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c));
                        }   
                        sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, dataValue);
                    } else if (sof.getDescribe().getType() == Schema.DisplayType.STRING) {
                        if (String.isEmpty(perSetting.ASI_CRM_Config_Default_Value__c)) {
                    		dataValue = String.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c));
                        } else {
                            dataValue = String.valueOf(perSetting.ASI_CRM_Config_Default_Value__c);
                        }     
                        sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, dataValue);
                    } else if (sof.getDescribe().getType() == Schema.DisplayType.DOUBLE 
                               || sof.getDescribe().getType() == Schema.DisplayType.CURRENCY) {
                        if (String.isEmpty(perSetting.ASI_CRM_Config_Default_Value__c)) {
                        	sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, DOUBLE.valueOf(singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c)));
                    	} else {
                        	sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, String.valueOf(perSetting.ASI_CRM_Config_Default_Value__c));
                    	}  
                    } else {
                        if (String.isEmpty(perSetting.ASI_CRM_Config_Default_Value__c)) {
                        	sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, singleJsonObject.get(perSetting.ASI_CRM_Excel_Column_Header__c));
                    	} else {
                        	sObj.put(perSetting.ASI_CRM_Salesforce_Field_Name__c, String.valueOf(perSetting.ASI_CRM_Config_Default_Value__c));
                    	}  
                    }    
                }
            }
            
            
            if (skipRecord) {
                System.debug ('Skipping current reocrd now');
                continue;
            }
            
			System.debug ('sObj generated for processing: '+ sObj);
            sObjList.add(sObj);
        }
        
        System.debug ('DB Processing.... --------------------------------------------------------------------------------------------------------');
        //Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        //Schema.SObjectType ctype = globalDescribe.get(retrievedUploadResourcesSettingList.get(0).ASI_CRM_Salesforce_Object_Name__c);
        ctype = getSObjectTypeFromCache (ctype, globalDescribe ,retrievedUploadResourcesSettingList.get(0).ASI_CRM_Salesforce_Object_Name__c);
        Database.UpsertResult[] upsertResultList = dynamicUpsert(sObjList, ctype, isProcessAll);
        
        Integer upsertResultCounter = 0;
        for (Database.UpsertResult upsertResult : upsertResultList) {
            UploadResult ur = new UploadResult ();
            if (upsertResult.isSuccess()) {
                ur = createUploadResult (upsertResultCounter, 'success', 'nono', 'done');
            } else {
                Database.Error [] dberror = upsertResult.getErrors();
                ur = createUploadResult (upsertResultCounter, 'fail', dberror[0].getMessage(), 'done');
            }         
            upsertResultCounter ++;        
            uploadResultList.add(ur);
        }
        
        
        System.debug ('uploadResultList: '+uploadResultList);
        return uploadResultList;
    }
    
    
    public static Schema.SObjectType getSObjectTypeFromCache (Schema.SObjectType ctype, Map<String, Schema.SObjectType> globalDescribe, String salesObjectName) {
     	if (ctype == null) {
            System.debug ('WARNING: Get SObject type');
        	return globalDescribe.get(salesObjectName);
        }
    	return ctype;
	}
    
    public static Map<String, Schema.SobjectField> getSObjectFieldMapFromCache (Map<String, Schema.SobjectField> fmap, Schema.SObjectType ctype) {
        if (fmap == null) {
            System.debug ('WARNING: Get target sobject field map');
            return ctype.getDescribe().fields.getMap();
        }
        return fmap;
    }
    
    public static Schema.SobjectField getSObjectFieldFromCache (Map<String, Schema.SobjectField> fmap, 
                                                                String salesforceFieldName,
                                                                Map <String, Schema.SobjectField> sObjectFieldMap) 
    {
        if (sObjectFieldMap.containsKey(salesforceFieldName)) {
            return sObjectFieldMap.get(salesforceFieldName);
        }  else {
            Schema.SobjectField sof = fmap.get(salesforceFieldName);
            System.debug ('WARNING: Get target SobjectField on : '+ salesforceFieldName );
            sObjectFieldMap.put (salesforceFieldName, sof);
            return sof;
        }                                                             
    }
    
    // ------------------------------------------------------------------------------------------------
    public static List<ASI_CRM_Upload_Resources_Setting__mdt> retrieveSettingData (String uploadResourceId) {
        List<ASI_CRM_Upload_Resources_Setting__mdt> retrievedUploadResourcesSettingList = [SELECT ASI_CRM_Upload_Resources_Id__c,
                                                                    ASI_CRM_Salesforce_Object_Name__c, ASI_CRM_Salesforce_Field_Name__c,
                                                                    ASI_CRM_Excel_Column_Header__c,
                                                                    ASI_CRM_Config_Is_Record_Id__c,
                                                                    ASI_CRM_Config_Is_Record_Key__c,
                                                                    ASI_CRM_Config_Lookup_Object__c,               
                                                                    ASI_CRM_Config_Lookup_Key__c,
                                                                    ASI_CRM_Config_Ignore_When_Null__c,
                                                                    ASI_CRM_Config_Default_Value__c,
                                                                    ASI_CRM_Validation_Is_Nullable__c,
                                                                    ASI_CRM_Validation_Regexp__c
                                                           			FROM ASI_CRM_Upload_Resources_Setting__mdt
                                                                   	WHERE ASI_CRM_Upload_Resources_Id__c =: uploadResourceId];
        System.debug ('retrievedUploadResourcesSettingList: ' +retrievedUploadResourcesSettingList);
        
        if (Test.isRunningTest()) {
            return getMetataTestData();
        }
        
        return retrievedUploadResourcesSettingList;
    }

    public static List<ASI_CRM_Upload_Resources_Setting__mdt> getMetataTestData () {
        List<RecordType> rt = [SELECT Id FROM RecordType WHERE SobjectType = 'ASI_CRM_Price_And_Discount__c'];
        
        List <ASI_CRM_Upload_Resources_Setting__mdt> settingList = new List <ASI_CRM_Upload_Resources_Setting__mdt>();
        ASI_CRM_Upload_Resources_Setting__mdt uploadResouce = new ASI_CRM_Upload_Resources_Setting__mdt(
            ASI_CRM_Upload_Resources_Id__c = 'uploadresouceid',
            ASI_CRM_Salesforce_Object_Name__c = 'ASI_CRM_Price_And_Discount__c', 
            ASI_CRM_Salesforce_Field_Name__c = 'ASI_CRM_SG_Master_Rebate_Period__c',
            ASI_CRM_Excel_Column_Header__c = null,
            ASI_CRM_Config_Is_Record_Id__c = true,
            ASI_CRM_Config_Is_Record_Key__c = false,
            ASI_CRM_Config_Lookup_Object__c = null,               
            ASI_CRM_Config_Lookup_Key__c = null,
            ASI_CRM_Config_Ignore_When_Null__c = false,
            ASI_CRM_Config_Default_Value__c = null,
            ASI_CRM_Validation_Is_Nullable__c = true,
            ASI_CRM_Validation_Regexp__c = null);
		settingList.add(uploadResouce);
            
        // Record Type Record with default value
        ASI_CRM_Upload_Resources_Setting__mdt uploadResouce2 = new ASI_CRM_Upload_Resources_Setting__mdt(
            ASI_CRM_Upload_Resources_Id__c = 'uploadresouceid',
            ASI_CRM_Salesforce_Object_Name__c = 'ASI_CRM_Price_And_Discount__c', 
            ASI_CRM_Salesforce_Field_Name__c = 'RecordTypeId',
            ASI_CRM_Excel_Column_Header__c = null,
            ASI_CRM_Config_Is_Record_Id__c = false,
            ASI_CRM_Config_Is_Record_Key__c = true,
            ASI_CRM_Config_Lookup_Object__c = null,               
            ASI_CRM_Config_Lookup_Key__c = null,
            ASI_CRM_Config_Ignore_When_Null__c = false,
            ASI_CRM_Config_Default_Value__c = rt.get(0).Id,
            ASI_CRM_Validation_Is_Nullable__c = true,
            ASI_CRM_Validation_Regexp__c = null);
        settingList.add(uploadResouce2);
        
        ASI_CRM_Upload_Resources_Setting__mdt uploadResouce3 = new ASI_CRM_Upload_Resources_Setting__mdt(
            ASI_CRM_Upload_Resources_Id__c = 'uploadresouceid',
            ASI_CRM_Salesforce_Object_Name__c = 'ASI_CRM_Price_And_Discount__c', 
            ASI_CRM_Salesforce_Field_Name__c = 'ASI_CRM_SG_Product_Grouping__c',
            ASI_CRM_Excel_Column_Header__c = 'productgroup',
            ASI_CRM_Config_Is_Record_Id__c = false,
            ASI_CRM_Config_Is_Record_Key__c = true,
            ASI_CRM_Config_Lookup_Object__c = 'ASI_MFM_Item_Group__c',               
            ASI_CRM_Config_Lookup_Key__c = 'Name',
            ASI_CRM_Config_Ignore_When_Null__c = true,
            ASI_CRM_Config_Default_Value__c = null,
            ASI_CRM_Validation_Is_Nullable__c = true,
            ASI_CRM_Validation_Regexp__c = null);
        settingList.add(uploadResouce3);
        
        ASI_CRM_Upload_Resources_Setting__mdt uploadResouce4 = new ASI_CRM_Upload_Resources_Setting__mdt(
            ASI_CRM_Upload_Resources_Id__c = 'uploadresouceid',
            ASI_CRM_Salesforce_Object_Name__c = 'ASI_CRM_Price_And_Discount__c', 
            ASI_CRM_Salesforce_Field_Name__c = 'ASI_CRM_SG_Portfolio_Back_Rebate_Amount__c',
            ASI_CRM_Excel_Column_Header__c = 'rebateamount',
            ASI_CRM_Config_Is_Record_Id__c = false,
            ASI_CRM_Config_Is_Record_Key__c = false,
            ASI_CRM_Config_Lookup_Object__c = null,               
            ASI_CRM_Config_Lookup_Key__c = null,
            ASI_CRM_Config_Ignore_When_Null__c = true,
            ASI_CRM_Config_Default_Value__c = null,
            ASI_CRM_Validation_Is_Nullable__c = true,
            ASI_CRM_Validation_Regexp__c = null);
        settingList.add(uploadResouce4);
        
        ASI_CRM_Upload_Resources_Setting__mdt uploadResouce5 = new ASI_CRM_Upload_Resources_Setting__mdt(
            ASI_CRM_Upload_Resources_Id__c = 'uploadresouceid',
            ASI_CRM_Salesforce_Object_Name__c = 'ASI_CRM_Price_And_Discount__c', 
            ASI_CRM_Salesforce_Field_Name__c = 'ASI_CRM_SG_Marketing_Fund_for_sales_OO__c',
            ASI_CRM_Excel_Column_Header__c = 'market',
            ASI_CRM_Config_Is_Record_Id__c = false,
            ASI_CRM_Config_Is_Record_Key__c = false,
            ASI_CRM_Config_Lookup_Object__c = null,            
            ASI_CRM_Config_Lookup_Key__c = null,
            ASI_CRM_Config_Ignore_When_Null__c = true,
            ASI_CRM_Config_Default_Value__c = null,
            ASI_CRM_Validation_Is_Nullable__c = true,
            ASI_CRM_Validation_Regexp__c = '[0-9]');
        settingList.add(uploadResouce5);
    
        return settingList;
    }
    
    public static String createQueryRecordCondition (String sobjecttype, String recordId){
        String result;
        if (sobjecttype != null && recordId != null) {
            result = sobjecttype + ' = \'' + recordId + '\'';
        }
        System.debug ('createQueryRecordCondition: '+ result);
        return result;
    }
    public static String createQueryKeyCondition (Map<String, List<String>> fieldKeyValueMap){
        String result;
        List<String> subResult = new List<String>();
        for (String key : fieldKeyValueMap.keySet()) {
            List<String> inputDataValueList = fieldKeyValueMap.get(key);
            subResult.add(' ' + key + ' IN (\'' + String.join(inputDataValueList, '\',\'') + '\') ');
        }
        if (subResult != null && subResult.size() > 0) {
            result = String.join (subResult, ' OR ');
        } 
        System.debug ('createQueryKeyCondition: '+ result);
        return result;
        
    }
    
    public static String createRecordKey(List<String> fieldKeyList, sObject existingObject) {
        String result;
        for (String key : fieldKeyList) {
            System.debug ('Checking Sub Key: ' + key);
            if (key.contains ('.')) {
                String objectName = key.substring(0, key.indexOf('.'));
                String fieldName = key.substring(key.indexOf('.')+1, key.length());
                System.debug ('objectName: ' + objectName);
                System.debug ('fieldName: ' + fieldName);
                result += existingObject.getSObject(objectName).get(fieldName) +'_';
            } else {
                Boolean isID = existingObject.get(key) instanceOf Id;
                if (isID) {
                    String value = (String) existingObject.get(key);
                    result += value.substring(0,15) +'_';
                } else {
                	result += existingObject.get(key) +'_';
                }
            }    
        }
        System.debug ('createRecordKey: '+ result);
        return result;
    }
    public static String determineKeyFromJson (List<String> fieldKeyList, 
               								   Map<String, String> fieldKeyExcelKeyMap,
           									   Map<String, Object> singleJsonObject,
                                               Map<String, String> systemKeyValueMap) {
    	String result;
       	for (String key : fieldKeyList) {
            if (systemKeyValueMap.containsKey(key)) {
                if (key == 'RecordTypeId'){
                    result += ((String)(systemKeyValueMap.get(key))).substring(0,15) +'_';
                } else {
                    result += String.valueOf(systemKeyValueMap.get(key)) +'_';
                }
                
            } else {
                result += String.valueOf(singleJsonObject.get(fieldKeyExcelKeyMap.get(key))) +'_';
            }
        }
       	System.debug ('determineKeyFromJson: '+ result);
        return result;                                            
    }
    
    
    public static Database.UpsertResult[] dynamicUpsert(List<SObject> records, 
                                                         SObjectType sObjectType, 
                                                         Boolean isAllOrNone) 
    {
        System.debug ('Upsert Begin: '+records.size());
        Database.UpsertResult[] result;
        if (sObjectType != null) {
        	String listType = 'List<' + sObjectType + '>';
        	List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
        	castRecords.addAll(records);
     		result = Database.upsert(castRecords, isAllOrNone);
            System.debug ('Upsert End.');
            return result;
    	}
        System.debug ('Upsert End - Invalid without provided sobject type.');
        return result;
	}
    
    
    public static List<UploadResult> createUploadResultList (Integer rowNumber, String status, String errorMessage, String internalstatus){
    	List<UploadResult> resultList =  new List<UploadResult>();
        UploadResult result = createUploadResult ( rowNumber,  status,  errorMessage,  internalstatus);
    	resultList.add(result);
        return resultList;
    }
    
    public static UploadResult createUploadResult (Integer rowNumber, String status, String errorMessage, String internalstatus){
    	UploadResult result = new UploadResult();
        result.rowNumber = rowNumber;
        result.status = status;
        result.errormessage = errorMessage;
        result.internalstatus = internalstatus;
        return result;
    }

	public static List<UploadResult> createBatchUploadResult (Integer rowNumberToSkip, Integer messageSize, String status, String errorMessage, String internalstatus){
        List<UploadResult> uploadBatchResult = new List<UploadResult>();
        for (Integer i=0; i < messageSize; i++) {
            if (i == rowNumberToSkip) {
                continue;
            }
            UploadResult result = new UploadResult();
           	result.rowNumber = i;
            result.status = status;
            result.errormessage = '[' + i + '] ' + errorMessage;
            result.internalstatus = internalstatus;
            uploadBatchResult.add(result);
        }
    	return uploadBatchResult;
    }       
}