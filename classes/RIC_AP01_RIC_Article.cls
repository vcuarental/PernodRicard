public class RIC_AP01_RIC_Article {
    
    public static void unlockRecordBeforeUpdate(List<RIC_Article__c> listUpdatedRICArticles, Map<Id,RIC_Article__c> oldMap) {
        for(RIC_Article__c ricArticle : listUpdatedRICArticles){
           	
            if(oldMap.get(ricArticle.Id).RIC_Tech_isLocked__c 
               && (!String.isBlank(ricArticle.RIC_Tech_LockingUser__c) 
                   && ricArticle.RIC_Tech_LockingUser__c.equals(UserInfo.getUserId()) && (ricArticle.RIC_Tech_LockingUser__c.equals(oldMap.get(ricArticle.Id).RIC_Tech_LockingUser__c)))) {
                ricArticle.RIC_Tech_isLocked__c = false;
                ricArticle.RIC_Tech_LockDateTIme__c = null;
                ricArticle.RIC_Tech_LockingUser__c = '';
            }
        }
    }
    
    public static void updateTechChangedFiels(List<RIC_Article__c> listUpdatedRICArticles, Map<Id,RIC_Article__c> oldMap) {
        
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.RIC_Article__c.fields.getMap();
        for(RIC_Article__c ricArticle : listUpdatedRICArticles) {
            RIC_Article__c oldRicArticle = oldMap.get(ricArticle.Id);
            String changedFields = '';
            for (String fieldName : mapFields.keyset()){
                if(!fieldName.containsIgnoreCase('tech_') && !fieldName.containsIgnoreCase('RIC_Editable')) { //Ensure that the changed field is not a tech field
                    if(ricArticle.get(fieldName) != oldRicArticle.get(fieldName)) {
                        if(changedFields.length() == 0)
                            changedFields += mapFields.get(fieldName).getDescribe().getLabel();
                        else
                            changedFields += ', ' + mapFields.get(fieldName).getDescribe().getLabel();
                    }   
                }
            }
            System.debug('####changedFields: ' + changedFields);
            if(String.isNotBlank(changedFields))
            	ricArticle.RIC_TECH_ChangedFields__c = changedFields;
            else
                ricArticle.RIC_TECH_ChangedFields__c = null;
        }
    }
    
    //Envoyer un mail au Groupe RCTA avec la liste des modifications sur la ficher article, n'importe quelle est la modification
    public static void notifyRTCAOnArticleUpdate(List<RIC_Article__c> listUpdatedRICArticles, Map<Id,RIC_Article__c> oldMap) {
        
        Set<Id> userIds = getUsersIdsFromGroup(Label.RIC_RCTA_Group_Id);
        List<String> changedRICArticleIds = new List<String>();
        
        for(RIC_Article__c ricArticle : listUpdatedRICArticles) {
            
            RIC_Article__c oldRicArticle = oldMap.get(ricArticle.Id);
            if(String.isNotBlank(ricArticle.RIC_TECH_ChangedFields__c)){
                changedRICArticleIds.add(ricArticle.Id);
            }
        }
        sendEmailToUsersList(userIds, Label.RIC_RCTA_Article_Changed_Notif_ID, changedRICArticleIds);
    }
    
    public static void sendEmailToUsersList(Set<Id> listUserIds, String emailTemplateId, List<String> listTargetRecordIds) {
        
        List<Messaging.SingleEmailMessage> allmsgs = new List<Messaging.SingleEmailMessage>();
        for(String tagretId: listTargetRecordIds) {
            //For each target record, send the email to the list of users
            for(String userId : listUserIds) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setWhatId(tagretId);
                mail.setTreatTargetObjectAsRecipient(true);
                mail.setTargetObjectId(userId);
                mail.setTemplateId(emailTemplateId);
                mail.setSaveAsActivity(false);
                allmsgs.add(mail);
            }
        }
        Messaging.sendEmail(allmsgs, false);
    }
    
    public static Set<Id> getUsersIdsFromGroup(String groupId) {
        
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();
        
        // Loop through all group members in a group
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId]) {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType)) {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType)) {
                // Call this function again but pass in the group found within this group
                result.addAll(getUsersIdsFromGroup(m.UserOrGroupId));
            }
        }
        return result; 
    }
}