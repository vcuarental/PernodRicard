/*********************************************************************************
 * Name: ASI_CRM_VN_GiftBoxRequestBeforeInsert
 * Description: Autoupdate HR User, Finance User, Marketing User of  Gift Box/POSM Request
                from Gift Box Notification User record depending upon owner of the record,
 *
 * Version History
 * Date                Developer             Comments
 * ---------------  --------------------  --------------------------------------------------------------------------------
 * 29/10/2015          Neha Sonawane         Created  
 * 02/11/2015          Neha Sonawane         Updated
 * 
*********************************************************************************/
public class ASI_CRM_VN_GiftBoxRequestBeforeInsert {

    // Method to populate HR User, Marketing User.
    public void beforeInsertPopulateHrFinanceMarketingUsers(list<ASI_GiftBox_Request_Header__c> newGiftBoxList) {
        
        set<Id> ownerIdSet = new set<Id>();
        set<string> ownerRoleset = new set<string>();
        
        for(ASI_GiftBox_Request_Header__c giftBoxObj : newGiftBoxList) {
        
            ownerIdSet.add(giftBoxObj.OwnerId);
        }
                     
        for(User userObj : [select Id, UserRole.DeveloperName
                           from User
                           where Id IN:ownerIdSet]) {
            ownerRoleset.add(userObj.UserRole.DeveloperName);        
        }
         
        List<ASI_GiftBox_Notification_User__c> giftBoxNotfUserList = [select Id,Name, HR_User__c, 
                                                                      Finance_User__c, MKT_User__c
                                                                      from ASI_GiftBox_Notification_User__c
                                                                      where RecordType.DeveloperName= 'ASI_CRM_POSM_Notification_User' AND Id IN (select Notification_Id__c 
                                                                      from ASI_GiftBox_Notification_Mapping__c 
                                                                      where ASI_GiftBox_User_Role_Name__c IN: ownerRoleset)
                                                                      limit 1];   
        
                                                                   
     if(giftBoxNotfUserList.size() != 0 && giftBoxNotfUserList[0] != null) {
           
            for(ASI_GiftBox_Request_Header__c giftBoxObj : newGiftBoxList) {

                giftBoxObj.ASI_GiftBox_HR_User__c = giftBoxNotfUserList[0].HR_User__c;
                giftBoxObj.ASI_GiftBox_Finance_User__c = giftBoxNotfUserList[0].Finance_User__c;
                giftBoxObj.ASI_GiftBox_Marketing_User__c = giftBoxNotfUserList[0].MKT_User__c;
                
        }
      }
        
    }
}