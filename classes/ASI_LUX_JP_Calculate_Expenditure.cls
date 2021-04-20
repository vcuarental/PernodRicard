/*********************************************************************************
 * Name:ASI_LUX_JP_Calculate_Expenditure
 * Description: Calculate Expenditure for Campaign Contribution, specific for JP LUX
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/10/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_JP_Calculate_Expenditure extends ASI_LUX_TriggerAbstract {

    public ASI_LUX_JP_Calculate_Expenditure() {
        super('ASI_LUX_JP_Calculate_Expenditure');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<ASI_LUX_Campaign_Contribution__c> validCampaignContributions = new List<ASI_LUX_Campaign_Contribution__c>();
        
        if(oldMap == null) {
            validCampaignContributions = (List<ASI_LUX_Campaign_Contribution__c>)sObjList;
        } 
        else {
            
            Map<ID, ASI_LUX_Campaign_Contribution__c> cmpContributionMap = (Map<ID, ASI_LUX_Campaign_Contribution__c>) oldmap;
            
            for(ASI_LUX_Campaign_Contribution__c cmpCon : (List<ASI_LUX_Campaign_Contribution__c>)sObjList) {
                // Only filter out the sales order where the Amount or Order Date has been updated: only applies for after update
                if((cmpCon.ASI_LUX_Luxury_Campaign_Lookup__c != cmpContributionMap.get(cmpCon.id).ASI_LUX_Luxury_Campaign_Lookup__c)
                    || cmpCon.ASI_LUX_Account__c != cmpContributionMap.get(cmpCon.id).ASI_LUX_Account__c
                    || cmpCon.ASI_LUX_Contribution_Amount__c != cmpContributionMap.get(cmpCon.id).ASI_LUX_Contribution_Amount__c ){
                        validCampaignContributions.add(cmpCon);
                    }
            }
            
        }
        
        //Calculate Expenditure for the related Account
        if (validCampaignContributions.size() > 0)
        {
            // Related Accounts to be Updated
            Set<ID> accIDSet = new Set<ID>();
            // loop through the trigger new items to output error if there is no existing running number for Campaign Contribution
            for(ASI_LUX_Campaign_Contribution__c cmpCon : validCampaignContributions) {
                
                if(cmpCon.ASI_LUX_Account__c != null) {
                    accIDSet.add(cmpCon.ASI_LUX_Account__c);
                }
            }
        
            // Calculate Date interval for the past 12 months Order Amount Calculation
            Date endDate = Date.newInstance(date.today().year(), date.today().month(), 1);
            Date startDate = endDate.addMonths(-12);
            endDate = date.today();
        
            // Retrieve the related Contact accordingly
            Map<ID, Contact> ctntMap = new Map<ID, Contact>([
                                                                SELECT ID, firstname, lastname, recordtypeid, accountID,
                                                                ASI_LUX_Amount_spend_P12M__c, ASI_LUX_Amount_spend_Total__c,
                                                                ASI_LUX_Number_of_attended_events_P12M__c, ASI_LUX_Number_of_attended_events_Total__c
                                                                FROM Contact WHERE accountID IN : accIDSet
                                                            ]);
                                                                
            // Retrieve the related account accordingly
            Map<ID, Account> accountMap = new Map<ID, Account>([
                                                                SELECT ID, firstname, lastname, recordtypeid,
                                                                    (
                                                                        SELECT ASI_LUX_Contribution_Amount__c,
                                                                        ASI_LUX_Luxury_Campaign_Lookup__c,
                                                                        ASI_LUX_Luxury_Campaign_Lookup__r.StartDate,
                                                                        ASI_LUX_Luxury_Campaign_Lookup__r.EndDate
                                                                        FROM Campaign_Contributions__r
                                                                        WHERE 
                                                                        ASI_LUX_Luxury_Campaign_Lookup__r.StartDate <> NULL
                                                                        AND ASI_LUX_Luxury_Campaign_Lookup__r.EndDate <> NULL
                                                                    )
                                                                FROM account WHERE ID IN : accIDSet
                                                               ]);
            List<Contact> ctntToUpdate = new List<Contact>();
                                                              
            // Core Logic
            for (Contact ctnt : ctntMap.values()) {
                
                Account acc = accountMap.get(ctnt.accountID);
                List<ASI_LUX_Campaign_Contribution__c> cmpContributionList = acc.Campaign_Contributions__r;
                Decimal totalAmount = 0;
                Decimal totalPast12Amount = 0;
                
                for (ASI_LUX_Campaign_Contribution__c cmpContribution : cmpContributionList) {
                    
                    totalAmount += (cmpContribution.ASI_LUX_Contribution_Amount__c != null ) ? cmpContribution.ASI_LUX_Contribution_Amount__c : 0;
                    
                    if (startDate <= cmpContribution.ASI_LUX_Luxury_Campaign_Lookup__r.EndDate 
                            && endDate >= cmpContribution.ASI_LUX_Luxury_Campaign_Lookup__r.EndDate) {
                        
                        totalPast12Amount += (cmpContribution.ASI_LUX_Contribution_Amount__c != null ) ? cmpContribution.ASI_LUX_Contribution_Amount__c : 0;
                    }
                }
                
                if (ctnt.ASI_LUX_Amount_spend_P12M__c != totalPast12Amount || ctnt.ASI_LUX_Amount_spend_Total__c != totalAmount) {
                    Contact ctntUpdate = new Contact (id = ctnt.id);
                    ctntUpdate.ASI_LUX_Amount_spend_P12M__c = totalPast12Amount;
                    ctntUpdate.ASI_LUX_Amount_spend_Total__c = totalAmount;
                    ctntToUpdate.add(ctntUpdate);
                }
            }
            
            if (ctntToUpdate.size() > 0) {
                update ctntToUpdate;
            }
             
        }
    
    }

}