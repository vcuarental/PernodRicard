Global without sharing class ASI_MFM_CN_StructureCost_Reverse_Batch implements Database.Batchable<sObject> ,Database.Stateful{

    Private Date fyStart;
    Private Date fyEnd;
    
    global ASI_MFM_CN_StructureCost_Reverse_Batch(String fy){
        
        fyStart = date.newInstance(2000 + integer.valueOf(fy.substring(2, 4)), 7, 1);
        fyEnd = date.newInstance(2000 + integer.valueOf(fy.substring(4)), 6, 30);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        
        String queryStr = 'SELECT id, ASI_MFM_Accrual_Reverse_Budget__c, ASI_MFM_Accrual_Reverse_Amount_ETL__c, ASI_MFM_GL_date__c, ASI_MFM_Expense_Type_ID__c ';
        //queryStr += 'FROM ASI_MFM_Payment_Detail__c WHERE ASI_MFM_Reverse_ETL__c = True AND ASI_MFM_Accrual_Reverse_Budget__c = False AND RecordType.DeveloperName Like \'%ASI_MFM_CAP_CN_Accrual_Detail%\' AND ASI_MFM_GL_date__c >= fyStart AND ASI_MFM_GL_date__c <= fyEnd';
        queryStr += 'FROM ASI_MFM_Payment_Detail__c WHERE ASI_MFM_Payment__r.ASI_MFM_Status__c = \'Final\' AND ASI_MFM_Reverse_ETL__c = True AND RecordType.DeveloperName Like \'%ASI_MFM_CAP_CN_Accrual_Detail%\' AND ASI_MFM_GL_date__c >= : fyStart AND ASI_MFM_GL_date__c <= : fyEnd';

        Return Database.getQueryLocator(queryStr);
    }
    
    global void execute(Database.BatchableContext BC,  List<sObject> scope){
        
        List<ASI_MFM_Payment_Detail__c> paymentDetail = (List<ASI_MFM_Payment_Detail__c>)scope;
        List<ASI_MFM_Payment_Detail__c> updatePaymentList = new List<ASI_MFM_Payment_Detail__c>();
        Set<String> fySet = new Set<String>();
        Set<String> expenseType = new Set<String>();
        Map<String, ASI_MFM_PO__c> poMap = new Map<String, ASI_MFM_PO__c>();
        Set<Id> POSet = new Set<Id>();
        Boolean hasError = False;
        
        for(ASI_MFM_Payment_Detail__c payline : paymentDetail){
            
            fySet.add(ASI_MFM_CN_StructureCostHelperClass.fyconversion(payline.ASI_MFM_GL_date__c));
            system.debug('GL Date ' + ASI_MFM_CN_StructureCostHelperClass.fyconversion(payline.ASI_MFM_GL_date__c));
            expenseType.add(payline.ASI_MFM_Expense_Type_ID__c);
        }
        
        for(ASI_MFM_PO__c po : [SELECT id, ASI_MFM_Reverse_Amount__c, ASI_MFM_PO_Fiscal_Year__c, ASI_MFM_Expense_Type__c FROM ASI_MFM_PO__c WHERE ASI_MFM_PO_Fiscal_Year__c IN : fySet AND ASI_MFM_Expense_Type__c IN : expenseType AND ASI_MFM_Status__c != 'Archived']){
            
            poMap.put('' + String.valueOf(po.ASI_MFM_Expense_Type__c).subString(0, 15) + po.ASI_MFM_PO_Fiscal_Year__c, po);
        }
        
        for(ASI_MFM_Payment_Detail__c payline : paymentDetail){
            
            String fy = ASI_MFM_CN_StructureCostHelperClass.fyconversion(payline.ASI_MFM_GL_date__c);
            double accrualAmount = payline.ASI_MFM_Accrual_Reverse_Amount_ETL__c != Null ? payline.ASI_MFM_Accrual_Reverse_Amount_ETL__c : 0;
            
            if(poMap.containsKey('' + payline.ASI_MFM_Expense_Type_ID__c + fy)){
                
                if(POSet.contains(poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).id)){
                    if(poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c != Null)
                        poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c += accrualAmount;
                    else
                        poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c = accrualAmount;
                }else{
                    
                    poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).ASI_MFM_Reverse_Amount__c = accrualAmount;
                    POSet.add(poMap.get('' + payline.ASI_MFM_Expense_Type_ID__c + fy).id);
                }
                
                if(!payline.ASI_MFM_Accrual_Reverse_Budget__c){
                    payline.ASI_MFM_Accrual_Reverse_Budget__c = True;
                    updatePaymentList.add(payline);
                }
            }
        }
        
        if(poMap.values().size() > 0){
            Try{
                
                Update poMap.values();
            }catch(dmlException dmle){
                
                hasError = True;
            }
        }
        if(!hasError){
            Try{
                
                if(updatePaymentList.size() > 0)
                    Update updatePaymentList;
                
            }catch(dmlException dmle){
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){}
}