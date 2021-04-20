/*
* Edit 10/23:
* Support multiple cocktail names per BQ, change on getting contract content and saving cloned contract
*/

public with sharing class EUR_CRM_ContractSummaryController {

    private final static String STATUS_DRAFT = 'Draft';
    private final static String LUMP_SUM_OR_PER_BQ = 'LUMP_SUM_OR_PER_BQ';
    private final static String BOTH_LUMP_SUM_AND_PER_BQ = 'BOTH';
    private final static String GROUPING_NAME_POURING = 'POURING';
    private final static String GROUPING_NAME_COCKTAIL = 'COCKTAIL';
    private final static Map<String, List<String>> contractLineItemColumnsPerType = new Map<String, List<String>>();

    private ApexPages.StandardController standardController { get; set; }
    private Id contractId {
        get {
            if (this.standardController != null) {
                return this.standardController.getId();
            }
            return null;
        }
    }

    private Map<String, List<String>> mechanicTypeFieldMap = new Map<String, List<String>>{
            'House Pouring Spirits' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_Min_Qty_Per_Annum_9L__c', 'EUR_CRM_Retro_Per_9L__c', 'EUR_CRM_Stock_Deal__c', 'EUR_CRM_TotalSpend__c'
            },
            'Premium Pouring Spirits' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_Min_Qty_Per_Annum_9L__c', 'EUR_CRM_Retro_Per_9L__c', 'EUR_CRM_Stock_Deal__c', 'EUR_CRM_TotalSpend__c'
            },
            'House Pouring Champagne' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_Min_Qty_Per_Annum_9L__c', 'EUR_CRM_Retro_Per_9L__c', 'EUR_CRM_Available_by_the_Glass__c', 'EUR_CRM_TotalSpend__c'
            },
            'Must Stock Item' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c'
            },
            'May Stock Item' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c'
            },
            'Cocktail' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_Min_Qty_Per_Annum_9L__c'
            }, //, 'EUR_CRM_Cocktail_Name__c'},
            'Marketing Support' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c'
            },
            'Trips' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_CRM_Mechanic_Name__c', 'EUR_CRM_No_of_People__c', 'EUR_CRM_Value__c'
            },
            'Educations' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_CRM_Mechanic_Name__c', 'EUR_CRM_Value__c'
            },
            'Point of Sales' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c'
            },
            'Free Stock' => new List<String>{
                    'EUR_CRM_Brand_Quality_Name_Reference__c', 'EUR_CRM_Value__c'
            }
    };
    public static String CONTRACT_MECHANIC_TABLE_PREFIX { get {return 'ContractMechanicTable_';} }
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX { get {return 'ContractLineItemTable_';} }

    public EUR_CRM_ContractClass contractObject { get; private set; }
    public EUR_CRM_Contract__c contractObj {
        get {
            if (contractObject != null) {
                return contractObject.contractDetails;
            } else {
                return new EUR_CRM_Contract__c();
            }
        }
        set;
    }
    public String currencyCode { get {return String.valueOf(contractObj.get('CurrencyIsoCode'));} }

    public EUR_CRM_Contract__c clonedContractObj { get; set; }

    public List<EUR_CRM_Mechanic_Type__c> contractMechanicTypeList {
        get {
            if (contractObject != null) {
                return contractObject.contractMechanicTypeMap.values();
            }
            return null;
        }
    }

    public Map<String, MechanicTypeWrapper> mechanicItems { get; set; }{
        mechanicItems = new Map<String, MechanicTypeWrapper>();
    }
    public Map<String, String> mechanicTypeId { get; set; }{
        mechanicTypeId = new Map<String, String>();
    }

    public Map<String, List<EUR_CRM_Contract_Line_Item__c>> allContractLineItems { get; set; } {
        allContractLineItems = new Map<String, List<EUR_CRM_Contract_Line_Item__c>>();
    }
