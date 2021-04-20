@isTest
private class ASI_CN_NPL_ForecastControllerTest {

    private static ASI_CN_NPL_NPL_Request__c npl;
    private static ASI_CN_NPL_NPL_Forecast__c nplForecast;
    private static ASI_CN_NPL_NPL_Forecast__c nplMonitorForecast;
    private static Boolean isDataCreated = false;

    static testMethod void testDisplayForecastData(){
        Test.startTest();

        initData();

        PageReference pageRef = Page.ASI_CN_NPL_ForecastPage;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_ForecastController forecastCon = new ASI_CN_NPL_ForecastController(stdCon);

        Test.stopTest();
    }

    static testMethod void testUpdateForecastData(){
        Test.startTest();

        initData();

        PageReference pageRef = Page.ASI_CN_NPL_ForecastPage;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_ForecastController forecastCon = new ASI_CN_NPL_ForecastController(stdCon);

        forecastCon.SalesVolForecast_South.ASI_CN_NPL_M1__c = 100;

        string nextPage = forecastCon.saveForecasts().getUrl();

        ASI_CN_NPL_NPL_Forecast__c updatedNPLForecast = [Select Id, ASI_CN_NPL_M1__c From ASI_CN_NPL_NPL_Forecast__c Where Id = :nplForecast.Id And ASI_CN_NPL_Type__c = 'Sales Volume'
            And ASI_CN_NPL_Region__c = 'South'];

        System.assertEquals(updatedNPLForecast.ASI_CN_NPL_M1__c, 100);
        Test.stopTest();
    }

    static testMethod void testUpdateForecastDataWithVol(){
        Test.startTest();
        initData();

        List<ASI_CN_NPL_NPL_Forecast__c> forecasts = [SELECT Id, ASI_CN_NPL_Type__c, ASI_CN_NPL_Region__c, ASI_CN_NPL_M6__c, ASI_CN_NPL_M5__c, ASI_CN_NPL_M4__c, ASI_CN_NPL_M3__c,
                  ASI_CN_NPL_M2__c, ASI_CN_NPL_M1__c FROM ASI_CN_NPL_NPL_Forecast__c WHERE New_Product_Launch_Request__c = :npl.Id];

        for (ASI_CN_NPL_NPL_Forecast__c f : forecasts){
            f.ASI_CN_NPL_M1__c = 100;
            f.ASI_CN_NPL_M2__c = 100;
            f.ASI_CN_NPL_M3__c = 100;
            f.ASI_CN_NPL_M4__c = 100;
            f.ASI_CN_NPL_M5__c = 100;
            f.ASI_CN_NPL_M6__c = 100;
        }

        update forecasts;

        PageReference pageRef = Page.ASI_CN_NPL_ForecastPage;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_ForecastController forecastCon = new ASI_CN_NPL_ForecastController(stdCon);

        forecastCon.SalesVolForecast_South.ASI_CN_NPL_M1__c = 100;

        string nextPage = forecastCon.saveForecasts().getUrl();

        ASI_CN_NPL_NPL_Forecast__c updatedNPLForecast = [Select Id, ASI_CN_NPL_M1__c From ASI_CN_NPL_NPL_Forecast__c Where Id = :nplForecast.Id And ASI_CN_NPL_Type__c = 'Sales Volume'
            And ASI_CN_NPL_Region__c = 'South'];

        System.assertEquals(updatedNPLForecast.ASI_CN_NPL_M1__c, 100);
        Test.stopTest();
    }

    static testMethod void testUpdateLogisticsData(){
        Test.startTest();
        initData();

        PageReference pageRef = Page.ASI_CN_NPL_LogisticsInfoPage;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_ForecastController forecastCon = new ASI_CN_NPL_ForecastController(stdCon);

        forecastCon.MonitoringForecast_South.ASI_CN_NPL_M1__c = 100;

        string nextPage = forecastCon.saveLogInformation().getUrl();

        ASI_CN_NPL_NPL_Forecast__c updatedNPLForecast = [Select Id, ASI_CN_NPL_M1__c From ASI_CN_NPL_NPL_Forecast__c Where Id = :nplMonitorForecast.Id And ASI_CN_NPL_Type__c = 'Monitoring'
            And ASI_CN_NPL_Region__c = 'South'];

        System.assertEquals(updatedNPLForecast.ASI_CN_NPL_M1__c, 100);
        Test.stopTest();
    }

    static testMethod void testCancel(){
        Test.startTest();
        initData();

        PageReference pageRef = Page.ASI_CN_NPL_ForecastPage;

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_ForecastController forecastCon = new ASI_CN_NPL_ForecastController(stdCon);

        string nextPage = forecastCon.cancel().getUrl();

        System.assertEquals('/' + npl.Id, nextPage);
        Test.stopTest();
    }

