@isTest
public with sharing class EUR_CRM_TestCriteriaThresholdExt {
    private static User user;
    private static Account account;
    private static EUR_CRM_Affiliate__c affiliate;
    
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Set__c criteriaSet;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    
    public static void init(){
        //user = EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        account = EUR_CRM_TestClassHelper.createAccount('Test');    
        insert account;
        
        affiliate = EUR_CRM_TestClassHelper.createAffiliate();
        insert affiliate;
        
        criteriaSet = EUR_CRM_TestClassHelper.createCriteriaSet(EUR_CRM_TestClassHelper.imageRecordType.Id);
        insert criteriaSet;     
        
        criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                    EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, '1', 50);
        insert criteriaAnswer;
    
    }
    
    static testMethod void testAddCriteriaAnswer(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
            for (Integer i=2; i<=8; i++){
                EUR_CRM_Criteria_Answer__c tempCriteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 
                                                                                        String.valueOf(i), i*10);
                insert tempCriteriaAnswer;
                controller.addCriteriaAnswer();
            }
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 8);
        //}
    }
    
        static testMethod void testMisc(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            controller.addPageMessage('Test', ApexPages.Severity.INFO);
            controller.cancel();
        //}
    }
    static testMethod void testMisc2(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
        criteriaThreshold.id=null;
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
             rf.getParameters().put('setId', criteriaSet.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
 
        //}
    }
    
    static testMethod void testAddCriteriaAnswer2(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
            for (Integer i=2; i<=8; i++){
                EUR_CRM_Criteria_Answer__c tempCriteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 
                                                                                        String.valueOf(i), i*10);
                insert tempCriteriaAnswer;
                controller.addCriteriaAnswer(String.valueOf(i), String.valueOf(i));
            }
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 8);
        //}
    }
    
    
    static testMethod void testDeleteCriteriaAnswer(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            rf.getParameters().put('rowIndex', '1');
            controller.deleteCriteriaAnswer();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 7);
        //}
    }
    
    static testMethod void testDeleteCriteriaAnswer2(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
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
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            controller.criteriaThreshold.RecordTypeId = EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id;
            controller.changeCriteriaType();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 9);
        //}
    }
    
    static testMethod void testChangeCriteriaType2(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            controller.criteriaThreshold.RecordTypeId = EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id;
            controller.criteriaThreshold.RecordTypeId = EUR_CRM_TestClassHelper.integerThresholdRecordType.Id;
            
            controller.changeCriteriaType();
    
            System.assertEquals(controller.criteriaAnswersDisplay.size(), 9);
        //}
    }
    

    static testMethod void testSaveCriteria(){
        init();
        
        //EUR_CRM_TestClassHelper.runAsStandardUserPortugal();
        //System.runAs(user){
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(criteriaThreshold);
            PageReference rf = new Pagereference('/apex/EUR_CRM_CriteriaThresholdPage');
            rf.getParameters().put('id', criteriaThreshold.id);
            Test.setCurrentPage(rf);
            
            EUR_CRM_CriteriaThresholdExt controller = new EUR_CRM_CriteriaThresholdExt(standardController);
            
            controller.criteriaAnswersDisplay = createcriteriaAnswers();
            controller.saveCriteria();
            
            Map<Id, EUR_CRM_Criteria_Answer__c> criteriaAnswers = new Map<Id, EUR_CRM_Criteria_Answer__c>([SELECT Id, 
                                                    RecordTypeId,
                                                    EUR_CRM_Value__c, 
                                                    EUR_CRM_Base_Currency__c, EUR_CRM_Base_Integer__c,
                                                    EUR_CRM_Condition__c, EUR_CRM_Criteria_Threshold__r.Id,
                                                    EUR_CRM_Label__c, EUR_CRM_Weight__c
                                                    FROM EUR_CRM_Criteria_Answer__c 
                                                    WHERE EUR_CRM_Criteria_Threshold__r.Id =: criteriaThreshold.Id]);
    
            System.assertNotEquals(criteriaAnswers.size(), 0);
        //}
    }
    
    private static List<EUR_CRM_Criteria_Answer__c> createcriteriaAnswers(){
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswers = new List<EUR_CRM_Criteria_Answer__c>();
        
        for (Integer i=1; i<=8; i++){
            EUR_CRM_Criteria_Answer__c tempCriteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 
                                                                                    String.valueOf(i), i*10);
            insert tempCriteriaAnswer;
            criteriaAnswers.add(tempCriteriaAnswer);
        }
        return criteriaAnswers;
    }
}