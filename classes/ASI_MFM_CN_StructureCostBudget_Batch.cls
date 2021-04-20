Global without sharing class ASI_MFM_CN_StructureCostBudget_Batch implements Database.Batchable<sObject> ,Database.Stateful{
    
    //Public Static String fy = ASI_MFM_CN_StructureCostHelperClass.fyconversion(date.today());
    Private Map<String, ASI_MFM_PO__c> budgetList = new Map<String, ASI_MFM_PO__c>();
    Private Map<String, Map<String, Double>> mapBudget = new Map<String, Map<String, Double>>();
    Private String fiscalYear;
    Private Date fyStart;
    Private Date fyEnd;
    
    global ASI_MFM_CN_StructureCostBudget_Batch(String fy){
        
        this.fiscalYear = fy;
        
        if(this.fiscalYear == Null || this.fiscalYear == '')
            this.fiscalYear = ASI_MFM_CN_StructureCostHelperClass.fyconversion(date.today());
        
        fyStart = date.newInstance(2000 + integer.valueOf(fiscalYear.substring(2, 4)), 7, 1);
        fyEnd = date.newInstance(2000 + integer.valueOf(fiscalYear.substring(4)), 6, 30);
        
        for(ASI_MFM_PO__c obj : [SELECT id, ASI_MFM_Expense_Type__c, ASI_MFM_CN_Amount_Ex__c FROM ASI_MFM_PO__c WHERE Recordtype.developerName Like '%ASI_MFM_CAP_CN_Structure_Cost%' AND ASI_MFM_PO_Fiscal_Year__c = : fiscalYear]){
            
            budgetList.put(obj.ASI_MFM_Expense_Type__c, obj);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryStr = 'SELECT id, ASI_MFM_Payment_Amount_RMB__c, ASI_MFM_Total_JDE_Adjustment_Amount__c, ASI_MFM_PO__r.ASI_MFM_CN_Amount_Ex__c, ASI_MFM_PO__c, ASI_MFM_Non_VAT_Amount_RMB__c, ';
        queryStr += 'ASI_MFM_Pre_payment__c, ASI_MFM_Expense_Date_From__c, ASI_MFM_Expense_Date_To__c, ASI_MFM_Exchange_Rate__c, ASI_MFM_Payment_Amount__c, ASI_MFM_CN_Fiscal_Year__c, ';
        queryStr += 'ASI_MFM_PO__r.ASI_MFM_Expense_Type__r.ASI_MFM_ExpenseType__c, ASI_MFM_PO__r.ASI_MFM_PO_Fiscal_Year__c, ASI_MFM_Expense_Type__c ';
        queryStr += 'FROM ASI_MFM_Payment__c ';
        queryStr += 'WHERE (NOT ASI_MFM_Accrual_Type__c Like \'Monthly Accrual\') AND ( ASI_MFM_CN_Fiscal_Year__c Like \'' + fiscalYear + '\' OR (ASI_MFM_Pre_payment__c = True AND ((ASI_MFM_Expense_Date_From__c >= : fyStart AND ASI_MFM_Expense_Date_From__c <= : fyEnd) OR (ASI_MFM_Expense_Date_From__c <= : fyStart AND ASI_MFM_Expense_Date_To__c >= : fyStart )))) AND RecordType.DeveloperName Like \'%ASI_MFM_CAP_CN_StructureCost_Payment%\' AND ASI_MFM_Status__c != \'Draft\'';
        queryStr += ' AND (ASI_MFM_Apply_CIP_Logic__c = False OR (ASI_MFM_Apply_CIP_Logic__c = True AND ASI_MFM_Completion__c = False))';
        
        Return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        List<ASI_MFM_Payment__c> paymentList = (List<ASI_MFM_Payment__c>)scope;
        
        for(ASI_MFM_Payment__c obj : paymentList){
            
            Map<String, Double> itemMap = new Map<String, Double>();
            Double actualAmount = 0;
            Double jdeAmount = 0;
            Double prePaymentAmount = 0;
            String keyPO;
            
            if(obj.ASI_MFM_CN_Fiscal_Year__c != fiscalYear){
                
                keyPO = budgetList.containsKey(obj.ASI_MFM_Expense_Type__c) ? budgetList.get('' + obj.ASI_MFM_Expense_Type__c).id : Null;
                
            }else{
                keyPO = obj.ASI_MFM_PO__c;
            }
                
            
            if(mapBudget.containsKey(keyPO)){
                
                itemMap = mapBudget.get(keyPO);
                actualAmount = itemMap.get('ActualAmount');
                jdeAmount = itemMap.get('JDEAmount');
                prePaymentAmount = itemMap.get('PrePaymentAmount');
            }
            
            if(obj.ASI_MFM_Pre_payment__c){
                
                if(obj.ASI_MFM_CN_Fiscal_Year__c != fiscalYear){
                    
                    prePaymentAmount += ASI_MFM_CN_StructureCostHelperClass.calculatePrePaymentPeriod(obj, obj.ASI_MFM_Expense_Date_From__c, obj.ASI_MFM_Expense_Date_To__c, fiscalYear);
                }else{
                    actualAmount += ASI_MFM_CN_StructureCostHelperClass.calculatePrePaymentPeriod(obj, obj.ASI_MFM_Expense_Date_From__c, obj.ASI_MFM_Expense_Date_To__c, fiscalYear);
                }
            }else{
                
                actualAmount += obj.ASI_MFM_Non_VAT_Amount_RMB__c;
            }
            
            jdeAmount = jdeAmount != Null ? jdeAmount + obj.ASI_MFM_Total_JDE_Adjustment_Amount__c : obj.ASI_MFM_Total_JDE_Adjustment_Amount__c;
            
            itemMap.put('PrePaymentAmount', prePaymentAmount);
            itemMap.put('ActualAmount', actualAmount);
            itemMap.put('JDEAmount', jdeAmount);
            
            mapBudget.put(keyPO, itemMap);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
        List<ASI_MFM_PO__c> updateList = new List<ASI_MFM_PO__c>();
        
        system.debug('Check1111111     ' + mapBudget);
        
        for(String key : mapBudget.keySet()){
            
            if(key != Null && key != ''){
                ASI_MFM_PO__c tmp = new ASI_MFM_PO__c(id = key);
                
                tmp.ASI_MFM_Actual_Paid_Amount__c = mapBudget.get(key).get('ActualAmount');
                tmp.ASI_MFM_JDE_Adjustment__c = mapBudget.get(key).get('JDEAmount');
                tmp.ASI_MFM_Previous_FY_Prepayment_Amount__c = mapBudget.get(key).get('PrePaymentAmount');

                updateList.add(tmp);
            }
        }
        
        if(updateList.size() > 0){
            try{
                Update updateList;
                
            }catch(dmlException dmle){
                
            }
        }
    }
}