public class PRH_Luxury_Account_Full_Active extends PRH_TriggerAbstract{
    public PRH_Luxury_Account_Full_Active() {
        super('PRH_Luxury_Account_Full_Active');
    }
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        if (tAction == TriggerAction.AFTER_UPDATE) {
            List<ID> accIDList = new List<ID>();
            List<PRH_Brand_Criteria__c> updatedBrandCriteriaList = (List<PRH_Brand_Criteria__c>) sObjList;
            for(PRH_Brand_Criteria__c updated: updatedBrandCriteriaList){
                accIDList.add(updated.PRH_Collect__c);
            }
            System.debug('accIDList : ' + accIDList);
            List<PRH_Brand_Criteria__c> criteriaList =[Select id,PRH_Presence__c, PRH_Brand__c,PRH_Collect__c, PRH_Brand__r.PRH_Presence_Category__c From PRH_Brand_Criteria__c where PRH_Collect__c in :accIDList and PRH_Collect__r.PRH_Active__c=true];
            
            // *** WARNING *** The algoritm below must be the same as the one used in class PRH_UpdateCollectsCalculatedValues
            //Evolution LCS-170
            // New rules update for "Full Active Portfolio"(previous field name) or now "Full Le Cercle" [objet Collect PRH_Collect__c, field PRH_Full_Active_Le_Cercle_Portfolio__c ]
            // The rules to set Full Le Cercle = True has been updated. From now on, the 2 following rules must be fulfilled : 
            // 1- All Le Cercle brand must have Presence checked if iconic brand(PRH_Brand_Luxury_Brand__c) field PRH_Portfolio_Presence__c(Portfolio Presence) is true 
            // 2- One of the Le Cercle Brand “Rum“ Category must have Presence checked (PRH_Brand_Luxury_Brand__c.PRH_Presence_Category__c)
            
            Try {
            //RULE 1
                        
            // Search Le Cercle Brand on active collect which have Portfolio presence to true on iconic brand and iconic brand active
            List<PRH_Brand_Criteria__c> idLCB = [select id from PRH_Brand_Criteria__c 
                                            	where PRH_Brand__r.PRH_Portfolio_Presence__c = true 
                                                and PRH_Collect__r.PRH_Active__c=true 
                                                and PRH_Collect__c in :accIDList
                                                and PRH_Brand__r.PRH_Active__c = true];  
                
            // Number of Le Cercle Brand on active collect which have Portfolio presence to true on iconic brand and iconic brand active 
            long nbidLCB = idLCB.size();
            System.debug('Number of Le Cercle Brand which have Portfolio presence to true on iconic brand and iconic brand active nbidLCB' + nbidLCB);    
                
            // Search Le Cercle Brand on active collect which have Portfolio presence to true
            List<PRH_Brand_Criteria__c> idLCBPresencePortfolio = [select PRH_Brand__r.id from PRH_Brand_Criteria__c 
                                            					  where PRH_Brand__r.PRH_Portfolio_Presence__c = true 
                                                                  and PRH_Collect__r.PRH_Active__c=true 
                                                                  and PRH_Collect__c in :accIDList
                                                                  and  PRH_Presence__c=true 
                                                                  and PRH_Brand__r.PRH_Active__c = true];
             
                
                
            // Number of Le Cercle Brand on active collect which have Portfolio presence to true
            long nbLCBPresencePortfolio = idLCBPresencePortfolio.size();
            System.debug('Number of Le Cercle Brand on active collect which have Portfolio presence to true nbLCBPresencePortfolio ' + nbLCBPresencePortfolio );
                  
            //RULE 2           
            // Number of le cercle brand "Rum" category on active collect
        	//long numberRumCollect = idRumCollect.size();
            //System.debug('Number of le cercle brand "Rum" category on active collect numberRumCollect ' + numberRumCollect );
            
            // Search le cercle brand "Rum" category which have presence to true on active collect
            List<PRH_Brand_Criteria__c> idRumPresenceCollect =[select id from PRH_Brand_Criteria__c 
                                                           where PRH_Collect__r.PRH_Active__c=true 
                                                           and PRH_Collect__c in :accIDList 
                                                           and PRH_Brand__r.PRH_Active__c = true 
                                                           and PRH_Brand__r.PRH_Presence_Category__c='Rum'
                                                           and PRH_Presence__c=true];   
            
            // Number of le cercle brand "Rum" category which have presence to true on active collect
            long numberRumPresenceCollect = idRumPresenceCollect.size();
            System.debug('Number of le cercle brand "Rum" category which have presence to true on active collect numberRumPresenceCollect ' + numberRumPresenceCollect );
            
            
            // Search active collect to update with id of iconic account
            List<PRH_Collect__c> collectToUpdate = [Select id /*, PRH_Full_Active_Le_Cercle_Portfolio__c */ From PRH_Collect__c where ID in :accIDList];
            
            // Application of rules
            // For information if there's no portfolio presence on iconic brands PRH_Full_Active_Le_Cercle_Portfolio__c stay false
            // For information if there's no rum category on iconic brands the rule 2 is not canceled
            System.debug('nbidLCB' + nbidLCB );
            System.debug('nbLCBPresencePortfolio' + nbLCBPresencePortfolio );
            System.debug('numberRumPresenceCollect' + numberRumPresenceCollect );
            
            //Update field Full Le Cercle
            update collectToUpdate;
                
            } catch (Exception e) {
				System.Debug('--> PRH_Luxury_Account_Full_Active, error:'+ e.getMessage());
				System.Debug('--> PRH_Luxury_Account_Full_Active, error:'+ e.getLineNumber());
				System.Debug('--> PRH_Luxury_Account_Full_Active, error:'+ e.getStackTraceString());
			}   
        }
    }
}