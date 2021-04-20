/*
Author:         IPC
Company:        IP Converge Data Services,Inc.
Description:    Utility class specific to Germany EMEA Project
Functionalities:
1. Generate Users -
2. Generate Regions -
3. Generate Territories - 
4. Generate Customer Taxonomy - 
5. Generate Postal Account mapping
6. Generate EU Germany Accounts
7. Generate Objective Promotion header
8. Generate Visit Actions, Visits
9. Generate Promo Action, Action List Template, OP Pros Segment, OP Promo Variation
History
2/7/2014      IPC    Created
31/7/2014     IPC    Added Visit Actions, Visits
1/8/2014      IPC    Added Promo Actions, Action List Template, OP Pros Segment, OP Promo Variation
*/
@isTest
public  class EUR_CRM_DE_TestClassUtilityHelper {

    public final static String NATIONAL_OFF_TRADE_MANAGER_ROLE = 'EUR_DE_National_Sales_Manager_Off_Trade';
    public final static String REGIONAL_OFF_TRADE_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade';
    public final static String SR_OFF_TRADE_ROLE = 'EUR_DE_BZL';
    public final static String DE_OFF_TRADE_USER_PROFILE = 'EUR DE OFF Trade User';

    public final static String NATIONAL_ON_TRADE_MANAGER_ROLE = 'EUR_DE_National_Sales_Manager_On_Trade';
    public final static String REGIONAL_ON_TRADE_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_On_Trade'; // there is no such role
//    public final static String SR_ON_TRADE_ROLE = 'EUR_DE_GSL'; //no such role on the production
    public final static String SR_ON_TRADE_ROLE = 'EUR_DE';
    public final static String DE_ON_TRADE_USER_PROFILE = 'EUR DE ON Trade User';

    public final static String DE_TERRITORY_RECORD_TYPE = 'EUR DE Territory';
    public final static String DE_REGION_RECORD_TYPE = 'EUR DE Region';
    public final static String DE_POSTAL_CODE_MAPPING_RECORD_TYPE = 'DE Off Trade Postal Code - Territory Mapping';
    public final static String DE_POSTAL_CODE_MAPPING_ON_TRADE_RECORD_TYPE = 'DE On Trade Postal Code - Territory Mapping';
    public final static String DE_CUSTOMER_TAXONOMY_RECORD_TYPE =  'EUR DE Customer Taxonomy';
    public final static String DE_EUACCOUNT_RECORD_TYPE = 'EUR DE Off Trade Retail';
    public final static String DE_ACTION_LIST_TEMPLATE_RECORD_TYPE = 'DE O/P Action List Template';
    public final static String DE_ACTION_LIST_TEMPLATE_EXT_ID = 'DE_OFF_ALT_Leaflet_Campaign';
    public final static String TEST_POSTAL = '12345';

    public final static String OP_DE_PROS_LISTING_CAMPAIGN = 'DE On Trade PROS Segment Listing Campaign';
    public final static String OP_DE_ON_TRADE_PROS_TMKT_PROMO = 'DE On Trade PROS TMKT Promo';
    public final static String OP_DE_LEAFLET_CAMPAIGN = 'DE Off Trade Leaflet Campaign';
    public final static String OP_DE_SALES_DRIVE = 'DE Off Trade Sales Drive';
    public final static String OP_DE_TASTING_CAMPAIGN = 'DE Off Trade Tasting Campaign';
    public final static String OP_DE_TRADE_FAIR = 'DE Off Trade Trade Fair';
    public final static String OP_DE_SECONDARY_PLACEMENT_CARTON = 'DE Off Trade Secondary Placement - Carton';
    public final static String OP_DE_SECONDARY_PLACEMENT_THEME = 'DE Off Trade Secondary Placement - Theme';
    public final static String DE_SKU = 'EUR DE SKU';
    public final static String DE_SIZE = 'EUR DE Size';

    public final static String DE_BRAND_RECORD_TYPE = 'EUR_DE_Brand';
    public final static String DE_QUALITY_RECORD_TYPE = 'EUR_DE_Quality';
    public final static String DE_CATEGORY_RECORD_TYPE = 'EUR DE Category';
    public final static String DE_WINE_SPIRIT_RECORD_TYPE = 'EUR DE Wine/Spirits';

    public final static String DE_EUACCOUNT_ON_CONSUMERS_RECORD_TYPE = 'DE ON Consumers';
    public final static String DE_EUACCOUNT_ON_GASTRONOMY_RECORD_TYPE = 'DE ON Gastronomy';
    public final static String DE_CONTRACT_RECORD_TYPE = 'EUR DE Contract';
    public final static String DE_MECHANIC_TYPE_RECORD_TYPE = 'EUR DE Mechanic Type';
    public final static String DE_MECHANIC_RECORD_TYPE = 'EUR_DE_Mechanic';
    public final static String DE_CONTRACT_MECHANIC_RECORD_TYPE = 'EUR_DE_Contract_Mechanic';
    public final static String DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE = 'EUR_DE_Focus_Brand';
    public final static String DE_CONTRACT_LISTING_POURING_RECORD_TYPE = 'EUR_DE_Listing_Pouring';
    public final static String DE_VOLUME_TRACKER_RECORD_TYPE = 'EUR_DE_Volume_Tracker';
    public final static String DE_VOLUME_TRACKER_ITEM_RECORD_TYPE = 'EUR DE Volume Tracker Line Item';


    public final static String DE_BUDGET_RECORD_TYPE = 'DE On Trade WKZ';
    public final static String DE_TRANSACTION_RECORD_TYPE = 'DE On Trade WKZ';

