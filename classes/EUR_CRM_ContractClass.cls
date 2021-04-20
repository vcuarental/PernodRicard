/*
* Edit 10/22: 
* Add contract cocktail wrapper and at a set of it at contract line item warpper, to support multiple cocktail name in one line item
*/
public without sharing class EUR_CRM_ContractClass {

    private Map<Id, List<EUR_CRM_Contract_Mechanic__c>> contractMechanicMap { get; set; }{
        contractMechanicMap = null;
    }//Key:EUR_CRM_Mechanic_Type__c.Id

    public EUR_CRM_Contract__c contractDetails { get; private set; }
    public Map<String, EUR_CRM_Mechanic_Type__c> contractMechanicTypeMap { get; private set; }//Key:EUR_CRM_Mechanic_Type__c.Name
    public Map<Id, List<EUR_CRM_Contract_Line_Item__c>> contractLineItemMap { get; private set; }//Key:EUR_CRM_Mechanic_Type__c.Id
    public Map<Id, EUR_CRM_Contract_Mechanic__c> allContractMechanicMap { get; private set; }{
        allContractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
    }
    //Contract Cocktail Map - Key:EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c
    public Map<Id, Set<ContractCocktailWrapper>> contractCocktailMap { get; set; } {
        contractCocktailMap = new Map<Id, Set<ContractCocktailWrapper>>();
    }

    //Added 03.2020
    //Activity Items With Product Items
    public List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsWithProductItems { get; set; } {
        contractActivityItemsWithProductItems = new List<EUR_CRM_Contract_Activity_Item__c>();
    }

    public EUR_CRM_ContractClass(Id contractId) {
        if (contractId != null) {
            //Get Contract Details
            contractDetails = retrieveContractDetails(contractId);
            System.debug('Flag - Contract Class - Contract Details:' + contractDetails);

            //Get Contract Mechanic Type Map
            contractMechanicTypeMap = retrieveMechanicTypes();
            System.debug('Flag - Contract Class - Contract Mechanic Type:' + contractMechanicTypeMap);

            //Get Contract Items
            contractLineItemMap = retrieveContractLineItems(contractId);
            System.debug('Flag - Contract Class - Contract Line Items:' + contractLineItemMap);

            //Get Contract Cocktail
            contractCocktailMap = retrieveContractCocktailWrapperMap(contractId);

            //Added 03.2020
            //Get Contract Activity Items
            contractActivityItemsWithProductItems = retrieveContractActivityItemsWithProductItems(contractId);
            System.debug('Flag - Contract Class - Contract Activity Items with Products: ' +
                    contractActivityItemsWithProductItems);
        }
    }

    //Added 03.2020
    public List<EUR_CRM_Contract_Activity_Item__c> retrieveContractActivityItemsWithProductItems(Id contractId) {
        List<EUR_CRM_Contract_Activity_Item__c> activityItems = new List<EUR_CRM_Contract_Activity_Item__c>();
        for (EUR_CRM_Contract_Activity_Item__c activityItem : [
                SELECT Id, Name,
                        EUR_CRM_Name__c,
                        EUR_CRM_Mechanic_Type__c,
                        EUR_CRM_Amount__c,
                        EUR_CRM_Cocktail_Percent__c,
                        EUR_CRM_Supplier_PR__c,
                        EUR_CRM_Brand_Budget__c,
                        EUR_CRM_Payment_Term__c, (
                        SELECT Id,
                                EUR_CRM_No_of_Cocktails__c,
                                EUR_CRM_Cocktail_Menu__c,
                                EUR_CRM_Value__c,
                                EUR_Min_Qty_Per_Annum_9L__c,
                                EUR_CRM_Available_by_the_Glass__c,
                                EUR_CRM_Stock_Deal_Mechanic__c,
                                EUR_CRM_Optics__c,
                                EUR_CRM_POS_type__c,
                                EUR_CRM_No_of_People__c,
                                EUR_CRM_Brand_Quality__c,
                                EUR_CRM_Product_Name__c,
                                EUR_CRM_Contract_Mechanic__c,
                                EUR_CRM_Unit__c,
                                EUR_CRM_Retro_Per_9L__c,
                                EUR_CRM_Mechanic_Name__c
                        FROM Contract_Product_Items__r
                )
                FROM EUR_CRM_Contract_Activity_Item__c
                WHERE EUR_CRM_Contract__c = :contractId
                LIMIT 49999
        ]) {
            activityItems.add(activityItem);
        }
        return activityItems;
    }

    public Map<Id, List<EUR_CRM_Contract_Mechanic__c>> retrieveTrimmedContractMechanicItems(Map<Id, List<EUR_CRM_Contract_Line_Item__c>> contractLineItemsMap) {
        Map <Id, List<EUR_CRM_Contract_Mechanic__c>> contractMechanics = new Map<Id, List<EUR_CRM_Contract_Mechanic__c>> ();

        Map<Id, Set<Id>> cliIdSet = new Map<Id, Set<Id>>();
        for (Id key : contractLineItemsMap.keySet()) {
            Set<Id> cmId = new Set<Id>();
            for (EUR_CRM_Contract_Line_Item__c cli : contractLineItemsMap.get(key)) {
                cmId.add(cli.EUR_CRM_Contract_Mechanic__c);
            }
            cliIdSet.put(key, cmId);
        }
        System.debug('Flag - CLI ID Set:' + cliIdSet);

        for (EUR_CRM_Contract_Mechanic__c cmItem : [
                SELECT Id, Name,
                        EUR_CRM_Brand_Quality__c,
                        EUR_CRM_Brand_Quality__r.Name,
                        EUR_CRM_Brand_Quality_Name__c,
                        EUR_CRM_Mechanic__c,
                        EUR_CRM_Mechanic__r.Name,
                        EUR_CRM_Mechanic_Name__c,
                        EUR_CRM_Mechanic__r.EUR_CRM_Grouping_Name__c,
                        EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c,
                        EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.Name,
                        EUR_CRM_Mechanic_Type_Name__c,
                        EUR_CRM_Brand_Quality_Category__c,
                        EUR_CRM_Contract_Mechanic_Reference__c,
                        EUR_CRM_Brand_Quality_Name_Ref__c,
                        EUR_CRM_Brand_Quality_Category_Ref__c
                FROM EUR_CRM_Contract_Mechanic__c
                WHERE EUR_CRM_Brand_Quality__c != null
                //TODO Add Filter - TBD with Dakang
                AND EUR_CRM_Brand_Quality__r.EUR_CRM_Active__c = true
                LIMIT 49999
        ]) {
            Id key = cmItem.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c;
            cmItem.EUR_CRM_Brand_Quality_Name_Ref__c = cmItem.EUR_CRM_Brand_Quality__r.Name;
            cmItem.EUR_CRM_Brand_Quality_Category_Ref__c = cmItem.EUR_CRM_Brand_Quality_Category__c;

            allContractMechanicMap.put(cmItem.Id, cmItem);
            List<EUR_CRM_Contract_Mechanic__c> cmList = (contractMechanics.containsKey(key)) ? contractMechanics.get(key) : new List<EUR_CRM_Contract_Mechanic__c>();
            if (cliIdSet.containsKey(key) && (!cliIdSet.get(key).contains(cmItem.Id))) {
                cmList.add(cmItem);
            } else if (!cliIdSet.containsKey(key)) {
                cmList.add(cmItem);
            }

            contractMechanics.put(key, cmList);
        }

        return contractMechanics;
    }

//    private Set<Id> createIdSet(List<sObject>objList) {
//        Set<Id> idSet = new Set<Id>();
//        for (sObject obj : objList) {
//            idSet.add(obj.Id);
//        }
//        return idSet;
//    }

    public Map<Id, List<EUR_CRM_Contract_Mechanic__c>> retrieveAllContractMechanicItems() {
        Map <Id, List<EUR_CRM_Contract_Mechanic__c>> contractMechanics = new Map<Id, List<EUR_CRM_Contract_Mechanic__c>> ();

        for (EUR_CRM_Contract_Mechanic__c cmItem : [
                SELECT Id, Name,
                        EUR_CRM_Brand_Quality__c,
                        EUR_CRM_Brand_Quality__r.Name,
                        EUR_CRM_Brand_Quality_Name__c,
                        EUR_CRM_Mechanic__c,
                        EUR_CRM_Mechanic__r.Name,
                        EUR_CRM_Mechanic_Name__c,
                        EUR_CRM_Mechanic__r.EUR_CRM_Grouping_Name__c,
                        EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c,
                        EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__r.Name,
                        EUR_CRM_Mechanic_Type_Name__c,
                        EUR_CRM_Brand_Quality_Category__c,
                        EUR_CRM_Contract_Mechanic_Reference__c,
                        EUR_CRM_Brand_Quality_Name_Ref__c,
                        EUR_CRM_Brand_Quality_Category_Ref__c
                FROM EUR_CRM_Contract_Mechanic__c
                WHERE EUR_CRM_Brand_Quality__c != null
                //TODO Add Filter - TBD with Dakang
                AND EUR_CRM_Brand_Quality__r.EUR_CRM_Active__c = true
                LIMIT 49999
        ]) {
            Id key = cmItem.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c;
            cmItem.EUR_CRM_Brand_Quality_Name_Ref__c = cmItem.EUR_CRM_Brand_Quality__r.Name;
            cmItem.EUR_CRM_Brand_Quality_Category_Ref__c = cmItem.EUR_CRM_Brand_Quality_Category__c;

            allContractMechanicMap.put(cmItem.Id, cmItem);
            List<EUR_CRM_Contract_Mechanic__c> cmList = (contractMechanics.containsKey(key)) ? contractMechanics.get(key) : new List<EUR_CRM_Contract_Mechanic__c>();
            cmList.add(cmItem);
            contractMechanics.put(key, cmList);
        }

        return contractMechanics;
    }


    public List<EUR_CRM_Contract_Mechanic__c> retrieveContractMechanicItems(Id mechanicTypeId) {
        if (contractMechanicMap == null) {
            contractMechanicMap = retrieveAllContractMechanicItems();
            System.debug('Flag - Retrieve Contract Mechanic Items - Query DB:' + contractMechanicMap);
        }

        if (contractMechanicMap.containsKey(mechanicTypeId)) {
            return contractMechanicMap.get(mechanicTypeId);
        }

        return null;
    }

    public List<EUR_CRM_Contract_Mechanic__c> getTrimmedContractMechanicItems(Id mechanicTypeId, Map<Id, List<EUR_CRM_Contract_Line_Item__c>> contractLineItemsMap) {
        if (contractMechanicMap == null) {
            contractMechanicMap = retrieveTrimmedContractMechanicItems(contractLineItemsMap);
            System.debug('Flag - Retrieve Contract Mechanic Items - Query DB:' + contractMechanicMap);
        }

        if (contractMechanicMap.containsKey(mechanicTypeId)) {
            return contractMechanicMap.get(mechanicTypeId);
        }

        return null;
    }

    public Id getMechanicTypeId(String name) {
        if (contractMechanicTypeMap != null && contractMechanicTypeMap.containsKey(name)) {
            return contractMechanicTypeMap.get(name).Id;
        }

        return null;
    }

    public EUR_CRM_Contract_Mechanic__c retrieveContractMechanic(Id id) {
        if (allContractMechanicMap.containsKey(id)) {
            return allContractMechanicMap.get(id);
        }
        return null;
    }

    public EUR_CRM_Contract_Mechanic__c retrieveContractMechanic(Id brandQuality, String mechanicType) {
        if (brandQuality != null && mechanicType != null) {
            for (EUR_CRM_Contract_Mechanic__c cm : allContractMechanicMap.values()) {
                System.debug('Flag - Retrieve Contract Mechanic:' + cm);
                if (cm.EUR_CRM_Mechanic_Type_Name__c != null && cm.EUR_CRM_Brand_Quality__c != null && String.valueOf(cm.EUR_CRM_Mechanic_Type_Name__c).equalsIgnoreCase(mechanicType) && String.valueOf(cm.EUR_CRM_Brand_Quality__c).equalsIgnoreCase(brandQuality)) {
                    return cm;
                }
            }
        }
        return null;
    }

    private EUR_CRM_Contract__c retrieveContractDetails(Id contractId) {
        if (contractId != null) {
            List<EUR_CRM_Contract__c> contractList = [
                    SELECT Id, Name,
                            EUR_CRM_Account__c,
                            EUR_CRM_Contact__c,
                            EUR_CRM_End_Date__c,
                            EUR_CRM_Nominated_Supplier__c,
                            EUR_CRM_Payment_Method__c,
                            EUR_CRM_Start_Date__c,
                            EUR_CRM_Status__c,
                            EUR_CRM_Marketing_Package_Lump_Sum__c,
                            EUR_CRM_Mktg_Package_Mechanic_Handling__c,
                            EUR_CRM_Active__c,
                            EUR_CRM_Contract_Approved_Date__c,
                            EUR_CRM_Total_Contract_Line_Items__c,
                            EUR_CRM_Cocktail_Percent__c,
                            EUR_CRM_Customer_Agreed_With_No_Sign_off__c,
                            EUR_CRM_Country_Code__c,
                            EUR_CRM_Agrees_with_TC__c,
                            EUR_CRM_Contract_Uploaded__c,
                            EUR_CRM_Total_Contract_Value__c //added JAN.05.2015
                    FROM EUR_CRM_Contract__c
                    WHERE Id = :contractId
            ];
            if (contractList.size() > 0) {
                EUR_CRM_Contract__c contract = contractList.get(0);
                if (contract.EUR_CRM_Marketing_Package_Lump_Sum__c == null) {
                    contract.EUR_CRM_Marketing_Package_Lump_Sum__c = 0;
                }
                //contract.EUR_CRM_Nominated_Supplier__c = (contract.EUR_CRM_Nominated_Supplier__c == null)? null : EUR_CRM_Nominated_Supplier__c;
                return contract;
            }
        }

        return null;
    }

    private Map<Id, List<EUR_CRM_Contract_Line_Item__c>> retrieveContractLineItems(Id contractId) {
        Map<Id, List<EUR_CRM_Contract_Line_Item__c>> contractLineItems = new Map<Id, List<EUR_CRM_Contract_Line_Item__c>>();
        if (contractId != null) {
            for (EUR_CRM_Contract_Line_Item__c cLineItem : [
                    SELECT Id, Name,
                            EUR_CRM_Contract__c,
                            EUR_CRM_Contract__r.EUR_CRM_Contract_Approved_Date__c,
                            EUR_CRM_Contract__r.EUR_CRM_Active__c,
                            EUR_CRM_Available_by_the_Glass__c,
                            EUR_Min_Qty_Per_Annum_9L__c,
                            EUR_CRM_Retro_Per_9L__c,
                            //EUR_CRM_Cocktail_Name__c,
                            //EUR_CRM_Cocktail_Percent__c,
                            EUR_CRM_No_of_Cocktails__c,
                            //EUR_CRM_Number_of_Cocktails__c,
                            EUR_CRM_No_of_People__c,
                            EUR_CRM_Contract_Mechanic__c,
                            EUR_CRM_Contract_Mechanic__r.Name,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Category__c,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.Name,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Contract_Mechanic_Reference__c,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__c,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.Name,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Grouping_Name__c,
                            EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c,
                            EUR_CRM_Mechanic_Type__c,
                            EUR_CRM_Mechanic_Type_Name__c,
                            EUR_CRM_Brand_Quality__c,
                            EUR_CRM_Brand_Quality_Name__c,
                            EUR_CRM_Brand_Quality_Name_Reference__c,
                            EUR_CRM_Category_Name__c,
                            EUR_CRM_Value__c,
                            EUR_CRM_Stock_Deal__c,
                            EUR_CRM_Stock_Deal__r.EUR_CRM_Stock_Deal_Name__c,
                            EUR_CRM_Mechanic_Name__c,
                            EUR_CRM_Process_Option_Lump_Sum__c,
                            EUR_CRM_TotalSpend__c,
                            EUR_CRM_Total_Value__c,
                            EUR_CRM_Total_Value_Reference__c
                    FROM EUR_CRM_Contract_Line_Item__c
                    WHERE EUR_CRM_Contract__c = :contractId
                    LIMIT 49999
            ]) {
                Id key = (cLineItem.EUR_CRM_Contract_Mechanic__c != null) ? cLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c : cLineItem.EUR_CRM_Mechanic_Type__c;
                List<EUR_CRM_Contract_Line_Item__c> cLineItemList = (contractLineItems.containsKey(key)) ? contractLineItems.get(key) : new List<EUR_CRM_Contract_Line_Item__c>();

                if (cLineItem.EUR_CRM_Brand_Quality_Name__c == null && cLineItem.EUR_CRM_Process_Option_Lump_Sum__c == false) {
                    cLineItem.EUR_CRM_Brand_Quality_Name__c = cLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.Name;
                }

                //Set default values
                cLineItem.EUR_CRM_Total_Value_Reference__c = cLineItem.EUR_CRM_Total_Value__c;
                cLineItem.EUR_CRM_Mechanic_Name__c = (cLineItem.EUR_CRM_Contract_Mechanic__c != null) ? cLineItem.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Mechanic__r.Name : null;

                cLineItemList.add(cLineItem);
                contractLineItems.put(key, cLineItemList);
            }
        }
        return contractLineItems;
    }

    private Map<Id, Set<ContractCocktailWrapper>> retrieveContractCocktailWrapperMap(Id contractId) {
        //Map Key: EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c
        Map<Id, Set<ContractCocktailWrapper>> contractCocktailMap = new Map<Id, Set<ContractCocktailWrapper>>();

        for (EUR_CRM_Contract_Cocktail__c contractCocktail : [
                SELECT Id, EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract__r.Id,
                        EUR_CRM_Contract_Line_Item__c, EUR_CRM_Cocktail_Menu__c,
                        EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.Name,
                        EUR_CRM_Cocktail_Menu__r.Name,
                        EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c
                FROM EUR_CRM_Contract_Cocktail__c
                WHERE EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract__r.Id = :contractId
                ORDER BY EUR_CRM_Cocktail_Menu__r.Name
                LIMIT 49999
        ]) {

            Set<ContractCocktailWrapper> cocktailSet = (contractCocktailMap.containsKey(contractCocktail.EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c)) ? contractCocktailMap.get(contractCocktail.EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c) : new Set<ContractCocktailWrapper>();
            cocktailSet.add(new ContractCocktailWrapper(contractCocktail));
            List<ContractCocktailWrapper> cocktailLi = new List<ContractCocktailWrapper>(cocktailSet);
            cocktailLi.sort();
            cocktailSet = new Set<ContractCocktailWrapper>(cocktailLi);
            contractCocktailMap.put(contractCocktail.EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c, cocktailSet);
        }

        return contractCocktailMap;
    }

    private Map<String, EUR_CRM_Mechanic_Type__c> retrieveMechanicTypes() {
        Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap = new Map<String, EUR_CRM_Mechanic_Type__c>();

        for (EUR_CRM_Mechanic_Type__c mechanic : [
                SELECT Id, Name, EUR_CRM_Grouping_Name__c,
                        EUR_CRM_Mechanic_Process_Type__c, EUR_CRM_Country_Code__c,
                        EUR_CRM_Has_Lump_Sum__c, EUR_CRM_Has_Per_BQ__c
                FROM EUR_CRM_Mechanic_Type__c
                WHERE EUR_CRM_Country_Code__c = :contractDetails.EUR_CRM_Country_Code__c
                LIMIT 49999
        ]) {
            mechanicTypeMap.put(mechanic.Name, mechanic);
        }

        System.debug('Flag - Retrieve Mechanic Types:' + mechanicTypeMap);
        return mechanicTypeMap;
    }

    public class ContractLineItemWrapper {
        public EUR_CRM_Contract_Line_Item__c contractLineItem { get; set; }
        public Id contractMechanic { get; set; }//EUR_CRM_Contract_Mechanic__c{get;set;}
        public Id contract { get; set; }
        public Set<ContractCocktailWrapper> contractCocktails { get; set; }{
            contractCocktails = new Set<ContractCocktailWrapper>();
        }
        public Map<Id, Id> contractCocktailsReferenceMap {
            get {
                Map<Id, Id> contractCocktailsRefMap = new Map<Id, Id>(); //Key:Cocktail Menu Id; Value:Contract Cocktail Id
                for (ContractCocktailWrapper ccWrap : contractCocktails) {
                    contractCocktailsRefMap.put(ccWrap.contractCocktail.EUR_CRM_Cocktail_Menu__c, ccWrap.contractCocktail.Id);
                }

                return contractCocktailsRefMap;
            }
        }

        public List<SelectOption> cocktailsSelected { get; set; }{
            cocktailsSelected = new List<SelectOption>();
        }
        public List<SelectOption> cocktailNameSelection { get; set; }{
            cocktailNameSelection = new List<SelectOption>();
        }
        public Set<Id> selectedIds = new Set<Id>();
//        public List<String> cocktailsSelectedText {
//            get {
//                List<String> cList = new List<String>();
//                for (SelectOption cSelected : cocktailsSelected) {
//                    cList.add(cSelected.getLabel());
//                }
//                return cList;
//            }
//        }
//        public Integer cocktailSelectedSize { get {return cocktailsSelected.size();} }

        public Boolean cocktailOnEdit { get; set; } {
            cocktailOnEdit = false;
        }

        public ContractLineItemWrapper(Id contract, Id contractMechanic, Id brandQualityName) {
            this.contract = contract;
            this.contractMechanic = contractMechanic;
            //cocktailNameSelection = retrieveCocktailMenuSelection();
            if (selectedIds.size() == 0) {
                cocktailNameSelection = retrieveCocktailMenuSelection(null);
            }
        }

        public ContractLineItemWrapper(EUR_CRM_Contract_Line_Item__c contractLineItemObj) {
            contractLineItem = contractLineItemObj;
            this.contract = contractLineItemObj.EUR_CRM_Contract__c;
            this.contractMechanic = contractLineItemObj.EUR_CRM_Contract_Mechanic__c;
            //cocktailNameSelection = retrieveCocktailMenuSelection();
            if (selectedIds.size() == 0) {
                cocktailNameSelection = retrieveCocktailMenuSelection(null);
            }
        }

        public ContractLineItemWrapper(EUR_CRM_Contract_Line_Item__c contractLineItemObj, Boolean needsToSelectCocktails) {
            contractLineItem = contractLineItemObj;
            this.contract = contractLineItemObj.EUR_CRM_Contract__c;
            this.contractMechanic = contractLineItemObj.EUR_CRM_Contract_Mechanic__c;
            //cocktailNameSelection = retrieveCocktailMenuSelection();
            if (needsToSelectCocktails == true && selectedIds.size() == 0) {
                cocktailNameSelection = retrieveCocktailMenuSelection(null);
            }
        }

        public void setCocktailsSelected(Set<ContractCocktailWrapper> contractCocktailWrapperSet) {
            cocktailsSelected = new List<SelectOption>();
            List<ContractCocktailWrapper> cocktailLi = new List<ContractCocktailWrapper>(contractCocktailWrapperSet);
            cocktailLi.sort();
            contractCocktailWrapperSet = new Set<ContractCocktailWrapper>(cocktailLi);
            for (ContractCocktailWrapper ccWrap : contractCocktailWrapperSet) {
                cocktailsSelected.add(new SelectOption(ccWrap.contractCocktail.EUR_CRM_Cocktail_Menu__c, ccWrap.contractCocktail.EUR_CRM_Cocktail_Menu__r.Name));
                selectedIds.add(ccWrap.contractCocktail.EUR_CRM_Cocktail_Menu__c);
            }
            cocktailNameSelection = retrieveCocktailMenuSelection(selectedIds);
        }

        //private List<SelectOption> retrieveCocktailMenuSelection(){
        private List<SelectOption> retrieveCocktailMenuSelection(Set<Id> selectedCTIds) {
            List<SelectOption> cocktailMenus = new List<SelectOption>();

            //cocktailMenus.add(new SelectOption('', '-None-'));
            for (EUR_CRM_Cocktail_Menu__c cocktailMenu : [SELECT Id, Name FROM EUR_CRM_Cocktail_Menu__c WHERE Id NOT IN :selectedCTIds ORDER BY Name]) {
                cocktailMenus.add(new SelectOption(cocktailMenu.Id, cocktailMenu.Name));
            }

            return cocktailMenus;
        }

    }

    //Used in EUR_CRM_ContractBuilderControllerExt
    public class ContractCocktailWrapper implements Comparable {
        public EUR_CRM_Contract_Cocktail__c contractCocktail { get; set; }
        String bqName { get; private set; }
        String cocktailName { get; private set; }
        Id contractMechanicID { get; set; }

        public Integer compareTo(Object compareToObj) {
            ContractCocktailWrapper compareToObjWrapper = (ContractCocktailWrapper) compareToObj;
            if (cocktailName == compareToObjWrapper.cocktailName) return 0;
            if (cocktailName > compareToObjWrapper.cocktailName) return 1;
            return -1;
        }

        public ContractCocktailWrapper(EUR_CRM_Contract_Cocktail__c contractCocktail) {
            this.contractCocktail = contractCocktail;
            this.bqName = contractCocktail.EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.Name;
            this.cocktailName = contractCocktail.EUR_CRM_Cocktail_Menu__r.Name;
            this.contractMechanicID = contractCocktail.EUR_CRM_Contract_Line_Item__r.EUR_CRM_Contract_Mechanic__c;
        }

        public ContractCocktailWrapper(Id contractMechanicID, String bqName, Id cocktailMenuId, String cocktailName) {
            this.contractMechanicID = contractMechanicID;
            this.bqName = bqName;
            this.cocktailName = cocktailName;
            this.contractCocktail = new EUR_CRM_Contract_Cocktail__c(EUR_CRM_Cocktail_Menu__c = cocktailMenuId);
        }
    }
}