/*********************************************************************************
 * Name: ASI_CRM_TH_TestClassUtilityHelperPROS 
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_TestClassUtilityHelperPROS 
*********************************************************************************/
public class ASI_CRM_TH_TestClassUtilityHelperPROS {

    //maps to hold the record type info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String,Map<Id,Schema.RecordTypeInfo>> recordTypesById = new Map<String,Map<Id,Schema.RecordTypeInfo>>();
    private static Map<String,Map<String,Schema.RecordTypeInfo>> recordTypesByName = new Map<String,Map<String,Schema.RecordTypeInfo>>();
    
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
    
    //CREATE USER
    public static User createUser(String profileName){
        Profile p = [SELECT Id FROM Profile WHERE Name =: profileName]; 
        User u = new User(Alias = 'standt', Email='testUser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='Asia/Hong_Kong', UserName='testUser_asi@test.com');
        
        return u;
    }
    
    //CREATE Customer
    public static List<ASI_CRM_AccountsAdditionalField__c> createAccountsASI(integer numberOfSGAccounts, String recordTypeDeveloperName){
        Id userId = UserInfo.getUserId();
        
        //Added by Twinkle - 20150506        
        Id recordtypeId = getRecordTypeId('Account', 'ASI_TH_CRM_Outlet');

        Account acc = new Account();
        acc.RecordTypeId = recordtypeId;
        acc.Name = 'TestAccount';       
        insert acc;
        
        ASI_CRM_CN_Channel__c ch = new ASI_CRM_CN_Channel__c();
        ch.ASI_CRM_CN_Channel_Chi_Name__c = 'Channel';
        insert ch;
        
        ASI_MFM_Sub_Channel__c sc = new ASI_MFM_Sub_Channel__c();
        sc.ASI_CRM_CN_Channel__c = ch.id;
        insert sc;
        
        ASI_TH_CRM_OutletType__c ot = new ASI_TH_CRM_OutletType__c();
        ot.ASI_CRM_Sub_Channel__c = sc.id;
        insert ot;
        //End by Twinkle - 20150506        
                
        recordtypeId = getRecordTypeId('ASI_CRM_AccountsAdditionalField__c', recordTypeDeveloperName);
        List<ASI_CRM_AccountsAdditionalField__c> accountASIList = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        for(integer i = 0;i < numberOfSGAccounts;i++){
            ASI_CRM_AccountsAdditionalField__c accountASI = new ASI_CRM_AccountsAdditionalField__c();
            accountASI.RecordTypeId = recordtypeId;
            accountASI.Name = 'TestAccount';
            accountASI.ASI_CRM_Account__c = acc.id;
            accountASI.ASI_TH_CRM_OutletType__c = ot.id;
            accountASI.ASI_CRM_Region__c = 'North';
            accountASI.ASI_CRM_City__c = 'Test City';
            accountASI.ASI_CRM_Town__c = 'Test Town';
            accountASI.ASI_CRM_TW_Street__c = 'Test Street';
            accountASI.ASI_CRM_TW_Number__c = '1';
            accountASI.ASI_CRM_TW_Floor__c = '12';
            
            accountASIList.add(accountASI);
        }
        return accountASIList;
    }
    
    //CREATE Criteria Set
    public static List<ASI_CRM_Criteria_Set__c> createCriteriaSet(integer numberOfEUCriteriaSet, String recordTypeDeveloperName){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Criteria_Set__c', recordTypeDeveloperName);
        List<ASI_CRM_Criteria_Set__c> criteriaSetASIList = new List<ASI_CRM_Criteria_Set__c>();
        
        for(integer i = 0;i < numberOfEUCriteriaSet;i++){
            ASI_CRM_Criteria_Set__c criteriaSetASI = new ASI_CRM_Criteria_Set__c();
            criteriaSetASI.RecordTypeId = recordtypeId;
            criteriaSetASI.ASI_CRM_SG_Name__c = 'TESTCRITERIASET';
            criteriaSetASI.CurrencyIsoCode = 'THB';
                       
            criteriaSetASIList.add(criteriaSetASI);
        }
        return criteriaSetASIList;
    }
    
    //CREATE Criteria Answer
    public static List<ASI_CRM_Criteria_Answer__c> createCriteriaAnswer(integer numberOfEUCriteriaAnswer, String recordTypeDeveloperName, Id criteriaThreshold){
        Id recordtypeId = getRecordTypeId('ASI_CRM_Criteria_Answer__c', recordTypeDeveloperName);
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerASIList = new List<ASI_CRM_Criteria_Answer__c>();
        
        for(integer i = 0;i < numberOfEUCriteriaAnswer;i++){
            ASI_CRM_Criteria_Answer__c criteriaAnswerASI = new ASI_CRM_Criteria_Answer__c();
            criteriaAnswerASI.RecordTypeId = recordtypeId;
            criteriaAnswerASI.ASI_CRM_SG_Criteria_Threshold__c = criteriaThreshold;
            
            criteriaAnswerASIList.add(criteriaAnswerASI);
        }
        return criteriaAnswerASIList;
    }
    
    //CREATE Criteria Threshold
    public static List<ASI_CRM_Criteria_Threshold__c> createCriteriaThreshold(integer numberOfEUCriteriaSet, String recordTypeDeveloperName, Id criteriaSet){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Criteria_Threshold__c', recordTypeDeveloperName);
        List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdASIList = new List<ASI_CRM_Criteria_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUCriteriaSet;i++){
            ASI_CRM_Criteria_Threshold__c criteriaThresholdASI = new ASI_CRM_Criteria_Threshold__c();
            criteriaThresholdASI.RecordTypeId = recordtypeId;
            criteriaThresholdASI.CurrencyIsoCode = 'THB';
            criteriaThresholdASI.ASI_CRM_SG_Criteria_Set__c = criteriaSet;
            criteriaThresholdASI.ASI_CRM_SG_Sequence__c = 1;
            criteriaThresholdASI.ASI_CRM_SG_Question__c = 'TEST QUESTION';
            criteriaThresholdASI.ASI_CRM_SG_Weight__c = 100;
            
            criteriaThresholdASIList.add(criteriaThresholdASI);
        }
        return criteriaThresholdASIList;
    }
    
