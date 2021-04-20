@isTest
public class ASI_LUX_AccountCalcScoreControllerTest {

    public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }
    
    public static testMethod void TaiwanTest ()
    {
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_TW';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_TW';
        testRunningNumList.add(runnNumTest2);
        
        ASI_HK_CRM_Running_Number__c runnNumTest3 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest3.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest3.ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c';
        testRunningNumList.add(runnNumTest3);
        
        Insert testRunningNumList;
        
        ASI_LUX_FX_Conversion_Rate__c conversionRate = new ASI_LUX_FX_Conversion_Rate__c();
        conversionRate.Name = 'TWD';
        conversionRate.ASI_LUX_Local_Currency_To_EUR__c = 0.094687;
        Insert conversionRate;
        
        List<Account> testAccountInsert = new List<Account>();
        List<ASI_HK_CRM_Sales_Order_History__c> testsoHistInsert = new List<ASI_HK_CRM_Sales_Order_History__c>();
        Date todayIndeductYr = date.today();
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_TW_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc.ASI_LUX_Le_Cercle_Member_Number__c = '13012268';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '1 Low';
        testAcc.ASI_LUX_Has_media_interest__c = '1 Low';
        testAccountInsert.add(testAcc);
        insert testAccountInsert;
        //SCORE ACC1
        ApexPages.StandardController sc = new ApexPages.standardController(testAcc);
        PageReference pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc.Id);
        Test.setCurrentPageReference(pageRefScore);
        ASI_LUX_AccountCalcScoreController testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
    }
    
    public static testMethod void nullTest ()
    {
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        ASI_HK_CRM_Running_Number__c runnNumTest3 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest3.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest3.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_Regional';
        testRunningNumList.add(runnNumTest3);
        
        ASI_HK_CRM_Running_Number__c runnNumTest4 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest4.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest4.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Regional_Customer_Num';
        testRunningNumList.add(runnNumTest4);
        
        Insert testRunningNumList;
        
        List<Account> testAccountInsert = new List<Account>();
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc.ASI_LUX_Le_Cercle_Member_Number__c = '13012268';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '1 Low';
        testAcc.ASI_LUX_Has_media_interest__c = '1 Low';
        testAccountInsert.add(testAcc);
        
        Account testAcc2 = new Account();
        testAcc2.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc2.FirstName = 'testFirst1';
        testAcc2.LastName = 'testLast1';
        testAcc2.ASI_LUX_Gender__c = 'Male';
        testAcc2.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc2.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc2.ASI_HK_CRM_Grade__c = 'D';
        testAcc2.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc2.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc2.ASI_LUX_Le_Cercle_Member_Number__c = '13012269';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '3 Medium';
        testAcc.ASI_LUX_Has_media_interest__c = '3 Medium';
        testAccountInsert.add(testAcc2);
        
        Account testAcc3 = new Account();
        testAcc3.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc3.FirstName = 'testFirst2';
        testAcc3.LastName = 'testLast2';
        testAcc3.ASI_LUX_Gender__c = 'Male';
        testAcc3.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc3.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc3.ASI_HK_CRM_Grade__c = 'D';
        testAcc3.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc3.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc3.ASI_LUX_Le_Cercle_Member_Number__c = '13012270';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '5 High';
        testAcc.ASI_LUX_Has_media_interest__c = '5 High';
        testAccountInsert.add(testAcc3);
        
        Account testAcc4 = new Account();
        testAcc4.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc4.FirstName = 'testFirst3';
        testAcc4.LastName = 'testLast3';
        testAcc4.ASI_LUX_Gender__c = 'Male';
        testAcc4.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc4.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc4.ASI_HK_CRM_Grade__c = 'D';
        testAcc4.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc4.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc4.ASI_LUX_Le_Cercle_Member_Number__c = '13012271';
        testAccountInsert.add(testAcc4);

        Account testAcc5 = new Account(
        recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Potential'),
        FirstName = 'testFirst3',
        LastName = 'testLast3',
        ASI_LUX_Gender__c = 'Male',
        ASI_LUX_Preferred_Contact_Number__c = '12345678',
        ASI_LUX_Preferred_Language_1__c = 'English',
        ASI_HK_CRM_Grade__c = 'D',
        ASI_LUX_Membership_Category__c = 'Affluent',
        ASI_LUX_Le_Cercle_Member__c = true,
        ASI_LUX_Le_Cercle_Member_Number__c = '13012271',
        ASI_LUX_Profile__c = 'Potential');
        testAccountInsert.add(testAcc5);

        Insert testAccountInsert;
        
        testAcc5.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc5.ASI_LUX_Profile__c = 'Second Contact';
        
        update testAcc5;
        
        //SCORE ACC1
        ApexPages.StandardController sc = new ApexPages.standardController(testAcc);
        PageReference pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc.Id);
        Test.setCurrentPageReference(pageRefScore);
        ASI_LUX_AccountCalcScoreController testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
    }
    
    public static testMethod void mainTest () 
    {
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        ASI_HK_CRM_Running_Number__c runnNumTest3 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest3.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest3.ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c';
        testRunningNumList.add(runnNumTest3);
        
        Insert testRunningNumList;
        
        ASI_LUX_FX_Conversion_Rate__c conversionRate = new ASI_LUX_FX_Conversion_Rate__c();
        conversionRate.Name = 'HKD';
        conversionRate.ASI_LUX_Local_Currency_To_EUR__c = 0.094687;
        Insert conversionRate;
        
        List<Account> testAccountInsert = new List<Account>();
        List<ASI_HK_CRM_Sales_Order_History__c> testsoHistInsert = new List<ASI_HK_CRM_Sales_Order_History__c>();
        Date todayIndeductYr = date.today();
        
        Account testAcc = new Account();
        testAcc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc.FirstName = 'testFirst';
        testAcc.LastName = 'testLast';
        testAcc.ASI_LUX_Gender__c = 'Male';
        testAcc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc.ASI_HK_CRM_Grade__c = 'D';
        testAcc.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc.ASI_LUX_Le_Cercle_Member_Number__c = '13012268';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '1 Low';
        testAcc.ASI_LUX_Has_media_interest__c = '1 Low';
        testAccountInsert.add(testAcc);
        
        Account testAcc2 = new Account();
        testAcc2.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc2.FirstName = 'testFirst1';
        testAcc2.LastName = 'testLast1';
        testAcc2.ASI_LUX_Gender__c = 'Male';
        testAcc2.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc2.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc2.ASI_HK_CRM_Grade__c = 'D';
        testAcc2.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc2.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc2.ASI_LUX_Le_Cercle_Member_Number__c = '13012269';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '3 Medium';
        testAcc.ASI_LUX_Has_media_interest__c = '3 Medium';
        testAccountInsert.add(testAcc2);
        
        Account testAcc3 = new Account();
        testAcc3.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc3.FirstName = 'testFirst2';
        testAcc3.LastName = 'testLast2';
        testAcc3.ASI_LUX_Gender__c = 'Male';
        testAcc3.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc3.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc3.ASI_HK_CRM_Grade__c = 'D';
        testAcc3.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc3.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc3.ASI_LUX_Le_Cercle_Member_Number__c = '13012270';
        testAcc.ASI_LUX_Well_conn_within_social_circle__c = '5 High';
        testAcc.ASI_LUX_Has_media_interest__c = '5 High';
        testAccountInsert.add(testAcc3);
        
        Account testAcc4 = new Account();
        testAcc4.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact');
        testAcc4.FirstName = 'testFirst3';
        testAcc4.LastName = 'testLast3';
        testAcc4.ASI_LUX_Gender__c = 'Male';
        testAcc4.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        testAcc4.ASI_LUX_Preferred_Language_1__c = 'English';
        testAcc4.ASI_HK_CRM_Grade__c = 'D';
        testAcc4.ASI_LUX_Membership_Category__c = 'Affluent';
        testAcc4.ASI_LUX_Le_Cercle_Member__c = true;
        testAcc4.ASI_LUX_Le_Cercle_Member_Number__c = '13012271';
        testAccountInsert.add(testAcc4);

        Account testAcc5 = new Account(
        recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact'),
        FirstName = 'testFirst3',
        LastName = 'testLast3',
        ASI_LUX_Gender__c = 'Male',
        ASI_LUX_Preferred_Contact_Number__c = '12345678',
        ASI_LUX_Preferred_Language_1__c = 'English',
        ASI_HK_CRM_Grade__c = 'D',
        ASI_LUX_Membership_Category__c = 'Affluent',
        ASI_LUX_Le_Cercle_Member__c = true,
        ASI_LUX_Le_Cercle_Member_Number__c = '13012271');
        testAccountInsert.add(testAcc5);
        
        Account testAcc6 = new Account(
        recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_Second_Contact'),
        FirstName = 'testFirst3',
        LastName = 'testLast3',
        ASI_LUX_Gender__c = 'Male',
        ASI_LUX_Preferred_Contact_Number__c = '12345678',
        ASI_LUX_Preferred_Language_1__c = 'English',
        ASI_HK_CRM_Grade__c = 'D',
        ASI_LUX_Membership_Category__c = 'Affluent',
        ASI_LUX_Le_Cercle_Member__c = true,
        ASI_LUX_Le_Cercle_Member_Number__c = '13012271');
        testAccountInsert.add(testAcc6);

        Insert testAccountInsert;

        //TESTACC
        ASI_HK_CRM_Sales_Order_History__c testsoHist = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist.ASI_HK_CRM_Account_PA__c = testAcc.id;
        testsoHist.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHistInsert.add(testsoHist);
        
        //TESTACC3
        ASI_HK_CRM_Sales_Order_History__c testsoHist2 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist2.ASI_HK_CRM_Account_PA__c = testAcc3.id;
        testsoHist2.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist2.ASI_HK_CRM_Total_Amount__c = 15346;
        testsoHistInsert.add(testsoHist2);

        //TESTACC3
        ASI_HK_CRM_Sales_Order_History__c testsoHist3 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist3.ASI_HK_CRM_Account_PA__c = testAcc3.id;
        testsoHist3.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist3.ASI_HK_CRM_Total_Amount__c = 15346;
        testsoHistInsert.add(testsoHist3);
        
        //TESTACC4
        ASI_HK_CRM_Sales_Order_History__c testsoHist4 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist4.ASI_HK_CRM_Account_PA__c = testAcc4.id;
        testsoHist4.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist4.ASI_HK_CRM_Total_Amount__c = 60000;
        testsoHistInsert.add(testsoHist4);
        
        //TESTACC4
        ASI_HK_CRM_Sales_Order_History__c testsoHist5 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist5.ASI_HK_CRM_Account_PA__c = testAcc4.id;
        testsoHist5.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist5.ASI_HK_CRM_Total_Amount__c = 60000;
        testsoHistInsert.add(testsoHist5);
        
        //TESTACC4
        ASI_HK_CRM_Sales_Order_History__c testsoHist6 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist6.ASI_HK_CRM_Account_PA__c = testAcc4.id;
        testsoHist6.ASI_HK_CRM_Total_Amount__c = 60000;
        testsoHistInsert.add(testsoHist6);
        
        //TESTACC4
        ASI_HK_CRM_Sales_Order_History__c testsoHist7 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist7.ASI_HK_CRM_Account_PA__c = testAcc4.id;
        testsoHist7.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist7.ASI_HK_CRM_Total_Amount__c = 60000;
        testsoHistInsert.add(testsoHist7);
        
        //TESTACC4
        ASI_HK_CRM_Sales_Order_History__c testsoHist8 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist8.ASI_HK_CRM_Account_PA__c = testAcc4.id;
        testsoHist8.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist8.ASI_HK_CRM_Total_Amount__c = 6000000;
        testsoHistInsert.add(testsoHist8);

        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist9 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist9);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist10 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist10);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist11 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist11);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist12 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist12);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist13 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist13);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist14 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist14);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist15 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist15);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist16 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist16);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist17 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist17);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist18 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist18);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist19 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist19);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist20 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist20);
        
        //TESTACC5
        ASI_HK_CRM_Sales_Order_History__c testsoHist21 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc5.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 5000);
        testsoHistInsert.add(testsoHist21);

        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist22 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist22);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist23 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist23);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist24 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist24);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist25 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist25);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist26 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist26);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist27 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist27);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist28 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist28);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist29 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist29);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist30 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist30);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist31 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist31);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist32 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist32);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist33 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist33);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist34 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist34);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist35 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist35);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist36 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist36);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist37 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist37);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist38 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist38);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist39 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist39);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist40 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist40);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist41 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist41);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist42 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist42);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist43 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist43);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist44 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist44);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist45 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist45);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist46 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist46);
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist47 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist47); 
        
        //TESTACC6
        ASI_HK_CRM_Sales_Order_History__c testsoHist48 = new ASI_HK_CRM_Sales_Order_History__c(
        ASI_HK_CRM_Account_PA__c = testAcc6.id,
        ASI_HK_CRM_Order_Date__c = todayIndeductYr,
        ASI_HK_CRM_Total_Amount__c = 3000);
        testsoHistInsert.add(testsoHist48);

        Insert testsoHistInsert;

        Test.startTest();

        //SCORE ACC1
        ApexPages.StandardController sc = new ApexPages.standardController(testAcc);
        PageReference pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc.Id);
        Test.setCurrentPageReference(pageRefScore);
        ASI_LUX_AccountCalcScoreController testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
        
        //SCORE ACC2
        sc = new ApexPages.standardController(testAcc2);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc2.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
        
        //SCORE ACC3
        sc = new ApexPages.standardController(testAcc3);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc3.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
        
        Test.StopTest();
        
        //SCORE ACC4
        sc = new ApexPages.standardController(testAcc4);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc4.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
        
        //SCORE ACC5
        sc = new ApexPages.standardController(testAcc5);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc5.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
        
        //SCORE ACC6
        sc = new ApexPages.standardController(testAcc6);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScorePage?id=' + testAcc6.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        testCON.calculateScore();
        testCON.calculateSegmentation();
        
        /*//SEGMENT ACC1
        sc = new ApexPages.standardController(testAcc);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScoreSegmentPage?id=' + testAcc.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        
        //SEGMENT ACC2
        sc = new ApexPages.standardController(testAcc2);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScoreSegmentPage?id=' + testAcc2.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        
        //SEGMENT ACC3
        sc = new ApexPages.standardController(testAcc3);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScoreSegmentPage?id=' + testAcc3.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);
        
        //SEGMENT ACC4
        sc = new ApexPages.standardController(testAcc4);
        pageRefScore = new PageReference('/apex/ASI_LUX_AccountCalcScoreSegmentPage?id=' + testAcc4.Id);
        Test.setCurrentPageReference(pageRefScore);
        testCON = new ASI_LUX_AccountCalcScoreController(sc);*/
        
        delete testAccountInsert;
    }

}