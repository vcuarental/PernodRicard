@IsTest
private class ASI_NPL_CN_ItemMasterTest {
    private static ASI_CN_NPL_Item_Master__c im;
    
    static testMethod void test_ASI_NPL_CN_ItemMasterTriggerAbstract() {
        initData();
    }

    static ID getRecordTypeIDByName(string RTName){
        return Global_RecordTypeCache.getRtId('ASI_CN_NPL_NPL_Request__c' + RTName);
    }
    
    static void initData(){
        ASI_FOC_Warehouse__c warehouse = new ASI_FOC_Warehouse__c();
        warehouse.ASI_MFM_Inventory_Required__c = true;
        warehouse.RecordTypeId  = Schema.SObjectType.ASI_FOC_Warehouse__c.getRecordTypeInfosByDeveloperName().get('ASI_NPL_CN_Normal_Goods_Warehouse').getRecordTypeId();
        insert warehouse;

        List<ASI_CN_NPL_Item_Master__c> items = new List<ASI_CN_NPL_Item_Master__c>();

        ASI_CN_NPL_Item_Master__c itemA = new ASI_CN_NPL_Item_Master__c();
        itemA.RecordTypeId  = Schema.SObjectType.ASI_CN_NPL_Item_Master__c.getRecordTypeInfosByDeveloperName().get('ASI_CN_NPL_Item_Master_TypeA').getRecordTypeId();
        items.add(itemA);

        ASI_CN_NPL_Item_Master__c itemB = new ASI_CN_NPL_Item_Master__c();
        itemB.RecordTypeId  = Schema.SObjectType.ASI_CN_NPL_Item_Master__c.getRecordTypeInfosByDeveloperName().get('ASI_CN_NPL_Item_Master_TypeB').getRecordTypeId();
        items.add(itemB);

        insert items;
    }
    
    static testMethod void test_trigger(){ 
        
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
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CRM_CN_NPLT1PriceFlag__c = TRUE, ASI_CN_NPL_Date__c = date.today(), RecordTypeId = getRecordTypeIDByName('ASI_CN_NPL_Class_A'), ASI_CN_NPL_Classification_Text__c = 'Class A', ASI_CN_NPL_Status__c = 'Final Approved', ownerID = u2.id, ASI_CN_NPL_Comparable_PR_Product__c = 'ABC', ASI_CN_NPL_Profit_Loss__c ='ABC', ASI_CN_NPL_Final_Proposed_Selling_Price__c  = 1);
        
        List<ASI_MFM_Item_Group__c> ltItemGroup = new List<ASI_MFM_Item_Group__c>();
        ASI_MFM_Item_Group__c tmpItemGroup = new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = 'TestItemGroup'
                                                                       , ASI_MFM_Item_Group_Code__c = 'aaa'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , OwnerID = u2.id
                                                                      );
        
        
        ltItemGroup.add(tmpItemGroup);
        ltItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = '123'
                                                                       , ASI_MFM_Item_Group_Code__c = '123'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , OwnerID = u2.id
                                                                      ));
        ltItemGroup.add(new ASI_MFM_Item_Group__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Item_Group__cASI_CRM_CN_CRM_Item_Group')
                                                                       , Name = '456'
                                                                       , ASI_MFM_Item_Group_Code__c = '456'
                                                                       , ASI_CRM_CN_Eng_Name__c = 'TestItemGroup'
                                                                       , OwnerID = u2.id
                                                                      ));
        
        System.runAs(DMLUser) {
            
            insert npl;
            insert ltItemGroup;
            
            RecordType rec = [select id from RecordType where developerName = 'ASI_CN_NPL_Item_Master_TypeA' limit 1];
            im = new ASI_CN_NPL_Item_Master__c(recordTypeID = rec.id, ASI_CN_NPL_Status__c = 'Completed', ASI_CN_NPL_Item_Goup_Code__c ='aaa', ASI_CN_NPL_NPL_Reference_No__c = npl.id);
            insert im;
            
			ASI_CRM_Price_And_Discount__c oPnd = new ASI_CRM_Price_And_Discount__c(recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Price_And_Discount__cASI_CRM_CN_NPL_T1_Price_Request_RO')
                                                                        , ASI_CRM_NPL_Reference_Number__c = npl.Id
                                                                        , ASI_CRM_Status__c = 'Pending for BO to PRCSW Pirce'
                                                                        , ASI_CRM_Remark__c = 'test'
                                                                        , ASI_CRM_Item_Master_Reference_Number__c = im.Id
                                                                        , ASI_CRM_Effective_From__c = date.today()
                                                                       );
            insert oPnd;
            
            Test.startTest();
            im.ASI_CN_NPL_Ignore_Checking__c = TRUE;
            im.ASI_CN_NPL_Item_Goup_Code__c = '123';
            update im;
            
            im.ASI_CN_NPL_Ignore_Checking__c = TRUE;
            im.ASI_CN_NPL_Item_Goup_Code__c = '456';
            im.ASI_CN_NPL_New_Brand_Sub_Brand_Picklist__c = 'Yes';
            im.ASI_CN_NPL_New_Item_Group_Picklist__c = 'Yes';
            im.ASI_CN_NPL_VAP_Picklist__c = 'No';
            update im;

        	Test.stopTest();
        }
    }   
}