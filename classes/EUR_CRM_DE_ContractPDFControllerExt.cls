public with sharing class EUR_CRM_DE_ContractPDFControllerExt{
    private ApexPages.StandardController standardController {get;set;}
    private EUR_CRM_DE_Contract_Class contractUtilClass{get;set;}
    
    private final String POURING_REFUND = 'Pouring Refund';
    private final String OTHERS = 'Others';
    private final String DRINKS_MENU = 'Drinks Menu';
    private final String WKZ_FIX_AMOUNT = 'WKZ Fix Amount';
    private final String NAPKINS = 'Napkins';
    private final String EVENTS = 'Events';
    private final String TRAINING = 'Training';
    private final String VISIBILITY = 'Visibility/ Branding';
    private final String POS_MATERIAL = 'POS Material';
    private final String POS_WKZ = 'POS WKZ';
    private final Set<String> DE_MECHANIC_TYPE_NAMES = new Set<String>{POURING_REFUND, OTHERS,
                                                        DRINKS_MENU, WKZ_FIX_AMOUNT, NAPKINS,
                                                        EVENTS, TRAINING, VISIBILITY, POS_MATERIAL,
                                                        POS_WKZ};
                                                    
    private final String ALL_BRANDS = 'All Brands';
    private final String ALL_BRAND_QUALITIES = 'All Brands Qualities';
    private final String ALL_OTHER_BRANDS = 'All Other Brands';
    private final String ALL_OTHER_BRAND_QUALITIES = 'All Other Brands Qualities';
    public static String DESCRIPTION_PREFIX = 'DESC--';
    
    public ContractWrapper contractWrapperObj {get;set;}
    public Contact contractContact {get;set;}
    
    public List<EUR_CRM_Contract_Product_Item__c> exclusivePouringRefundWKZ{
        get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            cpSet.addAll(contractWrapperObj.contractContentWrapperMap.get(POURING_REFUND).uniqueExclusiveContractProductSet);
            cpSet.addAll(contractWrapperObj.contractContentWrapperMap.get(WKZ_FIX_AMOUNT).uniqueExclusiveContractProductSet);
            
            System.debug('Flag - EXCLUSIVE POURING AND WKZ:' + cpSet);
            List<EUR_CRM_Contract_Product_Item__c> cpList = new List<EUR_CRM_Contract_Product_Item__c>();
            cpList.addAll(cpSet);
            return cpList;
        }
    }
    
    public List<EUR_CRM_Contract_Product_Item__c> nonExclusivePouringRefundWKZ{
        get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            cpSet.addAll(contractWrapperObj.contractContentWrapperMap.get(POURING_REFUND).uniqueNonExclusiveContractProductSet);
            cpSet.addAll(contractWrapperObj.contractContentWrapperMap.get(WKZ_FIX_AMOUNT).uniqueNonExclusiveContractProductSet);
            List<EUR_CRM_Contract_Product_Item__c> cpList = new List<EUR_CRM_Contract_Product_Item__c>();
            cpList.addAll(cpSet);
            return cpList;
    }
    }
    
    public EUR_CRM_DE_ContractPDFControllerExt(ApexPages.StandardController standardController){
        this.standardController = standardController;
        contractUtilClass = new EUR_CRM_DE_Contract_Class();
        EUR_CRM_Contract__c contractHeader = retrieveContractDetails(this.standardController.getId());
        EUR_CRM_Contract_Payment_Plan__c contractPaymentPlanHeader = retrieveContractPaymentPlan(this.standardController.getId());
        
        System.debug('Flag - DE Contract PDF - Contract Header:' + contractHeader);
        if (contractHeader != null){
            //Init Contract Contact
            //Update 10/17: Contract should get Account Contact instead of Contract's custom Contact field
            //Update 03/27: Contract should get EU Account Contact instead of Contract's custom Contact field
            contractContact = retrieveContact(contractHeader.EUR_CRM_Account__c);
        
            //Init Contract Wrapper Obj
            contractWrapperObj = new ContractWrapper(contractHeader, contractPaymentPlanHeader);
            
            //Init Focus Brands
            contractWrapperObj.focusBrandList.addAll(retrieveFocusBrands(contractHeader.Id).values());
            
            //Init Listing/Pouring
            contractWrapperObj.listingPouringList.addAll(retrieveListingPouring(contractHeader.Id).values());
            
            //Init Map
            for (String mtName : DE_MECHANIC_TYPE_NAMES){
               contractWrapperObj.contractContentWrapperMap.put(mtName, new ContractContentWrapper());
            }
            //Init Content
            initContractContent(contractHeader, contractWrapperObj);
            System.debug('Flag - DE Contract PDF - Contract Content:' + contractWrapperObj);
            //updateAllBrandsString();
        }
    }
    
    public Contact retrieveContact (Id accountId){
        if (accountId != null){
            /**
            Id standardAccountId = [SELECT EUR_CRM_Standard_Account__c FROM EUR_CRM_Account_Link__c WHERE EUR_CRM_EU_Account__c=:accountId].EUR_CRM_Standard_Account__c;
            
            List<Contact> contactList = new List<Contact>([SELECT Id, AccountId,
                                                        FirstName, LastName, Name,
                                                        Salutation, Title, EUR_CRM_Primary_Contact__c
                                                        FROM Contact WHERE AccountId =: standardAccountId]);
            **/
            //Update 03/27: Contract should get EU Account Contact instead of Contract's custom Contact field
            List<Contact> contactList = new List<Contact>([SELECT Id, AccountId,
                                                        FirstName, LastName, Name,
                                                        Salutation, Title, EUR_CRM_Primary_Contact__c
                                                        FROM Contact WHERE EUR_CRM_Account__c =: accountId]);                                       
            if (contactList.size() == 1){
                return contactList.get(0);
            }
            else if (contactList.size() > 1){
                Contact sContact = null;
                for (Contact contact: contactList){
                    if (contact.EUR_CRM_Primary_Contact__c){
                        sContact = contact;
                    }
                }
                return (sContact!=null)?sContact:contactList.get(0);
            }
        }
        return null;
    }
    
    public EUR_CRM_Contract__c retrieveContractDetails(Id contractId){
        if ( contractId != null){
            List<EUR_CRM_Contract__c> contractList = new List<EUR_CRM_Contract__c>([SELECT Id, Name,
                                            EUR_CRM_Country_Code__c, 
                                            EUR_CRM_Contract_Number__c,
                                            EUR_CRM_Customer_No__c, 
                                            EUR_CRM_Customer_No_ERP__c,
                                            EUR_CRM_Account__c, 
                                            EUR_CRM_Account__r.Name,
                                            EUR_CRM_Account__r.EUR_CRM_Street__c, 
                                            EUR_CRM_Account__r.EUR_CRM_Postal_Code__c,
                                            EUR_CRM_Account__r.EUR_CRM_City__c, 
                                            EUR_CRM_Account__r.EUR_CRM_Invoice_Street__c,
                                            EUR_CRM_Account__r.EUR_CRM_Invoice_Postal_Code__c, 
                                            EUR_CRM_Account__r.EUR_CRM_Invoice_City__c,
                                            EUR_CRM_Account__r.EUR_CRM_Comp_Establishment_Name_legally__c,
                                            EUR_CRM_Contact__c, 
                                            EUR_CRM_Contact__r.Salutation, EUR_CRM_Contact__r.Name, 
                                            EUR_CRM_Contact__r.FirstName, EUR_CRM_Contact__r.LastName,
                                            EUR_CRM_Contact__r.Title,
                                            EUR_CRM_Contract_Type__c, EUR_CRM_Contract_Sub_Type__c,                                         
                                            EUR_CRM_Start_Date__c, EUR_CRM_End_Date__c,
                                            EUR_CRM_Status__c, EUR_CRM_Active__c,
                                            EUR_CRM_Contract_Approved_Date__c, EUR_CRM_Payment_Method__c,EUR_CRM_Customer_Approved_Date__c,
                                            EUR_CRM_Total_Contract_Line_Items__c,
                                            EUR_CRM_DE_Actual_Contract_Total__c, EUR_CRM_DE_Deductible_Contract_Total__c,
                                            CreatedBy.Name, CreatedBy.Title, CreatedBy.MobilePhone,
                                            EUR_CRM_Flagship_Brand__c, EUR_CRM_Flagship_Brand__r.Name
                                            FROM EUR_CRM_Contract__c
                                            WHERE Id =: contractId]);
            if (contractList.size()>0){
                EUR_CRM_Contract__c contract = contractList.get(0);
                return contract;
            }
        }
        return null;
    }

    public EUR_CRM_Contract_Payment_Plan__c retrieveContractPaymentPlan (Id contractId) {
        if(contractId != null) {
            List<EUR_CRM_Contract_Payment_Plan__c> contractPaymentPlans = [SELECT Id,
                                                                            EUR_CRM_Account__c, EUR_CRM_Contract__c,
                                                                            EUR_CRM_Contract__r.Name,
                                                                            EUR_CRM_Contract_End_Date__c,
                                                                            EUR_CRM_Contract_Start_Date__c
                                                                           FROM EUR_CRM_Contract_Payment_Plan__c
                                                                           WHERE EUR_CRM_Contract__c = :contractId];

            System.debug(contractPaymentPlans);
            if(contractPaymentPlans.size() > 0) {
                return contractPaymentPlans.get(0);
            }
        }

        return null;
    }
    
    public void initContractContent(EUR_CRM_Contract__c contractObj, ContractWrapper contractWrapper){
        Map<String, ContractContentWrapper> contractContentWrapperMap = contractWrapper.contractContentWrapperMap;//new Map<String, ContractContentWrapper>();
        
        System.debug('Flag - DE Contract PDF - Util Class:' + contractUtilClass);
        Map <Id, EUR_CRM_Mechanic_Type__c> mechanicTypeMap = contractUtilClass.retrieveMechanicTypes(contractObj);
        //Key: Mechanic Type ID
        Map<Id, Map<String, EUR_CRM_Contract_Activity_Item__c>> contractActivityMap = contractUtilClass.retrieveContractActivityItems(contractObj);
        Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> contractProductMap = contractUtilClass.retrieveContractProductItems(contractObj);
        
        System.debug('Flag - DE Contract PDF - Mechanic Type Map:' + mechanicTypeMap);
        System.debug('Flag - DE Contract PDF - Contract Activity Map:' + contractActivityMap);
        System.debug('Flag - DE Contract PDF - Contract Product Map:' + contractProductMap);
        
        for (EUR_CRM_Mechanic_Type__c mechanicType: mechanicTypeMap.values()){
            ContractContentWrapper contractContentWrap;
            if (contractActivityMap.containsKey(mechanicType.Id)){
                contractContentWrap = new ContractContentWrapper(mechanicType, contractActivityMap.get(mechanicType.Id).values());
            }else{
                contractContentWrap = new ContractContentWrapper(mechanicType);
            }
            contractContentWrapperMap.put(mechanicType.EUR_CRM_Mechanic_Type_Name_English__c, contractContentWrap);
            system.debug('### mech name: ' + mechanicType.EUR_CRM_Mechanic_Type_Name_English__c);
            //contractContentWrapperMap.put(mechanicType.Name, contractContentWrap);
            //system.debug('### mech name: ' + mechanicType.Name);
        }
        
        //Iterate Contract Product, associate with Contract Activity Wrapper
        for (String cpKey: contractProductMap.keySet()){
            for (EUR_CRM_Contract_Product_Item__c contractProduct: contractProductMap.get(cpKey).values()){
                //String mechanicTypeName = contractProduct.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.Name;
                String mechanicTypeName = contractProduct.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c;
                Id contractActivityId = contractProduct.EUR_CRM_Contract_Activity_Item__c;
                if (contractContentWrapperMap.containsKey(mechanicTypeName)){
                    ContractContentWrapper ccWrap = contractContentWrapperMap.get(mechanicTypeName);
                    if (ccWrap.contractActivityMap!=null && ccWrap.contractActivityMap.containsKey(contractActivityId)){
                        ccWrap.contractActivityMap.get(contractActivityId).contractProductMap.put(contractProduct.Id, contractProduct.clone(false,true,false,false));
                    }
                }
            }
        }
        
        //return contractContentWrapperMap;
    }
    
    private Map<Id, EUR_CRM_Contract_Listing_Pouring__c> retrieveListingPouring(Id contractObjId){
        Map<Id, EUR_CRM_Contract_Listing_Pouring__c> listingPouringMap = new Map<Id, EUR_CRM_Contract_Listing_Pouring__c>();
        
        List<EUR_CRM_Contract_Listing_Pouring__c> listingPouringList =  [SELECT Id, Name,
                                                                EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality__r.Name,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__c, 
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                                                EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                                                                EUR_CRM_Contract__c, 
                                                                EUR_CRM_Listing__c, EUR_CRM_Pouring__c,
                                                                EUR_CRM_Name_Reference__c
                                                                FROM EUR_CRM_Contract_Listing_Pouring__c
                                                                WHERE EUR_CRM_Contract__c=:contractObjId ORDER BY EUR_CRM_Brand_Quality__r.Name];
         if(listingPouringList != null && listingPouringList.size()> 0)                                                       
        for (EUR_CRM_Contract_Listing_Pouring__c listingPouring:listingPouringList)
        {
            listingPouring.EUR_CRM_Name_Reference__c = listingPouring.EUR_CRM_Brand_Quality__r.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
            listingPouring.EUR_CRM_Brand_Quality__r.Name = (listingPouring.EUR_CRM_Brand_Quality__r.Name == ALL_BRAND_QUALITIES && listingPouringList.size()>1)?ALL_OTHER_BRAND_QUALITIES:listingPouring.EUR_CRM_Brand_Quality__r.Name;
            listingPouringMap.put(listingPouring.EUR_CRM_Brand_Quality__c, listingPouring);
        }
        
        return listingPouringMap;
    }
    
    private Map<Id, EUR_CRM_Contract_Focus_Brand__c> retrieveFocusBrands(Id contractObjId){
        Map<Id, EUR_CRM_Contract_Focus_Brand__c> focusBrands = new Map<Id, EUR_CRM_Contract_Focus_Brand__c>();
        
        List<EUR_CRM_Contract_Focus_Brand__c> focusBrandList = [SELECT Id, Name,  EUR_CRM_Contract__c, EUR_CRM_Brand__c,


                                                        EUR_CRM_Brand__r.Name,
                                                        EUR_CRM_Name_Reference__c 
                                                        FROM EUR_CRM_Contract_Focus_Brand__c
                                                        WHERE EUR_CRM_Contract__c =: contractObjId ];
        if(focusBrandList != null && focusBrandList.size()>0)
        for (EUR_CRM_Contract_Focus_Brand__c focusBrand : focusBrandList)
        {
            focusBrand.EUR_CRM_Name_Reference__c = (focusBrand.EUR_CRM_Name_Reference__c == null) ? focusBrand.EUR_CRM_Brand__r.Name : focusBrand.EUR_CRM_Name_Reference__c;
            
            focusBrand.EUR_CRM_Brand__r.Name = (focusBrand.EUR_CRM_Brand__r.Name == ALL_BRANDS && focusBrandList.size() > 1)?ALL_OTHER_BRANDS:focusBrand.EUR_CRM_Brand__r.Name;

            focusBrands.put(focusBrand.EUR_CRM_Brand__c, focusBrand);
        }
        System.debug('Flag - Focus Brand Component - Existing Focus Brands:' + focusBrands);
        return focusBrands;
    }
    
    public Map<String, Map <String, EUR_CRM_Contract_Product_Item__c>> retrieveContractProductItems(EUR_CRM_Contract__c contractObj){
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
                                                                WHERE EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Contract__c=:contractObj.Id ])
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

    public String getDynamicFormatString()
    {
        Decimal value = 1000.10;
        String formattedValue = value.format();
        String thousandSep = formattedValue.substring(1,2);
        String decimalSep = formattedValue.substring(5,6);
        //return '{0,number,#'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'###'+thousandSep+'##0'+decimalSep+'00}';
        return '{0,number,#,###,###,###,###,##0.00}';
    }

    
    public class ContractWrapper{
        public EUR_CRM_Contract__c contractHeader{get;set;}
        public EUR_CRM_Contract_Payment_Plan__c contractPaymentPlan {get; set;}
        public Map<String, ContractContentWrapper> contractContentWrapperMap{get;set;}{contractContentWrapperMap = new Map<String, ContractContentWrapper> ();}
        
        public List<EUR_CRM_Contract_Focus_Brand__c> focusBrandList {get;set;}{focusBrandList = new List<EUR_CRM_Contract_Focus_Brand__c>();}
        public Integer focusBrandListSize {get{return (focusBrandList==null)?0:focusBrandList.size();}}
        
        public List<EUR_CRM_Contract_Listing_Pouring__c> listingPouringList {get;set;} {listingPouringList = new List<EUR_CRM_Contract_Listing_Pouring__c>();}
        public List<EUR_CRM_Contract_Listing_Pouring__c> listingList {get{
            List<EUR_CRM_Contract_Listing_Pouring__c> listing = new List<EUR_CRM_Contract_Listing_Pouring__c>();
            for (EUR_CRM_Contract_Listing_Pouring__c lp: listingPouringList){
                if (lp.EUR_CRM_Listing__c){
                    listing.add(lp);
                }
            }
            return listing;
        }}
        public List<EUR_CRM_Contract_Listing_Pouring__c> pouringList {get{
            List<EUR_CRM_Contract_Listing_Pouring__c> pouring = new List<EUR_CRM_Contract_Listing_Pouring__c>();
            for (EUR_CRM_Contract_Listing_Pouring__c lp: listingPouringList){
                if (lp.EUR_CRM_Pouring__c){
                    pouring.add(lp);
                }
            }
            return pouring;
        }}
        
        public Integer listingPouringListSize{get{
            return (listingPouringList==null)?0:listingPouringList.size();
        }}
        public Integer listingListSize{get{
            return (listingList==null)?0:listingList.size();
        }}
        public Integer pouringListSize{get{
            Integer x = (pouringList==null)?0:pouringList.size();
            system.debug('woot' + x);
            return (pouringList==null)?0:pouringList.size();
        }}

        public String totalAmount { get{
            // Loop through all mechanic types and get the amount for each payment plan period
            Decimal totalAmount = 0;

            for(ContractContentWrapper ccw : contractContentWrapperMap.values()) {
                System.debug(ccw.allContractPaymentPlanPeriods);
                for(ContractPaymentPlanPeriodWrapper cppp: ccw.allContractPaymentPlanPeriods) {
                    System.debug(cppp);
                    totalAmount += cppp.amount;
                }
            }

            return totalAmount.format();
        }}
        
        public String totalAmountWithoutNoInvoicing { get{
            Decimal totalAmount = 0;

            for(ContractContentWrapper ccw : contractContentWrapperMap.values()) {
                for(ContractPaymentPlanPeriodWrapper cppp: ccw.allContractPaymentPlanPeriods) {
                    if(cppp.earliestDateOfInvoice != null) {
                        totalAmount += cppp.amount;
                    }
                }
            }

            return totalAmount.format();
        }}

        public ContractWrapper(EUR_CRM_Contract__c contractHeader){
            this.contractHeader = contractHeader;
        }

        public ContractWrapper(EUR_CRM_Contract__c contractHeader, EUR_CRM_Contract_Payment_Plan__c newContractPaymentPlan){
            this.contractHeader = contractHeader;
            this.contractPaymentPlan = newContractPaymentPlan;

            System.debug(this.contractPaymentPlan);
        }
    }
    
    public class ContractContentWrapper{
        public EUR_CRM_Mechanic_Type__c mechanicType{get;set;}
        //public Set<ContractActivityWrapper> contractActivitySet {get;set;}{contractActivitySet = new Set<ContractActivityWrapper>();}
        public Map<Id, ContractActivityWrapper> contractActivityMap{get;set;}{contractActivityMap = new Map<Id, ContractActivityWrapper>();}
        public Integer contractActivityCount {get{return (contractActivityMap==null)?0:contractActivityMap.size();}}
        
        public ContractActivityWrapper singleContractActivity{get{
            ContractActivityWrapper caWrap;
            for (ContractActivityWrapper ca: contractActivityMap.values()){
                caWrap = ca;
            }
            return caWrap;
        }}
        
        //PRD Events/Trainings
        public List<ContractActivityWrapper> prdActivities{get{
            List<ContractActivityWrapper> caWrapperList = new List<ContractActivityWrapper>();
            for (ContractActivityWrapper ca: contractActivityMap.values()){
                if (ca.contractActivity.EUR_CRM_PR_DE_Flag__c){
                    caWrapperList.add(ca);
                }
            }
            return caWrapperList;
        }}
        
        //Non-PRD Events/Trainings
        public List<ContractActivityWrapper> nonPRDActivities{get{
                    List<ContractActivityWrapper> caWrapperList = new List<ContractActivityWrapper>();
            for (ContractActivityWrapper ca: contractActivityMap.values()){
                if (! ca.contractActivity.EUR_CRM_PR_DE_Flag__c){
                    caWrapperList.add(ca);
                }
            }
            return caWrapperList;
        }}
        
        //PRD Events/Training Total
        public Decimal prdActivitiesTotal{get{
            Decimal total = 0;
            for (ContractActivityWrapper ca: contractActivityMap.values()){
                if (ca.contractActivity.EUR_CRM_PR_DE_Flag__c){
                    total += ca.contractActivity.EUR_CRM_Contract_Activity_Total__c;
                }
            }
            return total;
        }}
        
        public String prdActivitiesTotalStr{get{
            Decimal tValue = prdActivitiesTotal.setScale(2)+0.001;
            String sValue =  String.valueOf(tValue.format());
            return sValue.substring(0,sValue.length()-1);
        }}
        
        //Non-PRD Events/Training Total
        public Decimal nonPRDActivitiesTotal{get{
            Decimal total = 0;
            for (ContractActivityWrapper ca: contractActivityMap.values()){
                if (! ca.contractActivity.EUR_CRM_PR_DE_Flag__c){
                    total += ca.contractActivity.EUR_CRM_Contract_Activity_Total__c;
                }
            }
            return total;
        }}
        
        public String nonPRDActivitiesTotalStr{get{
            Decimal tValue = nonPRDActivitiesTotal.setScale(2)+0.001;
            String sValue =  String.valueOf(tValue.format());
            return sValue.substring(0,sValue.length()-1);
        }}
        
        //Unique Non-PRD Product List
        public Set<EUR_CRM_Contract_Product_Item__c> nonPRDUniqueContractProductSet {get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            Set<Id> productIdSet = new Set<Id>();
            for (ContractActivityWrapper caWrap: contractActivityMap.values()){
                if (! caWrap.contractActivity.EUR_CRM_PR_DE_Flag__c){
                    for (EUR_CRM_Contract_Product_Item__c cProduct: caWrap.contractProductMap.values()){
                        Id productId = (cProduct.EUR_CRM_Brand__c != null)?cProduct.EUR_CRM_Brand__c:cProduct.EUR_CRM_Brand_Quality__c;
                        if (productId!=null && (!productIdSet.contains(productId))){
                            productIdSet.add(productId);
                            cpSet.add(cProduct);
                        }
                    }
                }
            }
            return cpSet;
        }}
        
        //Unique PRD Product List
        public Set<EUR_CRM_Contract_Product_Item__c> PRDUniqueContractProductSet {get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            Set<Id> productIdSet = new Set<Id>();
            for (ContractActivityWrapper caWrap: contractActivityMap.values()){
                if (caWrap.contractActivity.EUR_CRM_PR_DE_Flag__c){
                    for (EUR_CRM_Contract_Product_Item__c cProduct: caWrap.contractProductMap.values()){
                        Id productId = (cProduct.EUR_CRM_Brand__c != null)?cProduct.EUR_CRM_Brand__c:cProduct.EUR_CRM_Brand_Quality__c;
                        if (productId!=null && (!productIdSet.contains(productId))){
                            productIdSet.add(productId);
                            cpSet.add(cProduct);
                        }
                    }
                }
            }
            return cpSet;
        }}
        
        //Unique Exclusive List
        public Set<EUR_CRM_Contract_Product_Item__c> uniqueContractProductSet {get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            Set<Id> productIdSet = new Set<Id>();
            for (ContractActivityWrapper caWrap: contractActivityMap.values()){
                for (EUR_CRM_Contract_Product_Item__c cProduct: caWrap.contractProductMap.values()){
                    System.debug(cProduct);
                    System.debug(caWrap.contractActivity);

                    Id productId = (cProduct.EUR_CRM_Brand__c != null)?cProduct.EUR_CRM_Brand__c:cProduct.EUR_CRM_Brand_Quality__c;
                    if (productId!=null && (!productIdSet.contains(productId))){
                        productIdSet.add(productId);
                        cProduct.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_End_Date__c = caWrap.contractActivity.EUR_CRM_End_Date__c;
                        cProduct.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Start_Date__c = caWrap.contractActivity.EUR_CRM_Start_Date__c;
                        cpSet.add(cProduct);
                    }
                }
            }
            return cpSet;
        }}
        
        public Integer uniqueContractProductSetSize{get{
            return (uniqueContractProductSet==null)?0:uniqueContractProductSet.size();
        }}
        
        public Set<EUR_CRM_Contract_Product_Item__c> uniqueExclusiveContractProductSet {get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            Set<Id> productIdSet = new Set<Id>();
            for (ContractActivityWrapper caWrap: contractActivityMap.values()){
                for (EUR_CRM_Contract_Product_Item__c cProduct: caWrap.contractProductMap.values()){
                    Id productId = (cProduct.EUR_CRM_Brand__c != null)?cProduct.EUR_CRM_Brand__c:cProduct.EUR_CRM_Brand_Quality__c;
                    if (productId!=null && (!productIdSet.contains(productId)) && cProduct.EUR_CRM_Exclusive__c==true){
                        productIdSet.add(productId);
                        cpSet.add(cProduct);
                    }
                }
            }
            return cpSet;
        }}
        
        public Set<EUR_CRM_Contract_Product_Item__c> uniqueNonExclusiveContractProductSet {get{
            Set<EUR_CRM_Contract_Product_Item__c> cpSet = new Set<EUR_CRM_Contract_Product_Item__c>();
            Set<EUR_CRM_Contract_Product_Item__c> allCP = uniqueContractProductSet;
            Set<EUR_CRM_Contract_Product_Item__c> exclusiveCP= uniqueExclusiveContractProductSet;
            
            for (EUR_CRM_Contract_Product_Item__c cp: allCP){
                if (!exclusiveCP.contains(cp)){
                    cpSet.add(cp);
                }
            }
            
            return cpSet;
        }}
        
        public Decimal total {get{
            Decimal iTotal = 0;
            for (ContractActivityWrapper caWrap : contractActivityMap.values()){
                Decimal iAmount = (mechanicType.EUR_CRM_Has_Lump_Sum__c==true)?caWrap.contractActivity.EUR_CRM_Amount__c:caWrap.contractActivity.EUR_CRM_Product_Items_Total__c;
                iTotal += (iAmount==null)?0:iAmount;
            }
            return iTotal;
        }}
        
        public String totalStr{get{
            Decimal tValue = total.setScale(2)+0.001;
            String sValue =  String.valueOf(tValue.format());
            return sValue.substring(0,sValue.length()-1);
        }}
        
        public Set<EUR_CRM_Contract_Product_Item__c>  allContractProducts {get{
            Set<EUR_CRM_Contract_Product_Item__c> contractProducts = new Set<EUR_CRM_Contract_Product_Item__c>();
            for (ContractActivityWrapper caWrap : contractActivityMap.values()){
                for (EUR_CRM_Contract_Product_Item__c cp: caWrap.contractProductMap.values()){
                    contractProducts.add(cp);
                }
            }
            return contractProducts;
        }}

        public Integer allContractProductsSize{get{return allContractProducts.size();}}

        public List<ContractProductWrapper> sumAllBrandQualities {get{
            Map<Id, ContractProductWrapper> bqIdToContractProductWrapperMap = new Map<Id, ContractProductWrapper>();
            for(EUR_CRM_Contract_Product_Item__c cpItem : this.allContractProducts) {

                if(bqIdToContractProductWrapperMap.get(cpItem.EUR_CRM_Brand_Quality__c) == null) {
                    bqIdToContractProductWrapperMap.put(
                        cpItem.EUR_CRM_Brand_Quality__c,
                        new ContractProductWrapper(
                            cpItem.EUR_CRM_Brand_Quality__r.Name,
                            cpItem.EUR_CRM_Unit__c,
                            cpItem.EUR_CRM_Quantity__c
                        )
                    );
                } else {
                    bqIdToContractProductWrapperMap.get(cpItem.EUR_CRM_Brand_Quality__c).addVolume(cpItem.EUR_CRM_Quantity__c);
                }
            }

            return bqIdToContractProductWrapperMap.values();
        }}

        public Integer sumAllBrandQualitiesSize{get{return sumAllBrandQualities.size();}}

        // Calculate total quantity for WKZ mech type
        public List<ContractProductWrapper> sumAllBrand {get{
            Map<Id, ContractProductWrapper> bqIdToContractProductWrapperMap = new Map<Id, ContractProductWrapper>();
            for(EUR_CRM_Contract_Product_Item__c cpItem : this.allContractProducts) {

                if(cpItem.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Mechanic_Type__r.EUR_CRM_Mechanic_Type_Name_English__c == 'WKZ Fix Amount' && bqIdToContractProductWrapperMap.get(cpItem.EUR_CRM_Brand__c) == null) {
                    bqIdToContractProductWrapperMap.put(
                        cpItem.EUR_CRM_Brand__c,
                        new ContractProductWrapper(
                            cpItem.EUR_CRM_Brand__r.Name,
                            cpItem.EUR_CRM_Unit__c,
                            cpItem.EUR_CRM_Quantity__c
                        )
                    );
                } else {
                    bqIdToContractProductWrapperMap.get(cpItem.EUR_CRM_Brand__c).addVolume(cpItem.EUR_CRM_Quantity__c);
                }
            }

            return bqIdToContractProductWrapperMap.values();
        }}

        public Integer sumAllBrandSize{get{return sumAllBrand.size();}}

        public Set<ContractPaymentPlanPeriodWrapper> allContractPaymentPlanPeriods{get{
            // Set<EUR_CRM_Contract_Payment_Plan_Period__c> contractPaymentPlanPeriods = new Set<EUR_CRM_Contract_Payment_Plan_Period__c>();
            Set<ContractPaymentPlanPeriodWrapper> contractPaymentPlanPeriods = new Set<ContractPaymentPlanPeriodWrapper>();
            for(ContractActivityWrapper caWrap: contractActivityMap.values()) {
                System.debug(caWrap.contractActivity);
                System.debug(caWrap.contractActivity.Contract_Payment_Plan_Periods__r);
                String mechanicTypeName = caWrap.contractActivity.EUR_CRM_Mechanic_Type__r.Name;
                if(caWrap.contractActivity.Contract_Payment_Plan_Periods__r != null) {
                    for(EUR_CRM_Contract_Payment_Plan_Period__c cppPeriod: caWrap.contractActivity.Contract_Payment_Plan_Periods__r) {
                        cppPeriod.EUR_CRM_Contract_Activity_Item__r = caWrap.contractActivity;
                        System.debug(cppPeriod);
                        // contractPaymentPlanPeriods.add(cppPeriod);
                        contractPaymentPlanPeriods.add(new ContractPaymentPlanPeriodWrapper(cppPeriod, mechanicTypeName));
                    }
                }
            }
            
            return contractPaymentPlanPeriods;
        }}

        public Integer allContractPaymentPlanPeriodsSize{get{return allContractPaymentPlanPeriods.size();}}
        
        public ContractContentWrapper(){}
        
        public ContractContentWrapper(EUR_CRM_Mechanic_Type__c mechanicType){
            this.mechanicType = mechanicType;
        }
        
        public ContractContentWrapper(EUR_CRM_Mechanic_Type__c mechanicType, List<EUR_CRM_Contract_Activity_Item__c> contractActivityList){
            this.mechanicType = mechanicType;
            
            for (EUR_CRM_Contract_Activity_Item__c ca: contractActivityList){
                ContractActivityWrapper caWrap = new ContractActivityWrapper(ca);
                this.contractActivityMap.put(ca.Id, caWrap);
            }
        }
        
        public Boolean isAvailable{get{return (contractActivityMap.size()>0?true:false);}}
    }
    
    public class ContractActivityWrapper{
        private String noInvoicing{get{return Label.EUR_CRM_No_Invoicing;}}

        public EUR_CRM_Contract_Activity_Item__c contractActivity {get;set;}
        public Map<Id, EUR_CRM_Contract_Product_Item__c> contractProductMap {get;set;}{contractProductMap = new Map<Id, EUR_CRM_Contract_Product_Item__c>();}
        public Integer contractProductMapSize {get{return (contractProductMap==null)?0:contractProductMap.size();}}
        
        public String paymentTerm{get{
            String paymentTerm = (contractActivity.EUR_CRM_Exclude_Budget_Deduction__c)?noInvoicing:contractActivity.EUR_CRM_Payment_Term__c;
            return (paymentTerm == null)?'':paymentTerm;
        }}
        
        public Set<EUR_CRM_Contract_Product_Item__c> exclusiveContractProducts{
            get{
                Set<EUR_CRM_Contract_Product_Item__c> eCProducts = new Set<EUR_CRM_Contract_Product_Item__c>();
                for (EUR_CRM_Contract_Product_Item__c cp: contractProductMap.values()){
                    if (cp.EUR_CRM_Exclusive__c == true){
                        eCProducts.add(cp);
                    }
                }
                return eCProducts;
            }
        }

        public Set<EUR_CRM_Contract_Product_Item__c> allContractProductItems{
            get {
                Set<EUR_CRM_Contract_Product_Item__c> contractProductItems = new Set<EUR_CRM_Contract_Product_Item__c>();
                for(EUR_CRM_Contract_Product_Item__c cp: contractProductMap.values()) {
                    contractProductItems.add(cp);
                }

                return contractProductItems;
            }
        }

        public ContractActivityWrapper(EUR_CRM_Contract_Activity_Item__c contractActivity){
            contractActivity.EUR_CRM_Payment_Term__c = contractActivity.EUR_CRM_Exclude_Budget_Deduction__c ? noInvoicing: contractActivity.EUR_CRM_Payment_Term__c;   
            this.contractActivity = contractActivity;
        }

    }
    
    public class ContractProductWrapper{
        public String productName {get; set;}
        public Decimal totalVolume {get;set;}{totalVolume=0;}
        public String unit {get; set;}

        public ContractProductWrapper(String productName, String unit, Decimal totalVolume) {
            this.productName = productName;
            this.unit = unit;
            this.totalVolume = totalVolume;
        }

        public void addVolume(Decimal volume) {
            this.totalVolume += volume;
        }
    }

    public class ContractPaymentPlanPeriodWrapper{
        public String name {get; set;}
        public String mechanicTypeName {get; set;}
        public String brand {get; set;}
        public String description {get; set;}
        public Date startDate {get; set;}
        public Date endDate {get; set;}
        public String rate {get; set;}
        public String unit {get; set;}
        public String volume {get; set;}
        public String formattedAmount {get; set;}
        public Decimal amount {get; set;}
        public String paymentTerm {get; set;}
        public Date earliestDateOfInvoice {get; set;}

        public ContractPaymentPlanPeriodWrapper(EUR_CRM_Contract_Payment_Plan_Period__c cppp) {
            this.name = cppp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c;
            this.brand = cppp.EUR_CRM_List_of_Brand__c == null ? cppp.EUR_CRM_Brand__c : cppp.EUR_CRM_List_of_Brand__c;
            this.description = cppp.EUR_CRM_Description__c;
            this.startDate = cppp.EUR_CRM_Payment_Period_Start_Date__c;
            this.endDate = cppp.EUR_CRM_Payment_Period_End_Date__c;
            this.rate = cppp.EUR_CRM_CPPP_Rate__c == null ? null : cppp.EUR_CRM_CPPP_Rate__c.format();
            this.unit = cppp.EUR_CRM_CPPP_Unit__c;
            this.volume = cppp.EUR_CRM_CPPP_Volume__c == null ? null : cppp.EUR_CRM_CPPP_Volume__c.format();
            this.amount = cppp.EUR_CRM_CPPP_Amount__c;
            this.formattedAmount = cppp.EUR_CRM_CPPP_Amount__c == null ? null : cppp.EUR_CRM_CPPP_Amount__c.format();
            this.paymentTerm = cppp.EUR_CRM_CPPP_Payment_Term__c;
            this.earliestDateOfInvoice = cppp.EUR_CRM_CPPP_Earliest_Date_of_Invoice__c;
        }

        public ContractPaymentPlanPeriodWrapper(EUR_CRM_Contract_Payment_Plan_Period__c cppp, String mechanicTypeName) {
            this.name = cppp.EUR_CRM_Contract_Activity_Item__r.EUR_CRM_Name__c;
            this.mechanicTypeName = mechanicTypeName;
            this.brand = cppp.EUR_CRM_List_of_Brand__c == null ? cppp.EUR_CRM_Brand__c : cppp.EUR_CRM_List_of_Brand__c;
            this.description = cppp.EUR_CRM_Description__c;
            this.startDate = cppp.EUR_CRM_Payment_Period_Start_Date__c;
            this.endDate = cppp.EUR_CRM_Payment_Period_End_Date__c;
            this.rate = cppp.EUR_CRM_CPPP_Rate__c == null ? null : cppp.EUR_CRM_CPPP_Rate__c.format();
            this.unit = cppp.EUR_CRM_CPPP_Unit__c;
            this.volume = cppp.EUR_CRM_CPPP_Volume__c == null ? null : cppp.EUR_CRM_CPPP_Volume__c.format();
            this.amount = cppp.EUR_CRM_CPPP_Amount__c;
            this.formattedAmount = cppp.EUR_CRM_CPPP_Amount__c == null ? null : cppp.EUR_CRM_CPPP_Amount__c.format();
            this.paymentTerm = cppp.EUR_CRM_CPPP_Payment_Term__c;
            this.earliestDateOfInvoice = cppp.EUR_CRM_CPPP_Earliest_Date_of_Invoice__c;
        }
    }
}