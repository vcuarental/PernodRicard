global class MMPJ_XRM_BatchSuppAnnuelleContrat implements Database.Batchable<sObject>
{
    global String query;
    global String year;
    global Database.QueryLocator start(Database.BatchableContext bc)
    {	
    	if(String.isBlank(year))
    		year = String.valueOf(Date.today().year() - 1);
    	if(String.isBlank(query))
        	query = 'select Id from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Contrat_Segmentation__c = \'Champagne\' and MMPJ_XRM_annee__c = :year';
        System.debug('### year : ' + year);
        System.debug('### query : ' + query);

        return Database.getQueryLocator(query);
        
    }
    
    //The execute method is called for each batch of records passed to the method. Use this method to do all required processing for each chunk of data.
    global void execute(Database.BatchableContext BC, list<sObject> scope)
    {
        System.Debug('>>>> MMPJ_XRM_BatchSuppAnnuelleContrat Start execute <<<<');
        if(scope.size() > 0)
        {
            //Find Societe Liees in order to delete them before deleting contracts
            Set<String> cles = new Set<String>();
            Set<Id> livreursId = new Set<Id>();
            for(MMPJ_Ext_Vign_Contrat__c con:[select Id,Name,MMPJ_Ext_Vign_Livreur__c,MMPJ_Ext_Vign_Courtier__c,MMPJ_XRM_Pressoir__c from MMPJ_Ext_Vign_Contrat__c where Id IN:scope])
            {
                System.debug('### contrat Name : ' + con.Name);

                if(con.MMPJ_Ext_Vign_Courtier__c != null &&  con.MMPJ_Ext_Vign_Livreur__c != con.MMPJ_Ext_Vign_Courtier__c)
                {
                    cles.add(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_Ext_Vign_Courtier__c);
                    livreursId.add(con.MMPJ_Ext_Vign_Livreur__c);
                }

                if(con.MMPJ_XRM_Pressoir__c != null && con.MMPJ_XRM_Pressoir__c != con.MMPJ_Ext_Vign_Livreur__c)
                {
                    cles.add(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_XRM_Pressoir__c);
                    livreursId.add(con.MMPJ_Ext_Vign_Livreur__c);
                }
            }

            if(cles.size() > 0 )
            {
                System.debug('#### cles trouvées : ' + cles.size());
                //requete des contrats des livreurs identifiés dans la requête précédente ; pour chacun vérifier si y'a une des clés. Si oui, suppression de la clé dans la liste.
                //cela permet de vérifier s'il le courtier ou pressoir n'est pas présent dans un autre contrat, pour ne pas supprimer la société lié
                for(MMPJ_Ext_Vign_Contrat__c con:[select MMPJ_Ext_Vign_Livreur__c,MMPJ_Ext_Vign_Courtier__c,MMPJ_XRM_Pressoir__c from MMPJ_Ext_Vign_Contrat__c where MMPJ_Ext_Vign_Livreur__c IN:livreursId and Id NOT IN :scope])
                {
                    if(con.MMPJ_Ext_Vign_Courtier__c != null && cles.contains(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_Ext_Vign_Courtier__c))
                        cles.remove(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_Ext_Vign_Courtier__c);
                    if(con.MMPJ_XRM_Pressoir__c != null && cles.contains(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_XRM_Pressoir__c))
                        cles.remove(con.MMPJ_Ext_Vign_Livreur__c + '' + con.MMPJ_XRM_Pressoir__c);
                }

                if(cles.size() > 0)
                {
                    System.debug('#### cles restantes : ' + cles.size());
                    List<MMPJ_XRM_RelationSociete__c> societesLies = [select MMPJ_XRM_Cle__c from MMPJ_XRM_RelationSociete__c where MMPJ_XRM_Cle__c IN:cles];
                    System.debug('### Nb relation a supprimer : ' + societesLies.size());
                    if(societesLies.size() > 0)
                        List<Database.DeleteResult> results = Database.delete(societesLies, false);
                }
            }


            //Delete Contracts
    		List<Database.DeleteResult> results = Database.delete(scope, false);
        }
        System.Debug('>>>> MMPJ_XRM_BatchSuppAnnuelleContrat End execute <<<<');
    } 

    //The finish method is called after all batches are processed. Use this method to send confirmation emails or execute post-processing operations.
    global void finish(Database.BatchableContext BC)
    {
       
    }
}