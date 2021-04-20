/*********************************************************************************
 * Name: EUR_CRM_BudgetCarryForwardHandler
 * Description: 
 * 5/12/2013
 * For Germany Budget Management.
 * Trigger on Budget Object (Header) AFTER INSERT.
 * IF Budget has previous budget (Previous Fiscal)
 * And Has a Carry Forward Amount.
 * Generate a new transaction line item under the new budget as DEBIT
 * 
 * 8/14/2013
 * For Germany Budget Management.
 * Instead on Budget Object (Header) it's the transaction object where
 * txn type = 'Initial Load'
 * AFTER INSERT.
 * IF Budget has previous budget (Previous Fiscal)
 * And Has a Carry Forward Amount.
 * Generate a new transaction line item under the new budget as DEBIT

 * Edit 11/26/14: 
 * - Assign Allocated Budget(EUR_CRM_Allocated_Budget__c) value on Budget Header
 * - Deduct transaction amount to Transfer From Budget (EUR_CRM_Transfer_From_Budget_Header__c) 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 9/11/2015        Conrad                  Added Comment Header
 *
*********************************************************************************/

public class EUR_CRM_BudgetCarryForwardHandler extends EUR_CRM_TriggerAbstract{
     
    private Set<String> rTypes = new Set<String>{'EUR_DE_On_Trade_WKZ', 'EUR_ZA_On_Trade_Budget'}; //Applicable Budget Record Types. DeveloperName.
    private Set<String> transactiorTypes = new Set<String>{'EUR_DE_On_Trade_WKZ', 'EUR_ZA_On_Trade_Budget'}; //Applicable Budget Record Types. DeveloperName.
    private final String DEBIT = 'Debit';
    private final String INITIAL_LOAD = 'Initial Load';
    private final String ROLLING_BUDGET_RECONCILIATION = 'Rolling Budget Reconciliation';
    private final String TRANSFER = 'Transfer';
    private final String FY = 'FY';
    public EUR_CRM_BudgetCarryForwardHandler(){
        super('EUR_CRM_BudgetCarryForwardHandler');
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        //uniqueness owner+fiscalyear
        // EUR_CRM_Budget__c
        // EUR_CRM_Fiscal_Year__c
        
        Set<Id> owners = new Set<Id>();
        Set<String> fiscalYears = new Set<String>();
        Map<Id, RecordType> budgetRecordTypes = new Map<Id,RecordType>([select Id, DeveloperName from RecordType where DeveloperName in:rTypes and SObjectType ='EUR_CRM_Budget__c']);
        Set<Id> rTypesId = budgetRecordTypes.keySet();
        Id de_RecordTypeId = null;
        for (Id budgetRtId : rTypesId) {
            if (budgetRecordTypes.get(budgetRtId).DeveloperName == 'EUR_DE_On_Trade_WKZ') {
                de_RecordTypeId = budgetRtId;
            }
        }
        
        Set<Id> transactionRTypesId = (new Map<Id,RecordType>([select id from RecordType where developername in:transactiorTypes and SObjectType ='EUR_CRM_Budget_Transaction__c'])).keySet();
        Set<Id> budgetIds = new Set<Id>();
        Map<Id, EUR_CRM_Budget_Transaction__c> budgetTransactionMap = new Map<Id, EUR_CRM_Budget_Transaction__c>(); // Key: Budget Id
        //Map of Transactions with specified Transfer From Budget
        Map<Id, List<EUR_CRM_Budget_Transaction__c>> sourceBudgetForDeduction = new Map<Id, List<EUR_CRM_Budget_Transaction__c>> ();// Key: Transfer From (Budget) - EUR_CRM_Transfer_From_Budget_Header__c
        
        for(EUR_CRM_Budget_Transaction__c txn : (List<EUR_CRM_Budget_Transaction__c>) sObjList){
            if(txn.EUR_CRM_Transaction_Category__c == INITIAL_LOAD){
                budgetIds.add(txn.EUR_CRM_Budget_Header__c);
                budgetTransactionMap.put(txn.EUR_CRM_Budget_Header__c, txn);
                system.debug('@txn.EUR_CRM_Transfer_From_Budget_Header__c'+txn.EUR_CRM_Transfer_From_Budget_Header__c);
                if (txn.EUR_CRM_Transfer_From_Budget_Header__c != null){
                    List<EUR_CRM_Budget_Transaction__c> txns = (sourceBudgetForDeduction.containsKey(txn.EUR_CRM_Transfer_From_Budget_Header__c))?sourceBudgetForDeduction.get(txn.EUR_CRM_Transfer_From_Budget_Header__c):new List<EUR_CRM_Budget_Transaction__c>();
                    txns.add(txn);
                    sourceBudgetForDeduction.put(txn.EUR_CRM_Transfer_From_Budget_Header__c, txns);
                }
            }
        }
        
        Map<Id, EUR_CRM_Budget__c> budgets = new Map<Id, EUR_CRM_Budget__c>();
        
        if(budgetIds.size()>0)
            budgets = new Map<Id, EUR_CRM_Budget__c>([select Id, recordTypeid, EUR_CRM_Fiscal_Year__c, ownerId, EUR_CRM_Allocated_Budget__c from EUR_CRM_Budget__c where id in: budgetIds]);
        
        if(budgets.size()>0){
            for(EUR_CRM_Budget__c budget: budgets.values()){
                system.debug('++Record Type Developer Name : '+ budget.recordTypeid);
                if(rTypesId.contains(budget.recordTypeid)){
                    owners.add(budget.ownerId);
                    String fiscalYear = '';
                    try{
                        fiscalYear = String.valueOf(Decimal.valueOf((budget.EUR_CRM_Fiscal_Year__c).substring(2,4)) - 1);
                        fiscalYears.add(FY+fiscalYear);
                    }catch(Exception e){
                        System.debug('Error - EUR_CRM_BudgetCarryForwardHandler: Invalid Fiscal Year - '+ budget.EUR_CRM_Fiscal_Year__c);
                        budget.addError('Invalid Fiscal Year');
                    }
                }
            }
        }
        
        List<EUR_CRM_Budget__c> prevBudgets = [select ownerId,EUR_CRM_Fiscal_Year__c,EUR_CRM_Current_Balance__c,EUR_CRM_Carry_Forward__c from EUR_CRM_Budget__c where ownerId in: owners and EUR_CRM_Fiscal_Year__c in: fiscalYears];
        Map<String,Decimal> prevBudgetAmounts = new Map<String,Decimal>();
        
        for(EUR_CRM_Budget__c prevBudget:  prevBudgets){
            if(prevBudget.EUR_CRM_Current_Balance__c < 0){
                String key = '' +prevBudget.ownerId +''+ prevBudget.EUR_CRM_Fiscal_Year__c;
                system.debug('++key: ' + key);
                prevBudgetAmounts.put(key,(prevBudget.EUR_CRM_Current_Balance__c * (-1)));
            }
        }
        
        List<EUR_CRM_Budget_Transaction__c> transactions = new List<EUR_CRM_Budget_Transaction__c>();
        List<EUR_CRM_Budget__c> toUpdateBudgets = new List<EUR_CRM_Budget__c>();
        //List of new debit transactions to deduct source (Transfer From) budgets
        List<EUR_CRM_Budget_Transaction__c> transactionsForSourceDeduction = new List<EUR_CRM_Budget_Transaction__c>();
        
        for(EUR_CRM_Budget__c budget: budgets.values()){
            String fiscalYear = '';
            try{
                fiscalYear = FY + String.valueOf(Decimal.valueOf((budget.EUR_CRM_Fiscal_Year__c).subString(2,4)) - 1);
            }catch(Exception e){
                System.debug('Error - EUR_CRM_BudgetCarryForwardHandler: Invalid Fiscal Year - '+ budget.EUR_CRM_Fiscal_Year__c);
                budget.addError('Invalid Fiscal Year');
            }
            String key = '' +budget.ownerId +''+ fiscalYear;
            Decimal amount =  prevBudgetAmounts.get(key);
            system.debug(' -- key: ' + key);
            system.debug(' -- amount: ' + amount);
            Boolean flag = false;
            if(rTypesId.contains(budget.RecordTypeId)  ){ 
               if (budgetTransactionMap.containsKey(budget.Id)){
                Decimal transactionAmount = budgetTransactionMap.get(budget.Id).EUR_CRM_Amount__c != null ? budgetTransactionMap.get(budget.Id).EUR_CRM_Amount__c: 0;
                Decimal budgetAllocatedAmount = budget.EUR_CRM_Allocated_Budget__c != null ? budget.EUR_CRM_Allocated_Budget__c : 0;
                budget.EUR_CRM_Allocated_Budget__c = budget.RecordTypeId == de_RecordTypeId?  (transactionAmount + budgetAllocatedAmount): transactionAmount;
                flag = true;
               }
               if(amount!= null){
                   budget.EUR_CRM_Carry_Forward__c = (-1) *  amount;
                   //Create Rolling Budget Transaction
                   EUR_CRM_Budget_Transaction__c txn= new EUR_CRM_Budget_Transaction__c(
                   EUR_CRM_Amount__c = amount,
                   EUR_CRM_Budget_Header__c = budget.id,
                   EUR_CRM_Transaction_Category__c = ROLLING_BUDGET_RECONCILIATION ,
                   EUR_CRM_Transaction_Type__c = DEBIT);
                   transactions.add(txn);
                   flag =true;
                }
                if(flag)
               toUpdateBudgets.add(budget);               
            }
        }
        
        system.debug('@sourceBudgetForDeduction'+sourceBudgetForDeduction);
        for (EUR_CRM_Budget__c sourceBudget: [SELECT Id FROM EUR_CRM_Budget__c WHERE Id IN:sourceBudgetForDeduction.keySet() LIMIT 49999]){
            for (EUR_CRM_Budget_Transaction__c txn : sourceBudgetForDeduction.get(sourceBudget.Id)){
                EUR_CRM_Budget_Transaction__c debitTxn = new EUR_CRM_Budget_Transaction__c();
                debitTxn.EUR_CRM_Budget_Header__c = sourceBudget.Id;
                debitTxn.EUR_CRM_Amount__c = txn.EUR_CRM_Amount__c;
                debitTxn.EUR_CRM_Transaction_Type__c = DEBIT;
                debitTxn.EUR_CRM_Transaction_Category__c = TRANSFER;
                debitTxn.EUR_CRM_Description__c = INITIAL_LOAD;
                debitTxn.EUR_CRM_Transfer_To__c = budgets.get(txn.EUR_CRM_Budget_Header__c).OwnerId;
                
                transactionsForSourceDeduction.add(debitTxn);
            }
        }
        
        if(transactions.size() > 0){
            insert transactions;
        }        
        if(toUpdateBudgets.size() > 0){
            update toUpdateBudgets;
        }
        if (transactionsForSourceDeduction.size() > 0){
            insert transactionsForSourceDeduction;
        }
         
     }
     
}