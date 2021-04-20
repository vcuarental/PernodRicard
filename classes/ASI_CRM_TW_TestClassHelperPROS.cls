/*********************************************************************************
 * Name: ASI_CRM_TW_TestClassHelperPROS
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/05/2015       Laputa: Alvin           Cloned from ASI_CRM_TestClassHelperPROS
*********************************************************************************/
@isTest
public with sharing class ASI_CRM_TW_TestClassHelperPROS{
    
    public static RecordType prosSGRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Pros_Segmentation__c' and DeveloperName = 'ASI_CRM_TW_PROS_Segmentation' LIMIT 1];
    public static RecordType acctRecordType = [select Id from RecordType where SobjectType='ASI_CRM_AccountsAdditionalField__c' and DeveloperName = 'ASI_CRM_TW_Outlet' LIMIT 1];
    public static RecordType euacctRecordType = [select Id from RecordType where SobjectType='ASI_CRM_AccountsAdditionalField__c' and DeveloperName = 'ASI_CRM_TW_Outlet' LIMIT 1];
     
    public static RecordType imageRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Set__c' and DeveloperName = 'ASI_CRM_TW_Image_Level_Criteria' LIMIT 1];
    public static RecordType volumeRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Set__c' and DeveloperName = 'ASI_CRM_TW_Volume_Potential_Criteria' LIMIT 1];
    
    public static RecordType booleanThresholdRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Threshold__c' and DeveloperName = 'ASI_CRM_TW_Boolean' LIMIT 1];
    public static RecordType currencyThresholdRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Threshold__c' and DeveloperName = 'ASI_CRM_TW_Currency_Input' LIMIT 1];
    public static RecordType integerThresholdRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Threshold__c' and DeveloperName = 'ASI_CRM_TW_Number_Input' LIMIT 1];
    public static RecordType picklistThresholdRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Threshold__c' and DeveloperName = 'ASI_CRM_TW_Picklist' LIMIT 1];
    public static RecordType textThresholdRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Threshold__c' and DeveloperName = 'ASI_CRM_TW_Text_Input' LIMIT 1];
    
    public static RecordType booleanAnswerRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Answer__c' and DeveloperName = 'ASI_CRM_TW_Boolean' LIMIT 1];
    public static RecordType currencyAnswerRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Answer__c' and DeveloperName = 'ASI_CRM_TW_Currency_Input' LIMIT 1];
    public static RecordType integerAnswerRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Answer__c' and DeveloperName = 'ASI_CRM_TW_Integer_Input' LIMIT 1];
    public static RecordType picklistAnswerRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Answer__c' and DeveloperName = 'ASI_CRM_TW_Picklist' LIMIT 1];
    public static RecordType textAnswerRecordType = [select Id from RecordType where SobjectType='ASI_CRM_Criteria_Answer__c' and DeveloperName = 'ASI_CRM_TW_Text_Input' LIMIT 1];
    
    public static RecordType groupOutletRecordtypeSG = [select Id from RecordType where SobjectType='ASI_CRM_Group_Outlet_Type__c' and DeveloperName = 'ASI_CRM_TW_Group_Outlet_Type' LIMIT 1];
    public static RecordType damdRecordTypeSG = [select Id from RecordType where SobjectType='ASI_CRM_DAMD_Threshold__c' and DeveloperName = 'ASI_CRM_TW_DAMD_Threshold' LIMIT 1];
     
    
    public static ASI_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String label, String value, Double weight)
    {
        ASI_CRM_Criteria_Answer__c criteriaAnswer = new ASI_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = booleanAnswerRecordType.Id;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = null;
        criteriaAnswer.ASI_CRM_SG_Base_Integer__c = null;
        criteriaAnswer.ASI_CRM_SG_Condition__c = null;
        criteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.ASI_CRM_SG_Label__c = label;
        criteriaAnswer.ASI_CRM_SG_Value__c = value;
        criteriaAnswer.ASI_CRM_SG_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static ASI_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String condition, Double currencyValue, Double weight)
    {
        ASI_CRM_Criteria_Answer__c criteriaAnswer = new ASI_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = currencyAnswerRecordType.Id;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = currencyValue;
        criteriaAnswer.ASI_CRM_SG_Base_Integer__c = null;
        criteriaAnswer.ASI_CRM_SG_Condition__c = condition;
        criteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.ASI_CRM_SG_Label__c = null;
        criteriaAnswer.ASI_CRM_SG_Value__c = null;
        criteriaAnswer.ASI_CRM_SG_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static ASI_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String condition, Integer integerValue, Double weight)
    {
        System.debug('Flag - Create Integer Criteria Answer');
        
        ASI_CRM_Criteria_Answer__c criteriaAnswer = new ASI_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = integerAnswerRecordType.Id;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = integerValue;
        criteriaAnswer.ASI_CRM_SG_Base_Integer__c = null;
        criteriaAnswer.ASI_CRM_SG_Condition__c = condition;
        criteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.ASI_CRM_SG_Label__c = null;
        criteriaAnswer.ASI_CRM_SG_Value__c = null;
        criteriaAnswer.ASI_CRM_SG_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static ASI_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold, String value, Double weight)
    {
        ASI_CRM_Criteria_Answer__c criteriaAnswer = new ASI_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = picklistAnswerRecordType.Id;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = null;
        criteriaAnswer.ASI_CRM_SG_Base_Integer__c = null;
        criteriaAnswer.ASI_CRM_SG_Condition__c = null;
        criteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.ASI_CRM_SG_Label__c = null;
        criteriaAnswer.ASI_CRM_SG_Value__c = value;
        criteriaAnswer.ASI_CRM_SG_Weight__c = weight;
        
        return criteriaAnswer;
    }
    
    public static ASI_CRM_Criteria_Answer__c createCriteriaAnswer(Id cThreshold)
    {
        ASI_CRM_Criteria_Answer__c criteriaAnswer = new ASI_CRM_Criteria_Answer__c();
        criteriaAnswer.RecordTypeId = textAnswerRecordType.Id;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = null;
        criteriaAnswer.ASI_CRM_SG_Base_Integer__c = null;
        criteriaAnswer.ASI_CRM_SG_Condition__c = null;
        criteriaAnswer.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        criteriaAnswer.ASI_CRM_SG_Label__c = null;
        criteriaAnswer.ASI_CRM_SG_Value__c = null;
        criteriaAnswer.ASI_CRM_SG_Weight__c = null;
        
        return criteriaAnswer;
    }
    
    public static ASI_CRM_Criteria_Threshold__c createCriteriaThreshold(Id criteriaSet, Id criteriaRecordTypeId, Double weight)
    {
        ASI_CRM_Criteria_Threshold__c criteriaThreshold = new ASI_CRM_Criteria_Threshold__c();
        criteriaThreshold.RecordTypeId = criteriaRecordTypeId;
        criteriaThreshold.ASI_CRM_SG_Criteria_Set__c = criteriaSet;
        criteriaThreshold.ASI_CRM_SG_Question__c = 'Test Question';
        criteriaThreshold.ASI_CRM_SG_Weight__c = weight;
        
        return criteriaThreshold;
    }
    
    public static ASI_CRM_Criteria_Threshold__c createCriteriaThreshold(Id criteriaSet, Id criteriaRecordTypeId, String question, Double weight)
    {
        ASI_CRM_Criteria_Threshold__c criteriaThreshold = new ASI_CRM_Criteria_Threshold__c();
        criteriaThreshold.RecordTypeId = criteriaRecordTypeId;
        criteriaThreshold.ASI_CRM_SG_Criteria_Set__c = criteriaSet;
        criteriaThreshold.ASI_CRM_SG_Question__c = question;
        criteriaThreshold.ASI_CRM_SG_Weight__c = weight;
        
        return criteriaThreshold;
    }
    
    
    public static ASI_CRM_Criteria_Set__c createCriteriaSet(Id criteriaRecordTypeId)
    {
        ASI_CRM_Criteria_Set__c criteriaSet = new ASI_CRM_Criteria_Set__c();
        criteriaSet.RecordTypeId = criteriaRecordTypeId;
        criteriaSet.ASI_CRM_SG_Name__c = 'Test';
        
        return criteriaSet;
    }
    
    public static ASI_CRM_Pros_Segmentation__c createProsSegmentation(Id accountId, Id servicePackId)
    {
        ASI_CRM_Pros_Segmentation__c prosSegmentation = new ASI_CRM_Pros_Segmentation__c();
        prosSegmentation.RecordTypeId = prosSGRecordType.Id;
        prosSegmentation.ASI_CRM_SG_Customer__c = accountId;
        prosSegmentation.ASI_CRM_SG_Service_Pack__c = servicePackId;
        
        return prosSegmentation;
    }
    
    public static ASI_CRM_Pros_Segmentation__c createProsSegmentation(Id accountId)
    {
        ASI_CRM_Pros_Segmentation__c prosSegmentation = new ASI_CRM_Pros_Segmentation__c();
        prosSegmentation.ASI_CRM_SG_Customer__c = accountId;
        prosSegmentation.ASI_CRM_SG_Service_Pack__c = null;
        
        return prosSegmentation;
    }
    
    public static ASI_CRM_Pros_Image_Level__c createProsImageLevel(Id cThreshold, Id prosSeg, String answer, Double weight)
    {
        ASI_CRM_Pros_Image_Level__c prosImageLevel = new ASI_CRM_Pros_Image_Level__c();
        prosImageLevel.ASI_CRM_SG_Answer__c = answer;
        prosImageLevel.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        prosImageLevel.ASI_CRM_SG_Pros_Segmentation__c = prosSeg;
        prosImageLevel.ASI_CRM_SG_Weight__c = weight;
        
        return prosImageLevel;
    }
    
    public static ASI_CRM_Pros_Volume_Potential__c createProsVolumePotential(Id cThreshold, Id prosSeg, String answer, Double weight)
    {
        ASI_CRM_Pros_Volume_Potential__c prosVolumePotential = new ASI_CRM_Pros_Volume_Potential__c();
        prosVolumePotential.ASI_CRM_SG_Answer__c = answer;
        prosVolumePotential.ASI_CRM_SG_Criteria_Threshold__c = cThreshold;
        prosVolumePotential.ASI_CRM_SG_Pros_Segmentation__c = prosSeg;
        prosVolumePotential.ASI_CRM_SG_Weight__c = weight;
        
        return prosVolumePotential;
    }
    
    public static ASI_CRM_ServicePack__c createServicePack(String groupOutlet, String imageLevel){
        ASI_CRM_ServicePack__c servicePack = new ASI_CRM_ServicePack__c();
        servicePack.ASI_CRM_SG_Outlet_Type__c = groupOutlet;
        servicePack.ASI_CRM_SG_Segmentation__c = imageLevel;
        
        return servicePack;
    }
    
    public static ASI_CRM_ServicePackItem__c createServicePackItem(Map<String, String> spItemFieldValues){
        ASI_CRM_ServicePackItem__c spItem = new ASI_CRM_ServicePackItem__c();
        
        for (String key: spItemFieldValues.keySet()){
            spItem.put(key, spItemFieldValues.get(key));
        }
        
        return spItem;
    }
    
    public static ASI_CRM_AccountsAdditionalField__c createAccount(String name)
    {
        ASI_CRM_AccountsAdditionalField__c newAccount = new ASI_CRM_AccountsAdditionalField__c(Name = name, RecordTypeId = acctRecordType.Id);
        return newAccount;
    }
    
    public static ASI_CRM_AccountsAdditionalField__c createAccount(String name, Id ownerId)
    {
        
        ASI_CRM_AccountsAdditionalField__c newAccount = new ASI_CRM_AccountsAdditionalField__c (Name=name, OwnerId =ownerId, 
            RecordTypeId=acctRecordType.Id);
        return newAccount;
    }
    
    public static ASI_CRM_Group_Outlet_Type__c createGroupOutlet(String name, Id imageCriteriaSet, Id volumeCriteriaSet){
        ASI_CRM_Group_Outlet_Type__c groupOutlet = new ASI_CRM_Group_Outlet_Type__c(ASI_CRM_SG_Name__c=name);
        if(imageCriteriaSet!=null)
            groupOutlet.ASI_CRM_SG_Image_Criteria_Set__c = imageCriteriaSet;
        if(volumeCriteriaSet!=null)
            groupOutlet.ASI_CRM_SG_Volume_Criteria_Set__c = volumeCriteriaSet;
        
        return groupOutlet;
    }
    
    public static ASI_CRM_ID_Card__c createIDCard(Id accountId){
        ASI_CRM_ID_Card__c idCard = new ASI_CRM_ID_Card__c();
        idCard.ASI_CRM_SG_Outlet__c = accountId;
        return idCard;
    }
    
    public static ASI_CRM_ID_Card_Volume__c createIDCardVolume(Id idCardId, Integer annualVolume, Id cat, Id serviceMark){
        ASI_CRM_ID_Card_Volume__c idCardVolume = new ASI_CRM_ID_Card_Volume__c();
        idCardVolume.ASI_CRM_SG_ID_Card__c = idCardId;
        idCardVolume.ASI_CRM_SG_Annual_Volume__c = annualVolume;
        if(serviceMark != null)
            idCardVolume.ASI_CRM_SG_Service_Mark__c = serviceMark;
        
        return idCardVolume;
    }
    
    //Create DAMD Threshold   
    public static ASI_CRM_DAMD_Threshold__c createDAMD(String recordTypeDeveloperName, Id grpId, Id vpId, String act, String ms, Decimal wei){
        
        ASI_CRM_DAMD_Threshold__c damd = new ASI_CRM_DAMD_Threshold__c();
        damd.ASI_CRM_SG_Action__c = act;
        damd.ASI_CRM_SG_Group_Outlet_Type__c = grpId;
        damd.ASI_CRM_SG_Market_Share__c = ms;
        damd.ASI_CRM_SG_Min_Weight__c = wei;
        damd.ASI_CRM_SG_Volume_Potential__c = vpId;
               
        return damd;
    }

    public static User runAsStandardUserPortugal(){
        User u = null;
        List<User>users = new List<User>();
        Profile p = [SELECT Id, Name FROM Profile WHERE Name='System Administrator' LIMIT 1]; 

        users = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1];   
                    
        if (users.size()<=0){
            u = new User(
                    Email='testing@email.com', 
                    Alias='test', 
                    TimeZoneSidKey='Asia/Hong_Kong', 
                    Username='testing@email.com', 
                    LanguageLocaleKey='en_US',  
                    LocaleSidKey='en_US',
                    EmailEncodingKey='UTF-8',
                    ProfileId=p.Id, 
                    LastName='Leray', 
                    CompanyName='PernodRicardTaiwan'
                    );
                    
            insert u;
            System.debug('New User inserted:' + u.Id);
        }else{
            u = users[0];
            u.CompanyName='PernodRicardTaiwan';
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
        Profile p = [SELECT Id FROM Profile WHERE Name='ASI TW Standard User']; 
        
        users = [SELECT Id, Country, CompanyName FROM User WHERE UserName='tester2@testorg.com' LIMIT 1];
        if (users.size()<=0){
            u = new User(Alias = 'standt', Email='tester2@testorg.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Hong_Kong', 
                UserName='tester2@testorg.com',
                CompanyName='PernodRicardTaiwan');
        }else{
            u = users[0];
        }
        
        System.runAs(u) 
        {
           System.debug('Current User: ' + UserInfo.getUserName());
        }
        
        return u;
    }
    
    public static Map<String,ID> prosObjectRecordType; // Key format 'countrycode+sobject' : example: EEASI_CRM_Account__c;
    public static Set<String> prosObjects = new Set<String>{'',''};
    
    static {
        prosObjectRecordType = new Map<String,ID>();
        List<RecordType> recordTypes = [select id, developername from RecordType where sObjectType in: prosObjects];
        
        for(RecordType rType : recordTypes){
            prosObjectRecordType.put('TW'+rType.developername,rType.id);
        }
    }
    
    
}