    //CREATE Group Outlet Type
    public static List<ASI_CRM_Group_Outlet_Type__c> createGroupOutletType(integer numberOfEUGrpOutletType, String recordTypeDeveloperName, String currencyCode, Id imageCriteriaSet, Id volumeCriteriaSet){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Group_Outlet_Type__c', recordTypeDeveloperName);
        List<ASI_CRM_Group_Outlet_Type__c> grpOutletTypeASIList = new List<ASI_CRM_Group_Outlet_Type__c>();
        
        for(integer i = 0;i < numberOfEUGrpOutletType;i++){
            ASI_CRM_Group_Outlet_Type__c grpOutletTypeASI = new ASI_CRM_Group_Outlet_Type__c();
            grpOutletTypeASI.RecordTypeId = recordtypeId;
            grpOutletTypeASI.CurrencyIsoCode = currencyCode;
            grpOutletTypeASI.ASI_CRM_SG_Image_Criteria_Set__c = imageCriteriaSet;
            grpOutletTypeASI.ASI_CRM_SG_Volume_Criteria_Set__c = volumeCriteriaSet;
            grpOutletTypeASI.ASI_CRM_SG_Name__c = 'TEST NAME';
            grpOutletTypeASI.ASI_CRM_SG_Group_Outlet_Name__c='test 1';
            
            grpOutletTypeASIList.add(grpOutletTypeASI);
        }
        return grpOutletTypeASIList;
    }
    
