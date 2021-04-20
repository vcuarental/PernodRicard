@isTest
public class EUR_CRM_BE_TestClassHelper {
    
    public static RecordType ApexConfigRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Apex_Configuration__c' and DeveloperName = 'EUR_CRM_Account_Running_Number_Normal' LIMIT 1];
    public static RecordType euacctBERecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_BE_On_Trade' LIMIT 1];
    //public static RecordType euacctRURecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_ZA_On_Trade_Indirect' LIMIT 1];
    //maps to hold the record type info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    
    
    public static EUR_CRM_Apex_Configuration__c createApexConfig(){
        EUR_CRM_Apex_Configuration__c config = new EUR_CRM_Apex_Configuration__c();
        config.EUR_CRM_Module__c = 'EUR_CRM_Account_Running_Number';
        config.EUR_CRM_Country_Code__c='BE';
        config.EUR_CRM_Account_RecordType_DevName__c='EUR_BE_On_Trade';
        config.EUR_CRM_Prefix__c = 'f';
        return config;
    }
    
    public static EUR_CRM_Account__c createEUAccount(String name){
        Id userId = UserInfo.getUserId();
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctBERecordType.Id;
        newAccount.EUR_CRM_Status__c = 'New';
        newAccount.EUR_CRM_Business_Type__c = 'Outlet';
        newAccount.EUR_CRM_Force_PRS_Image_Level__c = 'Leading';
        newAccount.EUR_CRM_Force_PRS_Volume_Potential__c = 'Low';
        newAccount.EUR_CRM_Territory__c = territory.Id;
        return newAccount;
    }
    
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
    
    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner,  String recordtypename){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Region__c'+recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=recordtypeId,name = name,EUR_CRM_Region_Owner__c = regionOwner, ownerid = regionOwner);
        insert region;
        return region;
    }
    
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
    
    public static EUR_CRM_OP_Action_List_Template__c createActionListTemplate(){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__c' + 'EUR_BE_O_P_Action_List_Template');
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'template';
        listTemplate.EUR_CRM_External_ID__c = 'BE_On_Trade_Promo_Kit_Activation';//EUR_BE_On_Trade_Promo_Kit_Activation
        listTemplate.recordtypeId = recordtypeId;
        return listTemplate;
    }
    
      public static EUR_CRM_OP_Action_List_Template__c createActionListTemplateWithExternal(String externalId){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Action_List_Template__c' + 'EUR_BE_O_P_Action_List_Template');
        EUR_CRM_OP_Action_List_Template__c listTemplate = new EUR_CRM_OP_Action_List_Template__c();
        listTemplate.name = 'template';
        listTemplate.EUR_CRM_External_ID__c = externalId;
        listTemplate.recordtypeId = recordtypeId;
        return listTemplate;
    }
    public static List<EUR_CRM_ObjPromo__c> createObjPromo(integer numberofObjPromo, String recordTypeDeveloperName, String Name,EUR_CRM_OP_Action_List_Template__c template){
        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo__c'+ recordTypeDeveloperName);
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
    
    public static List<EUR_CRM_ObjPromo_Account_Mapping__c> createOPAccountMapping(integer numRecords, String recordTypeDeveloperName, EUR_CRM_Account__c account, EUR_CRM_ObjPromo__c promo){
        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c'+ recordTypeDeveloperName);
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
    
    public static EUR_CRM_ObjPromo_Action__c createObjPromoAction(){
        EUR_CRM_ObjPromo_Action__c objPromoAction = new EUR_CRM_ObjPromo_Action__c();
        objPromoAction.EUR_CRM_Visit_Action_RecordType_DevName__c = 'OFF_FOLLOW_UP';
        return objPromoAction;
    }
    
    public static EUR_CRM_Visit_Action__c createVisitAction(EUR_CRM_Account__c euaccount, EUR_CRM_ObjPromo__c promo){
        EUR_CRM_Visit_Action__c visit = new EUR_CRM_Visit_Action__c();
        visit.EUR_CRM_Account__c = euaccount.id;
        visit.EUR_CRM_ObjPromo__c =  promo.Id;
        return visit;
    }
    
    public static EUR_CRM_SKU__c createSKU(String name, String articleno, String recordtypename ){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_SKU__c'+recordtypename);
        EUR_CRM_SKU__c sku= new EUR_CRM_SKU__c (
            recordtypeid=recordtypeId,name = name,
            EUR_CRM_Article_no__c= articleno);
        insert sku;
        return sku;
    }
    
    public static List<EUR_CRM_ObjPromo_Target__c> createOPTarget(integer numberofOPTarget, String recordTypeDeveloperName, Id objPromoId, Id opTargetId){
        
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Target__c'+ recordTypeDeveloperName);
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
    
    public static EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c createProsSegmentMapping(EUR_CRM_ObjPromo__c promo,String recordTypeDeveloperName){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c'+ recordTypeDeveloperName);
        EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c p = new EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c();
        p.EUR_CRM_Group_Outlet_Type__c = 'Restaurant';
        p.EUR_CRM_Image_Level__c = 'Iconic';
        p.EUR_CRM_ObjPromo__c = promo.Id;
        p.recordtypeId = recordtypeId;
        return p;
    }
    
    public static EUR_CRM_PRS_Group_Outlet_Type__c createGroupOutletType(string recordTypeDeveloperName){
        
        Id groupOutletTypeRtId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Group_Outlet_Type__c'+ recordTypeDeveloperName);
        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = new EUR_CRM_PRS_Group_Outlet_Type__c(EUR_CRM_Group_Outlet_Type_Name__c = 'Restrurant',
                                                                                                recordTypeId = groupOutletTypeRtId);
        
        return groupOutletType;
    }
    
    public static EUR_CRM_Customer_Taxonomy__c createCustomerTaxonomy(String name, String recordtypename){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_Customer_Taxonomy__c'+ recordtypename);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c
            (recordtypeid=recordtypeId,
             name = name
            );
        
        return customerTaxonomy;
    }
    public static EUR_CRM_OP_Customer_Taxonomy_Mapping__c createCustomerTaxonomyMapping(String recordtypename, Id customerTaxonomyid, Id objectPromoId){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_OP_Customer_Taxonomy_Mapping__c'+ recordtypename);
        EUR_CRM_OP_Customer_Taxonomy_Mapping__c customerTaxonomyMap = new EUR_CRM_OP_Customer_Taxonomy_Mapping__c
            (recordtypeid=recordtypeId,
             EUR_CRM_Customer_Taxonomy__c=customerTaxonomyid,
             EUR_CRM_ObjPromo__c = objectPromoId             
            );
        
        return customerTaxonomyMap;
    }
    
    public static EUR_CRM_ObjPromo_Account_Mapping__c createobjPromoAccMapping(String recordtypename, Id accountId, Id objectPromoId){
        Id recordtypeId = Global_RecordTypeCache.getRtId('EUR_CRM_ObjPromo_Account_Mapping__c'+ recordtypename);
        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMap = new EUR_CRM_ObjPromo_Account_Mapping__c
            (recordtypeid=recordtypeId,
             EUR_CRM_Account__c	=accountId,
             EUR_CRM_ObjPromo__c = objectPromoId             
            );
        
        return objPromoAccMap;
    }
    
    public static User createUser(String profileName, String roleName, String userEmail, String userName, String lastName){
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName]; 
        UserRole r = [select id from UserRole where Developername =:roleName ];
        User u = new User(Alias = 'standt', Email=userEmail, userroleid=r.id,
        EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',  
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=userName,
        BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate,ESN_User_AutojoinByAffiliates,ChatterEmailSettings');
        return u;
    }
    
    
    
}