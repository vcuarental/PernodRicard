// Le Cercle application - evolution LCS-153 - June 2017
// Scheduler for launching the batch of creation of Collects, Le Cercle Brand et Competitor brands
// There are 3 collects per year and one collect per iconic account. 
// These collects are created automatically in 2 steps in order to avoid Salesforce limitation regarding 10000 max query rows in APEX class
// Step one : launch of schedulable class PRH_BatchLeCercleCollectsCreation for deactivation of active collects and creation of new ones
// Step two : launch of schedulable class PRH_BatchLeCercleCollectsDataCreation for creation of Competitor/Le Cercle Brands linked to collects (only active Brands are taken into account)
// for creation of Competitor brands and Le Cercle brands for each new collect
// Step three : launch of schedulable class PRH_BatchUpdateCollectsCalculatedValues in order to recalculate values regarding collect's field Full Le Cercle, Nb of Pernod-Ricard product, Le Cercle Presence
global class PRH_UpdateCollectsCalculatedValues implements Database.Batchable<sObject>, Database.Stateful {
    public String Query;
	public List<PRH_Collect__c > listOfCollectsToUpdate;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('**************************** PRH_UpdateCollectsCalculatedValues Execution started ****************************');
        System.debug('--> PRH_UpdateCollectsCalculatedValues, start current date :' + system.today().format());
        
        // Define query for retrieving the list of previous collects linked to Iconic Accounts not in state suppress
        //this.Query = 'SELECT Id, PRH_Full_Active_Le_Cercle_Portfolio__c, PRH_Le_Cercle_Brand_Presence__c, PRH_Number_of_Pernod_Ricard_products__c, PRH_Iconic_Account__c FROM PRH_Collect__c WHERE PRH_Active__c=true AND PRH_Iconic_Account__c IN (SELECT id FROM PRH_Luxury_Accounts__c WHERE PRH_Suppress_and_archive__c=false)';
        this.Query = 'SELECT Id, PRH_Le_Cercle_Brand_Presence__c, PRH_Number_of_Pernod_Ricard_products__c, PRH_Iconic_Account__c FROM PRH_Collect__c WHERE PRH_Active__c=true AND PRH_Iconic_Account__c IN (SELECT id FROM PRH_Luxury_Accounts__c WHERE PRH_Suppress_and_archive__c=false)';
        System.debug('--> PRH_UpdateCollectsCalculatedValues, Query=' + this.Query);

        return Database.getQueryLocator(this.Query);
    }

    public void execute(Database.BatchableContext BC, List<PRH_Collect__c> activeCollectsList){
        PRH_Collect__c collectToUpdate;
        this.listOfCollectsToUpdate = new List<PRH_Collect__c >();
        Integer nbPernodRicardProducts;
        Boolean fullActivePortfolio;
        Boolean brandPresenceLeCercle;
        Long numberRumPresenceCollect;
        Long nbLCBPresencePortfolio;
        Long nbPresencePortfolio;

        try {
            System.debug('PRH_UpdateCollectsCalculatedValues, activeCollectsList.size=' + activeCollectsList.size());

            if (activeCollectsList.size() > 0) {
                // For all new active collects, recalculation of values Full Le Cercle, Nb of Pernod-Ricard products, Le Cercle Presence   
                for (PRH_Collect__c c:activeCollectsList) {
                	nbPernodRicardProducts = [SELECT count() FROM PRH_Brand_Criteria__c WHERE PRH_Collect__c = :c.Id AND PRH_Presence__c = true];
                	if ((nbPernodRicardProducts == 0) || (nbPernodRicardProducts == null)) {  
               			brandPresenceLeCercle = false;
            		}
            		else {
                		brandPresenceLeCercle = true;
            		}
            
		            // Search Le Cercle Brand on active collect which have Portfolio presence to true
		            List<PRH_Brand_Criteria__c> idLCBPresencePortfolio = [SELECT Id FROM PRH_Brand_Criteria__c 
		                                            					  WHERE PRH_Brand__r.PRH_Portfolio_Presence__c = true 
		                                                                  AND PRH_Collect__r.PRH_Active__c = true 
		                                                                  AND PRH_Collect__c = :c.Id
		                                                                  AND PRH_Presence__c = true 
		                                                                  AND PRH_Brand__r.PRH_Active__c = true];
            
            		// Number of Le Cercle Brand on active collect which have Portfolio presence to true
            		nbLCBPresencePortfolio = idLCBPresencePortfolio.size();
            		System.debug('PRH_UpdateCollectsCalculatedValues, nbLCBPresencePortfolio ' + nbLCBPresencePortfolio );
                     
                    // Search Le Cercle Brand on active collect which have Portfolio presence to true on iconic brand and iconic brand active
                    List<PRH_Brand_Criteria__c> idLCB = [select id from PRH_Brand_Criteria__c 
                                                        where PRH_Brand__r.PRH_Portfolio_Presence__c = true 
                                                        and PRH_Collect__r.PRH_Active__c=true 
                                                        AND PRH_Collect__c = :c.Id
                                                        and PRH_Brand__r.PRH_Active__c = true];  
                
                    // Number of Le Cercle Brand on active collect which have Portfolio presence to true on iconic brand and iconic brand active 
                    long nbidLCB = idLCB.size();                    
            		System.debug('PRH_UpdateCollectsCalculatedValues, nbidLCB ' + nbidLCB );                    
                    
		            // Search Le Cercle brand "Rum" category which have presence to true on active collect
		            List<PRH_Brand_Criteria__c> idRumPresenceCollect = [SELECT id FROM PRH_Brand_Criteria__c 
			                                                            WHERE PRH_Collect__r.PRH_Active__c = true 
			                                                            AND PRH_Collect__c = :c.Id 
			                                                            AND PRH_Brand__r.PRH_Active__c = true 
			                                                            AND PRH_Brand__r.PRH_Presence_Category__c = 'Rum'
			                                                            AND PRH_Presence__c = true];   
		            
		            // Number of le cercle brand "Rum" category which have presence to true on active collect
		            numberRumPresenceCollect = idRumPresenceCollect.size();

	            	if ((nbidLCB == nbLCBPresencePortfolio) && (nbidLCB != 0) && (numberRumPresenceCollect >= 1)) {
	                    fullActivePortfolio = true;   
	                }
	                else {
	                    fullActivePortfolio = false;  
	                }                
                    
                	collectToUpdate = new PRH_Collect__c(Id = c.Id,
	                									 PRH_Number_of_Pernod_Ricard_products__c = nbPernodRicardProducts,
	                									 //PRH_Full_Active_Le_Cercle_Portfolio__c = fullActivePortfolio,     LCS-1324
	                									 PRH_Le_Cercle_Brand_Presence__c = brandPresenceLeCercle); 
					//System.debug('==> PRH_ManageLeCercleCollectsCreation, collectToUpdate = ' + collectToUpdate);	
					this.listOfCollectsToUpdate.add(collectToUpdate);
				}
                
                if (this.listOfCollectsToUpdate.size() > 0) {
                    System.debug('--> PRH_UpdateCollectsCalculatedValues, ' + this.listOfCollectsToUpdate.size() + ' collects are going to be updated');
                    update this.listOfCollectsToUpdate;
                }
            }
        } catch (Exception e) {
            System.Debug('--> PRH_UpdateCollectsCalculatedValues, error:'+ e.getMessage());
            System.Debug('--> PRH_UpdateCollectsCalculatedValues, error:'+ e.getLineNumber());
            System.Debug('--> PRH_UpdateCollectsCalculatedValues, error:'+ e.getStackTraceString());
        }   
    }

    public void finish(Database.BatchableContext BC) {
       
    }
}