    //CREATE Outlet Type
    public static List<ASI_CRM_Outlet_Type__c> createOutletType(integer numberOfEUOutletType, String recordTypeDeveloperName, String currencyCode, Id grpOutletType){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Outlet_Type__c', recordTypeDeveloperName);
        List<ASI_CRM_Outlet_Type__c> outletTypeASIList = new List<ASI_CRM_Outlet_Type__c>();
        
        for(integer i = 0;i < numberOfEUOutletType;i++){
            ASI_CRM_Outlet_Type__c outletTypeASI = new ASI_CRM_Outlet_Type__c();
            outletTypeASI.RecordTypeId = recordtypeId;
            outletTypeASI.CurrencyIsoCode = currencyCode;
            outletTypeASI.ASI_CRM_SG_Active__c = true;
            outletTypeASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            outletTypeASI.ASI_CRM_SG_Name__c = 'TEST NAME';
            
            outletTypeASIList.add(outletTypeASI);
        }
        
        return outletTypeASIList;
    }
    
    //CREATE Image Level
    public static List<ASI_CRM_Image_Level__c> createImageLevel(integer numberOfEUImageLevel, String recordTypeDeveloperName, String currencyCode, Id grpOutletType, String iLevelName){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Image_Level__c', recordTypeDeveloperName);
        List<ASI_CRM_Image_Level__c> imageLevelASIList = new List<ASI_CRM_Image_Level__c>();
        
        for(integer i = 0;i < numberOfEUImageLevel;i++){
            ASI_CRM_Image_Level__c imageLevelASI = new ASI_CRM_Image_Level__c();
            imageLevelASI.RecordTypeId = recordtypeId;
            imageLevelASI.CurrencyIsoCode = currencyCode;
            imageLevelASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            imageLevelASI.ASI_CRM_SG_Min_Weight__c = 10;
            imageLevelASI.ASI_CRM_SG_Name__c = iLevelName;
            
            imageLevelASIList.add(imageLevelASI);
        }
        return imageLevelASIList;
    }
    

