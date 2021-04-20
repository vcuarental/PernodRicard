public class ASI_GiftBox_RequestHeaderTriggerClass {
    public static void routineBeforeUpdate(list<ASI_GiftBox_Request_Header__c> trigger_new) {
        for (ASI_GiftBox_Request_Header__c header :trigger_new){
            if (header.ASI_GiftBox_Status__c != 'Open'){
                List<ASI_GiftBox_Request_Item__c> requestItemList = [select ASI_GiftBox_Request_Item__c from ASI_GiftBox_Request_Item__c where ASI_GiftBox_Request_Id__c = :header.id];
                for (ASI_GiftBox_Request_Item__c i :requestItemList){
                    ASI_GiftBox_RequestItemTriggerClass.calRequestedQuantity(i.ASI_GiftBox_Request_Item__c);
                }
            }
        }
    }

    public static void routineAfterInsert(list<ASI_GiftBox_Request_Header__c> trigger_new) {
        //Assign Apex Sharing Rule to Approvers and Finance
        assignRecordPermission(trigger_new, 'ASI_GiftBox_Request_Header__Share','ASI_GiftBox_VN_Request_Approver__c',new String[] {'ASI_GiftBox_Sales_Manager__c', 'ASI_GiftBox_Finance_User__c'}, null,null);

    }

    public static void routineBeforeInsert(list<ASI_GiftBox_Request_Header__c> trigger_new) {
        //Default Request Region   
        User currentUser = [select ASI_KOR_User_Region_Name__c from user where id = :UserInfo.getUserId()].get(0);
        Set<ID> ownerIDSet = new Set<ID>();

        for (ASI_GiftBox_Request_Header__c header :trigger_new){
            if (Global_RecordTypeCache.getRt(header.recordTypeId).developerName.contains('ASI_GiftBox_VN')){
                //Default Request Fiscal Year
                if (system.today().month()<=6){
                    header.ASI_GiftBox_Fiscal_Year__c = 'FY'+ String.valueOf(system.today().year()-1).right(2) + String.valueOf(system.today().year()).right(2);
                }
                else{
                    header.ASI_GiftBox_Fiscal_Year__c = 'FY'+ String.valueOf(system.today().year()).right(2) + String.valueOf(system.today().year()+1).right(2);
                }            

                header.ASI_GiftBox_Region__c = currentUser.ASI_KOR_User_Region_Name__c;

                ownerIDSet.add(header.ownerID);
            }
        }

        if (ownerIDSet.size() > 0){
            Map<ID, ASI_GiftBox_Notification_Mapping__c> approverMap = new Map<ID,ASI_GiftBox_Notification_Mapping__c>();

            for (ASI_GiftBox_Notification_Mapping__c approver:[select id, ASI_GiftBox_Finance_User_ID__c, ASI_GiftBox_Sales_Manager_ID__c, ASI_GiftBox_Sales_Representative__c from ASI_GiftBox_Notification_Mapping__c where ASI_GiftBox_Sales_Representative__c = :ownerIDSet]){
                approverMap.put(approver.ASI_GiftBox_Sales_Representative__c, approver);
            }

            for (ASI_GiftBox_Request_Header__c req :trigger_new){
                if (approverMap.get(req.ownerID) != null && approverMap.get(req.ownerID).ASI_GiftBox_Finance_User_ID__c != null && approverMap.get(req.ownerID).ASI_GiftBox_Sales_Manager_ID__c != null){
                    req.ASI_GiftBox_Sales_Manager__c = approverMap.get(req.ownerID).ASI_GiftBox_Sales_Manager_ID__c;
                    req.ASI_GiftBox_Finance_User__c = approverMap.get(req.ownerID).ASI_GiftBox_Finance_User_ID__c;
                }
            }
        }
    }

    public static sObject createShareRule(sObject recordObject, String recordshare, String approverField, String reason, String accessLevel){
        sObject Access =  Schema.getGlobalDescribe().get(recordShare).newSObject();
        Access.put('ParentId',  recordObject.get('id')); //Which object record to have rights
        Access.put('UserOrGroupId', recordObject.get(approverField)); //Which user to get rights
        Access.put('AccessLevel', accessLevel); //What type of rights
        Access.put('RowCause', reason) ; //Reason to get rights

        system.debug('Access record: ' + Access);
        return Access;
    }

    // Code to grant access on the preview approver with a custom reason
    public static void assignRecordPermission(List<sObject> recordObjectList, String recordShare, String reason, String[] approverFields, Map<ID, sObject> oldMap, Map<String, String> accessLevel )
    {

        List<sObject> shareList = new List<sObject>(); //sharing rule of the object
        List<sObject> removeShareList = new List<sObject>(); //sharing rule of the object to be removed
        Map<ID, SObject> existingShare = new Map<ID, sObject>();
        Map<String, Integer> approvalCountMap = new Map<String, Integer>();

        /*if (oldMap != null)
        {
            Set<ID> approverIDs = new Set<ID>();
            Set<ID> recordIds = new Set<ID>();

            for (sObject recordObject : oldMap.values())
            {
                for (String approverField : approverFields)
                {
                    // To avoid erroneous deletion of Approver field the same approvers
                    if (approvalCountMap.containsKey((String)recordObject.get('id')+(String)recordObject.get(approverField) ) )
                        approvalCountMap.put((String)recordObject.get('id')+(String)recordObject.get(approverField), 
                                                approvalCountMap.get((String)recordObject.get('id')+(String)recordObject.get(approverField) ) + 1 ); //Increment the number of fields with the same approver id
                    else // If the approval is new, create a new approval map count
                        approvalCountMap.put((String)recordObject.get('id')+(String)recordObject.get(approverField), 1 );

                    if ((ID)recordObject.get(approverField) != null)
                        approverIDs.add((ID)recordObject.get(approverField));
                }
                recordIds.add((ID)recordObject.get('id'));
            }

            String shareQuery = ' Select Id, ParentID, UserOrGroupId, RowCause from ' + recordShare + ' where ParentID in :recordIds AND UserOrGroupId IN: approverIDs AND RowCause =: reason ';


            List<sObject> existShares = Database.query(shareQuery);


            for(sObject shareItem : existShares)
            {
                //removeShareList.add(shareItem);
                // Delete duplicates
                if (existingShare.containsKey((ID)shareItem.get('UserOrGroupId')))
                    removeShareList.add(shareItem);
                else
                    existingShare.put((ID)shareItem.get('UserOrGroupId'), shareItem);
            }

            for (sObject recordObject : recordObjectList)
            {
                // Loop through the list of approverfields to give 
                for(String approverField : approverFields)
                {
                    // Delete the old approver shared objects to avoid duplicate
                    if ( (oldMap.get((ID)recordObject.get('id')).get(approverField)  !=  recordObject.get(approverField) ) 
                        && (approvalCountMap.get((String)recordObject.get('id')+(String)(oldMap.get((ID)recordObject.get('id')).get(approverField)) ) < 2  ))
                    {       // ^^ If the total count of approval field with more than one with the same approver
                        if (existingShare.get((ID)(oldMap.get((ID)recordObject.get('id')).get(approverField))  ) != null)
                        {
                            removeShareList.add(existingShare.get((ID)(oldMap.get((ID)recordObject.get('id')).get(approverField))  ));
                            // Decrement the total count of an approval field with more than one with the same approver
                            approvalCountMap.put((String)recordObject.get('id')+(String)(oldMap.get((ID)recordObject.get('id')).get(approverField)), 
                                                approvalCountMap.get((String)recordObject.get('id')+(String)(oldMap.get((ID)recordObject.get('id')).get(approverField))) - 1 ); 
                        }
                    }
                }
            } 
        }*/

        for(sObject recordObject : recordObjectList)
        {
            // Loop through the list of approverfields to give 
            for(String approverField : approverFields)
            {
                String accessLevelApprover;
                //Default value for all
                if(accessLevel == null)
                    accessLevelApprover = 'read';
                else
                    accessLevelApprover = accessLevel.get(approverField);

                if (accessLevelApprover == null || accessLevelApprover == '')
                    accessLevelApprover = 'read';

                system.debug('accessLevelApprover: ' + accessLevelApprover + ' approver field: ' + approverField +  ' record approver field : ' + recordObject.get(approverField));
                if (recordObject.get(approverField) == null && oldMap == null) // If the approver field is null && in insert
                    continue;
                else if ( recordObject.get(approverField) != null && oldMap == null ) // If insert
                    shareList.add(createShareRule(recordObject, recordshare, approverField, reason, accessLevelApprover));
                else if ( oldMap.get((ID)recordObject.get('id')).get(approverField)  !=  recordObject.get(approverField)) // If update and the field is updated
                    shareList.add(createShareRule(recordObject, recordshare, approverField, reason, accessLevelApprover));
            }
        }     
        system.debug('Share List Size: ' + shareList.size());

        if (shareList.size() > 0){
            Database.SaveResult[] jobShareInsertResult = Database.insert(shareList,false);

            for (Database.SaveResult sr : jobShareInsertResult) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted record. Record ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Record fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        if (removeShareList.size() > 0)
            Database.DeleteResult[] jobShareDeleteResult = Database.delete(removeShareList,false);

    }
    
        public static void routineBeforeDelete(list<ASI_GiftBox_Request_Header__c> trigger_old) {
        for (ASI_GiftBox_Request_Header__c header : trigger_old){

            if (header.ASI_GiftBox_Status__c!='Open'){
                header.addError('Not allowed to delete because the Request is not in \'Open\' status');
                break;
            }
        }
    }
}