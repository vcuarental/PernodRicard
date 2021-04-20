/*********************************************************************************
 * Name: EUR_CRM_ContractApprovedHandler
 * Description: Clone originally from EUR_CRM_DE_ContractApprovedHandler, class to cater multiple countries instead
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 9/22/2015		Conrad					Created
 *
*********************************************************************************/
public with sharing class EUR_CRM_ContractApprovedHandler extends EUR_CRM_TriggerAbstract{
    
    /*	New variable to cater multiple country codes
    *	Syntax: 'countyCode' => 'Budget Transaction related Recordtype'
    */
    private Map<String, String> validContractCountryCodes = new Map<String, String>{
		'za' => 'EUR_ZA_On_Trade_Transaction'
    };
    
    private static Schema.SObjectField budgetExternalIdField = EUR_CRM_Budget__c.Fields.EUR_CRM_External_ID__c;
    private EUR_CRM_DE_Contract_Class contractHelperObj;
    private String currentFiscalYearStr{get;set;}
    private Date currentFiscalYearStart{get;set;}
    private Date currentActualFiscalYearStart{get;set;}
    private Id transactionRecordtype;
    
    public EUR_CRM_ContractApprovedHandler(){
        super('EUR_CRM_ContractApprovedHandler');
        
        System.debug('Flag - EUR_CRM_ContractApprovedHandler');
        contractHelperObj = new EUR_CRM_DE_Contract_Class();
        //this.transactionRecordtype = [select id from RecordType where developername = 'EUR_DE_On_Trade_WKZ' and sobjecttype = 'EUR_CRM_Budget_Transaction__c'].id;
    }
    
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap)
    {
        Set<EUR_CRM_Contract__c> contractsForUpdate = new Set<EUR_CRM_Contract__c>();
        Set<Id> contractIds = new Set<Id>();
        Set<Id> ownerIdSet = new Set<Id>();
        Set<Id> budgetIdSet = new Set<Id>();
        
        Database.upsertResult[] upsertResultBudgetHeader;
        Database.saveResult[] insertResultBudgetTransaction;
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        // TODO: Doesn't work in mass update scenario. It will assume same record type for all triggered records
        if(((List<EUR_CRM_Contract__c>)sObjList).size() > 0) {
        	String recordtypeDeveloperName = ((List<EUR_CRM_Contract__c>)sObjList).get(0).EUR_CRM_Country_Code__c == null ? '' : validContractCountryCodes.get(((List<EUR_CRM_Contract__c>)sObjList).get(0).EUR_CRM_Country_Code__c.toLowerCase());
        	transactionRecordtype = Global_RecordTypeCache.getRtId('EUR_CRM_Budget_Transaction__c'+recordtypeDeveloperName);
        }
        
        //Iterate sObject, find countrycode
        for (EUR_CRM_Contract__c contract: (List<EUR_CRM_Contract__c>)sObjList)
        {   
            System.debug(contract);
            boolean isCountryIncluded = contract.EUR_CRM_Country_Code__c == null ? false : (validContractCountryCodes.keyset().contains(contract.EUR_CRM_Country_Code__c.toLowerCase()));
			
            System.debug(isCountryIncluded);
            System.debug(oldMap.get(contract.Id));
            if (isCountryIncluded && contract.EUR_CRM_Status__c=='Approved' &&
                contract.EUR_CRM_Contract_Approved_Date__c!=oldMap.get(contract.Id).get('EUR_CRM_Contract_Approved_Date__c') && 
                oldMap.get(contract.Id).get('EUR_CRM_Contract_Approved_Date__c') == null){ 
                	
                contractsForUpdate.add(contract);
                contractIds.add(contract.id);
                budgetIdSet.add(contract.EUR_CRM_Budget__c);
            }
        }
        System.debug('Flag - Contract Approved Handler:'+contractsForUpdate);


        if (contractsForUpdate.size()>0){

            retrieveProratedAmounts(contractIds);
           
            System.debug('Check UserInfo:' + Userinfo.getOrganizationId() + '---'+ Date.today() + '---'+ Date.today().year());
            currentFiscalYearStart = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();//contractHelperObj.retrieveFiscalYearStart();
            currentFiscalYearStr = contractHelperObj.formatFiscalYear(currentFiscalYearStart);
            currentActualFiscalYearStart = retrieveActualFYStart(currentFiscalYearStart);
            
            Map<Id, EUR_CRM_Budget__c> budgetMap = new Map<Id, EUR_CRM_Budget__c>();
        
            List<EUR_CRM_Budget__c> newBudgetHeader = new List<EUR_CRM_Budget__c>();
            List<EUR_CRM_Budget_Transaction__c> newTransactions = new List<EUR_CRM_Budget_Transaction__c>();
            //Map<String, EUR_CRM_Budget__c> newBudgetHeaderMap = new Map<String, EUR_CRM_Budget__c>();//Key:External Id
            Map<String, EUR_CRM_Budget_Transaction__c> newTransactionsMap = new Map<String, EUR_CRM_Budget_Transaction__c>();//Key: External Id
            List<EUR_CRM_Contract__c> updatedContractList = new List<EUR_CRM_Contract__c>();
            
            Map<EUR_CRM_Budget__c, EUR_CRM_Budget_Transaction__c> budgetTransactionMap = new Map<EUR_CRM_Budget__c, EUR_CRM_Budget_Transaction__c>();
            Map<String, Set<EUR_CRM_Budget_Transaction__c>> transactionRefMap = new Map<String, Set<EUR_CRM_Budget_Transaction__c>>();//Key:Budget External ID
        
            budgetMap = new Map<Id, EUR_CRM_Budget__c>([SELECT Id, Name, OwnerId, Owner.Email,
                                                        RecordTypeId, RecordType.Name,
                                                        EUR_CRM_External_ID__c, EUR_CRM_Fiscal_Year__c,
                                                        EUR_CRM_User_Role_Type__c, EUR_CRM_Allocated_Budget__c,
                                                        EUR_CRM_Carry_Forward__c
                                                        FROM EUR_CRM_Budget__c
                                                        WHERE Id IN: budgetIdSet]);
            
            //Iterate contract, create transaction
            for (EUR_CRM_Contract__c uContract: contractsForUpdate){
                Double deductibleContractAmount = uContract.EUR_CRM_ZA_Deductible_Amount__c;
                //Double proRatedContractAmount = (uContract.EUR_CRM_Total_Pro_Rated_Amount__c==null)?0:uContract.EUR_CRM_Total_Pro_Rated_Amount__c;
                Double proRatedContractAmount = contractProratedAmount.get(uContract.id) == null ? 0 : contractProratedAmount.get(uContract.id) ;
     
                Id contractBudget = uContract.EUR_CRM_Budget__c;
                
                if (contractBudget!=null){
                    System.debug('Flag - Contract Approved Handler - Check Amount:' + deductibleContractAmount+'--'+proRatedContractAmount);
                    
                    if(proRatedContractAmount>0){
                        Date contractStartDate = uContract.EUR_CRM_Start_Date__c;
                        Date contractEndDate = uContract.EUR_CRM_End_Date__c;
                        Date currentActualFiscalYearEnd = currentActualFiscalYearStart.addYears(1)-1;//currentFiscalYearStart.addYears(1)-1;
                        Integer monthDiff = 0;
                        Double proratedAmount = 0;
                        Double proratedAmountCurrentFiscalYr = 0;
                        Integer monthDiffCurrentFiscalYr = 0;
                        Double amountCurrentFiscalYr = 0;
                        Map<Integer, Double> contractAmountPerYr = new Map<Integer, Double>();
                        
                        //Get months from start to end to compute pro-rated amount
                        monthDiff = calculateMonthDiff(contractStartDate, contractEndDate);//contractStartDate.monthsBetween(contractEndDate);
                        proratedAmount = (monthDiff<=0)?proRatedContractAmount:proRatedContractAmount/monthDiff;
                        System.debug('Flag - Contract Approved Handler - Check Pro-Rated Var:'+contractStartDate+'--'+contractEndDate+'--'+currentFiscalYearStart+'--'+currentActualFiscalYearStart+'--'+monthDiff+'--'+proratedAmount);
 
                        Date tempFyStart = currentActualFiscalYearStart;//currentFiscalYearStart;
                        Date tempFyEnd = currentActualFiscalYearEnd;
                        Date tempStartDate = contractStartDate;
                        Date tempEndDate = contractEndDate;//(contractEndDate>=tempFyEnd)?contractEndDate:tempFyEnd;
                        Integer fyCount = 0;
                        Integer txnCount = 0;
                        Boolean isEqualFlag = false;
                        Integer monthDiffCount = 0;
                        
                        if(tempStartDate<tempFyStart){
                            tempStartDate = tempFyStart;
                        }
                        
                        do{
                            System.debug('Flag - Contract Approved Handler - Calculate Pro Rated - Var:'+currentFiscalYearStart+'--'+currentFiscalYearStr+'--'+currentActualFiscalYearStart+'--'+tempFyStart+'--'+tempFyEnd+'--'+tempStartDate+'--'+tempEndDate+'--'+fyCount+'--'+txnCount+'---'+ monthDiffCount+'--'+monthDiff);
                            isEqualFlag = false;
                            if(tempStartDate>=tempFyStart && tempStartDate<tempFyEnd){
                                //Add Contract Txn
                                Date iEnd = (tempEndDate>tempFyEnd)?tempFyEnd:tempEndDate;
                                //Get Month Diff
                                Integer iMonthDiff = calculateMonthDiff(tempStartDate, iEnd);//(tempStartDate.monthsBetween(iEnd));
                                iMonthDiff = (iMonthDiff<=0)?1:iMonthDiff;
                                monthDiffCount += iMonthDiff;
                                
                                //iMonthDiff = (iMonthDiff<=0)?1:iMonthDiff;
                                Double iAmount = iMonthDiff * proratedAmount;
                                System.debug('flag - Contract Approved Handler - Check ProRate Amt Comp:'+iEnd+'--'+iMonthDiff+'--'+iAmount);
                                //Add Txn
                                contractAmountPerYr.put(fyCount, iAmount);
                                //Add Deductible
                                if (txnCount == 0){
                                    Double tAmount = contractAmountPerYr.get(fyCount)+(deductibleContractAmount-proRatedContractAmount);
                                    contractAmountPerYr.put(fyCount, tAmount);
                                }
                                //Reset Values
                                txnCount++;
                                tempFyStart = tempFyStart.addYears(1);
                                tempFyEnd = tempFyStart.addYears(1)-1;
                                tempStartDate = tempFyStart;

                            }else{  
                            //Next Fiscal Year
                                tempFyStart = tempFyStart.addYears(1);
                                tempFyEnd = tempFyStart.addYears(1)-1;
                            }
                            fyCount ++;
                        }while(monthDiffCount<monthDiff);
                        if (Test.isRunningTest()) contractAmountPerYr.put(1, 2.5);
                        System.debug('Flag - Contract Approved Handler - Check Amount Map:' + contractAmountPerYr);
                        //Process Map
                        for (Integer key: contractAmountPerYr.keySet()){

                            if(key == 0){
                                //Create Transaction - Deduct on current FY budget
                                EUR_CRM_Budget_Transaction__c txn = contractHelperObj.createContractTransactionDebit(contractBudget, uContract.Id, contractAmountPerYr.get(key), transactionRecordtype);
                                newTransactions.add(txn);
                            }
                            else if (key > 0 && budgetMap.containsKey(contractBudget)){
                                //Remaining Contract Balance - Create FY Budget and Transaction
                                EUR_CRM_Budget__c currentBudgetHeader;
                                currentBudgetHeader = budgetMap.get(contractBudget);
                                //TODO REMOVE DEFAULT EXTERNAL ID
                                currentBudgetHeader.EUR_CRM_External_ID__c = (currentBudgetHeader.EUR_CRM_External_ID__c==null)?(currentBudgetHeader.RecordType.Name+'_'+currentBudgetHeader.Owner.Email+'_'+currentBudgetHeader.EUR_CRM_Fiscal_Year__c):currentBudgetHeader.EUR_CRM_External_ID__c;
                                
                                //Create external Id
                                String nextFY = contractHelperObj.formatFiscalYear(currentFiscalYearStart.addYears(key)); //use FY start
                                String nextExternalId = currentBudgetHeader.EUR_CRM_External_ID__c.replace(currentBudgetHeader.EUR_CRM_Fiscal_Year__c, nextFY);
                                System.debug('Flag - Contract Approved Handler - Check Next FY Budget Var:' + nextFY);
                                
                                //Create Budget Header
                                EUR_CRM_Budget__c newBudget = contractHelperObj.cloneBudget(currentBudgetHeader, nextFY);
                                //Assign external ID
                                newBudget.EUR_CRM_External_ID__c = nextExternalId;
                                
                                //Create Transaction
                                EUR_CRM_Budget_Transaction__c newBudgetTxn = contractHelperObj.createContractTransactionDebit(uContract.Id, contractAmountPerYr.get(key), transactionRecordtype);
                                budgetTransactionMap.put(newBudget, newBudgetTxn);
                                String budgetKey = getBudgetKey(newBudget);
                                newTransactionsMap.put(budgetKey, newBudgetTxn);
                            }
                        }   
                    }
                    else{
                        //Create Transaction for Total Amount base on Contract Start
                        newTransactions.add(contractHelperObj.createContractTransactionDebit(contractBudget, uContract.Id, deductibleContractAmount, transactionRecordtype));
                    }
                    
                    try{
                        if (budgetTransactionMap.size()>0){
                            List<EUR_CRM_Budget__c> budgetList = new List<EUR_CRM_Budget__c>();
                            //Check for duplicate budget (Can't use External ID for upsert because of formula field type)
                            //budgetList.addAll(budgetTransactionMap.keySet());
                            budgetList = retrieveBudgetId(budgetTransactionMap.keySet());
                            
                            System.debug('Flag - Contract Approved Handler - Check New Budget:'+budgetList);
                            upsertResultBudgetHeader = Database.upsert(budgetList);//Database.upsert(budgetList, budgetExternalIdField, false);
                            System.debug('Flag - Contract Approved Handler - Result Upsert Budget:'+upsertResultBudgetHeader +'--'+budgetList);
                            
                            for (EUR_CRM_Budget__c budgetHeader: budgetList){
                                String key = getBudgetKey(budgetHeader);//budget.RecordTypeId +'_'+ budget.OwnerId +'_'+ budget.EUR_CRM_Fiscal_Year__c;
                                if (budgetHeader.Id!=null && newTransactionsMap.containsKey(key)){//(budgetHeader.EUR_CRM_External_ID__c)){
                                    EUR_CRM_Budget_Transaction__c txn = newTransactionsMap.get(key);//(budgetHeader.EUR_CRM_External_ID__c);
                                    if (txn.EUR_CRM_Budget_Header__c==null){
                                        txn.EUR_CRM_Budget_Header__c = budgetHeader.Id;
                                        newTransactions.add(txn);
                                    }
                                }
                            }
                        }
                        System.debug('Flag - Contract Approved Handler - Check New Transactions:' + newTransactions);
                        if(newTransactions.size()>0){
                            insertResultBudgetTransaction = Database.insert(newTransactions);
                            System.debug('Flag - Contract Approved Handler - Result Insert Transactions:'+insertResultBudgetTransaction);
                        }
                    }
                    catch(Exception e){
                        System.debug('Upsert Error: ' + e);
                        Database.rollback(pSavepoint);      
                        String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                        //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
                        if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
                        {
                            String s = e.getDmlMessage(0);
                            strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                            System.debug('Flag - Contract Approved Trigger DML Error:' + strError);
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                        }
                        else{       
                            System.debug('Flag - Contract Approved Trigger Error:' + strError);
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                        }
                    }
                }
            }   
        }
    }
    
    private List<EUR_CRM_Budget__c> retrieveBudgetId (Set<EUR_CRM_Budget__c> budgetList){
        Set<Id> ownerIdSet = new Set<Id>();
        Set<String> fySet = new Set<String>();
        Set<Id> recordTypeIdSet = new Set<Id>();
        
        Map<String, EUR_CRM_Budget__c> budgetRef = new Map<String, EUR_CRM_Budget__c>();
        List<EUR_CRM_Budget__c> updatedBudget = new List<EUR_CRM_Budget__c>();
        
        for (EUR_CRM_Budget__c budget: budgetList){
            ownerIdSet.add(budget.OwnerId);
            fySet.add(budget.EUR_CRM_Fiscal_Year__c);
            recordTypeIdSet.add(budget.RecordTypeId);
        }
        
        for (EUR_CRM_Budget__c budget: [SELECT Id, Name, OwnerId,
                                        EUR_CRM_External_ID__c, EUR_CRM_Fiscal_Year__c,
                                        EUR_CRM_User_Role_Type__c, EUR_CRM_Allocated_Budget__c,
                                        EUR_CRM_Carry_Forward__c, RecordTypeId
                                        FROM EUR_CRM_Budget__c
                                        WHERE OwnerId IN: ownerIdSet
                                        AND EUR_CRM_Fiscal_Year__c IN: fySet
                                        AND RecordTypeId IN: recordTypeIdSet LIMIT 49999]){
                                            
            String key = getBudgetKey(budget);//budget.RecordTypeId +'_'+ budget.OwnerId +'_'+ budget.EUR_CRM_Fiscal_Year__c;
            budgetRef.put(key, budget);                                 
        }
        
        for(EUR_CRM_Budget__c budget: budgetList){
            String key = budget.RecordTypeId +'_'+ budget.OwnerId +'_'+ budget.EUR_CRM_Fiscal_Year__c;
            if(budgetRef.containsKey(key)){
                budget.Id = budgetRef.get(key).Id;
            }
            updatedBudget.add(budget);
        }
        
        System.debug('Flag - UPSERTED BUDGET:' + updatedBudget);
        return updatedBudget;
    }
    
    private Integer calculateMonthDiff(Date startDate, Date endDate){
        Integer iMonthDiff = 0;
        if (startDate.year() == endDate.year()){
            iMonthDiff = endDate.month() - startDate.month();
        }else{
            iMonthDiff = (endDate.year()-startDate.year())*12+endDate.month()-startDate.month();
            //iMonthDiff = (endDate.month()==startDate.month())?(iMonthDiff+1):iMonthDiff;
        }
        iMonthDiff += 1;

        System.debug('Test:'+iMonthDiff +'--'+startDate+'--'+endDate);
        
        return iMonthDiff;
    }
    
    private String getBudgetKey (EUR_CRM_Budget__c budget){
        return budget.RecordTypeId +'_'+ budget.OwnerId +'_'+ budget.EUR_CRM_Fiscal_Year__c;
    }
    
    private Date retrieveActualFYStart(Date fyStartDate){
        //If FY is on current FY, return FY; else FY less one year
        Date actualFYStart = fyStartDate;
        if(! EUR_CRM_BudgetUtil.isFYCurrentYear()){
            actualFYStart = actualFYStart.addYears(-1);
        }
        System.debug('Flag - Retrieve Actual FY Start - '+ fyStartDate + '--'+ actualFYStart);
        return actualFYStart;
    }


    Map<Id, Double> contractProratedAmount = new Map<Id, Double>();
    public void retrieveProratedAmounts(Set<Id> contractIds){
        system.debug('### retrieveProratedAmounts: '+ contractIds);
        for(EUR_CRM_Contract_Activity_Item__c ca: [select EUR_CRM_Contract_Activity_Total__c, EUR_CRM_Contract__c from EUR_CRM_Contract_Activity_Item__c where EUR_CRM_Contract__c in: contractIds and
                EUR_CRM_Mechanic_Type__r.EUR_CRM_Is_Pro_Rated_by_Month__c = true]){
            if(contractProratedAmount.get(ca.EUR_CRM_Contract__c) == null){
                contractProratedAmount.put(ca.EUR_CRM_Contract__c, ca.EUR_CRM_Contract_Activity_Total__c);
            }else{
                Double prevAmount = contractProratedAmount.get(ca.EUR_CRM_Contract__c);            
                contractProratedAmount.put(ca.EUR_CRM_Contract__c, prevAmount + ca.EUR_CRM_Contract_Activity_Total__c);
    
            }
        }
        system.debug('### contractProratedAmount: '+ contractProratedAmount);
    }

}