    //CREATE USER
    public static User createUser(String profileName, String roleName, String userEmail, String userName, String lastName){
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName];
        UserRole r = [select id from UserRole where Developername =:roleName ];
        User u = new User(Alias = 'standt', Email=userEmail, userroleid=r.id,
                EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                BypassTriggers__c = 'Autofollow_User_InsertUpdate;AutoJoin_User_InsertUpdate;ESN_User_AutojoinByAffiliates;ChatterEmailSettings');
        insert u;
        return u;
    }

    //CREATE REGION
    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner,  String recordtypename){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Region__c',recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=recordtypeId,name = name,EUR_CRM_Region_Owner__c = regionOwner, ownerid = regionOwner, EUR_CRM_Channel__c = 'OFF TRADE');
        insert region;
        return region;
    }

    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner, String recordtypename, String channel) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Region__c',recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(
                recordtypeid=recordtypeId,
                name = name,
                ownerid = regionOwner,
                EUR_CRM_Region_Owner__c = regionOwner,
                EUR_CRM_Channel__c = channel
        );
        insert region;
        return region;
    }

    //CREATE Territory
    public static EUR_CRM_Territory__c createTerritory(String name, Id territoryOwner, Id regionId, String recordtypename){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Territory__c',recordtypename);
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = regionId, recordtypeid=recordtypeId,name = name,
                EUR_CRM_Territory_Owner__c = territoryOwner);
        system.debug('@territory'+territory);
        insert territory;
        return territory;
    }

    //CREATE EUR_CRM_Postal_Code_Territory_Mapping__c
    public static EUR_CRM_Postal_Code_Territory_Mapping__c createPostalCodeMapping(String name, String postalCode, Id territoryid, String recordtypename){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Postal_Code_Territory_Mapping__c',recordtypename);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c
                (EUR_CRM_Postal_Code__c = postalCode, recordtypeid=recordtypeId,name = name,
                        EUR_CRM_Territory__c = territoryid);
        insert postalCodeTerritoryMapping;
        return postalCodeTerritoryMapping;
    }

    //CREATE EUR_CRM_Postal_Code_City_Mapping__c
    public static EUR_CRM_Postal_Code_City_Mapping__c createPostalCodeCityMaping(String name, String postalCode,String cityName,String recordtypename){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Postal_Code_City_Mapping__c',recordtypename);
        EUR_CRM_Postal_Code_City_Mapping__c postalCodeCityMapping = new EUR_CRM_Postal_Code_City_Mapping__c(
                Name = name,
                recordtypeid=recordtypeId,
                EUR_CRM_Postal_Code__c = postalCode,
                EUR_CRM_City__c = cityName
        );
        insert postalCodeCityMapping;
        return postalCodeCityMapping;
    }

    //CREATE EUR_CRM_Customer_Taxonomy__c
    public static EUR_CRM_Customer_Taxonomy__c createCustomerTaxonomy(String name,   Id ownerId, String recordtypename){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c',recordtypename);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c
                (recordtypeid=recordtypeId,name = name,
                        ownerid  = ownerId );
        insert customerTaxonomy;
        return customerTaxonomy;
    }
    //CREATE EUR_CRM_Account__c
    public static EUR_CRM_Account__c creaEUAccount(String name, String postalCode , String recordtypename, Id customerTaxonomy){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
                EUR_CRM_Postal_Code__c = postalCode,
                recordtypeid=recordtypeId,
                name = name,
                EUR_JB_Customer_Taxonomy__c =customerTaxonomy, EUR_CRM_Owner_Role_API_Name__c = 'EMEA');
        insert euAccount;
        return euAccount;
    }

    public static EUR_CRM_Account__c creaEUAccount(String name, String postalCode , String recordtypename, Id customerTaxonomy, String channel){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
                recordtypeid=recordtypeId,
                name = name,
                EUR_JB_Customer_Taxonomy__c =customerTaxonomy, EUR_CRM_Owner_Role_API_Name__c = 'EMEA',
                EUR_CRM_Postal_Code__c = postalCode,
                EUR_CRM_Channel__c = channel);
        insert euAccount;
        return euAccount;
    }


    public static EUR_CRM_Account__c creaEUAccount(String name, String postalCode, String City,String Street , String Company, String recordtypename, Id customerTaxonomy, Id terrId){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
                EUR_CRM_Postal_Code__c = postalCode,
                EUR_CRM_Territory__c = terrId, EUR_CRM_Channel__c = 'OFF TRADE',
                EUR_CRM_Street__c = Street,
                EUR_CRM_Company_Establishment__c = Company,
                EUR_CRM_Comp_Establishment_Name_legally__c = Company,
                recordtypeid=recordtypeId,
                name = name,
                EUR_JB_Customer_Taxonomy__c =customerTaxonomy,EUR_CRM_Owner_Role_API_Name__c = 'EMEA' );
        insert euAccount;
        return euAccount;
    }
    //CREATE Sales Agency EUR_CRM_Account__c
    public static EUR_CRM_Account__c createSalesAgencyManagedEUAccount(String name, String postalCode , String recordtypename, Id customerTaxonomy){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
                EUR_CRM_Postal_Code__c = postalCode,
                recordtypeid=recordtypeId,name = name,
                EUR_JB_Customer_Taxonomy__c =customerTaxonomy );
        euAccount.EUR_CRM_Status__c = 'Sales Agency Managed';
        insert euAccount;
        return euAccount;
    }

    /*public static EUR_CRM_Account__c createEUAccountOnTrade (String name, String postalCode , String recordtypename, String territoryRecordTypeName){
EUR_CRM_Region__c testRegion = EUR_CRM_DE_TestClassUtilityHelper.createRegion('Test_Region', UserInfo.getUserId(),'DE Region');
//insert testRegion;
EUR_CRM_Territory__c testOnTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('TEST_TERRITORY' , UserInfo.getUserId(), testRegion.id, 'DE Territory');
//insert testOnTradeTerritory;
EUR_CRM_Postal_Code_Territory_Mapping__c testOnTradeTerritoryMapping= EUR_CRM_DE_TestClassUtilityHelper.createPostalCodeMapping('TEST_TERRITORY_MAPPING', postalCode , testOnTradeTerritory.id, territoryRecordTypeName);
//insert testOnTradeTerritoryMapping;
EUR_CRM_Customer_Taxonomy__c testCustTaxonomy = EUR_CRM_DE_TestClassUtilityHelper.createCustomerTaxonomy('TEST_TAXONOMY', UserInfo.getUserId(), 'DE Customer Taxonomy');
//insert testCustTaxonomy;

EUR_CRM_Account__c accountEU = EUR_CRM_DE_TestClassUtilityHelper.creaEUAccount(name, postalCode, recordtypename, testCustTaxonomy.Id);
return accountEU;

}*/



    //CREATE PRESTIGE EUR_CRM_Account__c
    public static EUR_CRM_Account__c creaPrestigeEUAccount(String name, String postalCode , String recordtypename, Id customerTaxonomy){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',recordtypename);
        EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
                EUR_CRM_Postal_Code__c = postalCode,
                recordtypeid=recordtypeId,name = name,
                EUR_JB_Customer_Taxonomy__c =customerTaxonomy,
                EUR_CRM_Is_Prestige_Account__c = true );
        insert euAccount;
        return euAccount;
    }

    public static EUR_CRM_SKU__c createSKU(String name, String articleno, String recordtypename ){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_SKU__c',recordtypename);
        EUR_CRM_SKU__c sku= new EUR_CRM_SKU__c (
                recordtypeid=recordtypeId,name = name,
                EUR_CRM_Article_no__c= articleno);
        insert sku;
        return sku;
    }
    public static EUR_CRM_OP_Action_List_Template__c creaActionListTemplate(String name, String externalId, String recordtypename ){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c',recordtypename);
        EUR_CRM_OP_Action_List_Template__c actionListTemplate= new EUR_CRM_OP_Action_List_Template__c(
                recordtypeid=recordtypeId,name = name,
                EUR_CRM_External_ID__c = externalId);
        insert actionListTemplate;
        return actionListTemplate;
    }
    public static EUR_CRM_Size__c createSIZE(String name, String recordtypename ){
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Size__c',recordtypename);
        EUR_CRM_Size__c size = new EUR_CRM_Size__c(
                recordtypeid=recordtypeId,name = name );
        insert size ;
        return size ;
    }

    //CREATE Objectives / Promotions
    public static List<EUR_CRM_ObjPromo__c> createObjPromo(integer numberofObjPromo, String recordTypeDeveloperName, String Name){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo__c> objPromoList = new List<EUR_CRM_ObjPromo__c>();

        for(integer i = 0;i < numberofObjPromo;i++){
            EUR_CRM_ObjPromo__c objPromo = new EUR_CRM_ObjPromo__c();
            objPromo.RecordTypeId = recordtypeId;
            objPromo.Name = Name;
            objPromoList.add(objPromo);
        }

        return objPromoList;
    }

    //CREATE O/P Target
    public static List<EUR_CRM_ObjPromo_Target__c> createOPTarget(integer numberofOPTarget, String recordTypeDeveloperName, Id objPromoId, Id opTargetId){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Target__c', recordTypeDeveloperName);
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

    //CREATE Visit Action
    public static List<EUR_CRM_Visit_Action__c> createVisitAction(integer numberofVisitAction, String recordTypeDeveloperName, Id objPromoId, Id opTargetId){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c', recordTypeDeveloperName);
        List<EUR_CRM_Visit_Action__c> visitActionList = new List<EUR_CRM_Visit_Action__c>();

        for(integer i = 0;i < numberofVisitAction;i++){
            EUR_CRM_Visit_Action__c visitAction = new EUR_CRM_Visit_Action__c();
            visitAction.RecordTypeId = recordtypeId;
            visitAction.EUR_CRM_ObjPromo__c = objPromoId;
            visitAction.EUR_CRM_ObjPromo_Target__c = opTargetId;
            visitActionList.add(visitAction);
        }

        return visitActionList;
    }

    //CREATE Visits
    public static List<EUR_CRM_Visit__c> createVisit(integer numberofVisit, String recordTypeDeveloperName, Id accountEUId){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit__c', recordTypeDeveloperName);
        List<EUR_CRM_Visit__c> visitList = new List<EUR_CRM_Visit__c>();

        for(integer i = 0;i < numberofVisit;i++){
            EUR_CRM_Visit__c visit = new EUR_CRM_Visit__c();
            visit.RecordTypeId = recordtypeId;
            visit.EUR_CRM_Account__c = accountEUId;
            visitList.add(visit);
        }

        return visitList;
    }

    //CREATE O/P Action List Template
    public static List<EUR_CRM_OP_Action_List_Template__c> createActionTemplate(integer numberofActionTemplate, String recordTypeDeveloperName, String externalId){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', recordTypeDeveloperName);
        List<EUR_CRM_OP_Action_List_Template__c> actionTemplateList = new List<EUR_CRM_OP_Action_List_Template__c>();

        for(integer i = 0;i < numberofActionTemplate;i++){
            EUR_CRM_OP_Action_List_Template__c actionTemplate = new EUR_CRM_OP_Action_List_Template__c();
            actionTemplate.RecordTypeId = recordtypeId;
            actionTemplate.EUR_CRM_External_ID__c = externalId;
            actionTemplateList.add(actionTemplate);
        }

        return actionTemplateList;
    }

    //CREATE Promo Actions
    public static List<EUR_CRM_ObjPromo_Action__c> createPromoAction(integer numberofPromoAction, String recordTypeDeveloperName, Id actionListTemp){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_Action__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo_Action__c> promoActionList = new List<EUR_CRM_ObjPromo_Action__c>();

        for(integer i = 0;i < numberofPromoAction;i++){
            EUR_CRM_ObjPromo_Action__c promoAction = new EUR_CRM_ObjPromo_Action__c();
            promoAction.RecordTypeId = recordtypeId;
            promoAction.EUR_CRM_OP_Action_List_Template__c = actionListTemp;
            promoActionList.add(promoAction);
        }

        return promoActionList;
    }

    //CREATE Pros Segment
    public static List<EUR_CRM_ObjPromo_PROS_Segment__c> createProsSegment(integer numberofProsSegment, String recordTypeDeveloperName, String outletType, String outletImage){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_PROS_Segment__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo_PROS_Segment__c> prosSegmentList = new List<EUR_CRM_ObjPromo_PROS_Segment__c>();

        for(integer i = 0;i < numberofProsSegment;i++){
            EUR_CRM_ObjPromo_PROS_Segment__c prosSegment = new EUR_CRM_ObjPromo_PROS_Segment__c();
            prosSegment.RecordTypeId = recordtypeId;
            prosSegment.EUR_CRM_Outlet_Type__c = outletType;
            prosSegment.EUR_CRM_Outlet_Image__c = outletImage;
            prosSegmentList.add(prosSegment);
        }

        return prosSegmentList;
    }

    //CREATE Promo Variation
    public static List<EUR_CRM_ObjPromo_OnTrade_Variation__c> createPromoVariation(integer numberofPromoVariation, String recordTypeDeveloperName, String pvName){

        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_ObjPromo_OnTrade_Variation__c', recordTypeDeveloperName);
        List<EUR_CRM_ObjPromo_OnTrade_Variation__c> promoVariationList = new List<EUR_CRM_ObjPromo_OnTrade_Variation__c>();

        for(integer i = 0;i < numberofPromoVariation;i++){
            EUR_CRM_ObjPromo_OnTrade_Variation__c promoVariation = new EUR_CRM_ObjPromo_OnTrade_Variation__c();
            promoVariation.RecordTypeId = recordtypeId;
            promoVariation.Name = pvName;
            promoVariationList.add(promoVariation);
        }

        return promoVariationList;
    }

    public static User nationalUser;
    public static User regionalUser;
    public static User salesRepUser;

    public static  void initUsers(){
        nationalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE,
                NATIONAL_OFF_TRADE_MANAGER_ROLE,'testdezxc1@testemail.com', 'testdezxc1@testemail.com', 'testdezxc1');

        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE,
                REGIONAL_OFF_TRADE_MANAGER_ROLE,'testdezxc2@testemail.com', 'testdezxc2@testemail.com', 'testdezxc2');

        salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_OFF_TRADE_USER_PROFILE,
                SR_OFF_TRADE_ROLE,'testdezxc3@testemail.com', 'testdezxc3@testemail.com', 'testdezxc3');
    }

    public static void initUsersOntrade(){
        nationalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                NATIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc4@testemail.com', 'testdezxc4@testemail.com', 'testdezxc4');

//        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
//                                                                    REGIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');

        salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }
    /*(Alias = 'standt', Email=userEmail, userroleid=r.id,
                          EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                          BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate,ESN_User_AutojoinByAffiliates,ChatterEmailSettings');*/

    public static void initUsersOntradeDE(){
        Profile p = [SELECT Id FROM Profile WHERE Name =: DE_ON_TRADE_USER_PROFILE];
        List<UserRole> roleList = [select id, Developername from UserRole where Developername =:NATIONAL_ON_TRADE_MANAGER_ROLE or DeveloperName =:REGIONAL_ON_TRADE_MANAGER_ROLE or Developername =:SR_ON_TRADE_ROLE];

        Map<Id, String> userRoleIdMap = new Map<Id, String>();
        for (UserRole role: roleList){
            userRoleIdMap.put(role.Id,role.DeveloperName);
        }
        List<User> initUserList = [select Id, UserName, Email, LastName, userroleid, ProfileId from User where userroleid =: userRoleIdMap.keySet() and ProfileId =: p.id];

        List<User> nationalUserList = new List<User>();
        List<User> regionalUserList = new List<User>();
        List<User> salesRepUserList = new List<User>();

        for (User initUser: initUserList){
            if (userRoleIdMap.get(initUser.userroleid)==NATIONAL_ON_TRADE_MANAGER_ROLE){
                nationalUserList.add(initUser);
            }else if (userRoleIdMap.get(initUser.userroleid)==REGIONAL_ON_TRADE_MANAGER_ROLE){
                regionalUserList.add(initUser);
            }else if (userRoleIdMap.get(initUser.userroleid)==SR_ON_TRADE_ROLE){
                salesRepUserList.add(initUser);
            }
        }
        nationalUser = nationalUserList.get(0);
        regionalUser = regionalUserList.get(0);
        salesRepUser = salesRepUserList.get(0);

        /*
        nationalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                                                                    NATIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc4@testemail.com', 'testdezxc4@testemail.com', 'testdezxc4');

        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                                                                    REGIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');

        salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                                                                    SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
*/
    }


    public static void initRegionalUser() {
        regionalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                REGIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc7@testemail.com', 'testdezxc7@testemail.com', 'testdezxc7');

        salesRepUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                SR_ON_TRADE_ROLE,'testdezxc8@testemail.com', 'testdezxc8@testemail.com', 'testdezxc8');
    }

    public static EUR_CRM_Region__c region;
    public static EUR_CRM_Territory__c territory;
    public static EUR_CRM_Postal_Code_Territory_Mapping__c postalmapping;
    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy;
    public static EUR_CRM_Account__c euAccount;
    public static EUR_CRM_OP_Action_List_Template__c actionListTemplate;
    public static EUR_CRM_SKU__c sku;
    public static EUR_CRM_Size__c bqs;

    public static void initByData(EUR_CRM_Region__c d_region, EUR_CRM_Territory__c d_territory,
            EUR_CRM_Postal_Code_Territory_Mapping__c d_postalmapping,
            EUR_CRM_Customer_Taxonomy__c d_customerTaxonomy,
            EUR_CRM_OP_Action_List_Template__c d_actionListTemplate){
        region = d_region;
        territory = d_territory;
        postalmapping = d_postalmapping;
        customerTaxonomy = d_customerTaxonomy;
        d_actionListTemplate = d_actionListTemplate;
    }

    // Function Hits 101 SOQL Query
    public static  void initData(){
        regionalUser = new User(Id = UserInfo.getUserId());
        salesRepUser = new User(Id = UserInfo.getUserId());
        System.Debug('@@INIT - initData');
        System.Debug('@@INIT - initData:createRegion');
        region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', regionalUser.id,  DE_REGION_RECORD_TYPE);
        System.debug('### SOQL LIMITS initData 1:'+Limits.getQueries());
        System.Debug('@@INIT - initData:createTerritory');
        territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', salesRepUser.id,region.id, DE_TERRITORY_RECORD_TYPE);
        System.debug('### SOQL LIMITS initData 2:'+Limits.getQueries());
        System.Debug('@@INIT - initData:createPostalCodeMapping');
        postalmapping = createPostalCodeMapping('postalmap' , TEST_POSTAL , territory.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        System.debug('### SOQL LIMITS initData 3:'+Limits.getQueries());
        System.Debug('@@INIT - initData:createCustomerTaxonomy');
        customerTaxonomy = createCustomerTaxonomy('testtaxonomy', regionalUser.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
        System.debug('### SOQL LIMITS initData 4:'+Limits.getQueries());
        System.Debug('@@INIT - initData:creaActionListTemplate');
        try{
            actionListTemplate = creaActionListTemplate('testsdfsdf',DE_ACTION_LIST_TEMPLATE_EXT_ID ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE );
        }catch(Exception e){
            actionListTemplate = [select id FROM EUR_CRM_OP_Action_List_Template__c Where EUR_CRM_External_ID__c =: DE_ACTION_LIST_TEMPLATE_EXT_ID];
        }
        creaActionListTemplate('testsdfsdf','DE_OFF_ALT_Sales_Drive' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        creaActionListTemplate('testsdfsdf','DE_OFF_ALT_2nd_PL_Carton' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        creaActionListTemplate('testsdfsdf','DE_OFF_ALT_2nd_PL_Theme' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        creaActionListTemplate('testsdfsdf','DE_OFF_ALT_Tasting' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        creaActionListTemplate('testsdfsdf','DE_OFF_ALT_Trade_Fair' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        System.Debug('@@INIT - initData: euAccount');
        //creaEUAccount(String name, String postalCode, String City,String Street , String Company, String recordtypename, Id customerTaxonomy)
        euAccount = creaEUAccount('testname', TEST_POSTAL ,'München', 'Bettinas Bar 1','Bettinas Bar' ,DE_EUACCOUNT_RECORD_TYPE , customerTaxonomy.id, territory.id);
        System.debug('### SOQL LIMITS initData 5:'+Limits.getQueries());
        System.Debug('@@INIT - initData: sku');
        sku = createSKU('test', '23',DE_SKU);
        System.Debug('@@INIT - initData: CreateSize');
        bqs = createSIZE('test',DE_SIZE);
    }

    public static  void initSalesAgencyData(){
        System.Debug('@@INIT - initSalesAgencyData');
        region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', regionalUser.id,  DE_REGION_RECORD_TYPE);

        territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', salesRepUser.id,region.id, DE_TERRITORY_RECORD_TYPE);

        postalmapping = createPostalCodeMapping('postalmap' , TEST_POSTAL , territory.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        customerTaxonomy = createCustomerTaxonomy('testtaxonomy', regionalUser.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
        actionListTemplate = creaActionListTemplate('testsdfsdf',DE_ACTION_LIST_TEMPLATE_EXT_ID ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE );
        //creaActionListTemplate('testsdfsdf','DE_OFF_ALT_Sales_Drive' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        //creaActionListTemplate('testsdfsdf','DE_OFF_ALT_2nd_PL_Carton' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        //creaActionListTemplate('testsdfsdf','DE_OFF_ALT_2nd_PL_Theme' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        //creaActionListTemplate('testsdfsdf','DE_OFF_ALT_Tasting' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );
        //creaActionListTemplate('testsdfsdf','DE_OFF_ALT_Trade_Fair' ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE  );

        euAccount = createSalesAgencyManagedEUAccount('testname', TEST_POSTAL , DE_EUACCOUNT_RECORD_TYPE , customerTaxonomy.id);
        sku = createSKU('test', '23',DE_SKU);
        bqs = createSIZE('test',DE_SIZE);
    }

    public static  void initDataOnTrade(){
        System.Debug('@@INIT - initDataOnTrade');
        region = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', regionalUser.id,  DE_REGION_RECORD_TYPE);
        System.debug('### SOQL Limits 2:'+Limits.getQueries());
        territory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', salesRepUser.id,region.id, DE_TERRITORY_RECORD_TYPE);
        System.debug('### SOQL Limits 3:'+Limits.getQueries());
        postalmapping = createPostalCodeMapping('postalmap' , TEST_POSTAL , territory.id, 'DE On Trade Postal Code - Territory Mapping');
        customerTaxonomy = createCustomerTaxonomy('testtaxonomy', regionalUser.id, DE_CUSTOMER_TAXONOMY_RECORD_TYPE);
        //   actionListTemplate = creaActionListTemplate('testsdfsdf',DE_ACTION_LIST_TEMPLATE_EXT_ID ,DE_ACTION_LIST_TEMPLATE_RECORD_TYPE );
        System.debug('### SOQL Limits 4:'+Limits.getQueries());
//        euAccount = creaEUAccount('testname', TEST_POSTAL , DE_EUACCOUNT_ON_CONSUMERS_RECORD_TYPE , customerTaxonomy.id);
        euAccount = creaEUAccount('testname', TEST_POSTAL , DE_EUACCOUNT_ON_GASTRONOMY_RECORD_TYPE , customerTaxonomy.id);
        //System.debug('### SOQL Limits 5:'+Limits.getQueries());
    }


    //Create Contract Activity Item
    public static EUR_CRM_Contract_Activity_Item__c createContractActivityItem(String recordTypeDeveloperName, Id contractId, Id mechanicType){
        System.Debug('@@INIT - createContractActivityItem');
        EUR_CRM_Contract_Activity_Item__c contractActivity = new EUR_CRM_Contract_Activity_Item__c();
        contractActivity.EUR_CRM_Contract__c = contractId;
        contractActivity.EUR_CRM_Mechanic_Type__c = mechanicType;

        return contractActivity;
    }
    //Create Contract Product Item
    public static EUR_CRM_Contract_Product_Item__c createContractProductItem(String recordTypeDeveloperName, Id contractActivityId, EUR_CRM_Brand__c product){
        System.Debug('@@INIT - createContractProductItem');
        EUR_CRM_Contract_Product_Item__c contractProduct = new EUR_CRM_Contract_Product_Item__c();
        contractProduct.EUR_CRM_Contract_Activity_Item__c = contractActivityId;
        contractProduct.EUR_CRM_Brand__c = product.Id;

        return contractProduct;
    }

    public static EUR_CRM_Contract_Product_Item__c createContractProductItem(String recordTypeDeveloperName, Id contractActivityId, EUR_CRM_Quality__c product){
        System.Debug('@@INIT - createContractProductItem');
        EUR_CRM_Contract_Product_Item__c contractProduct = new EUR_CRM_Contract_Product_Item__c();
        contractProduct.EUR_CRM_Contract_Activity_Item__c = contractActivityId;
        contractProduct.EUR_CRM_Brand_Quality__c = product.Id;

        return contractProduct;
    }

    //Create Contract Focus Brand Item
    public static EUR_CRM_Contract_Focus_Brand__c createContractFocusBrandItem(String recordTypeDeveloperName, Id contractId, Id brandId){
        System.Debug('@@INIT - createContractFocusBrandItem');
        EUR_CRM_Contract_Focus_Brand__c contractFocusBrand = new EUR_CRM_Contract_Focus_Brand__c();
        contractFocusBrand.EUR_CRM_Contract__c = contractId;
        contractFocusBrand.EUR_CRM_Brand__c = brandId;

        if (recordTypeDeveloperName != null){
            Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract_Focus_Brand__c', recordTypeDeveloperName);
            contractFocusBrand.RecordTypeId = recordtypeId;
        }
        return contractFocusBrand;
    }

    //Create Contract Listing Pouring Item
    public static EUR_CRM_Contract_Listing_Pouring__c createContractListingPouringItem(String recordTypeDeveloperName, Id contractId,
            Id bqId, Boolean listing, Boolean pouring){
        System.Debug('@@INIT - createContractListingPouringItem');
        EUR_CRM_Contract_Listing_Pouring__c contractListingPouring = new EUR_CRM_Contract_Listing_Pouring__c();
        contractListingPouring.EUR_CRM_Contract__c = contractId;
        contractListingPouring.EUR_CRM_Brand_Quality__c = bqId;
        contractListingPouring.EUR_CRM_Listing__c = listing;
        contractListingPouring.EUR_CRM_Pouring__c = pouring;

        if (recordTypeDeveloperName != null){
            Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Contract_Listing_Pouring__c', recordTypeDeveloperName);
            contractListingPouring.RecordTypeId = recordtypeId;
        }
        return contractListingPouring;
    }

    //Create Budget Header
    public static EUR_CRM_Budget__c createBudget(String recordTypeDeveloperName, Id userId,
            String fiscalYear, String externalId,
            Decimal allocatedBudget, Decimal carryForward){
        System.Debug('@@INIT - createBudget1');
        EUR_CRM_Budget__c budget = new EUR_CRM_Budget__c();
        if (recordTypeDeveloperName != null){
            Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Budget__c', recordTypeDeveloperName);
            budget.RecordTypeId = recordtypeId;
        }
        budget.OwnerId = userId;
        budget.EUR_CRM_Fiscal_Year__c = fiscalYear;
        //budget.EUR_CRM_External_ID__c = externalId;
        budget.EUR_CRM_Allocated_Budget__c = allocatedBudget;
        budget.EUR_CRM_Carry_Forward__c = carryForward;

        return budget;
    }

    public static EUR_CRM_Budget__c createBudget(String recordTypeDeveloperName, Id userId,
            String fiscalYear,
            Decimal allocatedBudget, Decimal carryForward){
        System.Debug('@@INIT - createBudget2');
        EUR_CRM_Budget__c budget = new EUR_CRM_Budget__c();
        if (recordTypeDeveloperName != null){
            Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Budget__c', recordTypeDeveloperName);
            budget.RecordTypeId = recordtypeId;
        }
        budget.OwnerId = userId;
        budget.EUR_CRM_Fiscal_Year__c = fiscalYear;
        budget.EUR_CRM_Allocated_Budget__c = allocatedBudget;
        budget.EUR_CRM_Carry_Forward__c = carryForward;

        return budget;
    }

    //Create Debit Transactions
    public static List<EUR_CRM_Budget_Transaction__c> createDebitTransactions (String recordTypeDeveloperName, Id budgetId,
            Integer numberOfTxn, Decimal amount,
            String transactionCategory){
        System.Debug('@@INIT - createDebitTransactions');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Budget_Transaction__c', recordTypeDeveloperName);
        List<EUR_CRM_Budget_Transaction__c> transactions = new List<EUR_CRM_Budget_Transaction__c>();

        for(Integer i=0; i<=numberOfTxn; i++){
            EUR_CRM_Budget_Transaction__c txn= new EUR_CRM_Budget_Transaction__c();
            txn.RecordTypeId = recordtypeId;
            txn.EUR_CRM_Budget_Header__c = budgetId;
            txn.EUR_CRM_Amount__c = amount;
            txn.EUR_CRM_Transaction_Category__c = transactionCategory;
            txn.EUR_CRM_Transaction_Type__c = 'Debit';
            transactions.add(txn);
        }
        return transactions;
    }
    //Create Credit Transactions
    public static List<EUR_CRM_Budget_Transaction__c> createCreditTransactions (String recordTypeDeveloperName, Id budgetId,Integer numberOfTxn, Decimal amount, String transactionCategory){
        System.Debug('@@INIT - createCreditTransactions');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Budget_Transaction__c', recordTypeDeveloperName);
        List<EUR_CRM_Budget_Transaction__c> transactions = new List<EUR_CRM_Budget_Transaction__c>();

        for(Integer i=0; i<=numberOfTxn; i++){
            EUR_CRM_Budget_Transaction__c txn = new EUR_CRM_Budget_Transaction__c();
            txn.RecordTypeId = recordtypeId;
            txn.EUR_CRM_Budget_Header__c = budgetId;
            txn.EUR_CRM_Amount__c = amount;
            txn.EUR_CRM_Transaction_Category__c = transactionCategory;
            txn.EUR_CRM_Transaction_Type__c = 'Credit';
            transactions.add(txn);
        }
        return transactions;
    }
    //Create Initial Load Budget Transaction
    public static EUR_CRM_Budget_Transaction__c createBudgetInitialLoad(String recordTypeDeveloperName, Id budgetId,Decimal amount){
        System.Debug('@@INIT - createBudgetInitialLoad');
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Budget_Transaction__c', recordTypeDeveloperName);
        EUR_CRM_Budget_Transaction__c txn= new EUR_CRM_Budget_Transaction__c();
        txn.RecordTypeId = recordtypeId;
        txn.EUR_CRM_Budget_Header__c = budgetId;
        txn.EUR_CRM_Amount__c = amount;
        txn.EUR_CRM_Transaction_Category__c = 'Initial Load';
        txn.EUR_CRM_Transaction_Type__c = 'Credit';

        return txn;
    }



    public static User offTradeNationalManager;
    public static User offTradeRegion1Manager;
    public static User offTradeRegion1SalesRep1;
    public static User offTradeRegion1SalesRep2;
    public static User offTradeRegion2Manager;
    public static User offTradeRegion2SalesRep1;
    public static User offTradeRegion2SalesRep2;
    public static User offTradeRegion3Manager;
    public static User offTradeRegion3SalesRep1;
    public static User offTradeRegion3SalesRep2;
    public static EUR_CRM_Region__c offTradeRegion1;
    public static EUR_CRM_Region__c offTradeRegion2;
    public static EUR_CRM_Region__c offTradeRegion3;
    public static EUR_CRM_Territory__c offTradeTerritory1;
    public static EUR_CRM_Territory__c offTradeTerritory2;
    public static EUR_CRM_Territory__c offTradeTerritory3;
    public static EUR_CRM_Territory__c offTradeTerritory4;
    public static EUR_CRM_Territory__c offTradeTerritory5;
    public static EUR_CRM_Territory__c offTradeTerritory6;

    public final static String REGIONAL_OFF_TRADE_NORTH_EAST_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    public final static String SR_OFF_TRADE_NORTH_EAST_ROLE = 'EUR_DE_BZL_Nord_East';
    public final static String REGIONAL_OFF_TRADE_SOUTH_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_South';
    public final static String SR_OFF_TRADE_SOUTH_ROLE = 'EUR_DE_BZL_South';
    public final static String REGIONAL_OFF_TRADE_WEST_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_West';
    public final static String SR_OFF_TRADE_WEST_ROLE = 'EUR_DE_BZL_West';

    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy1;
    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy2;
    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy3;
    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy4;
    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy5;
    public static EUR_CRM_Customer_Taxonomy__c customerTaxonomy6;

    public static EUR_CRM_Account__c offTradeAccount1;
    public static EUR_CRM_Account__c offTradeAccount2;
    public static EUR_CRM_Account__c offTradeAccount3;
    public static EUR_CRM_Account__c offTradeAccount4;
    public static EUR_CRM_Account__c offTradeAccount5;
    public static EUR_CRM_Account__c offTradeAccount6;

    private static User createUser(Id pId, Id rId, String userEmail, String userName, String lastName){
        System.Debug('@@INIT - createUser');
        User u = new User(Alias = 'standt', Email=userEmail, userroleid=rId,
                EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = pId,
                TimeZoneSidKey='America/Los_Angeles', UserName=userName,
                BypassTriggers__c = 'Autofollow_User_InsertUpdate;EUR_CRM_RU_UpdateAccountMgrHandlr;AutoJoin_User_InsertUpdate;ESN_User_AutojoinByAffiliates;ChatterEmailSettings;EUR_CRM_ZA_UpdateSOTeleSalesHandler;EUR_CRM_ZA_UpdateContractSalesMngrHandlr;EUR_CRM_RU_UpdateAccountMgrHandlr');
        return u;
    }

    public static void initOffTradeUsersLite(){
        System.Debug('@@INIT - initOffTradeUsersLite');
        Profile ps = [SELECT Id FROM Profile WHERE Name =: DE_OFF_TRADE_USER_PROFILE];
        Id p = ps.id;
        Map<String,Id> roleMap = new Map<String,Id>();

        for(UserRole r : [select id,Developername from UserRole where Developername in: new Set<String>{
                NATIONAL_OFF_TRADE_MANAGER_ROLE,
                REGIONAL_OFF_TRADE_NORTH_EAST_MANAGER_ROLE,
                SR_OFF_TRADE_NORTH_EAST_ROLE,
                REGIONAL_OFF_TRADE_SOUTH_MANAGER_ROLE,
                SR_OFF_TRADE_SOUTH_ROLE,
                REGIONAL_OFF_TRADE_WEST_MANAGER_ROLE,
                SR_OFF_TRADE_WEST_ROLE
        }]){
            roleMap.put(r.Developername,r.id);
        }
        List<User> userList = new List<User>();
        offTradeNationalManager = createUser(p, roleMap.get(NATIONAL_OFF_TRADE_MANAGER_ROLE),'offTradeNationalManager@testemail.com', 'offTradeNationalManager@testemail.com', 'offTradeNationalManager');
        userList.add(offTradeNationalManager);
        //north east
        offTradeRegion1Manager = createUser(p,roleMap.get(REGIONAL_OFF_TRADE_NORTH_EAST_MANAGER_ROLE),'offTradeRegion1Manager@testemail.com', 'offTradeRegion1Manager@testemail.com', 'offTradeRegion1Manager');
        userList.add(offTradeRegion1Manager);
        offTradeRegion1SalesRep1 = createUser(p, roleMap.get(SR_OFF_TRADE_NORTH_EAST_ROLE),'offTradeRegion1SalesRep1@testemail.com', 'offTradeRegion1SalesRep1@testemail.com', 'offTradeRegion1SalesRep1');
        userList.add(offTradeRegion1SalesRep1);
        offTradeRegion1SalesRep2 = createUser(p, roleMap.get(SR_OFF_TRADE_NORTH_EAST_ROLE),'offTradeRegion1SalesRep2@testemail.com', 'offTradeRegion1SalesRep2@testemail.com', 'offTradeRegion1SalesRep2');
        userList.add(offTradeRegion1SalesRep2);
        insert userList;
    }


    //On Trade Data Creation
    public static EUR_CRM_Region__c onTradeRegion;
    public static EUR_CRM_Territory__c onTradeTerritory;
    public static User onTradeNationalUser;
    public static USer onTradeRegionManager;
    public static User onTradeRegionSalesRep;
    public static EUR_CRM_Customer_Taxonomy__c ontrdcustomerTaxonomy;


    public static void initUsersOntradeLite(){
        onTradeNationalUser = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                NATIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc4@testemail.com', 'testdezxc4@testemail.com', 'testdezxc4');

        onTradeRegionManager = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                REGIONAL_ON_TRADE_MANAGER_ROLE,'testdezxc5@testemail.com', 'testdezxc5@testemail.com', 'testdezxc5');

        onTradeRegionSalesRep = EUR_CRM_DE_TestClassUtilityHelper.createUser(DE_ON_TRADE_USER_PROFILE,
                SR_ON_TRADE_ROLE,'testdezxc6@testemail.com', 'testdezxc6@testemail.com', 'testdezxc6');
    }

    public static void initOnTradeDataSetLite()
    {
        System.Debug('@@INIT - initOnTradeDataSetLite');

        onTradeRegion = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', onTradeRegionManager.id,  DE_REGION_RECORD_TYPE);

        onTradeTerritory = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', onTradeRegionSalesRep.id, onTradeRegion.id, DE_TERRITORY_RECORD_TYPE);

        createPostalCodeMapping('postalmap1' , '11111' , onTradeTerritory.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList = new List<EUR_CRM_Customer_Taxonomy__c>();

        Id customerTaxonomyDERecordType = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c',DE_CUSTOMER_TAXONOMY_RECORD_TYPE);

        ontrdcustomerTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
        ontrdcustomerTaxonomy.recordtypeid=customerTaxonomyDERecordType;
        ontrdcustomerTaxonomy.name='on trade customer taxonomy';
        ontrdcustomerTaxonomy.EUR_CRM_Chain_Name__c ='testchain1';
        ontrdcustomerTaxonomy.EUR_CRM_Level_1__c='chain1level1';
        ontrdcustomerTaxonomy.EUR_CRM_Level_2__c='chain1level2';
        ontrdcustomerTaxonomy.EUR_CRM_Level_3__c='chain1level3';
        ontrdcustomerTaxonomy.EUR_CRM_Level_4__c='chain1level4';
        ontrdcustomerTaxonomy.EUR_CRM_Level_5__c='chain1level5';
        ontrdcustomerTaxonomy.EUR_CRM_Level_6__c='chain1level6';
        ontrdcustomerTaxonomy.EUR_CRM_Level_7__c='chain1level7';
        ontrdcustomerTaxonomy.EUR_CRM_Level_8__c='chain1level8';
        ontrdcustomerTaxonomy.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(ontrdcustomerTaxonomy);

        insert customerTaxonomyList;

    }
    // Ontrade Data Creation


    public static void initOffTradeDataSetLite(){
        System.Debug('@@INIT - initOffTradeDataSetLite');
        offTradeRegion1 = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', offTradeRegion1Manager.id,  DE_REGION_RECORD_TYPE);

        offTradeTerritory1 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', offTradeRegion1SalesRep1.id,offTradeRegion1.id, DE_TERRITORY_RECORD_TYPE);

        createPostalCodeMapping('postalmap1' , '11111' , offTradeTerritory1.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList = new List<EUR_CRM_Customer_Taxonomy__c>();

        Id customerTaxonomyDERecordType = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c',DE_CUSTOMER_TAXONOMY_RECORD_TYPE);

        customerTaxonomy1 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy1.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy1.name='customerTaxonomy1';
        customerTaxonomy1.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy1.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy1.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy1.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy1.EUR_CRM_Level_4__c='chain1level4';
        customerTaxonomy1.EUR_CRM_Level_5__c='chain1level5';
        customerTaxonomy1.EUR_CRM_Level_6__c='chain1level6';
        customerTaxonomy1.EUR_CRM_Level_7__c='chain1level7';
        customerTaxonomy1.EUR_CRM_Level_8__c='chain1level8';
        customerTaxonomy1.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy1);

        insert customerTaxonomyList;


        List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();

        Id accountrecordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',DE_EUACCOUNT_RECORD_TYPE);
        offTradeAccount1 = new EUR_CRM_Account__c();
        offTradeAccount1.EUR_CRM_Postal_Code__c = '11111';
        offTradeAccount1.recordtypeid = accountrecordtypeId;
        offTradeAccount1.name = 'offTradeAccount1';
        //offTradeAccount1.EUR_JB_Customer_Taxonomy__c = customerTaxonomy1.id;
        offTradeAccount1.OwnerId = offTradeRegion1SalesRep1.id;
        euAccounts.add(offTradeAccount1);

        insert euAccounts;
        sku = createSKU('test', '23',DE_SKU);
        bqs = createSIZE('test',DE_SIZE);
    }
    public static void initOffTradeUsers(){
        System.Debug('@@INIT - initOffTradeUsers');
        Profile ps = [SELECT Id FROM Profile WHERE Name =: DE_OFF_TRADE_USER_PROFILE];
        Id p = ps.id;
        Map<String,Id> roleMap = new Map<String,Id>();

        for(UserRole r : [select id,Developername from UserRole where Developername in: new Set<String>{
                NATIONAL_OFF_TRADE_MANAGER_ROLE,
                REGIONAL_OFF_TRADE_NORTH_EAST_MANAGER_ROLE,
                SR_OFF_TRADE_NORTH_EAST_ROLE,
                REGIONAL_OFF_TRADE_SOUTH_MANAGER_ROLE,
                SR_OFF_TRADE_SOUTH_ROLE,
                REGIONAL_OFF_TRADE_WEST_MANAGER_ROLE,
                SR_OFF_TRADE_WEST_ROLE
        }]){
            roleMap.put(r.Developername,r.id);
        }
        List<User> userList = new List<User>();
        offTradeNationalManager = createUser(p, roleMap.get(NATIONAL_OFF_TRADE_MANAGER_ROLE),'offTradeNationalManager@testemail.com', 'offTradeNationalManager@testemail.com', 'offTradeNationalManager');
        userList.add(offTradeNationalManager);
        //north east
        offTradeRegion1Manager = createUser(p,roleMap.get(REGIONAL_OFF_TRADE_NORTH_EAST_MANAGER_ROLE),'offTradeRegion1Manager@testemail.com', 'offTradeRegion1Manager@testemail.com', 'offTradeRegion1Manager');
        userList.add(offTradeRegion1Manager);
        offTradeRegion1SalesRep1 = createUser(p, roleMap.get(SR_OFF_TRADE_NORTH_EAST_ROLE),'offTradeRegion1SalesRep1@testemail.com', 'offTradeRegion1SalesRep1@testemail.com', 'offTradeRegion1SalesRep1');
        userList.add(offTradeRegion1SalesRep1);
        offTradeRegion1SalesRep2 = createUser(p, roleMap.get(SR_OFF_TRADE_NORTH_EAST_ROLE),'offTradeRegion1SalesRep2@testemail.com', 'offTradeRegion1SalesRep2@testemail.com', 'offTradeRegion1SalesRep1');
        userList.add(offTradeRegion1SalesRep2);
        //south
        offTradeRegion2Manager = createUser(p,roleMap.get(REGIONAL_OFF_TRADE_SOUTH_MANAGER_ROLE),'offTadeRegion2Manager@testemail.com', 'offTadeRegion2Manager@testemail.com', 'offTadeRegion2Manager');
        userList.add(offTradeRegion2Manager);
        offTradeRegion2SalesRep1 = createUser(p,roleMap.get(SR_OFF_TRADE_SOUTH_ROLE),'offTradeRegion2SalesRep1@testemail.com', 'offTradeRegion2SalesRep1@testemail.com', 'offTradeRegion2SalesRep1');
        userList.add(offTradeRegion2SalesRep1);
        offTradeRegion2SalesRep2 = createUser(p,roleMap.get(SR_OFF_TRADE_SOUTH_ROLE),'offTradeRegion2SalesRep2@testemail.com', 'offTradeRegion2SalesRep2@testemail.com', 'offTradeRegion2SalesRep2');
        userList.add(offTradeRegion2SalesRep2);
        //west
        offTradeRegion3Manager= createUser(p, roleMap.get(REGIONAL_OFF_TRADE_WEST_MANAGER_ROLE),'offTradeRegion3Manager@testemail.com', 'offTradeRegion3Manager@testemail.com', 'offTradeRegion3Manager');
        userList.add(offTradeRegion3Manager);
        offTradeRegion3SalesRep1 = createUser(p,roleMap.get(SR_OFF_TRADE_WEST_ROLE),'offTradeRegion3SalesRep1@testemail.com', 'offTradeRegion3SalesRep1@testemail.com', 'offTradeRegion3SalesRep1');
        userList.add(offTradeRegion3SalesRep1);
        offTradeRegion3SalesRep2 = createUser(p,roleMap.get(SR_OFF_TRADE_WEST_ROLE),'offTradeRegion3SalesRep2@testemail.com', 'offTradeRegion3SalesRep2@testemail.com', 'offTradeRegion3SalesRep2');
        userList.add(offTradeRegion3SalesRep2);
        insert userList;
    }
    public static void initOffTradeDataSet(){
        System.Debug('@@INIT - initOffTradeDataSet');
        offTradeRegion1 = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region1', offTradeRegion1Manager.id,  DE_REGION_RECORD_TYPE);
        offTradeRegion2 = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region2', offTradeRegion2Manager.id,  DE_REGION_RECORD_TYPE);
        offTradeRegion3 = EUR_CRM_DE_TestClassUtilityHelper.createRegion('region3', offTradeRegion3Manager.id,  DE_REGION_RECORD_TYPE);

        offTradeTerritory1 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory1', offTradeRegion1SalesRep1.id,offTradeRegion1.id, DE_TERRITORY_RECORD_TYPE);
        offTradeTerritory2 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory2', offTradeRegion1SalesRep2.id,offTradeRegion1.id, DE_TERRITORY_RECORD_TYPE);
        offTradeTerritory3 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory3', offTradeRegion2SalesRep1.id,offTradeRegion2.id, DE_TERRITORY_RECORD_TYPE);
        offTradeTerritory4 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory4', offTradeRegion2SalesRep2.id,offTradeRegion2.id, DE_TERRITORY_RECORD_TYPE);
        offTradeTerritory5 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory5', offTradeRegion3SalesRep1.id,offTradeRegion3.id, DE_TERRITORY_RECORD_TYPE);
        offTradeTerritory6 = EUR_CRM_DE_TestClassUtilityHelper.createTerritory('territory6', offTradeRegion3SalesRep2.id,offTradeRegion3.id, DE_TERRITORY_RECORD_TYPE);

        createPostalCodeMapping('postalmap1' , '11111' , offTradeTerritory1.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        createPostalCodeMapping('postalmap2' , '22222' , offTradeTerritory2.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        createPostalCodeMapping('postalmap3' , '33333' , offTradeTerritory3.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        createPostalCodeMapping('postalmap4' , '44444' , offTradeTerritory4.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        createPostalCodeMapping('postalmap5' , '55555' , offTradeTerritory5.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);
        createPostalCodeMapping('postalmap6' , '66666' , offTradeTerritory6.id, DE_POSTAL_CODE_MAPPING_RECORD_TYPE);

        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList = new List<EUR_CRM_Customer_Taxonomy__c>();

        Id customerTaxonomyDERecordType = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c',DE_CUSTOMER_TAXONOMY_RECORD_TYPE);

        customerTaxonomy1 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy1.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy1.name='customerTaxonomy1';
        customerTaxonomy1.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy1.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy1.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy1.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy1.EUR_CRM_Level_4__c='chain1level4';
        customerTaxonomy1.EUR_CRM_Level_5__c='chain1level5';
        customerTaxonomy1.EUR_CRM_Level_6__c='chain1level6';
        customerTaxonomy1.EUR_CRM_Level_7__c='chain1level7';
        customerTaxonomy1.EUR_CRM_Level_8__c='chain1level8';
        customerTaxonomy1.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy1);

        customerTaxonomy2 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy2.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy2.name='customerTaxonomy2';
        customerTaxonomy2.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy2.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy2.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy2.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy2.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy2);

        customerTaxonomy3 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy3.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy3.name='customerTaxonomy3';
        customerTaxonomy3.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy3.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy3.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy3.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy3.EUR_CRM_Level_4__c='chain1level4';
        customerTaxonomy3.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy3);

        customerTaxonomy4 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy4.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy4.name='customerTaxonomy4';
        customerTaxonomy4.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy4.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy4.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy4.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy4.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy4);

        customerTaxonomy5 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy5.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy5.name='customerTaxonomy5';
        customerTaxonomy5.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy5.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy5.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy5.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy5.EUR_CRM_Level_3__c='chain1level5';
        customerTaxonomy5.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy5);

        customerTaxonomy6 = new EUR_CRM_Customer_Taxonomy__c();
        customerTaxonomy6.recordtypeid=customerTaxonomyDERecordType;
        customerTaxonomy6.name='customerTaxonomy6';
        customerTaxonomy6.EUR_CRM_Chain_Name__c ='testchain1';
        customerTaxonomy6.EUR_CRM_Level_1__c='chain1level1';
        customerTaxonomy6.EUR_CRM_Level_2__c='chain1level2';
        customerTaxonomy6.EUR_CRM_Level_3__c='chain1level3';
        customerTaxonomy6.EUR_CRM_Management_Type__c = 'Regie';
        customerTaxonomyList.add(customerTaxonomy6);

        insert customerTaxonomyList;


        List<EUR_CRM_Account__c> euAccounts = new List<EUR_CRM_Account__c>();

        Id accountrecordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c',DE_EUACCOUNT_RECORD_TYPE);

        offTradeAccount1 = new EUR_CRM_Account__c();
        offTradeAccount1.EUR_CRM_Postal_Code__c = '11111';
        offTradeAccount1.recordtypeid = accountrecordtypeId;
        offTradeAccount1.name = 'offTradeAccount1';
        offTradeAccount1.EUR_JB_Customer_Taxonomy__c = customerTaxonomy1.id;
        euAccounts.add(offTradeAccount1);

        offTradeAccount2 = new EUR_CRM_Account__c();
        offTradeAccount2.EUR_CRM_Postal_Code__c = '22222';
        offTradeAccount2.recordtypeid = accountrecordtypeId;
        offTradeAccount2.name = 'offTradeAccount2';
        offTradeAccount2.EUR_JB_Customer_Taxonomy__c = customerTaxonomy2.id;
        euAccounts.add(offTradeAccount2);

        offTradeAccount3 = new EUR_CRM_Account__c();
        offTradeAccount3.EUR_CRM_Postal_Code__c = '33333';
        offTradeAccount3.recordtypeid = accountrecordtypeId;
        offTradeAccount3.name = 'offTradeAccount3';
        offTradeAccount3.EUR_JB_Customer_Taxonomy__c = customerTaxonomy3.id;
        euAccounts.add(offTradeAccount3);

        offTradeAccount4 = new EUR_CRM_Account__c();
        offTradeAccount4.EUR_CRM_Postal_Code__c = '44444';
        offTradeAccount4.recordtypeid = accountrecordtypeId;
        offTradeAccount4.name = 'offTradeAccount4';
        offTradeAccount4.EUR_JB_Customer_Taxonomy__c = customerTaxonomy4.id;
        euAccounts.add(offTradeAccount4);

        offTradeAccount5 = new EUR_CRM_Account__c();
        offTradeAccount5.EUR_CRM_Postal_Code__c = '55555';
        offTradeAccount5.recordtypeid = accountrecordtypeId;
        offTradeAccount5.name = 'offTradeAccount5';
        offTradeAccount5.EUR_JB_Customer_Taxonomy__c = customerTaxonomy4.id;
        euAccounts.add(offTradeAccount5);


//        offTradeAccount6 = new EUR_CRM_Account__c();
//        offTradeAccount6.EUR_CRM_Postal_Code__c = '66666';
//        offTradeAccount6.recordtypeid = accountrecordtypeId;
//        offTradeAccount6.name = 'offTradeAccount6';
//        offTradeAccount6.EUR_JB_Customer_Taxonomy__c = null;
//        euAccounts.add(offTradeAccount6);
        insert euAccounts;
        sku = createSKU('test', '23',DE_SKU);
        bqs = createSIZE('test',DE_SIZE);
    }
}