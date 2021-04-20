trigger MMPJ_Ext_Vign_Document_After_Insert on MMPJ_Ext_Vign_Documents_Fournis__c (after insert) {
    List<MMPJ_Ext_Vign_Documents_Fournis__c> documents = new List<MMPJ_Ext_Vign_Documents_Fournis__c>();
    List<MMPJ_Ext_Vign_Documents_Fournis__c> documentsUnread = new List<MMPJ_Ext_Vign_Documents_Fournis__c>();
    
    for(MMPJ_Ext_Vign_Documents_Fournis__c doc:trigger.new)
    {
        
        System.debug('## TYpe = ' + doc.MMPJ_Ext_Vign_Type__c);
        if(doc.MMPJ_Ext_Vign_Type__c == 'Brouillon de déclaration de récolte' )
            documents.add(doc);
        
        if(doc.MMPJ_Ext_Vign_Type__c == 'Questionnaire de prévision récolte' || doc.MMPJ_Ext_Vign_Type__c == 'Calendrier de Traitement' || doc.MMPJ_Ext_Vign_Type__c == 'Déclaration de récolte'  || doc.MMPJ_Ext_Vign_Type__c == 'Déclaration de fabrication')
        {
            System.debug('## Add one doc to documentsUnread');
            documentsUnread.add(doc);
        }
    }
    System.debug('## documentsUnread ' + documentsUnread);
    if(documents.size() > 0 ){
        MMPJ_Ext_Vign_Notifications.createDocumentNotification(documents); 
    }		
    
    if(documentsUnread.size() > 0 ){
        MMPJ_Ext_Vign_Documents_Notifications.createDocumentNotifications(documentsUnread); 
    }	        
}