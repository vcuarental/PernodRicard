public class LAT_Notification_Controller {
    public static void createNotifications(List<LAT_Notification__c> lstNotifications) {
        List<User> lstUsers = null;
        List<LAT_Notification__c> lstNotificationUsers = null;
		String strTemplateRecordType = null;
        
        System.debug('createNotifications [lstNotifications : ' + lstNotifications + '] ->');

        strTemplateRecordType = Schema.SObjectType.LAT_Notification__c.getRecordTypeInfosByDeveloperName().get('LAT_Template').getRecordTypeId() ;
        
        for(LAT_Notification__c objNotification : lstNotifications) {
            if(objNotification.RecordTypeId == strTemplateRecordType) {
                if(String.isNotBlank(objNotification.LAT_Group_Id__c)) { 
                    lstUsers = LAT_Utils.retrieveUsersInGroup(objNotification.LAT_Group_Id__c);
                } else {
                    lstUsers = LAT_Utils.retrieveUsersByCountry(objNotification.LAT_Country__c);
                } 
                
                lstNotificationUsers = retrieveNotificationsForUsers(objNotification, lstUsers);
                
                if(lstNotificationUsers != NULL && !lstNotificationUsers.isEmpty()) {
                    insert lstNotificationUsers;
                }       
            }
        }
        
        System.debug('createNotifications [] <-');
    }   
            
    private static List<LAT_Notification__c> retrieveNotificationsForUsers(LAT_Notification__c objNotification, List<User> lstUsers) {
        List<LAT_Notification__c> lstNotifications = null;
        LAT_Notification__c objNotificationUser = null;
        System.debug('retrieveUsersInCountry [objNotification : ' + objNotification + ' - lstUsers : ' + lstUsers + ' ] ->');

        lstNotifications = new List<LAT_Notification__c>();
        
        if(lstUsers != NULL && !lstUsers.IsEmpty()) {
            for(User objUser : lstUsers) {
                objNotificationUser = new LAT_Notification__c();
                objNotificationUser.Name = objNotification.Name;
                objNotificationUser.LAT_Notification_Detail__c = objNotification.LAT_Notification_Detail__c;
                objNotificationUser.LAT_User__c = objUser.Id;
            	objNotificationUser.LAT_Active__c = objNotification.LAT_Active__c;
                objNotificationUser.LAT_Country__c = objNotification.LAT_Country__c;
                objNotificationUser.LAT_Start_Date__c = objNotification.LAT_Start_Date__c;
                objNotificationUser.LAT_End_Date__c = objNotification.LAT_End_Date__c;
                objNotificationUser.LAT_Status__c = objNotification.LAT_Status__c;
                objNotificationUser.LAT_Template_Notification__c = objNotification.Id;
                objNotificationUser.RecordTypeId = Schema.SObjectType.LAT_Notification__c.getRecordTypeInfosByDeveloperName().get('LAT_Entry').getRecordTypeId();
            	
                lstNotifications.add(objNotificationUser);
            }   
        }
        
        System.debug('retrieveUsersInCountry [' + lstNotifications + '] <-');
        return lstNotifications;
    }
}