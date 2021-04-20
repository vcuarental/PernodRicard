@isTest
public with sharing class EUR_CRM_TestCriteriaFactory {
    private static String question;
    private static Account account;
    private static EUR_CRM_Affiliate__c affiliate;
    private static EUR_CRM_Criteria_Threshold__c criteriaThreshold;
    private static EUR_CRM_Criteria_Set__c criteriaSet;
    private static EUR_CRM_Criteria_Answer__c criteriaAnswer;
    private static EUR_CRM_Group_Outlet_Type__c groupOutlet;
    private static EUR_CRM_CriteriaManager mgr;// = new EUR_CRM_CriteriaManager();
    
    public static void init(){
        question = 'Sample question 1?';
        
        mgr = new EUR_CRM_CriteriaManager();
        
        System.debug('Flag - Check TestClassHelper:' + EUR_CRM_TestClassHelper.prosPortugalRecordType);
        
        account = EUR_CRM_TestClassHelper.createAccount('Test');    
        insert account;
        
        affiliate = EUR_CRM_TestClassHelper.createAffiliate();
        insert affiliate;   
        //Create Criteria Set for Image Level
        criteriaSet = EUR_CRM_TestClassHelper.createCriteriaSet(EUR_CRM_TestClassHelper.volumeRecordType.Id);
        insert criteriaSet;     
    }
    
    static void initIntegerCriteria(){
        init();
        
        criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.integerThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
        insert criteriaAnswer;
    }
    
    static void initTextCriteria(){
        init();
        
        criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.textThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id);
        insert criteriaAnswer;
    }
    
    static void initBooleanCriteria(){
        init();
        
        criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'True', 'True', 100);
        insert criteriaAnswer;
    }
    
    static void initCurrencyCriteria(){
        init();
        
        criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.currencyThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Double.valueOf(0), Double.valueOf(100));
        insert criteriaAnswer;
    }
    
    static void initPicklistCriteria(){
        init();
        
        criteriaThreshold = EUR_CRM_TestClassHelper.createCriteriaThreshold(criteriaSet.Id, 
                                                            EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id, 
                                                            question, 100);
        insert criteriaThreshold;
        
        criteriaAnswer = EUR_CRM_TestClassHelper.createCriteriaAnswer(criteriaThreshold.Id, 'A', 100);
        insert criteriaAnswer;
    }
    
    static testMethod void testIntegerCalculateCriteria()
    {
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.integerThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', 50, Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', 50, Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.integerThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(EUR_CRM_TestClassHelper.integerThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testIntegerGetCriteria1(){
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.integerThresholdRecordType.Id).getCriteriaComponent
                                                (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testIntegerGetCriteria2(){
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.integerThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.textThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.textThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        mgr.newClassInstance(EUR_CRM_TestClassHelper.textThresholdRecordType.Id).setCriteria
                                                        (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testTextGetCriteria1()
    {
        initTextCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.textThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold);

        criteriaAnswerOptions.add(ans1);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.textThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id).setCriteria
                                                        (criteriaThreshold, criteriaAnswerOptions); 
    }
    
    static testMethod void testBooleanGetCriteria1()
    {
        initBooleanCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'true';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.currencyThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.currencyThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(EUR_CRM_TestClassHelper.currencyThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testCurrencyGetCriteria1()
    {
        initCurrencyCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40.00';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.currencyThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //EUR_CRM_Criteria_Answer__c temp = EUR_CRM_TestClassHelper.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.currencyThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Double result = mgr.newClassInstance(EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id).calculateCriteria(
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    
    }
    
    static testMethod void testPicklistGetCriteria1()
    {
        initPicklistCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = 'A';
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id).getCriteriaComponent
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
        
        List<EUR_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<EUR_CRM_Criteria_Answer__c>();
        
        //Args: Id cThreshold
        EUR_CRM_Criteria_Answer__c ans1 = EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        insert ans1;
        EUR_CRM_Criteria_Answer__c ans2 =EUR_CRM_TestClassHelper.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(EUR_CRM_TestClassHelper.picklistThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testCriteriaMgrDefaultRecordType(){
        init();
        
        Id defaultRecordType = mgr.getDefaultRecordType();
        
        System.assertEquals(defaultRecordType, EUR_CRM_TestClassHelper.booleanThresholdRecordType.Id);
    }
    
    static testMethod void testCriteriaMgrGetAnsRecordType(){
        init();
        
        Id getAnsRecordType = mgr.getAnswerRecordType(EUR_CRM_TestClassHelper.integerThresholdRecordType.Id);
        
        System.assertEquals(getAnsRecordType, EUR_CRM_TestClassHelper.integerAnswerRecordType.Id);
        
    }
}