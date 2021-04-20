/*********************************************************************************
 * Name:ASI_LUX_CalculateScoreTrigger_Test
 * Description: Test Class covering Segmentation and Score Calculation Automation for Object
 *              Account, Campaign Members and Sales Order History                
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 15/10/2014       Laputa: Conrad          Created
 * 31/10/2014       Laputa: Conrad          Added coverage for the Campaign member delete trigger
*********************************************************************************/

@isTest
public class ASI_LUX_CalculateScoreTrigger_Test {

    public static testMethod void soHistory_TriggerTest () {
        
        createSetupItems();
        Account acc = createAcc(Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_HK_Second_Contact'));
        ASI_HK_CRM_Sales_Order_History__c soHistory = createsoHistory(
                                                                        acc, 
                                                                        Global_RecordTypeCache.getRtId('ASI_HK_CRM_Sales_Order_History__cASI_HK_CRM_Sales_Order_History'),
                                                                        100000
                                                                     );
        soHistory.ASI_HK_CRM_Total_Amount__c = 300000;
        update soHistory;
        delete soHistory;
    }
    
    public static testMethod void account_TriggerTest () {
        
        createSetupItems();
        Account acc = createAcc(Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_HK_Second_Contact'));
        acc.ASI_LUX_Recognized_within_their_industry__c = '3 Medium';
        acc.ASI_LUX_Has_media_interest__c = '3 Medium';
        acc.ASI_LUX_Well_conn_within_social_circle__c = '3 Medium';
        update acc;
        acc.ASI_LUX_Recognized_within_their_industry__c = null;
        acc.ASI_LUX_Has_media_interest__c = '5 High';
        acc.ASI_LUX_Well_conn_within_social_circle__c = '5 High';
        update acc;
        acc.ASI_LUX_Recognized_within_their_industry__c = '3 Medium';
        acc.ASI_LUX_Has_media_interest__c = null;
        acc.ASI_LUX_Well_conn_within_social_circle__c = '1 Low';
        update acc;
    }
    
    @isTest
    public static void Campaign_TriggerTest () {
    
        createSetupItems();
        Account acc = createAcc(Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_JP'));
        Contact ctnt = [SELECT ID FROM Contact WHERE accountID = : acc.id LIMIT 1];
        Campaign cmp = create_Campaign(Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign'), 20000);
        /*CampaignMember cmpMember = create_CampaignMember(
                                                            cmp, 
                                                            ctnt.ID, 
                                                            Global_RecordTypeCache.getRtId('CampaignMemberASI_LUX_HK_Campaign_Member'),
                                                            'Registerd'
                                                        );*/
        
        create_CampaignMemberStatus(cmp);
                                                       
        CampaignMember cmpMember2 = create_CampaignMember(
                                                            cmp, 
                                                            ctnt.ID, 
                                                            Global_RecordTypeCache.getRtId('CampaignMemberASI_LUX_HK_Campaign_Member'),
                                                            'Attended'
                                                        );
                       
        Test.startTest();                                      
        cmpMember2.status = 'Attended';
        update cmpMember2;
        System.assert(cmpMember2.status == 'Attended');
        cmp.status = 'Completed';
        update cmp;
        
        List<ASI_LUX_Campaign_Contribution__c> cmpContributionList = [SELECT ID, Name, ASI_LUX_Contribution_Amount__c FROM ASI_LUX_Campaign_Contribution__c];
        
        update cmpContributionList;
        
        Test.StopTest();
        delete cmpContributionList;
    }
    
    @isTest
    public static void Campaign_TriggerDeleteTest () {
    
        createSetupItems();
        Account acc = createAcc(Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_JP'));
        Contact ctnt = [SELECT ID FROM Contact WHERE accountID = : acc.id LIMIT 1];
        //Campaign cmp = create_Campaign(Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign'), 20000);
        /*CampaignMember cmpMember = create_CampaignMember(
                                                            cmp, 
                                                            ctnt.ID, 
                                                            Global_RecordTypeCache.getRtId('CampaignMemberASI_LUX_HK_Campaign_Member'),
                                                            'Registerd'
                                                        );*/
        Campaign cmp = new Campaign (
            
            name = 'test Campaign Name',
            ASI_LUX_Fixed_Amount__c = 20000,
            StartDate = date.today().addMonths(-2), 
            endDate = date.today().addMonths(-1),
            recordtypeID = Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign'),
            CampaignMemberRecordTypeId = Global_RecordTypeCache.getRtId('CampaignMemberASI_LUX_Regional_Campaign_Member'),
            status = 'Planned'
        );
        insert cmp;
        create_CampaignMemberStatus(cmp);
                                                       
        CampaignMember cmpMember2 = create_CampaignMember(
                                                            cmp, 
                                                            ctnt.ID, 
                                                            Global_RecordTypeCache.getRtId('CampaignMemberASI_LUX_HK_Campaign_Member'),
                                                            'Attended'
                                                        );
        
        ASI_LUX_Campaign_Contribution__c cmpContributionTest = new ASI_LUX_Campaign_Contribution__c(
                                                                    ASI_LUX_Account__c = acc.id,
                                                                    ASI_LUX_Luxury_Campaign_Lookup__c = cmp.id,
                                                                    ASI_LUX_Contribution_Amount__c = 100,
                                                                    recordtypeid = Global_RecordTypeCache.getRtId('ASI_LUX_Campaign_Contribution__cASI_LUX_JP_Campaign_Contribution')
                                                                );
        
        
        Test.startTest();                
        insert cmpContributionTest;
        update cmpContributionTest;
        delete cmpContributionTest;                  
        delete cmpMember2;
        delete cmp;
        Test.StopTest();
    }
    
    @isTest
    public static void Campaign_SchedulerTest () {
    
        createSetupItems();
        Account acc = createAcc(Global_RecordTypeCache.getRtId('AccountASI_Luxury_Account_JP'));
        Contact ctnt = [SELECT ID FROM Contact WHERE accountID = : acc.id LIMIT 1];
        Campaign cmp = create_Campaign(Global_RecordTypeCache.getRtId('CampaignASI_LUX_JP_Campaign'), 20000);
        
        create_CampaignMemberStatus(cmp);
        Test.startTest();
        
        String jobId = System.schedule('testScheduledApex',
        ASI_LUX_JP_CalculateExp_Scheduler.CRON_EXP, 
        new ASI_LUX_JP_CalculateExp_Scheduler());
        
        Test.StopTest();
    
    }

    /*********************************************************************************
     * Description: Create the generic LUX Campaign Member Status
     *
     * Parameters:    Campaign
     *
     * Return: VOID
    *********************************************************************************/
    public static void create_CampaignMemberStatus (Campaign cmp){
    
        CampaignMemberStatus cmpMemberStatus = new CampaignMemberStatus
        (
            campaignID = cmp.id,
            Label = 'Attended',
            SortOrder = 100
        );
        
        insert cmpMemberStatus;
    
    }
    
    /*********************************************************************************
     * Description: Create the generic LUX Campaign Member
     *
     * Parameters:    Campaign
     *                ID
     *                ID
     *                String
     *
     * Return: CampaignMember
    *********************************************************************************/
    public static CampaignMember create_CampaignMember (Campaign cmp, ID ctntID, ID recordtypeID, String Status){
        
        CampaignMember cmpMember = new CampaignMember 
        (
            Contactid = ctntID,
            Campaignid = cmp.id,
            Status = status
        );
        
        insert cmpMember;
        system.debug('recordtypeID : ' + cmpMember.RecordTypeId);
        return cmpMember;
    }
    
    /*********************************************************************************
     * Description: Create the generic LUX Campaign
     *
     * Parameters:    ID
     *                Decimal
     *
     * Return: Campaign
    *********************************************************************************/
    public static Campaign create_Campaign (ID recordtypeID, Decimal fixedamount){
        Campaign cmp = new Campaign (
            
            name = 'test Campaign Name',
            ASI_LUX_Fixed_Amount__c = fixedAmount,
            StartDate = date.today().addMonths(-2), 
            endDate = date.today().addMonths(-1),
            recordtypeID = recordtypeID,
            status = 'Planned'
        );
        
        insert cmp;
        
        return cmp;
    }
    
    /*********************************************************************************
     * Description: Create the generic LUX Account
     *
     * Parameters:    Account
     *                ID
     *                Decimal
     *
     * Return: ASI_HK_CRM_Sales_Order_History__c
    *********************************************************************************/
    public static ASI_HK_CRM_Sales_Order_History__c createsoHistory (Account acc, ID recordtypeID, Decimal amount){
    
        ASI_HK_CRM_Sales_Order_History__c testsoHist = new ASI_HK_CRM_Sales_Order_History__c();
        testsoHist.recordtypeID = recordtypeID;
        testsoHist.ASI_HK_CRM_Account_PA__c = acc.id;
        testsoHist.ASI_HK_CRM_Total_Amount__c = amount;
        testsoHist.ASI_HK_CRM_Order_Date__c = date.today();
        
        insert testsoHist;
        return testsoHist;
    }
    
    /*********************************************************************************
     * Description: Create the generic LUX Account
     *
     * Parameters:  ID
     *
     * Return: Account
    *********************************************************************************/
    public static Account createAcc (ID recordtypeID){
    
        Account testAcc = new Account();
        testAcc.recordTypeID = recordtypeID;
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
        testAcc.ASI_LUX_Recognized_within_their_industry__c = '1 Low';
        testAcc.Salutation = 'Mr.';

        insert testAcc;
        return testAcc;
    }
    
    /*********************************************************************************
     * Description: Create the generic setup data such as Running numbers
     *
     * Parameters:  NONE
     *
     * Return: VOID
    *********************************************************************************/
    public static void createSetupItems (){
    
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
        
        
        ASI_HK_CRM_Running_Number__c runnNumTest4 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest4.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest4.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num';
        testRunningNumList.add(runnNumTest4);
        
        ASI_HK_CRM_Running_Number__c runnNumTest5 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest5.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest5.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_HK';
        testRunningNumList.add(runnNumTest5);
        
        ASI_HK_CRM_Running_Number__c runnNumTest6 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest6.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 7;
        runnNumTest6.ASI_HK_CRM_Object_Name__c = 'ASI_LUX_Le_Cercle_Membership_Num_JP';
        testRunningNumList.add(runnNumTest6);
        
        ASI_HK_CRM_Running_Number__c runnNumTest7 = new ASI_HK_CRM_Running_Number__c();
        runnNumTest7.ASI_HK_CRM_First_Month_of_Fiscal_Year__c = 2;
        runnNumTest7.ASI_HK_CRM_Object_Name__c = 'ASI_Luxury_Account_JP';
        testRunningNumList.add(runnNumTest7);
        
        Insert testRunningNumList;
        
        ASI_LUX_FX_Conversion_Rate__c conversionRate = new ASI_LUX_FX_Conversion_Rate__c();
        conversionRate.Name = 'JPY';
        conversionRate.ASI_LUX_Local_Currency_To_EUR__c = 0.0094687;
        Insert conversionRate;

    }

}