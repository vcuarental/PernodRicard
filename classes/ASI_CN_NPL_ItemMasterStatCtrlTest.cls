@isTest
private class ASI_CN_NPL_ItemMasterStatCtrlTest {
    static ID getRecordTypeIDByName(string RTName){
    
        return Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__c' + RTName);
    }
    private static ASI_CN_NPL_Item_Master__c im;
        
    static testMethod void testItemMasterProceedNextStep(){ 
        
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator GDT'];
        User DMLUser = [Select Id From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];
        DMLUser.CompanyName = 'Pernod Ricard China';
        update DMLUser;
		User u2 = new User(Username = 'NPLuser@user.com', CompanyName = 'Pernod Ricard China', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        
        UserRole supervisorRole = new UserRole(Name='Supervisor Role', DeveloperName = 'Supervisor_Role');
                    insert supervisorRole;
                    
                    UserRole ownerRole = new UserRole(Name='Owner Role', DeveloperName = 'Owner_Role', ParentRoleID = supervisorRole.Id);
                    insert ownerRole;
                    u2.UserRoleID = ownerRole.id;
                    
                    insert u2;
                
        ASI_CN_NPL_NPL_Request__c npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CRM_CN_NPLT1PriceFlag__c = false, ASI_CN_NPL_Date__c = date.today(), RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Class_A'), ASI_CN_NPL_Classification_Text__c = 'Class A', ASI_CN_NPL_Status__c = 'Final Approved', ownerID = u2.id, ASI_CN_NPL_Comparable_PR_Product__c = 'ABC', ASI_CN_NPL_Profit_Loss__c ='ABC', ASI_CN_NPL_Final_Proposed_Selling_Price__c  = 1);
        
        ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = 'TestItemGroup'
                                                                       , ASI_MFM_Item_Group_Code__c = 'aaa'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , OwnerID = u2.id
                                                                      );
        
        
        System.runAs(DMLUser) {
            
        insert npl;
        insert tmpItemGroup;
        
        RecordType rec = [select id from RecordType where developerName = 'ASI_CN_NPL_Item_Master_TypeA' limit 1];
        
        Test.startTest();
        
        im = new ASI_CN_NPL_Item_Master__c(recordTypeID = rec.id, ASI_CN_NPL_Status__c = 'Waiting For Logistics Input Item Code', ASI_CN_NPL_Item_Goup_Code__c ='aaa', ASI_CN_NPL_NPL_Reference_No__c = npl.id);
        insert im;
        
        PageReference pageRef = Page.ASI_CN_NPL_ItemMasterStatusPage;
        
        Test.setCurrentPage(pageRef);

        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(im);
        ASI_CN_NPL_ItemMasterStatusController proceedCon = new ASI_CN_NPL_ItemMasterStatusController(stdCon);
                
        proceedCon.proceedToNextStep();
        
        im.ASI_CN_NPL_Status__c = 'Waiting For BA Input Category Code';
        update im;
        
        ApexPages.StandardController stdCon2 = new ApexPages.StandardController(im);
        ASI_CN_NPL_ItemMasterStatusController proceedCon2 = new ASI_CN_NPL_ItemMasterStatusController(stdCon2);
        proceedCon2.proceedToNextStep();
        
        im.ASI_CN_NPL_Status__c = 'Waiting For Logistics Finalize Chinese Name';
        update im;
        
        ApexPages.StandardController stdCon3 = new ApexPages.StandardController(im);
        ASI_CN_NPL_ItemMasterStatusController proceedCon3 = new ASI_CN_NPL_ItemMasterStatusController(stdCon3);
        proceedCon3.proceedToNextStep();
        
        im.ASI_CN_NPL_Status__c = 'Waiting For Sales Planning Input Item Group Description (GE & CH)';
        update im;
        
        ApexPages.StandardController stdCon4 = new ApexPages.StandardController(im);
        ASI_CN_NPL_ItemMasterStatusController proceedCon4 = new ASI_CN_NPL_ItemMasterStatusController(stdCon4);
        proceedCon4.proceedToNextStep();

        im.ASI_CN_NPL_Status__c = 'Waiting For Logistics Final Confirmation';
        update im;
        
        ApexPages.StandardController stdCon5 = new ApexPages.StandardController(im);
        ASI_CN_NPL_ItemMasterStatusController proceedCon5 = new ASI_CN_NPL_ItemMasterStatusController(stdCon5);
        proceedCon5.proceedToNextStep();
            
            npl.ASI_CN_NPL_Profit_Loss__c = 'TEST';
            update npl;
            
            im.ASI_CN_NPL_Status__c = 'Waiting for Logistics Input Cap Group';
            update im;
            
            ApexPages.StandardController stdCon7 = new ApexPages.StandardController(im);
            ASI_CN_NPL_ItemMasterStatusController proceedCon7 = new ASI_CN_NPL_ItemMasterStatusController(stdCon7);
            proceedCon7.proceedToNextStep();

            proceedCon7.goBack();
            
//Test Type B       
        rec = [select id from RecordType where developerName = 'ASI_CN_NPL_Item_Master_TypeB' limit 1];
        
        im.recordTypeID = rec.id;
        
        im.ASI_CN_NPL_Status__c = 'Waiting For Logistics Input Item Code';
        update im;
        
        ApexPages.StandardController stdCon6 = new ApexPages.StandardController(im);
        ASI_CN_NPL_ItemMasterStatusController proceedCon6 = new ASI_CN_NPL_ItemMasterStatusController(stdCon6);
        proceedCon6.proceedToNextStep();
        
            
            
        Test.stopTest();
        }
    }   
}