    static void initData(){
        //Prepare Public Group member
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator GDT'];
        User DMLUser = [Select Id From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];

        User u = new User(Username = 'NPLsupervisor@supervisor.com', email = 'supervisor@supervisor.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='sup', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u2 = new User(Username = 'NPLuser@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');

        System.runAs(DMLUser) {
            try {
                //Wilken 20131125, updated brand director assignment logic, Prepare Role for Owner
                UserRole supervisorRole = new UserRole(Name='Supervisor Role', DeveloperName = 'Supervisor_Role');
                insert supervisorRole;
                u.UserRoleID = supervisorRole.id;

                UserRole ownerRole = new UserRole(Name='Owner Role', DeveloperName = 'Owner_Role', ParentRoleID = supervisorRole.Id);
                insert ownerRole;
                u2.UserRoleID = ownerRole.id;

                insert u;

                insert u2;

                if (!isDataCreated){
                    List<Group> publicGroups = [Select Id From Group Where Name IN ('ASI CN NPL Marketing Director', 'ASI CN NPL Brand Director Approvers', 'ASI CN NPL Deputy Managing Director',
                    'ASI CN NPL Finance Director', 'ASI CN NPL Marketing Director', 'ASI CN NPL National Sales Dev VP', 'ASI CN NPL Trade Marketing Director')];
                    List<GroupMember> groupMembers = new List<GroupMember>();

                    for (Group g : publicGroups){
                        GroupMember groupMember = new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
                        groupMembers.add(groupMember);
                    }

                    insert groupMembers;

                    isDataCreated = true;
                }
            } catch (Exception e){
                // 20190730 Wilson Chow start
                system.debug('e:' + e.getMessage());
                // 20190730 Wilson Chow end
            }
        }

        //Prepare NPL Request Data
        Id recordTypeID = [Select Id From RecordType Where SobjectType = 'ASI_CN_NPL_NPL_Request__c' And Name = 'Class A' LIMIT 1].Id;

        npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test',
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = recordTypeID, ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment', ASI_CN_NPL_Domestic_Launch_Date__c = date.today(), ASI_CN_NPL_MM_Launch_Date__c = date.today(),
            ASI_CN_NPL_Old_Stock_Start_Date__c = date.today(), ownerID = u2.id);

        System.debug('NPL OwnerID: ' + npl.ownerID + ' u2.id: ' + u2.id + ' u2.UserRoleID: ' + u2.UserRoleID);

        insert npl;

        nplForecast = [Select Id, ASI_CN_NPL_M1__c From ASI_CN_NPL_NPL_Forecast__c Where New_Product_Launch_Request__c = :npl.Id And ASI_CN_NPL_Type__c = 'Sales Volume'
            And ASI_CN_NPL_Region__c = 'South'];

        nplMonitorForecast = [Select Id, ASI_CN_NPL_M1__c From ASI_CN_NPL_NPL_Forecast__c Where New_Product_Launch_Request__c = :npl.Id And ASI_CN_NPL_Type__c = 'Monitoring'
            And ASI_CN_NPL_Region__c = 'South'];
    }

