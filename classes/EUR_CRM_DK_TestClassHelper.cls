@isTest
public class EUR_CRM_DK_TestClassHelper { 
    public static RecordType ApexConfigDKRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Apex_Configuration__c' and DeveloperName = 'EUR_CRM_Account_Running_Number_Normal' LIMIT 1];
    public static RecordType euacctDKRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_DK_OFF_Trade' LIMIT 1];
    //public static RecordType euacctRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_ZA_On_Trade_Indirect' LIMIT 1];
    //maps to hold the record type info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    
    public static EUR_CRM_Apex_Configuration__c createApexConfig(){
        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c();
        config.EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number';
        config.EUR_CRM_Country_Code__c='DK';
        config.EUR_CRM_Account_RecordType_DevName__c='EUR_DK_OFF_Trade';
        config.EUR_CRM_Prefix__c = 'f';
        return config;
    }
    //CREATE Region
    public static List<EUR_CRM_Region__c> createRegion(integer numberOfEURegion, String currencyCode, Id user){
    
        List<EUR_CRM_Region__c> regionEUList = new List<EUR_CRM_Region__c>();
        
        for(integer i = 0;i < numberOfEURegion;i++){
            EUR_CRM_Region__c regionEU = new EUR_CRM_Region__c();
            regionEU.CurrencyIsoCode = currencyCode;
            regionEU.EUR_CRM_Region_Code__c = 'TEST CODE';
            regionEU.EUR_CRM_Region_Owner__c = user;
            
            regionEUList.add(regionEU);
        }
        
        return regionEUList;
    }
    
    //CREATE Territory
    public static List<EUR_CRM_Territory__c> createTerritory(integer numberOfEUTerritory, String currencyCode, Id user, Id region){
    
        List<EUR_CRM_Territory__c> territoryEUList = new List<EUR_CRM_Territory__c>();
        
        for(integer i = 0;i < numberOfEUTerritory;i++){
            EUR_CRM_Territory__c territoryEU = new EUR_CRM_Territory__c();
            territoryEU.CurrencyIsoCode = currencyCode;
            territoryEU.EUR_CRM_Description__c = 'TEST DESCRIPTION';
            territoryEU.EUR_CRM_Territory_Owner__c = user;
            territoryEU.EUR_CRM_Territory_Code__c = 'TEST CODE';
            territoryEU.EUR_CRM_Region__c = region;
            
            territoryEUList.add(territoryEU);
        }
        
        return territoryEUList;
    }
    
    
    public static EUR_CRM_Account__c createEUAccount(String name)
    {
        Id userId = UserInfo.getUserId();
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctDKRecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        newAccount.EUR_CRM_Territory__c = territory.Id;
        return newAccount;
    }
    
    public static EUR_CRM_Account__c createEUAccountsDKOFF(String name)
    {

        Id userId = UserInfo.getUserId();
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        EUR_CRM_Customer_Taxonomy__c accCT = createCustomerTaxonomy('testCT',userId,'EUR_DK_Customer_Taxonomy');
        
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctDKRecordType.Id;
        newAccount.EUR_CRM_Channel__c = 'OFF TRADE';
        newAccount.EUR_CRM_Sub_Channel__c = 'Retail';
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        newAccount.EUR_CRM_Territory__c = territory.Id;
        newAccount.EUR_JB_Customer_Taxonomy__c = accCT.Id;
            
        return newAccount;
    }
    
    public static List<EUR_CRM_Account__c> createEUAccounts(String name,Integer no)
    {
        
        List<EUR_CRM_Account__c> accs = new List<EUR_CRM_Account__c>();
        for(Integer i=0; i<no; i++){
            Id userId = UserInfo.getUserId();
            EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
            EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
            EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name+i);
            newAccount.RecordTypeId = euacctDKRecordType.Id;
            newAccount.EUR_CRM_Status__c = 'New';
            newAccount.EUR_CRM_Business_Type__c = 'Outlet';
            newAccount.EUR_CRM_Territory__c = territory.Id;
            accs.add(newAccount);
        }
        