    //CREATE Image Level Threshold
    public static List<ASI_CRM_Image_Level_Threshold__c> createImageLevelThreshold(integer numberOfEUILThreshold, Id grpOutletType, Id imageLevel){

        List<ASI_CRM_Image_Level_Threshold__c> imageLevelThresholdASIList = new List<ASI_CRM_Image_Level_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUILThreshold;i++){
            ASI_CRM_Image_Level_Threshold__c imageLevelThresholdASI = new ASI_CRM_Image_Level_Threshold__c();
            imageLevelThresholdASI.ASI_CRM_SG_Name__c = 'Test Image Lvl Threshold';
            imageLevelThresholdASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            imageLevelThresholdASI.ASI_CRM_SG_Image_Level__c = imageLevel;
            
            imageLevelThresholdASIList.add(imageLevelThresholdASI);
        }
        return imageLevelThresholdASIList;
    }
    
    //CREATE Image Level Threshold with Mimimum weight
    public static List<ASI_CRM_Image_Level_Threshold__c> createImageLevelThreshold(integer numberOfEUILThreshold, Id grpOutletType, Id imageLevel,Integer minWeight){

        List<ASI_CRM_Image_Level_Threshold__c> imageLevelThresholdASIList = new List<ASI_CRM_Image_Level_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUILThreshold;i++){
            ASI_CRM_Image_Level_Threshold__c imageLevelThresholdASI = new ASI_CRM_Image_Level_Threshold__c();
            imageLevelThresholdASI.ASI_CRM_SG_Name__c = 'Test Image Lvl Threshold';
            imageLevelThresholdASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            imageLevelThresholdASI.ASI_CRM_SG_Image_Level__c = imageLevel;
            imageLevelThresholdASI.ASI_CRM_SG_Min_Weight__c = minWeight;
            imageLevelThresholdASIList.add(imageLevelThresholdASI);
        }
        return imageLevelThresholdASIList;
    }
    
    //CREATE Volume Potential
    public static List<ASI_CRM_Volume_Potential__c> createvolumePotential(integer numberOfEUVolumePotential, String recordTypeDeveloperName, String currencyCode, Id grpOutletType, String volPotentialName){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Volume_Potential__c', recordTypeDeveloperName);
        List<ASI_CRM_Volume_Potential__c> volumePotentialASIList = new List<ASI_CRM_Volume_Potential__c>();
        
        for(integer i = 0;i < numberOfEUVolumePotential;i++){
            ASI_CRM_Volume_Potential__c volumePotentialASI = new ASI_CRM_Volume_Potential__c();
            volumePotentialASI.RecordTypeId = recordtypeId;
            volumePotentialASI.CurrencyIsoCode = currencyCode;
            volumePotentialASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            volumePotentialASI.ASI_CRM_SG_Min_Weight__c = 10;
            volumePotentialASI.ASI_CRM_SG_Max_Weight__c = 100;
            volumePotentialASI.ASI_CRM_SG_Name__c = volPotentialName;
            
            volumePotentialASIList.add(volumePotentialASI);
        }
        return volumePotentialASIList;
    }
    
    //CREATE Volume Potential Threshold
    public static List<ASI_CRM_Volume_Potential_Threshold__c> createvolumePotentialThreshold(integer numberOfEUVolumePotentialThreshold, Id grpOutletType, Id volPotential){
    
        List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialTASIList = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUVolumePotentialThreshold;i++){
            ASI_CRM_Volume_Potential_Threshold__c volumePotentialTASI = new ASI_CRM_Volume_Potential_Threshold__c();
            volumePotentialTASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            volumePotentialTASI.ASI_CRM_SG_Volume_Potential__c = volPotential;
            
            volumePotentialTASIList.add(volumePotentialTASI);
        }
        return volumePotentialTASIList;
    }
        
    //CREATE Volume Potential Threshold with minmum weight
    public static List<ASI_CRM_Volume_Potential_Threshold__c> createvolumePotentialThreshold(integer numberOfEUVolumePotentialThreshold, Id grpOutletType, Id volPotential, Integer minWeight){
    
        List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialTASIList = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        
        for(integer i = 0;i < numberOfEUVolumePotentialThreshold;i++){
            ASI_CRM_Volume_Potential_Threshold__c volumePotentialTASI = new ASI_CRM_Volume_Potential_Threshold__c();
            volumePotentialTASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            volumePotentialTASI.ASI_CRM_SG_Volume_Potential__c = volPotential;            
            volumePotentialTASI.ASI_CRM_SG_Min_Weight__c = minWeight;
            volumePotentialTASIList.add(volumePotentialTASI);
        }
        return volumePotentialTASIList;
    }
    
    //CREATE Service Pack
    public static List<ASI_CRM_ServicePack__c> createServicePack(integer numberOfEUServicePack, String recordTypeDeveloperName, String grpOutletType, String imageLevel){

        Id recordtypeId = getRecordTypeId('ASI_CRM_ServicePack__c', recordTypeDeveloperName);
        List<ASI_CRM_ServicePack__c> servicePackASIList = new List<ASI_CRM_ServicePack__c>();
        
        for(integer i = 0;i < numberOfEUServicePack;i++){
            ASI_CRM_ServicePack__c  servicePackASI = new ASI_CRM_ServicePack__c();
            servicePackASI.RecordTypeId = recordtypeId;
            servicePackASI.ASI_CRM_SG_Outlet_Type__c = grpOutletType;
            servicePackASI.ASI_CRM_SG_Segmentation__c = imageLevel;
            
            servicePackASIList.add(servicePackASI);
        }
        return servicePackASIList;
    }
    
    //CREATE Pros Segmentation
    public static List<ASI_CRM_Pros_Segmentation__c> createProsSegmentation(integer numberOfEUProsSegmentation, String recordTypeDeveloperName, String currencyCode, Id accountASI, Id grpOutletType, Id outletType, Id imageLevel, Id volumePotential){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Pros_Segmentation__c', recordTypeDeveloperName);
        List<ASI_CRM_Pros_Segmentation__c> prosSegmentationASIList = new List<ASI_CRM_Pros_Segmentation__c>();
        
        for(integer i = 0;i < numberOfEUProsSegmentation;i++){
            ASI_CRM_Pros_Segmentation__c prosSegmentationASI = new ASI_CRM_Pros_Segmentation__c();
            prosSegmentationASI.RecordTypeId = recordtypeId;
            prosSegmentationASI.CurrencyIsoCode = currencyCode;
            prosSegmentationASI.ASI_CRM_SG_Customer__c = accountASI;
            prosSegmentationASI.ASI_CRM_SG_Group_Outlet_Type__c = grpOutletType;
            prosSegmentationASI.ASI_CRM_SG_Image_Level__c = imageLevel;
            prosSegmentationASI.ASI_CRM_SG_Outlet_Type__c = outletType;
            prosSegmentationASI.ASI_CRM_SG_Volume_Potential__c = volumePotential;
            
            prosSegmentationASIList.add(prosSegmentationASI);
        }
        return prosSegmentationASIList;
    }

    //CREATE Pros Volume Potential
    public static List<ASI_CRM_Pros_Volume_Potential__c> createProsVolumePotential(integer numberOfEUProsVolPotential, String recordTypeDeveloperName, String currencyCode, Id prosSegmentation, Id critThreshold){
    
        Id recordtypeId = getRecordTypeId('ASI_CRM_Pros_Volume_Potential__c', recordTypeDeveloperName);
        List<ASI_CRM_Pros_Volume_Potential__c> prosVolPotentialASIList = new List<ASI_CRM_Pros_Volume_Potential__c>();
        
        for(integer i = 0;i < numberOfEUProsVolPotential;i++){
            ASI_CRM_Pros_Volume_Potential__c prosVolPotentialASI = new ASI_CRM_Pros_Volume_Potential__c();
            prosVolPotentialASI.RecordTypeId = recordtypeId;
            prosVolPotentialASI.CurrencyIsoCode = currencyCode;
            prosVolPotentialASI.ASI_CRM_SG_Answer__c = 'TEST ANSWER';
            prosVolPotentialASI.ASI_CRM_SG_Criteria_Threshold__c = critThreshold;
            prosVolPotentialASI.ASI_CRM_SG_Pros_Segmentation__c = prosSegmentation;
            prosVolPotentialASI.ASI_CRM_SG_Weight__c = 100;
            
            prosVolPotentialASIList.add(prosVolPotentialASI);
        }
        return prosVolPotentialASIList;
    }
    
    //CREATE Pros Image Level
    public static List<ASI_CRM_Pros_Image_Level__c> createProsImageLevel(integer numberOfEUProsImageLevel, String recordTypeDeveloperName, String currencyCode, Id prosSegmentation, Id critThreshold){
        
        Id recordtypeId = getRecordTypeId('ASI_CRM_Pros_Image_Level__c', recordTypeDeveloperName);
        List<ASI_CRM_Pros_Image_Level__c> prosimageLevelASIList = new List<ASI_CRM_Pros_Image_Level__c>();
        
        for(integer i = 0;i < numberOfEUProsImageLevel;i++){
            ASI_CRM_Pros_Image_Level__c prosimageLevelASI = new ASI_CRM_Pros_Image_Level__c();
            prosimageLevelASI.CurrencyIsoCode = currencyCode;
            prosimageLevelASI.RecordTypeId = recordtypeId;
            prosimageLevelASI.ASI_CRM_SG_Answer__c = 'TEST ANSWER';
            prosimageLevelASI.ASI_CRM_SG_Criteria_Threshold__c = critThreshold;
            prosimageLevelASI.ASI_CRM_SG_Pros_Segmentation__c = prosSegmentation;
            prosimageLevelASI.ASI_CRM_SG_Weight__c = 100;
            
            prosimageLevelASIList.add(prosimageLevelASI);
        }
        return prosimageLevelASIList;
    }
    
    //CREATE Wine/Spirits
    public static List<ASI_CRM_Wine_Spirits__c> createWineSpirits(integer numberofWineSpirits, String recordTypeDeveloperName){
        
        Id recordtypeId = getRecordTypeId('ASI_CRM_Wine_Spirits__c', recordTypeDeveloperName);
        List<ASI_CRM_Wine_Spirits__c> wineSpiritsList = new List<ASI_CRM_Wine_Spirits__c>();
        
        for(integer i = 0;i < numberofWineSpirits;i++){
            ASI_CRM_Wine_Spirits__c wineSpirit = new ASI_CRM_Wine_Spirits__c();
            wineSpirit.RecordTypeId = recordtypeId;
            wineSpirit.ASI_CRM_SG_Wine_Spirits_Code__c = 'Test'+i;
            wineSpiritsList.add(wineSpirit);
        }
        return wineSpiritsList;
    }
    
    //CREATE Category
    public static List<ASI_HK_CRM_Product_Category__c> createCategory(integer numberofCategory, String recordTypeDeveloperName, String externalID, Id wineSpirit){
        
        Id recordtypeId = getRecordTypeId('ASI_HK_CRM_Product_Category__c', recordTypeDeveloperName);
        List<ASI_HK_CRM_Product_Category__c> categoryList = new List<ASI_HK_CRM_Product_Category__c>();
        
        for(integer i = 0;i < numberofCategory;i++){
            ASI_HK_CRM_Product_Category__c category = new ASI_HK_CRM_Product_Category__c();
            category.RecordTypeId = recordtypeId;
            category.ASI_CRM_SG_Wine_Spirits__c = wineSpirit;
            categoryList.add(category);
        }
        return categoryList;
    }
    
    //CREATE Brand
    public static List<ASI_MFM_Brand__c> createBrand(integer numberofBrand, String recordTypeDeveloperName, String brandName, String externalID, Id category){
        
        Id recordtypeId = getRecordTypeId('ASI_MFM_Brand__c', recordTypeDeveloperName);
        List<ASI_MFM_Brand__c> brandList = new List<ASI_MFM_Brand__c>();
        
        for(integer i = 0;i < numberofBrand;i++){
            ASI_MFM_Brand__c brand = new ASI_MFM_Brand__c();
            brand.RecordTypeId = recordtypeId;
            brand.Name = brandName;
            brand.ASI_HK_CRM_Product_Category__c = category;
            brandList.add(brand);
        }
        return brandList;
    }
    
    //CREATE Brand Quality
    public static List<ASI_CRM_Quality__c> createBrandQuality(integer numberofBrandQuality, String recordTypeDeveloperName, String brandQualityName, String externalID, Id brand){
        
        Id recordtypeId = getRecordTypeId('ASI_CRM_Quality__c', recordTypeDeveloperName);
        List<ASI_CRM_Quality__c> brandQualityList = new List<ASI_CRM_Quality__c>();
        
        for(integer i = 0;i < numberofBrandQuality;i++){
            ASI_CRM_Quality__c brandQuality = new ASI_CRM_Quality__c();
            brandQuality.RecordTypeId = recordtypeId;
            brandQuality.Name = brandQualityName;
            brandQuality.ASI_CRM_SG_Brand__c = brand;
            brandQualityList.add(brandQuality);
        }
        return brandQualityList;
    }
    
    //Create DAMD Threshold   
    public static List<ASI_CRM_DAMD_Threshold__c> createDAMD(integer numberofDAMD, String recordTypeDeveloperName, Id grpId, Id vpId, String act, String ms, Decimal wei){
        
        Id recordtypeId = getRecordTypeId('ASI_CRM_DAMD_Threshold__c', recordTypeDeveloperName);
        List<ASI_CRM_DAMD_Threshold__c> damdList = new List<ASI_CRM_DAMD_Threshold__c>();
        
        for(integer i = 0;i < numberofDAMD;i++){
            ASI_CRM_DAMD_Threshold__c damd = new ASI_CRM_DAMD_Threshold__c();
            damd.ASI_CRM_SG_Action__c = act;
            damd.ASI_CRM_SG_Group_Outlet_Type__c = grpId;
            damd.ASI_CRM_SG_Market_Share__c = ms;
            damd.ASI_CRM_SG_Min_Weight__c = wei;
            damd.ASI_CRM_SG_Volume_Potential__c = vpId;
            damd.RecordTypeId = recordtypeId;
            
            damdList.add(damd);
        }       
        return damdList;
    }    
}