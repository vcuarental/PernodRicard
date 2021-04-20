/***************************************************************************************************************************
 * Name: ASI_eForm_GenericTriggerClass
 * Description: 
 * Test Class: ASI_eForm_GenericTriggerClassTest, ASI_eForm_ITChangeRequestAfterUpdateTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-12       Wilken Lee		        [WL 1.0] Update to use ASI Department
 ****************************************************************************************************************************/
public class ASI_eForm_GenericTriggerClass
{
    public static void validateHeaderStatus(List<SObject> validOldHeaders, String apiStatusField, Set<String> lockStatus)
    { 
                
          List<GroupMember> groupMember = [Select UserOrGroupId from GroupMember Where 
        Group.DeveloperName = 'ASI_eForm_HK_Bypass_Group' and UserOrGroupId = :UserInfo.getUserId()]; 
       
        if (groupMember == null || groupMember.size() <=0)
        {  
         for (SObject oldHeader : validOldHeaders)
        {
            String oldHeaderStatus = String.valueOf(oldHeader.get(apiStatusField));
            if (lockStatus.contains(oldHeaderStatus))
            {
                oldHeader.addError(Label.ASI_eForm_Not_Allowed_To_Delete_Record);
            }    
        }
        }     
    
    }     
   
    public static void validateDetailStatus(List<sObject> validOldDetails, Map<Id,sObject> headersMap,  
         String parentApiStatusField, String childParentLookupField, Set<String> lockStatus, String itActionStatusField)
    {
        
        for(SObject oldDetail : validOldDetails)
        {
          SObject oldHeader = headersMap.get((Id)oldDetail.get(childParentLookupField));
          
         if (oldHeader != null && itActionStatusField != null && lockStatus.contains((String)oldDetail.get(itActionStatusField)))
         {
          oldDetail.addError(Label.ASI_eForm_Not_Allowed_To_Update_Record);                       
         } else if (oldHeader != null && lockStatus.contains((String)oldHeader.get(parentApiStatusField)))
         {
          oldDetail.addError(Label.ASI_eForm_Not_Allowed_To_Delete_Record);                       
         } 
        }        
    }

