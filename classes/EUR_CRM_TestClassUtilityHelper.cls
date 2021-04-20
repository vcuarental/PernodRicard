/*------------------------------------------------------------
Author:         IPC
Company:        IP Converge Data Services,Inc.
Description:    Utility class that create test records to be used in Test class
History
23/04/2014      IPC    Created
24/04/2014      IPC    Added Image Level Threshold and Service Pack.
25/04/2014      IPC    Added Volume Potential Threshold
25/04/2014      IPC    Added Pros Volume Potential
25/04/2014      IPC    Added Pros Image Level
29/04/2014      IPC    Added Route Template, Route Template Item, Territory
30/04/2014      IPC    Added Visit Frequency, Events, Route Template Day, Territory Mapping
02/06/2014      IPC    Added Contract, Mechanic Type, Contract Line Item, Mechanic, Contract Mechanic, Wine/Spirits, Category, Brand, Brand Quality
03/06/2014      IPC    Added Stock Deal Mechanic
04/06/2014      IPC    Added Volume Tracker, Volume Tracker Line Item
18/06/2014      IPC    Added Template, Template Criteria
19/06/2014      IPC    Added Store Audit, Store Audit Item
30/06/2014      IPC    Added Objectives / Promotions, O/P Target
30/04/2015      IPC    Added Cocktail Menu, Contract Cocktail
------------------------------------------------------------*/
@isTest
public class EUR_CRM_TestClassUtilityHelper {
    //maps to hold the record type info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByDevName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    
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
            recordTypesByDevName.put(objectName, d.getRecordTypeInfosByDeveloperName());
            recordTypesById.put(objectName, d.getRecordTypeInfosById());
        }
    }

    public static Id getRecordTypeId(String objectName, String recordTypeName) {
    /*------------------------------------------------------------
    Description:   Gives record type id from a given sObject and record type label
    Inputs:        objectName - The sObject
                   recordTypeName - The name of the record type (NOT the API Name)
    Returns:       The specified record types id value
    ------------------------------------------------------------*/
        // make sure we have this object's record types mapped
        if (!recordTypesByName.containsKey(objectName)){
            fillMapsForRecordTypeObject(objectName);
        }

        // now grab and return the requested id 
        Map<String,Schema.RecordTypeInfo> rtMap = recordTypesByName.get(objectName);
        Map<String,Schema.RecordTypeInfo> rtDevMap = recordTypesByDevName.get(objectName);
        System.debug('##RTMAP: '+rtMap);
        Id rtId = null;
        if (rtMap != null && rtMap.containsKey(recordTypeName)) {
            return rtMap.get(recordTypeName).getRecordTypeId();
        } else if (rtDevMap != null && rtDevMap.containsKey(recordTypeName)) {
            return rtDevMap.get(recordTypeName).getRecordTypeId();
        }
        return null;
    }
    
    //CREATE USER
    public static User createUser(String profileName){
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName]; 
        User u = new User(Alias = 'standt', Email='testUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testUser_EUR@test.com');
        
        return u;
    }

    public static User createUser(String name, Id profId, Id roleId){
        return new User(Alias = 'standt', Email='userEmail1234aoke@test.com', userroleid=roleId,
                              EmailEncodingKey='UTF-8', LastName=name, LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId=profId, 
                              TimeZoneSidKey='America/Los_Angeles', UserName='userEmail1234aoke@test.com');
    }

    public static User createUser(String profileName, String roleName, String userEmail, String userName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        List<UserRole> r = [select id from UserRole where Developername = :roleName];
        User u = new User(Alias = 'standt', Email = userEmail, userroleid = (r.size() > 0) ? r[0].Id : null,
                EmailEncodingKey = 'UTF-8', LastName = lastName, LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = userName,
                BypassTriggers__c = 'Autofollow_User_InsertUpdate;AutoJoin_User_InsertUpdate;ESN_User_AutojoinByAffiliates;ChatterEmailSettings');
        return u;
    }    
    
    //CREATE Account
    public static List<Account> createAccounts(integer numberOfAccounts, String recordTypeDeveloperName){
    
        Id recordtypeId = getRecordTypeId('Account', recordTypeDeveloperName);
        System.debug('##RecordtypeId: '+recordtypeId);
        List<Account> accList = new List<Account>();
        
        for(integer i = 0;i < numberOfAccounts;i++){
            Account acc = new Account();
            acc.RecordTypeId = recordtypeId;
            acc.Name = 'TestAccount';
            
            accList.add(acc);
        }
        
        return accList;
    }
    
    //CREATE Account EU
    public static List<EUR_CRM_Account__c> createAccountsEU(integer numberOfEUAccounts, String recordTypeDeveloperName){
        Id userId = UserInfo.getUserId();
        
        EUR_CRM_Region__c region = createRegion(1, '', userId)[0];
        EUR_CRM_Territory__c territory = createTerritory(1, '', userId, region.Id)[0];
        EUR_CRM_Postal_Code_Territory_Mapping__c territoryMap = createTerritoryMapping(1, '', territory.Id)[0];
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Account__c', recordTypeDeveloperName);
        List<EUR_CRM_Account__c> accountEUList = new List<EUR_CRM_Account__c>();
        
        for(integer i = 0;i < numberOfEUAccounts;i++){
            EUR_CRM_Account__c accountEU = createAccountEU('TestAccount', recordtypeId);//new EUR_CRM_Account__c();
            accountEU.EUR_CRM_Territory__c = territory.Id;
            if(recordTypeDeveloperName.contains('EE ') ||recordTypeDeveloperName.contains('LT ')){
                accountEU.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
                accountEU.EUR_CRM_Postal_Code__c = '12345';
            } else  if(recordTypeDeveloperName.contains('LV ')){
                accountEU.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
                accountEU.EUR_CRM_Postal_Code__c = '1234';
            }
            accountEUList.add(accountEU);
        }
        
        return accountEUList;
    }

    public static EUR_CRM_Account__c createAccountEU(String name, Id rtId){
        return new EUR_CRM_Account__C(
                recordTypeId = rtId,
                Name = name,
                EUR_CRM_Business_Type__c = 'Outlet',
                EUR_CRM_Postal_Code__c = '1111',
                EUR_CRM_Channel__c = 'ON TRADE',
                EUR_CRM_Status__c = 'Active',
                EUR_CRM_Owner_Role_API_Name__c = 'EMEA'
//            accountEU.EUR_CRM_Sub_Channel__c = 'Nightclub';
            );
    }

    public static EUR_CRM_Account__c createAccountEU(String name, String postalCode, String rtName){
        Id recordtypeId = getRecordTypeId('EUR_CRM_Account__c', rtName);
        EUR_CRM_Account__C acc = createAccountEU(name, recordtypeId);
        acc.EUR_CRM_Postal_Code__c = postalCode;
        return acc;
    } 
    
    public static EUR_CRM_Account__c createAccountEU(String name, String postalCode, String city, String street, String company, String recordtypename, Id customerTaxonomy) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Account__c', recordtypename);
        EUR_CRM_Account__c euAccount = createAccountEU(name, recordtypeId);
        euAccount.EUR_CRM_Postal_Code__c = postalCode;
        euAccount.EUR_CRM_Street__c = street;
        euAccount.EUR_CRM_Company_Establishment__c = company;
        euAccount.EUR_CRM_Comp_Establishment_Name_legally__c = company;
        euAccount.EUR_JB_Customer_Taxonomy__c = customerTaxonomy;
        return euAccount;
    }

    //CREATE Criteria Set
    public static List<EUR_CRM_Criteria_Set__c> createCriteriaSet(integer numberOfEUCriteriaSet, String recordTypeDeveloperName){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Criteria_Set__c', recordTypeDeveloperName);
        List<EUR_CRM_Criteria_Set__c> criteriaSetEUList = new List<EUR_CRM_Criteria_Set__c>();
        
        for(integer i = 0;i < numberOfEUCriteriaSet;i++){
            EUR_CRM_Criteria_Set__c criteriaSetEU = new EUR_CRM_Criteria_Set__c();
            criteriaSetEU.RecordTypeId = recordtypeId;
            criteriaSetEU.EUR_CRM_Name__c = 'TESTCRITERIASET';
            criteriaSetEU.CurrencyIsoCode = 'EUR';
            criteriaSetEU.EUR_CRM_Last_Mass_Update_Date__c = System.Today();
            
            
            criteriaSetEUList.add(criteriaSetEU);
        }
        
        return criteriaSetEUList;
    }
    
    //CREATE Criteria Answer
    public static List<EUR_CRM_Criteria_Answer__c> createCriteriaAnswer(integer numberOfEUCriteriaAnswer, String recordTypeDeveloperName, Id criteriaThreshold){
        Id recordtypeId = getRecordTypeId('EUR_CRM_Criteria_Answer__c', recordTypeDeveloperName);
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerEUList = new List<EUR_CRM_Criteria_Answer__c>();
        
        for(integer i = 0;i < numberOfEUCriteriaAnswer;i++){
            EUR_CRM_Criteria_Answer__c criteriaAnswerEU = new EUR_CRM_Criteria_Answer__c();
            criteriaAnswerEU.RecordTypeId = recordtypeId;
            criteriaAnswerEU.EUR_CRM_Criteria_Threshold__c = criteriaThreshold;
            
            criteriaAnswerEUList.add(criteriaAnswerEU);
        }
        
        return criteriaAnswerEUList;
    }
    
    //CREATE Criteria Threshold
    public static List<EUR_CRM_Criteria_Threshold__c> createCriteriaThreshold(integer numberOfEUCriteriaSet, String recordTypeDeveloperName, Id criteriaSet){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Criteria_Threshold__c', recordTypeDeveloperName);
        List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdEUList = new List<EUR_CRM_Criteria_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUCriteriaSet;i++){
            EUR_CRM_Criteria_Threshold__c criteriaThresholdEU = new EUR_CRM_Criteria_Threshold__c();
            criteriaThresholdEU.RecordTypeId = recordtypeId;
            criteriaThresholdEU.CurrencyIsoCode = 'EUR';
            criteriaThresholdEU.EUR_CRM_Criteria_Set__c = criteriaSet;
            criteriaThresholdEU.EUR_CRM_Sequence__c = 1;
            criteriaThresholdEU.EUR_CRM_Question__c = 'TEST QUESTION';
            criteriaThresholdEU.EUR_CRM_Weight__c = 100;
            
            criteriaThresholdEUList.add(criteriaThresholdEU);
        }
        
        return criteriaThresholdEUList;
    }
    
    //CREATE Group Outlet Type
    public static List<EUR_CRM_Group_Outlet_Type__c> createGroupOutletType(integer numberOfEUGrpOutletType, String recordTypeDeveloperName, String currencyCode, Id imageCriteriaSet, Id volumeCriteriaSet){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Group_Outlet_Type__c', recordTypeDeveloperName);
        List<EUR_CRM_Group_Outlet_Type__c> grpOutletTypeEUList = new List<EUR_CRM_Group_Outlet_Type__c>();
        
        for(integer i = 0;i < numberOfEUGrpOutletType;i++){
            EUR_CRM_Group_Outlet_Type__c grpOutletTypeEU = new EUR_CRM_Group_Outlet_Type__c();
            grpOutletTypeEU.RecordTypeId = recordtypeId;
            grpOutletTypeEU.CurrencyIsoCode = currencyCode;
            grpOutletTypeEU.EUR_CRM_Image_Criteria_Set__c = imageCriteriaSet;
            grpOutletTypeEU.EUR_CRM_Volume_Criteria_Set__c = volumeCriteriaSet;
            grpOutletTypeEU.EUR_CRM_Name__c = 'TEST NAME';
            grpOutletTypeEU.EUR_CRM_Group_Outlet_Name__c='test 1';
            
            grpOutletTypeEUList.add(grpOutletTypeEU);
        }
        
        return grpOutletTypeEUList;
    }
    
    //CREATE Outlet Type
    public static List<EUR_CRM_Outlet_Type__c> createOutletType(integer numberOfEUOutletType, String recordTypeDeveloperName, String currencyCode, Id grpOutletType){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Outlet_Type__c', recordTypeDeveloperName);
        List<EUR_CRM_Outlet_Type__c> outletTypeEUList = new List<EUR_CRM_Outlet_Type__c>();
        
        for(integer i = 0;i < numberOfEUOutletType;i++){
            EUR_CRM_Outlet_Type__c outletTypeEU = new EUR_CRM_Outlet_Type__c();
            outletTypeEU.RecordTypeId = recordtypeId;
            outletTypeEU.CurrencyIsoCode = currencyCode;
            outletTypeEU.EUR_CRM_Active__c = true;
            outletTypeEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            outletTypeEU.EUR_CRM_Name__c = 'TEST NAME';
            
            outletTypeEUList.add(outletTypeEU);
        }
        
        return outletTypeEUList;
    }
    
    //CREATE Image Level
    public static List<EUR_CRM_Image_Level__c> createImageLevel(integer numberOfEUImageLevel, String recordTypeDeveloperName, String currencyCode, Id grpOutletType, String iLevelName){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Image_Level__c', recordTypeDeveloperName);
        List<EUR_CRM_Image_Level__c> imageLevelEUList = new List<EUR_CRM_Image_Level__c>();
        
        for(integer i = 0;i < numberOfEUImageLevel;i++){
            EUR_CRM_Image_Level__c imageLevelEU = new EUR_CRM_Image_Level__c();
            imageLevelEU.RecordTypeId = recordtypeId;
            imageLevelEU.CurrencyIsoCode = currencyCode;
            imageLevelEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            imageLevelEU.EUR_CRM_Min_Weight__c = 10;
            imageLevelEU.EUR_CRM_Name__c = iLevelName;
            
            imageLevelEUList.add(imageLevelEU);
        }
        
        return imageLevelEUList;
    }
    

    //CREATE Image Level Threshold
    public static List<EUR_CRM_Image_Level_Threshold__c> createImageLevelThreshold(integer numberOfEUILThreshold, Id grpOutletType, Id imageLevel){

        List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholdEUList = new List<EUR_CRM_Image_Level_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUILThreshold;i++){
            EUR_CRM_Image_Level_Threshold__c imageLevelThresholdEU = new EUR_CRM_Image_Level_Threshold__c();
            imageLevelThresholdEU.EUR_CRM_Name__c = 'Test Image Lvl Threshold';
            imageLevelThresholdEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            imageLevelThresholdEU.EUR_CRM_Image_Level__c = imageLevel;
            
            imageLevelThresholdEUList.add(imageLevelThresholdEU);
        }
        
        return imageLevelThresholdEUList;
    }
    
        //CREATE Image Level Threshold with Mimimum weight
    public static List<EUR_CRM_Image_Level_Threshold__c> createImageLevelThreshold(integer numberOfEUILThreshold, Id grpOutletType, Id imageLevel,Integer minWeight){

        List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholdEUList = new List<EUR_CRM_Image_Level_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUILThreshold;i++){
            EUR_CRM_Image_Level_Threshold__c imageLevelThresholdEU = new EUR_CRM_Image_Level_Threshold__c();
            imageLevelThresholdEU.EUR_CRM_Name__c = 'Test Image Lvl Threshold';
            imageLevelThresholdEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            imageLevelThresholdEU.EUR_CRM_Image_Level__c = imageLevel;
            imageLevelThresholdEU.EUR_CRM_Min_Weight__c = minWeight;
            imageLevelThresholdEUList.add(imageLevelThresholdEU);
        }
        
        return imageLevelThresholdEUList;
    }
    
    //CREATE Volume Potential
    public static List<EUR_CRM_Volume_Potential__c> createvolumePotential(integer numberOfEUVolumePotential, String recordTypeDeveloperName, String currencyCode, Id grpOutletType, String volPotentialName){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Volume_Potential__c', recordTypeDeveloperName);
        List<EUR_CRM_Volume_Potential__c> volumePotentialEUList = new List<EUR_CRM_Volume_Potential__c>();
        
        for(integer i = 0;i < numberOfEUVolumePotential;i++){
            EUR_CRM_Volume_Potential__c volumePotentialEU = new EUR_CRM_Volume_Potential__c();
            volumePotentialEU.RecordTypeId = recordtypeId;
            volumePotentialEU.CurrencyIsoCode = currencyCode;
            volumePotentialEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            volumePotentialEU.EUR_CRM_Min_Weight__c = 10;
            volumePotentialEU.EUR_CRM_Max_Weight__c = 100;
            volumePotentialEU.EUR_CRM_Name__c = volPotentialName;
            
            volumePotentialEUList.add(volumePotentialEU);
        }
        
        return volumePotentialEUList;
    }
    
    //CREATE Volume Potential Threshold
    public static List<EUR_CRM_Volume_Potential_Threshold__c> createvolumePotentialThreshold(integer numberOfEUVolumePotentialThreshold, Id grpOutletType, Id volPotential){
    
        List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentialTEUList = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUVolumePotentialThreshold;i++){
            EUR_CRM_Volume_Potential_Threshold__c volumePotentialTEU = new EUR_CRM_Volume_Potential_Threshold__c();
            volumePotentialTEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            volumePotentialTEU.EUR_CRM_Volume_Potential__c = volPotential;
            
            volumePotentialTEUList.add(volumePotentialTEU);
        }
        
        return volumePotentialTEUList;
    }    
    //CREATE Volume Potential Threshold with minmum weight
    public static List<EUR_CRM_Volume_Potential_Threshold__c> createvolumePotentialThreshold(integer numberOfEUVolumePotentialThreshold, Id grpOutletType, Id volPotential, Integer minWeight){
    
        List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentialTEUList = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUVolumePotentialThreshold;i++){
            EUR_CRM_Volume_Potential_Threshold__c volumePotentialTEU = new EUR_CRM_Volume_Potential_Threshold__c();
            volumePotentialTEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            volumePotentialTEU.EUR_CRM_Volume_Potential__c = volPotential;            
            volumePotentialTEU.EUR_CRM_Min_Weight__c = minWeight;
            volumePotentialTEUList.add(volumePotentialTEU);
        }
        
        return volumePotentialTEUList;
    }
    
    //CREATE Service Pack
    public static List<EUR_CRM_Service_Pack__c> createServicePack(integer numberOfEUServicePack, String recordTypeDeveloperName, String grpOutletType, String imageLevel){

        Id recordtypeId = getRecordTypeId('EUR_CRM_Service_Pack__c', recordTypeDeveloperName);
        List<EUR_CRM_Service_Pack__c> servicePackEUList = new List<EUR_CRM_Service_Pack__c>();
        
        for(integer i = 0;i < numberOfEUServicePack;i++){
            EUR_CRM_Service_Pack__c servicePackEU = new EUR_CRM_Service_Pack__c();
            servicePackEU.RecordTypeId = recordtypeId;
            servicePackEU.EUR_CRM_Outlet_Type__c = grpOutletType;
            servicePackEU.EUR_CRM_Segmentation__c = imageLevel;
            
            servicePackEUList.add(servicePackEU);
        }
        
        return servicePackEUList;
    }
    
    //CREATE Pros Segmentation
    public static List<EUR_CRM_Pros_Segmentation__c> createProsSegmentation(integer numberOfEUProsSegmentation, String recordTypeDeveloperName, String currencyCode, Id accountEU, Id grpOutletType, Id outletType, Id imageLevel, Id volumePotential, Id account){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Pros_Segmentation__c', recordTypeDeveloperName);
        List<EUR_CRM_Pros_Segmentation__c> prosSegmentationEUList = new List<EUR_CRM_Pros_Segmentation__c>();
        
        for(integer i = 0;i < numberOfEUProsSegmentation;i++){
            EUR_CRM_Pros_Segmentation__c prosSegmentationEU = new EUR_CRM_Pros_Segmentation__c();
            prosSegmentationEU.RecordTypeId = recordtypeId;
            prosSegmentationEU.CurrencyIsoCode = currencyCode;
            prosSegmentationEU.EUR_CRM_Account__c = accountEU;
            prosSegmentationEU.EUR_CRM_Standard_Account__c = account;
            prosSegmentationEU.EUR_CRM_Group_Outlet_Type__c = grpOutletType;
            prosSegmentationEU.EUR_CRM_Image_Level__c = imageLevel;
            prosSegmentationEU.EUR_CRM_Outlet_Type__c = outletType;
            prosSegmentationEU.EUR_CRM_Volume_Potential__c = volumePotential;
            
            prosSegmentationEUList.add(prosSegmentationEU);
        }
        
        return prosSegmentationEUList;
    }

    //CREATE Pros Volume Potential
    public static List<EUR_CRM_Pros_Volume_Potential__c> createProsVolumePotential(integer numberOfEUProsVolPotential, String recordTypeDeveloperName, String currencyCode, Id prosSegmentation, Id critThreshold){
    
        Id recordtypeId = getRecordTypeId('EUR_CRM_Pros_Volume_Potential__c', recordTypeDeveloperName);
        List<EUR_CRM_Pros_Volume_Potential__c> prosVolPotentialEUList = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        for(integer i = 0;i < numberOfEUProsVolPotential;i++){
            EUR_CRM_Pros_Volume_Potential__c prosVolPotentialEU = new EUR_CRM_Pros_Volume_Potential__c();
            prosVolPotentialEU.RecordTypeId = recordtypeId;
            prosVolPotentialEU.CurrencyIsoCode = currencyCode;
            prosVolPotentialEU.EUR_CRM_Answer__c = 'TEST ANSWER';
            prosVolPotentialEU.EUR_CRM_Criteria_Threshold__c = critThreshold;
            prosVolPotentialEU.EUR_CRM_Pros_Segmentation__c = prosSegmentation;
            prosVolPotentialEU.EUR_CRM_Weight__c = 100;
            
            prosVolPotentialEUList.add(prosVolPotentialEU);
        }
        
        return prosVolPotentialEUList;
    }
    
    //CREATE Pros Image Level
    public static List<EUR_CRM_Pros_Image_Level__c> createProsImageLevel(integer numberOfEUProsImageLevel, String currencyCode, Id prosSegmentation, Id critThreshold){
    
        List<EUR_CRM_Pros_Image_Level__c> prosImageLevelEUList = new List<EUR_CRM_Pros_Image_Level__c>();
        
        for(integer i = 0;i < numberOfEUProsImageLevel;i++){
            EUR_CRM_Pros_Image_Level__c prosImageLevelEU = new EUR_CRM_Pros_Image_Level__c();
            prosImageLevelEU.CurrencyIsoCode = currencyCode;
            prosImageLevelEU.EUR_CRM_Answer__c = 'TEST ANSWER';
            prosImageLevelEU.EUR_CRM_Criteria_Threshold__c = critThreshold;
            prosImageLevelEU.EUR_CRM_Pros_Segmentation__c = prosSegmentation;
            prosImageLevelEU.EUR_CRM_Weight__c = 100;
            
            prosImageLevelEUList.add(prosImageLevelEU);
        }
        
        return prosImageLevelEUList;
    }
    
    //CREATE Route Template
    public static List<EUR_CRM_Route_Template__c> createRouteTemplate(integer numberofEURouteTemp, String recordTypeDeveloperName, String currencyCode){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Route_Template__c', recordTypeDeveloperName);
        List<EUR_CRM_Route_Template__c> routeTemplateList = new List<EUR_CRM_Route_Template__c>();
        
        for(integer i = 0;i < numberofEURouteTemp;i++){
            EUR_CRM_Route_Template__c routeTemplate = new EUR_CRM_Route_Template__c();
            routeTemplate.RecordTypeId = recordtypeId;
            routeTemplate.CurrencyIsoCode = currencyCode;
            routeTemplate.EUR_CRM_Active__c = true;
            routeTemplate.EUR_CRM_Last_Date_Populated__c = System.Today();
            routeTemplate.EUR_CRM_Max_Planning_Period_Week__c = 4;
            routeTemplate.EUR_CRM_Max_Visit_Duration_Hour__c = 8;
            routeTemplate.EUR_CRM_Planning_Period__c = 1;
            routeTemplate.EUR_CRM_Reminder_Day__c = 1;
            routeTemplate.EUR_CRM_Reset_Week__c = 1;
            routeTemplate.EUR_CRM_Scheduled__c = true;
            routeTemplate.EUR_CRM_Visit_Duration__c = 2;
            
            routeTemplateList.add(routeTemplate);
        }
        
        return routeTemplateList;
    }
    
    //CREATE Route Template Item
    public static List<EUR_CRM_Route_Template_Item__c> createRouteTemplateItem(integer numberofEURouteTempItem, Id routeTemplate){
        
        List<EUR_CRM_Route_Template_Item__c> routeTemplateItemList = new List<EUR_CRM_Route_Template_Item__c>();
        
        for(integer i = 0;i < numberofEURouteTempItem;i++){
            EUR_CRM_Route_Template_Item__c routeTemplateItem = new EUR_CRM_Route_Template_Item__c();
            routeTemplateItem.EUR_CRM_Route_Template__c = routeTemplate;
            
            routeTemplateItemList.add(routeTemplateItem);
        }
        
        return routeTemplateItemList;
    }
    
    //CREATE Visit Frequency
    public static List<EUR_CRM_Visit_Frequency__c> createVisitFrequency(integer numberofEUVisitFreq, String recordTypeDeveloperName){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Visit_Frequency__c', recordTypeDeveloperName);
        List<EUR_CRM_Visit_Frequency__c> visitFrequencyList = new List<EUR_CRM_Visit_Frequency__c>();
        
        for(integer i = 0;i < numberofEUVisitFreq;i++){
            EUR_CRM_Visit_Frequency__c visitFrequency = new EUR_CRM_Visit_Frequency__c();
            visitFrequency.RecordTypeId = recordtypeId;
            visitFrequency.Name = 'Test Visit Freq';
            
            visitFrequencyList.add(visitFrequency);
        }
        
        return visitFrequencyList;
    }
    
    //CREATE Events
    public static List<Event> createEvents(integer numberofEUEvents, String recordTypeDeveloperName, Id eventRelatedTo, Id eventOwner, DateTime startDate, DateTime endTime){
        
        Id recordtypeId = getRecordTypeId('Event', recordTypeDeveloperName);
        List<Event> eventList = new List<Event>();
        
        for(integer i = 0;i < numberofEUEvents;i++){
            Event events= new Event();
            events.RecordTypeId = recordtypeId;
            events.WhatId = eventRelatedTo;
            events.StartDateTime = startDate;
            events.EndDateTime = endTime;
            events.OwnerId = eventOwner;
            events.Subject = 'Meeting';
            
            eventList.add(events);
        }
        
        return eventList;
    }
    
    //CREATE Route Template Day
    public static List<EUR_CRM_Route_Template_Day__c> createRouteTempDay(integer numberofEURouteTempDay, Id routeTemplateItem){
        
        List<EUR_CRM_Route_Template_Day__c> routeTempDayList = new List<EUR_CRM_Route_Template_Day__c>();
        
        for(integer i = 0;i < numberofEURouteTempDay;i++){
            EUR_CRM_Route_Template_Day__c routeTemp = new EUR_CRM_Route_Template_Day__c();
            routeTemp.EUR_CRM_Route_Template_Item__c = routeTemplateItem;
            
            routeTempDayList.add(routeTemp);
        }
        
        return routeTempDayList;
    }
    
    //CREATE Region
    public static List<EUR_CRM_Region__c> createRegion(integer numberOfEURegion, String currencyCode, Id user){
    
        List<EUR_CRM_Region__c> regionEUList = new List<EUR_CRM_Region__c>();
        
        for(integer i = 0;i < numberOfEURegion;i++){
            EUR_CRM_Region__c regionEU = new EUR_CRM_Region__c();
            regionEU.CurrencyIsoCode = currencyCode;
            regionEU.EUR_CRM_Region_Code__c = 'TEST CODE';
            regionEU.EUR_CRM_Region_Owner__c = user;
            regionEU.EUR_CRM_Channel__c = 'ON Trade & OFF Trade';
            regionEUList.add(regionEU);
        }
        
        return regionEUList;
    }

    public static EUR_CRM_Region__c createRegion(String name, Id regionOwner, String recordtypename) {
        Id recordtypeId = getRecordTypeId('EUR_CRM_Region__c', recordtypename);
        EUR_CRM_Region__c region = new EUR_CRM_Region__c(
            Recordtypeid = recordtypeId, 
            Name = name,
            EUR_CRM_Region_Owner__c = regionOwner,
            Ownerid = regionOwner,
            EUR_CRM_Channel__c = 'ON Trade & OFF Trade',
            EUR_CRM_Region_Code__c = 'TEST CODE'
        );
        return region;
    }    
    
    //CREATE Territory
    public static List<EUR_CRM_Territory__c> createTerritory(integer numberOfEUTerritory, String currencyCode, Id user, Id region){
    
        List<EUR_CRM_Territory__c> territoryEUList = new List<EUR_CRM_Territory__c>();
        
        for(integer i = 0;i < numberOfEUTerritory;i++){
            EUR_CRM_Territory__c territoryEU = new EUR_CRM_Territory__c();
            territoryEU.CurrencyIsoCode = currencyCode;
            territoryEU.EUR_CRM_Description__c = 'TEST DESCRIPTION';
            territoryEU.EUR_CRM_Territory_Owner__c = user;
            territoryEU.EUR_CRM_On_Trade_Owner__c = user;
            territoryEU.EUR_CRM_Off_Trade_Owner__c = user;
            territoryEU.EUR_CRM_Territory_Code__c = 'TEST CODE';
            territoryEU.EUR_CRM_Region__c = region;
            
            territoryEUList.add(territoryEU);
        }
        
        return territoryEUList;
    }

    public static EUR_CRM_Territory__c createTerritory(String name, Id territoryOwner, Id regionId, String recordtypename) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Territory__c', recordtypename);
        EUR_CRM_Territory__c territory = new EUR_CRM_Territory__c(
            EUR_CRM_Region__c = regionId, 
            Recordtypeid = recordtypeId, 
            Name = name,
            EUR_CRM_Territory_Owner__c = territoryOwner,
            EUR_CRM_On_Trade_Owner__c = territoryOwner,
            EUR_CRM_Off_Trade_Owner__c = territoryOwner,
            EUR_CRM_Territory_Code__c = 'TEST CODE'
        );

        return territory;
    }    
    
    //CREATE Territory Mapping
    public static List<EUR_CRM_Postal_Code_Territory_Mapping__c> createTerritoryMapping(integer numberOfEUTerritoryMap, String currencyCode, Id territory){

        List<EUR_CRM_Postal_Code_Territory_Mapping__c> territoryMapList = new List<EUR_CRM_Postal_Code_Territory_Mapping__c>();
        
        for(integer i = 0; i < numberOfEUTerritoryMap;i++){
            EUR_CRM_Postal_Code_Territory_Mapping__c territoryMap = new EUR_CRM_Postal_Code_Territory_Mapping__c();
            territoryMap.EUR_CRM_Postal_Code__c = '1111';
            territoryMap.CurrencyIsoCode = currencyCode;
            
            territoryMapList.add(territoryMap);
        }
        
        return territoryMapList;
    }

    public static EUR_CRM_Postal_Code_Territory_Mapping__c createPostalCodeMapping(String name, String postalCode, Id territoryid, String recordtypename) {
        Id recordtypeId = getRecordTypeId('EUR_CRM_Postal_Code_Territory_Mapping__c', recordtypename);
        EUR_CRM_Postal_Code_Territory_Mapping__c postalCodeTerritoryMapping = new EUR_CRM_Postal_Code_Territory_Mapping__c(
            EUR_CRM_Postal_Code__c = postalCode, 
            Recordtypeid = recordtypeId, 
            Name = name,
            EUR_CRM_Territory__c = territoryid
        );

        return postalCodeTerritoryMapping;
    }    
    
    //CREATE Contract
    public static List<EUR_CRM_Contract__c> createContracts(integer numberofContracts, String recordTypeDeveloperName, Id accountEU, Date startDate, Date endDate){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Contract__c', recordTypeDeveloperName);
        List<EUR_CRM_Contract__c> contractList = new List<EUR_CRM_Contract__c>();
        
        for(integer i = 0;i < numberofContracts;i++){
            EUR_CRM_Contract__c contract = new EUR_CRM_Contract__c();
            contract.RecordTypeId = recordtypeId;
            contract.EUR_CRM_Account__c = accountEU;
            contract.EUR_CRM_Start_Date__c = startDate;
            contract.EUR_CRM_End_Date__c = endDate;
            
            contractList.add(contract);
        }
        
        return contractList;
    }

    public static EUR_CRM_Contract__c createContract(Id accId, Id rtId, Date startDate, Date endDate){
        return new EUR_CRM_Contract__c(
                recordTypeId = rtId,
                EUR_CRM_Account__c = accId,
                EUR_CRM_Start_Date__c = startDate,
                EUR_CRM_End_Date__c = endDate,
                EUR_CRM_Status__c = 'Draft',
                EUR_CRM_Is_this_contract_profitable__c = 100
            );
    }
    
    //CREATE Mechanic Type
    public static List<EUR_CRM_Mechanic_Type__c> createMechType(integer numberofMechType, String recordTypeDeveloperName, String Name){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Mechanic_Type__c', recordTypeDeveloperName);
        List<EUR_CRM_Mechanic_Type__c> mechTypeList = new List<EUR_CRM_Mechanic_Type__c>();
        
        for(integer i = 0;i < numberofMechType; i++){
            EUR_CRM_Mechanic_Type__c mechType = new EUR_CRM_Mechanic_Type__c();
            mechType.RecordTypeId = recordtypeId;
            mechType.EUR_CRM_Lump_Sum_Or_Per_BQ__c = true;
            mechType.Name = Name;
            mechTypeList.add(mechType);
        }
        
        return mechTypeList;
    }
    
    public static Map<String, EUR_CRM_Mechanic_Type__c> createMechTypes(List<String> mechTypeNames, Id rtId){
        Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap = new Map<String, EUR_CRM_Mechanic_Type__c>();

        for(String mechTypeName: mechTypeNames) {
            EUR_CRM_Mechanic_Type__c mechType = new EUR_CRM_Mechanic_Type__c(
                Name = mechTypeName,
                recordTypeId = rtId,
                EUR_CRM_Mechanic_Type_Name_English__c = mechTypeName
            );
            mechanicTypeMap.put(mechTypeName, mechType);
        }
        return mechanicTypeMap;
    }

    //CREATE Contract Line Item
    public static List<EUR_CRM_Contract_Line_Item__c> createContactLineItem(integer numberofContactLineItem, String recordTypeDeveloperName, Id contract){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Contract_Line_Item__c', recordTypeDeveloperName);
        List<EUR_CRM_Contract_Line_Item__c> contactLineItemList = new List<EUR_CRM_Contract_Line_Item__c>();
        
        for(integer i = 0;i < numberofContactLineItem;i++){
            EUR_CRM_Contract_Line_Item__c conLineItem = new EUR_CRM_Contract_Line_Item__c();
            conLineItem.RecordTypeId = recordtypeId;
            conLineItem.EUR_CRM_Contract__c = contract;
            contactLineItemList.add(conLineItem);
        }
        
        return contactLineItemList;
    }
    
    //CREATE Mechanic
    public static List<EUR_CRM_Mechanic__c> createMechanic(integer numberofMechanic, String recordTypeDeveloperName, String mechName, Id mechType){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Mechanic__c', recordTypeDeveloperName);
        List<EUR_CRM_Mechanic__c> mechanicList = new List<EUR_CRM_Mechanic__c>();
        
        for(integer i = 0;i < numberofMechanic;i++){
            EUR_CRM_Mechanic__c mechanic = new EUR_CRM_Mechanic__c();
            mechanic.RecordTypeId = recordtypeId;
            mechanic.Name = mechName;
            mechanic.EUR_CRM_Mechanic_Type__c = mechType;
            
            mechanicList.add(mechanic);
        }
        
        return mechanicList;
    }

    public static Map<String, EUR_CRM_Mechanic__c> createMechanics(Map<String, EUR_CRM_Mechanic_Type__c> mechanicTypeMap, Id rtId){
        Map<String, EUR_CRM_Mechanic__c> mechanicMap = new Map<String, EUR_CRM_Mechanic__c>();

        for(String mechTypeName: mechanicTypeMap.keySet()) {
            EUR_CRM_Mechanic__c mechType = new EUR_CRM_Mechanic__c(
                Name = mechTypeName,
                recordTypeId = rtId,
                EUR_CRM_Mechanic_Type__c = mechanicTypeMap.get(mechTypeName).Id
            );
            mechanicMap.put(mechTypeName, mechType);
        }
        return mechanicMap;
    }
    
    //CREATE Contact Mechanic
    public static List<EUR_CRM_Contract_Mechanic__c> createContractMechanic(integer numberofContractMechanic, String recordTypeDeveloperName, Id mechanic){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Contract_Mechanic__c', recordTypeDeveloperName);
        List<EUR_CRM_Contract_Mechanic__c> contractMechList = new List<EUR_CRM_Contract_Mechanic__c>();
        
        for(integer i = 0;i < numberofContractMechanic;i++){
            EUR_CRM_Contract_Mechanic__c conMech = new EUR_CRM_Contract_Mechanic__c();
            conMech.RecordTypeId = recordtypeId;
            conMech.EUR_CRM_Mechanic__c = mechanic;
            
            contractMechList.add(conMech);
        }
        
        return contractMechList;
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

    public static EUR_CRM_Brand__c createBrand(String name, Id rtId){
        return new EUR_CRM_Brand__c(
            Name = name,
            recordTypeId = rtId,
            EUR_CRM_Active__c = true
        );
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

    public static EUR_CRM_Quality__c createBrandQuality(String name, Id rtId){
        return new EUR_CRM_Quality__c(
            Name = name,
            recordTypeId = rtId,
            EUR_CRM_Active__c = true
        );
    }
    
    //CREATE Stock Deal Mechanic
    public static List<EUR_CRM_Stock_Deal_Mechanic__c> createStockDealMech(integer numberOfStockDealMech, Id brandQuality, String externalID){

        List<EUR_CRM_Stock_Deal_Mechanic__c> stockDealMechList = new List<EUR_CRM_Stock_Deal_Mechanic__c>();
        
        for(integer i = 0; i < numberOfStockDealMech;i++){
            EUR_CRM_Stock_Deal_Mechanic__c stockDealMech = new EUR_CRM_Stock_Deal_Mechanic__c();
            stockDealMech.EUR_CRM_Brand_Quality__c = brandQuality;
            stockDealMech.EUR_CRM_External_ID__c = externalID;
            stockDealMechList.add(stockDealMech);
        }
        
        return stockDealMechList;
    }
    
    //CREATE Volume Tracker
    public static List<EUR_CRM_GB_Volume_Tracker__c> createVolumeTracker(integer numberofVolumeTracker, String recordTypeDeveloperName, Id contract){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_GB_Volume_Tracker__c', recordTypeDeveloperName);
        List<EUR_CRM_GB_Volume_Tracker__c> volumeTrackerList = new List<EUR_CRM_GB_Volume_Tracker__c>();
        
        for(integer i = 0;i < numberofVolumeTracker;i++){
            EUR_CRM_GB_Volume_Tracker__c volumeTracker = new EUR_CRM_GB_Volume_Tracker__c();
            volumeTracker.RecordTypeId = recordtypeId;
            volumeTracker.EUR_CRM_Contract__c = contract;
            volumeTrackerList.add(volumeTracker);
        }
        
        return volumeTrackerList;
    }
    
    
    //CREATE Volume Tracker Line Item
    public static List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> createVolumeTrackerItem(integer numberOfVolumeTrackerItem, Id volumeTracker){

        List<EUR_CRM_GB_Volume_Tracker_Line_Item__c> volumeTrackerItemList = new List<EUR_CRM_GB_Volume_Tracker_Line_Item__c>();
        
        for(integer i = 0; i < numberOfVolumeTrackerItem;i++){
            EUR_CRM_GB_Volume_Tracker_Line_Item__c volumeTrackerItem = new EUR_CRM_GB_Volume_Tracker_Line_Item__c();
            volumeTrackerItem.EUR_CRM_Volume_Tracker__c = volumeTracker;
            volumeTrackerItemList.add(volumeTrackerItem);
        }
        
        return volumeTrackerItemList;
    }
    
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
    
    //CREATE Store Audit
    public static List<EUR_CRM_Store_Audit__c> createStoreAudit(integer numberofStoreAudit, String recordTypeDeveloperName, Id accountEU){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Store_Audit__c', recordTypeDeveloperName);
        List<EUR_CRM_Store_Audit__c> storeAuditList = new List<EUR_CRM_Store_Audit__c>();
        
        for(integer i = 0;i < numberofStoreAudit;i++){
            EUR_CRM_Store_Audit__c storeAudit = new EUR_CRM_Store_Audit__c();
            storeAudit.RecordTypeId = recordtypeId;
            storeAudit.EUR_CRM_Account__c = accountEU;
            storeAuditList.add(storeAudit);
        }
        
        return storeAuditList;
    }
    
    //CREATE Store Audit Item
    public static List<EUR_CRM_Store_Audit_Item__c> createStoreAuditItem(integer numberofStoreAuditItem, String recordTypeDeveloperName, Id storeAudit){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Store_Audit_Item__c', recordTypeDeveloperName);
        List<EUR_CRM_Store_Audit_Item__c> storeAuditItemList = new List<EUR_CRM_Store_Audit_Item__c>();
        
        for(integer i = 0;i < numberofStoreAuditItem;i++){
            EUR_CRM_Store_Audit_Item__c storeAuditItem = new EUR_CRM_Store_Audit_Item__c();
            storeAuditItem.RecordTypeId = recordtypeId;
            storeAuditItem.EUR_CRM_Store_Audit__c = storeAudit;
            storeAuditItemList.add(storeAuditItem);
        }
        
        return storeAuditItemList;
    }

    public static List<EUR_CRM_Cocktail_Menu__c> createCocktailMenu(integer numberofCocktailMenu, String recordTypeDeveloperName, String Name){
        
        Id recordtypeId = getRecordTypeId('EUR_CRM_Cocktail_Menu__c', recordTypeDeveloperName);
        List<EUR_CRM_Cocktail_Menu__c> cocktailMenuList = new List<EUR_CRM_Cocktail_Menu__c>();
        
        for(integer i = 0;i < numberofCocktailMenu;i++){
            EUR_CRM_Cocktail_Menu__c cocktailMenu = new EUR_CRM_Cocktail_Menu__c();
            cocktailMenu.RecordTypeId = recordtypeId;
            cocktailMenu.Name = Name;
            cocktailMenuList.add(cocktailMenu);
        }
        
        return cocktailMenuList;
    }

    public static List<EUR_CRM_Contract_Cocktail__c> createContractCocktail(integer numberofContractCocktail, Id cocktailMenuId, Id contractLineItemId){
        
        List<EUR_CRM_Contract_Cocktail__c> contractCocktailList = new List<EUR_CRM_Contract_Cocktail__c>();
        
        for(integer i = 0;i < numberofContractCocktail;i++){
            EUR_CRM_Contract_Cocktail__c contractCocktail = new EUR_CRM_Contract_Cocktail__c();
            contractCocktail.EUR_CRM_Cocktail_Menu__c = cocktailMenuId;
            contractCocktail.EUR_CRM_Contract_Line_Item__c = contractLineItemId;
            contractCocktailList.add(contractCocktail);
        }
        
        return contractCocktailList;
    }

    //CREATE EUR_CRM_Contract_Activity_Item__c
    public static List<EUR_CRM_Contract_Activity_Item__c> createContractActivityItems(List<EUR_CRM_Mechanic_Type__c> mechanicTypes, Id contractId){
        List<EUR_CRM_Contract_Activity_Item__c> contractActivityItems = new List<EUR_CRM_Contract_Activity_Item__c>();

        for(EUR_CRM_Mechanic_Type__c mechanicType: mechanicTypes) {
            contractActivityItems.add(new EUR_CRM_Contract_Activity_Item__c(
                EUR_CRM_Name__c = 'Test ContractActivityItems ' + mechanicType.Name,
                EUR_CRM_Contract__c = contractId,
                EUR_CRM_Mechanic_Type__c = mechanicType.Id
            ));
        }
        return contractActivityItems;
    }

    //CREATE EUR_CRM_Contract_Product_Item__c
    public static EUR_CRM_Contract_Product_Item__c createContractProductItem(Id contractActivityItemId, String brandId, String brandQualityId){
        EUR_CRM_Contract_Product_Item__c contractProductItem = new EUR_CRM_Contract_Product_Item__c(
            EUR_CRM_Contract_Activity_Item__c = contractActivityItemId
        );
        if(String.isNotBlank(brandId)){
            contractProductItem.EUR_CRM_Brand__c = brandId;
        }
        if(String.isNotBlank(brandQualityId)){
            contractProductItem.EUR_CRM_Brand_Quality__c = brandQualityId;
        }
        return contractProductItem;
    }

    public static EUR_CRM_Apex_Configuration__c createApexConfiguration(String module, String submodule, String text, Decimal dec){
        return new EUR_CRM_Apex_Configuration__c(
            EUR_CRM_Module__c = module, 
            EUR_CRM_Sub_Module__c = submodule, 
            EUR_CRM_Text_Value__c = text, 
            EUR_CRM_Decimal_Value__c = dec
        );
    }

    public static EUR_CRM_ObjPromo_Account_Mapping__c createobjPromoAccMapping(String recordtypename, Id accountId, Id objectPromoId){
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo_Account_Mapping__c', recordtypename);
        EUR_CRM_ObjPromo_Account_Mapping__c objPromoAccMap = new EUR_CRM_ObjPromo_Account_Mapping__c(
            Recordtypeid=recordtypeId,
            EUR_CRM_Account__c =accountId,
            EUR_CRM_ObjPromo__c = objectPromoId             
        );
        
        return objPromoAccMap;
    }

    public static EUR_CRM_OP_Action_List_Template__c creaActionListTemplate(String name, String externalId, String recordtypename) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_OP_Action_List_Template__c', recordtypename);
        EUR_CRM_OP_Action_List_Template__c actionListTemplate = new EUR_CRM_OP_Action_List_Template__c(
                Recordtypeid = recordtypeId, 
                Name = name,
                EUR_CRM_External_ID__c = externalId
            );

        return actionListTemplate;
    }    
    
    //CREATE Objectives / Promotions
    public static EUR_CRM_ObjPromo__c createObjPromo(String recordTypeDeveloperName, String name, String status){
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo__c', recordTypeDeveloperName);       
        return new EUR_CRM_ObjPromo__c(
            RecordTypeId = recordtypeId,
            Name = name,
            EUR_crm_status__c = status,
            EUR_CRM_Active_Start_Date__c = System.today(),
            EUR_CRM_Active_End_Date__c = System.today()
        );
    }

    //CREATE O/P Target
    public static EUR_CRM_ObjPromo_Target__c createOPTarget(String recordTypeDeveloperName, Id objPromoId, Id opTargetId){
        Id recordtypeId = getRecordTypeId('EUR_CRM_ObjPromo_Target__c', recordTypeDeveloperName);
        return new EUR_CRM_ObjPromo_Target__c(
            RecordTypeId = recordtypeId,
            EUR_CRM_ObjPromo__c = objPromoId,
            EUR_CRM_O_P_Target__c = opTargetId
        );
    }

    //CREATE EUR_CRM_Customer_Taxonomy__c
    public static EUR_CRM_Customer_Taxonomy__c createCustomerTaxonomy(String name, Id ownerId, String recordtypename) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Customer_Taxonomy__c', recordtypename);
        EUR_CRM_Customer_Taxonomy__c customerTaxonomy = new EUR_CRM_Customer_Taxonomy__c(
            Recordtypeid = recordtypeId, 
            Name = name,
            Ownerid = ownerId
            );
        return customerTaxonomy;
    }

    //
    public static EUR_CRM_OP_Customer_Taxonomy_Mapping__c createCustomerTaxonomyMapping(Id custTaxonomyId, Id objPromoId){
        return new EUR_CRM_OP_Customer_Taxonomy_Mapping__c(
            EUR_CRM_Customer_Taxonomy__c = custTaxonomyId, 
            EUR_CRM_ObjPromo__c = objPromoId
            );
    }

    //CREATE Visits
    public static EUR_CRM_Visit__c createVisit(String recordTypeDeveloperName, Id accountEUId) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit__c', recordTypeDeveloperName);
        return new EUR_CRM_Visit__c(
            RecordTypeId = recordtypeId,
            EUR_CRM_Account__c = accountEUId,
            EUR_CRM_End_Datetime__c = System.today()
        );
    }    

    //CREATE Visit Action
    public static EUR_CRM_Visit_Action__c createVisitAction(String recordTypeDeveloperName, Id objPromoId, Id opTargetId, Id visitId, Id accId, String status) {
        Id recordtypeId = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Visit_Action__c', recordTypeDeveloperName);    
        return new EUR_CRM_Visit_Action__c(
            RecordTypeId = recordtypeId,
            EUR_CRM_ObjPromo__c = objPromoId,
            EUR_CRM_ObjPromo_Target__c = opTargetId,
            EUR_CRM_Visit_ID__c = visitId,
            EUR_CRM_Account__c = accId,
            EUR_CRM_Status__c = status,
            EUR_CRM_Entitle_Achievement__c = true,
            EUR_CRM_Is_Successful__c = true,
            EUR_CRM_Is_Accrued__c = false
        );
    }

}