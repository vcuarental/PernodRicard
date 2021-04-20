@isTest
/****************************************
Test Classes:
 1. ASI_CRM_MY_VisitationPlanCalendarCtl
 2. ASI_CRM_MY_VisitationPlanDetailGenerator
 3. ASI_CRM_MY_VisitationPlanDtValidator
 4. ASI_CRM_MY_VisitationPlanEditController
****************************************/
public class ASI_CRM_MY_VisitationPlan_TEST{
 
    static testMethod void VisitationPlan_TEST() {
        //User userA = ASI_CRM_MY_TestClassHelper.createUser();
        User userA = [select name, userRole.developerName from user where id = :userInfo.getUserId()];  
        userA.BypassVR__c = TRUE;
        userA.BypassTriggers__c = 'ASI_CRM_MY_ContractTrigger';
        update userA;
        
        string strName = userA.Name;
        
        Id idRTContractNormal = Global_RecordTypeCache.getRTId('ASI_TH_CRM_Contract__cASI_CRM_MY_Contract');
            
        ASI_CRM_MY_TestClassHelper.createMYSetting();
        ASI_CRM_MY_TestClassHelper.createRunningNumbers();
        ASI_CRM_AccountsAdditionalField__c customer1 = ASI_CRM_MY_TestClassHelper.createCustomer('customer1', 'ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        
        ASI_CRM_CN_Channel__c channel = ASI_CRM_MY_TestClassHelper.createChannel();
        ASI_TH_CRM_OutletImage__c oimg = ASI_CRM_MY_TestClassHelper.createOutletImage();
        customer1.ASI_CRM_Channel__c = channel.id;
        customer1.ASI_TH_CRM_OutletImage__c = oimg.id;
        update customer1;
        
        String strid = String.valueOf(customer1.id);
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = '2015', ASI_HK_CRM_Month__c = 'May'); 
        insert visitationPlan;
        
        visitationPlan.ownerid = UserA.id;
        update visitationPlan;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = customer1.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,5,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-05-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-05-21 12:00:00'),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail53 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = customer1.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,5,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-05-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-05-21 12:00:00'),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail53;
        
        update vpDetail53;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail54 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = customer1.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,5,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-05-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-05-21 12:00:00'),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
        insert vpDetail54;
        
        
        ASI_HK_CRM_Visitation_Plan__c visitationPlan2 = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Visitation_Plan__cASI_CRM_MY_VisitationPlan'), ASI_HK_CRM_Year__c = '2015', ASI_HK_CRM_Month__c = 'June'); 
        insert visitationPlan2;
        
