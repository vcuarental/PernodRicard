/*********************************************************************************
 * Name: EUR_CRM_BudgetManagementPageController
 * Description: Budget Management Controller to allocate the budget 
 *
 * Version History
 * Date				Developer				Comments
 * ---------------	--------------------	--------------------------------------------------------------------------------
 * 9/24/2015		Conrad					Added Comment Header and added Record type control
 * 6/2/2017			PARX (sia)				Added pagination methods to handle postback (goPreviousPage, goNextPage...)
 *	
*********************************************************************************/
public with sharing class EUR_CRM_BudgetManagementPageController{

	/*
	*	Map Budget recordtype to its corresponding Transaction Recordtype
	*/
	public final Map<String, String> budgetToTransactionMap = new Map<String,String>{
        'EUR_DE_On_Trade_WKZ'=>'EUR_DE_On_Trade_WKZ',
        'EUR_ZA_On_Trade_Budget'=>'EUR_ZA_On_Trade_Transaction'
    };
	
    public final String DEBIT {get; private set;} {DEBIT = 'Debit';}
    public final String CREDIT {get; private set;} {CREDIT = 'Credit';}
    
    private EUR_CRM_Budget__c budget;
    private ID budgetId;
    private List<EUR_CRM_Budget__c> subBudgets;
    public List<ManageItem> manageItemList {get; set;}
    private List<EUR_CRM_Budget_Transaction__c> budgetTransactionList;
    private Map<Id,EUR_CRM_Budget_Transaction__c> budgetMap;
    private Map<Id,Id> userBudgetMap;
    
    public List<ManageItem> displayList {get;set;}
    public String pageMark {get;set;}
    public Integer maxPage {get;set;}
    public Integer curPage {get;set;}
    public Map<Integer, List<ManageItem>> mainMap {get;set;}
    Integer recordsPerPage = 20; 
    private Id transactionRecordtype;
    private Map<Id,EUR_CRM_Budget__c> budgetHeaderMap;
    private Set<Id>subordinateUserIdSet = new Set<Id>();
        
    public EUR_CRM_BudgetManagementPageController(ApexPages.StandardController stdController) {
        this.budget = (EUR_CRM_Budget__c)stdController.getRecord();
        this.budgetId = stdController.getRecord().id;
        userBudgetMap = new Map<Id,Id>();
        budgetMap = new Map<Id,EUR_CRM_Budget_Transaction__c>();
        budgetHeaderMap = new Map<Id,EUR_CRM_Budget__c>();
                
        subordinateUserIdSet = EUR_CRM_RoleUtils.getRoleSubordinateUsers(this.budget.OwnerId);
        filter(subordinateUserIdSet, this.budget.EUR_CRM_Fiscal_Year__c);
        displaylist = new List<ManageItem>();
        pageMark    = 'first';
        curPage     = 1;
        maxPage     = 1;
        getManageItemList(); 
        buildDisplayList();
        Recordtype budgetRT = Global_RecordTypeCache.getRt(budget.recordtypeID);
        transactionRecordtype = Global_RecordTypeCache.getRtId('EUR_CRM_Budget_Transaction__c'+budgetToTransactionMap.get(budgetRT.developerName));
        //transactionRecordtype = [select id from RecordType where developername = 'EUR_DE_On_Trade_WKZ' and sobjecttype = 'EUR_CRM_Budget_Transaction__c'].id;
        
    }
    
    //select all the appropriate budget under the current budget    
    public void filter(Set<Id> subordinateUserId, String fiscalYear){
        
        subBudgets = [select id,owner.name,EUR_CRM_Current_Balance__c, name,ownerId 
                                                from EUR_CRM_Budget__c 
                                                WHERE ownerId IN: subordinateUserId
                                                AND EUR_CRM_Fiscal_Year__c=:fiscalYear]; // add more filter
        
        for(EUR_CRM_Budget__c budget: subBudgets){
            userBudgetMap.put(budget.ownerId, budget.id);
            budgetHeaderMap.put(budget.id,budget);
        }
        
    }
    
    public  List<ManageItem> getManageItemList(){
        manageItemList = new List<ManageItem>();
        budgetTransactionList = new List<EUR_CRM_Budget_Transaction__c>();
        for(EUR_CRM_Budget__c budget : subBudgets){
            manageItemList.add(new ManageItem(budget.owner.name, budget.name, budget.id, budget.EUR_CRM_Current_Balance__c));
        } 
        return manageItemList;
    }
    
    //create two set of budget transactions, one for the current budget and another one subordinate budgets
    public PageReference quickSave(){
        PageReference pageRef = null;
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        List<EUR_CRM_Budget_Transaction__c> budgetTransactionsList = new List<EUR_CRM_Budget_Transaction__c>();
        List<EUR_CRM_Budget_Transaction__c> subBudgetTransactionsList = new List<EUR_CRM_Budget_Transaction__c>();
        system.debug('++saving...');
        List<ManageItem> tempManageList = new List<ManageItem>();
        try{
            if (validateBudgetTransfers()){
                for(integer i = 1;i <= maxPage;i++){
                    tempManageList.addAll(mainMap.get(i));
                }
                system.debug('@@TEMPAMANAGELIST: '+tempManageList);
                for(ManageItem item: tempManageList){
                    system.debug('++ budget'+ item.budget + ', newBudget' + item.newBudget+', ' +item.saveFlag);
                    //Decimal amount = Decimal.valueOf((item.newBudget).replace(',',''));
                    
                    if(item.budgetTransactions!=null){//if( amount > 0){ 
                        if(item.budgetTransactions.containsKey(CREDIT)){
                            Decimal cAmount = Decimal.valueOf((item.budgetTransactions.get(CREDIT)).replace(',',''));
                            if(cAmount>0){
                                subBudgetTransactionsList.add(new EUR_CRM_Budget_Transaction__c(EUR_CRM_Budget_Header__c = item.budget,
                                EUR_CRM_Amount__c = cAmount,
                                EUR_CRM_Transaction_Category__c = 'Transfer',
                                EUR_CRM_Transaction_Type__c = 'Credit', 
                                recordtypeid = transactionRecordtype,
                                EUR_CRM_Description__c = 'Manage Budget',
                                EUR_CRM_Transfer_From__c = budget.ownerId,
                                EUR_CRM_Transfer_To__c = budgetHeaderMap.get(item.budget).ownerid));
                                
                                budgetTransactionsList.add(new EUR_CRM_Budget_Transaction__c(EUR_CRM_Budget_Header__c = budgetId,
                                EUR_CRM_Amount__c = cAmount,
                                EUR_CRM_Transaction_Category__c = 'Transfer',
                                EUR_CRM_Transaction_Type__c = 'Debit', 
                                recordtypeid = transactionRecordtype,
                                EUR_CRM_Description__c = 'Manage Budget',
                                EUR_CRM_Transfer_From__c = budget.ownerId,
                                EUR_CRM_Transfer_To__c = budgetHeaderMap.get(item.budget).ownerid));
                            }
                        }
                        if(item.budgetTransactions.containsKey(DEBIT)){
                            Decimal dAmount = Decimal.valueOf((item.budgetTransactions.get(DEBIT)).replace(',',''));
                            if(dAmount>0){
                                subBudgetTransactionsList.add(new EUR_CRM_Budget_Transaction__c(EUR_CRM_Budget_Header__c = item.budget,
                                EUR_CRM_Amount__c = dAmount,
                                EUR_CRM_Transaction_Category__c = 'Transfer',
                                EUR_CRM_Transaction_Type__c = 'Debit', 
                                recordtypeid = transactionRecordtype,
                                EUR_CRM_Description__c = 'Manage Budget',
                                EUR_CRM_Transfer_From__c = budgetHeaderMap.get(item.budget).ownerid, //budget.ownerId,
                                EUR_CRM_Transfer_To__c = budget.ownerId)); //budgetHeaderMap.get(item.budget).ownerid));
                                
                                budgetTransactionsList.add(new EUR_CRM_Budget_Transaction__c(EUR_CRM_Budget_Header__c = budgetId,
                                EUR_CRM_Amount__c = dAmount,
                                EUR_CRM_Transaction_Category__c = 'Transfer',
                                EUR_CRM_Transaction_Type__c = 'Credit', 
                                recordtypeid = transactionRecordtype,
                                EUR_CRM_Description__c = 'Manage Budget',
                                EUR_CRM_Transfer_From__c = budgetHeaderMap.get(item.budget).ownerid,//budget.ownerId,
                                EUR_CRM_Transfer_To__c = budget.ownerId));
                            }
                        }

                    }
                }   
                system.debug('@@SUBBUDGET: '+subBudgetTransactionsList);   
                    if(subBudgetTransactionsList.size() > 0 ){
                        system.debug('++ inserting');
                        insert subBudgetTransactionsList;
                        insert budgetTransactionsList;
                    }
            }else{
                //Add error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_Insufficient_Balance));
            }  
        }
        catch(Exception e){
            System.debug('Save Error: ' + e);
            Database.rollback(pSavepoint);      
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
            if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
            {
                String s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                System.debug('Flag - Budgement Management Save DML Error:' + strError);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            }
            else{       
                System.debug('Flag - Budget Management Save Error:' + strError);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
        }
        pageRef = new PageReference('/apex/EUR_CRM_BudgetManagementPage?id=' + budgetId); 
        pageRef.setRedirect(true); 
        return pageRef; 
    }
     public PageReference save(){
     quickSave();
     return exit();
     }
    public PageReference exit(){               
        PageReference pageRef = new PageReference('/' + budgetId); 
        pageRef.setRedirect(true); 
        return pageRef;         
    } 
    
    //PAGINATION
    public void buildDisplayList(){
        if(manageItemList.size() > 0){          
            Integer exceed = math.mod(manageItemList.size(), recordsPerPage);
            maxPage = manageItemList.size() / recordsPerPage;
            if(exceed != 0){
                maxPage += 1;
            }
                        
            Integer counter   = 0;
            Integer pageIndex = 1;
            mainMap = new Map<Integer, List<ManageItem>>();
            
            List<ManageItem> tempList = new List<ManageItem>();
            for(ManageItem p: manageItemList){
                if(counter == recordsPerPage){
                    mainMap.put(pageIndex, tempList);
                    tempList = new List<ManageItem>();
                    pageIndex++;
                    counter = 0;
                }
                tempList.add(p);
                counter++;
            }
            if(tempList.size() != 0){
                mainMap.put(pageIndex, tempList);
            }           
            displayList = mainMap.get(curPage);
        }
    }
    
    public void removeManageItem(){
        manageItemList.clear();
    }

	public void goToPage(){
        if(pageMark == 'prev' && curPage > 1){
            curPage = curPage - 1;  
        }
        else if(pageMark == 'next' && curPage < maxPage){
            curPage = curPage + 1;
        }
        else if(pageMark == 'first' && curPage > 1){
            curPage = 1;
        }
        else if(pageMark == 'last' && curPage < maxPage){
            curPage = maxPage;
        }       
        displayList = mainMap.get(curPage);
    }

    public void goPreviousPage(){
        if (curPage > 1) {
            curPage--;
        }
		displayList = mainMap.get(curPage);
    }

    public void goNextPage() {
        if (curPage < maxPage){
            curPage++;
        }
		displayList = mainMap.get(curPage);
    }

    public void goFirstPage() {
        curPage = 1;
		displayList = mainMap.get(curPage);
    }

    public void goLastPage() {
        curPage = maxPage;
		displayList = mainMap.get(curPage);
    }

    private Boolean validateBudgetTransfers(){
        System.debug('++Validating...');
        //Validate Current Budget Balance is greater than total transferred amount
        Double totalAmount = Double.valueOf(getBudgetTransferAmount());
        System.debug('Flag - Validate Budget Transfer:'+String.valueOf(this.budget.EUR_CRM_Current_Balance__c)+'-'+String.valueOf(totalAmount)+'-'+String.valueOf(Double.valueOf(this.budget.EUR_CRM_Current_Balance__c) < totalAmount));
        return (Double.valueOf(this.budget.EUR_CRM_Current_Balance__c) < totalAmount || Double.valueOf(this.budget.EUR_CRM_Current_Balance__c)<0)?false:true;
    }
    
    private Decimal getBudgetTransferAmount(){
        List<ManageItem> tempManageList = new List<ManageItem>();
        Decimal totalAmount = 0;
        for(integer i = 1;i <= maxPage;i++){
            tempManageList.addAll(mainMap.get(i));
        }
        system.debug('@@TEMPAMANAGELIST - Budget Transfer Amount: '+tempManageList);
        for(ManageItem item: tempManageList){
            system.debug('++ budget'+ item.budget + ', newBudget' + item.budgetTransactions+', ' +item.saveFlag);
            //Decimal amount = Decimal.valueOf((item.newBudget).replace(',',''));
            //totalAmount += amount;
            
            if(item.budgetTransactions!=null){//if( amount > 0){ 
                if(item.budgetTransactions.containsKey(CREDIT)){
                    Decimal cAmount = Decimal.valueOf((item.budgetTransactions.get(CREDIT)).replace(',',''));
                    totalAmount += cAmount;
                }
                if(item.budgetTransactions.containsKey(DEBIT)){
                    Decimal dAmount = Decimal.valueOf((item.budgetTransactions.get(DEBIT)).replace(',',''));
                    totalAmount -= dAmount;
                }
            }
        }
        
        return totalAmount;
    }
    
    public class ManageItem{
        private final String DEBIT = 'Debit';
        private final String CREDIT = 'Credit';
    
        public Id budget {get;set;}
        public String ownerName {get;set;}
        public String budgetName {get;set;}
        public String region {get;set;}
        public Decimal currentBudget {get;set;} 
        public String newBudget {get;set;}        
        public Decimal resultingBudget {get;set;}
        public Boolean saveFlag{get;set;}
        
        public Map<String, String> budgetTransactions {get;set;}{budgetTransactions=new Map<String, String>();}
        
        public ManageItem(String ownerName, String budgetName, Id budgetId,Decimal currentBudget){
            this.budget = budgetId;
            this.currentBudget = currentBudget;
            this.resultingBudget = currentBudget;
            this.ownerName = ownerName;
            this.budgetName = budgetName;
            this.saveFlag = true;
            newBudget = '0';
            
            budgetTransactions = new Map<String, String>{DEBIT=>'0', CREDIT=>'0'}; 
        } 
    }
}