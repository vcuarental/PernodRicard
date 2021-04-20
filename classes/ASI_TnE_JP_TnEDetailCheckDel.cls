/*********************************************************************************
 * Name: ASI_TnE_JP_TnEDetailCheckDel
 * Description: Only the T&E record does not linked to Call Detail can be deleted
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 06/09/2017       Hugo Cheung             Created          
*/
public class ASI_TnE_JP_TnEDetailCheckDel {
    public ASI_TnE_JP_TnEDetailCheckDel() {
    }
    
    public static void executeTrigger(List<ASI_TnE_ClaimDetail__c> claimDetailList) {
        List<ASI_TnE_ClaimDetail__c> filteredClaimDetailList = filterClaimDetail(claimDetailList);
        checkIsDeletable(filteredClaimDetailList);
    }
    
    private static List<ASI_TnE_ClaimDetail__c> filterClaimDetail(List<ASI_TnE_ClaimDetail__c> claimDetailList) {
        return claimDetailList;
    }
    
    private static void checkIsDeletable(List<ASI_TnE_ClaimDetail__c> claimDetailList) {
        Set<Id> tneDetailIdSet = new Set<Id>();
        for(ASI_TnE_ClaimDetail__c detail : claimDetailList) {
            tneDetailIdSet.add(detail.Id);
        }
        
        Map<Id, ASI_CRM_Call_Detail__c> tneCallDetailMap = new Map<Id, ASI_CRM_Call_Detail__c>();
        for(ASI_CRM_Call_Detail__c callDetail : retrieveCallPlanDetail(tneDetailIdSet)) {
            tneCallDetailMap.put(callDetail.ASI_CRM_TnE_Detail_No__c, callDetail);
        }
        
        for(ASI_TnE_ClaimDetail__c detail : claimDetailList) {
            if(tneCallDetailMap.containsKey(detail.Id)) {
                detail.addError(String.format(Label.ASI_CRM_JP_CannotDeleteTnEDetail, new String[]{tneCallDetailMap.get(detail.Id).Name}));
            }
        }
    }
    
    /***************
    Data Retrievement Function
    ***************/
    private static List<ASI_CRM_Call_Detail__c> retrieveCallPlanDetail(Set<Id> tneDetailIdSet) {
    	String query = 'SELECT Id, Name, ASI_CRM_TnE_Detail_No__c ' +  
                       'FROM ASI_CRM_Call_Detail__c ' + 
                       'Where ASI_CRM_TnE_Detail_No__c in :tneDetailIdSet';
            
        return Database.query(query);
	}
}