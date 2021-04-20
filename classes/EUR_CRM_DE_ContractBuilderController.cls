/*
* Edit 12/15: 
    (1)For Flagship contract, apply ignore contract mechanic (EUR_CRM_Ignore_CM_Flagship__c) on checked Mechanic Types, instead use Brands/BQ from product hierarchy
    (2) Set Liter as default value for Unit pick list. Previously using inputField but probably a SFDC bug it doesn't use the default value instead adds -None- on options.
  Edit 2017-June-01:
    Change getIsInsufficientBalance checking: add deductibleContractTotalofCurrentFY, TotalByCurrentFY and DeductibleTotalByCurrentFY
  Edit 2017-June-20
    Update getIsInsufficientBalance checking: Use budget transaction to compare with current balance of budget
*/
public without sharing class EUR_CRM_DE_ContractBuilderController extends EUR_CRM_PageControllerBase {

    private ApexPages.StandardController standardController {get;set;}
    private Id contractId {
        get{
            if (this.standardController!=null){
                return this.standardController.getId();
            }
            return null;
            }
    }
    private Set<String> BQ_MECHANIC_TYPE_SET {get{return new Set<String>{'Pouring Refund'};}}
    public String FLAGSHIP_CONTRACT {get{return 'Flagship Contract';}}
    public Set<String> ALWAYS_EXCLUDED_BUDGET{get{return new Set<String>{'POS Material'};}}
    public Set<String> OVERLAP_CHECKING = new Set<String>{'Pouring Refund'};
//    private String DE_CONTRACT_ACTIVITY_ITEM = 'Contract_Activity_Item';
    private String DE_CONTRACT_ACTIVITY_ITEM = 'EUR_DE_Contract_Activity_Item';
    private String NO_INVOICING_PAYMENT_TERM = 'Keine Abrechnung';
    public String IS_QUICK_SAVE {get; set;}
    public String PR_DEUTSCHLAND {get{return 'PR Deutschland';}}
    public String FOCUS_BRAND_KEY {get{return 'FOCUS_BRAND';}}
    public String LISTING_POURING_KEY {get{return 'LISTING_POURING';}}
    public String LISTING_KEY {get{return 'LISTING';}}
    public String POURING_KEY {get{return 'POURING';}}
    public static String CONTRACT_MECHANIC_TABLE_PREFIX {get{return 'ContractMechanicTable_';}}
    public static String CONTRACT_LINE_ITEM_TABLE_PREFIX {get{ return 'ContractLineItemTable_';}}
    public static String CONTRACT_SUMMARY_ITEM_PREFIX {get{ return 'ContractItemSummaryTable_';}}
    public static String DESCRIPTION_PREFIX {get{ return 'DESC';}}
    public static String CURRENT_CONTRACT_ACTIVITY_FLAG {get{ return 'CURRENT_CA_FLAG';}}
    public static String FLAGSHIP {get{return 'FLAGSHIP';}}

//	private Map<String, String> PAYMENT_TERMS_ENG_DE_MAPPING = new Map<String, String> {
//			'After implementation' => 'Nach Umsetzung'
//		,	'Beginning of contract' => 'Nach Vertragsabschluss (einmalig)'
//		,	'Beginning of Contract item period' => 'Zu Beginn der Vertragsposition'
//		,	'Half-Yearly After Implementation' => 'Halbjährlich nach Leistungserfüllung'
//		,	'No Invoicing' => 'Keine Abrechnung'
//		,	'Yearly after implementation' => 'Jährlich nach Leistungserfüllung'
//		,	'3rd party invoicing' => 'Abrechnung durch Dritte'
//        ,   'Invoiced by 3rd party' => 'Abrechnung durch Dritte'
//	};
    private Map<String, ContractFormSettingWrapper> contractFormSettingWrapperByMTextId;

    private Map<String, Schema.SObjectField> contractActivityFieldMap {get;set;}
    //private Map<String, EUR_CRM_ComponentControllerBase> componentControllerMap{get;set;}{componentControllerMap = new  Map<String, EUR_CRM_ComponentControllerBase>();}
    private EUR_CRM_ContractFocusBrand_Controller focusBrandComponentController{
        set;
        get{
            //get the map, then the component controller using the appropriate key
            if(getComponentControllerMap()!=null){
              EUR_CRM_ContractFocusBrand_Controller compController;
              compController = (EUR_CRM_ContractFocusBrand_Controller )getComponentControllerMap().get(FOCUS_BRAND_KEY);
              if(compController!= null)
                 return compController;
            }
            //just in case something goes wrong return something...this can be handled better
            return new EUR_CRM_ContractFocusBrand_Controller();
        }
    }
//    private EUR_CRM_ContractListingPouringController listingPouringComponentController{
//        set;
//        get{
//            //get the map, then the component controller using the appropriate key
//            if(getComponentControllerMap()!=null){
//              EUR_CRM_ContractListingPouringController compController;
//              compController = (EUR_CRM_ContractListingPouringController )getComponentControllerMap().get(LISTING_POURING_KEY);
//              if(compController!= null)
//                 return compController;
//            }
//            //just in case something goes wrong return something...this can be handled better
//            return new EUR_CRM_ContractListingPouringController();
//        }
//    }

    private EUR_CRM_ContractListingController listingComponentController{
        set;
        get{
            //get the map, then the component controller using the appropriate key
            if(getComponentControllerMap()!=null){
                EUR_CRM_ContractListingController compController;
                compController = (EUR_CRM_ContractListingController )getComponentControllerMap().get(LISTING_KEY);
                if(compController!= null)
                    return compController;
            }
            //just in case something goes wrong return something...this can be handled better
            return new EUR_CRM_ContractListingController();
        }
    }

    private EUR_CRM_ContractPouringController pouringComponentController{
        set;
        get{
            //get the map, then the component controller using the appropriate key
            if(getComponentControllerMap()!=null){
                EUR_CRM_ContractPouringController compController;
                compController = (EUR_CRM_ContractPouringController )getComponentControllerMap().get(POURING_KEY);
                if(compController!= null)
                    return compController;
            }
            //just in case something goes wrong return something...this can be handled better
            return new EUR_CRM_ContractPouringController();
        }
    }

    public Map<Id, EUR_CRM_Mechanic_Type__c> mechanicTypeMap{get;set;}{mechanicTypeMap = new Map<Id, EUR_CRM_Mechanic_Type__c>();}
    public Map<Id, EUR_CRM_Mechanic_Type__c> oldMechanicTypeMap{get;set;}{oldMechanicTypeMap = new Map<Id, EUR_CRM_Mechanic_Type__c>();}

	public static Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingCMTByMechanicTypeExtId{
		set;
		get{
            if(contractSettingCMTByMechanicTypeExtId == null) return getProductLevelByMechanicTypeExtId('DE');
            return contractSettingCMTByMechanicTypeExtId;
		}
	}
    private static List<Schema.PicklistEntry> paymentTermPicklistEntries{
        set;
        get{
            if (paymentTermPicklistEntries == null) return EUR_CRM_Contract_Activity_Item__c.EUR_CRM_Payment_Term__c.getDescribe().getPicklistValues();
            return paymentTermPicklistEntries;
        }
    }
    private Map<Id, Map<Id, EUR_CRM_Brand__c>> brandsPerMechanicType {get;set;} {brandsPerMechanicType = new Map<Id, Map<Id, EUR_CRM_Brand__c>>();}
    private Map<Id, Map<Id, EUR_CRM_Quality__c>> brandQualitiesPerMechanicType {get;set;} {brandQualitiesPerMechanicType = new Map<Id, Map<Id, EUR_CRM_Quality__c>>();}
    private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivities {get;set;}{contractActivities = new Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();}

    public Set<String> mechanicTypeSet{get;set;}{mechanicTypeSet = new Set<String>{'Pouring Refund', 'Others', 'Drinks Menu',
                                                                                        'WKZ Fix Amount', 'Napkins', 'Events',
                                                                                        'Training', 'Visibility/ Branding', 'POS Material',
                                                                                        'POS WKZ', 'House Pouring', 'Listing'};}
    public static Set<String> mechanicTypeRequiredContractActivityName{get;set;}{mechanicTypeRequiredContractActivityName = new Set<String>{'Events', 'Training'};}

    public EUR_CRM_Contract__c contractObj {get;set;}

    public String mechanicTypeValue {get; set;}

    public Id selectedFlagshipBrand {get;set;}
    public List<SelectOption> flagshipBrandSelection{get;set;}{flagshipBrandSelection = new List<SelectOption>();}
    public Map<Id, EUR_CRM_Brand__c> allFlagshipBrandMap {get;set;}{allFlagshipBrandMap = new Map<Id, EUR_CRM_Brand__c>();}
    public Map<Id, EUR_CRM_Quality__c> allFlagshipBrandQualityMap {get;set;}{allFlagshipBrandQualityMap = new Map<Id, EUR_CRM_Quality__c>();}
    public List<EUR_CRM_Quality__c> listingPouringBQList {get;set;}{listingPouringBQList = new List<EUR_CRM_Quality__c>();}

    public Map<Id, EUR_CRM_Brand__c> allBrandMap {get;set;}{allBrandMap = new Map<Id, EUR_CRM_Brand__c>();}//Main Contract Source Ref
    public List<EUR_CRM_Brand__c>allBrandList{get{return allBrandMap.values();}}
    public Map<Id, EUR_CRM_Quality__c> allBrandQualityMap {get;set;}{allBrandQualityMap = new Map<Id, EUR_CRM_Quality__c>();}//Main Contract Source Ref
    public List<EUR_CRM_Quality__c> allBrandQualityList{get{return allBrandQualityMap.values();}}
    public Map<String, MechanicTypeWrapper> mechanicTypeWrapperMap {get;set;}{mechanicTypeWrapperMap = new Map<String, MechanicTypeWrapper>();}


    public Boolean isFlagshipMode{get{
        return (contractObj!=null && (contractObj.EUR_CRM_Contract_Type__c.equalsIgnoreCase(FLAGSHIP_CONTRACT))?true:false);
        }}

    public Double actualContractTotal{
        get{
                Double total=0;
                for (MechanicTypeWrapper mechanicTypeWrap: mechanicTypeWrapperMap.values()){
                    Double iTotal = (mechanicTypeWrap.total==null)?0:mechanicTypeWrap.total;
                    total += iTotal;
                }
                return total;
        }
    }

    public Double deductibleContractTotal{
        get{
                Double total=0;
                for (MechanicTypeWrapper mechanicTypeWrap: mechanicTypeWrapperMap.values()){
                        total += mechanicTypeWrap.deductibleTotal;
                }
                return total;
        }
    }

//    public Double deductibleContractTotalofCurrentFY{
//        get{
//                Double total=0;
//                for (MechanicTypeWrapper mechanicTypeWrap: mechanicTypeWrapperMap.values()){
//                    total += mechanicTypeWrap.DeductibleTotalByCurrentFY();
//                }
//                return total;
//        }
//    }

    public List<SelectOption> unitOptions {get{
        String defaultValue = null;
        List<SelectOption> options  = new List<SelectOption>();
        Schema.DescribeFieldResult unitFieldDescription = EUR_CRM_Contract_Product_Item__c.EUR_CRM_Unit__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: unitFieldDescription.getPicklistValues()){
            options.add(new SelectOption(pickListEntry.getValue(),pickListEntry.getLabel()));
            if (picklistEntry.defaultValue){
                defaultValue = pickListEntry.getValue();
            }
        }
        if (defaultValue == null){
            String noneValue = '-None-';
            options.add(new SelectOption(noneValue, null));
            defaultValue = noneValue;
        }

        return options;
    }set;}

    public String defaultUnitValue{get{
        String defaultValue = null;
        Schema.DescribeFieldResult unitFieldDescription = EUR_CRM_Contract_Product_Item__c.EUR_CRM_Unit__c.getDescribe();
        for (Schema.Picklistentry picklistEntry: unitFieldDescription.getPicklistValues()){
            if (picklistEntry.defaultValue){
                defaultValue = pickListEntry.getValue();
            }
        }

        if (defaultValue == null){
            String noneValue = '-None-';
            unitOptions.add(new SelectOption(noneValue, null));
            defaultValue = noneValue;
        }
        return defaultValue;
    }set;}

    public Decimal remainingUserBudgetTotal{get;set;}
    public String remainingUserBudgetTotalStr{get{return remainingUserBudgetTotal.format();}}
    public transient String userProfileName {get;set;}
    public EUR_CRM_DE_ContractBuilderController(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType contractActivitySchema = schemaMap.get('EUR_CRM_Contract_Activity_Item__c');
        contractActivityFieldMap = contractActivitySchema.getDescribe().fields.getMap();
        //Set Contract
        contractObj = initContract(contractId);
        remainingUserBudgetTotal = calculateRemainingUserBudgetTotal();
        //componentControllerMap = getComponentControllerMap();
        userProfileName = [select Name from profile where id = :userinfo.getProfileId()].name;
        mechanicTypeMap = retrieveMechanicTypes(contractObj);
        oldMechanicTypeMap = retrieveOldMechanicTypes(contractObj);
        //Set Contract Item Source
        System.debug('Flag - Is Flagship Contract:' + isFlagship(contractObj));

        allBrandMap = retrieveItemSourceBrands(contractObj);
        allBrandQualityMap = retrieveItemSourceBrandQualities(contractObj);

        if (isFlagship(contractObj)){
                //TODO Retrieve Brand/ BQ at Contract Mechanic

                Map<Id, EUR_CRM_Contract_Mechanic__c> contractMechanics = retrieveContractMechanic(mechanicTypeMap);
                Set<Id> specificBrands = retrieveContractMechanicBrands(contractObj, contractMechanics.values());
                Set<Id> specificBrandQualities = retrieveContractMechanicBrandQualities(contractObj, contractMechanics.values());
                //All Brand and BQ
                Map<Id, EUR_CRM_Brand__c> tempFlagshipAllBrandMap = retrieveItemSourceBrands(contractObj, specificBrands);
                Map<Id, EUR_CRM_Quality__c> tempFlagshipAllBrandQualityMap = retrieveItemSourceBrandQualities(contractObj, specificBrandQualities);
                //Listing Pouring
                Map<Id, EUR_CRM_Quality__c> tempLPBQ= retrieveItemSourceBrandQualities(contractObj);
                listingPouringBQList = (tempLPBQ!=null && tempLPBQ.size()>0) ? tempLPBQ.values() : new List<EUR_CRM_Quality__c>();
                //Set Flagship select option
                flagshipBrandSelection = setFlagshipBrandSelection(tempFlagshipAllBrandMap);
                List<Id> tempKeySet = new List<Id>();
                tempKeySet.addAll(tempFlagshipAllBrandMap.keySet());
                if (contractObj.EUR_CRM_Flagship_Brand__c==null && tempKeySet.size()>0){
                    contractObj.EUR_CRM_Flagship_Brand__c = tempKeySet.get(0);
                }
                selectedFlagshipBrand = contractObj.EUR_CRM_Flagship_Brand__c;

                allFlagshipBrandMap = trimFlagshipBrands(tempFlagshipAllBrandMap, selectedFlagshipBrand);
                allFlagshipBrandQualityMap = trimFlagshipBrandQualities(tempFlagshipAllBrandQualityMap, selectedFlagshipBrand);

                //Set Brand and BQ map per Mechanic Type
                brandsPerMechanicType = retrieveContractMechanicBrandsMap(contractObj, contractMechanics.values(), tempFlagshipAllBrandMap);
                brandQualitiesPerMechanicType = retrieveContractMechanicBrandQualitiesMap(contractObj, contractMechanics.values(), tempFlagshipAllBrandQualityMap);
        }
        //Set Contract Content Items
        mechanicTypeWrapperMap = initContractContent(contractObj);
        contractFormSettingWrapperByMTextId = this.getContractFormSettingWrapperByMTextId();
        System.debug('Flag - Check Budget:' + contractObj.EUR_CRM_Budget__c+'--'+contractObj.EUR_CRM_Budget_Balance_Reference__c+'--'+deductibleContractTotal);
        if (contractObj.EUR_CRM_Budget__c==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.EUR_CRM_No_Budget_Header));
        }

     //   if(contractObj.EUR_CRM_Budget__c!=null && contractObj.EUR_CRM_Budget_Balance_Reference__c<deductibleContractTotal && contractObj.EUR_CRM_Contract_Approved_Date__c==null){
        if(contractObj.EUR_CRM_Budget__c!=null && getIsInsufficientBalance() && contractObj.EUR_CRM_Contract_Approved_Date__c==null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, Label.EUR_CRM_Insufficient_Balance));
        }
    }

    public Boolean getIsInsufficientBalance(){
        Boolean flag = false;
        Decimal currentBalance = contractObj.EUR_CRM_Budget__r.EUR_CRM_Current_Balance__c;

        List<EUR_CRM_Budget_Transaction__c> BudgetTransactions = [SELECT id, EUR_CRM_Amount__c, EUR_CRM_Budget_Header__c, EUR_CRM_Contract__c,EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c FROM EUR_CRM_Budget_Transaction__c Where EUR_CRM_Contract__c =: contractId];
        Decimal requiredAmount = 0;
        Date fYear = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();



        String FYString = 'FY' + String.ValueOf(fYear.year()).substring(2);

        System.Debug('fYear:' + FYString);

        For(EUR_CRM_Budget_Transaction__c tran : BudgetTransactions){
            If(tran.EUR_CRM_Budget_Header__r.EUR_CRM_Fiscal_Year__c == FYString){
                requiredAmount += tran.EUR_CRM_Amount__c;
            }
        }


        System.Debug('@@ Required Budget:' + requiredAmount);
        if(currentBalance < requiredAmount){
            flag = true;
        }

        return flag;
    }



    public EUR_CRM_Contract__c initContract(Id contractId){
            if ( contractId != null){
        List<EUR_CRM_Contract__c> contractList = [SELECT Id, Name,
                                                CreatedById,
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
                                                EUR_CRM_Total_Contract_Line_Items__c,
                                                EUR_CRM_Contract_Sub_Type__c,
                                                EUR_CRM_DE_Actual_Contract_Total__c,
                                                EUR_CRM_DE_Deductible_Contract_Total__c,
                                                EUR_CRM_Flagship_Brand__c,
                                                EUR_CRM_Total_Pro_Rated_Amount__c,
                                                EUR_CRM_Budget_Balance_Reference__c,
                                                EUR_CRM_Budget__c,
                                                EUR_CRM_Agrees_with_TC__c,
                                                EUR_CRM_Contract_Uploaded__c,
                                                EUR_CRM_Budget__r.EUR_CRM_Fiscal_Year__c,
                                                EUR_CRM_Budget__r.EUR_CRM_Current_Balance__c,
                                                EUR_CRM_Customer_Approved_Date__c,
                                                EUR_CRM_Contract_Signed__c,
												EUR_CRM_Total_Contributive_Margin__c
                                                FROM EUR_CRM_Contract__c
                                                WHERE Id =: contractId];
        if (contractList.size()>0){
            EUR_CRM_Contract__c contract = contractList.get(0);
                            return contract;
        }
    }
    return null;
    }

    public Map<String, MechanicTypeWrapper> initContractContent(EUR_CRM_Contract__c contractObj){
        Map<String, MechanicTypeWrapper> mechanicWrapMap = new Map <String, MechanicTypeWrapper>();

        //Retrieve Contract Activities
        Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivities = retrieveContractActivityItems(contractObj);
        //Retrieve Contract Products
        Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> contractProducts = retrieveContractProductItems(contractObj);

        System.debug('Flag - Contract Content - Contract Products:' + contractProducts);
        if (contractObj != null){
            //Iterate Mechanic Type
            //TODO HANDLE FLAGSHIP - SELECTION
            List<EUR_CRM_Mechanic_Type__c> allMechanicTypes = new List<EUR_CRM_Mechanic_Type__c>(mechanicTypeMap.values());
            allMechanicTypes.addAll(oldMechanicTypeMap.values());
            for (EUR_CRM_Mechanic_Type__c mechanicType: allMechanicTypes){
                //String mTypeName = mechanicType.Name;
                String mTypeName = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c;
                Integer contractActivityCount = 0;
                if (mechanicTypeSet.contains(mTypeName)){
                    //Create Mechanic Type Wrapper
                    MechanicTypeWrapper mTypeWrapper = new MechanicTypeWrapper(mechanicType);
                    //Contract Activity Item
                    if (contractActivities.containsKey(mechanicType.Id)){
                        //iterate CA
                        //mTypeWrapper.contractActivityItems = contractActivities.get(mechanicType.Id);
                        System.debug('Flag - Init Contract Content - Contract Activities:' +contractActivities.get(mechanicType.Id));

                        System.debug('Flag - Init Contract Content - BQ Flagship Map:' + brandQualitiesPerMechanicType);
                        for (String key: contractActivities.get(mechanicType.Id).keySet()){
                                String contractActivityKey = String.valueOf(contractActivityCount);
                            System.debug('Flag - Init Contract Content - Iterate Contract Activities:' +key + '-' + contractActivityKey);
                            EUR_CRM_Contract_Activity_Item__c caItem = contractActivities.get(mechanicType.Id).get(key);
							System.debug('\n caItem => ' + JSON.serializePretty(caItem) + '\n');

                            //Check Contract Activity State:
                            //1. POS Material  - Budget Exclusion always true
                            if(ALWAYS_EXCLUDED_BUDGET.contains(mTypeName) || caItem.EUR_CRM_PR_DE_Flag__c){
                                caItem.EUR_CRM_Exclude_Budget_Deduction__c = true;
                            }

                            ContractActivityItemWrapper caItemWrapper= new ContractActivityItemWrapper(caItem);

                            if (contractProducts.containsKey(key)){
                                caItemWrapper.contractProductItems = contractProducts.get(key);
                                System.debug('\n caItemWrapper => ' + JSON.serializePretty(caItemWrapper) + '\n');
                            }

                            //TODO Remove Brands/ BQ existing on Contract Product Items
                            System.debug('Flag - Init Contract Content - Check Flagship Contract Source:' + BQ_MECHANIC_TYPE_SET.contains(mTypeName)+'-'+isFlagship(contractObj)+'-'+brandQualitiesPerMechanicType.containsKey(mechanicType.Id));
                            Map<Id, EUR_CRM_Quality__c> trimmedBQMap = new Map<Id,EUR_CRM_Quality__c>();
                            Map<Id, EUR_CRM_Brand__c> trimmedBrandMap = new Map<Id,EUR_CRM_Brand__c>();

                            if(((!isFlagship(contractObj)) || (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                                trimmedBQMap = (Map<Id, EUR_CRM_Quality__c>) trimContractSourceMap(allBrandQualityMap, caItemWrapper.retrieveExistingBrandQualities());
                                caItemWrapper.brandQualityItems.putAll(trimmedBQMap);
                            }else if (((!isFlagship(contractObj)) ||  (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                                trimmedBrandMap = (Map<Id, EUR_CRM_Brand__c>)trimContractSourceMap(allBrandMap, caItemWrapper.retrieveExistingBrands());
                                caItemWrapper.brandItems.putAll(trimmedBrandMap);
                            }else if ((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                                trimmedBQMap = (Map<Id, EUR_CRM_Quality__c>)trimContractSourceMap(allFlagshipBrandQualityMap, caItemWrapper.retrieveExistingBrandQualities());
                                caItemWrapper.brandQualityItems.putAll(trimmedBQMap);
                            }else if((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                                trimmedBrandMap = (Map<Id, EUR_CRM_Brand__c>)trimContractSourceMap(allFlagshipBrandMap, caItemWrapper.retrieveExistingBrands());
                                caItemWrapper.brandItems.putAll(trimmedBrandMap);
                            }
                            if(mechanicWrapMap.containsKey(mTypeName)) {
                                contractActivityKey = String.valueOf(mechanicWrapMap.get(mTypeName).nextContractActivityIndex + contractActivityCount);
                            }
                            caItemWrapper.mapKey = contractActivityKey;
                            mTypeWrapper.contractActivityItems.put(contractActivityKey, caItemWrapper);
                            contractActivityCount++;
                        }
                    }

                    System.debug(mTypeWrapper);

                    //Contract Product Item
                    if(mTypeWrapper.contractActivityItems.size()<=0 && mechanicType.EUR_CRM_Has_Multiple_Activity_Item__c==false){
                        ContractActivityItemWrapper caItemWrapper= new ContractActivityItemWrapper(createContractActivity(contractObj,mechanicType));
                        if(((!isFlagship(contractObj)) || (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                                caItemWrapper.brandQualityItems.putAll(allBrandQualityMap);
                        }else if (((!isFlagship(contractObj)) ||  (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                            caItemWrapper.brandItems.putAll(allBrandMap);
                        }else if ((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                                caItemWrapper.brandQualityItems.putAll(allFlagshipBrandQualityMap);
                        }else if((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                                caItemWrapper.brandItems.putAll(allFlagshipBrandMap);
                        }
                        //mTypeWrapper.contractActivityItems.put(mechanicType.Id+'-', caItemWrapper);
                        String contractActivityKey = String.valueOf(contractActivityCount);
                        if(mechanicWrapMap.containsKey(mTypeName)) {
                            contractActivityKey = String.valueOf(mechanicWrapMap.get(mTypeName).nextContractActivityIndex + contractActivityCount);
                        }
                        caItemWrapper.mapKey = contractActivityKey;
                        mTypeWrapper.contractActivityItems.put(contractActivityKey, caItemWrapper);

                        //Feb.01.2015 - added for initial load of contract activity item.
                        if(ALWAYS_EXCLUDED_BUDGET.contains(mTypeName)){
                            caItemWrapper.contractActivityItem.EUR_CRM_Exclude_Budget_Deduction__c = true;
                        }
                    }

                    if(mechanicWrapMap.containsKey(mTypeName)) {
                        mechanicWrapMap.get(mTypeName).contractActivityItems.putAll(mTypeWrapper.contractActivityItems);
                    } else {
                        mechanicWrapMap.put(mTypeName, mTypeWrapper);
                    }
                }
            }
        }
        System.debug('\n mechanicWrapMap => ' + JSON.serializePretty(mechanicWrapMap) + '\n');
        return mechanicWrapMap;
    }

    public PageReference addContractProductItem() {
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');
        String param_contractSourceItemId = params.get('PARAM_CONTRACT_SOURCE_ITEM_ID');
        //String param_description = params.get('PARAM_DESCRIPTION');

        System.debug('Flag - Add Contract Product Item:' + param_mechanicTypeName + '-'+param_contractActivityKey+'-'+param_contractSourceItemId);
        System.debug('Flag - Mechanic Type Wrapper Map: '+mechanicTypeWrapperMap);
        //Get Mechanic Type Wrapper
        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
                MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
                //Get Contract Activity
                if (param_contractActivityKey.equalsIgnoreCase(CURRENT_CONTRACT_ACTIVITY_FLAG) || mechanicTypeWrap.contractActivityItems.containsKey(param_contractActivityKey)){
                        String contractProductItemKey;
                        EUR_CRM_Contract_Product_Item__c contractProductItem;
                        ContractActivityItemWrapper contractActivityWrap = (param_contractActivityKey.equalsIgnoreCase(CURRENT_CONTRACT_ACTIVITY_FLAG))?mechanicTypeWrap.currentContractActivityItem:mechanicTypeWrap.contractActivityItems.get(param_contractActivityKey);
                        //Get Source Item
                        if (param_contractSourceItemId!=null && (!param_contractSourceItemId.contains(DESCRIPTION_PREFIX)) && allBrandMap.containsKey(param_contractSourceItemId)){
                            contractProductItemKey = String.valueOf(allBrandMap.get(param_contractSourceItemId).Id);
                            contractProductItem = createContractProductItem(contractActivityWrap.contractActivityItem, allBrandMap.get(param_contractSourceItemId));
                            System.debug('Flag - Add Contract Product Item - Create CPI:'+param_contractSourceItemId +'-'+contractProductItem);
                            contractActivityWrap.contractProductItems.put(contractProductItemKey, contractProductItem);
                            System.debug('Flag - Add Contract Product Item - Add Created CPI:'+param_contractSourceItemId +'-'+contractActivityWrap.contractProductItems);
                            //Remove Brand
                            contractActivityWrap.brandItems.remove(param_contractSourceItemId);
                        }
                        else if (param_contractSourceItemId!=null && (!param_contractSourceItemId.contains(DESCRIPTION_PREFIX)) && allBrandQualityMap.containsKey(param_contractSourceItemId)){
                            contractProductItemKey = String.valueOf(allBrandQualityMap.get(param_contractSourceItemId).Id);
                            contractProductItem = createContractProductItem(contractActivityWrap.contractActivityItem, allBrandQualityMap.get(param_contractSourceItemId));
                            System.debug('Flag - Add Contract Product Item - Create CPI:'+param_contractSourceItemId +'-'+contractProductItem);
                            contractActivityWrap.contractProductItems.put(contractProductItemKey, contractProductItem);
                            System.debug('Flag - Add Contract Product Item - Add Created CPI:'+param_contractSourceItemId +'-'+contractActivityWrap.contractProductItems);

                            //Remove BQ
                            contractActivityWrap.brandQualityItems.remove(param_contractSourceItemId);
                            System.debug('FLAG - Add Contract Product Item:'+allBrandQualityMap.containsKey(param_contractSourceItemId));
                        }
                        else if(param_contractSourceItemId!=null && param_contractSourceItemId.contains(DESCRIPTION_PREFIX)){
                            //TODO Handle Descripton Items
                            contractProductItemKey = contractActivityWrap.assignDescriptionId();
                            contractProductItem = createContractProductItem(contractActivityWrap.contractActivityItem);
                            System.debug('Flag - Add Contract Product Item - Create CPI:'+param_contractSourceItemId +'-'+contractProductItemKey+'-'+contractProductItem);
                            contractActivityWrap.contractProductItems.put(contractProductItemKey, contractProductItem);
                            System.debug('Flag - Add Contract Product Item - Add Created CPI:'+contractProductItemKey +'-'+contractActivityWrap.contractProductItems);
                        }else{
                            System.debug('FLAG - addContractProductItem - Contract Source Not Found: ' +param_mechanicTypeName+'-'+param_contractActivityKey+'-'+param_contractSourceItemId);
                        }

                         System.debug('FLAG - Contract Activity Product Item Map:' + contractActivityWrap.contractProductItems);
                }
        }else{
                //TODO
                //Add page error
        }

        return pageRef;
    }

    public PageReference removeContractProductItem(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');
        String param_contractProductItemId = params.get('PARAM_CONTRACT_PRODUCT_ITEM_ID');

        System.debug('flag - Remove Contract Product Item - Check Param:' + param_mechanicTypeName + '-'+param_contractActivityKey+'-'+param_contractProductItemId);

        //Get Mechanic Type Wrapper
        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
            //Get Contract Activity
            if (param_contractActivityKey.equalsIgnoreCase(CURRENT_CONTRACT_ACTIVITY_FLAG) || mechanicTypeWrap.contractActivityItems.containsKey(param_contractActivityKey)){
                String contractProductItemKey;
                //EUR_CRM_Contract_Product_Item__c contractProductItem;
                ContractActivityItemWrapper contractActivityWrap = (param_contractActivityKey.equalsIgnoreCase(CURRENT_CONTRACT_ACTIVITY_FLAG))?mechanicTypeWrap.currentContractActivityItem:mechanicTypeWrap.contractActivityItems.get(param_contractActivityKey);
                System.debug('FLAG - Remove Product Item - CA Wrap: ' + contractActivityWrap);
                if (contractActivityWrap.contractProductItems.containsKey(param_contractProductItemId)){
                    //contractProductItem = contractActivityWrap.contractProductItems.get(param_contractProductItemId);
                    System.debug('FLAG - Remove Product Item 2: ' + param_mechanicTypeName + '-'+param_contractActivityKey+'-'+param_contractProductItemId);
                    //System.debug('FLAG - Remove Product Item 3: ' + param_contractProductItemId+'-'+allBrandQualityMap.containsKey(param_contractProductItemId));

                    //EUR_CRM_Contract_Product_Item__c prodItemObj = contractActivityWrap.contractProductItems.get(param_contractProductItemId);
                    //Store Contract Product Item Id for Deletion
                    if (contractActivityWrap.contractProductItems.containsKey(param_contractProductItemId))
                    {
                            EUR_CRM_Contract_Product_Item__c contractProductItem = contractActivityWrap.contractProductItems.get(param_contractProductItemId);
                            if (contractProductItem.Id != null){
                                    contractActivityWrap.deletedContractProductItems.add(contractProductItem.Id);
                                    System.debug('Flag - Remove Product Item - Deleted Product Item List:' + contractActivityWrap.deletedContractProductItems);
                            }
                     //Remove
                    System.debug('Flag - Remove Contract Product Item 1:' + param_contractProductItemId!=null+'-'+(!param_contractProductItemId.contains(DESCRIPTION_PREFIX))+'-'+allBrandMap.containsKey(param_contractProductItemId));
                    System.debug('Flag - Remove Contract Product Item 2:' + param_contractProductItemId!=null+'-'+(!param_contractProductItemId.contains(DESCRIPTION_PREFIX))+'-'+allBrandQualityMap.containsKey(param_contractProductItemId));
                    System.debug('Flag - Remove Contract Product Item 3:' + param_contractProductItemId!=null+'-'+param_contractProductItemId.contains(DESCRIPTION_PREFIX)+'-'+contractActivityWrap.contractProductItems.containsKey(param_contractProductItemId));
                    if (param_contractProductItemId!=null && (!param_contractProductItemId.contains(DESCRIPTION_PREFIX)) && allBrandMap.containsKey(param_contractProductItemId)){
                        EUR_CRM_Brand__c brandItem = allBrandMap.get(param_contractProductItemId);
                        contractActivityWrap.brandItems.put(brandItem.Id, brandItem);
                        contractActivityWrap.contractProductItems.remove(param_contractProductItemId);
                        System.debug('FLAG - Remove Brand: '+ param_contractProductItemId +'-'+brandItem);
                    }
                    else if (param_contractProductItemId!=null && (!param_contractProductItemId.contains(DESCRIPTION_PREFIX)) && allBrandQualityMap.containsKey(param_contractProductItemId)){
                        EUR_CRM_Quality__c brandQualityItem = allBrandQualityMap.get(param_contractProductItemId);
                        contractActivityWrap.brandQualityItems.put(brandQualityItem.Id, brandQualityItem);
                        contractActivityWrap.contractProductItems.remove(param_contractProductItemId);
                        System.debug('FLAG - Remove BQ: '+ param_contractProductItemId +'-'+brandQualityItem);
                    }
                    else if(param_contractProductItemId!=null && param_contractProductItemId.contains(DESCRIPTION_PREFIX) && contractActivityWrap.contractProductItems.containsKey(param_contractProductItemId)){
                        contractActivityWrap.contractProductItems.remove(param_contractProductItemId);
                    } else{
                        System.debug('FLAG - removeContractProductItem - Contract Source Not Found: ' +param_mechanicTypeName+'-'+param_contractActivityKey+'-'+param_contractProductItemId);
                    }
                    }
                }
            }

            //if(param_contractActivityKey!=null){
            //  mechanicTypeWrap.contractActivityItems.put(param_contractActivityKey, contractActivityWrap);
            //}
        }
        return pageRef;
    }

    public PageReference retrieveCurrentContractActivity(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');

        System.debug('Flag - Retrieve Current Contract Activity - Check Param:'+param_mechanicTypeName+'--'+param_contractActivityKey);
        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
            //Get Contract Activity
            if (param_contractActivityKey!=null && mechanicTypeWrap.contractActivityItems.containsKey(param_contractActivityKey)){
                //Assign current Contract Activity
                ContractActivityItemWrapper contractActivityWrap = mechanicTypeWrap.contractActivityItems.get(param_contractActivityKey);
                mechanicTypeWrap.currentContractActivityItem = contractActivityWrap;
                //ContractActivityItemWrapper caWrap = createContractActivityCopy(contractActivityWrap);

                //mechanicTypeWrap.currentContractActivityItem = caWrap;
                mechanicTypeWrap.currentContractActivityItem.isNew = false;

                // Set Payment Term
                //mechanicTypeWrap.mechanicType.EUR_CRM_Payment_Term_By_MT__c = contractActivityWrap.contractActivityItem.EUR_CRM_Payment_Term_By_SR__c;
            }else{
                System.debug(mechanicTypeWrap);
                System.debug(mechanicTypeWrapperMap);

                Id DECAIRecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Contract_Activity_Item__c' + DE_CONTRACT_ACTIVITY_ITEM);
                EUR_CRM_Contract_Activity_Item__c newCAItem = new EUR_CRM_Contract_Activity_Item__c(EUR_CRM_Contract__c=contractObj.Id,
                                                            EUR_CRM_Mechanic_Type__c=mechanicTypeWrap.mechanicTypeId,
                                                            EUR_CRM_Name__c=null, EUR_CRM_Amount__c=null, EUR_CRM_Vendor__c=null,
                                                            EUR_CRM_Payment_Term_By_SR__c=null, recordtypeid = DECAIRecordTypeId,
                                                            EUR_CRM_Start_Date__c=null, EUR_CRM_End_Date__c=null, EUR_CRM_Exclude_Budget_Deduction__c=false);

                if(ALWAYS_EXCLUDED_BUDGET.contains(param_mechanicTypeName)){
                    newCAItem.EUR_CRM_Exclude_Budget_Deduction__c = true;
                }

                System.debug(newCAItem);
                System.debug(newCAItem.EUR_CRM_Mechanic_Type__r);
                System.debug(newCAItem.EUR_CRM_Mechanic_Type__c);

                mechanicTypeWrap.currentContractActivityItem = new ContractActivityItemWrapper(newCAItem);
                mechanicTypeWrap.currentContractActivityItem.isNew = true;

                // Set Payment Term
                // mechanicTypeWrap.mechanicType.EUR_CRM_Payment_Term_By_MT__c = null;

                // TODO: Differentiate for flagship & non flagship BQ?
                if(BQ_MECHANIC_TYPE_SET.contains(param_mechanicTypeName)){
                    mechanicTypeWrap.currentContractActivityItem.brandQualityItems.putAll(allBrandQualityMap);
                } else if (isFlagship(contractObj) && (!mechanicTypeWrap.mechanicType.EUR_CRM_Ignore_CM_Flagship__c)){
                    mechanicTypeWrap.currentContractActivityItem.brandItems = new Map<Id, EUR_CRM_Brand__c>();
                    mechanicTypeWrap.currentContractActivityItem.brandItems.putAll(allFlagshipBrandMap);
                }else{
                    mechanicTypeWrap.currentContractActivityItem.brandItems.putAll(allBrandMap);
                }
            }
            System.debug('Flag - Retrieve Current Contract Activity:' + JSON.serializePretty(mechanicTypeWrap.currentContractActivityItem));
        }
        return pageRef;
    }

    public PageReference removeContractActivity(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');

        System.debug('Flag - Remove Contract Activity - Check Params:' + param_mechanicTypeName + '-' + param_contractActivityKey);
        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
            System.debug('Flag - Remove Contract Activity: - Check Mechanic Type Wrapper:' + mechanicTypeWrap);
            //Get Contract Activity
            if (mechanicTypeWrap.contractActivityItems.containsKey(param_contractActivityKey)){
                    ContractActivityItemWrapper caWrap = mechanicTypeWrap.contractActivityItems.get(param_contractActivityKey);
                    EUR_CRM_Contract_Activity_Item__c caItem = caWrap.contractActivityItem;

                    System.debug('Flag - Remove Contract Activity - Check CA:' + caItem);
                    if (caItem.Id != null){
                            mechanicTypeWrap.deletedContractActivityItems.add(caItem.Id);
                    }
                //Remove Contract Activity
                mechanicTypeWrap.contractActivityItems.remove(param_contractActivityKey);
            }
            System.debug('Flag - Remove Contract Activity - Verify Mechanic Type Wrapper:' + mechanicTypeWrap);
        }
        return pageRef;
    }


    public PageReference removeCurrentContractActivity(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        //String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');

        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
            System.debug('Flag - Remove Current Contract Activity:' + mechanicTypeWrap);
            mechanicTypeWrap.resetCurrentContractActivity();
        }

        return pageRef;
    }

    public PageReference clearContractActivity(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        //String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');
        System.debug('flag - Clear Contract Activity - Check Mechanic Type Wrapper:' + mechanicTypeWrapperMap.containsKey(param_mechanicTypeName));
        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
            EUR_CRM_Mechanic_Type__c mechanicType = mechanicTypeWrap.mechanicType;
            //String mTypeName = mechanicType.Name;
            String mTypeName = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c;

                            //Create Set of deleted CA
                            Set<Id> deletedContractActivityItems = new Set<Id>();
                            for (ContractActivityItemWrapper caWrap: mechanicTypeWrap.contractActivityItems.values()){
                                    if (caWrap.contractActivityItem.Id != null){
                                            deletedContractActivityItems.add(caWrap.contractActivityItem.Id);
                                    }
                            }
                            //New Contract Activity Wrapper
            ContractActivityItemWrapper caItemWrapper= new ContractActivityItemWrapper(createContractActivity(contractObj,mechanicType));
            /*if(BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                    caItemWrapper.brandQualityItems.putAll(allBrandQualityMap);
            }else{
                caItemWrapper.brandItems.putAll(allBrandMap);
            }*/

            if(((!isFlagship(contractObj)) || (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c))&& BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                caItemWrapper.brandQualityItems.putAll(allBrandQualityMap);
            }else if (((!isFlagship(contractObj)) || (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                caItemWrapper.brandItems.putAll(allBrandMap);
            }else if ((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                caItemWrapper.brandQualityItems.putAll(allFlagshipBrandQualityMap);
            }else if((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                caItemWrapper.brandItems.putAll(allFlagshipBrandMap);
            }

            caItemWrapper.mapKey = '0';
            mechanicTypeWrap.contractActivityItems.put('0', caItemWrapper);
            mechanicTypeWrap.deletedContractActivityItems.addAll(deletedContractActivityItems);
            System.debug('Flag - Clear Contract Activity:' + mechanicTypeWrap.contractActivityItems.get(mechanicType.Id+'-'));
        }

        return pageRef;
    }

    public PageReference resetFlagshipBrandSelection(){
        PageReference pageRef = null;
        //TODO RESET ALL CONTRACT ACTIVITY SOURCE
        //TODO HANDLE FLAGSHIP - SELECTION
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_selectedFlagshipBrand = params.get('PARAM_SELECTED_FLAGSHIP_BRAND');

        selectedFlagshipBrand = (param_selectedFlagshipBrand!=null)?param_selectedFlagshipBrand:selectedFlagshipBrand;
        System.debug('Flag - Reset Flagship Brand Selection:' + param_selectedFlagshipBrand + '-'+ selectedFlagshipBrand);

        if (selectedFlagshipBrand!=null){
                //selectedFlagshipBrand = Id.valueOf(param_selectedFlagshipBrand);

                if (isFlagship(contractObj)){
                    allFlagshipBrandMap = trimFlagshipBrands(allBrandMap, selectedFlagshipBrand);
                    allFlagshipBrandQualityMap = trimFlagshipBrandQualities(allBrandQualityMap, selectedFlagshipBrand);
                }
                System.debug('Flag - Resey Flagship Brands:'+selectedFlagshipBrand+'-'+allFlagshipBrandMap);
                System.debug('Flag - Resey Flagship BQs:'+selectedFlagshipBrand+'-'+allFlagshipBrandQualityMap);

                for(String key: mechanicTypeWrapperMap.keySet()){
                    MechanicTypeWrapper mTypeWrapper = mechanicTypeWrapperMap.get(key);
                    EUR_CRM_Mechanic_Type__c mechanicType = mTypeWrapper.mechanicType;
                    //String mTypeName = mechanicType.Name;
                    String mTypeName = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c;
                    for (ContractActivityItemWrapper caItemWrapper: mTypeWrapper.contractActivityItems.values()){
                        System.debug('Flag - Reset Flagship - Check Flagship Contract Source:' + BQ_MECHANIC_TYPE_SET.contains(mTypeName)+'-'+isFlagship(contractObj));
                        //TODO FIX
                        caItemWrapper.brandQualityItems = new Map<Id, EUR_CRM_Quality__c>();
                        caItemWrapper.brandItems = new Map<Id, EUR_CRM_Brand__c>();
                        if(((!isFlagship(contractObj)) || (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                            caItemWrapper.brandQualityItems.putAll(allBrandQualityMap);
                        }else if (((!isFlagship(contractObj)) || (isFlagship(contractObj) && mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                            caItemWrapper.brandItems.putAll(allBrandMap);
                        }else if ((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && BQ_MECHANIC_TYPE_SET.contains(mTypeName)){
                            caItemWrapper.brandQualityItems.putAll(allFlagshipBrandQualityMap);
                        }else if((isFlagship(contractObj) && (!mechanicType.EUR_CRM_Ignore_CM_Flagship__c)) && (!BQ_MECHANIC_TYPE_SET.contains(mTypeName))){
                            caItemWrapper.brandItems.putAll(allFlagshipBrandMap);
                        }
                        System.debug('Flag - Reset Flagship - Check Product Items:' + caItemWrapper.contractProductItems);
                        if (caItemWrapper.contractProductItems!=null && caItemWrapper.contractProductItems.size()>0){
                                for (EUR_CRM_Contract_Product_Item__c prodItem : caItemWrapper.contractProductItems.values()){
                                        if (prodItem.Id != null){
                                                caItemWrapper.deletedContractProductItems.add(prodItem.Id);
                                        }
                                }
                        }
                        //Contract Product Item
                                caItemWrapper.contractProductItems = new Map<String, EUR_CRM_Contract_Product_Item__c>();
                    }
                }
        }
        System.debug('Flag - Reset Flagship Brand:' + mechanicTypeWrapperMap);
        return pageRef;
    }

    public void postProcessPRDActivity(){
        //Assign Vendor to PR Deutschland
        //Exclude Budget Deduction = true
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_PRDEFlag = params.get('PARAM_PR_DE_FLAG');

		Map<String, String> CAI_CHECKBOX_FIELD_BY_MECH_TYPE = new Map<String, String>{
			'Events' => 'EUR_CRM_Is_PR_Event__c'
		,	'Others' => 'EUR_CRM_Is_PR_Other__c'
		,	'Training' => 'EUR_CRM_Is_PR_Training__c'
		};

        System.debug('Flag - PRD Activity Post-Process - Check Param:'+param_mechanicTypeName +'--' +param_PRDEFlag);
        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
			EUR_CRM_Contract_Activity_Item__c cai = mechanicTypeWrap.currentContractActivityItem.contractActivityItem;
			String checkboxField = CAI_CHECKBOX_FIELD_BY_MECH_TYPE.get(param_mechanicTypeName);
			System.debug('\n checkboxField => ' + checkboxField + '\n');
			if (checkboxField != null) {
				cai.put(checkboxField, Boolean.valueOf(param_PRDEFlag));
			}
            System.debug('Flag - PRD Activity Post-Process - Check PRD Flag:'+mechanicTypeWrap.currentContractActivityItem.contractActivityItem.EUR_CRM_PR_DE_Flag__c);
            if (param_PRDEFlag=='true'){
                cai.EUR_CRM_PR_DE_Flag__c = true;
                cai.EUR_CRM_Vendor__c = PR_DEUTSCHLAND;
                cai.EUR_CRM_Exclude_Budget_Deduction__c = true;
//                cai.EUR_CRM_Payment_Term_By_SR__c = NO_INVOICING_PAYMENT_TERM;
                // mechanicTypeWrap.mechanicType.EUR_CRM_Payment_Term_By_MT__c = NO_INVOICING_PAYMENT_TERM;
            }else{
                cai.EUR_CRM_PR_DE_Flag__c = false;
                cai.EUR_CRM_Vendor__c = null;
                cai.EUR_CRM_Exclude_Budget_Deduction__c = false;
//                cai.EUR_CRM_Payment_Term_By_SR__c = null;
                // mechanicTypeWrap.mechanicType.EUR_CRM_Payment_Term_By_MT__c = null;
            }
            System.debug('Flag - PRD Activity Post-Process - Check Param:'+cai.EUR_CRM_PR_DE_Flag__c + '--'+cai.EUR_CRM_Vendor__c+'--'+cai.EUR_CRM_Exclude_Budget_Deduction__c);
        }
        //return pageRef;
    }

    public PageReference saveCurrentContractActivity(){
        PageReference pageRef = null;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');

        if (mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);
            EUR_CRM_Contract_Activity_Item__c caItem = mechanicTypeWrap.currentContractActivityItem.contractActivityItem;

            // TODO: Might be buggy
            //if(caItem.EUR_CRM_Payment_Term_By_SR__c == null) {
            if(caItem.EUR_CRM_PR_DE_Flag__c == false) {
                // for PRD items, Payment Term already set when the user clicked the button
                //caItem.EUR_CRM_Payment_Term_By_SR__c = mechanicTypeWrap.mechanicType.EUR_CRM_Payment_Term_By_MT__c;
            }
            //}

            if(caItem.EUR_CRM_Name__c==null) {
                caItem.EUR_CRM_Name__c = mechanicTypeWrap.mechanicType.Name + DateTime.now();
            }

            //String key = mechanicTypeWrap.mechanicType.Id +'-'+caItem.EUR_CRM_Name__c;
            String key = (mechanicTypeWrap.currentContractActivityItem.mapKey!=null)?mechanicTypeWrap.currentContractActivityItem.mapKey:String.valueOf(mechanicTypeWrap.lastContractActivityCount + 1);
            System.debug('Flag - Save Current Contract Activity - Check Route Item Map Key:' + key + '-' + mechanicTypeWrap.currentContractActivityItem.mapKey);
            System.debug('Flag - Save Current Contract Activity - Check CA Wrapper:' + JSON.serializePretty(mechanicTypeWrap.currentContractActivityItem));
            if (validateContractActivity(contractObj, mechanicTypeWrap.mechanicType, mechanicTypeWrap.currentContractActivityItem)
                && validateContractActivityOverlap(contractObj, mechanicTypeWrap.mechanicType, mechanicTypeWrap.currentContractActivityItem)){

                System.debug('Flag - Save Current Contract Activity: Validated - ' +mechanicTypeWrap.contractActivityNameSet+' - '+mechanicTypeWrap.contractActivityNameSet.contains(caItem.EUR_CRM_Name__c.toUpperCase()));
                if(mechanicTypeWrap.contractActivityNameSet.contains(caItem.EUR_CRM_Name__c.toUpperCase()) &&
                                (mechanicTypeWrap.currentContractActivityItem.isNew)){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.EUR_CRM_Require_Unique_Name));
                }else{
                    // See if the Contract Activity Item is a PRD type, if it is assign special record type
//                    if(caItem.EUR_CRM_PR_DE_Flag__c == true) {
//                        caItem.EUR_CRM_Payment_Term_By_SR__c = NO_INVOICING_PAYMENT_TERM;
//                    }
                    caItem.EUR_CRM_Payment_Term_By_SR__c = caItem.EUR_CRM_Payment_Term__c;
                    mechanicTypeWrap.currentContractActivityItem.mapKey = key;
                    mechanicTypeWrap.contractActivityItems.put(key, mechanicTypeWrap.currentContractActivityItem);

                    System.debug(mechanicTypeWrap);
                    System.debug(mechanicTypeWrap.mechanicType);
                    System.debug(mechanicTypeWrap.currentContractActivityItem);
                    //Reset Current Contract Activity
                    mechanicTypeWrap.resetCurrentContractActivity();
                    System.debug('Flag - Save Current Contract Activity - Successful:'+ mechanicTypeWrap.contractActivityItems);
                }
            }
            else{
                System.debug('flag - Save Current Contract Activity: Failed - Invalid Contract Activity');
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid Contract Activity'));
            }
        }

        return pageRef;
    }


    public PageReference saveContract(){
        PageReference pageRef = null;

        Map<String, String> params = ApexPages.currentPage().getParameters();
        //String isQuickSaveStr = params.get('IS_QUICK_SAVE');
        System.debug('Flag - Save Contract - isQuickSave:' + IS_QUICK_SAVE);
        Boolean isQuickSave = (IS_QUICK_SAVE==null)?false:Boolean.valueOf(IS_QUICK_SAVE);

        System.debug('Flag - Save Contract - Mode:' + isQuickSave);

        Database.deleteResult[] deleteResultFocusBrands;
        Database.upsertResult[] upsertResultFocusBrands;
        Database.deleteResult[] deleteResultContractProducts;
        Database.deleteResult[] deleteResultContractActivities;
        Database.upsertResult[] upsertResultContractProducts;
        Database.upsertResult[] upsertResultContractActivities;
        System.Savepoint pSavepoint = Database.setSavepoint();

        //List<EUR_CRM_Contract_Line_Item__c> updateContractLineItemList = new List<EUR_CRM_Contract_Line_Item__c>();
        //List<Id> oldContractLineItemList = new List<Id>();
        List<EUR_CRM_Contract_Product_Item__c> updatedContractProducts = new List<EUR_CRM_Contract_Product_Item__c>();
        List<EUR_CRM_Contract_Activity_Item__c> updatedContractActivities = new List<EUR_CRM_Contract_Activity_Item__c>();
        List<Id> deletedContractProducts = new List<Id>();
        List<Id> deletedContractActivities = new List<Id>();
        List<Id> updatedContractAcitvityIds = new List<Id>();

        //Mechanic Type (Id), Contract Activity (contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c), Products
        Map<Id, Map<String, List<EUR_CRM_Contract_Product_Item__c>>> contractProductsRef = new Map<Id, Map<String, List<EUR_CRM_Contract_Product_Item__c>>>();

        //Loop: Mechanic Type Wrappers
        //Get Contract Line Items
        try{
            Boolean isValid = true;
            Double proRatedTotal = 0;
            //Save Focus Brand
            if (focusBrandComponentController!=null){
                System.debug('FLAG - SAVE CONTRACT - CHECK FOCUS BRAND:'+focusBrandComponentController.createdFocusBrands +'---'+focusBrandComponentController.deletedFocusBrands);
                //Delete removed Focus Brands
                if (focusBrandComponentController.deletedFocusBrands!=null && focusBrandComponentController.deletedFocusBrands.size()>0)
                {
                    deleteResultFocusBrands = Database.delete(new List<Id>(focusBrandComponentController.deletedFocusBrands));
                }
                //Save created Focus Brands
                if (focusBrandComponentController.createdFocusBrands!=null && focusBrandComponentController.createdFocusBrands.size()>0)
                {
                    upsertResultFocusBrands = Database.upsert(focusBrandComponentController.createdFocusBrands.values());
                }
            }
            //Save Listing Pouring
//            if (listingPouringComponentController!=null && !Test.isRunningTest()){
//                System.debug('Flag - Save Contract - Save Listing Pouring');
//                listingPouringComponentController.save();
//            }

            //Save Listing
            if (listingComponentController!=null && !Test.isRunningTest()){
                System.debug('Flag - Save Contract - Save Listing');
                listingComponentController.save();
            }

            //Save Pouring
            if (pouringComponentController!=null && !Test.isRunningTest()){
                System.debug('Flag - Save Contract - Save Pouring');
                pouringComponentController.save();
            }

            System.debug(mechanicTypeWrapperMap);

                //Save Contract Activity
            for(String key: mechanicTypeWrapperMap.keySet()){
                Map<String, List<EUR_CRM_Contract_Product_Item__c>> caProducts = new Map<String, List<EUR_CRM_Contract_Product_Item__c>>();

                MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(key);
                Map<String, ContractActivityItemWrapper> contractActivityItemsWrap = mechanicTypeWrap.contractActivityItems;

                System.debug(contractActivityItemsWrap);

                if (contractActivityItemsWrap!= null){
                    if (mechanicTypeWrap.mechanicType.EUR_CRM_Is_Pro_Rated_by_Month__c){
                        proRatedTotal += mechanicTypeWrap.total;
                        system.debug('@@@ mechanicTypeWrap.total: ' + mechanicTypeWrap.total);
                    }

                    for (String caKey : contractActivityItemsWrap.keySet()){
                        ContractActivityItemWrapper contractActivityWrap = contractActivityItemsWrap.get(caKey);
                        EUR_CRM_Contract_Activity_Item__c tempContractActivity = contractActivityWrap.contractActivityItem;
                        System.debug('Flag - About to Validate Contract Activities');
						System.debug('\n contractObj => ' + JSON.serializePretty(contractObj) + '\n');
						if(validateContractActivity(contractObj, mechanicTypeWrap.mechanicType, contractActivityWrap)){
                            Boolean tempValid = true;
                            if(contractActivityWrap != null && contractActivityWrap.contractActivityItem != null &&
                                ( (contractActivityWrap.contractActivityItem.EUR_CRM_Amount__c == null ||
                                contractActivityWrap.contractActivityItem.EUR_CRM_Amount__c == 0) &&
                                    (contractActivityWrap.productItemsCount==null || contractActivityWrap.productItemsCount==0))){
                                tempValid = false;
                            }

                            if(tempValid) {
                                updatedContractActivities.add(tempContractActivity);
                            }
                            tempContractActivity.EUR_CRM_Name__c = (tempContractActivity.EUR_CRM_Name__c==null)?'':tempContractActivity.EUR_CRM_Name__c;
                            String tempCAMapKey = tempContractActivity.EUR_CRM_Mechanic_Type__c+'-'+tempContractActivity.EUR_CRM_Name__c;
                            System.debug('Flag - Save Contract - Check Deleted Product Items:'+key+'-'+caKey+'-'+tempCAMapKey+'-'+contractActivityWrap.deletedContractProductItems);
                            if (contractActivityWrap.deletedContractProductItems.size()>0){
                                deletedContractProducts.addAll(contractActivityWrap.deletedContractProductItems);
                            }
                            if (contractActivityWrap.productItemsCount>0){
                                caProducts.put(tempCAMapKey, contractActivityWrap.contractProductItems.values());
                            }
                        }
                        else{
                            isValid = false;
                        }
                    }
                }

                if (mechanicTypeWrap.deletedContractActivityItems.size()>0){
                    deletedContractActivities.addAll(mechanicTypeWrap.deletedContractActivityItems);
                }

                if (caProducts.size()>0){
                    contractProductsRef.put(mechanicTypeWrap.mechanicType.Id, caProducts);
                }
            }

            System.debug(isValid);
            if (isValid){
                //Delete Old Contract Products and Activities
                System.debug('Flag - Save Contract - Deleted Contract Products:' + deletedContractProducts);
                if (deletedContractProducts.size()>0){
                    deleteResultContractProducts = Database.delete(deletedContractProducts);
                }
                try {
                    System.debug('Flag - Save Contract - Deleted Contract Activities:' + deletedContractActivities);
                    if (deletedContractActivities.size()>0){
                        deleteResultContractActivities = Database.delete(deletedContractActivities);
                    }
                } catch(Exception e) {
                    System.debug(e.getMessage());
                }


                //Save Contract Activities and Products
                System.debug('Flag - Save Contract - Updated Contract Activities:' + updatedContractActivities);
                if (updatedContractActivities.size()>0){
                    System.debug('\n updatedContractActivities.size() => ' + updatedContractActivities.size() + '\n');
                    System.debug('\n updatedContractActivities => ' + JSON.serializePretty(updatedContractActivities) + '\n');
//                    Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingCMTByMechanicTypeExtId = this.getProductLevelByMechanicTypeExtId('DE');
                    System.debug('\n contractSettingCMTByMechanicTypeExtId.size() => ' + contractSettingCMTByMechanicTypeExtId.size() + '\n');
                    System.debug('\n contractSettingCMTByMechanicTypeExtId => ' + JSON.serializePretty(contractSettingCMTByMechanicTypeExtId) + '\n');
					System.debug('\n mechanicTypeMap.size() => ' + mechanicTypeMap.size() + '\n');
					System.debug('\n mechanicTypeMap => ' + JSON.serializePretty(mechanicTypeMap) + '\n');
					for (EUR_CRM_Contract_Activity_Item__c cai : updatedContractActivities) {
						if ( ! mechanicTypeMap.containsKey(cai.EUR_CRM_Mechanic_Type__c)) { continue; }
						String mtExtId = mechanicTypeMap.get(cai.EUR_CRM_Mechanic_Type__c).EUR_CRM_External_ID__c;
						System.debug('\n mtExtId => ' + mtExtId + '\n');
						System.debug('\n contractSettingCMTByMechanicTypeExtId.containsKey(mtExtId) => ' + contractSettingCMTByMechanicTypeExtId.containsKey(mtExtId) + '\n');
						if ( ! contractSettingCMTByMechanicTypeExtId.containsKey(mtExtId)) { continue; }
						cai.EUR_CRM_Product_level__c = contractSettingCMTByMechanicTypeExtId.get(mtExtId).EUR_CRM_Product_Level__c;
						cai.EUR_CRM_Item_Type__c = contractSettingCMTByMechanicTypeExtId.get(mtExtId).EUR_CRM_Setting_Type__c;
					}

                    //System.debug('Flag - Save Contract - Contract Activities:' + updatedContractActivities);
                    upsertResultContractActivities = Database.upsert(updatedContractActivities, EUR_CRM_Contract_Activity_Item__c.Id, false);
                    System.debug('Flag - Save Contract - Result Contract Activities 1:' + upsertResultContractActivities + '-' + updatedContractActivities);

                    System.debug('Flag - Save Contract - Contract Product Reference:' + contractProductsRef);
                    //TODO Assign Contract Activity Id
                    for(EUR_CRM_Contract_Activity_Item__c ca: updatedContractActivities){
                        Id mechanicTypeId = ca.EUR_CRM_Mechanic_Type__c;
                        updatedContractAcitvityIds.add(ca.Id);

                        ca.EUR_CRM_Name__c = (ca.EUR_CRM_Name__c==null)?'':ca.EUR_CRM_Name__c;
                        String caMapKey = ca.EUR_CRM_Mechanic_Type__c+'-'+ca.EUR_CRM_Name__c;
                        //List<EUR_CRM_Contract_Product_Item__c> prodList = new List<EUR_CRM_Contract_Product_Item__c>();
                        //Map<Id, Map<String, List<EUR_CRM_Contract_Product_Item__c>>>
                        if(contractProductsRef.containsKey(mechanicTypeId)){
                            Map<String, List<EUR_CRM_Contract_Product_Item__c>> caMap = contractProductsRef.get(mechanicTypeId);
                            System.debug('Flag - Save Contract - Contract Product Map (CA):'+mechanicTypeId+'-'+caMapKey+'-'+caMap);
                            if(caMap.containsKey(caMapKey)){
                                for(EUR_CRM_Contract_Product_Item__c prodItem: caMap.get(caMapKey)){
                                    if (prodItem.EUR_CRM_Contract_Activity_Item__c == null){
                                    //prodItem.EUR_CRM_Contract_Activity_Item__c = (prodItem.EUR_CRM_Contract_Activity_Item__c == null)?ca.Id:prodItem.EUR_CRM_Contract_Activity_Item__c;
                                        prodItem.EUR_CRM_Contract_Activity_Item__c = ca.Id;
                                    }
                                    if (updatedContractProducts.contains(prodItem)) { continue; }
                                    updatedContractProducts.add(prodItem);
                                }
                            }
                        }
                    }
                }

                System.debug('Flag - Save Contract - Updated Contract Products:' + updatedContractProducts);
                if (updatedContractProducts.size()>0){
//                    deleteExistingContractPaymentPlanPeriods(updatedContractAcitvityIds);
                    System.debug('Flag - Save Contract - Contract Products:' + updatedContractProducts);
                    upsertResultContractProducts = Database.upsert(updatedContractProducts, false);
                    System.debug('Flag - Save Contract - Result Contract Products:' + upsertResultContractProducts);
                }

                //Save Contract
                if (!isFlagship(contractObj)){
                    // This functionality is removed since we use the workflow field update to assign subtype
                    //contractObj.EUR_CRM_Contract_Sub_Type__c = assignContractSubType(mechanicTypeWrapperMap);
                }else{
                    contractObj.EUR_CRM_Flagship_Brand__c = selectedFlagshipBrand;
                }

                contractObj.EUR_CRM_Total_Pro_Rated_Amount__c = proRatedTotal;
                contractObj.EUR_CRM_Number_of_Mechanics__c = contractProductsRef.size();
                contractObj.EUR_CRM_Total_Contributive_Margin__c = this.getTotalContributiveMargin();
                System.debug(contractProductsRef.size());

                System.debug('Flag - Save Contract - Updated Contract:' + JSON.serializePretty(contractObj));
                Database.update(contractObj);

                if (!isQuickSave){
                    pageRef = new PageReference('/'+contractObj.Id);
                    pageRef.setRedirect(true);
                } else {
                    pageRef = new PageReference('/apex/EUR_CRM_DE_ContractBuilderRedirectPage?id=' + contractId);
                    pageRef.setRedirect(true);
                }

                //Reset Deleted List
                for(String key: mechanicTypeWrapperMap.keySet()){
                    MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(key);
                    Map<String, ContractActivityItemWrapper> contractActivityItemsWrap = mechanicTypeWrap.contractActivityItems;

                    if (contractActivityItemsWrap!= null){
                        for (String caKey : contractActivityItemsWrap.keySet()){
                            ContractActivityItemWrapper contractActivityWrap = contractActivityItemsWrap.get(caKey);
                            if (contractActivityWrap.deletedContractProductItems.size()>0){
                                    contractActivityWrap.deletedContractProductItems = new Set<Id>();
                            }
                        }
                    }

                    if (mechanicTypeWrap.deletedContractActivityItems.size()>0){
                           mechanicTypeWrap.deletedContractActivityItems = new Set<Id>();
                    }
                }

                System.debug(mechanicTypeWrapperMap);
            }
        } catch(Exception e) {

            System.debug('EUR_CRM_DE_ContractBuilderController.saveContract() => ' + e);
            pageRef = null;
            Database.rollback(pSavepoint);
            String strError = 'EUR_CRM_DE_ContractBuilderController.saveContract() => ' + e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
            if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                String s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
            }
        }

        return pageRef;
    }

    private Decimal calculateTotalContributiveMargin(List<EUR_CRM_Contract_Product_Item__c> cpis) {
        Decimal totalContributiveMargin = 0;
        for(EUR_CRM_Contract_Product_Item__c cpi : cpis){
            if (cpi.EUR_CRM_Contributive_Margin__c != null) {
                totalContributiveMargin += cpi.EUR_CRM_Contributive_Margin__c;
            }
        }
        return totalContributiveMargin;
    }

    private static Map<String, EUR_CRM_CTM_Contract_setting__mdt> getProductLevelByMechanicTypeExtId(String countryCode) {
        Map<String, EUR_CRM_CTM_Contract_setting__mdt> contractSettingCMTByMechanicTypeExtId = new Map<String, EUR_CRM_CTM_Contract_setting__mdt>();
        List<EUR_CRM_CTM_Contract_setting__mdt> contractSettings = selectContractSettingsWhereCountryCode(countryCode);
        for (EUR_CRM_CTM_Contract_setting__mdt cs : contractSettings) {
            contractSettingCMTByMechanicTypeExtId.put(cs.EUR_CRM_Mechanic_ExtID__c, cs);
        }
        return contractSettingCMTByMechanicTypeExtId;
    }

    private static List<EUR_CRM_CTM_Contract_setting__mdt> selectContractSettingsWhereCountryCode(String countryCode) {
        return [
            SELECT Id
                , EUR_CRM_Product_level__c
                , EUR_CRM_Setting_Type__c
                , EUR_CRM_Mechanic_ExtID__c
            FROM EUR_CRM_CTM_Contract_setting__mdt
            WHERE EUR_CRM_Country_Code__c = :countryCode
        ];
    }

    private Decimal getTotalContributiveMargin() {
        Map<Id,EUR_CRM_Contract_Product_Item__c> cpiToCalculateTotalContrMarginById = new Map<Id,EUR_CRM_Contract_Product_Item__c>();
        for(String key: mechanicTypeWrapperMap.keySet()){
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(key);
            Map<String, ContractActivityItemWrapper> contractActivityItemsWrap = mechanicTypeWrap.contractActivityItems;

            if (contractActivityItemsWrap!= null){
                for (String caKey : contractActivityItemsWrap.keySet()){
                    if (contractActivityItemsWrap.get(caKey).contractProductItems.isEmpty()) { continue; }

                    for (EUR_CRM_Contract_Product_Item__c cpi : contractActivityItemsWrap.get(caKey).contractProductItems.values()) {
						cpiToCalculateTotalContrMarginById.put(cpi.Id, cpi);
                    }
                }
            }
        }
		List<EUR_CRM_Contract_Product_Item__c> cpis = [SELECT EUR_CRM_Contributive_Margin__c FROM EUR_CRM_Contract_Product_Item__c WHERE Id IN :cpiToCalculateTotalContrMarginById.keySet()];

        return this.calculateTotalContributiveMargin(cpis);
    }

    public PageReference cloneContractActivity() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String param_mechanicTypeId = params.get('PARAM_MECHANIC_TYPE_ID');
        String param_mechanicTypeName = params.get('PARAM_MECHANIC_TYPE_NAME');
        String param_contractActivityKey = params.get('PARAM_CONTRACT_ACTIVITY_KEY');

        // Determine which contract activity is selected
        if(mechanicTypeWrapperMap.containsKey(param_mechanicTypeName)) {
            MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(param_mechanicTypeName);

            if (mechanicTypeWrap.contractActivityItems.containsKey(param_contractActivityKey)){
                ContractActivityItemWrapper caWrap = mechanicTypeWrap.contractActivityItems.get(param_contractActivityKey);
                EUR_CRM_Contract_Activity_Item__c caItem = caWrap.contractActivityItem;

                // Clone selected Contract Activity
                EUR_CRM_Contract_Activity_Item__c newCAItem = caItem.clone(false, true, false, false);
                newCAItem.EUR_CRM_Start_Date__c = null;
                newCAItem.EUR_CRM_End_Date__c = null;
                newCAItem.EUR_CRM_Amount__c = null;
                newCAItem.EUR_CRM_Name__c = null;

                System.debug(newCAItem);
                System.debug(caWrap.contractProductItems);

                // mechanicTypeWrap.mechanicType.EUR_CRM_Payment_Term_By_MT__c = newCAItem.EUR_CRM_Payment_Term_By_SR__c;
                mechanicTypeWrap.currentContractActivityItem = new ContractActivityItemWrapper(newCAItem);
                mechanicTypeWrap.currentContractActivityItem.isNew = true;
                if(BQ_MECHANIC_TYPE_SET.contains(param_mechanicTypeName)){
                    mechanicTypeWrap.currentContractActivityItem.brandQualityItems.putAll(allBrandQualityMap);
                } else if (isFlagship(contractObj) && (!mechanicTypeWrap.mechanicType.EUR_CRM_Ignore_CM_Flagship__c)){
                    mechanicTypeWrap.currentContractActivityItem.brandItems = new Map<Id, EUR_CRM_Brand__c>();
                    mechanicTypeWrap.currentContractActivityItem.brandItems.putAll(allFlagshipBrandMap);
                }else{
                    mechanicTypeWrap.currentContractActivityItem.brandItems.putAll(allBrandMap);
                }

                String contractProductItemKey;
                EUR_CRM_Contract_Product_Item__c contractProductItem;

                // CLONE ALL Contract Product Items
                if(caItem.Contract_Product_Items__r != null && caItem.Contract_Product_Items__r.size() > 0) {
                    for(EUR_CRM_Contract_Product_Item__c newCPItem: caItem.Contract_Product_Items__r) {
                        System.debug(allBrandMap);
                        System.debug(newCPItem);

                        if(newCPItem.EUR_CRM_Brand_Quality__c != null) {
                            contractProductItemKey = String.valueOf(allBrandQualityMap.get(newCPItem.EUR_CRM_Brand_Quality__c).Id);
                            contractProductItem = createContractProductItem(mechanicTypeWrap.currentContractActivityItem.contractActivityItem, allBrandQualityMap.get(newCPItem.EUR_CRM_Brand_Quality__c));
                            mechanicTypeWrap.currentContractActivityItem.brandItems.remove(newCPItem.EUR_CRM_Brand_Quality__c);
                        } else if(newCPItem.EUR_CRM_Brand__c != null) {
                            contractProductItemKey = String.valueOf(allBrandMap.get(newCPItem.EUR_CRM_Brand__c).Id);
                            contractProductItem = createContractProductItem(mechanicTypeWrap.currentContractActivityItem.contractActivityItem, allBrandMap.get(newCPItem.EUR_CRM_Brand__c));
                            mechanicTypeWrap.currentContractActivityItem.brandItems.remove(newCPItem.EUR_CRM_Brand__c);
                        }

                        mechanicTypeWrap.currentContractActivityItem.contractProductItems.put(contractProductItemKey, contractProductItem);

                        System.debug(contractProductItem);
                        System.debug(mechanicTypeWrap.currentContractActivityItem.contractProductItems);
                    }
                } else if(caWrap.contractProductItems.size() > 0) {
                    // Case for unsaved Contract Product Items that need to be cloned
                    for(EUR_CRM_Contract_Product_Item__c newCPItem: caWrap.contractProductItems.values()) {
                        System.debug(allBrandMap);
                        System.debug(newCPItem);

                        if(newCPItem.EUR_CRM_Brand_Quality__c != null) {
                            contractProductItemKey = String.valueOf(allBrandQualityMap.get(newCPItem.EUR_CRM_Brand_Quality__c).Id);
                            contractProductItem = createContractProductItem(mechanicTypeWrap.currentContractActivityItem.contractActivityItem, allBrandQualityMap.get(newCPItem.EUR_CRM_Brand_Quality__c));
                            mechanicTypeWrap.currentContractActivityItem.brandItems.remove(newCPItem.EUR_CRM_Brand_Quality__c);
                        } else if(newCPItem.EUR_CRM_Brand__c != null) {
                            contractProductItemKey = String.valueOf(allBrandMap.get(newCPItem.EUR_CRM_Brand__c).Id);
                            contractProductItem = createContractProductItem(mechanicTypeWrap.currentContractActivityItem.contractActivityItem, allBrandMap.get(newCPItem.EUR_CRM_Brand__c));
                            mechanicTypeWrap.currentContractActivityItem.brandItems.remove(newCPItem.EUR_CRM_Brand__c);
                        }

                        mechanicTypeWrap.currentContractActivityItem.contractProductItems.put(contractProductItemKey, contractProductItem);
                    }
                }
            }
        }

        return null;
    }

    public void deleteExistingContractPaymentPlanPeriods(List<Id> updatedContractAcitvityIds) {
        System.debug(updatedContractAcitvityIds);
        List<EUR_CRM_Contract_Payment_Plan_Period__c> existingContractPaymentPlanPeriods = new List<EUR_CRM_Contract_Payment_Plan_Period__c>();

        existingContractPaymentPlanPeriods = [SELECT Id, EUR_CRM_Description__c,
                                                EUR_CRM_Contract_Payment_Plan__c,
                                                EUR_CRM_Contract_Activity_Item__c,
                                                EUR_CRM_Payment_Period_Start_Date__c,
                                                EUR_CRM_Payment_Period_End_Date__c,
                                                EUR_CRM_CPPP_Amount__c,
                                                EUR_CRM_CPPP_Payment_Term__c,
                                                EUR_CRM_CPPP_Earliest_Date_of_Invoice__c,
                                                EUR_CRM_Contract_Product_Item__c, EUR_CRM_Brand__c
                                                FROM EUR_CRM_Contract_Payment_Plan_Period__c
                                                WHERE EUR_CRM_Contract_Activity_Item__c IN :updatedContractAcitvityIds];

        if(existingContractPaymentPlanPeriods != null) {
            delete existingContractPaymentPlanPeriods;
        }
    }

    public Boolean validateContract(EUR_CRM_Contract__c contractObj){
        Boolean isValid = false;

        return isValid;
    }

    private Boolean validateContractActivityOverlap(EUR_CRM_Contract__c contractObj, EUR_CRM_Mechanic_Type__c mechanicType, ContractActivityItemWrapper contractActivityWrap) {
        if(!OVERLAP_CHECKING.contains(mechanicType.EUR_CRM_Mechanic_Type_Name_English__c)) {
            // Overlap Checking only for Pouring Refund mechanic type
            return true;
        }

        List<EUR_CRM_Contract_Activity_Item__c> existingContractActivityItems = [SELECT Id, EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c,
                                                                                    EUR_CRM_Name__c, EUR_CRM_PR_DE_Flag__c,
                                                                                    (SELECT EUR_CRM_Brand__c, EUR_CRM_Brand__r.Name,
                                                                                     EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.Name
                                                                                     FROM Contract_Product_Items__r)
                                                                                    FROM EUR_CRM_Contract_Activity_Item__c
                                                                                    WHERE EUR_CRM_Contract__c = :contractObj.Id
                                                                                    AND EUR_CRM_Mechanic_Type__c = :mechanicType.Id];
        // Maps Contract Activity Item Name to Contract Product Item
        Map<String, List<EUR_CRM_Contract_Product_Item__c>> existingContractProductItems = new Map<String, List<EUR_CRM_Contract_Product_Item__c>>();

        System.debug(existingContractActivityItems);

        MechanicTypeWrapper mechanicTypeWrap = mechanicTypeWrapperMap.get(mechanicType.EUR_CRM_Mechanic_Type_Name_English__c);
        for(ContractActivityItemWrapper caItemWrapper: mechanicTypeWrap.contractActivityItems.values()) {
            existingContractActivityItems.add(caItemWrapper.contractActivityItem);
            //existingContractProductItems.addAll(caItemWrapper.contractProductItems);
            for(EUR_CRM_Contract_Product_Item__c cpItem: caItemWrapper.contractProductItems.values()) {
                if(contractActivityWrap.contractActivityItem.EUR_CRM_Name__c != caItemWrapper.contractActivityItem.EUR_CRM_Name__c) {
                    if(existingContractProductItems.get(caItemWrapper.contractActivityItem.EUR_CRM_Name__c) == null) {

                        existingContractProductItems.put(caItemWrapper.contractActivityItem.EUR_CRM_Name__c, new List<EUR_CRM_Contract_Product_Item__c>());
                    }

                    existingContractProductItems.get(caItemWrapper.contractActivityItem.EUR_CRM_Name__c).add(cpItem);
                }
            }
        }

        System.debug(existingContractProductItems);
        System.debug(existingContractActivityItems);

        if(contractActivityWrap.contractActivityItem != null) {
            for(EUR_CRM_Contract_Activity_Item__c caItem: existingContractActivityItems) {
                String productId = '';
                String productName = '';

                if(caItem.Contract_Product_Items__r != null && caItem.Contract_Product_Items__r.size() > 0) {
                    for(EUR_CRM_Contract_Product_Item__c cpItem: caItem.Contract_Product_Items__r) {
                        if(cpItem.EUR_CRM_Brand__c != null) {
                            productId = cpItem.EUR_CRM_Brand__c;
                            productName = cpItem.EUR_CRM_Brand__r.Name;
                        } else if(cpItem.EUR_CRM_Brand_Quality__c != null) {
                            productId = cpItem.EUR_CRM_Brand_Quality__c;
                            productName = cpItem.EUR_CRM_Brand_Quality__r.Name;
                        }

                        if(contractActivityWrap.contractProductItems.keySet().contains(productId) &&
                            (caItem.EUR_CRM_Start_Date__c <= contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c) &&
                            (caItem.EUR_CRM_End_Date__c   >= contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c) &&
                            caItem.EUR_CRM_Name__c        != contractActivityWrap.contractActivityItem.EUR_CRM_Name__c &&
                            caItem.EUR_CRM_PR_DE_Flag__c  == contractActivityWrap.contractActivityItem.EUR_CRM_PR_DE_Flag__c) {

                            String errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c + ' - Overlap on ' + productName;
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                            return false;
                        }
                    }
                } else if(existingContractProductItems.size() > 0 && existingContractProductItems.containsKey(caItem.EUR_CRM_Name__c)) {
                    // Case for other unsaved contract activities exists
                    for(EUR_CRM_Contract_Product_Item__c cpItem: existingContractProductItems.get(caItem.EUR_CRM_Name__c)) {
                        if(cpItem.EUR_CRM_Brand__c != null) {
                            productId = cpItem.EUR_CRM_Brand__c;
                        } else if(cpItem.EUR_CRM_Brand_Quality__c != null) {
                            productId = cpItem.EUR_CRM_Brand_Quality__c;
                        }

                        if(contractActivityWrap.contractProductItems.keySet().contains(productId) &&
                            (caItem.EUR_CRM_Start_Date__c <= contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c) &&
                            (caItem.EUR_CRM_End_Date__c   >= contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c) &&
                            caItem.EUR_CRM_Name__c        != contractActivityWrap.contractActivityItem.EUR_CRM_Name__c &&
                            caItem.EUR_CRM_PR_DE_Flag__c  == contractActivityWrap.contractActivityItem.EUR_CRM_PR_DE_Flag__c) {

                            String errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c + ' - Overlap on Product';
                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
                            return false;
                        }
                    }
                }
            }
            return true;
        }

        return false;
    }

    //private Map<Id, EUR_CRM_Quality__c> trimBrandQualityList(){}
    private Boolean validateContractActivity(EUR_CRM_Contract__c contractObj, EUR_CRM_Mechanic_Type__c mechanicType, ContractActivityItemWrapper contractActivityWrap){
            //Reset messages
            ApexPages.getMessages().clear();

            //validate contract activity base on mechanic type
            String errorMessage = '';
            Boolean isValid = true;

            System.debug('Flag - Validate Contract Activity:' + mechanicType + '--' + contractActivityWrap);
            System.debug('Flag - Validate Contract Activity 1:' +mechanicTypeRequiredContractActivityName);
            System.debug('Flag - Validate Contract Activity 1:' +mechanicType.EUR_CRM_Mechanic_Type_Name_English__c);
            System.debug('Flag - Validate Contract Activity 2:' +contractActivityWrap.contractActivityItem.EUR_CRM_Name__c);

            //Check Name for Events and Training
            if ((mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Events')|| mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Training')) && (contractActivityWrap.contractActivityItem.EUR_CRM_Name__c=='' || contractActivityWrap.contractActivityItem.EUR_CRM_Name__c==null)){
                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+Label.EUR_CRM_Missing_Required_Field+' '+contractActivityFieldMap.get('Name').getDescribe().getLabel();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Check Payment Term for all mechanic type that requires payment term (EUR_CRM_Has_Payment_Term__c)
//            System.debug(contractActivityWrap.contractActivityItem.EUR_CRM_Payment_Term_By_SR__c);
//            if (( ! (mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Listing') || mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('House Pouring'))) &&
//                contractActivityWrap.contractActivityItem.EUR_CRM_Payment_Term_By_SR__c==null || contractActivityWrap.contractActivityItem.EUR_CRM_Payment_Term_By_SR__c == 'None'
//                ){
//                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+Label.EUR_CRM_Missing_Required_Field+' '+contractActivityFieldMap.get('EUR_CRM_Payment_Term_By_SR__c').getDescribe().getLabel();
//                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
//            }
            //Check Amount(Lump Sum) for all mechanic type that has lump sum (EUR_CRM_Has_Lump_Sum__c)
            if (mechanicType.EUR_CRM_Has_Lump_Sum__c && contractActivityWrap.contractActivityItem.EUR_CRM_Amount__c==null &&
                    ((mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Events')|| mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Training')) ||
                    ((!mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Events'))&&(!mechanicType.EUR_CRM_Mechanic_Type_Name_English__c.equalsIgnoreCase('Training')) && mechanicType.EUR_CRM_Has_Per_BQ__c && (contractActivityWrap.productItemsCount!=null && contractActivityWrap.productItemsCount>0)))){
                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+Label.EUR_CRM_Missing_Required_Field+' '+contractActivityFieldMap.get('EUR_CRM_Amount__c').getDescribe().getLabel();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Check Start Date for all mechanic type that has start date (EUR_CRM_Has_Start_Date__c)
            if (mechanicType.EUR_CRM_Has_Start_Date__c && contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c==null){
                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+Label.EUR_CRM_Missing_Required_Field+' '+contractActivityFieldMap.get('EUR_CRM_Start_Date__c').getDescribe().getLabel();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Validate if Start Date is not earlier that Contract Start Date
            else if (mechanicType.EUR_CRM_Has_Start_Date__c &&
                    contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c!=null &&
                    (
                    contractObj.EUR_CRM_Start_Date__c>contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c ||
                    contractObj.EUR_CRM_End_Date__c < contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c )){

                    //errorMessage = mechanicType.Name+' - '+Label.EUR_CRM_Invalid_Value+' '+contractActivityFieldMap.get('EUR_CRM_Start_Date__c').getDescribe().getLabel();
                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+  Label.EUR_CRM_ValidStartDate;

                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Validate if end date is not less than start date.
            else if (mechanicType.EUR_CRM_Has_Start_Date__c && mechanicType.EUR_CRM_Has_End_Date__c &&
                    contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c!=null &&
                     contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c < contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c ){

                    //errorMessage = mechanicType.Name+' - '+Label.EUR_CRM_Invalid_Value+' '+contractActivityFieldMap.get('EUR_CRM_Start_Date__c').getDescribe().getLabel();
                errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+  Label.EUR_CRM_ValidStartEndDate;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Check End Date for all mechanic type that has start date (EUR_CRM_Has_End_Date__c)
            if(mechanicType.EUR_CRM_Has_End_Date__c&& contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c==null){
                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c+' - '+Label.EUR_CRM_Missing_Required_Field+' '+contractActivityFieldMap.get('EUR_CRM_End_Date__c').getDescribe().getLabel();
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Added jan 07.2014
            //End Date should be within the Contract Performance Period
            else if (mechanicType.EUR_CRM_Has_End_Date__c &&
                    contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c!=null &&
                    contractActivityWrap.contractActivityItem.EUR_CRM_Start_Date__c!=null &&
                    (contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c > contractObj.EUR_CRM_End_Date__c ||
                     contractActivityWrap.contractActivityItem.EUR_CRM_End_Date__c < contractObj.EUR_CRM_Start_Date__c )
                    ){

                errorMessage = mechanicType.Name + ' - ' + Label.EUR_CRM_ValidEndDate;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }
            //Check Product Items length if contract activity has lump sum
            if (!Test.isRunningTest() && mechanicType.EUR_CRM_Has_Per_BQ__c && (contractActivityWrap.productItemsCount==null || contractActivityWrap.productItemsCount<=0)){
                    errorMessage = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c + ' - '+Label.EUR_CRM_Empty_Product_List;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }

            if (errorMessage.length()>0){
                    System.debug('Flag - Validate Contract Activity - Error Message:' + errorMessage);
                    isValid = false;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
            }

            return isValid;
    }

    private Map<Id, EUR_CRM_Quality__c> trimContractSourceMap(Map<Id, EUR_CRM_Quality__c> referenceMap, Set<Id>existingSet){
        System.debug('Flag - Trim Contract Source Map:' + referenceMap + '--'+ existingSet);
        Map<Id, EUR_CRM_Quality__c> tempRefMap = new Map<Id, EUR_CRM_Quality__c>();
        tempRefMap.putAll(referenceMap);
        for (Id key: existingSet){
            if (tempRefMap.containsKey(key)){
                    tempRefMap.remove(key);
            }
        }
        System.debug('Flag - Trim Contract Source Map - Result:' + tempRefMap);
        return tempRefMap;
    }

     private Map<Id, EUR_CRM_Brand__c> trimContractSourceMap(Map<Id, EUR_CRM_Brand__c> referenceMap, Set<Id>existingSet){
        System.debug('Flag - Trim Contract Source Map:' + referenceMap + '--'+ existingSet);
        Map<Id, EUR_CRM_Brand__c> tempRefMap = new Map<Id, EUR_CRM_Brand__c>();
        tempRefMap.putAll(referenceMap);
        for (Id key: existingSet){
            if (tempRefMap.containsKey(key)){
                    tempRefMap.remove(key);
            }
        }
        System.debug('Flag - Trim Contract Source Map - Result:' + tempRefMap);
        return tempRefMap;
    }
    @TestVisible
    private EUR_CRM_Contract_Product_Item__c createContractProductItem(EUR_CRM_Contract_Activity_Item__c contractActivityItem, EUR_CRM_Brand__c contractSourceItem) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
        EUR_CRM_Contract_Product_Item__c cpItem = new EUR_CRM_Contract_Product_Item__c(
            RecordTypeId = rtId,
            EUR_CRM_Contract_Activity_Item__c = contractActivityItem.Id,
            EUR_CRM_Brand__c = contractSourceItem.Id,
            EUR_CRM_Name_Reference__c = contractSourceItem.Name);
        cpItem.EUR_CRM_Unit__c = defaultUnitValue;
        cpItem.EUR_CRM_With_Logo__c = true;
        return cpItem;
    }

    private EUR_CRM_Contract_Product_Item__c createContractProductItem(EUR_CRM_Contract_Activity_Item__c contractActivityItem, EUR_CRM_Quality__c contractSourceItem) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
        EUR_CRM_Contract_Product_Item__c cpItem = new EUR_CRM_Contract_Product_Item__c(
            RecordTypeId = rtId,
            EUR_CRM_Contract_Activity_Item__c = contractActivityItem.Id,
            EUR_CRM_Brand_Quality__c = contractSourceItem.Id,
            EUR_CRM_Name_Reference__c = contractSourceItem.Name);
        cpItem.EUR_CRM_Unit__c = defaultUnitValue;
        cpItem.EUR_CRM_With_Logo__c = true;
        return cpItem;
    }

    @TestVisible
    private EUR_CRM_Contract_Product_Item__c createContractProductItem(EUR_CRM_Contract_Activity_Item__c contractActivityItem) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Product_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Product_Item').getRecordTypeId();
        EUR_CRM_Contract_Product_Item__c cpItem = new EUR_CRM_Contract_Product_Item__c(
            RecordTypeId = rtId,
            EUR_CRM_Contract_Activity_Item__c = contractActivityItem.Id,
            EUR_CRM_Description__c = null,
            EUR_CRM_Brand_Quality__c = null,
            EUR_CRM_Brand__c = null,
            EUR_CRM_Name_Reference__c = null);
        cpItem.EUR_CRM_Unit__c = defaultUnitValue;
        cpItem.EUR_CRM_With_Logo__c = true;
        return cpItem;
    }


    private EUR_CRM_Contract_Activity_Item__c createContractActivity(EUR_CRM_Contract__c contract, EUR_CRM_Mechanic_Type__c mechanicType) {
        Id rtId = Schema.SObjectType.EUR_CRM_Contract_Activity_Item__c.getRecordTypeInfosByDeveloperName().get('EUR_DE_Contract_Activity_Item').getRecordTypeId();
        EUR_CRM_Contract_Activity_Item__c contractActivity = new EUR_CRM_Contract_Activity_Item__c(
            RecordTypeId = rtId,
            EUR_CRM_Contract__c = contract.Id,
            EUR_CRM_Mechanic_Type__c = mechanicType.Id);
        return contractActivity;
    }

    private Map <Id, EUR_CRM_Mechanic_Type__c> retrieveMechanicTypes(EUR_CRM_Contract__c contractObj){
        Map <Id, EUR_CRM_Mechanic_Type__c> mechanicTypeMap = new Map <Id, EUR_CRM_Mechanic_Type__c>();

        mechanicTypeMap = new Map <Id, EUR_CRM_Mechanic_Type__c>([SELECT Id, Name, EUR_CRM_Country_Code__c,
                                                            recordType.Developername,
                                                            EUR_CRM_Grouping_Name__c,
                                                            EUR_CRM_Has_End_Date__c, EUR_CRM_Has_Lump_Sum__c,
                                                            EUR_CRM_Has_Per_BQ__c, EUR_CRM_Has_Start_Date__c,
                                                            EUR_CRM_Has_Vendor__c, EUR_CRM_Lump_Sum_Or_Per_BQ__c,
                                                            EUR_CRM_Mechanic_Process_Type__c, EUR_CRM_Has_Multiple_Activity_Item__c,
                                                            EUR_CRM_Has_Payment_Term__c, EUR_CRM_Has_Budget_Exclusion_Option__c,
                                                            EUR_CRM_Is_Pro_Rated_by_Month__c, EUR_CRM_Ignore_CM_Flagship__c,
                                                            EUR_CRM_Mechanic_Type_Name_English__c,
                                                            EUR_CRM_External_ID__c
                                                            FROM EUR_CRM_Mechanic_Type__c
                                                            WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                                            AND RecordType.DeveloperName = 'EUR_DE_Mechanic_Type']);
        return mechanicTypeMap;
    }

    private Map <Id, EUR_CRM_Mechanic_Type__c> retrieveOldMechanicTypes(EUR_CRM_Contract__c contractObj){
        Map <Id, EUR_CRM_Mechanic_Type__c> mechanicTypeMap = new Map <Id, EUR_CRM_Mechanic_Type__c>();

        mechanicTypeMap = new Map <Id, EUR_CRM_Mechanic_Type__c>([SELECT Id, Name, EUR_CRM_Country_Code__c,
                                                            recordType.Developername,
                                                            EUR_CRM_Grouping_Name__c,
                                                            EUR_CRM_Has_End_Date__c, EUR_CRM_Has_Lump_Sum__c,
                                                            EUR_CRM_Has_Per_BQ__c, EUR_CRM_Has_Start_Date__c,
                                                            EUR_CRM_Has_Vendor__c, EUR_CRM_Lump_Sum_Or_Per_BQ__c,
                                                            EUR_CRM_Mechanic_Process_Type__c, EUR_CRM_Has_Multiple_Activity_Item__c,
                                                            EUR_CRM_Has_Payment_Term__c, EUR_CRM_Has_Budget_Exclusion_Option__c,
                                                            EUR_CRM_Is_Pro_Rated_by_Month__c, EUR_CRM_Ignore_CM_Flagship__c,
                                                            EUR_CRM_Mechanic_Type_Name_English__c,
                                                            EUR_CRM_External_ID__c
                                                            FROM EUR_CRM_Mechanic_Type__c
                                                            WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                                            AND RecordType.DeveloperName != 'EUR_DE_Mechanic_Type']);
        return mechanicTypeMap;
    }

    private Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> retrieveContractActivityItems(EUR_CRM_Contract__c contractObj){
        Map <Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivityMap = new Map <Id, Map<String, EUR_CRM_Contract_Activity_Item__c>>();

        for (EUR_CRM_Contract_Activity_Item__c contractActivityItem: [SELECT Id, Name,
                                                                EUR_CRM_Amount__c, EUR_CRM_Contract__c,
                                                                EUR_CRM_End_Date__c, EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c,
                                                                EUR_CRM_Name__c,
                                                                EUR_CRM_Start_Date__c, EUR_CRM_Vendor__c,
                                                                EUR_CRM_Exclude_Budget_Deduction__c,
                                                                EUR_CRM_Total_Pouring_Refund__c,
                                                                EUR_CRM_Product_Items_Total__c,
                                                                EUR_CRM_Product_Items_Count__c,
                                                                EUR_CRM_Pro_Rated_by_Month__c,
                                                                EUR_CRM_Description__c, EUR_CRM_Product_Qty_Total__c,
                                                                EUR_CRM_Payment_Term_By_SR__c,
                                                                EUR_CRM_Payment_Term__c,
                                                                EUR_CRM_PR_DE_Flag__c,
                                                                EUR_CRM_Is_PR_Event__c,
                                                                EUR_CRM_Is_PR_Training__c,
                                                                EUR_CRM_Is_PR_Other__c
                                                                FROM EUR_CRM_Contract_Activity_Item__c
                                                                WHERE EUR_CRM_Contract__c =: contractObj.Id])
        {
                //contractActivityMap Key
                Id contractActivityKey = contractActivityItem.EUR_CRM_Mechanic_Type__c;
                contractActivityItem.EUR_CRM_Name__c = (contractActivityItem.EUR_CRM_Name__c==null)?'':contractActivityItem.EUR_CRM_Name__c;
                contractActivityItem.EUR_CRM_Vendor__c = (contractActivityItem.EUR_CRM_PR_DE_Flag__c)?PR_DEUTSCHLAND:contractActivityItem.EUR_CRM_Vendor__c;
                //caItemMap Key
//                String key = contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c;
                String key = contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.Id;
                Map<String, EUR_CRM_Contract_Activity_Item__c> caItemMap = (contractActivityMap.containsKey(contractActivityKey))?contractActivityMap.get(contractActivityKey):new Map<String, EUR_CRM_Contract_Activity_Item__c>();

                caItemMap.put(key, contractActivityItem);

                contractActivityMap.put(contractActivityKey, caItemMap);
                System.debug('\n contractActivityMap.size() => ' + contractActivityMap.size() + '\n');
                System.debug('\n contractActivityMap => ' + contractActivityMap + '\n');
        }

        return contractActivityMap;
    }

    private Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> retrieveContractProductItems(EUR_CRM_Contract__c contractObj){
        Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> contractProductMap = new Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>>();

        for (EUR_CRM_Contract_Product_Item__c contractProductItem: [SELECT Id, Name,
                                                                EUR_CRM_Brand__c,
                                                                EUR_CRM_Brand__r.Name,
                                                                EUR_CRM_Brand_Quality__c,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c,
                                                                EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c,
                                                                EUR_CRM_Contract_Activity_Item__r.Name,
                                                                EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c,
                                                                EUR_CRM_Description__c, EUR_CRM_Quantity__c, EUR_CRM_Volume_lt__c,
                                                                EUR_CRM_Amount__c, EUR_CRM_Total_Spent__c,
                                                                EUR_CRM_Amount_Spent__c,
                                                                EUR_CRM_Unit__c, EUR_CRM_Name_Reference__c,
                                                                EUR_CRM_Amount_Spent_Reference__c, EUR_CRM_Exclusive__c,
                                                                EUR_CRM_With_Logo__c,
                                                                EUR_CRM_Contributive_Margin__c
                                                                FROM EUR_CRM_Contract_Product_Item__c
                                                                WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c=:contractObj.Id])
        {
            System.debug('Flag - Retrieve Contract Product Items - Check Product:' + contractProductItem);
            //contractProductMap Key
            contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c = (contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c==null)?'':contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c;
//            String contractProductKey = contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c +'-'+ contractProductItem.EUR_CRM_Contract_Activity_Item__r.Name;
            String contractProductKey = contractProductItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__c +'-'+ contractProductItem.EUR_CRM_Contract_Activity_Item__c;
            //cpItemMap Key
            //String key = (contractProductItem.EUR_CRM_Brand__c==null && contractProductItem.EUR_CRM_Brand_Quality__c==null)?(DESCRIPTION_PREFIX+contractProductItem.Id):null;
            //key = (key==null && contractProductItem.EUR_CRM_Brand__c!=null)?contractProductItem.EUR_CRM_Brand__c:contractProductItem.EUR_CRM_Brand_Quality__c;
            String key = null;
            if (contractProductItem.EUR_CRM_Brand__c!=null && contractProductItem.EUR_CRM_Brand_Quality__c==null){
                key = contractProductItem.EUR_CRM_Brand__c;
            }else if (contractProductItem.EUR_CRM_Brand__c==null && contractProductItem.EUR_CRM_Brand_Quality__c!=null){
                key = contractProductItem.EUR_CRM_Brand_Quality__c;
            }else{
                key = DESCRIPTION_PREFIX+contractProductItem.Id;
            }

            if (key !=null){
                    Map <String, EUR_CRM_Contract_Product_Item__c> cpItemMap = (contractProductMap.containsKey(contractProductKey))?contractProductMap.get(contractProductKey):new Map <String, EUR_CRM_Contract_Product_Item__c>();

                    //System Field Update
                    if (contractProductItem.EUR_CRM_Brand__r.Name != null){
                            contractProductItem.EUR_CRM_Name_Reference__c = contractProductItem.EUR_CRM_Brand__r.Name;
                    }
                    else if (contractProductItem.EUR_CRM_Brand_Quality__r.Name != null){
                            contractProductItem.EUR_CRM_Name_Reference__c = contractProductItem.EUR_CRM_Brand_Quality__r.Name;
                    }
                    contractProductItem.EUR_CRM_Amount_Spent_Reference__c = contractProductItem.EUR_CRM_Total_Spent__c;

                    cpItemMap.put(key, contractProductItem);

                    contractProductMap.put(contractProductKey, cpItemMap);
            }
        }

        System.debug('Flag - Retrieve Product Items:' + contractProductMap);
        return contractProductMap;
    }

    private Map<Id, EUR_CRM_Contract_Mechanic__c> retrieveContractMechanic( Map <Id, EUR_CRM_Mechanic_Type__c> mechanicTypes){
            Map<Id, EUR_CRM_Contract_Mechanic__c> contractMechanicMap = new Map<Id, EUR_CRM_Contract_Mechanic__c>();

            if (mechanicTypes.size()>0){
                    contractMechanicMap = new Map <Id, EUR_CRM_Contract_Mechanic__c>();
                    for(EUR_CRM_Contract_Mechanic__c cm: [SELECT Id, Name,
                                                                                    EUR_CRM_Brand__c, EUR_CRM_Brand__r.Name,EUR_CRM_Brand__r.EUR_CRM_Active__c,
                                                                                    EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.Name,EUR_CRM_Brand_Quality__r.EUR_CRM_Active__c,
                                                                                    EUR_CRM_Country_Code__c, EUR_CRM_Mechanic__c,
                                                                                    EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c
                                                                                    FROM EUR_CRM_Contract_Mechanic__c
                                                                                    WHERE EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c IN: mechanicTypes.keySet()
                                                                            ]){
                        if((cm.EUR_CRM_Brand__c != null && cm.EUR_CRM_Brand__r.EUR_CRM_Active__c) ||
                            (cm.EUR_CRM_Brand_Quality__c != null && cm.EUR_CRM_Brand_Quality__r.EUR_CRM_Active__c)){
                            contractMechanicMap.put(cm.id,cm);
                        }
                    }
            }
            System.debug('Contract Mechanic Type Map:' + contractMechanicMap);
            return contractMechanicMap;
    }

    private Set<Id> retrieveContractMechanicBrands(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Contract_Mechanic__c> contractMechanics){
            Set<Id> specificBrands = new Set<Id>();

            //Iterate Contract Mechanic - Get all Brands
            for (EUR_CRM_Contract_Mechanic__c cm : contractMechanics){
                    Id key = cm.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c;
                    if (cm.EUR_CRM_Brand__c != null){
                            specificBrands.add(cm.EUR_CRM_Brand__c );
                    }
            }

            System.debug('Flag - specificBrands:' + specificBrands);
            return specificBrands;
    }

    private Map<Id, Map<Id, EUR_CRM_Brand__c>> retrieveContractMechanicBrandsMap(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Contract_Mechanic__c> contractMechanics, Map<Id, EUR_CRM_Brand__c> sourceMap){
            //Key:Mechanic Type Id
            Map<Id, Map<Id, EUR_CRM_Brand__c>> sourceMapPerMechanicType = new Map<Id, Map<Id, EUR_CRM_Brand__c>>();
            Set<Id> specificBrands = new Set<Id>();

            //Iterate Contract Mechanic - populate brand map per mechanic type
            for (EUR_CRM_Contract_Mechanic__c cm : contractMechanics){
                    Id key = cm.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c;
                    Id brandKey = cm.EUR_CRM_Brand__c;
                    Map<Id, EUR_CRM_Brand__c> mtBrandMap = new Map<Id, EUR_CRM_Brand__c>();
                    if (sourceMapPerMechanicType.containsKey(key) && sourceMap.containsKey(brandKey)){
                            mtBrandMap = sourceMapPerMechanicType.get(key);
                            mtBrandMap.put(brandKey,sourceMap.get(brandKey));

                            sourceMapPerMechanicType.put(key, mtBrandMap);
                    }
            }

            return sourceMapPerMechanicType;
    }

    private Set<Id> retrieveContractMechanicBrandQualities(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Contract_Mechanic__c> contractMechanics){
            Set<Id> specificBrandQualities = new Set<Id>();

            //Iterate Contract Mechanic - Get all Brands
            for (EUR_CRM_Contract_Mechanic__c cm : contractMechanics){
                    if (cm.EUR_CRM_Brand_Quality__c != null){
                            specificBrandQualities.add(cm.EUR_CRM_Brand_Quality__c);
                    }
            }
            return specificBrandQualities;
    }

    private Map<Id, Map<Id, EUR_CRM_Quality__c>> retrieveContractMechanicBrandQualitiesMap(EUR_CRM_Contract__c contractObj, List<EUR_CRM_Contract_Mechanic__c> contractMechanics, Map<Id, EUR_CRM_Quality__c> sourceMap){
            //Key:Mechanic Type Id
            Map<Id, Map<Id, EUR_CRM_Quality__c>> sourceMapPerMechanicType = new Map<Id, Map<Id, EUR_CRM_Quality__c>>();
            Set<Id> specificBrandQualities = new Set<Id>();

            //Iterate Contract Mechanic - populate brand map per mechanic type
            for (EUR_CRM_Contract_Mechanic__c cm : contractMechanics){
                    Id key = cm.EUR_CRM_Mechanic__r.EUR_CRM_Mechanic_Type__c;
                    Id bqKey = cm.EUR_CRM_Brand_Quality__c;
                    Map<Id, EUR_CRM_Quality__c> mtBrandQualityMap = new Map<Id, EUR_CRM_Quality__c>();
                    if (sourceMapPerMechanicType.containsKey(key) && sourceMap.containsKey(bqKey)){
                            mtBrandQualityMap = sourceMapPerMechanicType.get(key);
                            mtBrandQualityMap.put(bqKey, sourceMap.get(bqKey));

                            sourceMapPerMechanicType.put(key, mtBrandQualityMap);
                    }
            }

            return sourceMapPerMechanicType;
    }


    private Map<Id, EUR_CRM_Brand__c> retrieveItemSourceBrands(EUR_CRM_Contract__c contractObj, Set<Id>specificBrands){
        Map <Id, EUR_CRM_Brand__c> brandMap = new Map <Id, EUR_CRM_Brand__c>();
        if (contractObj != null){
            brandMap = new Map <Id, EUR_CRM_Brand__c>(
                                    [SELECT Id, Name,
                                    EUR_CRM_Brand_Code__c,
                                    EUR_CRM_Country_Code__c,
                                    EUR_CRM_Is_Competitor__c
                                    FROM  EUR_CRM_Brand__c
                                    WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                    AND EUR_CRM_Is_Competitor__c=false
                                    AND EUR_CRM_Active__c=true
                                    AND Id IN: specificBrands
                                    ]);
        }
        System.debug('FLAG - retrieveItemSourceBrands'+ specificBrands+'--'+brandMap);
        return brandMap;
    }

    private Map<Id, EUR_CRM_Brand__c> retrieveItemSourceBrands(EUR_CRM_Contract__c contractObj){
        Map <Id, EUR_CRM_Brand__c> brandMap = new Map <Id, EUR_CRM_Brand__c>();
        if (contractObj != null){
            brandMap = new Map <Id, EUR_CRM_Brand__c>(
                                    [SELECT Id, Name,
                                    EUR_CRM_Brand_Code__c,
                                    EUR_CRM_Country_Code__c,
                                    EUR_CRM_Is_Competitor__c
                                    FROM  EUR_CRM_Brand__c
                                    WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                    AND EUR_CRM_Is_Competitor__c=false
                                    AND EUR_CRM_Active__c=true
                                    ]);
        }
        return brandMap;
    }

    private Map<Id, EUR_CRM_Quality__c> retrieveItemSourceBrandQualities (EUR_CRM_Contract__c contractObj, Set<Id>specificBQ){
        Map <Id, EUR_CRM_Quality__c> brandQualityMap = new Map <Id, EUR_CRM_Quality__c>();
        if (contractObj != null){
            brandQualityMap = new Map <Id, EUR_CRM_Quality__c>(
                                        [SELECT Id, Name,
                                        EUR_CRM_Quality_Code__c,
                                        EUR_CRM_Brand__c, EUR_CRM_Brand__r.Name,
                                        EUR_CRM_Quality_Description__c, EUR_CRM_Country_Code__c,
                                        EUR_CRM_Quality_Is_Competitor__c,
                                        EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                        EUR_CRM_Brand__r.EUR_CRM_Category__r.Name
                                        FROM EUR_CRM_Quality__c
                                        WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                        AND EUR_CRM_Quality_Is_Competitor__c = false
                                        AND Id =: specificBQ
                                        ]);
        }
        return brandQualityMap;
    }

    private Map<Id, EUR_CRM_Quality__c> retrieveItemSourceBrandQualities (EUR_CRM_Contract__c contractObj){
        Map <Id, EUR_CRM_Quality__c> brandQualityMap = new Map <Id, EUR_CRM_Quality__c>();
        if (contractObj != null){
            brandQualityMap = new Map <Id, EUR_CRM_Quality__c>(
                                        [SELECT Id, Name,
                                        EUR_CRM_Quality_Code__c,
                                        EUR_CRM_Brand__c, EUR_CRM_Brand__r.Name,
                                        EUR_CRM_Quality_Description__c, EUR_CRM_Country_Code__c,
                                        EUR_CRM_Quality_Is_Competitor__c,
                                        EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                        EUR_CRM_Brand__r.EUR_CRM_Category__r.Name
                                        FROM EUR_CRM_Quality__c
                                        WHERE EUR_CRM_Country_Code__c =: contractObj.EUR_CRM_Country_Code__c
                                        AND EUR_CRM_Quality_Is_Competitor__c = false
                                        AND EUR_CRM_Active__c = true
                                        ]);
        }
        System.debug(brandQualityMap);
        return brandQualityMap;
    }

    public List<SelectOption> getPouringRefundPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Pouring Refund').mechanicType.Id);
        return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Pouring Refund'), false);
    }

    public List<SelectOption> getOtherPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Others').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Others'),
			mechanicTypeWrapperMap.get('Others').currentContractActivityItem.contractActivityItem.EUR_CRM_Is_PR_Other__c);
    }

    public List<SelectOption> getDrinksMenuPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Drinks Menu').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Drinks Menu'), false);
    }

    public List<SelectOption> getWKZFixAmountPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('WKZ Fix Amount').mechanicType.Id);
        return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('WKZ Fix Amount'), false);
    }

    public List<SelectOption> getNapkinsPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Napkins').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Napkins'), false);
    }

    public List<SelectOption> getEventsPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Events').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Events'),
			mechanicTypeWrapperMap.get('Events').currentContractActivityItem.contractActivityItem.EUR_CRM_Is_PR_Event__c);
    }

    public List<SelectOption> getTrainingPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Training').mechanicType.Id);
		System.debug('\n mechanicTypeWrapperMap.size() => ' + mechanicTypeWrapperMap.size() + '\n');
		System.debug('\n mechanicTypeWrapperMap => ' + JSON.serializePretty(mechanicTypeWrapperMap) + '\n');
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Training'),
			mechanicTypeWrapperMap.get('Training').currentContractActivityItem.contractActivityItem.EUR_CRM_Is_PR_Training__c);
    }

    public List<SelectOption> getVisibilityPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('Visibility/ Branding').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('Visibility/ Branding'), false);
    }

    public List<SelectOption> getPOSMaterialPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('POS Material').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('POS Material'), false);
    }

    public List<SelectOption> getPOSWKZPaymentTermOptions() {
//        return retrieveListValues(mechanicTypeWrapperMap.get('POS WKZ').mechanicType.Id);
		return restrictPaymentTermsPicklist(mechanicTypeWrapperMap.get('POS WKZ'), false);
    }

    private Map<String, ContractFormSettingWrapper> getContractFormSettingWrapperByMTextId() {
        Map<String, ContractFormSettingWrapper> contractFormSetWrapperByMTextId = new Map<String, ContractFormSettingWrapper>();
        List<EUR_CRM_CTM_Contract_forms_setting__mdt> contractFormSettings = this.selectContractFormSettingsWhereCountryCode();
		System.debug('\n contractFormSettings => ' + JSON.serializePretty(contractFormSettings) + '\n');
        if (contractFormSettings.isEmpty()) { return new Map<String, ContractFormSettingWrapper>(); }

        for (EUR_CRM_CTM_Contract_forms_setting__mdt cfs : contractFormSettings) {
            contractFormSetWrapperByMTextId.put(cfs.EUR_CRM_Mechanic_Type_External_ID__c, new ContractFormSettingWrapper(cfs));
        }
        return contractFormSetWrapperByMTextId;
    }

    private List<SelectOption> restrictPaymentTermsPicklist(MechanicTypeWrapper mechTypeWrap, Boolean isEventOrTrainingOrOther) {
		ContractFormSettingWrapper cfsWrap = contractFormSettingWrapperByMTextId.get(mechTypeWrap.mechanicType.EUR_CRM_External_ID__c);
        System.debug('\n cfsWrap => ' + JSON.serializePretty(cfsWrap) + '\n');
		if (cfsWrap == null) { return new List<SelectOption>(); }

		List<SelectOption> paymentTermsOptions = new List<SelectOption>();

		if (isEventOrTrainingOrOther) {
            paymentTermsOptions = this.getPaymentTermOptions(cfsWrap.eventOrTrainingOrOtherPaymentTerms);
		} else {
            paymentTermsOptions = this.getPaymentTermOptions(cfsWrap.availablePaymentTerms);
		}
        System.debug('\n paymentTermsOptions => ' + paymentTermsOptions + '\n');
        return paymentTermsOptions;
    }

	private List<SelectOption> getPaymentTermOptions(List<String> paymentTerms) {
		List<SelectOption> paymentTermOptions = new List<SelectOption>();
        for (PicklistEntry ptPicklistEntry : paymentTermPicklistEntries) {
            for (String paymentTerm : paymentTerms) {
                if (ptPicklistEntry.getValue().equalsIgnoreCase(paymentTerm)) {
//                    paymentTermOptions.add(new SelectOption(paymentTerm, paymentTerm));
                    paymentTermOptions.add(new SelectOption(ptPicklistEntry.getValue(), ptPicklistEntry.getLabel()));
                }
            }
        }
		return paymentTermOptions;
	}

