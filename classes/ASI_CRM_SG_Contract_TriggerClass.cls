/*********************************************************************************
 * Name:        ASI_CRM_SG_Contract_TriggerClass
 * Description: N/A
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2020-03-06       Introv: Howard Fei      Created
 * Test Class: ASI_CRM_SG_ContractAfterInsertTest
*********************************************************************************/
public class ASI_CRM_SG_Contract_TriggerClass {
    public static void routineBeforeDelete(list<ASI_TH_CRM_Contract__c> trigger_old) {
        for(ASI_TH_CRM_Contract__c objContract : trigger_old) {
            if((objContract.ASI_TH_CRM_Contract_Status__c != 'Draft' && objContract.ASI_TH_CRM_Contract_Status__c != 'Contract Reject') && !ASI_MFM_ByPass_Setting.CheckingBypassByCurrentUser('ASI_CRM_SG_Contract_BeforeDelete')  ){
                objContract.addError('Only Draft Contract or Contract Reject can be deleted.');
            }
        }
    }
}