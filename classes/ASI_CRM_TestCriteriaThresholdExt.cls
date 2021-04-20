@isTest
public with sharing class ASI_CRM_TestCriteriaThresholdExt {
    private static User user;
    private static ASI_CRM_AccountsAdditionalField__c account;
    
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    
    public static void init(){
        //user = ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        account = ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1,'ASI_CRM_SG_Outlet')[0];    
        insert account;
        
        criteriaSet = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaSet(1, 'ASI_SG_Image_Level_Criteria')[0];
        insert criteriaSet;     
        
        criteriaThreshold = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaThreshold(1, 'ASI_CRM_SG_Picklist', criteriaSet.Id)[0];
        criteriaThreshold.ASI_CRM_SG_Weight__c = 100; 
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_SG_Picklist', criteriaThreshold.Id)[0];
        criteriaAnswer.ASI_CRM_SG_Value__c = null;
        criteriaAnswer.ASI_CRM_SG_Weight__c = 90;
        criteriaAnswer.ASI_CRM_SG_Base_Currency__c = 50;
        criteriaAnswer.ASI_CRM_SG_Condition__c = 'Less Than or Equal (<=)';
        insert criteriaAnswer;
    
    }
    
    static testMethod void testAddCriteriaAnswer(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            for (Integer i=2; i<=8; i++){
                ASI_CRM_Criteria_Answer__c tempCriteriaAnswer = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_SG_Picklist', criteriaThreshold.Id)[0];
                tempCriteriaAnswer.ASI_CRM_SG_Value__c = null;
                tempCriteriaAnswer.ASI_CRM_SG_Weight__c = 90;
                tempCriteriaAnswer.ASI_CRM_SG_Base_Currency__c = 50;
                tempCriteriaAnswer.ASI_CRM_SG_Condition__c = 'Less Than or Equal (<=)';
                insert tempCriteriaAnswer;
                controller.addCriteriaAnswer();
            }
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 8);
        //}
    }
    
        static testMethod void testMisc(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            controller.addPageMessage('Test', ApexPages.Severity.INFO);
            controller.cancel();
        //}
    }
    static testMethod void testMisc2(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
        criteriaThreshold.id=null;
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
             rf.getParameters().put('setId', criteriaSet.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
 
        //}
    }
    
    static testMethod void testAddCriteriaAnswer2(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            for (Integer i=2; i<=8; i++){
                ASI_CRM_Criteria_Answer__c tempCriteriaAnswer = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_SG_Picklist', criteriaThreshold.Id)[0];
                tempCriteriaAnswer.ASI_CRM_SG_Value__c = null;
                tempCriteriaAnswer.ASI_CRM_SG_Weight__c = 90;
                tempCriteriaAnswer.ASI_CRM_SG_Base_Currency__c = 50;
                tempCriteriaAnswer.ASI_CRM_SG_Condition__c = 'Less Than or Equal (<=)';
                insert tempCriteriaAnswer;
                controller.addCriteriaAnswer(String.valueOf(i), String.valueOf(i));
            }
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 8);
        //}
    }
    
    
    static testMethod void testDeleteCriteriaAnswer(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            rf.getParameters().put('rowIndex', '1');
            controller.deleteCriteriaAnswer();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 7);
        //}
    }
    
    static testMethod void testDeleteCriteriaAnswer2(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            rf.getParameters().put('rowIndex', '1');
            controller.deleteCriteriaAnswer();
            
            rf.getParameters().put('rowIndex', '2');
            controller.deleteCriteriaAnswer();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 6);
        //}
    }
    
    
    static testMethod void testChangeCriteriaType(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            controller.criteriaThreshold.RecordTypeId = ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id;
            controller.changeCriteriaType();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 9);
        //}
    }
    
    static testMethod void testChangeCriteriaType2(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            controller.criteriaThreshold.RecordTypeId = ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id;
            controller.criteriaThreshold.RecordTypeId = ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id;
            
            controller.changeCriteriaType();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 9);
        //}
    }
    

    static testMethod void testSaveCriteria(){
        init();
        
        //ASI_CRM_TestClassUtilityHelperPROS.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/ASI_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            ASI_CRM_CriteriaThresholdExt controller = new ASI_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            controller.saveCriteria();
            
            Map<Id, ASI_CRM_Criteria_Answer__c> criteriaAnswers = new Map<Id, ASI_CRM_Criteria_Answer__c>([SELECT Id, 
                                                    RecordTypeId,
                                                    ASI_CRM_SG_Value__c, 
                                                    ASI_CRM_SG_Base_Currency__c, ASI_CRM_SG_Base_Integer__c,
                                                    ASI_CRM_SG_Condition__c, ASI_CRM_SG_Criteria_Threshold__r.Id,
                                                    ASI_CRM_SG_Label__c, ASI_CRM_SG_Weight__c
                                                    FROM ASI_CRM_Criteria_Answer__c 
                                                    WHERE ASI_CRM_SG_Criteria_Threshold__r.Id =: criteriaThreshold.Id]);
    
            System.assertNotEquals(criteriaAnswers.size(), 0);
        //}
    }
    
    private static List<ASI_CRM_Criteria_Answer__c> createcriteriaAnswers(){
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswers = new List<ASI_CRM_Criteria_Answer__c>();
        
        for (Integer i=1; i<=8; i++){
            ASI_CRM_Criteria_Answer__c tempCriteriaAnswer = ASI_CRM_TestClassUtilityHelperPROS.createCriteriaAnswer(1, 'ASI_CRM_SG_Picklist', criteriaThreshold.Id)[0];
                tempCriteriaAnswer.ASI_CRM_SG_Value__c = null;
                tempCriteriaAnswer.ASI_CRM_SG_Weight__c = 90;
                tempCriteriaAnswer.ASI_CRM_SG_Base_Currency__c = 50;
                tempCriteriaAnswer.ASI_CRM_SG_Condition__c = 'Less Than or Equal (<=)';
                insert tempCriteriaAnswer;
            criteriaAnswers.add(tempCriteriaAnswer);
        }
        return criteriaAnswers;
    }
}