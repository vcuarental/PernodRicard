@isTest
public class ASI_CRM_TW_AccountPSPhototest {
    static testMethod void ASI_CRM_TW_AccountPSPhototest()
    { 
        user u = [select userRole.developerName from user where id = :userInfo.getUserId()];
        PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name='ASI_CRM_TW_System_Admin'];
        
        //Assign permission set 'ASI_CRM_TW_System_Admin' to user u 
        PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = ps.id, AssigneeId = u.id);              
            
        //Insert Outlet type
        String recordTypeid = Global_RecordTypeCache.getRTId('ASI_TH_CRM_OutletType__cASI_CRM_TW_Outlet_Type');
        ASI_TH_CRM_OutletType__c outletType = new ASI_TH_CRM_OutletType__c(Name = 'LS (零售菸專)', ASI_TH_CRM_Code__c = 'TW_LS', RecordTypeid = recordTypeid);
        insert outletType;
         
        List<Account> listAccount = new List<Account>();
        List<ASI_CRM_AccountsAdditionalField__c> listCustomer = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        //Insert Account
        recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Outlet');   
        listAccount.add(new Account(Name='Outlet1', RecordTypeid = recordTypeid, ownerid = u.id, ASI_TH_CRM_Region__c = 'North'));
        listAccount.add(new Account(Name='Outlet2', RecordTypeid = recordTypeid, ownerid = u.id, ASI_TH_CRM_Region__c = 'South'));
        recordTypeid = Global_RecordTypeCache.getRTId('AccountASI_CRM_TW_Wholesaler');   
        listAccount.add(new Account(Name='WS', RecordTypeid = recordTypeid, ownerid = u.id));                
        insert listAccount;
        
        //Insert Customer
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_AccountsAdditionalField__cASI_CRM_TW_Outlet');
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer1', ASI_CRM_Account__c = listAccount[0].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));      
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer2', ASI_CRM_Account__c = listAccount[1].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));
        listCustomer.add(new ASI_CRM_AccountsAdditionalField__c(Name = 'Customer3', ASI_CRM_Account__c = listAccount[2].id, ASI_TH_CRM_OutletType__c = outletType.id, ASI_CRM_Region__c = 'North',
                                                                RecordTypeid = recordTypeid, ASI_CRM_City__c = 'Test City', ASI_CRM_Town__c = 'Test Town', ASI_CRM_TW_Street__c = 'Test Street', 
                                                                ASI_CRM_TW_Number__c = '1', ASI_CRM_TW_Floor__c = '12', ASI_CRM_MY_GeoConverStatus__c = 'Completed'));                                                           
        insert listCustomer;

        //Insert promotion
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_HK_CRM_Promotion__cASI_CRM_TW_ChannelPromotion');
        ASI_HK_CRM_Promotion__c promotion = new ASI_HK_CRM_Promotion__c(Name = 'Promotion', RecordTypeid = recordTypeid, ASI_CRM_PurchaseDueDate__c = date.today(), 
                                                                        ASI_HK_CRM_Promotion_Start_Date__c = date.today()-1, ASI_HK_CRM_Promotion_End_Date__c = date.today()+1,
                                                                        ASI_CRM_Display_Check__c = TRUE, ASI_CRM_Display_Setup__c = TRUE, ASI_CRM_POSM__c = TRUE, ASI_HK_CRM_Promotion_Name__c='aaa');
        insert promotion;
        
        //Insert Promotion Target
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Target__cASI_CRM_TW_PromotionTarget');
        ASI_CRM_Promotion_Target__c promoTarget = new ASI_CRM_Promotion_Target__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Region__c = 'North', ASI_CRM_Target_Unit__c = 100, ASI_CRM_Confirmed__c = TRUE);
        insert promoTarget;
            
        //Insert Promotion Status
        recordTypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Promotion_Status__cASI_CRM_TW_PromotionStatus');
        List<ASI_CRM_Promotion_Status__c> listPromoStatus = new List<ASI_CRM_Promotion_Status__c>();
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[0].id, ASI_CRM_Supplier__c = listAccount[0].id, ASI_CRM_Unit__c = 100));
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[0].id, ASI_CRM_Supplier__c = listAccount[0].id, ASI_CRM_Confirmed__c = TRUE, ASI_CRM_Unit__c = 100));
        listPromoStatus.add(new ASI_CRM_Promotion_Status__c(RecordTypeid = recordTypeid, ASI_CRM_Promotion__c = promotion.id, ASI_CRM_Account__c = listAccount[0].id, ASI_CRM_Supplier__c = listAccount[0].id, ASI_CRM_Confirmed__c = TRUE, ASI_CRM_Unit__c = 100));
        insert listPromoStatus;

        List<Attachment> listAttch = new List<Attachment>();
        listAttch.add(new Attachment(ParentId = listPromoStatus[0].id, Name = 'Merchan_0001', Body = EncodingUtil.base64Decode('Test Data')));
        listAttch.add(new Attachment(ParentId = listPromoStatus[1].id, Name = 'Merchan_0002', Body = EncodingUtil.base64Decode('Test Data')));
        insert listAttch;

        Test.StartTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(listAccount[0]);
        ApexPages.currentPage().getParameters().put('id', listAccount[0].Id);
        ASI_CRM_TW_AccountPSPhotoClass controller = new ASI_CRM_TW_AccountPSPhotoClass(stdController);

        //controller.getChannelList();
        controller.getPromotionNameList();
        //controller.getRegionList();
        //controller.getPagnationRecords();
        controller.getDoneList();
        //controller.getTaskList();
        //controller.getSalesList();
        //controller.getSearchSalesSOQL();
        list<string> done_L = new list<string>();
        done_L.add('No');
        controller.getSearchDoneSOQL(done_L);
        list<string> POId_L = new list<string>();
        POId_L.add(promotion.id);
        controller.getsearchPromotionNameSOQL(POId_L);
        controller.getsearchPromotionDateSOQL();
        controller.ViewSearch();
        controller.searchCurrentPage();
        controller.pageRedirect();
        controller.Beginning();
        controller.Previous();
        controller.Next();
        controller.End();
        controller.getDisablePrevious();
        controller.getDisableNext();

        Test.stopTest();
    }
}