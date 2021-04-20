@isTest
public with sharing class EUR_CRM_TestClassHelper {
    
    public static RecordType prosPortugalRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Pros_Segmentation__c' and DeveloperName = 'EUR_PRT_PROS_Segmentation' LIMIT 1];
    public static RecordType acctRecordType = [select Id from RecordType where SobjectType='Account' and DeveloperName = 'EUR_PRT_On_Trade' LIMIT 1];
    public static RecordType euacctRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_LT_DIR_ON_Trade' LIMIT 1];

    public static RecordType euEEacctRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_EE_DIR_ON_Trade' LIMIT 1];
    public static RecordType euLTacctRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_LT_DIR_ON_Trade' LIMIT 1];
    public static RecordType euLVacctRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Account__c' and DeveloperName = 'EUR_LV_DIR_ON_Trade' LIMIT 1];
   
    public static RecordType imageRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Set__c' and DeveloperName = 'EUR_PRT_Image_Level_Criteria' LIMIT 1];
    public static RecordType volumeRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Set__c' and DeveloperName = 'EUR_PRT_Volume_Potential_Criteria' LIMIT 1];
    
    public static RecordType booleanThresholdRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Threshold__c' and DeveloperName = 'EUR_CRM_Boolean' LIMIT 1];
    public static RecordType currencyThresholdRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Threshold__c' and DeveloperName = 'EUR_CRM_Currency_Input' LIMIT 1];
    public static RecordType integerThresholdRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Threshold__c' and DeveloperName = 'EUR_CRM_Integer_Input' LIMIT 1];
    public static RecordType picklistThresholdRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Threshold__c' and DeveloperName = 'EUR_CRM_Picklist' LIMIT 1];
    public static RecordType textThresholdRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Threshold__c' and DeveloperName = 'EUR_CRM_Text_Input' LIMIT 1];
    
    public static RecordType booleanAnswerRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Answer__c' and DeveloperName = 'EUR_CRM_Boolean' LIMIT 1];
    public static RecordType currencyAnswerRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Answer__c' and DeveloperName = 'EUR_CRM_Currency_Input' LIMIT 1];
    public static RecordType integerAnswerRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Answer__c' and DeveloperName = 'EUR_CRM_Integer_Input' LIMIT 1];
    public static RecordType picklistAnswerRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Answer__c' and DeveloperName = 'EUR_CRM_Picklist' LIMIT 1];
    public static RecordType textAnswerRecordType = [select Id from RecordType where SobjectType='EUR_CRM_Criteria_Answer__c' and DeveloperName = 'EUR_CRM_Text_Input' LIMIT 1];
    
    public static RecordType groupOutletRecordtypeLT = [select Id from RecordType where SobjectType='EUR_CRM_Group_Outlet_Type__c' and DeveloperName = 'EUR_LT_Group_Outlet' LIMIT 1];
    
    public static final String EE = 'EE'; 
    public static final String LT = 'LT'; 
    public static final String LV = 'LV'; 
    public static final String DE = 'DE';  
    public static final String AT = 'AT'; 
    public static final String SK = 'SK'; 
    public static final String CZ = 'CZ'; 
    public static final String GB = 'GB'; 
    public static final String PRT = 'PRT'; 
    
    public static EUR_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String label, String value, Double weight)
    {
        EUR_CRM_Criteria_Answer__c criteriaAnswer = new EUR_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = booleanAnswerRecordType.Id;
        criteriaAnswer.EUR_CRM_Base_Currency__c = null;
        criteriaAnswer.EUR_CRM_Base_Integer__c = null;
        criteriaAnswer.EUR_CRM_Condition__c = null;
        criteriaAnswer.EUR_CRM_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.EUR_CRM_Label__c = label;
        criteriaAnswer.EUR_CRM_Value__c = value;
        criteriaAnswer.EUR_CRM_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static EUR_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String condition, Double currencyValue, Double weight)
    {
        EUR_CRM_Criteria_Answer__c criteriaAnswer = new EUR_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = currencyAnswerRecordType.Id;
        criteriaAnswer.EUR_CRM_Base_Currency__c = currencyValue;
        criteriaAnswer.EUR_CRM_Base_Integer__c = null;
        criteriaAnswer.EUR_CRM_Condition__c = condition;
        criteriaAnswer.EUR_CRM_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.EUR_CRM_Label__c = null;
        criteriaAnswer.EUR_CRM_Value__c = null;
        criteriaAnswer.EUR_CRM_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static EUR_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String condition, Integer integerValue, Double weight)
    {
        System.debug('Flag - Create Integer Criteria Answer');
        
        EUR_CRM_Criteria_Answer__c criteriaAnswer = new EUR_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = integerAnswerRecordType.Id;
        criteriaAnswer.EUR_CRM_Base_Currency__c = integerValue;
        criteriaAnswer.EUR_CRM_Base_Integer__c = null;
        criteriaAnswer.EUR_CRM_Condition__c = condition;
        criteriaAnswer.EUR_CRM_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.EUR_CRM_Label__c = null;
        criteriaAnswer.EUR_CRM_Value__c = null;
        criteriaAnswer.EUR_CRM_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static EUR_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String value, Double weight)
    {
        EUR_CRM_Criteria_Answer__c criteriaAnswer = new EUR_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = picklistAnswerRecordType.Id;
        criteriaAnswer.EUR_CRM_Base_Currency__c = null;
        criteriaAnswer.EUR_CRM_Base_Integer__c = null;
        criteriaAnswer.EUR_CRM_Condition__c = null;
        criteriaAnswer.EUR_CRM_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.EUR_CRM_Label__c = null;
        criteriaAnswer.EUR_CRM_Value__c = value;
        criteriaAnswer.EUR_CRM_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static EUR_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold)
    {
        EUR_CRM_Criteria_Answer__c criteriaAnswer = new EUR_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = textAnswerRecordType.Id;
        criteriaAnswer.EUR_CRM_Base_Currency__c = null;
        criteriaAnswer.EUR_CRM_Base_Integer__c = null;
        criteriaAnswer.EUR_CRM_Condition__c = null;
        criteriaAnswer.EUR_CRM_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.EUR_CRM_Label__c = null;
        criteriaAnswer.EUR_CRM_Value__c = null;
        criteriaAnswer.EUR_CRM_Weight__c = null;
        
        return criteriaAnswer;
    }
    
    public static EUR_CRM_Criteria_Threshold__c createCriteriaThreshold(Id criteriaSet, Id criteriaRecordTypeId, Double weight)
    {
        EUR_CRM_Criteria_Threshold__c criteriaThreshold = new EUR_CRM_Criteria_Threshold__c();
        criteriaThreshold.RecordTypeId = criteriaRecordTypeId;
        criteriaThreshold.EUR_CRM_Criteria_Set__c = criteriaSet;
        criteriaThreshold.EUR_CRM_Question__c = 'Test Question';
        criteriaThreshold.EUR_CRM_Weight__c = weight;
        
        return criteriaThreshold;
    }
    
    public static EUR_CRM_Criteria_Threshold__c createCriteriaThreshold(Id criteriaSet, Id criteriaRecordTypeId, String question, Double weight)
    {
        EUR_CRM_Criteria_Threshold__c criteriaThreshold = new EUR_CRM_Criteria_Threshold__c();
        criteriaThreshold.RecordTypeId = criteriaRecordTypeId;
        criteriaThreshold.EUR_CRM_Criteria_Set__c = criteriaSet;
        criteriaThreshold.EUR_CRM_Question__c = question;
        criteriaThreshold.EUR_CRM_Weight__c = weight;
        
        return criteriaThreshold;
    }
    
    
    public static EUR_CRM_Criteria_Set__c createCriteriaSet(Id criteriaRecordTypeId)
    {
        EUR_CRM_Criteria_Set__c criteriaSet = new EUR_CRM_Criteria_Set__c();
        criteriaSet.RecordTypeId = criteriaRecordTypeId;
        criteriaSet.EUR_CRM_Name__c = 'Test';
        //criteriaSet.EUR_CRM_Footer_Message__c = null;
        //criteriaSet.EUR_CRM_Header_Message__c = null;
        //criteriaSet.EUR_CRM_Title__c = null;
        
        return criteriaSet;
    }
    
    public static EUR_CRM_Pros_Segmentation__c createProsSegmentation(Id accountId, Id affiliateId, Id servicePackId)
    {
        EUR_CRM_Pros_Segmentation__c prosSegmentation = new EUR_CRM_Pros_Segmentation__c();
        prosSegmentation.RecordTypeId = prosPortugalRecordType.Id;

        prosSegmentation.EUR_CRM_Account__c = accountId;

        prosSegmentation.EUR_CRM_Affiliate__c = affiliateId;
        //EUR_CRM_Is_Image_Level_Modified__c
        //EUR_CRM_Is_Volume_Potential_Modified__c
        prosSegmentation.EUR_CRM_Service_Pack__c = servicePackId;
        
        return prosSegmentation;
    }
    
        public static EUR_CRM_Pros_Segmentation__c createProsSegmentation(Id accountId, Id affiliateId)
    {
        EUR_CRM_Pros_Segmentation__c prosSegmentation = new EUR_CRM_Pros_Segmentation__c();

        prosSegmentation.EUR_CRM_Account__c = accountId;

        prosSegmentation.EUR_CRM_Affiliate__c = affiliateId;
        //EUR_CRM_Is_Image_Level_Modified__c
        //EUR_CRM_Is_Volume_Potential_Modified__c
        prosSegmentation.EUR_CRM_Service_Pack__c = null;
        
        return prosSegmentation;
    }
    
    public static EUR_CRM_Pros_Image_Level__c createProsImageLevel(Id cThreshold, Id prosSeg, String answer, Double weight)
    {
        EUR_CRM_Pros_Image_Level__c prosImageLevel = new EUR_CRM_Pros_Image_Level__c();
        prosImageLevel.EUR_CRM_Answer__c = answer;
        prosImageLevel.EUR_CRM_Criteria_Threshold__c = cThreshold;
        prosImageLevel.EUR_CRM_Pros_Segmentation__c = prosSeg;
        prosImageLevel.EUR_CRM_Weight__c = weight;
        
        return prosImageLevel;
    }
    
    public static EUR_CRM_Pros_Volume_Potential__c createProsVolumePotential(Id cThreshold, Id prosSeg, String answer, Double weight)
    {
        EUR_CRM_Pros_Volume_Potential__c prosVolumePotential = new EUR_CRM_Pros_Volume_Potential__c();
        prosVolumePotential.EUR_CRM_Answer__c = answer;
        prosVolumePotential.EUR_CRM_Criteria_Threshold__c = cThreshold;
        prosVolumePotential.EUR_CRM_Pros_Segmentation__c = prosSeg;
        prosVolumePotential.EUR_CRM_Weight__c = weight;
        
        return prosVolumePotential;
    }
    
    public static EUR_CRM_Service_Pack__c createServicePack(Id affiliateId, String groupOutlet, String imageLevel){
        EUR_CRM_Service_Pack__c servicePack = new EUR_CRM_Service_Pack__c();
        servicePack.EUR_CRM_Affiliate__c = affiliateId;
        servicePack.EUR_CRM_Outlet_Type__c = groupOutlet;
        servicePack.EUR_CRM_Segmentation__c = imageLevel;
        
        return servicePack;
    }
    
    public static EUR_CRM_Service_Pack_Item__c createServicePackItem(Map<String, String> spItemFieldValues){
        EUR_CRM_Service_Pack_Item__c spItem = new EUR_CRM_Service_Pack_Item__c();
        
        for (String key: spItemFieldValues.keySet()){
            spItem.put(key, spItemFieldValues.get(key));
        }
        
        return spItem;
    }
    
    public static EUR_CRM_Affiliate__c createAffiliate()
    {
        EUR_CRM_Affiliate__c affiliate = new EUR_CRM_Affiliate__c();
       affiliate.Name = 'Pernod Ricard Portugal';
        affiliate.EUR_CRM_Decision_Tree__c = 'EUR_CRM_GroupOutletTypePage';

        return affiliate;
    }
    
    public static Account createAccount(String name)
    {
        Account newAccount = new Account(Name = name);
        newAccount.RecordTypeId = acctRecordType.Id;
        return newAccount;
    }
    
    public static EUR_CRM_Account__c createEUAccount(String name)
    {
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        newAccount.RecordTypeId = euacctRecordType.Id;
        return newAccount;
    }
    public static Account createAccount(String name, Id ownerId)
    {
        
        Account newAccount = new Account(Name=name, OwnerId =ownerId, 
            RecordTypeId=acctRecordType.Id);
        return newAccount;
    }
    
    public static EUR_CRM_Account__c createEUAccount(String name,String countryCode){
        EUR_CRM_Account__c newAccount = new EUR_CRM_Account__c(Name = name);
        if(countryCode == EE)
            newAccount.RecordTypeId = euEEacctRecordType.Id;
        else if(countryCode == LT)
            newAccount.RecordTypeId = euLTacctRecordType.Id;
        else if(countryCode == LV)
            newAccount.RecordTypeId = euLVacctRecordType.Id;
            
        return newAccount;
    }
    public static EUR_CRM_Group_Outlet_Type__c createGroupOutlet(String name, Id affiliate, Id imageCriteriaSet, Id volumeCriteriaSet){
        EUR_CRM_Group_Outlet_Type__c groupOutlet = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_Name__c=name, EUR_CRM_Affiliate__c=affiliate);
        //groupOutlet.RecordTypeId = groupOutletRecordtypeLT.Id;
        if(imageCriteriaSet!=null)
            groupOutlet.EUR_CRM_Image_Criteria_Set__c = imageCriteriaSet;
        if(volumeCriteriaSet!=null)
            groupOutlet.EUR_CRM_Volume_Criteria_Set__c = volumeCriteriaSet;
        
        return groupOutlet;
    }
    
    public static EUR_CRM_ID_Card__c createIDCard(Id accountId){
        EUR_CRM_ID_Card__c idCard = new EUR_CRM_ID_Card__c();
        idCard.EUR_CRM_Outlet__c = accountId;
        return idCard;
    }
    
    public static EUR_CRM_ID_Card_Volume__c createIDCardVolume(Id idCardId, Integer annualVolume, Id cat, Id serviceMark){
        EUR_CRM_ID_Card_Volume__c idCardVolume = new EUR_CRM_ID_Card_Volume__c();
        idCardVolume.EUR_CRM_ID_Card__c = idCardId;
        idCardVolume.EUR_CRM_Annual_Volume__c = annualVolume;
        if(cat != null)
            idCardVolume.EUR_CRM_Category__c = cat;
        if(serviceMark != null)
            idCardVolume.EUR_CRM_Service_Mark__c = serviceMark;
        
        return idCardVolume;
    }

    public static User runAsStandardUserPortugal(){
        User u = null;
        List<User>users = new List<User>();
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='System Administrator' LIMIT 1]; 

        users = [SELECT Id, CompanyName, UserName, ProfileId, LanguageLocaleKey, TimeZoneSidKey, Alias  
                FROM User WHERE UserName='jeremy.leray@pernod-ricard.com.staging' LIMIT 1];
                    
        if (users.size()<=0){
            //User:User:{Email=services@laputatech.com, Alias=llapu, TimeZoneSidKey=Europe/Paris, Username=laputa@preurope-crm.com, LanguageLocaleKey=en_US, Id=005c0000000TkofAAC, ProfileId=00eD0000001mMVzIAM, LastName=Admin}
            //User:{Email=jeremy.leray@pernod-ricard.com.staging, Alias=JLera, TimeZoneSidKey=Europe/Paris, Username=jeremy.leray@pernod-ricard.com.staging, LanguageLocaleKey=en_US, Id=005D00000023SXMIA2, ProfileId=00eL0000000DlELIA0, LastName=Leray, Title=Project and IT Manager}
            u = new User(
                    /*Email='services@laputatech.com',
                    Alias='llapu', 
                    TimeZoneSidKey='Europe/Paris', 
                    LocaleSidKey='en_US',
                    EmailEncodingKey='UTF-8',
                    Username='laputatest@preurope-crm.com', 
                    LanguageLocaleKey='en_US', 
                    ProfileId=p.Id, 
                    LastName='Admin',*/
                    Email='jeremy.leray@pernod-ricard.com.staging', 
                    Alias='JLera', 
                    TimeZoneSidKey='Europe/Paris', 
                    Username='jeremy.leray@pernod-ricard.com.staging2', 
                    LanguageLocaleKey='en_US',  
                    LocaleSidKey='en_US',
                    EmailEncodingKey='UTF-8',
                    ProfileId=p.Id, 
                    LastName='Leray', 
                    Title='Project and IT Manager',
                    CompanyName='Pernod Ricard Portugal'
                    );
                    
            insert u;
            System.debug('New User inserted:' + u.Id);
        }else{
            u = users[0];
            u.CompanyName='Pernod Ricard Portugal';
            update u;
            System.debug('Using existing user:' + u.id + '-' + u.CompanyName);
        }
       
        System.runAs(u) 
        {
           System.debug('Current User: ' + UserInfo.getUserName());
        }
        
        System.debug('Flag - REturning user:' + u.Username + '-' + u.CompanyName);
        return u;
    }
    
    public static User runAsStandardUser(){
        User u = null;
        List<User>users = new List<User>();
        //Assign Standard User with country not in affiliate
        Profile p = [SELECT Id FROM Profile WHERE Name='EUR PRT Standard Platform User']; 
        
        users = [SELECT Id, Country, CompanyName FROM User WHERE UserName='tester2@testorg.com' LIMIT 1];
        if (users.size()<=0){
            u = new User(Alias = 'standt', Email='tester2@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
                UserName='tester2@testorg.com',
                CompanyName='Pernod Ricard X');
        }else{
            u = users[0];
        }
        //insert u;
        
        System.runAs(u) 
        {
           System.debug('Current User: ' + UserInfo.getUserName());
        }
        
        return u;
    }
    
    public static Map<String,ID> prosObjectRecordType; // Key format 'countrycode+sobject' : example: EEEUR_CRM_Account__c;
    public static Set<String> prosObjects = new Set<String>{'',''};
    
    static {
        prosObjectRecordType = new Map<String,ID>();
        List<RecordType> recordTypes = [select id, developername from RecordType where sObjectType in: prosObjects];
        
        for(RecordType rType : recordTypes){
            String countryCode = (rType.developername).contains(PRT)? 'PRT' : (rType.developername).substring(4,6);
            prosObjectRecordType.put(countryCode+rType.developername,rType.id);
        }
    }
    
    
}