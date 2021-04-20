/*********************************************************************************
 * Name: ASI_CRM_TW_TestCriteriaFactory
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/05/2015       Laputa: Alvin           Cloned from ASI_CRM_TestCriteriaFactory
*********************************************************************************/
@isTest
public with sharing class ASI_CRM_TW_TestCriteriaFactory{
    private static String question;
    private static ASI_CRM_AccountsAdditionalField__c account;
    private static ASI_CRM_Criteria_Threshold__c criteriaThreshold;
    private static ASI_CRM_Criteria_Set__c criteriaSet;
    private static ASI_CRM_Criteria_Answer__c criteriaAnswer;
    private static ASI_CRM_Group_Outlet_Type__c groupOutlet;
    private static ASI_CRM_TW_CriteriaManager  mgr;// = new ASI_CRM_TW_CriteriaManager();
    
    public static void init(){
        question = 'Sample question 1?';
        
        mgr = new ASI_CRM_TW_CriteriaManager();
        
        //account = ASI_CRM_TW_TestClassHelperPROS.createAccount('Test');  
        Account acc = new Account(Name='TestAccount', RecordTypeId = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Outlet'));     
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
          
        account = new ASI_CRM_AccountsAdditionalField__c(Name = 'Test', RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet'),
                                                         ASI_CRM_Account__c = acc.id, ASI_TH_CRM_OutletType__c = ot.id, ASI_CRM_Region__c = 'North');
        insert account;
         
        //Create Criteria Set for Image Level
        //criteriaSet = ASI_CRM_TW_TestClassHelperPROS.createCriteriaSet(ASI_CRM_TW_TestClassHelperPROS.volumeRecordType.Id);
        criteriaSet = new ASI_CRM_Criteria_Set__c(ASI_CRM_SG_Name__c = 'Test', RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Set__cASI_CRM_TW_Volume_Potential_Criteria'));
        insert criteriaSet;     
    }
    
    static void initIntegerCriteria(){
        init();
        
        /*criteriaThreshold = ASI_CRM_TW_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id,                                                            
                                                            ASI_CRM_TestClassHelperPROS.integerThresholdRecordType.Id, 
                                                            question, 100);*/
        criteriaThreshold = new ASI_CRM_Criteria_Threshold__c(ASI_CRM_SG_Criteria_Set__c=criteriaSet.Id, RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Number_Input'),
                                                              ASI_CRM_SG_Question__c = 'Test Question', ASI_CRM_SG_Weight__c=100);
        insert criteriaThreshold;
        
        //criteriaAnswer = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Integer.valueOf(0), 100);
        criteriaAnswer = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Base_Currency__c=Double.valueOf(0), ASI_CRM_SG_Condition__c = 'Greater Than (>)', ASI_CRM_SG_Weight__c =Double.valueOf(100));
        insert criteriaAnswer;
    }
    
    static void initTextCriteria(){
        init();
        
        /*criteriaThreshold = ASI_CRM_TW_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TW_TestClassHelperPROS.textThresholdRecordType.Id, 
                                                            question, 100);*/
        criteriaThreshold = new ASI_CRM_Criteria_Threshold__c(ASI_CRM_SG_Criteria_Set__c=criteriaSet.Id, RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Text_Input'),
                                                              ASI_CRM_SG_Question__c = 'Test Question', ASI_CRM_SG_Weight__c=100);
        insert criteriaThreshold;
        
        //criteriaAnswer = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id);
        criteriaAnswer = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Text_Input'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.id);
        insert criteriaAnswer;
    }
    
    static void initBooleanCriteria(){
        init();
        
        criteriaThreshold = (new ASI_CRM_Criteria_Threshold__c(ASI_CRM_SG_Criteria_Set__c=criteriaSet.Id, 
                                                            RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean'), 
                                                            ASI_CRM_SG_Question__c = 'Test Question', ASI_CRM_SG_Weight__c=100));
        insert criteriaThreshold;
        
        //criteriaAnswer = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'True', 'True', 100);
        criteriaAnswer = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Label__c='True', ASI_CRM_SG_Value__c='True', ASI_CRM_SG_Weight__c =100);
        insert criteriaAnswer;
    }
    
    static void initCurrencyCriteria(){
        init();
        
        //criteriaThreshold = ASI_CRM_TW_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
        //                                                    ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id, question, 100);
        criteriaThreshold = new ASI_CRM_Criteria_Threshold__c(ASI_CRM_SG_Criteria_Set__c=criteriaSet.Id, RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Currency_Input'),
                                                              ASI_CRM_SG_Question__c = 'Test Question', ASI_CRM_SG_Weight__c=100);
        insert criteriaThreshold;
        
        //criteriaAnswer = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'Greater Than (>)', Double.valueOf(0), Double.valueOf(100));
        criteriaAnswer = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Base_Currency__c=Double.valueOf(0), ASI_CRM_SG_Condition__c ='Greater Than (>)', ASI_CRM_SG_Weight__c =Double.valueOf(100));
        insert criteriaAnswer;
    }
    
    static void initPicklistCriteria(){
        init();
        
        /*criteriaThreshold = ASI_CRM_TW_TestClassHelperPROS.createCriteriaThreshold(criteriaSet.Id, 
                                                            ASI_CRM_TW_TestClassHelperPROS.picklistThresholdRecordType.Id, 
                                                            question, 100);*/
        criteriaThreshold = new ASI_CRM_Criteria_Threshold__c(ASI_CRM_SG_Criteria_Set__c=criteriaSet.Id, RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Picklist'),
                                                              ASI_CRM_SG_Question__c = 'Test Question', ASI_CRM_SG_Weight__c=100);
        insert criteriaThreshold;
        
        //criteriaAnswer = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(criteriaThreshold.Id, 'A', 100);
        criteriaAnswer = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Value__c='A', ASI_CRM_SG_Weight__c =100);
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Integer.valueOf(50), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                        ASI_CRM_SG_Weight__c=Double.valueOf(10));        
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Integer.valueOf(50), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                        ASI_CRM_SG_Weight__c=Double.valueOf(90));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.integerThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Number_Input')).calculateCriteria(
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.integerThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Number_Input')).calculateCriteria(
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.integerThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);*/
        mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Number_Input')).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);
    }
    
    static testMethod void testIntegerGetCriteria1(){
        initIntegerCriteria();
        
        //Test Integer Input
        Id cthreshold = criteriaThreshold.Id;
        
        Double thresholdWeight = 1.00;
        String answer = '40';
        
        List<ASI_CRM_Criteria_Answer__c> criteriaAnswerOptions = new List<ASI_CRM_Criteria_Answer__c>();
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.integerThresholdRecordType.Id).getCriteriaComponent
                                                (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Number_Input')).getCriteriaComponent
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Integer_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.integerThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Number_Input')).getCriteriaComponent
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold);
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Text_Input'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold);
        criteriaAnswerOptions.add(ans1);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.textThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Text_Input')).calculateCriteria(
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold);
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Text_Input'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold);
        criteriaAnswerOptions.add(ans1);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.textThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Text_Input')).calculateCriteria(
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold);
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Text_Input'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold);
        criteriaAnswerOptions.add(ans1);
        
        /*mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.textThresholdRecordType.Id).setCriteria
                                                        (criteriaThreshold, criteriaAnswerOptions);*/
        mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Text_Input')).setCriteria
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold);
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Text_Input'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold);
        criteriaAnswerOptions.add(ans1);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.textThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Text_Input')).getCriteriaComponent
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold);
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Text_Input'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold);
        criteriaAnswerOptions.add(ans1);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.textThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Text_Input')).getCriteriaComponent
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Label__c='True', ASI_CRM_SG_Value__c='True', ASI_CRM_SG_Weight__c =Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Label__c='false', ASI_CRM_SG_Value__c='false', ASI_CRM_SG_Weight__c =Double.valueOf(20));
        
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.booleanThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean')).calculateCriteria(
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Label__c='True', ASI_CRM_SG_Value__c='True', ASI_CRM_SG_Weight__c =Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Label__c='false', ASI_CRM_SG_Value__c='false', ASI_CRM_SG_Weight__c =Double.valueOf(20));
        
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.booleanThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean')).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);
        System.assertEquals(result, 0.8);
        
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Label__c='True', ASI_CRM_SG_Value__c='True', ASI_CRM_SG_Weight__c =Double.valueOf(80));        
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), 
                                                                        ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Label__c='false', ASI_CRM_SG_Value__c='false', ASI_CRM_SG_Weight__c =Double.valueOf(20));
        
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean')).setCriteria
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Label__c='True', ASI_CRM_SG_Value__c='True', ASI_CRM_SG_Weight__c =Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Label__c='false', ASI_CRM_SG_Value__c='false', ASI_CRM_SG_Weight__c =Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean')).getCriteriaComponent
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'true', 'true', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Label__c='True', ASI_CRM_SG_Value__c='True', ASI_CRM_SG_Weight__c =Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'false', 'false', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Boolean'), ASI_CRM_SG_Criteria_Threshold__c=criteriaThreshold.Id,
                                                        ASI_CRM_SG_Label__c='false', ASI_CRM_SG_Value__c='false', ASI_CRM_SG_Weight__c =Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean')).getCriteriaComponent
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Currency_Input')).calculateCriteria(
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Currency_Input')).calculateCriteria(
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);*/
        mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Currency_Input')).setCriteria
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Currency_Input')).getCriteriaComponent
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
        
        //ASI_CRM_Criteria_Answer__c temp = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cThreshold, '<=', 50, .10);
        //Args: Id cThreshold, String condition, Integer integerValue, Double weight
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Less Than or Equal (<=)', Double.valueOf(50.00), Double.valueOf(10));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Less Than or Equal (<=)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(10));    
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'Greater Than (>)', Double.valueOf(50.00), Double.valueOf(90));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'), 
                                                                         ASI_CRM_SG_Criteria_Threshold__c=cthreshold, ASI_CRM_SG_Base_Currency__c=Integer.valueOf(50), ASI_CRM_SG_Condition__c ='Greater Than (>)', 
                                                                         ASI_CRM_SG_Weight__c=Double.valueOf(90));    
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Currency_Input')).getCriteriaComponent
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='A', ASI_CRM_SG_Weight__c=Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='B', ASI_CRM_SG_Weight__c=Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.picklistThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        answer);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Picklist')).calculateCriteria(
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='A', ASI_CRM_SG_Weight__c=Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='B', ASI_CRM_SG_Weight__c=Double.valueOf(80));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Double result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.picklistThresholdRecordType.Id).calculateCriteria(
                                                        thresholdWeight, 
                                                        criteriaAnswerOptions, 
                                                        null);*/
        Double result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Picklist')).calculateCriteria(
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='A', ASI_CRM_SG_Weight__c=Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='B', ASI_CRM_SG_Weight__c=Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.picklistThresholdRecordType.Id).setCriteria
                                                (criteriaThreshold, criteriaAnswerOptions);*/
        mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Picklist')).setCriteria
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='A', ASI_CRM_SG_Weight__c=Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='B', ASI_CRM_SG_Weight__c=Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        /*Component.Apex.PageBlockSection result = mgr.newClassInstance(ASI_CRM_TW_TestClassHelperPROS.picklistThresholdRecordType.Id).getCriteriaComponent
                                    (account.Id, criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);*/
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Picklist')).getCriteriaComponent
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
        //ASI_CRM_Criteria_Answer__c ans1 = ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'A', Double.valueOf(80));
        ASI_CRM_Criteria_Answer__c ans1 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='A', ASI_CRM_SG_Weight__c=Double.valueOf(80));
        insert ans1;
        //ASI_CRM_Criteria_Answer__c ans2 =ASI_CRM_TW_TestClassHelperPROS.createCriteriaAnswer(cthreshold, 'B', Double.valueOf(20));
        ASI_CRM_Criteria_Answer__c ans2 = new ASI_CRM_Criteria_Answer__c(RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Picklist'), ASI_CRM_SG_Criteria_Threshold__c=cthreshold,
                                                                        ASI_CRM_SG_Value__c='B', ASI_CRM_SG_Weight__c=Double.valueOf(20));
        insert ans2;
        
        criteriaAnswerOptions.add(ans1);
        criteriaAnswerOptions.add(ans2);
        
        Component.Apex.PageBlockSection result = mgr.newClassInstance(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Picklist')).getCriteriaComponent
                                    (criteriaThreshold, criteriaAnswerOptions, '{!TargetComponent}', null);
        System.assertNotEquals(result, null);
    }
    
    static testMethod void testCriteriaMgrDefaultRecordType(){
        init();
        
        Id defaultRecordType = mgr.getDefaultRecordType();
        
        //System.assertEquals(defaultRecordType, ASI_CRM_TW_TestClassHelperPROS.currencyThresholdRecordType.Id);
        System.assertEquals(defaultRecordType, Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Threshold__cASI_CRM_TW_Boolean'));
    }
    
    static testMethod void testCriteriaMgrGetAnsRecordType(){
        init();
        
        //Id getAnsRecordType = mgr.getAnswerRecordType(ASI_CRM_TW_TestClassHelperPROS.currencyAnswerRecordType.Id);
        Id getAnsRecordType = mgr.getAnswerRecordType(Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'));
        
        //System.assertEquals(getAnsRecordType, ASI_CRM_TW_TestClassHelperPROS.currencyAnswerRecordType.Id);
        //System.assertEquals(getAnsRecordType, Global_RecordTypeCache.getRTId('ASI_CRM_Criteria_Answer__cASI_CRM_TW_Currency_Input'));
        
    }
}