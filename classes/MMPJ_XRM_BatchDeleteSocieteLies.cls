global class MMPJ_XRM_BatchDeleteSocieteLies implements Database.Batchable<sObject>
{
    global String query;
    global Database.QueryLocator start(Database.BatchableContext bc)
    {	
    	//String dateEnd = System.now().format('yyyy-MM-dd');
        Date endDate = (Date.today() < Date.newInstance(Date.today().year(), 8, 31)) ? Date.newInstance(Date.today().year() - 1, 8, 31) : Date.newInstance(Date.today().year(), 8, 31);
        String endDateString = Datetime.newInstance(endDate, System.now().Time()).format('yyyy-MM-dd');
    	//String condDate = System.now().format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    	//String dateEnd = '2018-05-25';
        query = 'select Id,Name,MMPJ_Ext_Vign_Livreur__c,MMPJ_Ext_Vign_Courtier__c,MMPJ_XRM_Pressoir__c from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Contrat_Segmentation__c = \'Champagne\' and MMPJ_Ext_Vign_Date_de_fin_du_contrat__c <= ' + endDateString;
        System.debug('### query : ' + query);
        return Database.getQueryLocator(query);
        
    }
    
    //The execute method is called for each batch of records passed to the method. Use this method to do all required processing for each chunk of data.
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {
        System.Debug('>>>> MMPJ_XRM_BatchDeleteSocieteLies Start execute <<<<');
        
        Set<String> cles = new Set<String>();

        for(sObject s : scope)
        {
            MMPJ_Ext_Vign_Contrat__c con = (MMPJ_Ext_Vign_Contrat__c)s;
            System.debug('### contrat Name : ' + con.Name);

           if(con.MMPJ_Ext_Vign_Courtier__c != null &&  con.MMPJ_Ext_Vign_Livreur__c != con.MMPJ_Ext_Vign_Courtier__c)
				cles.add(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_Ext_Vign_Courtier__c);

			if(con.MMPJ_XRM_Pressoir__c != null && con.MMPJ_XRM_Pressoir__c != con.MMPJ_Ext_Vign_Livreur__c)
				cles.add(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_XRM_Pressoir__c);
        }
        
        System.debug('### Nb clés : ' + cles.size());

        if(cles.size() > 0 )
        {
        	List<MMPJ_XRM_RelationSociete__c> societesLies = [select MMPJ_XRM_Cle__c from MMPJ_XRM_RelationSociete__c where MMPJ_XRM_Cle__c IN:cles];
			 System.debug('### Nb relation a supprimer : ' + societesLies.size());
			if(societesLies.size() > 0)
				List<Database.DeleteResult> results = Database.delete(societesLies, false);
		}

        System.Debug('>>>> MMPJ_XRM_BatchDeleteSocieteLies End execute <<<<');
    } 

    //The finish method is called after all batches are processed. Use this method to send confirmation emails or execute post-processing operations.
    global void finish(Database.BatchableContext BC)
    {
       
    }
}