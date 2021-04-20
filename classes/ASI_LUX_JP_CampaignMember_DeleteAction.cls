/*********************************************************************************
 * Name:ASI_LUX_JP_CampaignMember_DeleteAction
 * Description: Campaign for JP LUX: Delete Campaign Contibutions based on Campaign Membeers: Trigger in Campaign Member
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 30/10/2014       Laputa: Conrad          Created
*********************************************************************************/

public with sharing class ASI_LUX_JP_CampaignMember_DeleteAction extends ASI_HK_CRM_TriggerAbstract {

    public ASI_LUX_JP_CampaignMember_DeleteAction() {
        super('ASI_LUX_JP_CampaignMember_DeleteAction');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    
        List<CampaignMember> campaignMemberList = (List<CampaignMember>)sObjList;
        Set<ID> campaignIDSet = new Set<ID>();
        Set<ID> contactIDSet = new Set<ID>();
        
        
        for(CampaignMember cmpMember : campaignMemberList){
            if (cmpMember.Status == 'Attended') {
                campaignIDSet.add(cmpMember.campaignid);
                contactIDSet.add(cmpMember.contactid);
            }
        }
        
        if (campaignIDSet.size() > 0) {
            
            List<ASI_LUX_Campaign_Contribution__c> cmpContributionToDelete = 
                                                   [
                                                       SELECT ID
                                                       FROM ASI_LUX_Campaign_Contribution__c WHERE ASI_LUX_Luxury_Campaign_Lookup__c IN : campaignIDSet 
                                                       AND ASI_LUX_Luxury_Campaign_Lookup__r.recordtypeid = : Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign')
                                                       AND ASI_LUX_Account__r.PersonContactId IN : contactIDSet
                                                   ];
                                                   
            if (cmpContributionToDelete.size() > 0) {
                delete cmpContributionToDelete;
            }
                                                   
        }
    
    }
}