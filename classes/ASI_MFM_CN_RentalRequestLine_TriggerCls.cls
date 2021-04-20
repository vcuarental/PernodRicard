public without sharing class ASI_MFM_CN_RentalRequestLine_TriggerCls {

    Public static void beforeUpdateMethod(List<ASI_MFM_Rental_Request_Line__c> triggerNew, Map<id, ASI_MFM_Rental_Request_Line__c> triggerOldMap){

        //List<ASI_MFM_Rental_Request_Line__c> renovationLine = New List<ASI_MFM_Rental_Request_Line__c>();
        Map<Id, ASI_MFM_Rental_Request_Line__c> rentalLineMap = new Map<Id, ASI_MFM_Rental_Request_Line__c>();
        
        //CIP Logic
        Map<Id, ASI_MFM_Payment__c> mapDummyPayment = new Map<id, ASI_MFM_Payment__c>();
        List<ASI_MFM_Rental_Request_Line__c> finalRentalContractList = new List<ASI_MFM_Rental_Request_Line__c>();
        List<ASI_MFM_Payment__c> insertPaymentList = new List<ASI_MFM_Payment__c>();
        Set<Id> expensetypeIdSet = new Set<Id>();
        Map<id, ASI_MFM_PO__c> mapBudget = new Map<id, ASI_MFM_PO__c>();
        String fy = ASI_MFM_CN_StructureCostHelperClass.fyconversion(date.today());
        List<ASI_MFM_Prefix__c> prefixList = new List<ASI_MFM_Prefix__c>();
        Boolean hasError = False;
        
        //get all dummy payment
        for(ASI_MFM_Payment__c dp : [SELECT id
                                     , ASI_MFM_Contract__r.ASI_MFM_Rental_Request__c
                                     , ASI_MFM_Contract__c
                                     FROM ASI_MFM_Payment__c 
                                     WHERE ASI_MFM_Dummy_Payment__c = True
                                     AND ASI_MFM_Contract__c IN : triggerNew
                                     AND recordtype.developerName like '%ASI_MFM_CAP_CN_StructureCost_Payment%'
                                    ]){
                                        mapDummyPayment.put(dp.ASI_MFM_Contract__c, dp);
                                    }
        
        //if(renovationLine.size() > 0){
        	//20190324-Andy: CR#88-add a new field  “Total Paid Amount with VAT & Deposit”
            for(ASI_MFM_Payment__c obj : [SELECT id, ASI_MFM_Completion__c, ASI_MFM_Payment_Amount__c, ASI_MFM_Payment_Amount_RMB__c, ASI_MFM_Contract__c, ASI_MFM_Total_Amount_Without_Tax__c, ASI_MFM_Non_VAT_Amount_RMB__c, ASI_MFM_Status__c FROM ASI_MFM_Payment__c 
                                          WHERE ASI_MFM_Contract__c IN : triggerNew
                                          AND ASI_MFM_Status__c != 'Draft'
                                          AND ASI_MFM_Dummy_Payment__c = False
                                         ]){
                                              
                                              if(rentalLineMap.containsKey(obj.ASI_MFM_Contract__c)){
                                                  
                                                  if(!obj.ASI_MFM_Completion__c)
                                                      rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_CIP_Amount__c 
                                                      = rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_CIP_Amount__c != Null 
                                                      ? rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_CIP_Amount__c + obj.ASI_MFM_Non_VAT_Amount_RMB__c 
                                                      : obj.ASI_MFM_Non_VAT_Amount_RMB__c;
                                                  
                                                  rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_Paid_Amount__c
                                                      = rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_Paid_Amount__c != NUll
                                                      ? rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_Paid_Amount__c + obj.ASI_MFM_Payment_Amount_RMB__c 
                                                      : obj.ASI_MFM_Payment_Amount_RMB__c;
                                                  
                                                  //20190324-Andy: CR#88-add a new field  “Total Paid Amount with VAT & Deposit”
                                                  //if ((obj.ASI_MFM_Status__c == 'Submitted') || (obj.ASI_MFM_Status__c == 'Final')) {
                                                      rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_Total_Paid_Amount_w_VAT__c
                                                          = rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_Total_Paid_Amount_w_VAT__c != NUll
                                                          ? rentalLineMap.get(obj.ASI_MFM_Contract__c).ASI_MFM_Total_Paid_Amount_w_VAT__c + obj.ASI_MFM_Total_Amount_Without_Tax__c 
                                                          : obj.ASI_MFM_Total_Amount_Without_Tax__c;
                                                  //}
                                                  
                                              }else{
                                                  
                                                  ASI_MFM_Rental_Request_Line__c tmp = new ASI_MFM_Rental_Request_Line__c(id = obj.ASI_MFM_Contract__c);
                                                  
                                                  if(!obj.ASI_MFM_Completion__c)
                                                      tmp.ASI_MFM_CIP_Amount__c = obj.ASI_MFM_Non_VAT_Amount_RMB__c;
                                                  
                                                  tmp.ASI_MFM_Paid_Amount__c = obj.ASI_MFM_Payment_Amount_RMB__c;
                                                  
                                                  //20190324-Andy: CR#88-add a new field  “Total Paid Amount with VAT & Deposit”
                                                  if ((obj.ASI_MFM_Status__c == 'Submitted') || (obj.ASI_MFM_Status__c == 'Final'))
                                                      tmp.ASI_MFM_Total_Paid_Amount_w_VAT__c = obj.ASI_MFM_Total_Amount_Without_Tax__c;
                                                  
                                                  rentalLineMap.put(tmp.id, tmp);
                                              }
                                          }
            
        for(ASI_MFM_Rental_Request_Line__c rl : triggerNew){
            
            if(rentalLineMap.containsKey(rl.id)){
                rl.ASI_MFM_CIP_Amount__c = rentalLineMap.get(rl.id).ASI_MFM_CIP_Amount__c;
                rl.ASI_MFM_Paid_Amount__c = rentalLineMap.get(rl.id).ASI_MFM_Paid_Amount__c;
                //20190324-Andy: CR#88-add a new field  “Total Paid Amount with VAT & Deposit”
                rl.ASI_MFM_Total_Paid_Amount_w_VAT__c = rentalLineMap.get(rl.id).ASI_MFM_Total_Paid_Amount_w_VAT__c;
            }else{
                rl.ASI_MFM_CIP_Amount__c = 0;
                rl.ASI_MFM_Paid_Amount__c = 0;
                //20190324-Andy: CR#88-add a new field  “Total Paid Amount with VAT & Deposit”
                rl.ASI_MFM_Total_Paid_Amount_w_VAT__c = 0;
            }
            
            if(rl.ASI_MFM_Paid_Amount__c != Null && rl.ASI_MFM_Total_Amount__c != Null && rl.ASI_MFM_Total_Amount__c < rl.ASI_MFM_Paid_Amount__c)
                rl.addError('Total Amount cannot be less than paid amount.');
            
            if(rl.ASI_MFM_Status__c == 'Final' && rl.ASI_MFM_Apply_CIP_Logic__c && !triggerOldMap.get(rl.id).ASI_MFM_Completion__c && rl.ASI_MFM_Completion__c && !mapDummyPayment.containsKey(rl.id)){
                expensetypeIdSet.add(rl.ASI_MFM_ExpenseType__c);
                finalRentalContractList.add(rl);
            }
        }
        
        if(finalRentalContractList.size() > 0){
            
            List<Account> dummySupplier = new List<Account>([Select id From Account Where recordtypeid = : Global_RecordTypeCache.getRtId('AccountASI_MFM_CN_Structure_Cost_Supplier') And ASI_MFM_Dummy_Supplier__c = True]);
            Set<id> budgetId = new Set<Id>();
            Set<String> expensetypeSet = new Set<String>();
            Set<String> fySet = new Set<String>();
            Map<id, ASI_MFM_Rental_Request_Line__c> mapContract = new Map<Id, ASI_MFM_Rental_Request_Line__c>();
            
            List<ASI_MFM_Tax_Code__c> OTHtaxcode = new List<ASI_MFM_Tax_Code__c>([SELECT id FROM ASI_MFM_Tax_Code__c WHERE Name Like 'OTH' AND RecordType.DeveloperName Like 'ASI_MFM_CN_Tax_Code']);
            prefixList = [SELECT id FROM ASI_MFM_Prefix__c WHERE ASI_MFM_Module__c = 'Structure Cost Rental Payment' AND ASI_MFM_Fiscal_year__c = : fy AND recordtype.developerName like 'ASI_MFM_CN_Prefix'];
            
            for(ASI_MFM_PO__c budget : [SELECT id, ASI_MFM_Expense_Type__r.ASI_MFM_BudgetControlMethod__c, ASI_MFM_CN_Amount_Ex__c, ASI_MFM_Budget_Owner__c, ASI_MFM_Expense_Type__c FROM ASI_MFM_PO__c WHERE ASI_MFM_PO_Fiscal_Year__c Like : fy AND ASI_MFM_Expense_Type__c IN : expensetypeIdSet AND ASI_MFM_Status__c != 'Archived' AND recordtype.developerName like '%ASI_MFM_CAP_CN_Structure_Cost%']){
                
                mapBudget.put(budget.ASI_MFM_Expense_Type__c, budget);
            }
            
            for(ASI_MFM_Rental_Request_Line__c obj : finalRentalContractList){
                
                if(mapBudget.containsKey(obj.ASI_MFM_ExpenseType__c) && prefixList.size() > 0 && dummySupplier.size() > 0){
                    
                    budgetId.add(mapBudget.get(obj.ASI_MFM_ExpenseType__c).id);
                    expensetypeSet.add(obj.ASI_MFM_Expense_Type_Text__c);
                    fySet.add(fy);
                    mapContract.put(obj.id, obj);
                    
                    insertPaymentList.add(new ASI_MFM_Payment__c(ASI_MFM_Expense_Type__c = obj.ASI_MFM_ExpenseType__c
                                                                 , ASI_MFM_BU__c = obj.ASI_MFM_Rental_Request__r.ASI_MFM_BU__c
                                                                 , ASI_MFM_Status__c = 'Final'
                                                                 , ASI_MFM_Tax_Code__c = OTHtaxcode.size() > 0 ? OTHtaxcode[0].id : Null//obj.ASI_MFM_Tax_Code__c
                                                                 , ASI_MFM_Dummy_Payment__c = True
                                                                 , ASI_MFM_Period_From__c = date.today()
                                                                 , ASI_MFM_Period_To__c = date.today()
                                                                 , ASI_MFM_Currency__c = 'RMB'
                                                                 , ASI_MFM_Contract__c = obj.id
                                                                 , ASI_MFM_Prefix__c = prefixList[0].id
                                                                 , ASI_MFM_Invoice_Amount__c = (obj.ASI_MFM_Total_Amount_Without_Tax__c - obj.ASI_MFM_CIP_Amount__c).setScale(2)
                                                                 , ASI_MFM_PO__c = mapBudget.get(obj.ASI_MFM_ExpenseType__c).id
                                                                 , ASI_MFM_Supplier_Name__c = dummySupplier[0].id
                                                                 , recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_CAP_CN_StructureCost_Payment')
                                                                 , ASI_MFM_Department_Text__c = obj.ASI_MFM_Department__c
                                                                 , ASI_MFM_Budget_Owner__c = mapBudget.get(obj.ASI_MFM_ExpenseType__c).ASI_MFM_Budget_Owner__c
                                                                ));
                }else{
                    
                    obj.addError('Budget/Prefix/Supplier cannot be found.');
                    hasError = True;
                }
            }
            
            if(!hasError && insertPaymentList.size() > 0){
                
                Map<String, Map<String, Double>> mapAmount = ASI_MFM_CN_StructureCostHelperClass.calculateBudgetRemaining(null, budgetId, fySet, true, expensetypeSet);
                
                for(ASI_MFM_Payment__c obj : insertPaymentList){
                    
                    if(mapBudget.containsKey(obj.ASI_MFM_Expense_Type__c) && mapBudget.get(obj.ASI_MFM_Expense_Type__c).ASI_MFM_Expense_Type__r.ASI_MFM_BudgetControlMethod__c){
                        
                        if(mapAmount.containsKey(obj.ASI_MFM_PO__c)){
                            
                            if((mapBudget.get(obj.ASI_MFM_Expense_Type__c).ASI_MFM_CN_Amount_Ex__c - obj.ASI_MFM_Invoice_Amount__c - mapAmount.get(obj.ASI_MFM_PO__c).get('ActualAmount') - mapAmount.get(obj.ASI_MFM_PO__c).get('JDEAmount') < 0) && mapContract.get(obj.ASI_MFM_Contract__c).ASI_MFM_ExpenseType__r.ASI_MFM_BudgetControlLevel__c != 'By Expense Type'){
                                
                                hasError = true;
                            }else if((mapAmount.get(obj.ASI_MFM_PO__c).get('TotalExpenseRemaining') - obj.ASI_MFM_Invoice_Amount__c < 0) && mapContract.get(obj.ASI_MFM_Contract__c).ASI_MFM_ExpenseType__r.ASI_MFM_BudgetControlLevel__c == 'By Expense Type'){
                                
                                hasError = true;
                            }
                        }else if(mapBudget.get(obj.ASI_MFM_Expense_Type__c).ASI_MFM_CN_Amount_Ex__c - obj.ASI_MFM_Invoice_Amount__c < 0){
                            
                            hasError = true;
                        }
                    }
                    
                    
                }
                
                if(!hasError){
                    try{
                        Insert insertPaymentList;
                    }catch(dmlException dmle){
                        triggerNew[0].addError(dmle.getMessage());
                    }
                }else{
                    triggerNew[0].addError('Over Budget');
                }
            }
        }
    }
}