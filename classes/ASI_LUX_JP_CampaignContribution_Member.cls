/*********************************************************************************
 * Name:ASI_LUX_JP_CampaignContribution_Member
 * Description: Campaign for JP LUX: Generate Campaign Contibutions based on Campaign Membeers: Trigger in Campaign Member
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/10/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_JP_CampaignContribution_Member extends ASI_HK_CRM_TriggerAbstract {

    public ASI_LUX_JP_CampaignContribution_Member() {
        super('ASI_LUX_JP_CampaignContribution_Member');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        
        List<CampaignMember> campaignMemberList = (List<CampaignMember>)sObjList;
        Set<ID> campaignIDSet = new Set<ID>();
        
        // Clean the data: only retrieve the attended status
        if (oldMap == null) {
        
            for(CampaignMember cmpMember : campaignMemberList){
                if (cmpMember.Status == 'Attended') {
                    campaignIDSet.add(cmpMember.campaignid);
                }
            }
        }
        else {
            Map<ID, CampaignMember> oldcmpMemberMap = (Map<ID, CampaignMember>) oldMap;
            for(CampaignMember cmpMember : campaignMemberList){
                // Only apply logic on completed campaigns
                if(cmpMember.status == 'Attended' && cmpMember.status != oldcmpMemberMap.get(cmpMember.id).status) {
                    campaignIDSet.add(cmpMember.campaignid);
                }
            }
        }
        
        if (campaignIDSet.size() > 0) {
            
            List<Campaign> validCampaignList = [SELECT ID, status, ActualCost, ASI_LUX_Fixed_Amount__c
                                                   FROM Campaign WHERE ID IN : campaignIDSet 
                                                   AND recordtypeid = : Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign')];
            
            // Execute Campaign Contribution Generation trigger class
            if (validCampaignList.size() > 0) {
            
                List<ASI_LUX_TriggerAbstract> triggerClasses = new List<ASI_LUX_TriggerAbstract>();
                triggerClasses.add(new ASI_LUX_JP_Generate_CampaignContribution());
                for (ASI_LUX_TriggerAbstract triggerClass : triggerClasses) {
                    triggerClass.executeTriggerAction(null, validCampaignList, null, null);
                }
            }
            
        }
    
    }
    
}