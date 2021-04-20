@isTest
public with sharing class ASI_CRM_TestCriteriaFactory {
    private static String question;
    private static ASI_CRM_AccountsAdditionalField__c account;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    private static ASI_CRM_Group_Outlet_Type__c groupOutlet;
    private static ASI_CRM_CriteriaManager mgr;// = new ASI_CRM_CriteriaManager();
    
    public static void init(){
        question = 'Sample question 1?';
        
        mgr = new ASI_CRM_CriteriaManager();
        
        System.debug('Flag - Check TestClassHelper:' + ASI_CRM_TestClassHelperPROS.prosSGRecordType);
        
        account = ASI_CRM_TestClassHelperPROS.createAccount('Test');    
        insert account;
         
        //Create Criteria Set for Image Level
        criteriaSet = ASI_CRM_TestClassHelperPROS.createCriteriaSet(ASI_CRM_TestClassHelperPROS.volumeRecordType.Id);
        insert criteriaSet;     
    }
    
    static void initIntegerCriteria(){
        init();
        
        criteriaThreshold = ASI_CRM_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
        insert criteriaAnswer;
    }
    
    static void initTextCriteria(){
        init();
        
        criteriaThreshold = ASI_CRM_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TestClassHelperPROS.textThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id);
        insert criteriaAnswer;
    }
    
    static void initBooleanCriteria(){
        init();
        
        criteriaThreshold = ASI_CRM_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'True', 'True', 100);
        insert criteriaAnswer;
    }
    
    static void initCurrencyCriteria(){
        init();
        
        criteriaThreshold = ASI_CRM_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TestClassHelperPROS.currencyThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Double.valueOf(0), Double.valueOf(100));
        insert criteriaAnswer;
    }
    
    static void initPicklistCriteria(){
        init();
        
        criteriaThreshold = ASI_CRM_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TestClassHelperPROS.picklistThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'A', 100);
        insert criteriaAnswer;
    }
    
    static testMethod void testIntegerCalculateCriteria()
    {
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);
        //System.assertEquals(result, .10);
        
    }
    
    static testMethod void testIntegerCalculateNullCriteria()
    {
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', 50, Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', 50, Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);
        System.assertEquals(result, 0);
        
    }
    
    static testMethod void testIntegerSetCriteria(){
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testIntegerGetCriteria1(){
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id).getCriteriaComponent
                                                (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testIntegerGetCriteria2(){
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    
    static testMethod void testTextCalculateCriteria()
    {
        initTextCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.textThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);
        System.assertEquals(result, 0);
        
    }
    
    static testMethod void testTextNullCalculateCriteria()
    {
        initTextCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.textThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);
        System.assertEquals(result, 0);
        
    }
    
    static testMethod void testTextSetCriteria()
    {
        initTextCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.textThresholdRecordType.Id).setCriteria
                                                        (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testTextGetCriteria1()
    {
        initTextCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.textThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testTextGetCriteria2()
    {
        initTextCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.textThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    
    static testMethod void testBooleanNullCalculateCriteria()
    {
        initBooleanCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'true';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);
        System.assertEquals(result, 0);
        
    }
    
    static testMethod void testBooleanCalculateCriteria()
    {
        initBooleanCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'true';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);
        System.assertEquals(result, .80);
        
    }
    
    static testMethod void testBooleanSetCriteria()
    {
        initBooleanCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'true';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id).setCriteria
                                                        (criteriaThreshold, criteriaAnswerOptions); 
    }
    
    static testMethod void testBooleanGetCriteria1()
    {
        initBooleanCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'true';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
        
    }
    
    static testMethod void testBooleanGetCriteria2()
    {
        initBooleanCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'true';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testCurrencyCalculateCriteria()
    {
        initCurrencyCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40.00';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.currencyThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);
        System.assertEquals(result, .10);
    }
    
    static testMethod void testCurrencyNullCalculateCriteria()
    {
        initCurrencyCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40.00';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.currencyThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);
        System.assertEquals(result, .10);
    }
    
    static testMethod void testCurrencySetCriteria()
    {
        initCurrencyCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40.00';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.currencyThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testCurrencyGetCriteria1()
    {
        initCurrencyCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40.00';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.currencyThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testCurrencyGetCriteria2()
    {
        initCurrencyCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40.00';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.currencyThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testPicklistCalculateCriteria()
    {
        initPicklistCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'A';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.picklistThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);
        System.assertEquals(result, .80);
    }
    
    static testMethod void testPicklistNullCalculateCriteria()
    {
        initPicklistCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'A';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.picklistThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);
        System.assertEquals(result, 0);
    }
    
    static testMethod void testPicklistSetCriteria()
    {
        initPicklistCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'A';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.picklistThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    
    }
    
    static testMethod void testPicklistGetCriteria1()
    {
        initPicklistCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'A';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.picklistThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testPicklistGetCriteria2()
    {
        initPicklistCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'A';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TestClassHelperPROS.picklistThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testCriteriaMgrDefaultRecordType(){
        init();
        
        Id defaultRecordType = mgr.getDefaultRecordType();
        
        System.assertEquals(defaultRecordType, ASI_CRM_TestClassHelperPROS.booleanThresholdRecordType.Id);
    }
    
    static testMethod void testCriteriaMgrGetAnsRecordType(){
        init();
        
        Id getAnsRecordType = mgr.getAnswerRecordType(ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id);
        
        System.assertEquals(getAnsRecordType, ASI_CRM_TestClassHelperPROS.integerAnswerRecordType.Id);
        
    }
}