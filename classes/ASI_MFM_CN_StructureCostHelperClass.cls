public without sharing class ASI_MFM_CN_StructureCostHelperClass {
	
    Public Static Map<String, Map<String, Double>> calculateBudgetRemaining(Set<Id> paymentId, Set<Id> budgetId, Set<String> fy, Boolean isByExpenseType2, Set<String> expenseTypeSet){
        
        Map<String, Map<String, Double>> tmpMap = new Map<String, Map<String, Double>>();
        Map<String, String> mapPOExpenseType = new Map<String, String>();
        List<ASI_MFM_Payment__c> tmpPaymentList;
        Boolean isByExpenseType = True;//20170503 always run by expense type budget checking logic
        
        if(isByExpenseType){
            
            tmpPaymentList = new List<ASI_MFM_Payment__c>([SELECT id
                                                           , ASI_MFM_Payment_Amount_RMB__c
                                                           , ASI_MFM_Total_JDE_Adjustment_Amount__c
                                                           , ASI_MFM_PO__r.ASI_MFM_CN_Amount_Ex__c
                                                           , ASI_MFM_PO__c
                                                           , ASI_MFM_Pre_payment__c
                                                           , ASI_MFM_Expense_Date_From__c
                                                           , ASI_MFM_Expense_Date_To__c
                                                           , ASI_MFM_Exchange_Rate__c
                                                           , ASI_MFM_Payment_Amount__c
                                                           , ASI_MFM_CN_Fiscal_Year__c
                                                           , ASI_MFM_Non_VAT_Amount_RMB__c
                                                           , ASI_MFM_PO__r.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c
                                                           , ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c
                                                           FROM ASI_MFM_Payment__c
                                                           WHERE RecordType.DeveloperName Like 'ASI_MFM_CAP_CN_StructureCost_Payment'
                                                           AND (NOT ASI_MFM_Accrual_Type__c Like 'Monthly Accrual')
                                                           AND (ASI_MFM_PO__c IN : budgetId
                                                                OR ASI_MFM_PO__r.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c IN : expenseTypeSet
                                                                )
                                                           AND id NOT IN : paymentId
                                                           AND ASI_MFM_CN_Fiscal_Year__c IN : fy
                                                           AND ASI_MFM_Status__c != 'Draft'
                                                           AND (ASI_MFM_Apply_CIP_Logic__c = False
                                                                OR (ASI_MFM_Apply_CIP_Logic__c = True
                                                                    AND ASI_MFM_Completion__c = False)
                                                               )
                                                          ]);
        }/*else{
            
            tmpPaymentList = new List<ASI_MFM_Payment__c>([SELECT id
                                                           , ASI_MFM_Payment_Amount_RMB__c
                                                           , ASI_MFM_Total_JDE_Adjustment_Amount__c
                                                           , ASI_MFM_PO__r.ASI_MFM_CN_Amount_Ex__c
                                                           , ASI_MFM_PO__c
                                                           , ASI_MFM_Pre_payment__c
                                                           , ASI_MFM_Expense_Date_From__c
                                                           , ASI_MFM_Expense_Date_To__c
                                                           , ASI_MFM_Exchange_Rate__c
                                                           , ASI_MFM_Payment_Amount__c
                                                           , ASI_MFM_CN_Fiscal_Year__c
                                                           , ASI_MFM_Non_VAT_Amount_RMB__c
                                                           , ASI_MFM_PO__r.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c
                                                           , ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c
                                                           FROM ASI_MFM_Payment__c
                                                           WHERE RecordType.DeveloperName Like 'ASI_MFM_CAP_CN_StructureCost_Payment'
                                                           AND (NOT ASI_MFM_Accrual_Type__c Like 'Monthly Accrual')
                                                           AND ASI_MFM_PO__c IN : budgetId
                                                           AND id NOT IN : paymentId
                                                           AND ASI_MFM_CN_Fiscal_Year__c IN : fy
                                                           AND ASI_MFM_Status__c != 'Draft'
                                                           AND (ASI_MFM_Apply_CIP_Logic__c = False
                                                                OR (ASI_MFM_Apply_CIP_Logic__c = True
                                                                    AND ASI_MFM_Completion__c = False)
                                                               )
                                                          ]);
        }*/
        
        
        for(ASI_MFM_Payment__c obj : tmpPaymentList){
            
            Map<String, Double> itemMap = new Map<String, Double>();
            Double actualAmount = 0;
            Double jdeAmount = 0;
            Double budget = 0;
            
            if(tmpMap.containsKey(obj.ASI_MFM_PO__c)){
                
                actualAmount = tmpMap.get(obj.ASI_MFM_PO__c).get('ActualAmount');
                jdeAmount = tmpMap.get(obj.ASI_MFM_PO__c).get('JDEAmount');
            }
            
            if(!obj.ASI_MFM_Pre_payment__c){
                
                actualAmount += obj.ASI_MFM_Non_VAT_Amount_RMB__c != Null ? obj.ASI_MFM_Non_VAT_Amount_RMB__c : 0;
                jdeAmount += obj.ASI_MFM_Total_JDE_Adjustment_Amount__c != Null ? obj.ASI_MFM_Total_JDE_Adjustment_Amount__c : 0;
            }else{
                
                actualAmount += calculatePrePaymentPeriod(obj, obj.ASI_MFM_Expense_Date_From__c, obj.ASI_MFM_Expense_Date_To__c, obj.ASI_MFM_CN_Fiscal_Year__c);
                jdeAmount += obj.ASI_MFM_Total_JDE_Adjustment_Amount__c != Null ? obj.ASI_MFM_Total_JDE_Adjustment_Amount__c : 0;
            }
            
            budget = obj.ASI_MFM_PO__r.ASI_MFM_CN_Amount_Ex__c;
            
            itemMap.put('ActualAmount', actualAmount);
            itemMap.put('JDEAmount', jdeAmount);
            itemMap.put('Budget', budget);
            itemMap.put('TotalExpenseRemaining', 0);
            
            tmpMap.put(obj.ASI_MFM_PO__c, itemMap);
            
            if(!mapPOExpenseType.containsKey(obj.ASI_MFM_PO__c)){
                
                mapPOExpenseType.put(obj.ASI_MFM_PO__c, '' + obj.ASI_MFM_PO__r.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c + obj.ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c);
            }
        }
        
        if(isByExpenseType){
            
            Map<String, Decimal> mapExpenseTypeTotalAmount = new Map<String, Decimal>();
            Map<String, Decimal> mapExpenseTypeTotalPaid = new Map<String, Decimal>();
            
            Map<id, ASI_MFM_PO__c> tmpPOlist = new Map<id, ASI_MFM_PO__c>([SELECT id, ASI_MFM_CN_Amount_Ex__c 
                                                                           , ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c
                                                                           , ASI_MFM_PO_Fiscal_Year__c
                                                                           , ASI_MFM_Previous_FY_Prepayment_Amount__c
                                                                           FROM ASI_MFM_PO__c 
                                                                           WHERE ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c IN : expenseTypeSet 
                                                                           AND RecordType.DeveloperName Like 'ASI_MFM_CAP_CN_Structure_Cost'
                                                                           AND ASI_MFM_PO_Fiscal_Year__c IN : fy
                                                                           AND (NOT ASI_MFM_Status__c Like 'Archived')
                                                                           Order By ASI_MFM_PO_Fiscal_Year__c DESC
                                                                           , ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c DESC
                                                                          ]);
            
            for(ASI_MFM_PO__c obj : tmpPOlist.values()){
                if(!mapPOExpenseType.containsKey(obj.id)){
                    
                    mapPOExpenseType.put(obj.id, '' + obj.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c + obj.ASI_MFM_PO_Fiscal_Year__c);
                }
            }
            
            for(ASI_MFM_PO__c obj : tmpPOlist.values()){
                
                if(!mapExpenseTypeTotalAmount.containsKey(mapPOExpenseType.get(obj.id))){
                    
                    mapExpenseTypeTotalAmount.put(mapPOExpenseType.get(obj.id), (obj.ASI_MFM_CN_Amount_Ex__c - (obj.ASI_MFM_Previous_FY_Prepayment_Amount__c != Null ? obj.ASI_MFM_Previous_FY_Prepayment_Amount__c : 0)));
                }else{
                    Decimal tmpTotal = mapExpenseTypeTotalAmount.get(mapPOExpenseType.get(obj.id)) + (obj.ASI_MFM_CN_Amount_Ex__c - (obj.ASI_MFM_Previous_FY_Prepayment_Amount__c != Null ? obj.ASI_MFM_Previous_FY_Prepayment_Amount__c : 0));
                    mapExpenseTypeTotalAmount.put(mapPOExpenseType.get(obj.id), tmpTotal);
                }
            }
            
            //total by expense type actual paid
            for(String key : tmpMap.keySet()){
                
                if(mapPOExpenseType.containsKey(Key) && mapExpenseTypeTotalAmount.containsKey(mapPOExpenseType.get(key))){
                    
                    if(!mapExpenseTypeTotalPaid.containsKey(mapPOExpenseType.get(key))){
                        
                        mapExpenseTypeTotalPaid.put(mapPOExpenseType.get(key), tmpMap.get(key).get('ActualAmount') + tmpMap.get(key).get('JDEAmount') );
                    }else{
                        Decimal tmpTotal = mapExpenseTypeTotalPaid.get(mapPOExpenseType.get(key)) + tmpMap.get(key).get('ActualAmount') + tmpMap.get(key).get('JDEAmount');
                        mapExpenseTypeTotalPaid.put(mapPOExpenseType.get(key), tmpTotal);
                    }
                }
            }
            
            //total by expense type remaining
            for(String key : tmpMap.keySet()){
                
                if(mapPOExpenseType.containsKey(Key) && mapExpenseTypeTotalAmount.containsKey(mapPOExpenseType.get(key))){
                    
                    Map<String, Double> itemMap = tmpMap.get(key);
                    Decimal totalActualPaid = mapExpenseTypeTotalPaid.containsKey(mapPOExpenseType.get(key)) ? mapExpenseTypeTotalPaid.get(mapPOExpenseType.get(key)) : 0;
                    Decimal totalExpenseRemaining = mapExpenseTypeTotalAmount.get(mapPOExpenseType.get(key)) - totalActualPaid;
                    itemMap.put('TotalExpenseRemaining', totalExpenseRemaining);
                    
                    tmpMap.put(key, itemMap);
                }
            }
            
            //for budget without any payment
            for(String key : mapPOExpenseType.keySet()){
                
                if(!tmpMap.containsKey(key) && mapExpenseTypeTotalAmount.containsKey(mapPOExpenseType.get(key))){
                    
                    Map<String, Double> itemMap = new Map<String, Double>();
                    
                    itemMap.put('ActualAmount', 0);
                    itemMap.put('JDEAmount', 0);
                    itemMap.put('Budget', tmpPOlist.get(key).ASI_MFM_CN_Amount_Ex__c);
                    
                    Decimal totalActualPaid = mapExpenseTypeTotalPaid.containsKey(mapPOExpenseType.get(key)) ? mapExpenseTypeTotalPaid.get(mapPOExpenseType.get(key)) : 0;
                    
                    itemMap.put('TotalExpenseRemaining', (mapExpenseTypeTotalAmount.get(mapPOExpenseType.get(key)) - totalActualPaid));
                    
                    tmpMap.put(key, itemMap);
                }
            }
        }
        
        return tmpMap;
    }
    
    Public Static double calculatePrePaymentPeriod(ASI_MFM_Payment__c pay, date periodFrom, date periodTo, string thisFY){
        
        Double amount = 0;
        
        integer months = periodFrom.monthsBetween(periodTo) + 1;
        //decimal averageAmount = (pay.ASI_MFM_Payment_Amount__c/(months + 1)).setScale(2, System.RoundingMode.CEILING);
        
        decimal averageNonVATAmount = (pay.ASI_MFM_Non_VAT_Amount_RMB__c/(months)).setScale(2, System.RoundingMode.CEILING);
        
        //double remaining = pay.ASI_MFM_Payment_Amount__c - (averageAmount * (months + 1));
        double nonVATRemaining = (pay.ASI_MFM_Non_VAT_Amount_RMB__c - (averageNonVATAmount * (months))).setScale(2);
        //double remaining = pay.ASI_MFM_Payment_Amount__c - (averageAmount * (months + 1));
        
        for(integer i = 0 ; i < months ; i++){
            
            String fy = fyconversion(date.newInstance(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month(), date.daysInMonth(periodFrom.addMonths(i).year(), periodFrom.addMonths(i).month())));
            if(fy == thisFY){
                amount += (i == months - 1) ? averageNonVATAmount + nonVATRemaining : averageNonVATAmount;
            }
        }
        
        return amount;
    }
    
    Public Static String fyconversion(date d){
        
        string fy = 'FY';
        
        if(d.month() >= 7){
            fy += ('' + d.year()).subString(2) + ('' + d.addYears(1).year()).subString(2);
        }else{
            fy += ('' + d.addYears(-1).year()).subString(2) + ('' + d.year()).subString(2);
        }
        
        return fy;
    }
    
    Public Static Void updateBudget(ASI_MFM_PO__c currentBudget){
        
        update currentBudget;
    }
    
    Public Static String splitString(String stringToSplit, Integer splitLength){
        
        String a = '';
        
        if(stringToSplit.length() <= splitLength){
            return stringToSplit;
        }
        
        while(stringToSplit.length() > splitLength){
            
            a += stringToSplit.substring(0, splitLength) + ' ';
            stringToSplit = stringToSplit.substring(splitLength);
        }
        
        a += stringToSplit;
        
        return a;
    }
    
    Public Static ASI_MFM_Payment__c upsertPayment(ASI_MFM_Payment__c currentPayment, Boolean isInsert){
        
        if(isInsert){
            
            Insert currentPayment;
        }else{
            
            Update currentPayment;
        }
        Return currentPayment;
    }
    
    public Static List<ASI_MFM_PO__c> queryBudget(String thisPaymentFY, String expenseType, Id budgetId){
        
        if(budgetId != Null){
            
            return [SELECT id, ASI_MFM_Budget_Owner__c, ASI_MFM_CN_Amount_Ex__c, ASI_MFM_Previous_FY_Prepayment_Amount__c, ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE Id = : budgetId AND (NOT ASI_MFM_Status__c Like 'Archived') AND RecordTypeId = : Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_CN_Structure_Cost')];
        }else{
            
            return [SELECT id, ASI_MFM_Budget_Owner__c, ASI_MFM_CN_Amount_Ex__c, ASI_MFM_Previous_FY_Prepayment_Amount__c, ASI_MFM_Status__c FROM ASI_MFM_PO__c WHERE ASI_MFM_PO_Fiscal_Year__c = : thisPaymentFY AND (NOT ASI_MFM_Status__c Like 'Archived') AND ASI_MFM_Expense_Type__c = : expenseType AND RecordTypeId = : Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_CAP_CN_Structure_Cost')];
        }
    }
    
    Public Static List<ASI_CRM_Fix_Approval_Route__c> RetrieveFixApprovalInfo(Map<String, Schema.SObjectField> fieldMap, String whereClause) {
        
        String query = 'SELECT ' + genQueryField(fieldMap) + ' FROM ASI_CRM_Fix_Approval_Route__c ' + whereClause;
        
        List<ASI_CRM_Fix_Approval_Route__c> fixApprovalList = (List<ASI_CRM_Fix_Approval_Route__c>) Database.query(query);
        return fixApprovalList.size() > 0 ? fixApprovalList : new List<ASI_CRM_Fix_Approval_Route__c>();
    }
    
    Public Static String genQueryField(Map<String, Schema.SObjectField> fieldMap) {
        String queryField = '';
        for(String fields : fieldMap.keySet()) {
            queryField += fields + ',';
        }
        return queryField.subString(0, queryField.length() - 1);
    }
}