     public static void validateDetailStatus(List<sObject> validOldDetails, String parentApiClass, 
         String parentApiStatusField, String childParentLookupField, Set<String> lockStatus, String itActionStatusField)
    {
        
        Set<Id> headerIds = new Set<Id>();
        for(SObject oldDetail : validOldDetails)
        {
          headerIds.add((Id)oldDetail.get(childParentLookupField));         
        }
        
        String headerQuery = ' Select Id, ' + parentApiStatusField + ' from ' + parentApiClass + ' where id in :headerIds  ';
        
        Map<Id,sObject> headersMap = new 
        Map<Id,sObject>(Database.query(headerQuery));
        
        for(SObject oldDetail : validOldDetails)
        {
          SObject oldHeader = headersMap.get((Id)oldDetail.get(childParentLookupField));
          
         if (itActionStatusField != null && lockStatus.contains((String)oldDetail.get(itActionStatusField)))
         {
            oldDetail.addError(Label.ASI_eForm_Not_Allowed_To_Update_Record);                       
         } else if (lockStatus.contains((String)oldHeader.get(parentApiStatusField)))
          {
            oldDetail.addError(Label.ASI_eForm_Not_Allowed_To_Delete_Record);          
          }
        }        
    }

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
        }
          
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
                
                if (recordObject.get(approverField) == null && oldMap == null) // If the approver field is null && in insert
                    continue;
                else if ( recordObject.get(approverField) != null && oldMap == null ) // If insert
                    shareList.add(createShareRule(recordObject, recordshare, approverField, reason, accessLevelApprover));
                else if ( oldMap.get((ID)recordObject.get('id')).get(approverField)  !=  recordObject.get(approverField)) // If update and the field is updated
                    shareList.add(createShareRule(recordObject, recordshare, approverField, reason, accessLevelApprover));
            }
        }     
     
        if (shareList.size() > 0)
            Database.SaveResult[] jobShareInsertResult = Database.insert(shareList,false);
            
        if (removeShareList.size() > 0)
            Database.DeleteResult[] jobShareDeleteResult = Database.delete(removeShareList,false);
            
    }
    
    public static OrgWideEmailAddress retrieveITServiceDesk()
    {
        OrgWideEmailAddress serviceDesk = null; 
        List<OrgWideEmailAddress> serviceDeskList = [SELECT ID, Address, DisplayName, IsAllowAllProfiles 
                                                        FROM OrgWideEmailAddress
                                                        WHERE DisplayName = : 'eForm Administrator']; // Issue #1 Fix: Change orgWideEmail from IT Service Desk to eForm Administrator
        if (serviceDeskList.size() == 1)
            serviceDesk = serviceDeskList.get(0);
            
        return serviceDesk;
        
    }
    
    public static sObject assignOwnerInfo (sObject o, Map<ID, User> userOwnerMap)
    {
        User ownerUser = userOwnerMap.get((id)o.get('ownerid'));
        
        if (ownerUser != null)
        {
            o.put('ASI_eForm_Country__c', ownerUser.country);
            o.put('ASI_eForm_Position__c', ownerUser.Title);
            o.put('ASI_eForm_Department__c', ownerUser.ASI_Department__c);	//[WL 1.0]
            o.put('ASI_eForm_Company__c', ownerUser.CompanyName); 
        }
        
        return o;
    }
    
    public static map<id, User> mapUser(List<sObject> os)
    {
        return mapUser(os, false);
    }
    
    public static map<id, User> mapUser(List<sObject> os, boolean isPreTrip)
    {
        Set<ID> ownerIDSet = new Set<ID>();
        Map<ID, User> userOwnerMap = new Map<ID, User>();
    
        for (sObject i : os)
        {
            if(i.get('ownerid') != null)
               ownerIDSet.add((id)(i.get('ownerid')));
            
            if (isPreTrip)
            {   
                if(i.get('ASI_eForm_Employee_Traveller__c') != null)
                    ownerIDSet.add((id)(i.get('ASI_eForm_Employee_Traveller__c')));
            }
        }   
    
        if (ownerIDSet.size() > 0)
            userOwnerMap = new Map<ID, User>([SELECT ID, Name, Country, Title, Department, ASI_Department__c, CompanyName, ASI_Company_Name__c,
                                                FirstName, LastName
                                                FROM User
                                                WHERE ID IN : ownerIDSet]);
        
        return userOwnerMap;
    }
    
    /*********************************************************************************
    * Description: Issue #5 20140905 Enable Items IT Action's to be changed from Complete to WIP or IT Acknowledged
    *
    * Parameter List
    * Name              Comments
    * headersMap        Map of the Header
    * lineItems         List of the line level items
    * lineItemsOldMap   List of the old values of the line level items
    * apiFieldsItems    Specific api field name for line level item: Master API Name and IT Action Field
    * apiFieldsHeader   Specific api field name for header level: IT Action Field and Status Field
    *
    * Return: Void
    * Exception: Update the header validation rules error
    *********************************************************************************/
    public static void reverseCompleteITAction(Map<Id,sObject> headersMap, List<sObject> lineItems, Map<Id,sObject> lineItemsOldMap, String apiFieldsItems, String apiFieldsHeader)
    {
        String[] parseStringItem = apiFieldsItems.split(';');
        String childToParentMaster = parseStringItem[0];
        String ITActionAPIItem = parseStringItem[1];
        
        String[] parseStringHeader = apiFieldsHeader.split(';');
        String ITActionAPIHeader = parseStringHeader[0];
        String statusAPIHeader = parseStringHeader[1];
        
        List<sObject> validLineItems = new List<sObject>();
        Map<ID, sObject> validHeadersMap = new Map<ID, sObject>();
        
        Set<ID> validHeaderIds = new Set<ID>();
        
        for(sObject lineItem : lineItems)
        {
            if( (String)(lineItemsOldMap.get(((ID)lineItem.get('ID'))).get(ITActionAPIItem)) == 'Complete' && 
                (String)lineItem.get(ITActionAPIItem) != 'Complete' && 
                (String)lineItem.get(ITActionAPIItem) != 'Invalid Submission' ) 
            {
                validHeaderIds.add((ID)(lineItem.get(childToParentMaster)));
            }
            else if ((String)lineItem.get(ITActionAPIItem) == 'Invalid Submission')
            {
                lineItem.addError(label.ASI_eForm_Complete_to_invalid);
            }
            
        }
        
        for(sObject header : headersMap.values())
        {
            if( ((String)(header.get(ITActionAPIHeader))) == 'Complete' && 
                ((String)(header.get(statusAPIHeader))) == 'Final' &&
                validHeaderIds.contains(((ID)header.get('ID') )) ) 
            {
                validHeadersMap.put(((ID)header.get('ID') ), header);
            }
        }

        List<sObject> headerToUpdate = new List<sObject>();
    
        for(sObject header : validHeadersMap.values())
        {
            header.put(ITActionAPIHeader, 'IT Acknowledged');
            headerToUpdate.add(header);
        }
        
        if(headerToUpdate.size() > 0)
        {
            try
            {
                update headerToUpdate;
            }
            catch (exception e)
            {
            }
        }
        
    }    
}