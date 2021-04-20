/*********************************************************************************
 * Name:ASI_CRM_Function
 * Description: Shared class for CRM function
 * Test Class: 	ASI_CRM_Function_Test
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2020-11-26       PRA COE                 Created
*********************************************************************************/

public with sharing class ASI_CRM_Function {
  
    @AuraEnabled(cacheable = false)
    public static List<SObject> fetchsObjectData(String soqlStatement){ 
        return database.query(soqlStatement  );
    }
    
    @AuraEnabled(cacheable = false)
    public static string  upsertObjectData(List<SObject>  sObjList, List<Id> DeletedIdList,string  recordTypeId){ 
        String UpdateStatus = 'Success';
        Boolean hasError= false;
        
        Savepoint sp = Database.setSavepoint();
        
        // delete Process
        if(DeletedIdList.size()>0){
            System.debug(' delete process');
            Database.DeleteResult[] deleteResults = Database.delete(DeletedIdList, false);
            
            for(Database.DeleteResult dr : deleteResults) {                   
                if (!dr.isSuccess()) {
                    hasError=true;
                    for(Database.Error err : dr.getErrors()) {
                        System.debug(LoggingLevel.Error, 'The following error has occurred.'  + '\n' + err.getStatusCode() + ': ' + err.getMessage()  + '\n fields that affected this error: ' + err.getFields());
                        UpdateStatus = 'The following error has occurred.'  + '\n' + err.getStatusCode() + ': ' + err.getMessage()  + '\n fields that affected this error: ' + err.getFields();
                    }
                }
            }
        }
        
        // Upsert Process
        if(sObjList.size()>0){
            system.debug(sObjList);
            for(sObject so :sObjList){
                so.put('recordTypeId', recordTypeId);
            }
            List<Database.UpsertResult> saveResults = Database.upsert(sObjList, false);
            
            for (Database.UpsertResult saveResult : saveResults) {
                if ( ! saveResult.isSuccess()) {
                    System.debug('\n\n Error on upserting record! \n');
                    
                    for(Database.Error error : saveResult.getErrors()) {
                        System.debug('\n\n The following error has occurred: ' + error.getStatusCode() + ' : ' + error.getMessage() + '\n');
                        System.debug('\n\n Object\'s fields that affected this error: ' + error.getFields() + '\n');
                        if(hasError){
                            UpdateStatus += 'Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n';
                        }else{
                            UpdateStatus = 'Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n';
                        }
                    }
                }
            }
        }
        
        if(hasError){
            Database.rollback(sp);
        }
        
        return UpdateStatus;
    }
    
    

    @AuraEnabled(cacheable = false)
    public static string  upsertsObjList(List<SObject>  sObjList){ 
        String UpdateStatus = 'Success';
        Boolean hasError= false;
        
        Savepoint sp = Database.setSavepoint();
        
        // Upsert Process
        if(sObjList.size()>0){
            List<Database.UpsertResult> saveResults = Database.upsert(sObjList, false);
            
            for (Database.UpsertResult saveResult : saveResults) {
                if ( ! saveResult.isSuccess()) {
                    System.debug('\n\n Error on upserting record! \n');
                    hasError=true;
                    for(Database.Error error : saveResult.getErrors()) {
                        System.debug('\n\n The following error has occurred: ' + error.getStatusCode() + ' : ' + error.getMessage() + '\n');
                        System.debug('\n\n Object\'s fields that affected this error: ' + error.getFields() + '\n');
                        UpdateStatus = 'Error Status: ' + error.getStatusCode() + ' ;\n' + 'Message: ' + error.getMessage() + ' ;\n' + 'Problem Fields: ' + error.getFields() + '.\n';
                    }
                }
            }
        }
        
        if(hasError){
            Database.rollback(sp);
        }
        
        return UpdateStatus;
    }
    
    
    @AuraEnabled(cacheable = false)
    public static List<fieldInfo>  GetfieldTypeList(String objType){
        List<fieldInfo> returnList = new List<fieldInfo>();
        //String objType='ASI_MFM_Plan_Line_Item__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objType);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            system.debug('fieldName' +string.valueOf(fielddataType));
            fieldInfo item = new fieldInfo();
            item.fieldName = fieldName;
            item.fieldType = string.valueOf(fielddataType);
            returnList.add(item);
        }
        return returnList;
    }
    
    public class fieldInfo {
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String fieldType { get; set; }
    }
    
    
    public static string getCreatableFieldsSOQL(String objectName, String whereClause, String extrafield){
        
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ return null; }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
        
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
            
        }
        
        if(extrafield.length() > 0)
            selects = selects + ',' + extrafield;
        
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
        
    }
    
}