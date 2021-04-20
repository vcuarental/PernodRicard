/***************************************************************************************************************************
 * Name: ASI_eForm_CustomerFormAtt_TriggerClass
 * Description: 
 * Test Class: ASI_eForm_CustomerForm_TriggerClassTest
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-08-29       Wilken Lee              Created to fix incorrect FileID for Customer Form attachment created from WebForm system
 ****************************************************************************************************************************/
public class ASI_eForm_CustomerFormAtt_TriggerClass {
    
    public static void routineBeforeInsert(list<ASI_eForm_Customer_Form_Attachment__c> trigger_new) {
        List<Id> idList = new List<Id>();
        Map<Id, Id> correctFileIDMap = new Map<Id,Id>();
        
        for (ASI_eForm_Customer_Form_Attachment__c custAttachment:trigger_new){
            if (custAttachment.ASI_eForm_FeedItemId__c == null){
                //FeedItemID is null for WebForm converted attachment. Replace incorrect FileID (prefix 069) to Correct FileID (prefix 068)
                idList.add(custAttachment.ASI_eForm_FileId__c);
            }
        }
        
        system.debug('Incorrect File ID List: ' + idList);
        if (idList.size() > 0){
            List<ContentVersion> cVersionList = [select Id, ContentDocumentId from ContentVersion where ContentDocumentId IN :idList];
            
            for (ContentVersion cVersion:cVersionList){
                correctFileIDMap.put(cVersion.ContentDocumentId, cVersion.Id);  //ContentVersion object's ID (prefix 068) is the correct ID for download link
            }
        }
        
        for (ASI_eForm_Customer_Form_Attachment__c custAttachment:trigger_new){
            if (custAttachment.ASI_eForm_FeedItemId__c == null){
                custAttachment.ASI_eForm_FileId__c = correctFileIDMap.get(custAttachment.ASI_eForm_FileId__c);
            }
        }           
    }
}