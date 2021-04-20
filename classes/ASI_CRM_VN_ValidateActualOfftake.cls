/*********************************************************************************
 * Name: ASI_CRM_VN_ValidateActualOfftake
 * Description: Block user to modify Actual Offtake when Actual Offtake is used in CS Request
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 26/02/2018       Hugo Cheung             Created          
*/
public class ASI_CRM_VN_ValidateActualOfftake {
    
    public ASI_CRM_VN_ValidateActualOfftake() {
    }
    
    public void executeTrigger(List<sObject> newList, Map<Id, sObject> oldMap) {
    	List<ASI_TH_CRM_Actual_Offtake__c> offtakeList   = (List<ASI_TH_CRM_Actual_Offtake__c>) newList;
        Map<Id, ASI_TH_CRM_Actual_Offtake__c> offtakeMap = (Map<Id, ASI_TH_CRM_Actual_Offtake__c>) oldMap;
        
        validateOfftake(offtakeList, offtakeMap);
    }
    
    public void validateOfftake(List<ASI_TH_CRM_Actual_Offtake__c> offtakeList, Map<Id, ASI_TH_CRM_Actual_Offtake__c> offtakeMap) {
        if(offtakeList == null) {
            for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakeMap.values()) {
                if(offtake.ASI_CRM_CS_Request_Item__c != null || 
                   offtake.ASI_CRM_Payment_Time__c != null) {
                    offtake.addError('Actual Offtake is linked to CS Request. Please delete CS Request before edit Actual Offtake!');
                }
            }
        } else {
            for(ASI_TH_CRM_Actual_Offtake__c offtake : offtakeList) {
                ASI_TH_CRM_Actual_Offtake__c oldOfftake = offtakeMap.get(offtake.Id);
            	if((offtake.ASI_CRM_CS_Request_Item__c == oldOfftake.ASI_CRM_CS_Request_Item__c && 
                   String.isNotBlank(offtake.ASI_CRM_CS_Request_Item__c)) || 
                   (offtake.ASI_CRM_Payment_Time__c == oldOfftake.ASI_CRM_Payment_Time__c && 
                    String.isNotBlank(offtake.ASI_CRM_Payment_Time__c))) {
                    offtake.addError('Actual Offtake is linked to CS Request. Please delete CS Request before edit Actual Offtake!');
                }
            }
        }
    }
}