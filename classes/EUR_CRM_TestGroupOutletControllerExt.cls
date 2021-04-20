@isTest
public with sharing class EUR_CRM_TestGroupOutletControllerExt {
    private static User user;
    private static EUR_CRM_Group_Outlet_Type__c groupOutletType;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Criteria_Threshold__c criteriaThresholdImage;
    private static EUR_CRM_Criteria_Set__c criteriaSetImage;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswerImage;
    private static EUR_CRM_Criteria_Threshold__c criteriaThresholdVolume;
    private static EUR_CRM_Criteria_Set__c criteriaSetVolume;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswerVolume;
    private static String groupOutletName;
    private static EUR_CRM_Image_Level__c iconicImageLevel;
    private static EUR_CRM_Image_Level__c leadingImageLevel;
    private static EUR_CRM_Image_Level__c premiumImageLevel;
    private static EUR_CRM_Image_Level__c mainstreamImageLevel;
    private static EUR_CRM_Image_Level_Threshold__c iconicImageLevelThreshold;
    private static EUR_CRM_Image_Level_Threshold__c leadingImageLevelThreshold;
    private static EUR_CRM_Image_Level_Threshold__c PremiumImageLevelThreshold;
    private static EUR_CRM_Image_Level_Threshold__c mainstreamImageLevelThreshold;
    private static EUR_CRM_Volume_Potential__c highVolPontential;
    private static EUR_CRM_Volume_Potential__c mediumVolPontential;
    private static EUR_CRM_Volume_Potential__c lowVolPontential;
    private static EUR_CRM_Volume_Potential_Threshold__c highVolPontentialThreshold;
    private static EUR_CRM_Volume_Potential_Threshold__c mediumVolPontentialThreshold;
    private static EUR_CRM_Volume_Potential_Threshold__c lowVolPontentialThreshold;
    private static String countryCode = '';
    private static String value;
    
    public static void setupUser(){
      user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
      user.BypassTriggers__c = 'ESN_User_AutojoinByAffiliates';
    }
    
    public static void init(){
        //create user
        // user = EUR_CRM_TestClassUtilityHelper.createUser('System Administrator');
        // insert user;
        //create criteria set
        criteriaSetImage = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,countryCode +' Image Level Criteria')).get(0);
        insert criteriaSetImage; 
        //create criteria threshold
        criteriaThresholdImage = (EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1,'Text Input',criteriaSetImage.id)).get(0);
        insert criteriaThresholdImage ; 
        //create criteria answer
        criteriaAnswerImage= (EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1,'Text Input',criteriaThresholdImage.id)).get(0);
        insert criteriaAnswerImage;
        //create volume criteria set
        criteriaSetVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaSet(1,countryCode +' Volume Potential Criteria')).get(0);
        insert criteriaSetVolume ; 
        //create criteria threshold
        criteriaThresholdVolume = (EUR_CRM_TestClassUtilityHelper.createCriteriaThreshold(1,'Text Input',criteriaSetVolume.id)).get(0);
        insert criteriaThresholdVolume ; 
        //create criteria answer
        criteriaAnswerVolume= (EUR_CRM_TestClassUtilityHelper.createCriteriaAnswer(1,'Text Input',criteriaThresholdVolume.id)).get(0);
        insert criteriaAnswerVolume;         
        //create group outlet type
        groupOutletType = (EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1,'EUR '+countryCode+' Group Outlet','EUR',criteriaSetImage.id,criteriaSetVolume.id)).get(0);
        insert groupOutletType;  
        //create image level       
        iconicImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Iconic')).get(0);
        insert iconicImageLevel;       
        leadingImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Leading')).get(0);
        insert leadingImageLevel;       
        premiumImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Premium')).get(0);
        insert premiumImageLevel;       
        mainstreamImageLevel = (EUR_CRM_TestClassUtilityHelper.createImageLevel(1,countryCode+' Image Level','EUR',groupOutletType.id,'Mainstream')).get(0);
        insert mainstreamImageLevel ;
        
        /*if(countryCode == 'GB') {
            insert EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'GB Image Level', 'EUR', groupOutletType.id, 'Mainstream Quality')
        }*/
        
        iconicImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,iconicImageLevel.id,80)).get(0);
        insert iconicImageLevelThreshold;
        leadingImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,leadingImageLevel.id,60)).get(0);
        insert leadingImageLevelThreshold ; 
        premiumImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,premiumImageLevel.id,40)).get(0);
        insert premiumImageLevelThreshold ;  
        mainstreamImageLevelThreshold = (EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1,groupOutletType.id,mainstreamImageLevel.id,20)).get(0);
        insert mainstreamImageLevelThreshold ;   
        
        highVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,countryCode+' Volume Potential','EUR',groupOutletType.id,'High')).get(0);
        insert highVolPontential ;        
        mediumVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,countryCode+' Volume Potential','EUR',groupOutletType.id,'Medium')).get(0);
        insert mediumVolPontential ;        
        lowVolPontential = (EUR_CRM_TestClassUtilityHelper.createvolumePotential(1,countryCode+' Volume Potential','EUR',groupOutletType.id,'Low')).get(0);
        insert lowVolPontential ;
        
        highVolPontentialThreshold = (EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1500)).get(0);
        insert highVolPontentialThreshold ;
        mediumVolPontentialThreshold = (EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,1000)).get(0);
        insert mediumVolPontentialThreshold ;
        lowVolPontentialThreshold = (EUR_CRM_TestClassUtilityHelper.createvolumePotentialThreshold(1,groupOutletType.id,highVolPontential.id,500)).get(0);
        insert lowVolPontentialThreshold ;  
        
    }
    static testMethod void testNewPageEE(){
        countryCode ='EE';
        init();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
        PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
        rf.getParameters().put('id', groupOutletType.id);
        rf.getParameters().put('RecordType', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Group_Outlet_Type__c','EUR '+countryCode+' Group Outlet'));
        Test.setCurrentPage(rf);
        //String rtName = groupOutletType.RecordType.DeveloperName;
        EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
    }
        static testMethod void testNewPageLT(){
        countryCode ='LT';
        init();
        groupOutletType.id =null;
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
        PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
        rf.getParameters().put('id', null);
        rf.getParameters().put('RecordType', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Group_Outlet_Type__c','EUR '+countryCode+' Group Outlet'));
        Test.setCurrentPage(rf);
        //String rtName = groupOutletType.RecordType.DeveloperName; 
        EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
    }
        static testMethod void testNewPageLV(){
        countryCode ='LV';
        init();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
        PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
        rf.getParameters().put('id', groupOutletType.id);
        rf.getParameters().put('RecordType', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Group_Outlet_Type__c','EUR '+countryCode+' Group Outlet'));
        rf.getParameters().put('rowIndex', '0');
        Test.setCurrentPage(rf);
        //String rtName = groupOutletType.RecordType.DeveloperName;
        EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
        controller.saveGroupOutlet();
        controller.returnMapIsUK();
        Boolean d = controller.hasOutletDescription;
        SeT<String> s = controller.imageSetValues;
        Integer x = controller.rowIndex;
        List<EUR_CRM_Volume_Potential__c> volumePotentialsList = controller.volumePotentialsList;
        
        List<String> countrycodes = new List<String>{'CZ','SK','GB','PRT','EE','AT','DE', 'dfdfd'};
        
        for(String cc : countrycodes){
            String r = EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Group_Outlet_Type__c','EUR '+cc+' Group Outlet');
            if(r != null){
                controller.rid = r;
                controller.initOutletTypes();
            }
        }
        controller.addPageMessage('test', ApexPages.Severity.WARNING);
        controller.deleteOutletType();
    }

    static testMethod void savePage(){
        countryCode ='EE';
        init();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
        PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
        rf.getParameters().put('id', groupOutletType.id);
        rf.getParameters().put('rowIndex', '0');
        rf.getParameters().put('RecordType', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Group_Outlet_Type__c','EUR '+countryCode+' Group Outlet'));
        Test.setCurrentPage(rf);
        //String rtName = groupOutletType.RecordType.DeveloperName;
        EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
        controller.saveGroupOutlet();
        controller.deleteOutletType();
        controller.returnMapIsUK();
        controller.addPageMessage('TEST', ApexPages.Severity.INFO);
    }

    static testMethod void GBGroupOutlet(){
        countryCode ='GB';
        init();
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
        PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
        rf.getParameters().put('id', groupOutletType.id);
        rf.getParameters().put('rowIndex', '0');
        rf.getParameters().put('RecordType', EUR_CRM_TestClassUtilityHelper.getRecordTypeId('EUR_CRM_Group_Outlet_Type__c','EUR '+countryCode+' Group Outlet'));
        Test.setCurrentPage(rf);
        //String rtName = groupOutletType.RecordType.DeveloperName;
        /*EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
        controller.saveGroupOutlet();
        controller.deleteOutletType();
        controller.returnMapIsUK();
        controller.addPageMessage('TEST', ApexPages.Severity.INFO);*/
    }
    
    /*
    public static void init(){
        groupOutletName = 'Test';
        value = 'TestValue1';
        Double weight = 100;

        //System.runAs(user){
          affiliate = EUR_CRM_TestClassHelper.createAffiliate();
          insert affiliate;
          
          criteriaSet = EUR_CRM_TestClassHelper.createCriteriaSet(EUR_CRM_TestClassHelper.imageRecordType.Id);
          insert criteriaSet;     
          
          criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                      EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id, 100);
          insert criteriaThreshold;
          
          criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, value, weight);
          insert criteriaAnswer;
          RecordType groupOutletRecordtypeLT = [select Id from RecordType where SobjectType='EUR_CRM_Group_Outlet_Type__c' and DeveloperName = 'EUR_LT_Group_Outlet' LIMIT 1];
          groupOutletType = EUR_CRM_TestClassHelper.createGroupOutlet(groupOutletName, affiliate.Id, criteriaSet.Id, null);
          groupOutletType.RecordTypeId = groupOutletRecordtypeLT.Id;
          insert groupOutletType;
        //}
        
    }
    static testMethod void testNewPage(){
        //init();
        setupUser();
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        System.runAs(user){
          init();
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
            PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
            rf.getParameters().put('id', groupOutletType.id);
            Test.setCurrentPage(rf);
            //String rtName = groupOutletType.RecordType.DeveloperName;
            EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
            //controller.recordtypeDevName = rtNAme;
        }
    }
    
    static testMethod void testAddOutletType(){
        //init();
    setupUser();
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        System.runAs(user){
          init();
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
            PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
            rf.getParameters().put('id', groupOutletType.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
            
            Integer orginalOutletTypeCount = controller.outletTypesDisplay.size();
            controller.addOutletType();
            
            System.assertEquals(controller.outletTypesDisplay.size(), orginalOutletTypeCount+1);
        }
    }
    
    static testMethod void testDeleteOutletType(){
        setupUser();

        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        System.runAs(user){
          init();
          
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
            PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
            rf.getParameters().put('id', groupOutletType.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
            
            controller.addOutletType();
            controller.addOutletType();
            
            Integer orginalOutletTypeCount = controller.outletTypesDisplay.size();
    
            rf.getParameters().put('rowIndex', '0');
            controller.deleteOutletType();
            
            System.assertEquals(controller.outletTypesDisplay.size(), orginalOutletTypeCount-1);
        }
    }
    
    static testMethod void testSaveGroupOutlet(){
        String name = 'Test';   
    
        setupUser();

        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        System.runAs(user){
          init();
          
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(groupOutletType);
            PageReference rf = new Pagereference('/apex/EUR_CRM_GroupOutletPage');
            rf.getParameters().put('id', groupOutletType.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_GroupOutletControllerExt controller = new EUR_CRM_GroupOutletControllerExt(standardController);
    
            System.assertNotEquals(controller.groupOutletType, null);
            
            //Change group outlet type settings
            controller.groupOutletType.EUR_CRM_Name__c = name;
            
            controller.saveGroupOutlet();
            
            System.assertEquals(controller.groupOutletType.EUR_CRM_Name__c, name);
        }
    }
    */
}