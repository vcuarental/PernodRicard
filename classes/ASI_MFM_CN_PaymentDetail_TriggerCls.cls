public without sharing class ASI_MFM_CN_PaymentDetail_TriggerCls {

    Public static void beforeUpdateMethod(List<ASI_MFM_Payment_Detail__c> triggerNew, Map<id, ASI_MFM_Payment_Detail__c> triggerOldMap){
        
        Set<Id> expenseType = new Set<Id>();
        Set<String> fySet = new Set<String>();
        List<ASI_MFM_Payment_Detail__c> reverseList = new List<ASI_MFM_Payment_Detail__c>();
        Map<String, ASI_MFM_PO__c> poMap = new Map<String, ASI_MFM_PO__c>();
        
        for(ASI_MFM_Payment_Detail__c obj : triggerNew){
            
            if(obj.RecordTypeId == Global_RecordTypeCache.getRtId('ASI_MFM_Payment_Detail__cASI_MFM_CAP_CN_Accrual_Detail') && obj.ASI_MFM_Reverse_ETL__c && !triggerOldMap.get(obj.id).ASI_MFM_Reverse_ETL__c && !obj.ASI_MFM_Accrual_Reverse_Budget__c){
                reverseList.add(obj);
                fySet.add(ASI_MFM_CN_StructureCostHelperClass.fyconversion(obj.ASI_MFM_GL_date__c));
                expenseType.add(obj.ASI_MFM_Expense_Type_ID__c);
            }
        }
        
        for(ASI_MFM_PO__c po : [SELECT id, ASI_MFM_Reverse_Amount__c, ASI_MFM_PO_Fiscal_Year__c, ASI_MFM_Expense_Type__c FROM ASI_MFM_PO__c WHERE ASI_MFM_PO_Fiscal_Year__c IN : fySet AND ASI_MFM_Expense_Type__c IN : expenseType AND ASI_MFM_Status__c != 'Archived']){
            
            poMap.put('' + String.valueOf(po.ASI_MFM_Expense_Type__c).subString(0, 15) + po.ASI_MFM_PO_Fiscal_Year__c, po);
        }
        
        for(ASI_MFM_Payment_Detail__c payline : reverseList){
            
            String fy = ASI_MFM_CN_StructureCostHelperClass.fyconversion(payline.ASI_MFM_GL_date__c);
            
            if(poMap.containsKey('' + payline.ASI_MFM_Expense_Type_ID__c + fy)){
                
                if(poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c != Null)
                    poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c += payline.ASI_MFM_Accrual_Reverse_Amount_ETL__c;
                else
                    poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c = payline.ASI_MFM_Accrual_Reverse_Amount_ETL__c;
                
                payline.ASI_MFM_Accrual_Reverse_Budget__c = True;
            }
        }
        
        if(poMap.values().size() > 0){
            Try{
                
                Update poMap.values();
            }catch(dmlException dmle){
                
                reverseList[0].addError(dmle.getMessage());
            }
        }
    }
}