        return accs;
    }
    
    public static EUR_CRM_Account__c createEUAccount(String name,String recordTypeDeveloperName)
    {
        Id recordtypeId = getRecordTypeId('EUR_CRM_Account__c', recordTypeDeveloperName);
        Id userId = UserInfo.getUserId();
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctDKRecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        newAccount.EUR_CRM_Territory__c = territory.Id;
        newAccount.EUR_CRM_Postal_Code__c = '123456';
        newAccount.EUR_CRM_Street__c = 'Stree';
        return newAccount;
    }
    
    private static void fillMapsForRecordTypeObject(string objectName) {
    /*------------------------------------------------------------
    Description:   Function to fill record type map for objects not in cache
    Inputs:        objectName - The name of the sObject
    Returns:       Nothing
    ------------------------------------------------------------*/
        // get the object map the first time
        if (gd==null) gd = Schema.getGlobalDescribe();

        // get the object description
        if (gd.containsKey(objectName)) {
            Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();
            recordTypesByName.put(objectName, d.getRecordTypeInfosByName());
            recordTypesById.put(objectName, d.getRecordTypeInfosById());
        }
    }
    
    //CREATE Brand
    public static List<EUR_CRM_Brand__c> createBrand(integer numberofBrand, String recordTypeDeveloperName, String brandName, String externalID, Id category){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Brand__c', recordTypeDeveloperName);
        List<EUR_CRM_Brand__c> brandList = new List<EUR_CRM_Brand__c>();
        
        for(integer i = 0;i < numberofBrand;i++){
            EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
            brand.RecordTypeId = recordtypeId;
            brand.Name = brandName;
            brand.EUR_CRM_External_ID__c = externalID;
            brand.EUR_CRM_Category__c = category;
            brandList.add(brand);
        }
        
        return brandList;
    }
    
    public static Id getRecordTypeId(String objectName, String recordTypeName) {
    /*------------------------------------------------------------
    Description:   Gives record type id from a given sObject and record type label
    Inputs:        objectName - The sObject
                   recordTypeName - The name of the record type (NOT the API Name)
    Returns:       The specified record types id value
    ------------------------------------------------------------*/
        // make sure we have this object's record types mapped
        if (!recordTypesByName.containsKey(objectName)) 
            fillMapsForRecordTypeObject(objectName);

        // now grab and return the requested id 
        Map<String,Schema.RecordTypeInfo> rtMap = recordTypesByName.get(objectName);
        System.debug('##RTMAP: '+rtMap);
        Id rtId = null;
        if (rtMap != null && rtMap.containsKey(recordTypeName)) {
            return rtMap.get(recordTypeName).getRecordTypeId();
        } else {
            List<Recordtype> tempRecordTypes = Global_RecordTypeCache.getRtList(objectName);
            Map<String,Id> tempRecordTypesMap = new Map<String,Id>();
                
            for(Recordtype rt : tempRecordTypes ){
               if(rt.developername ==  recordTypeName){
                   rtId = rt.id;
                   break;
               }
            }
            return rtId;
        }
        
    }
    
     //CREATE Objectives / Promotions
    public static List<EUR_CRM_ObjPromo__c> createEMObjPromo(integer numberofObjPromo, String recordTypeDeveloperName, String Name){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        for(integer i = 0;i < numberofObjPromo;i++){
            system.Debug('!!Debug:Create OP:' + i);
            integer StartDate = i - 1;
            integer EndDate = i;
            EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
            objPromo.RecordTypeId = recordtypeId;
            objPromo.Name = Name+i;
            objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = 'TEST CHAIN';
            objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'TEST CHAIN';
            //objPromo.EUR_CRM_OP_Action_List_Template__c = template.Id;
             objPromo.EUR_CRM_Preparation_Start_Date__c = Date.today() + StartDate;
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today() + StartDate;
            objPromo.EUR_CRM_Active_End_Date__c = Date.today() + EndDate; 
            objPromo.EUR_CRM_Status__c = 'Committed';
            objPromoList.add(objPromo);
        }
        
        return objPromoList;
    } 

     //CREATE Objectives / Promotions
    public static List<EUR_CRM_ObjPromo__c> createObjPromo(integer numberofObjPromo, String recordTypeDeveloperName, String Name,EUR_CRM_OP_Action_List_Template__c template){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        for(integer i = 0;i < numberofObjPromo;i++){
            system.Debug('!!Debug:Create OP:' + i);
            integer StartDate = i - 1;
            integer EndDate = i;
            EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
            objPromo.RecordTypeId = recordtypeId;
            objPromo.Name = Name+i;
            objPromo.EUR_CRM_CustomerTaxonomy_Chain__c = 'TEST CHAIN';
            objPromo.EUR_CRM_Customer_Taxonomy_Sub_Chain__c = 'TEST CHAIN';
            objPromo.EUR_CRM_OP_Action_List_Template__c = template.Id;
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today() + StartDate;
            objPromo.EUR_CRM_Active_End_Date__c = Date.today() + EndDate; 
            objPromoList.add(objPromo);
        }
        
        return objPromoList;
    } 

    
     //CREATE Objectives / Promotions
    public static List<EUR_CRM_ObjPromo_Account_Mapping__c> createOPAccountMapping(integer numRecords, String recordTypeDeveloperName, EUR_CRM_Account__c account, EUR_CRM_ObjPromo__c promo){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo_Account_Mapping__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo_Account_Mapping__c> OPMappingList = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        
        for(integer i = 0;i < numRecords;i++){
            EUR_CRM_ObjPromo_Account_Mapping__c OP = new EUR_CRM_ObjPromo_Account_Mapping__c();
            OP.RecordTypeId = recordtypeId;
            OP.EUR_CRM_Account__c = account.Id;
            OP.EUR_CRM_ObjPromo__c = promo.Id;
            OP.EUR_CRM_Is_Active__c =false;
            OPMappingList.add(OP);
        }
        
        return OPMappingList;
    }
    
    public static EUR_CRM_OP_Action_List_Template__c createActionListTemplate(){
        Id recordtypeId = getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', 'EUR_DK_OP_Action_List_Template');
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'DK OFF Leaflet Campaign Test';
        listTemplate.EUR_CRM_External_ID__c = 'DK_OFF_LeafletCampaign';
        listTemplate.recordtypeId = recordtypeId;
        return listTemplate;
    }
    
    public static EUR_CRM_ObjPromo_Action__c createObjPromoAction(){
        EUR_CRM_ObjPromo_Action__c objPromoAction = new EUR_CRM_ObjPromo_Action__c();
        objPromoAction.EUR_CRM_External_ID__c = 'DK_OFF_LeafletCampaign_ConfirmAgreeToBuy';
        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = 'EUR_DK_OFF_Leaflet_Campaign_Agreement_To_Buy';
        return objPromoAction;
    }
    
    public static EUR_CRM_Visit_Action__c createVisitAction(EUR_CRM_Account__c euaccount,EUR_CRM_ObjPromo__c promo){
        //Id recordtypeId = getRecordTypeId('EUR_CRM_Visit_Action__c', 'EUR_DK_OFF_Dist_Drive_Listing_Check');
        EUR_CRM_Visit_Action__c visit = new EUR_CRM_Visit_Action__c();
        visit.EUR_CRM_Account__c = euaccount.id;
        visit.EUR_CRM_ObjPromo__c =  promo.Id;
        //visit.recordtypeId= recordtypeId;
        return visit;
    }
    
    //CREATE O/P Target
    public static List<EUR_CRM_ObjPromo_Target__c> createOPTarget(integer numberofOPTarget, String recordTypeDeveloperName, Id objPromoId, Id opTargetId){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo_Target__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo_Target__c> opTargetList = new List<EUR_CRM_ObjPromo_Target__c>();
        
        for(integer i = 0;i < numberofOPTarget;i++){
            EUR_CRM_ObjPromo_Target__c opTarget = new EUR_CRM_ObjPromo_Target__c();
            opTarget.RecordTypeId = recordtypeId;
            opTarget.EUR_CRM_ObjPromo__c = objPromoId;
            opTarget.EUR_CRM_O_P_Target__c = opTargetId;
            opTargetList.add(opTarget);
        }
        
        return opTargetList;
    }
    
    public static EUR_CRM_SKU__c createSKU(String name, String articleno, String recordtypename ){
        Id recordtypeId = getRecordTypeId('EUR_CRM_SKU__c',recordtypename);
        EUR_CRM_SKU__c sku= new EUR_CRM_SKU__c (
            recordtypeid=recordtypeId,name = name,
            EUR_CRM_Article_no__c= articleno);
        insert sku;
        return sku;
    }
    
    //CREATE EUR_CRM_Customer_Taxonomy__c
    public static EUR_CRM_Customer_Taxonomy__c createCustomerTaxonomy(String name,   Id ownerId, String recordtypename){
        Id recordtypeId = getRecordTypeId('EUR_CRM_Customer_Taxonomy__c',recordtypename);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c(recordtypeid = recordtypeId,
                                                                                         name = name,
                                                                                         ownerid = ownerId,
                                                                                         EUR_CRM_Chain__c = 'TEST CHAIN',
                                                                                         EUR_CRM_Sub_Chain__c = 'TEST CHAIN');
        insert customerTaxonomy;
        return customerTaxonomy;
    }
    
    // create EUR_CRM_OP_Customer_Taxonomy_Mapping__c
    public static EUR_CRM_OP_Customer_Taxonomy_Mapping__c createCustomerTaxonomyMapping(EUR_CRM_Customer_Taxonomy__c cusTax, EUR_CRM_ObjPromo__c obPromo,String recordtypename){
        Id recordtypeId = getRecordTypeId('EUR_CRM_OP_Customer_Taxonomy_Mapping__c',recordtypename);
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c ctm = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        ctm.EUR_CRM_Customer_Taxonomy__c = cusTax.Id;
        ctm.EUR_CRM_ObjPromo__c = obPromo.Id;
        ctm.recordtypeid=recordtypeId;
        return ctm;
    }
    
    //CREATE REGION
    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner,  String recordtypename){
        Id recordtypeId = getRecordTypeId('EUR_CRM_Region__c',recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=recordtypeId,name = name,EUR_CRM_Region_Owner__c = regionOwner, ownerid = regionOwner);
        insert region;
        return region;
    }
    //CREATE Territory
    public static EUR_CRM_Territory__c createTerritory(String name, Id territoryOwner, Id regionId, String recordtypename){
        Id recordtypeId = getRecordTypeId('EUR_CRM_Territory__c',recordtypename);
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = regionId, recordtypeid=recordtypeId,name = name,
        EUR_CRM_Territory_Owner__c = territoryOwner);
        system.debug('@territory'+territory);
        insert territory;
        return territory;
    }
    
     //CREATE USER
    public static User createUser(String profileName, String roleName, String userEmail, String userName, String lastName){
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName]; 
        UserRole r = [select id from UserRole where Developername =:roleName ];
        User u = new User(Alias = 'standt', Email=userEmail, userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        insert u;
        return u;
    }
    

    
     //CREATE Wine/Spirits
    public static List<EUR_CRM_Wine_Spirits__c> createWineSpirits(integer numberofWineSpirits, String recordTypeDeveloperName, String externalID, String prodType){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Wine_Spirits__c', recordTypeDeveloperName);
        List<EUR_CRM_Wine_Spirits__c> wineSpiritsList = new List<EUR_CRM_Wine_Spirits__c>();
        
        for(integer i = 0;i < numberofWineSpirits;i++){
            EUR_CRM_Wine_Spirits__c wineSpirit = new EUR_CRM_Wine_Spirits__c();
            wineSpirit.RecordTypeId = recordtypeId;
            wineSpirit.EUR_CRM_External_ID__c = externalID;
            wineSpirit.EUR_CRM_Product_Type_Name__c = prodType;
            wineSpiritsList.add(wineSpirit);
        }
        
        return wineSpiritsList;
    }
    
    //CREATE Category
    public static List<EUR_CRM_Category__c> createCategory(integer numberofCategory, String recordTypeDeveloperName, String externalID, Id wineSpirit){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Category__c', recordTypeDeveloperName);
        List<EUR_CRM_Category__c> categoryList = new List<EUR_CRM_Category__c>();
        
        for(integer i = 0;i < numberofCategory;i++){
            EUR_CRM_Category__c category = new EUR_CRM_Category__c();
            category.RecordTypeId = recordtypeId;
            category.EUR_CRM_External_ID__c = externalID;
            category.EUR_CRM_Wine_Spirits__c = wineSpirit;
            categoryList.add(category);
        }
        
        return categoryList;
    }
    
    //CREATE Brand
    public static List<EUR_CRM_Brand__c> createBrands(integer numberofBrand, String recordTypeDeveloperName, String brandName, String externalID, Id category){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Brand__c', recordTypeDeveloperName);
        List<EUR_CRM_Brand__c> brandList = new List<EUR_CRM_Brand__c>();
        
        for(integer i = 0;i < numberofBrand;i++){
            EUR_CRM_Brand__c brand = new EUR_CRM_Brand__c();
            brand.RecordTypeId = recordtypeId;
            brand.Name = brandName;
            brand.EUR_CRM_External_ID__c = externalID;
            brand.EUR_CRM_Category__c = category;
            brandList.add(brand);
        }
        
        return brandList;
    }
    
    //CREATE Brand Quality
    public static List<EUR_CRM_Quality__c> createBrandQuality(integer numberofBrandQuality, String recordTypeDeveloperName, String brandQualityName, String externalID, Id brand){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Quality__c', recordTypeDeveloperName);
        List<EUR_CRM_Quality__c> brandQualityList = new List<EUR_CRM_Quality__c>();
        
        for(integer i = 0;i < numberofBrandQuality;i++){
            EUR_CRM_Quality__c brandQuality = new EUR_CRM_Quality__c();
            brandQuality.RecordTypeId = recordtypeId;
            brandQuality.Name = brandQualityName;
            brandQuality.EUR_CRM_External_ID__c = externalID;
            brandQuality.EUR_CRM_Brand__c = brand;
            brandQualityList.add(brandQuality);
        }
        
        return brandQualityList;
    }

    // create EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c
    public static EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c createProsSegmentMapping(EUR_CRM_ObjPromo__c promo,String recordTypeDeveloperName){
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c', recordTypeDeveloperName);
        EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c p = new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
        p.EUR_CRM_Group_Outlet_Type__c = 'Restaurant';
        p.EUR_CRM_Image_Level__c = 'Iconic';
        p.EUR_CRM_ObjPromo__c = promo.Id;
        p.recordtypeId = recordtypeId;
        return p;
    }
    
    public static EUR_CRM_ObjPromo_Account_Mapping__c createOPAccountMapping(EUR_CRM_ObjPromo__c promo, EUR_CRM_Account__c acc)
    {
        Id recordTypeId = getRecordTypeId('EUR_CRM_ObjPromo_Account_Mapping__c','EUR_DK_OP_Account_Mapping');
        EUR_CRM_ObjPromo_Account_Mapping__c oam = new EUR_CRM_ObjPromo_Account_Mapping__c();
        oam.EUR_CRM_Account__c = acc.Id;
        oam.EUR_CRM_ObjPromo__c = promo.Id;
        oam.EUR_CRM_Is_Active__c = true;
        return oam;
    }
}