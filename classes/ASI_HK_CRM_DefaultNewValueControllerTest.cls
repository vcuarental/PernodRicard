@isTest
private class ASI_HK_CRM_DefaultNewValueControllerTest {

    static map<string, id> getRecordTypeId(string object_type) {
        map<string, id> rt_map = new map<string, id>();
        for (recordType rt:[select id, DeveloperName from recordType where SobjectType = :object_type]) {
            rt_map.put(rt.DeveloperName, rt.id);            
        }
        return rt_map;
    }

    static testMethod void test_main() {
        
        ASI_HK_CRM_AccountGenerator acctGen = new ASI_HK_CRM_AccountGenerator();
        ASI_HK_CRM_CustomerProductPriceGenerator Cus_Pro_Gen = new ASI_HK_CRM_CustomerProductPriceGenerator();
        ASI_HK_CRM_SalesOrderGenerator SO_Gen = new ASI_HK_CRM_SalesOrderGenerator();
        //ASI_HK_CRM_RunningNumberGenerator SO_Run_Gen = new ASI_HK_CRM_RunningNumberGenerator();

        ASI_HK_CRM_RunningNumberGenerator.initSORunningNumber();
        ASI_HK_CRM_CustomSettingGenerator.initFieldPrefix();
        
        ASI_HK_CRM_Field_Prefix__c fpc = ASI_HK_CRM_Field_Prefix__c.getInstance('Setting1');
        /*
        String PAaccId = curPageParams.get(fpc.SalesOrderNewPAID__c);
        String PAaccName = curPageParams.get(fpc.SalesOrderNewPANameID__c);
        String DAaccId = curPageParams.get(fpc.SalesOrderNewDAID__c);
        String DAaccName = curPageParams.get(fpc.SalesOrderNewDANameID__c);
        */
        
        //Added by Wilken to prevent Mixed DML Exception
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator'];
        User DMLUser = [Select Id From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];
        User u = new User();    
        
        System.runAs(DMLUser) {
            u = new User(alias = 'test', email='userwithrole@roletest1.com', userroleid = UserInfo.getUserRoleId(),
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                            localesidkey='en_US', profileid = UserInfo.getProfileId(),timezonesidkey='America/Los_Angeles',  
                            username='userwithrole@test.int');
            insert u;
        }
        
        List<Account> accToInsert = new List<Account>();
        
        Account Outlet_PA = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT);
        accToInsert.add(Outlet_PA);

        Account Outlet_DA_Hv_Parent = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_JDE_CREDIT);
        Outlet_DA_Hv_Parent.ParentID=Outlet_PA.id;
        accToInsert.add(Outlet_DA_Hv_Parent);

        Account Cash_Acc = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_CASH);
        Cash_Acc.ownerid=u.id;
        Cash_Acc.ASI_KOR_Customer_Code__c='HK_0000';
        accToInsert.add(Cash_Acc);
        
               
        Account Potential_Acc = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_POTENTIAL);
        Potential_Acc.ownerid=u.id;
        accToInsert.add(Potential_Acc);
        
        
        
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
        

        
        map<string, id> rt_mapAcc = getRecordTypeId('Account');
        Account Lux_First_Acc= new Account();
        Lux_First_Acc.recordTypeID = rt_mapAcc.get('ASI_Luxury_Account_HK_First_Contact');
        Lux_First_Acc.FirstName = 'testFirst';
        Lux_First_Acc.LastName = 'testLast';
        Lux_First_Acc.ASI_LUX_Gender__c = 'Male';
        Lux_First_Acc.ASI_LUX_Preferred_Contact_Number__c = '12345678';
        Lux_First_Acc.ASI_LUX_Preferred_Language_1__c = 'English';
        Lux_First_Acc.ASI_HK_CRM_Grade__c = 'D';
        Lux_First_Acc.ASI_LUX_Membership_Category__c = 'Affluent';
        Lux_First_Acc.ASI_LUX_Le_Cercle_Member__c = false;
        Lux_First_Acc.ownerid=u.id;
        
        accToInsert.add(Lux_First_Acc);
        
        Insert accToInsert;
        
        Account Potential_Acc2 = acctGen.generateAccount(ASI_HK_CRM_AccountGenerator.RT_POTENTIAL);
        Potential_Acc2.ownerid=u.id;
        Potential_Acc2.parent=Cash_Acc;
        insert Potential_Acc2;
        
        Test.startTest();
        //insert SO_Run_Num;
       
        //Test SO Insert trigger, hv parent
        ASI_HK_CRM_Sales_Order__c SO = SO_Gen.generateOnlyDASalesOrder(Outlet_DA_Hv_Parent,ASI_HK_CRM_SalesOrderGenerator.RT_Default);
        insert SO;

        ApexPages.StandardController stdSetConroller = new ApexPages.StandardController(so);
        // Initialize page and controller
        PageReference testPage = Page.ASI_HK_CRM_SalesOrderNewButtonPage;
        Map<String, String> pageParams = testPage.getParameters();
        pageParams.put('id', SO.id);
        pageParams.put(fpc.SalesOrderNewDAID__c, SO.id);
        pageParams.put(fpc.SalesOrderNewDANameID__c, SO.name);
        
        Test.setCurrentPageReference(testPage);
        ASI_HK_CRM_DefaultNewValueController testController = new ASI_HK_CRM_DefaultNewValueController(stdSetConroller);
        PageReference initRedirectPage = testController.assignDefaultAndRedirect();
       
       
       
       //Test SO Insert trigger, no parent
        ASI_HK_CRM_Sales_Order__c SO2 = SO_Gen.generateOnlyDASalesOrder(Outlet_PA,ASI_HK_CRM_SalesOrderGenerator.RT_Default);
        insert SO2;
       
        stdSetConroller = new ApexPages.StandardController(SO2);
        // Initialize page and controller
        testPage = Page.ASI_HK_CRM_SalesOrderNewButtonPage;
        Map<String, String> pageParams2 = testPage.getParameters();
        pageParams2.put('id', SO2.id);
        Test.setCurrentPageReference(testPage);
        testController = new ASI_HK_CRM_DefaultNewValueController(stdSetConroller);
        initRedirectPage = testController.assignDefaultAndRedirect();
        testController.DefaultNewValue_Map(null, null, Outlet_DA_Hv_Parent.id, Outlet_DA_Hv_Parent.name);
        initRedirectPage = testController.assignDefaultAndRedirect();
        
        //Test SO Insert trigger, Lux
        ASI_HK_CRM_Sales_Order__c SO3 = SO_Gen.generateOnlyDASalesOrder(Potential_Acc,ASI_HK_CRM_SalesOrderGenerator.RT_Default);
        SO3.ASI_HK_CRM_Payment_Method__c='CASH';
        SO3.ASI_HK_CRM_Attention__c='Mr';
        insert SO3;
               
        stdSetConroller = new ApexPages.StandardController(SO3);
        // Initialize page and controller
        testPage = Page.ASI_HK_CRM_SalesOrderNewButtonPage;
        Map<String, String> pageParams3 = testPage.getParameters();
        pageParams3.put('id', SO3.id);
        Test.setCurrentPageReference(testPage);
        testController = new ASI_HK_CRM_DefaultNewValueController(stdSetConroller);
        initRedirectPage = testController.assignDefaultAndRedirect();
        testController.DefaultNewValue_Map(null, null, Potential_Acc.id, Potential_Acc.name);
        initRedirectPage = testController.assignDefaultAndRedirect();


        // Validate other things and execute other methods
        Test.stopTest();


       
    }
}