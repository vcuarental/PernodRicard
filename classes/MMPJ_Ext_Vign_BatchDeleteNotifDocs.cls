global class MMPJ_Ext_Vign_BatchDeleteNotifDocs implements Database.Batchable<sObject>
{
    global String query;
    global DateTime createdDateStart;
    global Database.QueryLocator start(Database.BatchableContext bc)
    {	
    	//String dateEnd = System.now().format('yyyy-MM-dd');
    	if(createdDateStart == null)
       		createdDateStart = Date.today().addMonths(-3);

       	if(query == null)
        	query = 'select Id from MMPJ_Ext_Vign_Notification_Document__c where CreatedDate <= :createdDateStart and MMPJ_Ext_Vign_Lu__c=true';

        System.debug('### query : ' + query);
        return Database.getQueryLocator(query);
        
    }
    
    //The execute method is called for each batch of records passed to the method. Use this method to do all required processing for each chunk of data.
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {
        System.Debug('>>>> MMPJ_Ext_Vign_BatchDeleteNotifDocs Start execute <<<<');
        
        if(scope.size() > 0)
        	delete scope;

        System.Debug('>>>> MMPJ_Ext_Vign_BatchDeleteNotifDocs End execute <<<<');
    } 

    //The finish method is called after all batches are processed. Use this method to send confirmation emails or execute post-processing operations.
    global void finish(Database.BatchableContext BC)
    {
       
    }
}