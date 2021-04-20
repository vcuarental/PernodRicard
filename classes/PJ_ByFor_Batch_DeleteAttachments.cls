global class PJ_ByFor_Batch_DeleteAttachments implements Database.Batchable<sObject> {
    public String Query = 'select Id from PJ_ByFor_AttachmentFile__c';
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	List<PJ_ByFor_AttachmentFile__c> fichiers = new List<PJ_ByFor_AttachmentFile__c>();
        for(sobject s : scope)
        {
            PJ_ByFor_AttachmentFile__c f = (PJ_ByFor_AttachmentFile__c)s;
            fichiers.add(f);
        }
        
        if(fichiers.size() > 0)
        	Database.DeleteResult[] results = Database.delete(fichiers, false);
            //delete fichiers;
    }
    
    global void finish(Database.BatchableContext BC)
    {

    }
}