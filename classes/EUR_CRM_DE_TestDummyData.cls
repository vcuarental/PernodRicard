/**
*   Utility class used for generating Dummy Data for Test Methods
**/

@isTest
public class EUR_CRM_DE_TestDummyData
{

    /**
    * Variables
    **/

    private static Id RecordTypeId = null;
    public final static String DE_CUSTOMER_TAXONOMY_RECORD_TYPE_DEVELOPERNAME =  'EUR_DE_Customer_Taxonomy';
    public final static String DE_EUACCOUNT_RECORD_TYPE_DEVELOPERNAME = 'EUR_DE_OFF_STD';
    public final static String DE_POSTAL_CODE_MAPPING_RECORD_TYPE_DEVELOPERNAME = 'EUR_DE_Off_Trade_Postal_Code_Territory_Mapping';
    public final static String DE_REGION_RECORD_TYPE_DEVELOPERNAME =  'EUR_DE_Region';
    public final static String DE_TERRITORY_RECORD_TYPE_DEVELOPERNAME = 'EUR_DE_Territory';

    public final static String NATIONAL_OFF_TRADE_MANAGER_ROLE = 'EUR_DE_National_Sales_Manager_Off_Trade';
    public final static String REGIONAL_OFF_TRADE_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    public final static String SR_OFF_TRADE_ROLE = 'EUR_DE_BZL_Nord_East';
    public final static String DE_OFF_TRADE_USER_PROFILE = 'EUR DE OFF Trade User';
    public final static String NATIONAL_ON_TRADE_MANAGER_ROLE = 'EUR_DE_National_Sales_Manager_On_Trade';
    public final static String REGIONAL_ON_TRADE_MANAGER_ROLE = 'EUR_DE_Regional_Sales_Manager_On_Trade_North_East';
    public final static String SR_ON_TRADE_ROLE = 'EUR_DE_GSL_Nord_East';
    public final static String DE_ON_TRADE_USER_PROFILE = 'EUR DE ON Trade User';
    public final static String DE_TERRITORY_RECORD_TYPE = 'DE Territory';
    public final static String DE_REGION_RECORD_TYPE = 'DE Region';
    public final static String DE_POSTAL_CODE_MAPPING_RECORD_TYPE = 'DE Off Trade Postal Code - Territory Mapping';
    public final static String DE_POSTAL_CODE_MAPPING_ON_TRADE_RECORD_TYPE = 'DE On Trade Postal Code - Territory Mapping';
    public final static String DE_CUSTOMER_TAXONOMY_RECORD_TYPE =  'DE Customer Taxonomy';
    public final static String DE_EUACCOUNT_RECORD_TYPE = 'DE OFF STD';
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
    public final static String DE_BRAND_RECORD_TYPE = 'EUR DE Brand';
    public final static String DE_QUALITY_RECORD_TYPE = 'EUR DE Quality';
    public final static String DE_CATEGORY_RECORD_TYPE = 'EUR DE Category';
    public final static String DE_WINE_SPIRIT_RECORD_TYPE = 'EUR DE Wine/Spirits';
    public final static String DE_EUACCOUNT_ON_CONSUMERS_RECORD_TYPE = 'DE ON Consumers';
    public final static String DE_CONTRACT_RECORD_TYPE = 'DE Contract';
    public final static String DE_MECHANIC_TYPE_RECORD_TYPE = 'DE Mechanic Type';
    public final static String DE_MECHANIC_RECORD_TYPE = 'EUR_DE_Mechanic';
    public final static String DE_CONTRACT_MECHANIC_RECORD_TYPE = 'EUR_DE_Contract_Mechanic';
    public final static String DE_CONTRACT_FOCUS_BRAND_RECORD_TYPE = 'EUR_DE_Focus_Brand';
    public final static String DE_CONTRACT_LISTING_POURING_RECORD_TYPE = 'EUR_DE_Listing_Pouring';
    public final static String DE_VOLUME_TRACKER_RECORD_TYPE = 'EUR_DE_Volume_Tracker';
    public final static String DE_VOLUME_TRACKER_ITEM_RECORD_TYPE = 'EUR DE Volume Tracker Line Item';
    public final static String DE_BUDGET_RECORD_TYPE = 'DE On Trade WKZ';
    public final static String DE_TRANSACTION_RECORD_TYPE = 'DE On Trade WKZ';

    /**
    *   Description : This method will generate List of Account with Dummy Data
    *
    *   Parameters :
    *   @totalRecords : How many Records you want to generate ?
    *   @withIds : Do you want returned records with generateId? 
    **/
    public static List<Account> getAccounts(Integer totalRecords, Boolean withIds)
    {
        List<Account> retList = new List<Account>();
        for(Integer i=0;i<totalRecords;i++)
        {
            Account a = new Account(Name = constructTestString(20));
            retList.add(a);
        }
        if(withIds)
            insert retList;

        return retList;
    }

