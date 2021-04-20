public class ASI_TnE_FieldHistoryComponentController {
    
    // External variables
    public SObject myObject {get; set;}
    public String childObjectName {get; set;}
    public String parentObjLookupName {get; set;} 
    
    public Integer recordLimit {get; set;}
    public static String objectLabel {get;}
    
    // Internal Variables
    public objectHistoryLine[] objectHistory; 

    public static final Map<String, Schema.SObjectType> mySObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myObjectFieldMap;
    public static List<Schema.PicklistEntry> historyFieldPicklistValues;
    
    public static final Map<String, Schema.SObjectType> myChildSObjectTypeMap = Schema.getGlobalDescribe();
    public static Map<String, Schema.SObjectField> myChildObjectFieldMap;
    public static List<Schema.PicklistEntry> childhistoryFieldPicklistValues;
    
    public List<objectHistoryLine> getObjectHistory(){

        Id myObjectId = String.valueOf(myObject.get('Id'));
        Schema.DescribeSObjectResult objectDescription = myObject.getSObjectType().getDescribe();

        myObjectFieldMap = objectDescription.fields.getMap();
        objectLabel = String.valueOf(objectDescription.getLabel());
        
        //Get the name of thew history table
        String objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if (objectDescription.isCustom()){
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';
        
        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        historyFieldPicklistValues = objectHistoryFieldField.getPickListValues();
                    
        list<objectHistoryLine> objectHistory = new list<objectHistoryLine>();
        
        String prevDate = '';
        
        if (recordLimit== null){
            recordLimit = 100;
        }
        
        list<sObject> historyList = Database.query( 'SELECT CreatedDate,'+
                                                    'CreatedById,'+
                                                    'Field,'+
                                                    'NewValue,'+
                                                    'OldValue ' +
                                                    'FROM ' + objectHistoryTableName + ' ' +
                                                    'WHERE ParentId =\'' + myObjectId + '\' ' +
                                                    'ORDER BY CreatedDate DESC '+
                                                    'LIMIT ' + String.valueOf(recordLimit));
        
        for(Integer i = 0; i < historyList.size(); i++){
            sObject historyLine = historyList.get(i);
            if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                    || (historyLine.get('newValue') != null && !(string.valueOf(historyLine.get('newValue')).startsWith('005') || string.valueOf(historyLine.get('newValue')).startsWith('00G')))
                    || (historyLine.get('oldValue') != null && !(string.valueOf(historyLine.get('oldValue')).startsWith('005') || string.valueOf(historyLine.get('oldValue')).startsWith('00G')))){
                objectHistoryLine tempHistory = new objectHistoryLine();
                // Set the Date and who performed the action
                if (String.valueOf(historyLine.get('CreatedDate')) != prevDate){
                    tempHistory.theDate = String.valueOf(historyLine.get('CreatedDate'));
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                }
                else{
                    tempHistory.theDate = '';
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                prevDate = String.valueOf(historyLine.get('CreatedDate'));
                
                // Get the field label
                String fieldLabel = ASI_TnE_FieldHistoryComponentController.returnFieldLabel(String.valueOf(historyLine.get('Field')));
                
                // Set the Action value
                   if (String.valueOf(historyLine.get('Field')) == 'created') {    // on Creation
                       tempHistory.action = 'Created.';
                  }
                  else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null){ // when deleting a value from a field
                      // Format the Date and if there's an error, catch it and re
                      try {
                         tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in <b>' + fieldLabel + '</b>.';
                    } catch (Exception e){
                         tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in <b>' + fieldLabel + '</b>.';
                    }
                  }
                  else{  // all other scenarios
                      String fromText = '';
                    if (historyLine.get('oldValue') != null) {
                         try {
                              fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
                         } catch (Exception e) {
                              fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
                         }
                    }
                    
                    String toText = '';
                    if (historyLine.get('oldValue') != null) {
                        try {
                             toText = Date.valueOf(historyLine.get('newValue')).format();
                        } catch (Exception e) {
                             toText = String.valueOf(historyLine.get('newValue'));
                        }
                    }
                    if (toText != ''){
                        tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
                    }
                    else {
                        tempHistory.action = 'Changed <b>' + fieldLabel;
                    }
                   }
                   
                   // Add to the list
                   objectHistory.add(tempHistory);
            }
         }
         
         List<Id> userIdList = new List<Id>();
         for (objectHistoryLine myHistory : objectHistory){
             userIdList.add(myHistory.userId);
         }
         Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList]);
         
         for (objectHistoryLine myHistory : objectHistory){
             if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
                 myHistory.who = userIdMap.get(myHistory.who).Name;
             }
         }
         
        //Add Child Object History Line
		String parentObjectId = String.valueOf(myObject.get('Id'));
		List<SObject> childObjects = database.query('Select Id from ' + childObjectName + ' Where ' + parentObjLookupName + ' = :parentObjectId');
		if (childObjects.size() > 0){
			for (objectHistoryLine line : getChildObjectHistory()){
				objectHistory.add(line);
			}
         }
         return objectHistory;
    }    
    
    public List<objectHistoryLine> getChildObjectHistory(){

        String parentObjectId = String.valueOf(myObject.get('Id'));
        List<SObject> childObjects = database.query('Select Id from ' + childObjectName + ' Where ' + parentObjLookupName + ' = :parentObjectId');
        System.debug('childObjects Size: ' + childObjects.size());
        
		Schema.DescribeSObjectResult objectDescription = childObjects.get(0).getSObjectType().getDescribe();
		
		List<ID> childIds = new List<ID>();
		
		if (childObjects.size() > 0){
			for (Sobject sobj : childObjects){
				System.debug('ChildObjID: ' + sobj.Id);
				childIds.add(sobj.Id);
			}
		}
		
        myChildObjectFieldMap = objectDescription.fields.getMap();
        
        //Get the name of thew history table
        String objectHistoryTableName = objectDescription.getName();
        //if we have a custom object we need to drop the 'c' off the end before adding 'History' to get the history tables name
        if (objectDescription.isCustom()){
            objectHistoryTableName = objectHistoryTableName.substring(0, objectHistoryTableName.length()-1);
        }
        objectHistoryTableName = objectHistoryTableName + 'History';
        
        Schema.DescribeFieldResult objectHistoryFieldField = mySObjectTypeMap.get(objectHistoryTableName).getDescribe().fields.getMap().get('Field').getDescribe();
        childhistoryFieldPicklistValues = objectHistoryFieldField.getPickListValues();
                    
        list<objectHistoryLine> objectHistory = new list<objectHistoryLine>();
        
        String prevDate = '';
        String created = 'created';
		
        if (recordLimit== null){
            recordLimit = 100;
        }
        
        list<sObject> historyList = Database.query( 'SELECT CreatedDate,'+
                                                    'CreatedById,'+
                                                    'Field,'+
                                                    'NewValue,'+
                                                    'OldValue ' +
                                                    'FROM ' + objectHistoryTableName + ' ' +
                                                    'WHERE ParentId = :childIds AND Field <> :created ' +
                                                    'ORDER BY CreatedDate DESC '+
                                                    'LIMIT ' + String.valueOf(recordLimit));
        
        for(Integer i = 0; i < historyList.size(); i++){
            sObject historyLine = historyList.get(i);
            if ((historyLine.get('newValue') == null && historyLine.get('oldValue') == null) 
                    || (historyLine.get('newValue') != null && !(string.valueOf(historyLine.get('newValue')).startsWith('005') || string.valueOf(historyLine.get('newValue')).startsWith('00G')))
                    || (historyLine.get('oldValue') != null && !(string.valueOf(historyLine.get('oldValue')).startsWith('005') || string.valueOf(historyLine.get('oldValue')).startsWith('00G')))){
                objectHistoryLine tempHistory = new objectHistoryLine();
                // Set the Date and who performed the action
                if (String.valueOf(historyLine.get('CreatedDate')) != prevDate){
                    tempHistory.theDate = String.valueOf(historyLine.get('CreatedDate'));
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                    tempHistory.who = String.valueOf(historyLine.get('CreatedById'));
                }
                else{
                    tempHistory.theDate = '';
                    tempHistory.who = '';
                    tempHistory.userId = String.valueOf(historyLine.get('CreatedById'));
                }
                prevDate = String.valueOf(historyLine.get('CreatedDate'));
                
                // Get the field label
                String fieldLabel = ASI_TnE_FieldHistoryComponentController.returnChildObjFieldLabel(String.valueOf(historyLine.get('Field')));
                
                // Set the Action value
                   if (String.valueOf(historyLine.get('Field')) == 'created') {    // on Creation
                       tempHistory.action = 'Created.';
                  }
                  else if (historyLine.get('oldValue') != null && historyLine.get('newValue') == null){ // when deleting a value from a field
                      // Format the Date and if there's an error, catch it and re
                      try {
                         tempHistory.action = 'Deleted ' + Date.valueOf(historyLine.get('oldValue')).format() + ' in <b>' + fieldLabel + '</b>.';
                    } catch (Exception e){
                         tempHistory.action = 'Deleted ' + String.valueOf(historyLine.get('oldValue')) + ' in <b>' + fieldLabel + '</b>.';
                    }
                  }
                  else{  // all other scenarios
                      String fromText = '';
                    if (historyLine.get('oldValue') != null) {
                         try {
                              fromText = ' from ' + Date.valueOf(historyLine.get('oldValue')).format();
                         } catch (Exception e) {
                              fromText = ' from ' + String.valueOf(historyLine.get('oldValue'));
                         }
                    }
                    
                    String toText = '';
                    if (historyLine.get('oldValue') != null) {
                        try {
                             toText = Date.valueOf(historyLine.get('newValue')).format();
                        } catch (Exception e) {
                             toText = String.valueOf(historyLine.get('newValue'));
                        }
                    }
                    if (toText != ''){
                        tempHistory.action = 'Changed <b>' + fieldLabel + '</b>' + fromText + ' to <b>' + toText + '</b>.';
                    }
                    else {
                        tempHistory.action = 'Changed <b>' + fieldLabel;
                    }
                   }
                   
                   // Add to the list
                   objectHistory.add(tempHistory);
            }
         }
         
         List<Id> userIdList = new List<Id>();
         for (objectHistoryLine myHistory : objectHistory){
             userIdList.add(myHistory.userId);
         }
         Map<Id, User> userIdMap = new Map<ID, User>([SELECT Name FROM User WHERE Id IN : userIdList]);
         
         for (objectHistoryLine myHistory : objectHistory){
             if (userIdMap.containsKey(myHistory.userId) & (myHistory.who != '') ){
                 myHistory.who = userIdMap.get(myHistory.who).Name;
             }
         }
         
         return objectHistory;
    }    
    
    // Function to return Field Label of a object field given a Field API name
    public Static String returnFieldLabel(String fieldName){

        if (ASI_TnE_FieldHistoryComponentController.myObjectFieldMap.containsKey(fieldName)){
            return ASI_TnE_FieldHistoryComponentController.myObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : historyFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }
    
     // Function to return Field Label of a object field given a Field API name
    public Static String returnChildObjFieldLabel(String fieldName){

        if (ASI_TnE_FieldHistoryComponentController.myChildObjectFieldMap.containsKey(fieldName)){
            return ASI_TnE_FieldHistoryComponentController.myChildObjectFieldMap.get(fieldName).getDescribe().getLabel();
        }
        else {
            for(Schema.PicklistEntry pickList : childhistoryFieldPicklistValues){
                if (pickList.getValue() == fieldName){
                    if (pickList.getLabel() != null){
                        return pickList.getLabel();
                    }
                    else {
                        return pickList.getValue();
                    }
                }
            }
        }
        return '';
    }
    
    // Inner Class to store the detail of the object history lines    
    public class objectHistoryLine {

        public String theDate {get; set;}
        public String who {get; set;}
        public Id userId {get; set;} 
        public String action {get; set;}
    }
}