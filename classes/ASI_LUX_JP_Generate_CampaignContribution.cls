/*********************************************************************************
 * Name:ASI_LUX_JP_Generate_CampaignContribution
 * Description: Campaign for JP LUX: Generate Campaign Contibutions based on Campaign Members once the Campaign is closed
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 08/10/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_JP_Generate_CampaignContribution extends ASI_LUX_TriggerAbstract {

    public ASI_LUX_JP_Generate_CampaignContribution() {
        super('ASI_LUX_JP_Generate_CampaignContribution');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<Campaign> campaignList = (List<Campaign>)sObjList;
        List<Campaign> validCampaignList = new List<Campaign>();
        Set<ID> campaignIDSet = new Set<ID>();
        
        if (oldMap == null) {
        
            for(Campaign cmp : campaignList){
                // Only apply logic on completed campaigns
                if(cmp.status == 'Completed') {
                    campaignIDSet.add(cmp.id);
                    validCampaignList.add(cmp);
                }
            }
        }
        else {
            Map<ID, Campaign> oldcmpMap = (Map<ID, Campaign>) oldMap;
            for(Campaign cmp : campaignList){
                // Only apply logic on completed campaigns
                if(cmp.status == 'Completed' && cmp.status != oldcmpMap.get(cmp.id).status) {
                    campaignIDSet.add(cmp.id);
                    validCampaignList.add(cmp);
                }
            }
        }
        
        // Continue Campaign Contribution generation Logic if only theres any valid campaigns
        if(campaignIDSet.size() > 0) {
        
            List<Campaign> campaignToMemberList = [SELECT ID, status, ActualCost, ASI_LUX_Fixed_Amount__c,
                                                        (SELECT ID, Contactid, Campaignid FROM campaignMembers WHERE Status = 'Attended') //Filter only those who attended
                                                     FROM Campaign WHERE ID IN : campaignIDSet];
            
            Set<ID> contactIDSet = new Set<ID>();
            
            for(Campaign cmp: campaignToMemberList){
                for(campaignMember cmpMember : cmp.campaignMembers) {
                    contactIDSet.add(cmpMember.Contactid);
                }
            }
            
            if(contactIDSet.size() > 0)
            {
            
                Map<ID, Contact> ctntMap = new Map<ID, Contact>([SELECT ID, AccountID FROM Contact WHERE ID IN : contactIDSet]);
                List<ASI_LUX_Campaign_Contribution__c> cmpContributionToInsert = new List<ASI_LUX_Campaign_Contribution__c>();
                
                for(Campaign cmp : campaignToMemberList) {
                    
                    List<campaignMember> cmpMemberList = cmp.campaignMembers;
                    // Continue Campaign Contribution generation Logic if only theres any members who attended
                    if(cmpMemberList.size() > 0) {
                    
                        //Integer average = cmpMemberList.size();
                        
                        //Core Logic: Create Campaign Contributions
                        for(campaignMember cmpMember : cmpMemberList) {
                            if (cmp.ASI_LUX_Fixed_Amount__c != null && cmp.ASI_LUX_Fixed_Amount__c != 0) {
                            
                                Decimal contributionAmount = (cmp.ASI_LUX_Fixed_Amount__c == null ? 0 : cmp.ASI_LUX_Fixed_Amount__c);
                                ID accID = ctntMap.get(cmpMember.Contactid).accountID;
                            
                                ASI_LUX_Campaign_Contribution__c cmpContribution = new ASI_LUX_Campaign_Contribution__c (
                                    RecordTypeid = Global_RecordTypeCache.getRtId('ASI_LUX_Campaign_Contribution__cASI_LUX_JP_Campaign_Contribution'),
                                    ASI_LUX_Contribution_Amount__c = contributionAmount,
                                    ASI_LUX_Account__c = accID,
                                    ASI_LUX_Luxury_Campaign_Lookup__c = cmp.id,
                                    CurrencyIsoCode = 'JPY'
                                );
                                cmpContributionToInsert.add(cmpContribution);
                            }
                        }
                   }
                }
                
                // Generate the campaign contributions
                if (cmpContributionToInsert.size() > 0) {
                    insert cmpContributionToInsert;
                }
                
            }
        }
    }
}