        visitationPlan2.ownerid = UserA.id;
        update visitationPlan2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail2 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = customer1.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,6,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan2.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-06-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-06-21 12:00:00'),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_VisitationPlanDetail'));
        insert vpDetail2;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail3 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = customer1.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,6,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan2.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-06-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-06-21 12:00:00'),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Cold_Call'));
        insert vpDetail3;
        
        ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail4 = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_CRM_MY_Customer__c = customer1.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,6,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan2.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-06-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-06-21 12:00:00'),
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_HK_CRM_Visitation_Plan_Detail__cASI_CRM_MY_Visitation_Plan_Detail_Ad_Hoc'));
        insert vpDetail4;
        
        ASI_CRM_Holiday__c ho = new ASI_CRM_Holiday__c(Name = 'Test Holiday', ASI_CRM_Date_From__c = Date.newInstance(2015,5,21), ASI_CRM_Date_To__c = Date.newInstance(2015,5,21), ASI_CRM_Holiday_Type__c = 'Public', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Holiday__cASI_CRM_MY_Holiday')); 
        insert ho;
        
        ASI_CRM_Holiday__c ho2 = new ASI_CRM_Holiday__c(Name = 'Test Holiday', ASI_CRM_Date_From__c = Date.newInstance(2015,5,21), ASI_CRM_Date_To__c = Date.newInstance(2015,5,21), ASI_CRM_Holiday_Type__c = 'Company', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Holiday__cASI_CRM_MY_Holiday')); 
        insert ho2;
        
        ASI_CRM_Holiday__c ho3 = new ASI_CRM_Holiday__c(Name = 'Test Holiday', ASI_CRM_Date_From__c = Date.newInstance(2015,5,21), ASI_CRM_Date_To__c = Date.newInstance(2015,5,21), ASI_CRM_Holiday_Type__c = 'Meeting', RecordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Holiday__cASI_CRM_MY_Holiday')); 
        insert ho3;
        
        List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = [Select id from ASI_HK_CRM_Visitation_Plan_Detail__c limit 1];
            
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(visitationPlanDetailList);
        ApexPages.currentPage().getParameters().put('id', visitationPlan.id);    
        ASI_CRM_MY_VisitationPlanEditController controller = new ASI_CRM_MY_VisitationPlanEditController(stdSetController);                          
        
        controller.initPage();                 
        
        controller.searchAccountName = 'XXXXXX';
        controller.searchGrade= '';
        controller.searchCity = 'Test';
        controller.searchTown = 'Test';
        controller.ViewData();
        controller.quickSaveChanges();
        controller.saveChanges();
        
        controller.getSortDirection();
        controller.NameSearch();
        controller.ResetNameSearch();
        
        controller.sortExpression = 'ASC';
        controller.sortExpression = 'ASI_HK_CRM_Grade__c';        
        controller.setSortDirection('ASC');
        
        ApexPages.currentPage().getParameters().put('id', null);    
        controller = new ASI_CRM_MY_VisitationPlanEditController(stdSetController);
        
        ASI_CRM_MY_VisitationPlanCalendarCtl ctl = new ASI_CRM_MY_VisitationPlanCalendarCtl();
        ctl.getUsers();
        ctl.getUserItems();
        String strTest = ASI_CRM_MY_VisitationPlanCalendarCtl.insertEvent('10/10/2015', 'testing', 'obj', strid, '1', strName);
        String strTest2 = ASI_CRM_MY_VisitationPlanCalendarCtl.getEventData(strName, '2015-05-01');
    }
    
    /*static testMethod void VisitationPlanTest(){              
        user u = [SELECT id, ASI_CN_NPL_Receive_Approval_Request__c, DelegatedApproverId, Managerid, userroleid
        from user where profile.Name = 'System Administrator' and isactive = true and userroleid <> null limit 1];                                                
        
        System.runAs(u) {
            String recordTypeid = checkRecordType('ASI_TH_CRM_OutletType__c','ASI_CRM_TW_Outlet_Type');
            ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
            insert outletType;
        
            List<Account> insertAccountList = new List<Account>();
            List<ASI_CRM_AccountsAdditionalField__c> insertAccountAdditionalFieldList = new List<ASI_CRM_AccountsAdditionalField__c>();
            
            recordTypeid = checkRecordType('Account','ASI_CRM_TW_Outlet');    
            Account outlet = new Account(Name='Test Outlet', RecordTypeid = recordTypeid, ownerid = u.id);
            insertAccountList.add(outlet);            
            
            insert insertAccountList;
            
            recordTypeid = checkRecordType('ASI_CRM_AccountsAdditionalField__c','ASI_CRM_TW_Outlet');
            ASI_CRM_AccountsAdditionalField__c accountAdditionalField = new ASI_CRM_AccountsAdditionalField__c(
                Name = 'Test Outlet', ASI_CRM_Account__c = outlet.id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',RecordTypeid = recordTypeid,
                ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12'
            );
            insertAccountAdditionalFieldList.add(accountAdditionalField);
            
            insert insertAccountAdditionalFieldList;
        
            recordTypeid = checkRecordType('ASI_HK_CRM_Visitation_Plan__c','ASI_CRM_TW_Visitation_Plan');
            ASI_HK_CRM_Visitation_Plan__c visitationPlan = new ASI_HK_CRM_Visitation_Plan__c(Name = 'Test Visitation Plan', RecordTypeid = recordTypeid,
                ASI_HK_CRM_Year__c = '2015', ASI_HK_CRM_Month__c = 'May');
                
            insert visitationPlan;
            
            ASI_HK_CRM_Visitation_Plan_Detail__c vpDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c(
                ASI_HK_CRM_Account__c = outlet.id, ASI_HK_CRM_Visit_Date__c = Date.newInstance(2015,5,21), ASI_HK_CRM_Visitation_Plan__c = visitationPlan.id,
                ASI_TH_CRM_Visit_Date_Time_From__c = datetime.valueOf('2015-05-21 11:00:00'), ASI_TH_CRM_Visit_Date_Time_To__c = datetime.valueOf('2015-05-21 12:00:00')
            );
            insert vpDetail;
            
            List<ASI_HK_CRM_Visitation_Plan_Detail__c> visitationPlanDetailList = [Select id from ASI_HK_CRM_Visitation_Plan_Detail__c limit 1];
            
            ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(visitationPlanDetailList);
            ApexPages.currentPage().getParameters().put('id', visitationPlan.id);    
            ASI_CRM_TW_VisitationPlanEditController controller5 = new ASI_CRM_TW_VisitationPlanEditController(stdSetController);                          
            
            controller5.initPage();                 
            
            controller5.searchAccountName = 'XXXXXX';
            controller5.searchGrade= '';
            controller5.searchCity = 'Test';
            controller5.searchTown = 'Test';
            controller5.ViewData();
            controller5.quickSaveChanges();
            controller5.saveChanges();
            
            controller5.getSortDirection();
            controller5.NameSearch();
            controller5.ResetNameSearch();
            
            controller5.sortExpression = 'ASC';
            controller5.sortExpression = 'ASI_HK_CRM_Grade__c';        
            controller5.setSortDirection('ASC');
            
            ApexPages.currentPage().getParameters().put('id', null);    
            controller5 = new ASI_CRM_TW_VisitationPlanEditController(stdSetController); 
        }
    }*/
}