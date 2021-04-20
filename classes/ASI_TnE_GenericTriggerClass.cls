/*********************************************************************************
 * Name:ASI_TnE_GenericTriggerClass
 * Description: Generic Trigger Class for TnE
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2/3/2015         Laputa: Hank            Created
 * 7/17/2017        Introv: Linus           Modified: Adding logic check Approver is whether still active when creating the manual share
*********************************************************************************/
public without sharing class ASI_TnE_GenericTriggerClass
{
    public static sObject createShareRule(sObject recordObject, String recordshare, String approverField, String reason, String accessLevel)
    {
        sObject Access =  Schema.getGlobalDescribe().get(recordShare).newSObject();
        Access.put('ParentId',  recordObject.get('id')); //Which object record to have rights
        Access.put('UserOrGroupId', recordObject.get(approverField)); //Which user to get rights
        Access.put('AccessLevel', accessLevel); //What type of rights
        Access.put('RowCause', reason) ; //Reason to get rights
        return Access;
    }
    
    // Code to grant access on the preview approver with a custom reason
    public static void assignRecordPermission(List<sObject> recordObjectList, String recordShare, String reason, String[] approverFields, Map<ID, sObject> oldMap )
    {       
        assignRecordPermission(recordObjectList, recordShare, reason, approverFields, oldMap, null);
    }
    
    // Code to grant access on the preview approver with a custom reason
    public static void assignRecordPermission(List<sObject> recordObjectList, String recordShare, String reason, String[] approverFields, Map<ID, sObject> oldMap, Map<String, String> accessLevel )
    {
                
        List<sObject> shareList = new List<sObject>(); //sharing rule of the object
        List<sObject> removeShareList = new List<sObject>(); //sharing rule of the object to be removed
        Map<ID, SObject> existingShare = new Map<ID, sObject>();
        Map<String, Integer> approvalCountMap = new Map<String, Integer>();
        Map<Id, Boolean> activeUserMap = new Map<Id, Boolean>();   // Added by 2017-07-17 Linus@introv
        
        if (oldMap != null)
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
            
            // Added by 2017-07-17 Linus@Introv
            String usersQuery = 'Select id, isActive from User where id IN :approverIds and isActive = true';            
            List<User> approverList = Database.query(usersQuery);             
                        
            for(User u: approverList){
                activeUserMap.put(u.id, u.isActive);
            }
            // END - Added by 2017-07-17 Linus@Introv
            
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
                    if ( (oldMap.get((ID)recordObject.get('id')).get(approverField)  !=  recordObject.get(approverField) || approverField == 'ASI_TnE_Payee_Employee__c' || approverField == 'ASI_TnE_Checker__c') 
                        && (approvalCountMap.get((String)recordObject.get('id')+(String)(oldMap.get((ID)recordObject.get('id')).get(approverField)) ) < 2  ))
                    {       // ^^ If the total count of approval field with more than one with the same approver
                        if (existingShare.get((ID)(oldMap.get((ID)recordObject.get('id')).get(approverField))  ) != null /* || approverField == 'ASI_TnE_Payee_Employee__c' */)
                        {
                            removeShareList.add(existingShare.get((ID)(oldMap.get((ID)recordObject.get('id')).get(approverField))  ));
                            // Decrement the total count of an approval field with more than one with the same approver
                            approvalCountMap.put((String)recordObject.get('id')+(String)(oldMap.get((ID)recordObject.get('id')).get(approverField)), 
                                                approvalCountMap.get((String)recordObject.get('id')+(String)(oldMap.get((ID)recordObject.get('id')).get(approverField))) - 1 ); 
                        }
                    }
                }
            } 
        }
          
        for(sObject recordObject : recordObjectList)
        {
            // Loop through the list of approverfields to give 
            for(String approverField : approverFields)
            {
                String accessLevelApprover;
                //Default value for all
                if(accessLevel == null)
                    accessLevelApprover = 'Read';
                else{
                    accessLevelApprover = accessLevel.get(approverField);
                    if(recordObject.get('ASI_TnE_Status__c') != 'Draft'){
                        accessLevelApprover = 'Read';
                    }
                }
                if (accessLevelApprover == null || accessLevelApprover == '')
                    accessLevelApprover = 'Read';
                
                system.debug('Check access level: ' + accessLevelApprover);
                system.debug('Check approver field: ' + recordObject.get(approverField));
                if (recordObject.get(approverField) == null) // If the approver field is null 
                    continue;
                else if ( recordObject.get(approverField) != null && oldMap == null ) // If insert
                    if(!activeUserMap.containsKey((ID)recordObject.get(approverField)) && !Test.isRunningTest())
                        continue;    // Added by 2017-7017   Linus@Introv
                    else
                        shareList.add(createShareRule(recordObject, recordshare, approverField, reason, accessLevelApprover));                                        
                else if ( oldMap.get((ID)recordObject.get('id')).get(approverField)  !=  recordObject.get(approverField) || approverField == 'ASI_TnE_Payee_Employee__c' || approverField == 'ASI_TnE_Checker__c'){ // If update and the field is updated
                    if(!activeUserMap.containsKey((ID)recordObject.get(approverField)) && !Test.isRunningTest())
                        continue;    // Added by 2017-7017   Linus@Introv
                    else
                        shareList.add(createShareRule(recordObject, recordshare, approverField, reason, accessLevelApprover));
                }
            }
        }     
        
        if (removeShareList.size() > 0)
            Database.DeleteResult[] jobShareDeleteResult = Database.delete(removeShareList,false);
        
        if (shareList.size() > 0){
            Database.SaveResult[] jobShareInsertResult = Database.insert(shareList,false);
            system.debug('Check list: ' + shareList);
            system.debug('Check result: ' + jobShareInsertResult);
        }    
        
            
    }
}