//        public Integer allContractLineItemsSize{get{return allContractLineItems.size();}}

    public EUR_CRM_ContractSummaryController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        System.debug('Flag - Check Standard Controller:' + this.standardController + ' - ' + contractId);
        if (contractId == null) {
            //EUR_CRM_MissingIdMessage
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        } else {
            initContract();
            initContractContent();
            cloneContractHeader();
        }
    }

    public PageReference initContract() {
        PageReference pageRef = null;

        contractObject = new EUR_CRM_ContractClass(contractId);
        System.debug('Flag - Check Mechanic Type:' + contractObject.contractMechanicTypeMap);

        return pageRef;
    }

    public void initContractContent() {
        //Create Mechanic Type Items
        System.debug('FLag - INIT Contract Content');

        mechanicItems = new Map<String, MechanicTypeWrapper>();
        mechanicTypeId = new Map<String, String>();

        for (EUR_CRM_Mechanic_Type__c cMechanicType : contractMechanicTypeList) {
            String mechanicTypeName = cMechanicType.Name;
            MechanicTypeWrapper mechanicTypeWrapper = new MechanicTypeWrapper(cMechanicType);

            //Set data content
            List<EUR_CRM_Contract_Line_Item__c> contractLineItems = (contractObject.contractLineItemMap.containsKey(cMechanicType.Id)) ? contractObject.contractLineItemMap.get(cMechanicType.Id) : new List<EUR_CRM_Contract_Line_Item__c>();

            if (String.isNotBlank(cMechanicType.EUR_CRM_Mechanic_Process_Type__c)) {
                if (cMechanicType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(LUMP_SUM_OR_PER_BQ)) {
                    mechanicTypeWrapper.hasMechanicTypeChoice = true;
                }

                if (cMechanicType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(BOTH_LUMP_SUM_AND_PER_BQ)) {
                    mechanicTypeWrapper.hasBothMechanicType = true;
                }


                if (cMechanicType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(BOTH_LUMP_SUM_AND_PER_BQ)) {
                    //Parse Contract Line Item if Mechanic Type Processing is Both
                    mechanicTypeWrapper.hasBothMechanicType = true;

                    EUR_CRM_Contract_Line_Item__c cliLumpSum = new EUR_CRM_Contract_Line_Item__c();
                    List<EUR_CRM_Contract_Line_Item__c> cliList = new List<EUR_CRM_Contract_Line_Item__c>();

                    System.debug('Flag - Init Contract Content - Check Line Items:' + contractLineItems);
                    for (EUR_CRM_Contract_Line_Item__c cli : contractLineItems) {
                        if (cli.EUR_CRM_Process_Option_Lump_Sum__c == true) {
                            cliLumpSum = cli;
                        } else {
                            cliList.add(cli);
                        }
                    }
                    //Set Lump Sum Contract Line Item
                    System.debug('Flag - Init Contract Content - Check Lump Sum Line Item:' + cliLumpSum);
                    mechanicTypeWrapper.contractLineItemLumpSum = (cliLumpSum.Id != null) ? cliLumpSum : createLumpSumContractLineItem(cMechanicType);
                    System.debug('Flag - Init Contract Content - Check Lump Sum Line Item 2:' + mechanicTypeWrapper.contractLineItemLumpSum);

                    //Set BQ Contract Line Items
                    mechanicTypeWrapper.setContractLineItemMap(cliList);
                    mechanicTypeWrapper.setContractLineItemWrapperMap(cliList, contractObject.contractCocktailMap);
                    //contractLineItems = cliList;
                    setContractLineItemContent(cMechanicType.Id, cliList);
                }
            } else {
                setContractLineItemContent(cMechanicType.Id, contractLineItems);
                mechanicTypeWrapper.setContractLineItemMap(contractLineItems);
                mechanicTypeWrapper.setContractLineItemWrapperMap(contractLineItems, contractObject.contractCocktailMap);
            }

            //System.debug('Flag - Init Contract Content - Line Item:' + mechanicTypeWrapper.contractLineItemsTable);
            mechanicItems.put(mechanicTypeName, mechanicTypeWrapper);
            mechanicTypeId.put(mechanicTypeName, cMechanicType.Id);

        }

        System.debug('Flag - initContractContent - Mechanic Items:' + mechanicItems);
    }

    public void setContractLineItemContent(String mechanicTypeName, List<EUR_CRM_Contract_Line_Item__c> content) {
        allContractLineItems.put(mechanicTypeName, content);
    }

    public PageReference cloneContractHeader() {
        PageReference pageRef = null;

        System.debug('Flag - Clone Contract Header 1:' + clonedContractObj);

        //Copy Contract Header
        clonedContractObj = contractObj.clone(false, true);
        clonedContractObj.EUR_CRM_Account__c = null;
        clonedContractObj.EUR_CRM_Active__c = false;
        clonedContractObj.EUR_CRM_Contract_Agreed_Date__c = null;
        clonedContractObj.EUR_CRM_Contract_Approved_Date__c = null;
        clonedContractObj.EUR_CRM_Contract_Signed_Date__c = null;
        clonedContractObj.EUR_CRM_End_Date__c = null;
        clonedContractObj.EUR_CRM_Proposal_Approved_Date__c = null;
        clonedContractObj.EUR_CRM_Proposal_Date__c = null;
        clonedContractObj.EUR_CRM_Start_Date__c = null;
        clonedContractObj.EUR_CRM_Status__c = STATUS_DRAFT;

        System.debug('Flag - Clone Contract Header 2:' + clonedContractObj);

        return pageRef;
    }

    //Added 03.2020
    public PageReference saveClonedContractNew() {
        PageReference pageRef = null;
        Database.SaveResult contractInsertResult;
        System.Savepoint pSavepoint = Database.setSavepoint();
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItemsToInsert = new
                List<EUR_CRM_Contract_Activity_Item__c>();
        List<EUR_CRM_Contract_Product_Item__c> contractProductItemsToInsert = new
                List<EUR_CRM_Contract_Product_Item__c>();
        try {
            System.debug('Flag - Save Cloned Contract : ' + clonedContractObj);
            if (clonedContractObj.EUR_CRM_Account__c != null && clonedContractObj.EUR_CRM_End_Date__c != null
                    && clonedContractObj.EUR_CRM_Start_Date__c != null) {

                //Insert Contract
                contractInsertResult = Database.insert(clonedContractObj);

                if (clonedContractObj.Id != null) {
                    contractActivityItemsToInsert = cloneActivityItems(contractObject
                            .contractActivityItemsWithProductItems, clonedContractObj.Id);
                    if (contractActivityItemsToInsert.size() > 0) {

                        //Insert Contract Activity Items
                        System.debug('Flag - Save Cloned Activity items : ' + contractActivityItemsToInsert);
                        Database.insert(contractActivityItemsToInsert);

                    }
                    contractProductItemsToInsert = cloneProductItems(contractActivityItemsToInsert);
                    if (contractProductItemsToInsert.size() > 0) {

                        //Insert Product Activity Items
                        System.debug('Flag - Save Cloned Product items : ' + contractProductItemsToInsert);
                        Database.insert(contractProductItemsToInsert);

                    }
                    pageRef = new PageReference('/' + clonedContractObj.Id);
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Missing value on required field/s.'));
                }
            }
        } catch (Exception e) {
            System.debug('Save Clone Error: ' + e);
            pageRef = null;
            Database.rollback(pSavepoint);
            String strError = e.getMessage() + '|' + String.valueOf(e.getLineNumber());
            if (e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                String s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
        }
        return pageRef;
    }

    //Added 03.2020
    private List<EUR_CRM_Contract_Activity_Item__c> cloneActivityItems(List<EUR_CRM_Contract_Activity_Item__c>
            itemsToClone, Id contractId) {
        List<EUR_CRM_Contract_Activity_Item__c> result = new List<EUR_CRM_Contract_Activity_Item__c>();
        if (itemsToClone.size() > 0) {
            for (EUR_CRM_Contract_Activity_Item__c item : itemsToClone) {
                EUR_CRM_Contract_Activity_Item__c clonedItem = item.clone(false, true);
                clonedItem.EUR_CRM_Contract__c = contractId;
                System.debug('Testing cloneActivityItems - products in cla -  ' + clonedItem.Contract_Product_Items__r);
                result.add(clonedItem);
            }
        }
        return result;
    }

    //Added 03.2020
    private List<EUR_CRM_Contract_Product_Item__c> cloneProductItems(List<EUR_CRM_Contract_Activity_Item__c>
            activityItems) {
        List<EUR_CRM_Contract_Product_Item__c> result = new List<EUR_CRM_Contract_Product_Item__c>();

        if (activityItems.size() > 0) {
            for(EUR_CRM_Contract_Activity_Item__c item: activityItems) {
                if(item.Contract_Product_Items__r.size() > 0) {
                    for(EUR_CRM_Contract_Product_Item__c product: item.Contract_Product_Items__r) {
                        EUR_CRM_Contract_Product_Item__c clonedProduct = product.clone(false, true);
                        clonedProduct.EUR_CRM_Contract_EU__c = item.EUR_CRM_Contract__c;
                        clonedProduct.EUR_CRM_Contract_Activity_Item__c = item.Id;
                        result.add(clonedProduct);
                    }
                }
            }
        }

        return result;
    }
    //Added 03.2020
//    private List<EUR_CRM_Contract_Product_Item__c> getProductItemsFromActivityItems
//            (List<EUR_CRM_Contract_Activity_Item__c> items) {
//        List<EUR_CRM_Contract_Product_Item__c> result = new List<EUR_CRM_Contract_Product_Item__c>();
//        for (EUR_CRM_Contract_Activity_Item__c item : items) {
//            if(item.Id != null) {
//                for(EUR_CRM_Contract_Product_Item__c product: item.Contract_Product_Items__r) {
//                    product.EUR_CRM_Contract_Activity_Item__c = item.Id;
//                    result.add(product);
//                }
//            } else {
//                throw new NullActivityItemIdException();
//            }
//        }
//        return result;
//    }

//    public PageReference saveClonedContract() {
//        PageReference pageRef = null;
//
//        Database.SaveResult contractInsertResult;
////            Database.SaveResult[] clineItemsInsertResult;
//        System.Savepoint pSavepoint = Database.setSavepoint();
////            Boolean isSaved = true;
//
//        try {
//            List<EUR_CRM_ContractClass.ContractLineItemWrapper> contractLineItemWrapperList = new List<EUR_CRM_ContractClass.ContractLineItemWrapper>();
//
//            System.debug('Flag - Save Cloned Contract : ' + clonedContractObj);
//            if (clonedContractObj.EUR_CRM_Account__c != null && clonedContractObj.EUR_CRM_End_Date__c != null && clonedContractObj.EUR_CRM_Start_Date__c != null) {
//                //Insert Contract
//                contractInsertResult = Database.insert(clonedContractObj);
//
//                //Copy Contract Line Items
//                if (clonedContractObj.Id != null) {
//                    List<EUR_CRM_Contract_Line_Item__c> clonedContractLineItemList = new List<EUR_CRM_Contract_Line_Item__c>();
//                    //Iterate Contract Line Items
//                    for (MechanicTypeWrapper mechanicWrapper : mechanicItems.values()) {
//                        for (EUR_CRM_Contract_Line_Item__c cli : mechanicWrapper.contractLineItemList) {
//                            EUR_CRM_Contract_Line_Item__c clonedCli = cli.clone(false, true);
//                            clonedCli.EUR_CRM_Contract__c = clonedContractObj.Id;
//                            clonedContractLineItemList.add(clonedCli);
//                        }
//
//                        if (mechanicWrapper.contractLineItemLumpSum != null) {
//                            EUR_CRM_Contract_Line_Item__c clonedCli = mechanicWrapper.contractLineItemLumpSum.clone(false, true);
//                            clonedCli.EUR_CRM_Contract__c = clonedContractObj.Id;
//                            clonedContractLineItemList.add(clonedCli);
//                        }
//
////Contract Cocktail
//                        contractLineItemWrapperList.addAll(mechanicWrapper.contractLineItemWrapperMap.values());
//                    }
//
////Save to Database
//                    if (clonedContractLineItemList.size() > 0) {
////clineItemsInsertResult = Database.insert(clonedContractLineItemList);
//                        List<Id> contractLineItemsInserted = new List<Id>();
//                        for (Database.SaveResult ur : Database.insert(clonedContractLineItemList)) {
//                            if (ur.isSuccess()) {
//                                contractLineItemsInserted.add(ur.getId());
//                            }
//                        }
//
//                        if (contractLineItemsInserted.size() > 0) {
//                            saveContractCocktails(contractLineItemsInserted, contractLineItemWrapperList);
//                        }
//                    }
//                    pageRef = new PageReference('/' + clonedContractObj.Id);
//                }
//            } else {
//                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error, 'Missing value on required field/s.'));
//            }
//
//        } catch (Exception e) {
//            System.debug('Save Clone Error: ' + e);
//            pageRef = null;
//            Database.rollback(pSavepoint);
//            String strError = e.getMessage() + '|' + String.valueOf(e.getLineNumber());
////System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
//            if (e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
//                String s = e.getDmlMessage(0);
//                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());
//                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
//            } else {
//                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
//            }
//        }
//
//        return pageRef;
//    }
//
//    private void saveContractCocktails(List<Id> contractLineItemsInserted, List<EUR_CRM_ContractClass.ContractLineItemWrapper> contractLineItemWrapperList) {
//        if (contractLineItemsInserted.size() > 0) {
//            List<EUR_CRM_Contract_Cocktail__c> contractCocktailsForInsert = new List<EUR_CRM_Contract_Cocktail__c>();
//
////key: EUR_CRM_Contract_Mechanic__c
//            Map<String, EUR_CRM_Contract_Line_Item__c> contractLineItemsMap = new Map<String, EUR_CRM_Contract_Line_Item__c>();
////Create Contract Line Item Map
//            for (EUR_CRM_Contract_Line_Item__c cli : [
//                    SELECT Id, EUR_CRM_Contract_Mechanic__c
//                    FROM EUR_CRM_Contract_Line_Item__c
//                    WHERE Id IN:contractLineItemsInserted
//            ]) {
//                contractLineItemsMap.put(cli.EUR_CRM_Contract_Mechanic__c, cli);
//            }
//
////Iterate Contract Line Item Wrapper if it has cocktail list
//            for (EUR_CRM_ContractClass.ContractLineItemWrapper cliWrapper : contractLineItemWrapperList) {
//                if (contractLineItemsMap.containsKey(cliWrapper.contractMechanic) && cliWrapper.contractCocktails.size() > 0) {
//                    for (EUR_CRM_ContractClass.ContractCocktailWrapper ccWrap : cliWrapper.contractCocktails) {
//                        EUR_CRM_Contract_Cocktail__c clonedContractCocktail = ccWrap.contractCocktail.clone(false, true);
//                        clonedContractCocktail.EUR_CRM_Contract_Line_Item__c = contractLineItemsMap.get(cliWrapper.contractMechanic).Id;
//                        contractCocktailsForInsert.add(clonedContractCocktail);
//                    }
//                }
//            }
////Save at DB
//            if (contractCocktailsForInsert.size() > 0) {
//                Database.insert(contractCocktailsForInsert);
//            }
//
//        }
//    }


//        private List<EUR_CRM_Contract_Line_Item__c> getContractLineItemContent(String mechanicTypeName){
//                if (allContractLineItems != null && allContractLineItems.containsKey(mechanicTypeName)){
//                        return allContractLineItems.get(mechanicTypeName);
//                }
//
//                return new List<EUR_CRM_Contract_Line_Item__c>();
//        }

    private EUR_CRM_Contract_Line_Item__c createLumpSumContractLineItem(EUR_CRM_Mechanic_Type__c mechanicType) {
        EUR_CRM_Contract_Line_Item__c lumpSumContractLineItem = new EUR_CRM_Contract_Line_Item__c();
        lumpSumContractLineItem.EUR_CRM_Contract__c = contractObj.Id;
        lumpSumContractLineItem.EUR_CRM_Mechanic_Type__c = mechanicType.Id;
        lumpSumContractLineItem.EUR_CRM_Value__c = 0;
        lumpSumContractLineItem.EUR_CRM_Process_Option_Lump_Sum__c = true;

        return lumpSumContractLineItem;
    }


    private void addMessage(ApexPages.Severity severity, String message) {
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }

    public class MechanicTypeWrapper {
        public EUR_CRM_Mechanic_Type__c mechanicType {
            get;
            set;
        }
        public String mechanicTypeName {
            get;
            set;
        }
        public Id mechanicTypeId {
            get;
            set;
        }
        public String mechanicTypeGroupingName {
            get;
            set;
        }
//public Decimal lumpSumAmount {get;set;}
        public boolean hasMechanicTypeChoice { get; set; }{
            hasMechanicTypeChoice = false;
        }
        public boolean hasBothMechanicType {
            get;
            set;
        }{
            hasBothMechanicType = false;
        }
//            public String mechanicTypeChoice {get;set;} //From Picklist: Lump Sum or Per BQ

        public Decimal totalValue {
            set;
            get {
                totalValue = 0;
//set value7s
                for (EUR_CRM_Contract_Line_Item__c cli : contractLineItemMap.values()) {
//Double tValue = (cli.EUR_CRM_Total_Value__c!=null)?cli.EUR_CRM_Total_Value__c:0;
                    Decimal tValue = (cli.EUR_CRM_Total_Value_Reference__c != null) ? cli.EUR_CRM_Total_Value_Reference__c : 0;
                    if (tValue <= 0 && cli.EUR_CRM_Value__c > 0) {
                        tValue = cli.EUR_CRM_Value__c;
                        cli.EUR_CRM_Total_Value_Reference__c = tValue;
                    }
                    totalValue += tValue;
                }
                totalValue += (contractLineItemLumpSum != null) ? contractLineItemLumpSum.EUR_CRM_Value__c : 0;
                return totalValue;
            }
        }{
            totalValue = 0;
        }

//public EUR_CRM_GenericTable contractLineItemsTable {get;set;}
//public EUR_CRM_GenericTable contractMechanicTable {get;set;}

        public EUR_CRM_Contract_Line_Item__c contractLineItemLumpSum {
            get;
            set;
        }
        public Map<String, EUR_CRM_Contract_Line_Item__c> contractLineItemMap { get; set; } {
            contractLineItemMap = new Map<String, EUR_CRM_Contract_Line_Item__c>();
        }//Key: EUR_CRM_Contract_Line_Item__c.EUR_CRM_Brand_Quality_Name__c
        public Map<Id, EUR_CRM_Contract_Mechanic__c> contractMechanicMap {
            get;
            set;
        } {
            contractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
        }// Key: EUR_CRM_Contract_Mechanic__c.Id

        public List<EUR_CRM_Contract_Line_Item__c> contractLineItemList {
            get {
                return ((contractLineItemMap.size() > 0) ? contractLineItemMap.values() : new List<EUR_CRM_Contract_Line_Item__c>());
            }
            set;
        }
        public List<EUR_CRM_Contract_Mechanic__c> contractMechanicList {
            get {
                return ((contractMechanicMap.size() > 0) ? contractMechanicMap.values() : new List<EUR_CRM_Contract_Mechanic__c>());
            }
            set;
        }

        public Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper> contractLineItemWrapperMap { get; set; }{
            contractLineItemWrapperMap = new Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper>();
        }


        public Integer contractLineItemMapSize {
            get {
                return contractLineItemMap.size();
            }
        }
        public Integer contractMechanicMapSize {
            get {
                return contractMechanicMap.size();
            }
        }

        public Set<Id> deletedContractLineItem {
            get;
            set;
        }{
            deletedContractLineItem = new Set<Id>();
        }

//FOR COCKTAIL
        public Map<String, EUR_CRM_Mechanic__c> mechanicMap {
            get;
            set;
        }{
            mechanicMap = new Map<String, EUR_CRM_Mechanic__c>();
        }//Key:Mechanic Name
        public Map<String, EUR_CRM_Mechanic__c> cocktailMechanicReference {
            get;
            set;
        }{
            cocktailMechanicReference = new Map<String, EUR_CRM_Mechanic__c>();
        }//Key:Contract Mechanic Reference Id; Value:Mechanic Name
        public Map<String, EUR_CRM_Contract_Mechanic__c> cocktailContractMechanicReference {
            get;
            set;
        }{
            cocktailContractMechanicReference = new Map<String, EUR_CRM_Contract_Mechanic__c>();
        }//Key:Contract Mechanic Reference Id; Value:Mechanic Name
//END OF COCKTAIL VARIABLES

        public Map<String, MechanicTypeWrapper> subMechanics {
            get;
            set;
        }
//            public Integer subMechanicsSize{get{
//                return subMechanics.size();
//            }}

        public MechanicTypeWrapper(String mechanicTypeName) {
            this.mechanicTypeName = mechanicTypeName;
        }

        public MechanicTypeWrapper(EUR_CRM_Mechanic_Type__c mechanicType) {
            this.mechanicType = mechanicType;
            this.mechanicTypeName = mechanicType.Name;
            this.mechanicTypeId = mechanicType.Id;
            this.mechanicTypeGroupingName = mechanicType.EUR_CRM_Grouping_Name__c;
        }

        public void setContractLineItemMap(List<EUR_CRM_Contract_Line_Item__c> cliList) {
            this.contractLineItemMap = new Map<String, EUR_CRM_Contract_Line_Item__c>();
            for (EUR_CRM_Contract_Line_Item__c cli : cliList) {
                this.contractLineItemMap.put(cli.EUR_CRM_Brand_Quality_Name__c, cli);
            }
        }

        public void setContractLineItemWrapperMap(List<EUR_CRM_Contract_Line_Item__c> cliList, Map<Id, Set<EUR_CRM_ContractClass.ContractCocktailWrapper>> contractCocktailMap) {
            this.contractLineItemWrapperMap = new Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper>();
            for (EUR_CRM_Contract_Line_Item__c cli : cliList) {
                EUR_CRM_ContractClass.ContractLineItemWrapper cliWrap = new EUR_CRM_ContractClass.ContractLineItemWrapper(cli);
                this.contractLineItemWrapperMap.put(cli.EUR_CRM_Brand_Quality_Name__c, cliWrap);
                if (contractCocktailMap.containsKey(cli.EUR_CRM_Contract_Mechanic__c)) {
                    cliWrap.contractCocktails.addAll(contractCocktailMap.get(cli.EUR_CRM_Contract_Mechanic__c));
                    //cliWrap.setCocktailsSelected(contractCocktailMap.get(cli.EUR_CRM_Contract_Mechanic__c));
                }

            }
        }
//Key: Brand-Quality Name
        public Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper> putContractLineItemWrappper(String key, EUR_CRM_Contract_Line_Item__c contractLineItem) {
            EUR_CRM_ContractClass.ContractLineItemWrapper cliWrap = new EUR_CRM_ContractClass.ContractLineItemWrapper(contractLineItem);
            this.contractLineItemWrapperMap.put(key, cliWrap);
            return this.contractLineItemWrapperMap;
        }

//Key: Brand-Quality Name
        public Map<String, EUR_CRM_Contract_Line_Item__c> putContractLineItem(String key, EUR_CRM_Contract_Line_Item__c contractLineItem) {
            this.contractLineItemMap.put(key, contractLineItem);
            return this.contractLineItemMap;
        }

        public Map<String, EUR_CRM_Contract_Line_Item__c> removeContractLineItem(String brandQualityName) {
            this.contractLineItemMap.remove(brandQualityName);
            return this.contractLineItemMap;
        }


        public void setContractMechanicMap(List<EUR_CRM_Contract_Mechanic__c> cmList) {
            this.contractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
            for (EUR_CRM_Contract_Mechanic__c cm : cmList) {
                this.contractMechanicMap.put(cm.Id, cm);
            }
        }

        public Map<Id, EUR_CRM_Contract_Mechanic__c> putContractMechanic(Id contractMechanicId, EUR_CRM_Contract_Mechanic__c contractMechanicObj) {
            this.contractMechanicMap.put(contractMechanicId, contractMechanicObj);
            return this.contractMechanicMap;
        }

        public Map<Id, EUR_CRM_Contract_Mechanic__c> removeContractMechanic(Id contractMechanicId) {
            this.contractMechanicMap.remove(contractMechanicId);
            return this.contractMechanicMap;
        }

        public Double amendTotalValue(Double amount) {
            this.totalValue += amount;

            return this.totalValue;
        }

    }

    //public class NullActivityItemIdException extends Exception {}

}