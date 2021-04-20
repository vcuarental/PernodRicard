public with sharing class EUR_CRM_DE_BudgetTransferController {
        private final String TRANSFER = 'Transfer';
        public final String DEBIT {get; private set;} {DEBIT = 'Debit';}
        public final String CREDIT {get; private set;} {CREDIT = 'Credit';}
        
        private EUR_CRM_Budget__c budget;
        private Id transactionRecordtype;
        
        private Set<Id> subordinateUserIdSet {get;set;}{subordinateUserIdSet = new Set<Id>();}
        private Map<Id, EUR_CRM_Budget__c> subordinateBudgets{get;set;}{subordinateBudgets = new Map<Id, EUR_CRM_Budget__c>();}
        private Map<Id, User> subordinateUsers{get;set;}{subordinateUsers = new Map<Id, User>();}
        
        //private Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        //Schema.SObjectType leadSchema = schemaMap.get(type);
        private Map<String, Schema.SObjectField> transactionFieldMap {get;set;}// leadSchema.getDescribe().fields.getMap();
        
        public EUR_CRM_Budget_Transaction__c budgetTransactionFrom {get;set;}{budgetTransactionFrom = new EUR_CRM_Budget_Transaction__c(EUR_CRM_Amount__c=0  );}
        public EUR_CRM_Budget_Transaction__c budgetTransactionTo {get;set;}{budgetTransactionTo = new EUR_CRM_Budget_Transaction__c();}
        public EUR_CRM_Budget__c budgetFrom {get;set;}{budgetFrom = new EUR_CRM_Budget__c();}
        public EUR_CRM_Budget__c budgetTo {get;set;}{budgetTo = new EUR_CRM_Budget__c();}
        public Set<Id> userOptions {get;set;}{userOptions = new Set<Id>();}
        
        public List<SelectOption> transferorOptions {get{
                List<SelectOption> fromOptions = new List<SelectOption>();
                Map<Id, User> fromUsers = new Map<Id, User>();
                fromUsers.putAll(subordinateUsers);
                
                if (budgetTo.Id!=null){
                        fromUsers.remove(budgetTo.OwnerId);
                }
                fromOptions.add(new SelectOption('', '-None-'));
                for (User u: fromUsers.values()){
                        if (subordinateBudgets.containsKey(u.Id)){
                                fromOptions.add(new SelectOption(u.Id, u.Name));
                        }
                }
                
                return fromOptions;
        }}//{transferorOptions = new List<SelectOption>();}
        
        public List<SelectOption> transfereeOptions {get{
                List<SelectOption> toOptions = new List<SelectOption>();
                Map<Id, User> toUsers = new Map<Id, User>();
                toUsers.putAll(subordinateUsers);
                
                if (budgetFrom.Id!=null){
                        toUsers.remove(budgetFrom.OwnerId);
                }
                toOptions.add(new SelectOption('', '-None-'));
                for (User u: toUsers.values()){
                        if (subordinateBudgets.containsKey(u.Id)){
                                toOptions.add(new SelectOption(u.Id, u.Name));
                        }
                }
                
                return toOptions;
        }}//{transfereeOptions = new List<SelectOptions>();}
        
        public Double runningBalanceFrom{get{
                if (budgetFrom.Id!=null && budgetTransactionFrom.EUR_CRM_Amount__c!=null){
                        Double amt = (budgetFrom.EUR_CRM_Current_Balance__c==null)?0:budgetFrom.EUR_CRM_Current_Balance__c;
                        return (amt - budgetTransactionFrom.EUR_CRM_Amount__c); 
                }
                return 0;
        }set;}
        public Double runningBalanceTo{get{
                if (budgetFrom.Id!=null && budgetTransactionFrom.EUR_CRM_Amount__c!=null){
                        Double amt = (budgetTo.EUR_CRM_Current_Balance__c==null)?0:budgetTo.EUR_CRM_Current_Balance__c;
                        return (amt + budgetTransactionFrom.EUR_CRM_Amount__c); 
                }
                return 0;
        }set;}
        
        
        //public Double runningBalanceFrom{get;set;}{runningBalanceFrom=0;}
        //public Double runningBalanceTo{get;set;}{runningBalanceTo=0;}
        
        public EUR_CRM_DE_BudgetTransferController(ApexPages.StandardController stdController){
            this.budget = (EUR_CRM_Budget__c)stdController.getRecord();
            this.transactionRecordtype = [select id from RecordType where developername = 'EUR_DE_On_Trade_WKZ' and sobjecttype = 'EUR_CRM_Budget_Transaction__c'].id;
            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType transactionSchema = schemaMap.get('EUR_CRM_Budget_Transaction__c');
            transactionFieldMap = transactionSchema.getDescribe().fields.getMap();

            
            subordinateUserIdSet = EUR_CRM_RoleUtils.getRoleSubordinateUsers(this.budget.OwnerId);
            subordinateBudgets = retrieveSubordinateBudgets(subordinateUserIdSet, this.budget.EUR_CRM_Fiscal_Year__c);//filter(subordinateUserIdSet, this.budget.EUR_CRM_Fiscal_Year__c);
            subordinateUsers = retrieveUsers(subordinateUserIdSet);
            
            System.debug('flag - Init Budget Transfer Controller:'+subordinateUserIdSet+'--'+subordinateBudgets);
        }
        
        public PageReference quickSave(){
                PageReference pageRef = null;
                //quickSave();
                pageRef = new PageReference('/' + this.budget.Id); 
        pageRef.setRedirect(true); 
                return pageRef;
        }
        
        public PageReference save(){
                System.debug('Flag - Quick Save');
                PageReference pageRef = null;
                Boolean isDone = false;
                List<EUR_CRM_Budget_Transaction__c> budgetTransactionsList = new List<EUR_CRM_Budget_Transaction__c>();
                 
                if(validateTransaction()){
                        //Budget Transaction From
                        budgetTransactionFrom.EUR_CRM_Budget_Header__c = budgetFrom.Id;
                        budgetTransactionFrom.EUR_CRM_Transaction_Category__c = TRANSFER;
                        budgetTransactionFrom.EUR_CRM_Transaction_Type__c = DEBIT;
                        budgetTransactionFrom.recordtypeid = transactionRecordtype;
                        budgetTransactionsList.add(budgetTransactionFrom);
                        
                        //Budget Transaction To
                        budgetTransactionTo.EUR_CRM_Budget_Header__c = budgetTo.Id;
                        budgetTransactionTo.EUR_CRM_Transaction_Category__c = TRANSFER;
                        budgetTransactionTo.EUR_CRM_Transaction_Type__c = CREDIT;
                        budgetTransactionTo.recordtypeid = transactionRecordtype;
                        budgetTransactionTo.EUR_CRM_Transfer_From__c = budgetTransactionFrom.EUR_CRM_Transfer_From__c;
                        budgetTransactionTo.EUR_CRM_Transfer_To__c = budgetTransactionFrom.EUR_CRM_Transfer_To__c;
                        budgetTransactionTo.EUR_CRM_Amount__c = budgetTransactionFrom.EUR_CRM_Amount__c;
                        budgetTransactionTo.EUR_CRM_Description__c = budgetTransactionFrom.EUR_CRM_Description__c;
                        budgetTransactionsList.add(budgetTransactionTo);
                        
                        isDone = true;
                }
                
                if (budgetTransactionsList.size()>0){
                        try{
                                Database.insert(budgetTransactionsList);
                        }catch(Exception e){
                                System.debug('Save Budget Transfer - Database Insert Error:'+e);
                        }
                }
                
                if (isDone){
                        pageRef = new PageReference('/' + this.budget.Id); 
                pageRef.setRedirect(true);
                }
                
                return pageRef;
        }
        
        public PageReference retrieveUserOptions(){
                PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String paramExcludedUser = params.get('EXCLUDED_USER');
        userOptions = subordinateUserIdSet;
        if (paramExcludedUser!=null && userOptions.contains(Id.valueOf(paramExcludedUser))){
                userOptions.remove(Id.valueOf(paramExcludedUser));
        }
        return pageRef;
        }
        
        public PageReference budgetFromOnChange(){
                PageReference pageRef = null;
                Id userId = budgetTransactionFrom.EUR_CRM_Transfer_From__c;
                String fy = this.budget.EUR_CRM_Fiscal_Year__c;
                budgetFrom = new EUR_CRM_Budget__c();
                if (subordinateBudgets.containsKey(userId)){
                        budgetFrom = subordinateBudgets.get(userId);//retrieveUserBudget(userId, fy);
                        runningBalanceFrom = budgetFrom.EUR_CRM_Current_Balance__c - budgetTransactionFrom.EUR_CRM_Amount__c;
                }else if(userId==''){
                        budgetTransactionFrom.EUR_CRM_Transfer_From__c = '';
                        budgetFrom = new EUR_CRM_Budget__c();
                }
                System.debug('Flag - Budget From OnChange:' + budgetFrom+'--'+userId+'--'+subordinateBudgets);
                return pageRef;
        }
        
        public PageReference budgetToOnChange(){
                PageReference pageRef = null;
                Id userId = budgetTransactionFrom.EUR_CRM_Transfer_To__c;
                String fy = this.budget.EUR_CRM_Fiscal_Year__c;
                budgetTo = new EUR_CRM_Budget__c();
                if (subordinateBudgets.containsKey(userId)){
                        budgetTo = subordinateBudgets.get(userId);//retrieveUserBudget(userId, fy);
                        runningBalanceTo = budgetTo.EUR_CRM_Current_Balance__c + budgetTransactionFrom.EUR_CRM_Amount__c;
                }else if(userId==''){
                        budgetTransactionFrom.EUR_CRM_Transfer_To__c = '';
                        budgetTo = new EUR_CRM_Budget__c();
                }
                System.debug('Flag - Budget To OnChange:' + budgetTo+'--'+userId+'--'+subordinateBudgets);
                return pageRef;
        }
        
        private Boolean validateTransaction(){
                Boolean isValid = true;
                //Validate Transfer From Amount not less than 0
                if (budgetFrom.Id==null){
                        isValid = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.EUR_CRM_Missing_Required_Field +' '+ transactionFieldMap.get('EUR_CRM_Transfer_From__c').getDescribe().getLabel()));
                }
                if (budgetTo.Id==null){
                        isValid = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.EUR_CRM_Missing_Required_Field +' '+ transactionFieldMap.get('EUR_CRM_Transfer_To__c').getDescribe().getLabel()));
                }
                if (runningBalanceFrom<0){
                        isValid = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.EUR_CRM_Amt_Lt_Budget));
                }
                if (budgetTransactionFrom!=null && (budgetTransactionFrom.EUR_CRM_Amount__c==null || budgetTransactionFrom.EUR_CRM_Amount__c<=0)){
                        isValid = false;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.EUR_CRM_Amt_Gt_0));
                }
                return isValid;
        }
        /*
        private EUR_CRM_Budget__c retrieveUserBudget(Id userId, String fy){
                EUR_CRM_Budget__c userBudget = new EUR_CRM_Budget__c();
                
                if (userId !=null && fy!=null){
                        List<EUR_CRM_Budget__c> tempBudgets = [SELECT Id, Name, OwnerId,
                                                                                                EUR_CRM_Actual_Budget__c, EUR_CRM_Allocated_Budget__c,
                                                                                                EUR_CRM_Current_Balance__c, EUR_CRM_External_ID__c, EUR_CRM_Fiscal_Year__c
                                                                                                FROM EUR_CRM_Budget__c 
                                                                                                WHERE OwnerId =: userId
                                                                                                AND EUR_CRM_Fiscal_Year__c =:fy
                                                                                                LIMIT 1];
                        if (tempBudgets.size()>0)
                                userBudget = tempBudgets.get(0);
                }
                return userBudget;
        }
        */
        private Map<Id, EUR_CRM_Budget__c> retrieveSubordinateBudgets(Set<Id> subordinateUserId, String fiscalYear){
        Map<Id, EUR_CRM_Budget__c> subBudgets = new Map<Id, EUR_CRM_Budget__c> ();
        
        List<EUR_CRM_Budget__c> subBudgetList = [SELECT Id,Owner.Name,
                                                                                EUR_CRM_Current_Balance__c, EUR_CRM_Actual_Budget__c,
                                                                                EUR_CRM_Allocated_Budget__c, EUR_CRM_Fiscal_Year__c,
                                                                                Name,OwnerId 
                                                                    FROM EUR_CRM_Budget__c 
                                                                    WHERE ownerId IN: subordinateUserId
                                                                    AND EUR_CRM_Fiscal_Year__c=:fiscalYear]; // add more filter
        
        for(EUR_CRM_Budget__c budget: subBudgetList){
                subBudgets.put(budget.OwnerId, budget);
            //userBudgetMap.put(budget.ownerId, budget.id);
            //budgetHeaderMap.put(budget.id,budget);
        }
        return subBudgets;
    }
    
    private Map<Id, User> retrieveUsers(Set<Id> userSet){
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User Where Id IN: userSet LIMIT 49999]);
        
        return userMap;
    }
}