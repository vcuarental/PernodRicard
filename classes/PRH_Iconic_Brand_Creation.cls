/*
  January 2017 - evolution application Le Cercle LCS-11 - no more used - replaced by evolution LCS-159 (July 2017)
  Lorsqu'une nouvelle brand est créée, celle-ci doit entrainer la création de la Competitor Brand ou Le Cercle Brand correspondante pour chaque collecte active
*/
public class PRH_Iconic_Brand_Creation extends PRH_TriggerAbstract {
    public PRH_Iconic_Brand_Creation() {
        super('PRH_Iconic_Brand_Creation');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
		
		// LCS-159 : Adding a new Brand creates this Iconic Brand in the Active status by default. 
		// This new Brand is not added to active collects.
        // It will only be taken into account when creating the collects for the following period.
        /*
        if (tAction == TriggerAction.AFTER_INSERT) {
			List<PRH_Brand_Luxury_Brand__c> newBrandList = (List<PRH_Brand_Luxury_Brand__c>)sObjList;
			List<PRH_Brand_Criteria__c> newLeCercleBRsList = new List<PRH_Brand_Criteria__c >();
			PRH_Brand_Criteria__c leCercleBrand;
			List<PRH_Competitor_Brands__c> newCompetitorBRsList = new List<PRH_Competitor_Brands__c >();
			PRH_Competitor_Brands__c compBrand;
            // Retrieve all IDs of active collects  
			List<PRH_Collect__c> activeCollects = [SELECT id, PRH_Iconic_Account__c, PRH_Active__c, PRH_Iconic_Account__r.OwnerId FROM PRH_Collect__c WHERE PRH_Active__c=true ORDER BY Name DESC];
			
			for (PRH_Brand_Luxury_Brand__c newBrand : newBrandList) {
				// Create Competitor Brand or Le Cercle Brand for each active collect
				if (activeCollects.size() > 0) {
					System.debug('PRH_Iconic_Brand_Creation, executeTriggerAction, Creation of Competitor Brand or Le Cercle Brand for Brand <' + newBrand.Name + '> for the ' + activeCollects.size() + ' active collects');
					for (PRH_Collect__c c:activeCollects) {					
						// If flag Competitor is equal to True
						if (newBrand.PRH_Competitor_Brand__c == true) {
							// Create a new Brand Competitor linked with to the active collect
							compBrand = new PRH_Competitor_Brands__c(
								PRH_Collect__c = c.id,
								PRH_Iconic_Brand__c = newBrand.id,
								OwnerId = c.PRH_Iconic_Account__r.OwnerId
							);
							newCompetitorBRsList.add(compBrand);
						} else {
							// Create a new Le Cercle Brand linked with to the active collect
							leCercleBrand = new PRH_Brand_Criteria__c(
								PRH_Brand__c = newBrand.id,
								PRH_Collect__c = c.id,
								OwnerId = c.PRH_Iconic_Account__r.OwnerId
							);
							newLeCercleBRsList.add(leCercleBrand);
						}
					}
				}
			}

			if (newCompetitorBRsList.size() > 0) {
				System.debug('PRH_Iconic_Brand_Creation, executeTriggerAction, ' + newCompetitorBRsList.size() + ' Competitor Brands are going to be created');
				insert newCompetitorBRsList;
			}
			if (newLeCercleBRsList.size() > 0) {
				System.debug('PRH_Iconic_Brand_Creation, executeTriggerAction, ' + newLeCercleBRsList.size() + ' Le Cercle Brands are going to be created');
				insert newLeCercleBRsList;
			}					
        }
        */
    }
}