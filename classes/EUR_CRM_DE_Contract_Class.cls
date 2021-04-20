public with sharing virtual class EUR_CRM_DE_Contract_Class {
    public static String CONTRACT_MECHANIC_TABLE_PREFIX {get{return 'ContractMechanicTable_';}}
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    public static String CONTRACT_SUMMARY_ITEM_PREFIX {get{ return 'ContractItemSummaryTable_';}}
    public static String DESCRIPTION_PREFIX {get{ return 'DESC--';}}
    public static String CURRENT_CONTRACT_ACTIVITY_FLAG {get{ return 'CURRENT_CA_FLAG';}}
    public static String FLAGSHIP {get{return 'FLAGSHIP';}}
    
    private Id contractId{get;set;}
    
    public EUR_CRM_DE_Contract_Class(){}
    public EUR_CRM_DE_Contract_Class(Id contractId){
        this.contractId = contractId;
    }
    
    public EUR_CRM_Contract__c retrieveContractDetails(Id contractId){
        if ( contractId != null){
            List<EUR_CRM_Contract__c> contractList = [SELECT Id, Name, 
                                                    EUR_CRM_Account__c,
                                                    EUR_CRM_Contact__c,
                                                    EUR_CRM_Country_Code__c,
                                                    EUR_CRM_Contract_Type__c,
                                                    EUR_CRM_End_Date__c,
                                                    EUR_CRM_Nominated_Supplier__c,
                                                    EUR_CRM_Payment_Method__c,
                                                    EUR_CRM_Start_Date__c,
                                                    EUR_CRM_Status__c,
                                                    EUR_CRM_Active__c,
                                                    EUR_CRM_Contract_Approved_Date__c,
                                                    EUR_CRM_Total_Contract_Line_Items__c
                                                    FROM EUR_CRM_Contract__c
                                                    WHERE Id =: contractId];
            if (contractList.size()>0){
                EUR_CRM_Contract__c contract = contractList.get(0);
                return contract;
            }
        }
        return null;
    }
    
    public Map<Id, EUR_CRM_Contract_Focus_Brand__c> retrieveFocusBrands(Id contractObjId){
        Map<Id, EUR_CRM_Contract_Focus_Brand__c> focusBrands = new Map<Id, EUR_CRM_Contract_Focus_Brand__c>();
        
        for (EUR_CRM_Contract_Focus_Brand__c focusBrand : [SELECT Id, Name, 
                                                        EUR_CRM_Contract__c, EUR_CRM_Brand__c,
                                                        EUR_CRM_Brand__r.Name,
                                                        EUR_CRM_Name_Reference__c 
                                                        FROM EUR_CRM_Contract_Focus_Brand__c
                                                        WHERE EUR_CRM_Contract__c =: contractObjId])
        {
            focusBrand.EUR_CRM_Name_Reference__c = (focusBrand.EUR_CRM_Name_Reference__c == null) ? focusBrand.EUR_CRM_Brand__r.Name : focusBrand.EUR_CRM_Name_Reference__c;
            focusBrands.put(focusBrand.EUR_CRM_Brand__c, focusBrand);
        }
        System.debug('Flag - Focus Brand Component - Existing Focus Brands:' + focusBrands);
        return focusBrands;
    }
    
    public Map<Id, EUR_CRM_Contract_Listing_Pouring__c> retrieveListingPouring(Id contractObjId){
        Map<Id, EUR_CRM_Contract_Listing_Pouring__c> listingPouringMap = new Map<Id, EUR_CRM_Contract_Listing_Pouring__c>();
        for (EUR_CRM_Contract_Listing_Pouring__c listingPouring: [SELECT Id, Name,
                                                                EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c, 
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                                                                EUR_CRM_Contract__c, 
                                                                EUR_CRM_Listing__c, EUR_CRM_Pouring__c,
                                                                EUR_CRM_Name_Reference__c
                                                                FROM EUR_CRM_Contract_Listing_Pouring__c
                                                                WHERE EUR_CRM_Contract__c=:contractObjId])
        {
            listingPouring.EUR_CRM_Name_Reference__c = listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            listingPouringMap.put(listingPouring.EUR_CRM_Brand_Quality__c, listingPouring);
        }
        
        return listingPouringMap;
    }

    
    public Map <Id, EUR_CRM_Mechanic_Type__c> retrieveMechanicTypes(EUR_CRM_Contract__c contractObj){
        Map <Id, EUR_CRM_Mechanic_Type__c> mechanicTypeMap;
        
        mechanicTypeMap = new Map <Id, EUR_CRM_Mechanic_Type__c>([SELECT Id, Name, EUR_CRM_Country_Code__c,
                                                            EUR_CRM_Grouping_Name__c,
                                                            EUR_CRM_Has_End_Date__c, EUR_CRM_Has_Lump_Sum__c,
                                                            EUR_CRM_Has_Per_BQ__c, EUR_CRM_Has_Start_Date__c,
                                                            EUR_CRM_Has_Vendor__c, EUR_CRM_Lump_Sum_Or_Per_BQ__c,
                                                            EUR_CRM_Mechanic_Process_Type__c, EUR_CRM_Has_Multiple_Activity_Item__c,
                                                            EUR_CRM_Has_Payment_Term__c, EUR_CRM_Has_Budget_Exclusion_Option__c,
                                                            EUR_CRM_For_Compliance_Check__c, EUR_CRM_Mechanic_Type_Name_English__c
                                                            FROM EUR_CRM_Mechanic_Type__c
                                                            WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c]);
        return mechanicTypeMap;
    }
    
    public Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> retrieveContractActivityItems(EUR_CRM_Contract__c contractObj){
        Map <Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivityMap = new Map <Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();
        
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem: [SELECT Id, Name, 
                                                                EUR_CRM_Amount__c, EUR_CRM_Contract__c,
                                                                EUR_CRM_End_Date__c, EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Mechanic_Type__r.Name,
                                                                EUR_CRM_Name__c, EUR_CRM_Payment_Term__c,
                                                                EUR_CRM_Product_Items_Total__c, EUR_CRM_Product_Items_Count__c,
                                                                EUR_CRM_Start_Date__c, EUR_CRM_Vendor__c,
                                                                EUR_CRM_Exclude_Budget_Deduction__c,
                                                                EUR_CRM_Description__c, EUR_CRM_PR_DE_Flag__c,
                                                                EUR_CRM_Contract_Activity_Total__c,
                                                                (SELECT EUR_CRM_Brand__c,
                                                                 EUR_CRM_List_of_Brand__c,
                                                                 EUR_CRM_CPPP_Amount__c,
                                                                 EUR_CRM_CPPP_Unit__c,
                                                                 EUR_CRM_Contract_Payment_Plan__c,
                                                                 EUR_CRM_Contract_Product_Item__c,
                                                                 EUR_CRM_CPPP_Earliest_Date_of_Invoice__c,
                                                                 EUR_CRM_Payment_Period_End_Date__c,
                                                                 EUR_CRM_Payment_Period_Start_Date__c,
                                                                 EUR_CRM_CPPP_Payment_Term__c, EUR_CRM_CPPP_Rate__c,
                                                                 EUR_CRM_CPPP_Volume__c,
                                                                 EUR_CRM_Description__c
                                                                 FROM Contract_Payment_Plan_Periods__r
                                                                 ORDER BY Id ASC)
                                                                FROM EUR_CRM_Contract_Activity_Item__c
                                                                WHERE EUR_CRM_Contract__c =: contractObj.Id])
        {
                //contractActivityMap Key
                Id contractActivityKey = contractActivityItem.EUR_CRM_Mechanic_Type__c;
                //caItemMap Key
                String key = contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c;
                Map<String, EUR_CRM_Contract_Activity_Item__c> caItemMap = (contractActivityMap.containsKey(contractActivityKey))?contractActivityMap.get(contractActivityKey):new Map<String, EUR_CRM_Contract_Activity_Item__c>();
                caItemMap.put(key, contractActivityItem);
                
                contractActivityMap.put(contractActivityKey, caItemMap);
        }
        
        return contractActivityMap;
    }
    
    public Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> retrieveContractActivityItems(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Mechanic_Type__c> mechanicTypes){
        Map <Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivityMap = new Map <Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();
        
        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem: [SELECT Id, Name, 
                                                                EUR_CRM_Amount__c, EUR_CRM_Contract__c,
                                                                EUR_CRM_End_Date__c, EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Mechanic_Type__r.Name,
                                                                EUR_CRM_Name__c, EUR_CRM_Payment_Term__c,
                                                                EUR_CRM_Start_Date__c, EUR_CRM_Vendor__c,
                                                                EUR_CRM_Product_Items_Total__c, EUR_CRM_Product_Items_Count__c,
                                                                EUR_CRM_Exclude_Budget_Deduction__c,
                                                                EUR_CRM_Description__c, EUR_CRM_PR_DE_Flag__c,
                                                                EUR_CRM_Contract_Activity_Total__c
                                                                FROM EUR_CRM_Contract_Activity_Item__c
                                                                WHERE EUR_CRM_Contract__c =: contractObj.Id
                                                                AND EUR_CRM_Mechanic_Type__c IN:mechanicTypes])
        {
                //contractActivityMap Key
                Id contractActivityKey = contractActivityItem.EUR_CRM_Mechanic_Type__c;
                //caItemMap Key
                String key = contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c;
                Map<String, EUR_CRM_Contract_Activity_Item__c> caItemMap = (contractActivityMap.containsKey(contractActivityKey))?contractActivityMap.get(contractActivityKey):new Map<String, EUR_CRM_Contract_Activity_Item__c>();
                caItemMap.put(key, contractActivityItem);
                
                contractActivityMap.put(contractActivityKey, caItemMap);
        }
        
        return contractActivityMap;
    }
    
    
    public Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> retrieveContractProductItems(EUR_CRM_Contract__c contractObj){
        Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> contractProductMap = new Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>>();
        system.debug('@contractObj');

        for (EUR_CRM_Contract_Product_Item__c contractProductItem: [SELECT Id, Name,
                                                                EUR_CRM_Brand__c,
                                                                EUR_CRM_Brand__r.Name,
                                                                EUR_CRM_Brand_Quality__c,
                                                                EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c,
                                                                EUR_CRM_Contract_Activity_Item__r.Name,
                                                                EUR_CRM_Description__c, EUR_CRM_Quantity__c,
                                                                EUR_CRM_Amount__c, EUR_CRM_Amount_Spent__c,
                                                                EUR_CRM_Unit__c, EUR_CRM_Name_Reference__c,
                                                                EUR_CRM_Exclusive__c,
                                                                EUR_CRM_With_Logo__c
                                                                FROM EUR_CRM_Contract_Product_Item__c
                                                                WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c=:contractObj.Id])
        {
            //contractProductMap Key
            String contractProductKey = contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c +'-'+ contractProductItem.EUR_CRM_Contract_Activity_Item__r.Name;
            //cpItemMap Key
            String key = (contractProductItem.EUR_CRM_Brand__c!=null)?contractProductItem.EUR_CRM_Brand__c:contractProductItem.EUR_CRM_Brand_Quality__c;
            key = (contractProductItem.EUR_CRM_Brand__c==null && contractProductItem.EUR_CRM_Brand_Quality__c==null)?(DESCRIPTION_PREFIX+contractProductItem.Id):key;
            Map <String, EUR_CRM_Contract_Product_Item__c> cpItemMap = (contractProductMap.containsKey(contractProductKey))?contractProductMap.get(contractProductKey):new Map <String, EUR_CRM_Contract_Product_Item__c>(); 
            
            //System Field Update
            if (contractProductItem.EUR_CRM_Brand__r.Name != null){
                    contractProductItem.EUR_CRM_Name_Reference__c = contractProductItem.EUR_CRM_Brand__r.Name;
            }
            else if (contractProductItem.EUR_CRM_Brand_Quality__r.Name != null){
                    contractProductItem.EUR_CRM_Name_Reference__c = contractProductItem.EUR_CRM_Brand_Quality__r.Name;
            }
            
            cpItemMap.put(key, contractProductItem);
            
            contractProductMap.put(contractProductKey, cpItemMap);
        }
        
        return contractProductMap;
    }
    
    public Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> retrieveContractProductItems(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Mechanic_Type__c> mechanicTypes){
        Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> contractProductMap = new Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>>();
        
        for (EUR_CRM_Contract_Product_Item__c contractProductItem: [SELECT Id, Name,
                                                                EUR_CRM_Brand__c,
                                                                EUR_CRM_Brand__r.Name,
                                                                EUR_CRM_Brand_Quality__c,
                                                                EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c,
                                                                EUR_CRM_Contract_Activity_Item__r.Name,
                                                                EUR_CRM_Description__c, EUR_CRM_Quantity__c,
                                                                EUR_CRM_Amount__c, EUR_CRM_Amount_Spent__c,
                                                                EUR_CRM_Unit__c, EUR_CRM_Name_Reference__c,
                                                                EUR_CRM_Exclusive__c
                                                                FROM EUR_CRM_Contract_Product_Item__c
                                                                WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c=:contractObj.Id
                                                                AND EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c IN: mechanicTypes])
        {
            //contractProductMap Key
            String contractProductKey = contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c +'-'+ contractProductItem.EUR_CRM_Contract_Activity_Item__r.Name;
            //cpItemMap Key
            String key = (contractProductItem.EUR_CRM_Brand__c!=null)?contractProductItem.EUR_CRM_Brand__c:contractProductItem.EUR_CRM_Brand_Quality__c;
            key = (contractProductItem.EUR_CRM_Brand__c==null && contractProductItem.EUR_CRM_Brand_Quality__c==null)?(DESCRIPTION_PREFIX+contractProductItem.Id):key;
            Map <String, EUR_CRM_Contract_Product_Item__c> cpItemMap = (contractProductMap.containsKey(contractProductKey))?contractProductMap.get(contractProductKey):new Map <String, EUR_CRM_Contract_Product_Item__c>(); 
            
            //System Field Update
            if (contractProductItem.EUR_CRM_Brand__r.Name != null){
                    contractProductItem.EUR_CRM_Name_Reference__c = contractProductItem.EUR_CRM_Brand__r.Name;
            }
            else if (contractProductItem.EUR_CRM_Brand_Quality__r.Name != null){
                    contractProductItem.EUR_CRM_Name_Reference__c = contractProductItem.EUR_CRM_Brand_Quality__r.Name;
            }
            
            cpItemMap.put(key, contractProductItem);
            
            contractProductMap.put(contractProductKey, cpItemMap);
        }
        
        return contractProductMap;
    }
    
    public Map<Id, EUR_CRM_Quality__c> retrieveItemSourceBrandQualities (EUR_CRM_Contract__c contractObj){
        Map <Id, EUR_CRM_Quality__c> brandQualityMap = new Map <Id, EUR_CRM_Quality__c>();
        if (contractObj != null){
            brandQualityMap = new Map <Id, EUR_CRM_Quality__c>(
                                        [SELECT Id, Name,
                                        EUR_CRM_Quality_Code__c,
                                        EUR_CRM_Brand__c, EUR_CRM_Brand__r.Name,
                                        EUR_CRM_Quality_Description__c, EUR_CRM_Country_Code__c,
                                        EUR_CRM_Quality_Is_Competitor__c
                                        FROM EUR_CRM_Quality__c
                                        WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                        AND EUR_CRM_Quality_Is_Competitor__c = false                                                                                            
                                        ]);
        }
        return brandQualityMap;
    }
    
    public EUR_CRM_Budget_Transaction__c createContractTransactionDebit(id budgetId, Id contractId, Double amount, Id txnRecordTypeId){
        EUR_CRM_Budget_Transaction__c newTransaction = new EUR_CRM_Budget_Transaction__c(EUR_CRM_Budget_Header__c = budgetId, EUR_CRM_Contract__c=contractId, RecordTypeid = txnRecordTypeId);
        newTransaction.EUR_CRM_Transaction_Type__c = 'Debit';
        newTransaction.EUR_CRM_Transaction_Category__c = 'Contract Transaction';
        newTransaction.EUR_CRM_Amount__c = amount;
        
        return newTransaction;
    }
    
    
    public EUR_CRM_Budget_Transaction__c createContractTransactionDebit(Id contractId, Double amount, Id txnRecordTypeId){
        EUR_CRM_Budget_Transaction__c newTransaction = new EUR_CRM_Budget_Transaction__c(EUR_CRM_Contract__c=contractId, RecordTypeid = txnRecordTypeId);
        newTransaction.EUR_CRM_Transaction_Type__c = 'Debit';
        newTransaction.EUR_CRM_Transaction_Category__c = 'Contract Transaction';
        newTransaction.EUR_CRM_Amount__c = amount;
        
        return newTransaction;
    }
    
    public EUR_CRM_Budget__c createBudget(Id OwnerId, String fiscalYear, String userRole){
        EUR_CRM_Budget__c newBudget = new EUR_CRM_Budget__c(OwnerId=OwnerId,
                                                    EUR_CRM_Fiscal_Year__c=fiscalYear,
                                                    EUR_CRM_User_Role_Type__c=userRole);
        
        return newBudget;
    }
    
    public EUR_CRM_Budget__c cloneBudget(EUR_CRM_Budget__c budgetRef, String fiscalYear){
        EUR_CRM_Budget__c newBudget = budgetRef.clone();
        if (budgetRef.RecordTypeId!=null){
            newBudget.RecordTypeId = budgetRef.RecordTypeId;
        }
        newBudget.EUR_CRM_Fiscal_Year__c = fiscalYear;
        newBudget.EUR_CRM_Allocated_Budget__c = 0;
        newBudget.EUR_CRM_Carry_Forward__c = 0;
        
        return newBudget;
    }
    
    public Date retrieveFiscalYearStart(){
        return EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
        /*
        Organization  org = new Organization() ;  
        org = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()];
        Date currentDate = Date.today();
        Integer fiscalYear = currentDate.year();
        if(currentDate.month()< org.FiscalYearStartMonth){
            fiscalYear = currentDate.year()-1;
        }
        
        return Date.newinstance(fiscalYear, org.FiscalYearStartMonth, 1);   
        */
    }
    
    public String formatFiscalYear(Date fiscalYearStart){
        return (fiscalYearStart==null)?'':'FY'+ String.valueOf(fiscalYearStart.year()).substring(2);
    }
    /*
    public class MechanicTypeWrapper{
        //Mechanic or Contract Activity Variables
        public EUR_CRM_Mechanic_Type__c mechanicType{get;set;}
        public String mechanicTypeName {get;set;}
        public Id mechanicTypeId {get;set;}
        public String mechanicTypeGroupingName{get;set;}
        
        //Contract Content
        //Key: contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c
        public Map<String, ContractActivityItemWrapper> contractActivityItems{get;set;}{contractActivityItems= new Map<String, ContractActivityItemWrapper>();} 
        public ContractActivityItemWrapper currentContractActivityItem {get;set;}{currentContractActivityItem = null;}
        public Boolean isEditMode{get{return ((currentContractActivityItem!=null)?true:false);}}
        //Map<String, Map<String, EUR_CRM_Contract_Product_Item__c>> contractProductItems{get;set;}{contractProductItems = new Map<String, Map<String, EUR_CRM_Contract_Product_Item__c>>();} //contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c
        
        public Double total {get;set;}
    
        //public Map<Id, EUR_CRM_Brand__c> brandItems {get;set;}{brandItems = new Map<Id, EUR_CRM_Brand__c>();}
        //public Map<Id, EUR_CRM_Quality__c> brandQualityItems {get;set;}{brandQualityItems = new Map<Id, EUR_CRM_Quality__c>();}
        
        public Set<Id> deletedContractActivityItems {get;set;}{deletedContractActivityItems = new Set<Id>();}
        
        public MechanicTypeWrapper(String mechanicTypeName){
            this.mechanicTypeName = mechanicTypeName;
        }
        
        public MechanicTypeWrapper(EUR_CRM_Mechanic_Type__c mechanicType){
            this.mechanicType = mechanicType;
            this.mechanicTypeName = mechanicType.Name;
            this.mechanicTypeId = mechanicType.Id;
            this.mechanicTypeGroupingName = mechanicType.EUR_CRM_Grouping_Name__c;
        }
        
        public void resetCurrentContractActivity(){
            this.currentContractActivityItem = null;
        }
    }
    
    public class ContractActivityItemWrapper{
        public EUR_CRM_Contract_Activity_Item__c contractActivityItem {get;set;}
        public Double total {get;set;}
        
        public Map<String, EUR_CRM_Contract_Product_Item__c> contractProductItems{get;set;}{contractProductItems = new Map<String, EUR_CRM_Contract_Product_Item__c>();} //Brand or Brand Quality Id or Description
        
        public Set<Id> deletedContractProductItems {get;set;}{deletedContractProductItems = new Set<Id>();}
        
        public Map<Id, EUR_CRM_Brand__c> brandItems {get;set;}{brandItems = new Map<Id, EUR_CRM_Brand__c>();}
        public Map<Id, EUR_CRM_Quality__c> brandQualityItems {get;set;}{brandQualityItems = new Map<Id, EUR_CRM_Quality__c>();}
        
        public ContractActivityItemWrapper(EUR_CRM_Contract_Activity_Item__c contractActivityItem){
                this.contractActivityItem = contractActivityItem;
        }
    }
    */
}