    // 20190730 Wilson Chow start
    @testSetup
    static void testSetup() {
        Id recordTypeID = [Select Id From RecordType Where SobjectType = 'ASI_CN_NPL_NPL_Request__c' And Name = 'Class A' LIMIT 1].Id;

        ASI_CN_NPL_Item_Master__c tmpItemMaster =
                new ASI_CN_NPL_Item_Master__c(
                        ASI_CN_NPL_Item_Goup_Code__c = '20190730',
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_CN_NPL_Item_Master__cASI_CN_NPL_Item_Master_TypeA')
                );
        insert tmpItemMaster;

        ASI_MFM_Item_Group__c tmpItemGroup =
                new ASI_MFM_Item_Group__c(
                        RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group'),
                        Name = 'TestItemGroup',
                        ASI_MFM_Item_Group_Code__c = '20190730',
                        ASI_CRM_CN_Eng_Name__c = 'TestItemGroup',
                        OwnerID = UserInfo.getUserId(),
                        ASI_CRM_Allocation_Information__c = true
                );
        insert tmpItemGroup;

        Profile p = [Select Id From Profile Where Name = 'System Administrator GDT'];

        User u =
                new User(
                        Username = 'tmp_npl_supervisor@supervisor.com',
                        email = 'supervisor@supervisor.com',
                        profileID = p.Id,
                        IsActive = true,
                        LastName='Supervisor',
                        Alias='sup',
                        TimeZoneSidKey='GMT',
                        LocaleSidKey='en_US',
                        EmailEncodingKey='ISO-8859-1',
                        LanguageLocaleKey='en_US'
                );
        insert u;

        List<ASI_CN_NPL_NPL_Request__c> tmpNplList = new List<ASI_CN_NPL_NPL_Request__c>();

        ASI_CN_NPL_NPL_Request__c tmpNpl1 =
                new ASI_CN_NPL_NPL_Request__c(
                        ASI_CN_NPL_When_to_Launch__c = date.today(),
                        ASI_CN_NPL_Source_of_Volume__c = 'Test',
                        ASI_CN_NPL_Reason_to_Launch__c = 'Test',
                        ASI_CN_NPL_Product_Name_English__c = 'Test',
                        ASI_CN_NPL_Date__c = date.today(),
                        RecordTypeId = recordTypeID,
                        ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment',
                        ASI_CN_NPL_Domestic_Launch_Date__c = date.today(),
                        ASI_CN_NPL_MM_Launch_Date__c = date.today(),
                        ASI_CN_NPL_Old_Stock_Start_Date__c = date.today(),
                        ownerID = u.Id,
                        ASI_CN_NPL_Category__c = 'WINE',
                        ASI_CN_NPL_Item_Master__c = tmpItemMaster.Id
                );
        tmpNplList.add(tmpNpl1);

        ASI_CN_NPL_NPL_Request__c tmpNpl2 =
                new ASI_CN_NPL_NPL_Request__c(
                        ASI_CN_NPL_When_to_Launch__c = date.today(),
                        ASI_CN_NPL_Source_of_Volume__c = 'Test',
                        ASI_CN_NPL_Reason_to_Launch__c = 'Test',
                        ASI_CN_NPL_Product_Name_English__c = 'Test',
                        ASI_CN_NPL_Date__c = date.today(),
                        RecordTypeId = recordTypeID,
                        ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment',
                        ASI_CN_NPL_Domestic_Launch_Date__c = date.today(),
                        ASI_CN_NPL_MM_Launch_Date__c = date.today(),
                        ASI_CN_NPL_Old_Stock_Start_Date__c = date.today(),
                        ownerID = u.Id,
                        ASI_CN_NPL_Category__c = 'WINE',
                        ASI_CN_NPL_Brand_Director__c = u.Id
                );
        tmpNplList.add(tmpNpl2);

        insert tmpNplList;

        User approver = [select id,ManagerID from user where CompanyName = 'Pernod Ricard China' and ManagerID !=null limit 1];

        ASI_CRM_Fix_Approval_Route__c fixApprovalRoute =
                new ASI_CRM_Fix_Approval_Route__c(
                        ASI_CRM_CN_Region_Area_Channel__c = 'Test',
                        ASI_CRM_CN_Approver_1__c = approver.id,
                        ASI_CRM_CN_Type__c='New Product Launch - TP Approval',
                        recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')
                );
        insert fixApprovalRoute;
    }

    @isTest
    static void testAfterUpdate1() {
        system.debug('testAfterUpdate1 start');

        List<ASI_CN_NPL_NPL_Request__c> tmpNplList = [SELECT Id FROM ASI_CN_NPL_NPL_Request__c WHERE ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment'];
        ASI_CN_NPL_NPL_Request__c tmpNpl = tmpNplList.get(0);

        List<User> userList = [SELECT Id FROM User LIMIT 1];
        User u = userList.get(0);

        //20200806:AM@introv - add team start
        ASI_MFM_Team__c oTeam = new ASI_MFM_Team__c(Name = 'Wine',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Team__cASI_MFM_CN_Brand_Team'));
        insert oTeam;
		ASI_MFM_Team_Member__c oTeamMember = new ASI_MFM_Team_Member__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Team_Member__cASI_MFM_CN_Team_Member'), ASI_MFM_Team__c=oTeam.id, ASI_MFM_Team_Member__c=u.Id);
        insert oTeamMember;
        //20200806:AM@introv - add team end
        
        tmpNpl.ASI_CN_NPL_Status__c = 'Final Approved';
        tmpNpl.ASI_CN_NPL_Brand_Director__c = u.Id;
        update tmpNpl;

        system.debug('testAfterUpdate1 end');
    }

    @isTest
    static void testAfterUpdate2() {
        system.debug('testAfterUpdate2 start');

        List<ASI_CN_NPL_NPL_Request__c> tmpNplList = [SELECT Id FROM ASI_CN_NPL_NPL_Request__c WHERE ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment'];
        ASI_CN_NPL_NPL_Request__c tmpNpl = tmpNplList.get(0);

        List<User> userList = [SELECT Id FROM User LIMIT 1];
        User u = userList.get(0);

        //20200806:AM@introv - add team start
        ASI_MFM_Team__c oTeam = new ASI_MFM_Team__c(Name = 'Wine',recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Team__cASI_MFM_CN_Brand_Team'));
        insert oTeam;
		ASI_MFM_Team_Member__c oTeamMember = new ASI_MFM_Team_Member__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Team_Member__cASI_MFM_CN_Team_Member'), ASI_MFM_Team__c=oTeam.id, ASI_MFM_Team_Member__c=u.Id);
        insert oTeamMember;
        //20200806:AM@introv - add team end

        tmpNpl.ASI_CN_NPL_Status__c = 'Pre-Approved';
        tmpNpl.ASI_CN_NPL_Brand_Director__c = u.Id;
        update tmpNpl;

        system.debug('testAfterUpdate2 end');
    }
    // 20190730 Wilson Chow end
}