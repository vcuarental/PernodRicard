@istest 
class ASI_LUX_AccountCalcScoreLastYrTest {

    static testmethod void testScheduler()
    {
        Test.startTest();
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        
        List<ASI_HK_CRM_Running_Number__c> testRunningNumList = new List<ASI_HK_CRM_Running_Number__c>();
        
        ASI_HK_CRM_Running_Number__c runnNumTest = new ASI_HK_CRM_Running_Number__c();
        runnNumTest.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest.ASI_HK_CRM_Object_Name__c = 'ASI_HK_CRM_Sales_Order__c';
        testRunningNumList.add(runnNumTest);
        
        ASI_HK_CRM_Running_Number__c runnNumTest3 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest3.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest3.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest3);
        
        ASI_HK_CRM_Running_Number__c runnNumTest2 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest2.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest2.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest2);
        
        Insert testRunningNumList;
        
        ASI_LUX_FX_Conversion_Rate__c conversionRate = new ASI_LUX_FX_Conversion_Rate__c();
        conversionRate.Name = 'HKD';
        conversionRate.ASI_LUX_Local_Currency_To_EUR__c = 0.094687;
        Insert conversionRate;
        
        List<Account> testAccountInsert = new List<Account>();
        List<ASI_HK_CRM_Sales_Order_History__c> testsoHistInsert = new List<ASI_HK_CRM_Sales_Order_History__c>();
        Date todayIndeductYr = date.today().addMonths(- 12);
        
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
        testsoHist6.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist6.ASI_HK_CRM_Total_Amount__c = 60000;
        testsoHistInsert.add(testsoHist6);
        
        //TESTACC4
        ASI_HK_CRM_Sales_Order_History__c testsoHist7 = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist7.ASI_HK_CRM_Account_PA__c = testAcc4.id;
        testsoHist7.ASI_HK_CRM_Order_Date__c = todayIndeductYr;
        testsoHist7.ASI_HK_CRM_Total_Amount__c = 60000;
        testsoHistInsert.add(testsoHist7);
        
        Insert testsoHistInsert;
        
        ASI_LUX_PastFiscalYear__c customTest = new ASI_LUX_PastFiscalYear__c();
        customTest.name = 'test';
        customTest.ASI_LUX_Months_Interval__c = 12;
        customTest.ASI_LUX_Number_of_Past_Days__c = 365; 
        Insert customTest;
        
        String jobId = System.schedule('testScheduledApex',
        ASI_LUX_AccountCalcScoreLastYr.CRON_EXP, 
        new ASI_LUX_AccountCalcScoreLastYr());
        
        Test.StopTest();
        
    }
    
    public static testmethod void testSchedulerOverCapacity() {
        
        ASI_LUX_AccountCalcScoreLastYr testSchedulerCap = new ASI_LUX_AccountCalcScoreLastYr();
        
        ASI_LUX_AccountCalcScoreLastYr.runningJobCount = 5;
        
        String jobId6 = System.schedule('testScheduledApex6',
        ASI_LUX_AccountCalcScoreLastYr.CRON_EXP, 
        testSchedulerCap);
        
    }

    public static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }

}