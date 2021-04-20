trigger LAT_Notification_Trigger on LAT_Notification__c (after insert) {
    System.debug('LAT_Notification_Trigger [] ->');
    if(Trigger.IsInsert) {
        if(Trigger.IsAfter) {
     		LAT_Notification_Controller.createNotifications(Trigger.new);       
        }        
    }    
    System.debug('LAT_Notification_Trigger [] <-');
}