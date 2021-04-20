public with sharing class ASI_HK_CRM_SalesOrderApprovalCalculator extends ASI_HK_CRM_TriggerAbstract {
    
    private Decimal minOrderAmount;
    private Decimal amountLv1;
    private Decimal amountLv2;
    
    public ASI_HK_CRM_SalesOrderApprovalCalculator() {
        super('ASI_HK_CRM_SalesOrderApprovalCalculator');
        ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
        if (thresholdValueSetting != null) {
            // updateForMinAmount
            minOrderAmount = thresholdValueSetting.ASI_HK_CRM_SO_Min_Order_Amount__c;
            // updateForMinAmount
            amountLv1 = thresholdValueSetting.ASI_HK_CRM_SO_Amount_Level_1__c;
            amountLv2 = thresholdValueSetting.ASI_HK_CRM_SO_Amount_Level_2__c;
        }
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
            && !isBypassByCurrentUser()) {
            List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
            
            for (ASI_HK_CRM_Sales_Order__c so : soList) {
                updateForMinAmount(so);
                updateForAmountRange(so);
            }
        }
    }
    
    private void updateForMinAmount(ASI_HK_CRM_Sales_Order__c so) {
        if (minOrderAmount != null && so.ASI_HK_CRM_Total_Order_Amount__c != null) {
            so.ASI_HK_CRM_SYS_Greater_Than_Min_Amount__c = so.ASI_HK_CRM_Total_Order_Amount__c >= minOrderAmount;
        }
    }
    
    private void updateForAmountRange(ASI_HK_CRM_Sales_Order__c so) {
        if (amountLv1 != null && so.ASI_HK_CRM_Total_Order_Amount__c != null) {
            so.ASI_HK_CRM_SYS_Greater_LvL1__c = so.ASI_HK_CRM_Total_Order_Amount__c > amountLv1;
        }
        if (amountLv2 != null && so.ASI_HK_CRM_Total_Order_Amount__c != null) {
            so.ASI_HK_CRM_SYS_Greater_LvL2__c = so.ASI_HK_CRM_Total_Order_Amount__c > amountLv2;
        }
    }
    
}