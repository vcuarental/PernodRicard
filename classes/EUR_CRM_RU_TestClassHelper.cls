@isTest
public class EUR_CRM_RU_TestClassHelper { 
    public static RecordType ApexConfigRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Apex_Configuration__c' and DeveloperName = 'EUR_CRM_Account_Running_Number_Normal' LIMIT 1];
    public static RecordType euacctRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_RU_On_Trade' LIMIT 1];
    //public static RecordType euacctRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_ZA_On_Trade_Indirect' LIMIT 1];
    //maps to hold the record type info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    
    public static EUR_CRM_Apex_Configuration__c createApexConfig(){
        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c();
        config.EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number';
        config.EUR_CRM_Country_Code__c='RU';
        config.EUR_CRM_Account_RecordType_DevName__c='EUR_RU_On_Trade';
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
        newAccount.RecordTypeId = euacctRURecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        newAccount.EUR_CRM_Territory__c = territory.Id;
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
            newAccount.RecordTypeId = euacctRURecordType.Id;
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
        newAccount.RecordTypeId = euacctRURecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        newAccount.EUR_CRM_Territory__c = territory.Id;
        return newAccount;
    }
    
    public static EUR_CRM_Account__c createEUAccount(String name,String recordTypeDeveloperName, Id territoryId, Id Owner)
    {
        Id recordtypeId = getRecordTypeId('EUR_CRM_Account__c', recordTypeDeveloperName);
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctRURecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        //newAccount.EUR_CRM_Sub_Channel__c = 'Independent';
        newAccount.EUR_CRM_Territory__c = territoryId;
        newAccount.EUR_CRM_Company_Type__c = 'Discount Store';
        newAccount.OwnerId = Owner;
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
    public static List<EUR_CRM_ObjPromo__c> createObjPromo(integer numberofObjPromo, String recordTypeDeveloperName, String Name,EUR_CRM_OP_Action_List_Template__c template){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();
        
        for(integer i = 0;i < numberofObjPromo;i++){
            EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
            objPromo.RecordTypeId = recordtypeId;
            objPromo.Name = Name+i;
            objPromo.EUR_CRM_OP_Action_List_Template__c = template.Id;
            objPromo.EUR_CRM_Active_Start_Date__c = Date.today() -1;
            objPromo.EUR_CRM_Active_End_Date__c = Date.today() + 1; 
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
        Id recordtypeId = getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', 'EUR_RU_OP_Action_List_Template');
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'template';
        listTemplate.EUR_CRM_External_ID__c = 'RU_ON_Promo_Phase_1';
        listTemplate.recordtypeId = recordtypeId;
        return listTemplate;
    }
    
    public static EUR_CRM_ObjPromo_Action__c createObjPromoAction(){
        EUR_CRM_ObjPromo_Action__c objPromoAction = new EUR_CRM_ObjPromo_Action__c();
        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = 'OFF_FOLLOW_UP';
        return objPromoAction;
    }
    
    public static EUR_CRM_Visit_Action__c createVisitAction(EUR_CRM_Account__c euaccount,EUR_CRM_ObjPromo__c promo){
        //Id recordtypeId = getRecordTypeId('EUR_CRM_Visit_Action__c', 'EUR_RU_OFF_Install_POSM');
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
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c
        (recordtypeid=recordtypeId,name = name,
        ownerid  = ownerId );
        insert customerTaxonomy;
        return customerTaxonomy;
    }
    
    // create EUR_CRM_OP_Customer_Taxonomy_Mapping__c
    public static EUR_CRM_OP_Customer_Taxonomy_Mapping__c createCustomerTaxonomyMapping(EUR_CRM_Customer_Taxonomy__c cusTax, EUR_CRM_ObjPromo__c obPromo,String recordtypename){
        Id recordtypeId = getRecordTypeId('EUR_CRM_OP_Customer_Taxonomy_Mapping__c',recordtypename);
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c ctm = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c();
        ctm.EUR_CRM_Customer_Taxonomy__c    = cusTax.Id;
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
    
    // Create Mechanic Type CO
    /* Disabled for deployment, should create another Test class helper for RU CO

    
    // create EUR_CRM_CO_Header__c
    
    public static EUR_CRM_CO_Header__c createCoHeader(EUR_CRM_Account__c acc){
        EUR_CRM_CO_Header__c coh = new EUR_CRM_CO_Header__c();
        coh.EUR_CRM_Total_Number_of_Logos__c = 1;
        coh.EUR_CRM_4_Promos_a_year__c = true;
        coh.EUR_CRM_PR_Brand_names_in_full__c = true;
        coh.EUR_CRM_Promo_Comments__c = 'Test Promo Comments';
        coh.EUR_CRM_Logos_Comments__c = 'Test Logo Comments';
        coh.EUR_CRM_Account__c = acc.Id;
        coh.EUR_CRM_Start_Date__c = Date.today();
        coh.EUR_CRM_End_Date__c = Date.today()+1;
        coh.EUR_CRM_Average_Distributor_Margin__c = 3;
        return coh;
    }

    public static EUR_CRM_CO_Mechanic_Type__c createMechanicTypeCO(EUR_CRM_Brand__c brand){
        EUR_CRM_CO_Mechanic_Type__c com = new EUR_CRM_CO_Mechanic_Type__c();
        com.Name = 'Test CO Mech type';
        com.EUR_CRM_Brand__c = brand.Id;
        return com;
    }
    
    // Create CO ProductLine Item
    
    public static EUR_CRM_CO_Product_Line_Item__c createCoProductLine(EUR_CRM_Brand__c brand,EUR_CRM_Quality__c brandQuality,EUR_CRM_CO_Line_Item__c col){
        EUR_CRM_CO_Product_Line_Item__c prl = new EUR_CRM_CO_Product_Line_Item__c();
        prl.EUR_CRM_Brand__c = brand.Id;
        prl.EUR_CRM_Brand_Quality__c = brandQuality.Id;
        prl.EUR_CRM_CO_Line_Item__c = col.Id;
        return prl;
    }
    
    // Create EUR_CRM_CO_Payment_Plan__c
    
    public static EUR_CRM_CO_Payment_Plan__c createCoPaymentPlan(EUR_CRM_CO_Header__c newCo,EUR_CRM_CO_Line_Item__c coLine){
        EUR_CRM_CO_Payment_Plan__c pp = new EUR_CRM_CO_Payment_Plan__c();
        pp.EUR_CRM_CO_Header__c = newCo.Id;
        pp.EUR_CRM_CO_Line_Item__c = coLine.id;
        return pp;
    }
    
    // Create EUR_CRM_CO_Payment_Plan_Period__c
    
    public static EUR_CRM_CO_Payment_Plan_Period__c createCoPaymentPlanPeriod(EUR_CRM_CO_Payment_Plan__c pPlan){
        EUR_CRM_CO_Payment_Plan_Period__c ppp = new EUR_CRM_CO_Payment_Plan_Period__c();
        ppp.EUR_CRM_CO_Payment_Plan__c = pPlan.Id;
        return ppp;
    }
    
    // create EUR_CRM_CO_Mechanic__c
    
    public static EUR_CRM_CO_Mechanic__c createCoMechanic(EUR_CRM_CO_Mechanic_Type__c comType,EUR_CRM_CO_Payment_Plan__c  COpayPlan,String name){
        EUR_CRM_CO_Mechanic__c coMechanic = new EUR_CRM_CO_Mechanic__c();
        coMechanic.name = name;
        coMechanic.EUR_CRM_CO_Mechanic_Type__c = comType.Id;
        coMechanic.EUR_CRM_CO_Payment_Plan__c = COpayPlan.Id; 
        coMechanic.EUR_CRM_External_ID__c = 'X123';
        return coMechanic;
    }
    
        // Create CO Lineitem
        
    public static EUR_CRM_CO_Line_Item__c createCoLine(EUR_CRM_Account__c acc,EUR_CRM_Category__c cat,EUR_CRM_CO_Header__c coHeader,EUR_CRM_CO_Mechanic__c coMechanic){ 
        EUR_CRM_CO_Line_Item__c col = new EUR_CRM_CO_Line_Item__c();
        col.EUR_CRM_Account__c = acc.Id;
        col.EUR_CRM_Category__c = cat.Id;
        col.EUR_CRM_CO_Header__c = coHeader.Id;
        col.EUR_CRM_CO_Mechanic__c = coMechanic.Id;
        
        return col;
    }*/
    
    //CREATE Template
    public static List<EUR_CRM_JB_Template__c> createTemplate(integer numberofTemplate, String recordTypeDeveloperName, String Name){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_JB_Template__c', recordTypeDeveloperName);
        List<EUR_CRM_JB_Template__c> templateList = new List<EUR_CRM_JB_Template__c>();
        
        for(integer i = 0;i < numberofTemplate;i++){
            EUR_CRM_JB_Template__c template = new EUR_CRM_JB_Template__c();
            template.RecordTypeId = recordtypeId;
            template.name = Name;
            templateList.add(template);
        }
        
        return templateList;
    }
    
    //CREATE Template Criteria
    public static List<EUR_CRM_JB_Template_Criteria__c> createTemplateCriteria(integer numberofTemplateCriteria, String recordTypeDeveloperName, Id template){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_JB_Template_Criteria__c', recordTypeDeveloperName);
        List<EUR_CRM_JB_Template_Criteria__c> templateCriteriaList = new List<EUR_CRM_JB_Template_Criteria__c>();
        
        for(integer i = 0;i < numberofTemplateCriteria;i++){
            EUR_CRM_JB_Template_Criteria__c templateCriteria = new EUR_CRM_JB_Template_Criteria__c();
            templateCriteria.RecordTypeId = recordtypeId;
            templateCriteria.EUR_JB_Template__c = template;
            templateCriteriaList.add(templateCriteria);
        }
        
        return templateCriteriaList;
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
}