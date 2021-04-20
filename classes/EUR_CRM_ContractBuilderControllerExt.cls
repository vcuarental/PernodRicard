/**

May 6, 2015
 - Updated the 
*/
public with sharing class EUR_CRM_ContractBuilderControllerExt {
    public final static String DEFAULT_KEY = 'DEFAULT';
    
    public static String LUMP_SUM {get{ return 'Lump Sum';}}
    public static String PER_BQ {get{return 'Per Brand-Quality';}}
    
    private final static String DELIMITER = ' | ';
    private final static String LUMP_SUM_OR_PER_BQ = 'LUMP_SUM_OR_PER_BQ';
    private final static String BOTH_LUMP_SUM_AND_PER_BQ = 'BOTH';
    //private final static Map<String, List<String>> contractLineItemColumnsPerType= new Map<String, List<String>>();
    
    public static String CONTRACT_MECHANIC_TABLE_PREFIX {get{return 'ContractMechanicTable_';}}
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    
    //FOR MECHANIC TYPE
    private final static Set<String> EXPECTED_MECHANIC_TYPE_SET = new Set<String>{'Educations', 'Free Stock',
                                                                        'House Pouring', 'Marketing Support',
                                                                        'May Stock Item', 'Must Stock Item',
                                                                        'Point of Sales', 'Premium Pouring',
                                                                        'Trips', 'Cocktail'                                                                                                                                                     
                                                                };
    //FOR MARKETING PACKAGE MECHANIC TYPE
    private final static Set<String> MARKETING_PACKAGE_TYPE_SET = new Set<String>{'Educations', 'Free Stock',
                                                                        'Marketing Support', 'Point of Sales', 
                                                                        'Trips'                                                                                                                                                     
                                                                };

    //FOR COCKTAIL - REQ: Cocktail Contract Mechanic depends on Pouring and Stock
    private final static String COCKTAIL_MECHANIC_TYPE_NAME = 'Cocktail';
    private final static String POURING_GROUP_NAME = 'Pouring';
    private final static String STOCK_GROUP_NAME = 'Stock';
    private Set<String> cocktailGroupMechanicTypeSource = new Set<String>{POURING_GROUP_NAME.toUpperCase(), STOCK_GROUP_NAME.toUpperCase()};
    //Cocktail 
    private Map<String, EUR_CRM_Mechanic__c> cocktailMechanicMap{get;set;}{cocktailMechanicMap = new Map<String, EUR_CRM_Mechanic__c>();}
    public List<SelectOption> cocktailNameSelection{get;set;}{cocktailNameSelection = new List<SelectOption>();}
    //END COCKTAIL VAR
    
    //STOCK DEAL
    public Map<String, List<SelectOption>> stockDealSelectionMap{get;set;}{stockDealSelectionMap = new Map<String, List <SelectOption>>();}
    public Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> stockDealMap{get;set;}{stockDealMap = new Map<Id, EUR_CRM_Stock_Deal_Mechanic__c>();}
    public String stockDealKeyReference {get;set;}{stockDealKeyReference='';}
    public String stockDealJSON{get{
        return JSON.serialize(stockDealMap);
    }}
    //END STOCK DEAL VAR
    
    //PAGE VARIABLE
    private ApexPages.StandardController standardController {get;set;}
    
    
    //Contract Class
    private Id contractId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();                                 
            }
            return null;
        }
    }
    
    
    public Boolean isGB_RectypeId {get; set;}
    private  final String GB_CONTRACT_DEV_NAME = 'EUR_GB_Contract';
    
    
    public EUR_CRM_ContractClass contractClassObject {get; private set;}
    //Contract Obj
    public EUR_CRM_Contract__c contractObj{get; set;}
    public String currencyCode {get{return String.valueOf(contractObj.get('CurrencyIsoCode'));}}
    
    //Mechanic Type Wrapper Map
    public Map<String, MechanicTypeWrapper> mechanicTypeWrapperMap{get;set;}{mechanicTypeWrapperMap = new Map<String, MechanicTypeWrapper>();} //Key: MechanicType.Name
    
    //Marketing Package Mechanic Handling Choice, either Lump Sum or Per BQ
    public String marketingPackageHandlingChoice{get;set;}
    
    //Action Support Param
    public EUR_CRM_Contract_Line_Item__c contractLineItemParam{get;set;}
    public Id stockDealIdParam {get;set;}
    public String mechanicTypeNameParam{get;set;}
    public String brandQualityNameParam{get;set;}
    
    //Constructor
    public EUR_CRM_ContractBuilderControllerExt (ApexPages.StandardController standardController){
        this.standardController = standardController;
        
        if (this.standardController.getId()==null){
            addMessage(ApexPages.Severity.ERROR, Label.EUR_CRM_MissingIdMessage);
        }else{
            initContract();
            //initContractContent();
        }
        
    }
    
    
    public void initContract(){
        contractClassObject = new EUR_CRM_ContractClass(contractId);
        contractObj = contractClassObject.contractDetails;
        //System.debug('&&LUMP SUM: '+contractObj.EUR_CRM_Marketing_Package_Lump_Sum__c);
        if(contractObj.recordtypeId!=null){
            isGB_RectypeId = isGB_Contract(contractObj.recordtypeId);
        }
        contractObj.EUR_CRM_Mktg_Package_Mechanic_Handling__c = PER_BQ;
        //Set Contract Content
        initContractContent();
        
        //Set Cocktail Menu
        cocktailNameSelection = retrieveCocktailMenuSelection();
        //Set Stock Deal
        stockDealMap = retrieveStockDeals();
        stockDealSelectionMap = retrieveStockDealSelectionMap(stockDealMap.values());
    }
    
    public Boolean isGB_Contract(Id recordtypeId){
        String devname = [Select developername from recordtype where Id=:recordtypeId].developername;
        return (devname==GB_CONTRACT_DEV_NAME) ? true : false;
    }
    
    private void initContractContent(){
        //Initial creation of Mechanic Wrapper Map
            //System.debug('FLag - INIT Contract Content');
            //TODO Assign Cocktail Mechanic Type Source, base on mechanic type grouping name
        
            mechanicTypeWrapperMap = new Map<String, MechanicTypeWrapper>();
            //cocktailMechanicTypeSource = new Set<String>();
            
            //Initial Cocktail Contract Mechanic
            Map<Id, EUR_CRM_Contract_Mechanic__c> cocktailContractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
            
            if(contractClassObject != null){
                for(EUR_CRM_Mechanic_Type__c mType: contractClassObject.contractMechanicTypeMap.values()){
                    String key = mType.name;                                
                    //Create Mechanic Type Wrapper
                    MechanicTypeWrapper mTypeWrapper = new MechanicTypeWrapper(mType);
                    
                    //Assign Process Type
                    if (mType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(LUMP_SUM_OR_PER_BQ)){
                            mTypeWrapper.hasMechanicTypeChoice = true;
                        }   
                    /*if (mType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(BOTH_LUMP_SUM_AND_PER_BQ)){
                        mTypeWrapper.hasBothMechanicType = true;
                    }*/
                                    
                    //Set Contract Mechanics
                    List<EUR_CRM_Contract_Mechanic__c> contractMechanics = new List<EUR_CRM_Contract_Mechanic__c>();
                    if (contractClassObject.contractLineItemMap.size()>0){
                        contractMechanics = contractClassObject.getTrimmedContractMechanicItems(mType.Id, contractClassObject.contractLineItemMap);
                    }else{
                        contractMechanics = contractClassObject.retrieveContractMechanicItems(mType.Id);
                    }
                    contractMechanics = (contractMechanics==null)?new List<EUR_CRM_Contract_Mechanic__c>():contractMechanics;
                    if (key != COCKTAIL_MECHANIC_TYPE_NAME){
                            mTypeWrapper.setContractMechanicMap(contractMechanics);
                    }
                    
                    //Set Contract line items
                    List<EUR_CRM_Contract_Line_Item__c> contractLineItems = (contractClassObject.contractLineItemMap.containsKey(mType.Id))?contractClassObject.contractLineItemMap.get(mType.Id):new List<EUR_CRM_Contract_Line_Item__c>();
                    
                    //Parse Contract Line Item if Mechanic Type Processing is Both
                    if (mType.EUR_CRM_Mechanic_Process_Type__c.equalsIgnoreCase(BOTH_LUMP_SUM_AND_PER_BQ)){
                        //Set Mechanic Type Processing
                        mTypeWrapper.hasBothMechanicType = true;
                         
                        EUR_CRM_Contract_Line_Item__c cliLumpSum = new EUR_CRM_Contract_Line_Item__c();
                        List<EUR_CRM_Contract_Line_Item__c> cliList = new List<EUR_CRM_Contract_Line_Item__c>();
                        
                        //System.debug('Flag - Init Contract Content - Check Line Items:' + contractLineItems);
                        for (EUR_CRM_Contract_Line_Item__c cli: contractLineItems){
                            if (cli.EUR_CRM_Process_Option_Lump_Sum__c == true){
                                cliLumpSum = cli;
                            }else{
                                cliList.add(cli);
                            }
                        }
                        //Set Lump Sum Contract Line Item
                        //System.debug('Flag - Init Contract Content - Check Lump Sum Line Item:' + cliLumpSum);
                        mTypeWrapper.contractLineItemLumpSum =(cliLumpSum.Id!=null)?cliLumpSum:createLumpSumContractLineItem(mType);
                        //System.debug('Flag - Init Contract Content - Check Lump Sum Line Item 2:' + mTypeWrapper.contractLineItemLumpSum);
                        
                        //Set BQ Contract Line Items
                        mTypeWrapper.setContractLineItemMap(cliList);
                        //Edit: 10/22 - To support multiple cocktail name
                        mTypeWrapper.setContractLineItemWrapperMap(cliList, contractClassObject.contractCocktailMap);
                    }else{
                        mTypeWrapper.setContractLineItemMap(contractLineItems);
                        //Edit: 10/22 - To support multiple cocktail name
                        mTypeWrapper.setContractLineItemWrapperMap(contractLineItems, contractClassObject.contractCocktailMap);
                    }
                    //Put to Map
                    mechanicTypeWrapperMap.put(key, mTypeWrapper);
                    
                    //Create Cocktail Contract Mechanic
                    if (mType.EUR_CRM_Grouping_Name__c != null && cocktailGroupMechanicTypeSource.contains(mType.EUR_CRM_Grouping_Name__c.toUpperCase())){
                        cocktailContractMechanicMap.putAll(createContractMechanicFromContractLineItem(contractLineItems));
                    }
                    
                    //System.debug('Flag - Check Mechanic Wrapper:' + mTypeWrapper);
                }
                        
                //Set Cocktail Contract Mechanics
                //System.debug('Flag - Init Contract Content - Check Cocktail Mechanics:' + cocktailContractMechanicMap);
                if (cocktailContractMechanicMap.size()>0 && mechanicTypeWrapperMap.containsKey(COCKTAIL_MECHANIC_TYPE_NAME)){
                        MechanicTypeWrapper cocktailMechanicWrapper = mechanicTypeWrapperMap.get(COCKTAIL_MECHANIC_TYPE_NAME);
                        cocktailMechanicWrapper.contractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
                        cocktailMechanicWrapper.contractMechanicMap = cocktailContractMechanicMap;
                        //cocktailMechanicWrapper.cocktailContractMechanicReference = cocktailContractMechanicMap;
                        cocktailMechanicWrapper.cocktailContractMechanicReference = new Map<String, EUR_CRM_Contract_Mechanic__c>();
                        for (EUR_CRM_Contract_Mechanic__c cm: cocktailContractMechanicMap.values()){
                            cocktailMechanicWrapper.cocktailContractMechanicReference.put(String.valueOf(cm.EUR_CRM_Contract_Mechanic_Reference__c), cm);
                        }
                }

            }
    }
    
    //Add Contract Mechanic from Contract Line Item - Remove Contract Line Item
    public PageReference addContractMechanic(){
        //REMOVE: data from Contract Line Item - Get Contract Mechanic - Save at Contract Mechanic Map
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_brandQualityName = params.get('PARAM_BQ_NAME');
        
        
        //Find Mechanic Type
        MechanicTypeWrapper mtWrap = (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName))?mechanicTypeWrapperMap.get(param_mechanicTypeName):null;
        
        if (mtWrap != null){
                //Get Contract Line Item Obj
                EUR_CRM_Contract_Line_Item__c cliObj = mtWrap.contractLineItemMap.get(param_brandQualityName);

                system.debug('*** test mtWrap.contractLineItemMap ' + mtWrap.contractLineItemMap);
                //Get Contract Mechanic
                if (cliObj!=null){
                        EUR_CRM_Contract_Mechanic__c cmObj = retrieveExistingContractMechanic(cliObj.EUR_CRM_Contract_Mechanic__c);
                        if (cmObj != null){
                                //Add to Contract Mechanic Map
                                mtWrap.putContractMechanic(cmObj.Id, cmObj);
                                //Add to Deleted Contract Line Item Set
                               
                                if(cocktailGroupMechanicTypeSource.contains(mtWrap.mechanicTypeGroupingName.toUpperCase())){
                                        removeCocktailContractMechanic(cmObj);
                                }
                        }
                        
                        if (cliObj.Id != null){
                                mtWrap.deletedContractLineItem.add(cliObj.Id);
                        }
                }
                //Less Total Value
                //Double lineItemValue = calculateValue(cliObj);
                //lineItemValue = (lineItemValue>0)?(lineItemValue*-1):lineItemValue;
                //mtWrap.amendTotalValue(lineItemValue);
                //Remove Contract Line Item
                mtWrap.removeContractLineItem(param_brandQualityName);
                mtWrap.removeContractLineItemWrapper(param_brandQualityName);

        }
        return pageRef;
    }
    
    //Add Contract Line Item from Contract Mechanic
    public PageReference addContractLineItem(){
        //ADD:Data from Contract Mechanic - Create Contract Line Item - Save at Contract Line Item Map
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        Id param_contractMechanicId = (Id) params.get('PARAM_CONTRACT_MECHANIC_ID');
        //String param_brandQualityName = params.get('PARAM_BQ_NAME');
        
        //Find Mechanic Type
        MechanicTypeWrapper mtWrap = (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName))?mechanicTypeWrapperMap.get(param_mechanicTypeName):null;
        
        if (mtWrap != null){
            //Get Contract Mechanic Obj
            EUR_CRM_Contract_Mechanic__c cmObj = mtWrap.contractMechanicMap.get(param_contractMechanicId);
            //Create Contract Line Item
            EUR_CRM_Contract_Line_Item__c cliObj = createContractLineItemObj(this.contractId, param_contractMechanicId, cmObj.EUR_CRM_Brand_Quality_Name__c, cmObj.EUR_CRM_Mechanic_Name__c);
            //Add to Contract Line Item Map
            mtWrap.putContractLineItem(cmObj.EUR_CRM_Brand_Quality_Name_Ref__c, cliObj);
            mtWrap.putContractLineItemWrappper (cmObj.EUR_CRM_Brand_Quality_Name_Ref__c, cliObj);
            
            //Process Cocktail
            if(cocktailGroupMechanicTypeSource.contains(mtWrap.mechanicTypeGroupingName.toUpperCase())){
                        addCocktailContractMechanic(cmObj);
            }
            //Add Total Value
            Double lineItemValue = calculateValue(cliObj);
            //mtWrap.amendTotalValue(lineItemValue);
            //Remove Contract Mechanic
            mtWrap.removeContractMechanic(param_contractMechanicId);
        }
        
        return pageRef;
    }
    
    public PageReference addCocktailContractLineItem(){
        //ADD:Data from Cocktail Contract Mechanic - Create Cocktail Contract Line Item - Save at Cocktail Contract Line Item Map
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Id param_contractMechanicId = (Id) params.get('PARAM_CONTRACT_MECHANIC_ID');
        
        //Find Mechanic Type
        MechanicTypeWrapper mtWrap = (mechanicTypeWrapperMap.containsKey(COCKTAIL_MECHANIC_TYPE_NAME))?mechanicTypeWrapperMap.get(COCKTAIL_MECHANIC_TYPE_NAME):null;
        
        if (mtWrap != null){
            //Get Contract Mechanic Obj
            EUR_CRM_Contract_Mechanic__c cmObj = mtWrap.contractMechanicMap.get(param_contractMechanicId);
            //Create Contract Line Item
            EUR_CRM_Contract_Line_Item__c cliObj = new EUR_CRM_Contract_Line_Item__c(); //createContractLineItemObj(this.contractId, param_contractMechanicId, cmObj.EUR_CRM_Brand_Quality_Name_Ref__c);
                cliObj.EUR_CRM_Contract__c = this.contractId;
                cliObj.EUR_CRM_Contract_Mechanic_Ref__c = param_contractMechanicId;
                //cliObj.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c = cmObj.EUR_CRM_Brand_Quality__c;
                cliObj.EUR_CRM_Brand_Quality_Name__c = cmObj.EUR_CRM_Brand_Quality_Name_Ref__c;
                cliObj.EUR_CRM_Contract_Mechanic_Ref__c = cmObj.EUR_CRM_Contract_Mechanic_Reference__c;
                
            //Add to Contract Line Item Map
            mtWrap.putContractLineItem(cmObj.EUR_CRM_Contract_Mechanic_Reference__c, cliObj);
            mtWrap.putContractLineItemWrappper(cmObj.EUR_CRM_Contract_Mechanic_Reference__c, cliObj);
                
            //Remove Contract Mechanic
            mtWrap.removeContractMechanic(param_contractMechanicId);
        }
        
        return pageRef;

    }
    
    public PageReference removeCocktailContractLineItem(){
        //REMOVE: data from Cocktail Contract Line Item - Get Cocktail Contract Mechanic - Save at Contract Mechanic Map
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        //String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_brandQualityRef = params.get('PARAM_BQ_REF');
        
        
        //Find Mechanic Type
        MechanicTypeWrapper mtWrap = (mechanicTypeWrapperMap.containsKey(COCKTAIL_MECHANIC_TYPE_NAME))?mechanicTypeWrapperMap.get(COCKTAIL_MECHANIC_TYPE_NAME):null;
        
        if (mtWrap != null){
                //Get Contract Line Item Obj
                EUR_CRM_Contract_Line_Item__c cliObj = mtWrap.contractLineItemMap.get(param_brandQualityRef);
                if (cliObj != null) {
                    //Get Contract Mechanic
                    EUR_CRM_Contract_Mechanic__c cmObj = mtWrap.cocktailContractMechanicReference.get(String.valueOf(cliObj.EUR_CRM_Contract_Mechanic_Ref__c));
                    //Add to Contract Mechanic Map
                    mtWrap.putContractMechanic(cmObj.Id, cmObj);
                    //Add to Deleted Contract Line Item Set
                    if (cliObj.Id != null){
                            mtWrap.deletedContractLineItem.add(cliObj.Id);
                    }
                }
                //Remove Contract Line Item
                mtWrap.removeContractLineItem(param_brandQualityRef);
                mtWrap.removeContractLineItemWrapper(param_brandQualityRef);
        }
        return pageRef;

    }
    
    //Save (Boolean - Quick Save or Not)
    public PageReference saveContract(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        Boolean isQuickSave = Boolean.valueOf(params.get('IS_QUICK_SAVE'));
        
        Database.deleteResult[] deleteResultLineItems;
        Database.upsertResult[] upsertResultLineItems;
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        List<EUR_CRM_Contract_Line_Item__c> updateContractLineItemList = new List<EUR_CRM_Contract_Line_Item__c>();
        List<EUR_CRM_Contract_Line_Item__c> deleteContractItemList = new List<EUR_CRM_Contract_Line_Item__c>();
        List<Id> oldContractLineItemList = new List<Id>();
        //Cocktail Var
        List<EUR_CRM_ContractClass.ContractLineItemWrapper> contractLineItemWrapperList = new List<EUR_CRM_ContractClass.ContractLineItemWrapper>();
        
        try{        
            //Loop: Mechanic Type Wrappers
            //Get Contract Line Items
            //System.debug('Flag - Contract: '+contractObj.EUR_CRM_Mktg_Package_Mechanic_Handling__c);
            for(String key: mechanicTypeWrapperMap.keySet()){
                    MechanicTypeWrapper mTypeWrapper = mechanicTypeWrapperMap.get(key);
                            //Add to deleted contract line item list
                    oldContractLineItemList.addAll(mTypeWrapper.deletedContractLineItem);

                    //System.debug('Flag - Save Contract - Contract Line Items:'+key+'-'+mTypeWrapper.contractLineItemMap);
                    //System.debug('Flag - Save Contract - LUMP SUM:'+key+'-'+mTypeWrapper.contractLineItemLumpSum);
                    updateContractLineItemList.addAll(mTypeWrapper.contractLineItemMap.values());
                    contractLineItemWrapperList.addAll(mTypeWrapper.contractLineItemWrapperMap.values());
                    
                   /* 
                    if (mTypeWrapper.contractLineItemLumpSum != null && mTypeWrapper.contractLineItemLumpSum.EUR_CRM_Value__c>0){
                        EUR_CRM_Contract_Line_Item__c cliLumpSum = mTypeWrapper.contractLineItemLumpSum;
                        cliLumpSum.EUR_CRM_Total_Value_Reference__c = cliLumpSum.EUR_CRM_Value__c;
                        updateContractLineItemList.add(mTypeWrapper.contractLineItemLumpSum);
                    }       
                    */             
                    if (mTypeWrapper.contractLineItemLumpSum != null ){ 
                        EUR_CRM_Contract_Line_Item__c cliLumpSum = mTypeWrapper.contractLineItemLumpSum;
                        cliLumpSum.EUR_CRM_Value__c = cliLumpSum.EUR_CRM_Value__c == null ? 0 : cliLumpSum.EUR_CRM_Value__c;
                        cliLumpSum.EUR_CRM_Total_Value_Reference__c = cliLumpSum.EUR_CRM_Value__c;
                        updateContractLineItemList.add(mTypeWrapper.contractLineItemLumpSum);
                    }

                    /*if(contractObj.EUR_CRM_Mktg_Package_Mechanic_Handling__c == LUMP_SUM){
                        if(MARKETING_PACKAGE_TYPE_SET.contains(key)){deleteContractItemList.addAll(mTypeWrapper.contractLineItemMap.values());
                            if (mTypeWrapper.contractLineItemLumpSum != null && mTypeWrapper.contractLineItemLumpSum.EUR_CRM_Value__c>0){deleteContractItemList.add(mTypeWrapper.contractLineItemLumpSum);}
                        }
                    } else {
                        if (mTypeWrapper.contractLineItemLumpSum != null && mTypeWrapper.contractLineItemLumpSum.EUR_CRM_Value__c>0){EUR_CRM_Contract_Line_Item__c cliLumpSum = mTypeWrapper.contractLineItemLumpSum;
                            cliLumpSum.EUR_CRM_Total_Value_Reference__c = cliLumpSum.EUR_CRM_Value__c;
                            updateContractLineItemList.add(mTypeWrapper.contractLineItemLumpSum);
                        }
                    }*/
            }

            //Delete Old Contract Line Items
            if (oldContractLineItemList.size()>0){
                    deleteResultLineItems = Database.delete(oldContractLineItemList);
            }
            //Save Contract Line Item
            if (updateContractLineItemList.size()>0){
                //System.debug('Flag - Save Contract - Contract Line Items:' + updateContractLineItemList);
                List<Id> contractLineItemsUpserted = new List<Id>();
                for (Database.UpsertResult ur: Database.upsert(updateContractLineItemList)){
                    if (ur.isSuccess()){
                        contractLineItemsUpserted.add(ur.getId());
                    }
                }
                
                if (contractLineItemsUpserted.size()>0){
                    saveContractCocktails(contractLineItemsUpserted, contractLineItemWrapperList);
                }
            }
            //Save Contract
            Database.update(contractObj);

            //Delete Marketing Package line items
            /*if(deleteContractItemList.size() > 0){
                //System.debug('Flag - Delete Marketing Packages: '+deleteContractItemList);
                delete deleteContractItemList;
            }*/
            
            if (!isQuickSave){
                pageRef = new PageReference('/'+contractObj.Id);
            }
        }
        catch(Exception e){
            pageRef = null;
            Database.rollback(pSavepoint); 
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
            if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
            {
                String s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            }
            else{       
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
        }
        
        return pageRef;
    }
    
    private void saveContractCocktails (List<Id> contractLineItemsUpserted, List<EUR_CRM_ContractClass.ContractLineItemWrapper> contractLineItemWrapperList ){
        if (contractLineItemsUpserted.size()>0){
            List<EUR_CRM_Contract_Cocktail__c> contractCocktailsForInsert = new List<EUR_CRM_Contract_Cocktail__c>();
            List<Id> contractCocktailForDelete = new List<Id>();
            
            //key: EUR_CRM_Contract_Mechanic__c
            Map<String, EUR_CRM_Contract_Line_Item__c> contractLineItemsMap = new Map<String, EUR_CRM_Contract_Line_Item__c>();
            //Create Contract Line Item Map
            for (EUR_CRM_Contract_Line_Item__c cli: [SELECT Id, EUR_CRM_Contract_Mechanic__c 
                                                    FROM EUR_CRM_Contract_Line_Item__c
                                                    WHERE Id IN:contractLineItemsUpserted]){    
                contractLineItemsMap.put(cli.EUR_CRM_Contract_Mechanic__c, cli);
            }
            
            //Iterate Contract Line Item Wrapper if it has cocktail list
            for (EUR_CRM_ContractClass.ContractLineItemWrapper cliWrapper: contractLineItemWrapperList){
                if (contractLineItemsMap.containsKey(cliWrapper.contractMechanic) && (cliWrapper.cocktailsSelected.size()>0 || cliWrapper.contractCocktails.size()>0)){
                    Map<Id, Id> contractCocktailsReferenceMap = cliWrapper.contractCocktailsReferenceMap; //Key:Cocktail Menu Id; Value:Contract Cocktail Id
                    Set<Id> selectedCocktailMenuSet = new Set<Id>();
                    
                    for (SelectOption cocktailSelected: cliWrapper.cocktailsSelected){
                        selectedCocktailMenuSet.add(cocktailSelected.getValue());
                        //get list of new contract cocktails
                        if(!contractCocktailsReferenceMap.containsKey(cocktailSelected.getValue())){
                            EUR_CRM_Contract_Cocktail__c contractCocktail = new EUR_CRM_Contract_Cocktail__c(EUR_CRM_Cocktail_Menu__c=cocktailSelected.getValue());
                            contractCocktail.EUR_CRM_Contract_Line_Item__c = contractLineItemsMap.get(cliWrapper.contractMechanic).Id;
                            contractCocktailsForInsert.add(contractCocktail);
                        }
                    }
                    
                    for (Id key: contractCocktailsReferenceMap.keySet()){
                        if (!selectedCocktailMenuSet.contains(key)){
                            contractCocktailForDelete.add(contractCocktailsReferenceMap.get(key));
                        }
                    }
                }
            }
            //Save at DB
            if (contractCocktailForDelete.size()>0){
                Database.delete(contractCocktailForDelete);
            }
            
            if (contractCocktailsForInsert.size()>0){
                Database.upsert(contractCocktailsForInsert);
            }
            
        }
    }
    
    
    public PageReference resetMarketingLumpSum(){
        PageReference pageRef= null;
        
        //contractObj.EUR_CRM_Marketing_Package_Lump_Sum__c = 0;
        
        //TODO Reset Marketing Package Per BQ Line Items
        
        return pageRef;
    }
    
    public PageReference resetMechanicTypeHandling(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String mechanicTypeNameParam = params.get('PARAM_MECHANIC_TYPE_NAME');
        String handlingChoice = params.get('PARAM_HANDLING_CHOICE');
        
        if (mechanicTypeWrapperMap.containsKey(mechanicTypeNameParam)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(mechanicTypeNameParam);
            
            if (handlingChoice.equalsIgnoreCase(LUMP_SUM)){
                mechanicTypeWrap.contractLineItemMap= new Map<String, EUR_CRM_Contract_Line_Item__c>();
            }
            else if (handlingChoice.equalsIgnoreCase(PER_BQ)){
                mechanicTypeWrap.contractLineItemLumpSum = null;
            }
        }
        
        return pageRef;
    }
    
    
    public PageReference setLineItemValue(){
        PageReference pageRef = null;
        
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String mechanicTypeNameParam = params.get('PARAM_MECHANIC_TYPE_NAME');
        String brandQualityNameParam = params.get('PARAM_BQ_NAME');
        
        //Get Contract Line Item
        if (mechanicTypeWrapperMap.containsKey(mechanicTypeNameParam)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(mechanicTypeNameParam);
            if (mechanicTypeWrap.contractLineItemMap.containsKey(brandQualityNameParam)){
                EUR_CRM_Contract_Line_Item__c cli = mechanicTypeWrap.contractLineItemMap.get(brandQualityNameParam);
                //Calculate Item Value
                //System.debug('CHECK - Set Line Item Value - Stock Deal:' + cli.EUR_CRM_Stock_Deal__c +'-'+cli);
                if (cli.EUR_CRM_Stock_Deal__c!=null && String.valueOf(cli.EUR_CRM_Stock_Deal__c).trim().length()<=0){cli.EUR_CRM_Stock_Deal__c=null;}
                //cli.EUR_CRM_Stock_Deal__c = (String.valueOf(cli.EUR_CRM_Stock_Deal__c).trim().length()<=0) ? null : cli.EUR_CRM_Stock_Deal__c;
                Double itemValue = calculateValue(cli);
                //Set to total value
                cli.EUR_CRM_Total_Value_Reference__c = itemValue;
            }
        }
        return pageRef;
    }
    
    //Edit Cocktail Names
    public void Test(){}
    public PageReference editSelectedCocktail(){
        PageReference pageRef = null;
        
         Map<String, String> params = ApexPages.currentPage().getParameters();
        String mechanicTypeNameParam = params.get('PARAM_MECHANIC_TYPE_NAME');
        String brandQualityNameParam = params.get('PARAM_BQ_NAME');
        //String contractMechanicParam = params.get('PARAM_CONTRACT_MECHANIC');
        
        if (mechanicTypeWrapperMap.containsKey(mechanicTypeNameParam)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(mechanicTypeNameParam);
            if (mechanicTypeWrap.contractLineItemMap.containsKey(brandQualityNameParam)){
                EUR_CRM_ContractClass.ContractLineItemWrapper cliWrap = mechanicTypeWrap.contractLineItemWrapperMap.get(brandQualityNameParam);
                cliWrap.cocktailOnEdit = (!cliWrap.cocktailOnEdit);
            }
        }
        
        return pageRef;
    }
    
    //Create Contract Line Item (Contract, Mechanic, Brand Quality Name)
    private EUR_CRM_Contract_Line_Item__c createContractLineItemObj (Id contractId, Id contractMechanicId, String brandQualityName, String mechanicName){
        EUR_CRM_Contract_Line_Item__c newCLI = new EUR_CRM_Contract_Line_Item__c();
        newCLI.EUR_CRM_Contract__c = contractId;
        newCLI.EUR_CRM_Contract_Mechanic__c = contractMechanicId;
        
        newCLI.EUR_Min_Qty_Per_Annum_9L__c = 0;
        newCLI.EUR_CRM_Retro_Per_9L__c = 0;
        newCLI.EUR_CRM_No_of_People__c= 0;
        newCLI.EUR_CRM_Stock_Deal__c = null;
        newCLI.EUR_CRM_Value__c = 0;
        
        //newCLI.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c = brandQualityId;
        newCLI.EUR_CRM_Brand_Quality_Name__c = brandQualityName;
        if (mechanicName != null){
            newCLI.EUR_CRM_Mechanic_Name__c = mechanicName;
        }
        return newCLI;
    }
    

    //Get Contract Mechanic (Id)
    private EUR_CRM_Contract_Mechanic__c retrieveExistingContractMechanic (Id contractMechanicId){
        return contractClassObject.retrieveContractMechanic(contractMechanicId);
    }
    
    //Create Cocktail Mechanic Type
    private void addCocktailContractMechanic(EUR_CRM_Contract_Mechanic__c contractMechanicReference){
        //Get Cocktail Mechanic Wrapper
        MechanicTypeWrapper cocktailMechanicWrapper = mechanicTypeWrapperMap.get(COCKTAIL_MECHANIC_TYPE_NAME);
        
        //Create Mechanic
        EUR_CRM_Mechanic__c cocktailMechanic = new EUR_CRM_Mechanic__c();
        cocktailMechanic.Name = contractMechanicReference.EUR_CRM_Mechanic_Name__c;
        //cocktailMechanic.EUR_CRM_Unit_Volume__c = contractMechanicReference.
        
        //Create Contract Mechanic
        /*EUR_CRM_Contract_Mechanic__c cocktailContractMechanic = new EUR_CRM_Contract_Mechanic__c();
        cocktailContractMechanic.EUR_CRM_Brand_Quality__c = contractMechanicReference.EUR_CRM_Brand_Quality__c;
        cocktailContractMechanic.EUR_CRM_Contract_Mechanic_Reference__c = contractMechanicReference.Id;
        cocktailContractMechanic.EUR_CRM_Brand_Quality_Name_Ref__c = contractMechanicReference.EUR_CRM_Brand_Quality_Name__c;
        cocktailContractMechanic.EUR_CRM_Brand_Quality_Category_Ref__c = contractMechanicReference.EUR_CRM_Brand_Quality_Category__c;
        */
        
        EUR_CRM_Contract_Mechanic__c cocktailContractMechanic = contractClassObject.retrieveContractMechanic(contractMechanicReference.EUR_CRM_Brand_Quality__c, COCKTAIL_MECHANIC_TYPE_NAME);
        if (cocktailContractMechanic!= null){
                //Add on Cocktail Contract Mechanic Map
                cocktailMechanicWrapper.cocktailMechanicReference.put(String.valueOf(contractMechanicReference.Id), cocktailMechanic);
                //Add on Contract Mechanic Map - Used for display
                cocktailMechanicWrapper.contractMechanicMap.put(cocktailContractMechanic.Id, cocktailContractMechanic);
                //Add Cocktail Contract Mechanic Reference Map - to store all cocktail contract mechanics
                cocktailMechanicWrapper.cocktailContractMechanicReference.put(String.valueOf(contractMechanicReference.Id), cocktailContractMechanic);
        }
        ////System.debug('Flag - Add Cocktail Contract Mechanic - Mechanic Reference:' + )
    }
    
    private void removeCocktailContractMechanic(EUR_CRM_Contract_Mechanic__c contractMechanicReference){
        //Get Cocktail Contract Mechanic
        EUR_CRM_Contract_Mechanic__c cocktailContractMechanic = contractClassObject.retrieveContractMechanic(contractMechanicReference.EUR_CRM_Brand_Quality__c, COCKTAIL_MECHANIC_TYPE_NAME);
        
        if (cocktailContractMechanic!= null){
                //Get Cocktail Mechanic Wrapper
                MechanicTypeWrapper cocktailMechanicWrapper = mechanicTypeWrapperMap.get(COCKTAIL_MECHANIC_TYPE_NAME);
                //Remove on Cocktail Contract Mechanic Map
                if(cocktailMechanicWrapper.contractMechanicMap.containsKey(cocktailContractMechanic.Id)){
                        cocktailMechanicWrapper.contractMechanicMap.remove(cocktailContractMechanic.Id);
                }
                //Remove on Cocktail Contract Mechanic Map
                if (cocktailMechanicWrapper.cocktailContractMechanicReference.containsKey(contractMechanicReference.Id)){
                        cocktailMechanicWrapper.cocktailContractMechanicReference.remove(contractMechanicReference.Id);
                }
                //Remove on Cocktail Contract Line Item
                if (cocktailMechanicWrapper.contractLineItemMap.containsKey(contractMechanicReference.EUR_CRM_Brand_Quality_Name__c)){
                        cocktailMechanicWrapper.contractLineItemMap.remove(contractMechanicReference.EUR_CRM_Brand_Quality_Name__c);
                }
        }
    }
    
    private Map<Id, EUR_CRM_Contract_Mechanic__c> createContractMechanicFromContractLineItem(List<EUR_CRM_Contract_Line_Item__c> cLineItems){
        Map<Id, EUR_CRM_Contract_Mechanic__c> contractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
        /*
        for (EUR_CRM_Contract_Line_Item__c cli: cLineItems){
                EUR_CRM_Contract_Mechanic__c cm = new EUR_CRM_Contract_Mechanic__c();
                //cm.Id = cli.EUR_CRM_Contract_Mechanic__c;
                cm.EUR_CRM_Brand_Quality__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c;
                cm.EUR_CRM_Brand_Quality_Category_Ref__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality_Category__c;
                cm.EUR_CRM_Brand_Quality_Name_Ref__c = cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__r.Name;
                cm.EUR_CRM_Contract_Mechanic_Reference__c = cli.EUR_CRM_Contract_Mechanic__c;
                
                contractMechanicList.put(cm.EUR_CRM_Contract_Mechanic_Reference__c, cm);
        }
        
        //System.debug('Flag - Created Contract Mechanics:' + contractMechanicList);
        
        return contractMechanicList;
        */
        for (EUR_CRM_Contract_Line_Item__c cli: cLineItems){
                EUR_CRM_Contract_Mechanic__c cm = contractClassObject.retrieveContractMechanic(cli.EUR_CRM_Contract_Mechanic__r.EUR_CRM_Brand_Quality__c, COCKTAIL_MECHANIC_TYPE_NAME);
                
                if (cm != null){
                        contractMechanicMap.put(cm.Id, cm);
                }
        }
        return contractMechanicMap;
    }
    
    private EUR_CRM_Contract_Line_Item__c createLumpSumContractLineItem (EUR_CRM_Mechanic_Type__c mechanicType){
        EUR_CRM_Contract_Line_Item__c lumpSumContractLineItem = new EUR_CRM_Contract_Line_Item__c();
        lumpSumContractLineItem.EUR_CRM_Contract__c = contractObj.Id;
        lumpSumContractLineItem.EUR_CRM_Mechanic_Type__c = mechanicType.Id;
        lumpSumContractLineItem.EUR_CRM_Value__c = 0;
        lumpSumContractLineItem.EUR_CRM_Process_Option_Lump_Sum__c = true;
        
        return lumpSumContractLineItem;
    }
    
    private List<SelectOption> retrieveCocktailMenuSelection(){
        List<SelectOption> cocktailMenus = new List<SelectOption>();
        
        //cocktailMenus.add(new SelectOption('', '-None-'));
        for (EUR_CRM_Cocktail_Menu__c cocktailMenu: [SELECT Id, Name FROM EUR_CRM_Cocktail_Menu__c ORDER BY Name]){
                cocktailMenus.add(new SelectOption(cocktailMenu.Id, cocktailMenu.Name));
        }
        
        return cocktailMenus;
    }
    
    private Map<String, List<SelectOption>> retrieveStockDealSelectionMap(List<EUR_CRM_Stock_Deal_Mechanic__c> stockDeals){
        //Per BQ Name
        Map<String, List<SelectOption>> stockDealOptionMap = new Map<String, List<SelectOption>>();
        Set<String> stockDealsKeySet = new Set<String>();
        
        //stockDealOptionMap.put(DEFAULT_KEY, new List<SelectOption>());
        
        for (EUR_CRM_Stock_Deal_Mechanic__c stockDeal: stockDeals){
                String key = String.valueOf(stockDeal.EUR_CRM_Brand_Quality__r.Name);
                List<SelectOption> sdOptionList = (stockDealOptionMap.containsKey(key))?stockDealOptionMap.get(key): new List<SelectOption>{new SelectOption('', '-None-')};
                
                //Add Key on Set
                stockDealsKeySet.add(key);
                //Create Select Option
                SelectOption sdOption = new SelectOption(stockDeal.Id, stockDeal.EUR_CRM_Stock_Deal_Name__c);
                sdOptionList.add(sdOption);
                //Add Select Option List on Map
                stockDealOptionMap.put(stockDeal.EUR_CRM_Brand_Quality__r.Name, sdOptionList);
                
                /*if (stockDeal.EUR_CRM_RTM_Supplier_Account__c=null){
                        stockDealOptionMap.get(DEFAULT_KEY).add(sdOption);
                }*/
        }
        
        //Set Stock Deal Key Reference
        List<String> temp = new List<String>();
        temp.addAll(stockDealsKeySet);
        stockDealKeyReference = String.join(temp, DELIMITER);
        
        return stockDealOptionMap;
    }
    
    private Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> retrieveStockDeals(){
        Map<Id, EUR_CRM_Stock_Deal_Mechanic__c> stockDeals = new Map<Id, EUR_CRM_Stock_Deal_Mechanic__c>();
        
        //System.debug('Flag - Check:' + contractObj  + '-' + contractObj.EUR_CRM_Nominated_Supplier__c);
        String nominatedSupplier = contractObj.EUR_CRM_Nominated_Supplier__c;
        
        String stockDealQuery = 'SELECT Id, Name,'+
                                'EUR_CRM_Bottles_per_Case_BQ__c, EUR_CRM_Brand_Quality__c,'+
                                'EUR_CRM_Brand_Quality__r.Name, EUR_CRM_Date_Effective__c,'+
                                'EUR_CRM_Date_Expiry__c, EUR_CRM_External_ID__c,'+
                                'EUR_CRM_Liquid_per_Bottle_litre__c,    EUR_CRM_Litres_per_Case__c,'+
                                'EUR_CRM_Qty_Buy__c,    EUR_CRM_Qty_Free__c,'+
                                'EUR_CRM_RTM_Supplier_Account__c, EUR_CRM_RTM_Price__c,'+
                                'EUR_CRM_Stock_Deal_Name__c'+
                                ' FROM EUR_CRM_Stock_Deal_Mechanic__c'+
                                ' WHERE (EUR_CRM_Date_Effective__c<TODAY OR EUR_CRM_Date_Effective__c=TODAY)'+
                                ' AND (EUR_CRM_Date_Expiry__c>TODAY OR EUR_CRM_Date_Expiry__c=TODAY)';
                                
                //if (contractObj.EUR_CRM_Nominated_Supplier__c == null){
                        stockDealQuery += (contractObj.EUR_CRM_Nominated_Supplier__c == null)?' AND EUR_CRM_RTM_Supplier_Account__c = null':' AND EUR_CRM_RTM_Supplier_Account__c =:nominatedSupplier';
                //}else{
                //        stockDealQuery +=  ' AND EUR_CRM_RTM_Supplier_Account__c =: contractObj.EUR_CRM_Nominated_Supplier__c';
                //}
                stockDealQuery += ' LIMIT 49999';
                
                //System.debug('Flag - STOCK DEAL QUERY:' + stockDealQuery);
                //'AND (EUR_CRM_RTM_Supplier_Account__c=null OR EUR_CRM_RTM_Supplier_Account__c=:contractObj.EUR_CRM_Nominated_Supplier__c)'+
                //'LIMIT 49999'
        //List<EUR_CRM_Stock_Deal_Mechanic__c> stockDealList = Database.query(stockDealQuery);
        for(EUR_CRM_Stock_Deal_Mechanic__c stockDeal: Database.query(stockDealQuery)){
        /*for(EUR_CRM_Stock_Deal_Mechanic__c stockDeal: Database.query([SELECT Id, Name,
                                                                EUR_CRM_Bottles_per_Case_BQ__c, EUR_CRM_Brand_Quality__c,
                                                                EUR_CRM_Brand_Quality__r.Name, EUR_CRM_Date_Effective__c,
                                                                EUR_CRM_Date_Expiry__c, EUR_CRM_External_ID__c,'+
                                                                EUR_CRM_Liquid_per_Bottle_litre__c,     EUR_CRM_Litres_per_Case__c,
                                                                EUR_CRM_Qty_Buy__c,     EUR_CRM_Qty_Free__c,
                                                                EUR_CRM_RTM_Supplier_Account__c, EUR_CRM_RTM_Price__c,
                                                                EUR_CRM_Stock_Deal_Name__c
                                                                FROM EUR_CRM_Stock_Deal_Mechanic__c
                                                                WHERE (EUR_CRM_Date_Effective__c<TODAY OR EUR_CRM_Date_Effective__c=TODAY)
                                                                AND (EUR_CRM_Date_Expiry__c>TODAY OR EUR_CRM_Date_Expiry__c=TODAY)
                                                                AND (EUR_CRM_RTM_Supplier_Account__c=null OR EUR_CRM_RTM_Supplier_Account__c=:contractObj.EUR_CRM_Nominated_Supplier__c)
                                                                LIMIT 49999])){*/
                        stockDeals.put(stockDeal.Id, stockDeal);
        }
        
        return stockDeals;
    }
    
    private Double calculateValue (EUR_CRM_Contract_Line_Item__c contractLineItem){
        Double value = 0;
        Double discountAmount = 0;
        
        if (contractLineItem.EUR_CRM_Value__c != null && contractLineItem.EUR_CRM_Value__c>0){
            value= contractLineItem.EUR_CRM_Value__c;
        }
        else if (contractLineItem.EUR_Min_Qty_Per_Annum_9L__c != null && contractLineItem.EUR_Min_Qty_Per_Annum_9L__c>0){
            if (contractLineItem.EUR_CRM_Stock_Deal__c != null && String.valueOf(contractLineItem.EUR_CRM_Stock_Deal__c).trim().length()>0 && stockDealMap.containsKey(contractLineItem.EUR_CRM_Stock_Deal__c)){
                //get stock deal 
                EUR_CRM_Stock_Deal_Mechanic__c stockDeal = stockDealMap.get(contractLineItem.EUR_CRM_Stock_Deal__c);
                discountAmount = ((stockDeal.EUR_CRM_Litres_per_Case__c/stockDeal.EUR_CRM_Bottles_per_Case_BQ__c/stockDeal.EUR_CRM_Liquid_per_Bottle_litre__c/stockDeal.EUR_CRM_Qty_Buy__c)*stockDeal.EUR_CRM_Qty_Free__c)*stockDeal.EUR_CRM_RTM_Price__c;
            }  
            contractLineItem.EUR_CRM_Retro_Per_9L__c = (contractLineItem.EUR_CRM_Retro_Per_9L__c!=null)?contractLineItem.EUR_CRM_Retro_Per_9L__c:0;
            
            value =  contractLineItem.EUR_Min_Qty_Per_Annum_9L__c*(contractLineItem.EUR_CRM_Retro_Per_9L__c + discountAmount);      
        }
        
        contractLineItem.EUR_CRM_Total_Value_Reference__c = value;
        return value;
    }
    
    private void addMessage(ApexPages.Severity severity, String message){
        ApexPages.addMessage(new ApexPages.Message(severity, message));
    }
    
    
    //Wrapper Class
        public class MechanicTypeWrapper{
            public EUR_CRM_Mechanic_Type__c mechanicType{get;set;}
            public String mechanicTypeName {get;set;}
            public Id mechanicTypeId {get;set;}
            public String mechanicTypeGroupingName{get;set;}
            //public Decimal lumpSumAmount {get;set;}
            public boolean hasMechanicTypeChoice{get;set;}{hasMechanicTypeChoice=false;}
            public boolean hasBothMechanicType{get;set;}{hasBothMechanicType=false;}
            public String mechanicTypeChoice {get;set;} //From Picklist: Lump Sum or Per BQ
            
            public Decimal totalValue{set;get{
                    totalValue = 0;
                    //set value7s 
                    for (EUR_CRM_Contract_Line_Item__c cli: contractLineItemMap.values()){
                        //Double tValue = (cli.EUR_CRM_Total_Value__c!=null)?cli.EUR_CRM_Total_Value__c:0;
                        Decimal tValue = (cli.EUR_CRM_Total_Value_Reference__c!=null)?cli.EUR_CRM_Total_Value_Reference__c:0;
                        if (tValue<=0 && cli.EUR_CRM_Value__c>0){
                            tValue = cli.EUR_CRM_Value__c;
                            cli.EUR_CRM_Total_Value_Reference__c = tValue;
                        }
                        totalValue += tValue;
                    }
                totalValue += (contractLineItemLumpSum!=null)?contractLineItemLumpSum.EUR_CRM_Value__c:0;
                return totalValue;
            }}{totalValue = 0;}
            
            //public EUR_CRM_GenericTable contractLineItemsTable {get;set;}
            //public EUR_CRM_GenericTable contractMechanicTable {get;set;}
            
            public EUR_CRM_Contract_Line_Item__c contractLineItemLumpSum{get;set;}
            public Map<String, EUR_CRM_Contract_Line_Item__c> contractLineItemMap {get;set;} {contractLineItemMap= new Map<String, EUR_CRM_Contract_Line_Item__c>();}//Key: EUR_CRM_Contract_Line_Item__c.EUR_CRM_Brand_Quality_Name__c
            public Map<Id, EUR_CRM_Contract_Mechanic__c> contractMechanicMap {get;set;} {contractMechanicMap= new Map<Id, EUR_CRM_Contract_Mechanic__c>();}// Key: EUR_CRM_Contract_Mechanic__c.Id
            
            public List<EUR_CRM_Contract_Line_Item__c> contractLineItemList{get{
                return ((contractLineItemMap.size()>0)?contractLineItemMap.values(): new List<EUR_CRM_Contract_Line_Item__c>());}set;}
            public List<EUR_CRM_Contract_Mechanic__c> contractMechanicList{get{
                return ((contractMechanicMap.size()>0)?contractMechanicMap.values(): new List<EUR_CRM_Contract_Mechanic__c>());}set;}
                
            public Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper> contractLineItemWrapperMap {get;set;}{contractLineItemWrapperMap = new Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper>();}
            
            public Integer contractLineItemMapSize {get{return contractLineItemMap.size();}}
            public Integer contractMechanicMapSize {get{return contractMechanicMap.size();}}

            public Set<Id> deletedContractLineItem {get;set;}{deletedContractLineItem = new Set<Id>();}
            
            //FOR COCKTAIL
            public Map<String, EUR_CRM_Mechanic__c> mechanicMap {get;set;}{mechanicMap = new Map<String, EUR_CRM_Mechanic__c>();}//Key:Mechanic Name
            public Map<String, EUR_CRM_Mechanic__c> cocktailMechanicReference{get;set;}{cocktailMechanicReference = new Map<String, EUR_CRM_Mechanic__c>();}//Key:Contract Mechanic Reference Id; Value:Mechanic Name
            public Map<String, EUR_CRM_Contract_Mechanic__c> cocktailContractMechanicReference{get;set;}{cocktailContractMechanicReference = new Map<String, EUR_CRM_Contract_Mechanic__c>();}//Key:Contract Mechanic Reference Id; Value:Mechanic Name
            //END OF COCKTAIL VARIABLES
            
            public Map<String, MechanicTypeWrapper> subMechanics {get;set;}
            public Integer subMechanicsSize{get{
                return subMechanics.size();
            }}
            
            public MechanicTypeWrapper(String mechanicTypeName){
                this.mechanicTypeName = mechanicTypeName;
            }
            
            public MechanicTypeWrapper(EUR_CRM_Mechanic_Type__c mechanicType){
                this.mechanicType = mechanicType;
                this.mechanicTypeName = mechanicType.Name;
                this.mechanicTypeId = mechanicType.Id;
                this.mechanicTypeGroupingName = mechanicType.EUR_CRM_Grouping_Name__c;
            }
            
            public void setContractLineItemMap(List<EUR_CRM_Contract_Line_Item__c> cliList){
                this.contractLineItemMap = new Map<String, EUR_CRM_Contract_Line_Item__c>();
                for(EUR_CRM_Contract_Line_Item__c cli: cliList){
                        this.contractLineItemMap.put(cli.EUR_CRM_Brand_Quality_Name__c, cli);
                }
            }
            
            public void setContractLineItemWrapperMap(List<EUR_CRM_Contract_Line_Item__c> cliList, Map<Id, Set<EUR_CRM_ContractClass.ContractCocktailWrapper>> contractCocktailMap){
                this.contractLineItemWrapperMap = new Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper>();
                String pageName = ApexPages.currentPage().getUrl().substringAfter('apex/');

                for(EUR_CRM_Contract_Line_Item__c cli: cliList){
                    EUR_CRM_ContractClass.ContractLineItemWrapper cliWrap = null;
                    if (pageName.containsIgnoreCase('EUR_CRM_ContractSummaryPage')) {
                        cliWrap = new EUR_CRM_ContractClass.ContractLineItemWrapper(cli, false);
                    } else {
                        cliWrap = new EUR_CRM_ContractClass.ContractLineItemWrapper(cli);
                    }
                    this.contractLineItemWrapperMap.put(cli.EUR_CRM_Brand_Quality_Name__c, cliWrap);
                    if (contractCocktailMap.containsKey(cli.EUR_CRM_Contract_Mechanic__c)){
                        cliWrap.contractCocktails.addAll(contractCocktailMap.get(cli.EUR_CRM_Contract_Mechanic__c));
                        cliWrap.setCocktailsSelected(contractCocktailMap.get(cli.EUR_CRM_Contract_Mechanic__c));
                    }

                }
            }
            //Key: Brand-Quality Name
            public Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper> putContractLineItemWrappper (String key, EUR_CRM_Contract_Line_Item__c contractLineItem){
                EUR_CRM_ContractClass.ContractLineItemWrapper cliWrap = new EUR_CRM_ContractClass.ContractLineItemWrapper(contractLineItem);
                this.contractLineItemWrapperMap.put(key, cliWrap);
                return this.contractLineItemWrapperMap;
            }
            
            //Key: Brand-Quality Name
            public Map<String, EUR_CRM_Contract_Line_Item__c> putContractLineItem (String key, EUR_CRM_Contract_Line_Item__c contractLineItem){
                this.contractLineItemMap.put(key, contractLineItem);
                return this.contractLineItemMap;
            }
            
            public Map<String, EUR_CRM_ContractClass.ContractLineItemWrapper> removeContractLineItemWrapper (String brandQualityName){
                this.contractLineItemWrapperMap.remove(brandQualityName);
                return this.contractLineItemWrapperMap;
            }
            
            public Map<String, EUR_CRM_Contract_Line_Item__c> removeContractLineItem (String brandQualityName){
                this.contractLineItemMap.remove(brandQualityName);
                return this.contractLineItemMap;
            }

            public void setContractMechanicMap (List<EUR_CRM_Contract_Mechanic__c> cmList){
                this.contractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();
                for(EUR_CRM_Contract_Mechanic__c cm: cmList){
                        this.contractMechanicMap.put(cm.Id, cm);
                }
            }
            
            public Map<Id, EUR_CRM_Contract_Mechanic__c> putContractMechanic(Id contractMechanicId, EUR_CRM_Contract_Mechanic__c contractMechanicObj){
                this.contractMechanicMap.put(contractMechanicId, contractMechanicObj);
                return this.contractMechanicMap;
            }
            
            public Map<Id, EUR_CRM_Contract_Mechanic__c> removeContractMechanic(Id contractMechanicId){
                this.contractMechanicMap.remove(contractMechanicId);
                return this.contractMechanicMap;
            }
            
            public Double amendTotalValue(Double amount){
                this.totalValue += amount;
                
                return this.totalValue;
            }

        }
        
        public class rowWrapper{
                public Integer rowId {get;set;}
                public sObject sObj {get;set;} // row sObject content
                
                public rowWrapper(Integer id, sObject obj){
                        rowId = id;
                        sObj = obj;
                }
        }
  
}