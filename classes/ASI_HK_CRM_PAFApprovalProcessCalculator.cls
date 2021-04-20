public with sharing class ASI_HK_CRM_PAFApprovalProcessCalculator extends ASI_HK_CRM_TriggerAbstract {
    
    private TriggerAction tAction;
    private Map<ID, ASI_HK_CRM_Pre_Approval_Form__c> newMap;
    private Map<ID, ASI_HK_CRM_Pre_Approval_Form__c> oldMap;
    private ASI_HK_CRM_ThresholdValues__c thresholdValueSetting;
    
    public ASI_HK_CRM_PAFApprovalProcessCalculator() {
        super('ASI_HK_CRM_PAFApprovalProcessCalculator');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)// || tAction == TriggerAction.AFTER_INSERT)
            && !isBypassByCurrentUser()) {
            List<ASI_HK_CRM_Pre_Approval_Form__c> pafList = (List<ASI_HK_CRM_Pre_Approval_Form__c>)sObjList;
            this.tAction = tAction;
            this.newMap = (Map<ID, ASI_HK_CRM_Pre_Approval_Form__c>)newMap;
            this.oldMap = (Map<ID, ASI_HK_CRM_Pre_Approval_Form__c>)oldMap;
            // Modified 20160128 copy the start/end date to adjusted date when create only
                if (tAction == TriggerAction.BEFORE_INSERT ){//|| tAction == TriggerAction.BEFORE_UPDATE) {
                    for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafList) {
                        paf.ASI_HK_CRM_Adjusted_Start_Date__c = paf.ASI_HK_CRM_PAF_Start_Date__c;
                        paf.ASI_HK_CRM_Adjusted_End_Date__c = paf.ASI_HK_CRM_PAF_End_Date__c;
                   	}
            }
                
   			Set<id> RemoveCustomerSet = new Set<id>();
            for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafList) {
                if (paf.ASI_CRM_Short_Term_Promotion__c == False) {
                    RemoveCustomerSet.add(paf.id);
                }
            }
            if (RemoveCustomerSet.size() > 0) {
                List<ASI_CRM_HK_Pre_Approval_Form_Customer__c> removecustlist = [SELECT id From ASI_CRM_HK_Pre_Approval_Form_Customer__c WHERE ASI_CRM_HK_Pre_Approval_Form__c IN: RemoveCustomerSet]; 
                if (removecustlist.size() > 0){
                    delete removecustlist;
                } 
            }
               
                
            for (ASI_HK_CRM_Pre_Approval_Form__c paf : pafList) {
                try {
                    updateThresholdCheckbox(paf, 'ASI_HK_CRM_Total_Investment_Value__c', 'ASI_HK_CRM_PAF_Investment_Amount__c', 'ASI_HK_CRM_ExceedTshInvestmentAmt__c');
                    updateThresholdCheckbox(paf, 'ASI_HK_CRM_Total_Investment__c', 'ASI_HK_CRM_PAF_Investment_Percent__c', 'ASI_HK_CRM_ExceedTshInvestmentPercent__c');
                } catch (ASI_HK_CRM_ExitException ee) {
                    throw ee;
                } catch (Exception e) {
                    paf.addError(e);
                }
            }
        }
    }
    
    private void updateThresholdCheckbox(ASI_HK_CRM_Pre_Approval_Form__c paf, String checkFN, String thresholdFN, String checkboxFN) {
        if (isChangeFieldValue(paf, checkFN)) {
            if (thresholdValueSetting == null) {
                try {
                    thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
                    if (thresholdValueSetting == null)
                        throw new ASI_HK_CRM_ExitException('Custom Setting Threshold Values (HK CRM) data is missing');
                } catch (Exception e) {
                    throw new ASI_HK_CRM_ExitException(e.getMessage());
                }
            }
            
            Object pafVal = paf.get(checkFN);
            Object thresholdVal = thresholdValueSetting.get(thresholdFN);
            Boolean shouldChecked = false;
            if (pafVal != null && thresholdVal != null) {
                if (pafVal instanceof Decimal) {
                    shouldChecked = (Decimal)pafVal >= (Decimal)thresholdVal;
                }
            }
            paf.put(checkboxFN, shouldChecked);
        }
    }
    
    private Boolean isChangeFieldValue(ASI_HK_CRM_Pre_Approval_Form__c paf, String checkFN) {
        if (tAction == TriggerAction.BEFORE_INSERT) return true;
        Object oldValue = oldMap.get(paf.Id).get(checkFN);
        Object newValue = newMap.get(paf.Id).get(checkFN);
        if (newValue != oldValue) return true;
        return false;
    }
    
    public class ASI_HK_CRM_ExitException extends Exception {
        
    }
}