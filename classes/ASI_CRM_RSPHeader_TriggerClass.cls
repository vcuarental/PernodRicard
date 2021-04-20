/*********************************************************************************
 * Name: ASI_CRM_ContractTarget_TriggerClass
 * Description: Trigger Class for RSP Header
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2015-01-01                               Created
 */
public class ASI_CRM_RSPHeader_TriggerClass {
    
    /** Routine before deleteing header, to remove all the child records */
    public static void routineBeforeDelete(List<ASI_CRM_RSPHeader__c> trigger_old) {
        Set<id> setRSPHeader = new Set<id>();
        List<ASI_TH_CRM_RSP__c> lstRSP = new List<ASI_TH_CRM_RSP__c>();
        
        for (ASI_CRM_RSPHeader__c r : trigger_old) {
            setRSPHeader.add(r.id);
        }
        
        for (ASI_TH_CRM_RSP__c r : [SELECT id FROM ASI_TH_CRM_RSP__c WHERE ASI_CRM_RSPHeader__c IN :setRSPHeader ]) {
            lstRSP.add(r);
        }
        
        delete lstRSP;
	}
}