    /**
    *   This method is used to generate Random String of supplied length
    */
    public static String constructTestString(Integer length) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        return key.substring(0,length);
    }

    /**
    *   Description : This method will get Record type Id's from RecordType
    *
    *   Parameters :
    *   @Developername : Recordtype DeveloperName
    **/
    public static Id getRecordTypeId(String Developername,String SobjectType){
        if(RecordTypeId==null)
            RecordTypeId = [Select Id from RecordType where Developername=:Developername and SobjectType=:SobjectType].Id;  
        return RecordTypeId;
    }

    //CREATE USER
    public static List<User> getUser(String profileName, String roleName, String userEmail, String userName, String lastName,Integer totalRecords,Boolean withIds){
        List<User> usersList = new List<User>();
        for(Integer i=0;i<totalRecords;i++){
            Profile p = [SELECT Id FROM Profile WHERE Name =: profileName]; 
            UserRole r = [select id from UserRole where Developername =:roleName ];
            User u = new User(Alias = 'us'+constructTestString(4), Email=constructTestString(4)+userEmail, userroleid=r.id,
            EmailEncodingKey='UTF-8', LastName=lastName+constructTestString(4), LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=userName+constructTestString(4));
            usersList.add(u);
        }
        if(withIds && usersList.size()>0)
            insert usersList;
        return usersList;
    }


    //CREATE REGION
    public static List<EUR_CRM_Region__c> createRegion(String name, Id regionOwner,  String developername,Integer totalRecords,Boolean withIds){
        List<EUR_CRM_Region__c> regionList = new List<EUR_CRM_Region__c>();
        recordtypeId= null;
        recordtypeId = getRecordTypeId(developername,'EUR_CRM_Region__c');
        for(Integer i=0;i<totalRecords;i++){
            
            EUR_CRM_Region__c region = new EUR_CRM_Region__c(recordtypeid=recordtypeId,name = name,EUR_CRM_Region_Owner__c = regionOwner, ownerid = regionOwner);
            regionList.add(region);
        }
        if(withIds && regionList.size()>0) 
        insert regionList;
        return regionList;
    }
    //CREATE Territory
    public static List<EUR_CRM_Territory__c> createTerritory(String name, Id territoryOwner, Id regionId, String developername,Integer totalRecords,Boolean withIds){
        recordtypeId= null;
        recordtypeId = getRecordTypeId(developername,'EUR_CRM_Territory__c');
        List<EUR_CRM_Territory__c> territoryList = new List<EUR_CRM_Territory__c>();
        for(Integer i=0;i<totalRecords;i++){
            EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(EUR_CRM_Region__c = regionId, recordtypeid=recordtypeId,name = name,
            EUR_CRM_Territory_Owner__c = territoryOwner);
            territoryList.add(territory);
        }
        if(withIds && territoryList.size()>0) 
        insert territoryList;
        return territoryList;
    }

    //CREATE EUR_CRM_Postal_Code_Territory_Mapping__c
    public static List<EUR_CRM_Postal_Code_Territory_Mapping__c> createPostalCodeMapping(String name, String postalCode, Id territoryid, String developername,Integer totalRecords,Boolean withIds){
        recordtypeId= null;
        recordtypeId = getRecordTypeId(developername,'EUR_CRM_Postal_Code_Territory_Mapping__c');
        List<EUR_CRM_Postal_Code_Territory_Mapping__c> postalCodeTerritoryMappingList = new List<EUR_CRM_Postal_Code_Territory_Mapping__c>();
        for(Integer i=0;i<totalRecords;i++){
            EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c
            (EUR_CRM_Postal_Code__c = postalCode, recordtypeid=recordtypeId,name = name,
            EUR_CRM_Territory__c = territoryid);
            postalCodeTerritoryMappingList.add(postalCodeTerritoryMapping);
        }   
        if(withIds && postalCodeTerritoryMappingList.size()>0) 
        insert postalCodeTerritoryMappingList;
        return postalCodeTerritoryMappingList;
    }

    //CREATE EUR_CRM_Customer_Taxonomy__c
    public static List<EUR_CRM_Customer_Taxonomy__c> createCustomerTaxonomy(String name,   Id ownerId, String developername,Integer totalRecords,Boolean withIds){
        recordtypeId= null;
        recordtypeId = getRecordTypeId(developername,'EUR_CRM_Customer_Taxonomy__c');
        List<EUR_CRM_Customer_Taxonomy__c> customerTaxonomyList = new List<EUR_CRM_Customer_Taxonomy__c>();
        for(Integer i=0;i<totalRecords;i++){
            EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c
            (recordtypeid=recordtypeId,name = name+constructTestString(4),
            ownerid  = ownerId );
            customerTaxonomyList.add(customerTaxonomy);
        }    
        if(withIds && customerTaxonomyList.size()>0)
            insert customerTaxonomyList;
        return customerTaxonomyList;
    }

    //CREATE EUR_CRM_Account__c
    public static List<EUR_CRM_Account__c> creaEUAccount(String name, String postalCode , String developername, Id customerTaxonomy,Integer totalRecords,Boolean withIds){
        recordtypeId= null;
        recordtypeId = getRecordTypeId(developername,'EUR_CRM_Account__c');
        List<EUR_CRM_Account__c> euAccountList = new List<EUR_CRM_Account__c>();
        for(Integer i=0;i<totalRecords;i++){
            EUR_CRM_Account__c euAccount = new EUR_CRM_Account__c(
            EUR_CRM_Postal_Code__c = postalCode,
            recordtypeid=recordtypeId,
            name = name+constructTestString(4),
            EUR_JB_Customer_Taxonomy__c =customerTaxonomy );  
            euAccountList.add(euAccount);   
        }
        
        if(withIds && euAccountList.size()>0)
            insert euAccountList;
        return euAccountList;
    }


}