//	private List<SelectOption> retrieveListValues(String mechanicTypeId) {
//        List<SelectOption> paymentTermOptions = new List<SelectOption>();
//
//        // String query = 'SELECT EUR_CRM_Payment_Term__c, EUR_CRM_Mechanic_Type__c FROM EUR_CRM_Payment_Term_to_MT_Mapping__c'
//        String query = 'SELECT EUR_CRM_Payment_Term__c, EUR_CRM_Payment_Term__r.EUR_CRM_Payment_Term_Unique_Value_Name__c, EUR_CRM_Mechanic_Type__c, ' +
//                        'EUR_CRM_Payment_Term__r.EUR_CRM_Payment_Term_Picklist_Value__c ' +
//                        'FROM EUR_CRM_Payment_Term_to_MT_Mapping__c ' +
//                        'WHERE EUR_CRM_Mechanic_Type__c = :mechanicTypeId ' +
//                        'ORDER BY EUR_CRM_Payment_Term__r.EUR_CRM_Payment_Term_Unique_Value_Name__c ASC';
//
//        paymentTermOptions.add(new SelectOption(
//            'None', 'None'
//        ));
//
//        for(EUR_CRM_Payment_Term_to_MT_Mapping__c paymentTermMapping: Database.query(query)) {
//            paymentTermOptions.add(new SelectOption(
//                paymentTermMapping.EUR_CRM_Payment_Term__r.EUR_CRM_Payment_Term_Picklist_Value__c,
//                paymentTermMapping.EUR_CRM_Payment_Term__r.EUR_CRM_Payment_Term_Picklist_Value__c
//            ));
//        }
//
//        return paymentTermOptions;
//    }

    private List<EUR_CRM_CTM_Contract_forms_setting__mdt> selectContractFormSettingsWhereCountryCode() {
        return [
            SELECT
                Id,
                EUR_CRM_Mechanic_Type_External_ID__c,
                EUR_CRM_Available_Payment_Terms_Values__c,
                EUR_CRM_Event_Payment_Terms__c
            FROM EUR_CRM_CTM_Contract_forms_setting__mdt
            WHERE EUR_CRM_Country_Code__c = 'DE'
        ];
    }

    private Boolean isFlagship(EUR_CRM_Contract__c contractObj){
        return ((contractObj.EUR_CRM_Contract_Type__c.equalsIgnoreCase(FLAGSHIP_CONTRACT))?true:false);
    }

    private List<SelectOption> setFlagshipBrandSelection(Map<Id, EUR_CRM_Brand__c> brandMap){
        List<SelectOption> flagshipBrandSelection = new List<SelectOption>();

        //flagshipBrandSelection.add(new SelectOption('', '-None-'));
        for (EUR_CRM_Brand__c brand: brandMap.values()){
            flagshipBrandSelection.add(new SelectOption(brand.Id, brand.Name));
        }

        return flagshipBrandSelection;
    }

    private Map<Id, EUR_CRM_Brand__c> trimFlagshipBrands(Map<Id, EUR_CRM_Brand__c> sourceReference, Id selectedItem){
        Map<Id, EUR_CRM_Brand__c> trimmedSource = new Map<Id, EUR_CRM_Brand__c>();
        trimmedSource.putAll(sourceReference);
        for (Id key: sourceReference.keySet()){
                if (key != selectedItem){
                        trimmedSource.remove(key);
                }
        }
        return trimmedSource;
    }

        private Map<Id, EUR_CRM_Quality__c> trimFlagshipBrandQualities(Map<Id, EUR_CRM_Quality__c> sourceReference, Id selectedItem){
        Map<Id, EUR_CRM_Quality__c> trimmedSource = new Map<Id, EUR_CRM_Quality__c>();
        trimmedSource.putAll(sourceReference);
        for (EUR_CRM_Quality__c val: sourceReference.values()){
                Id key = val.EUR_CRM_Brand__c;
                if (key != selectedItem){
                        trimmedSource.remove(val.Id);
                }
        }
        return trimmedSource;
    }

    private Decimal calculateRemainingUserBudgetTotal(){
        Decimal remainingBudgetBalance = 0;

        if (contractObj.EUR_CRM_Budget__c != null){
        AggregateResult[] groupedResults = [SELECT SUM(EUR_CRM_DE_Deductible_Contract_Total__c)sumDeductibleAmt FROM EUR_CRM_Contract__c
                                                WHERE EUR_CRM_Contract_Approved_Date__c=null
                                                AND CreatedById=:contractObj.CreatedById
                                                AND EUR_CRM_Budget__c =: contractObj.EUR_CRM_Budget__c];
        Decimal sumDeductibleAmt = (Decimal)groupedResults[0].get('sumDeductibleAmt');
        //calculate
        sumDeductibleAmt = (sumDeductibleAmt==null)?0:sumDeductibleAmt;
        remainingBudgetBalance = contractObj.EUR_CRM_Budget__r.EUR_CRM_Current_Balance__c - sumDeductibleAmt;
        }
        return remainingBudgetBalance;
    }

    private class ContractFormSettingWrapper {
        private EUR_CRM_CTM_Contract_forms_setting__mdt contractFormsSetting;
        private String mechTypeExtId;
        private List<String> availablePaymentTerms;
        private List<String> eventOrTrainingOrOtherPaymentTerms;

        private ContractFormSettingWrapper(EUR_CRM_CTM_Contract_forms_setting__mdt contractFormsSetting) {
            this.contractFormsSetting = contractFormsSetting;
            this.mechTypeExtId = contractFormsSetting.EUR_CRM_Mechanic_Type_External_ID__c;
            this.availablePaymentTerms = this.extractFieldValues(contractFormsSetting.EUR_CRM_Available_Payment_Terms_Values__c);
            this.eventOrTrainingOrOtherPaymentTerms = this.extractFieldValues(contractFormsSetting.EUR_CRM_Event_Payment_Terms__c);
        }

        private List<String> extractFieldValues(String fieldValue) {
			if (String.isBlank(fieldValue)) { return new List<String>(); }

            List<String> fieldValues = new List<String>();
            for (String val : fieldValue.split(',')) {
                fieldValues.add(val.trim());
            }
            return fieldValues;

        }
    }

    public static String getThousandSep(){
        Decimal value = 1000.10;
        String formattedValue = value.format();
        return formattedValue.substring(1,2);
    }

    public static String getDecimalSep(){
        Decimal value = 1000.10;
        String formattedValue = value.format();
        return formattedValue.substring(5,6);
    }

    public class MechanicTypeWrapper{
        //Mechanic or Contract Activity Variables
        public EUR_CRM_Mechanic_Type__c mechanicType{get;set;}
        public String mechanicTypeName {get;set;}
        public Id mechanicTypeId {get;set;}
        public String mechanicTypeGroupingName{get;set;}
        public String mechanicTypeTranslatedName {get;set;}

        //Contract Content
        //Key: contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c
        public Map<String, ContractActivityItemWrapper> contractActivityItems{get;set;}{contractActivityItems= new Map<String, ContractActivityItemWrapper>();}
        public ContractActivityItemWrapper currentContractActivityItem {get;set;}{currentContractActivityItem = null;}
        public Boolean isEditMode{get{return ((currentContractActivityItem!=null)?true:false);}}
        //Map<String, Map<String, EUR_CRM_Contract_Product_Item__c>> contractProductItems{get;set;}{contractProductItems = new Map<String, Map<String, EUR_CRM_Contract_Product_Item__c>>();} //contractActivityItem.EUR_CRM_Mechanic_Type__c +'-'+ contractActivityItem.EUR_CRM_Name__c

        //public Map<Id, EUR_CRM_Brand__c> brandItems {get;set;}{brandItems = new Map<Id, EUR_CRM_Brand__c>();}
        //public Map<Id, EUR_CRM_Quality__c> brandQualityItems {get;set;}{brandQualityItems = new Map<Id, EUR_CRM_Quality__c>();}

        public Set<Id> deletedContractActivityItems {get;set;}{deletedContractActivityItems = new Set<Id>();}

        public Set<String> contractActivityNameSet{get{
            Set<String> caNames = new Set<String>();//Set of Uppercase string
            for(ContractActivityItemWrapper caWrap: contractActivityItems.values()){
                    if (caWrap.contractActivityItem.EUR_CRM_Name__c != null)
                            caNames.add(caWrap.contractActivityItem.EUR_CRM_Name__c.toUpperCase());
            }

            return caNames;
        }}

        public Integer lastContractActivityCount{get{
            List<Integer> caCount = new List<Integer>();
            for(String key: contractActivityItems.keySet()){
                    caCount.add(Integer.valueOf(key));
            }
            caCount.sort();
            return (caCount.size()==0)?0:caCount.get((caCount.size()-1));
        }}

        public Integer nextContractActivityIndex{get{
            List<Integer> caCount = new List<Integer>();
            for(String key: contractActivityItems.keySet()){
                caCount.add(Integer.valueOf(key));
            }
            caCount.sort();
            return (caCount.size()==0)?0:caCount.get(caCount.size()-1)+1;
        }}

        public Double total{
            get{
                    Double caTotal = 0;
                    for (ContractActivityItemWrapper caWrap: contractActivityItems.values()){
                            Double amount = (this.mechanicType.EUR_CRM_Has_Lump_Sum__c)?caWrap.contractActivityItem.EUR_CRM_Amount__c:caWrap.productItemsTotal;
                            amount = (amount==null)?0:amount;
                            caTotal += amount;
                    }
                    return caTotal;
            }
        }

        public Double deductibleTotal{
            get{
                    Double caTotal = 0;
                    for (ContractActivityItemWrapper caWrap: contractActivityItems.values()){
                            if(caWrap.contractActivityItem.EUR_CRM_Exclude_Budget_Deduction__c==false){
                                    Double amount = (this.mechanicType.EUR_CRM_Has_Lump_Sum__c)?caWrap.contractActivityItem.EUR_CRM_Amount__c:caWrap.productItemsTotal;
                                    amount = (amount==null)?0:amount;
                                    caTotal += amount;
                            }
                    }
                    return caTotal;
            }
        }



        public Boolean hasProductItems{
            get{
                    Boolean hasItems = false;
                    for (ContractActivityItemWrapper caWrap: contractActivityItems.values()){
                            if (caWrap.productItemsCount!=null && caWrap.productItemsCount>0){
                                    hasItems = true;
                                    break;
                            }
                    }

                    return hasItems;
            }
        }

        public Double TotalByCurrentFY(){
            Double caTotal = 0;
            Date FiscalYear = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
            Date NextFiscalYear = FiscalYear.addYears(1);
            Date FiscalYearEnd = FiscalYear.addYears(1);

            System.Debug('FiscalYear:' + FiscalYear);
            System.Debug('NextFiscalYear:' + FiscalYear);
            System.Debug('FiscalYearEnd:' + FiscalYearEnd);



            for (ContractActivityItemWrapper caWrap: contractActivityItems.values()){
                Date ActivityStartDate = caWrap.contractActivityItem.EUR_CRM_Start_Date__c;
                Date ActivityEndDate = caWrap.contractActivityItem.EUR_CRM_End_Date__c;

                System.Debug('@@@ActivityStartDate:' + ActivityStartDate);
                System.Debug('@@@ActivityEndDate:' + ActivityEndDate);
                Double amount = (this.mechanicType.EUR_CRM_Has_Lump_Sum__c)?caWrap.contractActivityItem.EUR_CRM_Amount__c:caWrap.productItemsTotal;


                If(ActivityStartDate >= FiscalYear && ActivityEndDate < NextFiscalYear){
                    System.Debug('@@@Take All:' + amount);
                    //Within FY1, Take all amount
                }Else If(ActivityStartDate >= NextFiscalYear){
                    System.Debug('@@@Take None');

                    //In FY2, don't take any
                    amount = 0;
                }Else{

                    System.Debug('@@@Take Part.1:' + amount);
                    //Across FY1 and FY2
                    Integer totalMonths = ActivityStartDate.monthsBetween(ActivityEndDate) + 1;
                    Integer months_FY1 = ActivityStartDate.monthsBetween(FiscalYearEnd);
                    Integer months_FY2 = ActivityEndDate.monthsBetween(NextFiscalYear);
                    System.Debug('@@@Take Part Month:' + months_FY1 + ':' + totalMonths);
                    amount = (((Decimal)months_FY1)/totalMonths) * amount;
                    System.Debug('@@@Take Part.2:' + amount);
                }

                amount = (amount==null)?0:amount;
                caTotal += amount;
            }

            System.Debug('@@@Total:' +caTotal );
            return caTotal;
        }

        public Double DeductibleTotalByCurrentFY(){
            Double caTotal = 0;
            Date FiscalYear = EUR_CRM_BudgetUtil.retrieveFiscalYearStart();
            Date NextFiscalYear = FiscalYear.addYears(1);
            Date FiscalYearEnd = FiscalYear.addYears(1);


            for (ContractActivityItemWrapper caWrap: contractActivityItems.values()){
                Date ActivityStartDate = caWrap.contractActivityItem.EUR_CRM_Start_Date__c;
                Date ActivityEndDate = caWrap.contractActivityItem.EUR_CRM_End_Date__c;
                System.Debug('@@@ActivityStartDate:' + ActivityStartDate);
                System.Debug('@@@ActivityEndDate:' + ActivityEndDate);

                if(caWrap.contractActivityItem.EUR_CRM_Exclude_Budget_Deduction__c==false){
                    Double amount = (this.mechanicType.EUR_CRM_Has_Lump_Sum__c)?caWrap.contractActivityItem.EUR_CRM_Amount__c:caWrap.productItemsTotal;
                    If(ActivityStartDate >= FiscalYear && ActivityEndDate < NextFiscalYear){
                        System.Debug('@@@Take All:' + amount);
                        //Within FY1, Take all amount
                    }Else If(ActivityStartDate >= NextFiscalYear){
                        System.Debug('@@@Take None');
                        //In FY2, don't take any
                        amount = 0;
                    }Else{
                        System.Debug('@@@Take Part.1:' + amount);

                        //Across FY1 and FY2
                        Integer totalMonths = ActivityStartDate.monthsBetween(ActivityEndDate) + 1;
                        Integer months_FY1 = ActivityStartDate.monthsBetween(FiscalYearEnd);
                        Integer months_FY2 = ActivityEndDate.monthsBetween(NextFiscalYear);
                        System.Debug('@@@Take Part Month:' + months_FY1 + ':' + totalMonths);
                        amount = (((Decimal)months_FY1)/totalMonths) * amount;
                        System.Debug('@@@Take Part.2:' + amount);
                    }
                    amount = (amount==null)?0:amount;
                    caTotal += amount;
                }
            }
            System.Debug('@@@Total Deduct<<<<' + caTotal);
            return caTotal;
        }

        public MechanicTypeWrapper(String mechanicTypeName){
            this.mechanicTypeName = mechanicTypeName;
        }

        public MechanicTypeWrapper(EUR_CRM_Mechanic_Type__c mechanicType){
            this.mechanicType = mechanicType;
            //this.mechanicTypeName = mechanicType.Name;
            this.mechanicTypeName = mechanicType.EUR_CRM_Mechanic_Type_Name_English__c;
            this.mechanicTypeTranslatedName = mechanicType.Name;
            this.mechanicTypeId = mechanicType.Id;
            this.mechanicTypeGroupingName = mechanicType.EUR_CRM_Grouping_Name__c;
        }

        public void resetCurrentContractActivity(){
            this.currentContractActivityItem = null;
        }
    }

    public class ContractActivityItemWrapper{
        private Integer descriptionCount {get;set;}{descriptionCount=0;}

        public EUR_CRM_Contract_Activity_Item__c contractActivityItem {get;set;}
        public Double total {get;set;}
        public Double totalPouringRefund {get;set;}
        public String mapKey;

        public Map<String, EUR_CRM_Contract_Product_Item__c> contractProductItems{get;set;}{contractProductItems = new Map<String, EUR_CRM_Contract_Product_Item__c>();} //Brand or Brand Quality Id or Description

        public Set<Id> deletedContractProductItems {get;set;}{deletedContractProductItems = new Set<Id>();}

        public Map<Id, EUR_CRM_Brand__c> brandItems {get;set;}{brandItems = new Map<Id, EUR_CRM_Brand__c>();}
        public Map<Id, EUR_CRM_Quality__c> brandQualityItems {get;set;}{brandQualityItems = new Map<Id, EUR_CRM_Quality__c>();}

        public Boolean isNew {get;set;}{isNew = true;}
        public Boolean isOldContract {get;set;}{isOldContract = false;}

        public Double productItemsTotal{
            get{
                    Double total = 0;
                    for (EUR_CRM_Contract_Product_Item__c prodItem: contractProductItems.values()){
                            prodItem.EUR_CRM_Quantity__c = (prodItem.EUR_CRM_Quantity__c!=null)?prodItem.EUR_CRM_Quantity__c:0;
                            prodItem.EUR_CRM_Amount__c = (prodItem.EUR_CRM_Amount__c!=null)?prodItem.EUR_CRM_Amount__c:0;
                        total += (prodItem.EUR_CRM_Quantity__c * prodItem.EUR_CRM_Amount__c);
                    }
                    return total;
            }
        }

        public Integer productItemsCount{
            get{
                    return (contractProductItems==null)?0:contractProductItems.size();
            }
        }

        public String assignDescriptionId(){
            String descId = DESCRIPTION_PREFIX + descriptionCount;
            descriptionCount++;

            return descId;
        }

        public ContractActivityItemWrapper(EUR_CRM_Contract_Activity_Item__c contractActivityItem){
            this.contractActivityItem = contractActivityItem;
            this.totalPouringRefund = contractActivityItem.EUR_CRM_Total_Pouring_Refund__c;
            if(contractActivityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c != null && !contractActivityItem.EUR_CRM_Mechanic_Type__r.EUR_CRM_External_ID__c.startsWith('EUR_')) {
                this.isOldContract = true;
            }
        }

        public Set<Id> retrieveExistingBrands(){
            Set<Id> existingSet = new Set<Id>();
            for (EUR_CRM_Contract_Product_Item__c cpi: contractProductItems.values()){
                    if (cpi.EUR_CRM_Brand__c != null){
                            existingSet.add(cpi.EUR_CRM_Brand__c);
                    }
            }
            return existingSet;
        }

        public Set<Id> retrieveExistingBrandQualities(){
            Set<Id> existingSet = new Set<Id>();
            for (EUR_CRM_Contract_Product_Item__c cpi: contractProductItems.values()){
                    if (cpi.EUR_CRM_Brand_Quality__c != null){
                            existingSet.add(cpi.EUR_CRM_Brand_Quality__c);
                    }
            }
            return existingSet;
        }
    }
}