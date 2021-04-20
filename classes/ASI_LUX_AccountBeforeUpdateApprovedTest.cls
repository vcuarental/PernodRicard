@isTest
public class  ASI_LUX_AccountBeforeUpdateApprovedTest {

    public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }
    
    public static testMethod void mainTest () 
    {
        Test.startTest();
        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        
        Insert testAcc;
        
        Test.StopTest();
        
        testAcc.ASI_LUX_LeCercle_Member_Appl_Status__c = 'Approved';
        
        update testAcc;
        
    }

   public static testMethod void mainTestTW () 
    {
        Test.startTest();
        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_TW';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_TW';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_TW_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        
        Insert testAcc;
        
        Test.StopTest();
        
        testAcc.ASI_LUX_LeCercle_Member_Appl_Status__c = 'Approved';
        
        update testAcc;
        
    }

   public static testMethod void mainTestMY () 
    {
        Test.startTest();
        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_MY';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_MY';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_MY_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        
        Insert testAcc;
        
        Test.StopTest();
        
        testAcc.ASI_LUX_LeCercle_Member_Appl_Status__c = 'Approved';
        
        update testAcc;
        
    }
    
   public static testMethod void mainTestReg () 
    {
        Test.startTest();
        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_Regional';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_Regional';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_Regional_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        
        Insert testAcc;
        
        Test.StopTest();
        
        testAcc.ASI_LUX_LeCercle_Member_Appl_Status__c = 'Approved';
        
        update testAcc;
        
    }
    
   public static testMethod void mainTestJP () 
    {
        Test.startTest();
        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Running_Number__c = 2315;
        runnNumTest.ASI_HK_CRM_Format__c = 'SO-{YY}{000000}';
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_JP';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_JP';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_JP');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = false;
        testAcc.Salutation = 'Mr.';
        
        Insert testAcc;
        
        Test.StopTest();
        
        testAcc.ASI_LUX_LeCercle_Member_Appl_Status__c = 'Approved';
        
        update testAcc;
        
    }

}