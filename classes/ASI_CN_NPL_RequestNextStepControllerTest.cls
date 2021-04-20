@isTest
private class ASI_CN_NPL_RequestNextStepControllerTest {
    private static Boolean isDataCreated = false;
    private static ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c();
    
    static testMethod void testClassA_ProceedNextStep(){     
        
        initDataClassA();
        PageReference pageRef = Page.ASI_CN_NPL_RequestNextStep;
        Test.setCurrentPage(pageRef);
                
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
                
        proceedCon.proceedToNextStep();
        
        //Test for Step 3.2 Class A P&L
        System.debug('Start Test for Step 3.2 Class A P&L: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        //npl.RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Step_3_2_ClassA');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Profit and Loss';
        //update npl;
        
        ApexPages.StandardController stdCon2 = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon2 = new ASI_CN_NPL_RequestNextStepController(stdCon2);
        proceedCon2.proceedToNextStep();
        System.debug('End Test for Step 3.2 Class A P&L: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        
        Test.startTest();
        
        //Test for Step 3.3 Class A Proposed Price
        System.debug('Start Test for Step 3.3 Class A Proposed Price: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        //npl.RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Step_3_3_ClassA');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Final Proposed Selling Price';
        //update npl;
        
        ApexPages.StandardController stdCon3 = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon3 = new ASI_CN_NPL_RequestNextStepController(stdCon3);
        proceedCon3.proceedToNextStep();
        System.debug('End Test for Step 3.3 Class A Proposed Price: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        
        //Test for Step 4 Launch Plan
        System.debug('Start Test for Step 4 Launch Plan: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        //npl.RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_LaunchPlan');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Launch Plan';
        //update npl;
        
        ApexPages.StandardController stdCon4 = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon4 = new ASI_CN_NPL_RequestNextStepController(stdCon4);
        proceedCon4.proceedToNextStep();
        System.debug('End Test for Step 4 Launch Plan: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        
        //Test for Step 5 Class A Vol Est
        System.debug('Start Test for Step 5 Class A Vol Est: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        //npl.RecordTypeId = getRecordTypeIDByName('Step_5_Cass_A_Vol_Est');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Vol Estimation';
        //update npl;
        
        ApexPages.StandardController stdCon5 = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon5 = new ASI_CN_NPL_RequestNextStepController(stdCon5);
        proceedCon5.proceedToNextStep();
        
        ASI_CN_NPL_NPL_Forecast__c f = new ASI_CN_NPL_NPL_Forecast__c(New_Product_Launch_Request__c = npl.id, ASI_CN_NPL_Region__c = 'South', ASI_CN_NPL_Type__c = 'Sales Volume', ASI_CN_NPL_M1__c = 100);
        insert f;
        ApexPages.StandardController stdCon6 = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon6 = new ASI_CN_NPL_RequestNextStepController(stdCon6);
        proceedCon6.proceedToNextStep();
        
        System.debug('End Test for Step 5 Class A Vol Est: ' + npl.ASI_CN_NPL_Status__c + ' ' + npl.RecordTypeId);
        
        //Test goBack
        proceedCon5.goBack();
        
        Test.stopTest();
    }   
    
    static testMethod void testClassBPart1_ProceedNextStep(){
        initDataClassB();
        PageReference pageRef = Page.ASI_CN_NPL_RequestNextStep;
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_RequestNextStepController proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();
        
        //Test for Step 3.1 Class B Price Scenario
        //npl.RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Step_3_1_ClassB');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Price Scenario';
        System.debug('Current NPL Record Type Name: ' + npl.RecordType.Name);
        //update npl;
        stdCon = new ApexPages.StandardController(npl);
        proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();
        
        Test.startTest();
        
        //Test Step 3.1 negative case
        npl.ASI_CN_NPL_Comparable_PR_Product__c = null;
        update npl;
        stdCon = new ApexPages.StandardController(npl);
        proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();
        
        //Test.startTest();
        
        //Test for Step 3.2 Class B P&L
        //npl.RecordTypeId = getRecordTypeIDByName('Step_3_2_ClassB');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Profit and Loss';
        System.debug('Current NPL Record Type Name: ' + npl.RecordType.Name);
        //update npl;
        stdCon = new ApexPages.StandardController(npl);
        proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();

        //Test for Step 3.3 Class B Proposed Price
        //npl.RecordTypeId = getRecordTypeIDByName('Step_3_3_ClassB');
        //npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Final Proposed Selling Price';
        System.debug('Current NPL Record Type Name: ' + npl.RecordType.Name);
        //update npl;
        stdCon = new ApexPages.StandardController(npl);
        proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();

        Test.stopTest();
    }

    static testMethod void testClassBPart2nC_ProceedNextStep(){            
        initDataClassB();
        PageReference pageRef = Page.ASI_CN_NPL_RequestNextStep;
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        
        Test.setCurrentPage(pageRef);
        
        //Test for Step 5 Class B Vol Est
        npl.RecordTypeId = getRecordTypeIDByName('Step_5_Class_B_Vol_Est');
        npl.ASI_CN_NPL_Status__c = 'Waiting to Fill in Vol Estimation';
        System.debug('Current NPL Record Type Name: ' + npl.RecordType.Name);
        update npl;
        stdCon = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        
        proceedCon.proceedToNextStep();
        
        Test.startTest();
        
        ASI_CN_NPL_NPL_Forecast__c f = new ASI_CN_NPL_NPL_Forecast__c(New_Product_Launch_Request__c = npl.id, ASI_CN_NPL_Region__c = 'South', ASI_CN_NPL_Type__c = 'Sales Volume', ASI_CN_NPL_M1__c = 100);
        insert f;
        stdCon = new ApexPages.StandardController(npl);
        proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();
        
        //Negative Test Test for Class C
        npl.RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Class_C');
        npl.ASI_CN_NPL_Status__c = 'Open';
        npl.ASI_CN_NPL_Classification_Text__c = 'Class C';
        update npl;
        stdCon = new ApexPages.StandardController(npl);
        proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        proceedCon.proceedToNextStep();
        
        Test.stopTest();
    }    
    
    static testMethod void testClassForStatusAndRT() {
        initDataClassA();
        PageReference pageRef = Page.ASI_CN_NPL_RequestNextStep;
        Test.setCurrentPage(pageRef);
                
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        ASI_CN_NPL_RequestNextStepController proceedCon = new ASI_CN_NPL_RequestNextStepController(stdCon);
        
        Test.startTest();

        //record type
        Id idTmpRT = null;
        idTmpRT = proceedCon.getNextRecordTypeID('Class A', 'ASI_CN_NPL_Step_3_1_ClassA');
        idTmpRT = proceedCon.getNextRecordTypeID('Class A', 'ASI_CN_NPL_Step_3_2_ClassA');
        idTmpRT = proceedCon.getNextRecordTypeID('Class A', 'ASI_CN_NPL_Step_3_3_ClassA');
        idTmpRT = proceedCon.getNextRecordTypeID('Class A', 'ASI_CN_NPL_LaunchPlan');
        idTmpRT = proceedCon.getNextRecordTypeID('Class A', 'Step_5_Cass_A_Vol_Est');
        
        idTmpRT = proceedCon.getNextRecordTypeID('Class B', 'ASI_CN_NPL_Class_B');
        idTmpRT = proceedCon.getNextRecordTypeID('Class B', 'ASI_CN_NPL_Step_3_1_ClassB');
        idTmpRT = proceedCon.getNextRecordTypeID('Class B', 'Step_3_2_ClassB');
        idTmpRT = proceedCon.getNextRecordTypeID('Class B', 'Step_3_3_ClassB');
        idTmpRT = proceedCon.getNextRecordTypeID('Class B', 'Step_5_Class_B_Vol_Est');
        
        idTmpRT = proceedCon.getNextRecordTypeID('Class C', 'ASI_CN_NPL_Step_5_Class_B_Vol_Est');
        
        idTmpRT = proceedCon.getNextRecordTypeID('Class D', 'ASI_CN_NPL_Class_D');
        idTmpRT = proceedCon.getNextRecordTypeID('Class D', 'ASI_CN_NPL_Step_3_1_Light');
        idTmpRT = proceedCon.getNextRecordTypeID('Class D', 'ASI_CN_NPL_Step_3_2_Light');
        idTmpRT = proceedCon.getNextRecordTypeID('Class D', 'ASI_CN_NPL_Step_3_3_Light');
        idTmpRT = proceedCon.getNextRecordTypeID('Class D', 'ASI_CN_NPL_LaunchPlan');
        idTmpRT = proceedCon.getNextRecordTypeID('Class D', 'ASI_CN_NPL_Step_5_Class_D');
        
        idTmpRT = proceedCon.getNextRecordTypeID('Class E', 'ASI_CN_NPL_Class_E');
        idTmpRT = proceedCon.getNextRecordTypeID('Class E', 'ASI_CN_NPL_Step_3_1_Light');
        idTmpRT = proceedCon.getNextRecordTypeID('Class E', 'ASI_CN_NPL_Step_3_2_Light');
        idTmpRT = proceedCon.getNextRecordTypeID('Class E', 'ASI_CN_NPL_Step_3_3_Light');
        idTmpRT = proceedCon.getNextRecordTypeID('Class E', 'ASI_CN_NPL_LaunchPlan');
        idTmpRT = proceedCon.getNextRecordTypeID('Class E', 'ASI_CN_NPL_Step_5_Light');

        //status
        string sTmpStatus = null;
        sTmpStatus = proceedCon.getNextStatus('Class A', 'Pre-Approved');
        sTmpStatus = proceedCon.getNextStatus('Class A', 'Waiting to Fill in Profit and Loss');
        sTmpStatus = proceedCon.getNextStatus('Class A', 'Waiting to Fill in Final Proposed Selling Price');
        sTmpStatus = proceedCon.getNextStatus('Class A', 'Waiting to Fill in Launch Plan');
        sTmpStatus = proceedCon.getNextStatus('Class A', 'Waiting to Fill in Vol Estimation');
        
        sTmpStatus = proceedCon.getNextStatus('Class B', 'Pre-Approved');
        sTmpStatus = proceedCon.getNextStatus('Class B', 'Waiting to Fill in Profit and Loss');
        sTmpStatus = proceedCon.getNextStatus('Class B', 'Waiting to Fill in Final Proposed Selling Price');
        sTmpStatus = proceedCon.getNextStatus('Class B', 'Waiting to Fill in Vol Estimation');
        
        sTmpStatus = proceedCon.getNextStatus('Class C', 'Pre-Approved');
        
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Open');
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Pre-Approved');
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Waiting to Fill in Price Scenario');
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Waiting to Fill in Profit and Loss');
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Waiting to Fill in Final Proposed Selling Price');
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Waiting to Fill in Launch Plan');
        sTmpStatus = proceedCon.getNextStatus('Class D', 'Waiting to Fill in Vol Estimation');
        
        Test.stopTest();
    }
    
    static void initDataClassA(){
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
                }
            } 
               
        npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Step_3_1_ClassA'), ASI_CN_NPL_Classification_Text__c = 'Class A', ASI_CN_NPL_Status__c = 'Pre-Approved', ownerID = u2.id, ASI_CN_NPL_Comparable_PR_Product__c = 'ABC', ASI_CN_NPL_Profit_Loss__c ='ABC', ASI_CN_NPL_Final_Proposed_Selling_Price__c  = 123);
        
        insert npl;
        
        System.debug('NPL Id: ' + npl.Id);
    }
    
    static void initDataClassB(){
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
					
					list<user> list_u = new list<user>();
					for(integer i=0; i<=20; i++){
						list_u.add(new User(Username = 'NPLuser@user.com'+i, email = 'user@user.com'+i, profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', UserRoleID = ownerRole.id));
					}
					insert list_u;
                        
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
                }
            } 
               
        npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Step_3_1_ClassB'), ASI_CN_NPL_Classification_Text__c = 'Class B', ASI_CN_NPL_Status__c = 'Pre-Approved', ownerID = u2.id, ASI_CN_NPL_Comparable_PR_Product__c = 'ABC', ASI_CN_NPL_Profit_Loss__c ='ABC', ASI_CN_NPL_Final_Proposed_Selling_Price__c  = 123);
        
        insert npl;
        
        System.debug('NPL Id: ' + npl.Id);
    }
    
    static ID getRecordTypeIDByName(string RTName){
    
        return Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__c' + RTName);
        //Id recordTypeID = [Select Id From RecordType Where SobjectType = 'ASI_CN_NPL_NPL_Request__c' And Name = :RTName LIMIT 1].Id;
        //return recordTypeID;
    }
}