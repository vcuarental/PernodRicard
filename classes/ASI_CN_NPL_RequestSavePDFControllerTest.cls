@isTest
private class ASI_CN_NPL_RequestSavePDFControllerTest {
    private static ASI_CN_NPL_NPL_Request__c npl;
    private static Boolean isDataCreated = false;
    private static List<ASI_CN_NPL_NPL_Request__c> nplList = new List<ASI_CN_NPL_NPL_Request__c>();//20170928 Introv
    Private Static List<ASI_CRM_Fix_Approval_Route__c> fixApproval = new List< ASI_CRM_Fix_Approval_Route__c >();
    static testMethod void testDisplayPDF(){                           
        initData();
            
        Test.startTest();
        
        PageReference pageRef = Page.ASI_CN_NPL_RequestSavePDFPage;
        
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_CN_NPL_RequestSavePDFController PDFCon = new ASI_CN_NPL_RequestSavePDFController(stdCon);
        
        PDFCon.savePnL();
        
        PDFCon.popUp();
        
        Test.stopTest();
    }
    
    static testMethod void testDisplayPDF2(){                           
        initData();
        nplList[1].ASI_CN_NPL_Status__c = 'Pre-Approved';
        
        
        Test.startTest();
        
        Update nplList[1];
        
        PageReference pageRef = Page.ASI_CN_NPL_RequestSavePDFPage;
        
        Test.setCurrentPage(pageRef);
        
        //20170928 Introv
        ApexPages.StandardController stdCon = new ApexPages.StandardController(nplList[1]);

        ASI_CN_NPL_RequestSavePDFController PDFCon = new ASI_CN_NPL_RequestSavePDFController(stdCon);
        
        PDFCon.savePnL();
        
        PDFCon.popUp();
        
        Test.stopTest();
    }
    
    static testMethod void testDisplayPDF3(){                           
        initData();
        Update nplList[2];
        
        Test.startTest();
        
        PageReference pageRef = Page.ASI_CN_NPL_RequestSavePDFPage;
        
        Test.setCurrentPage(pageRef);
        
        //20170928 Introv
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(nplList[2]);
        
        ASI_CN_NPL_RequestSavePDFController PDFCon = new ASI_CN_NPL_RequestSavePDFController(stdCon);
        
        PDFCon.savePnL();
        
        PDFCon.popUp();
        
        Test.stopTest();
    }
    
    static void initData(){
        //Prepare Public Group member    
        Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator'];
        User DMLUser = [Select Id From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];
        
        User u = new User(Username = 'NPLsupervisor@supervisor.com', email = 'supervisor@supervisor.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='sup', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u2 = new User(Username = 'NPLuser@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u3 = new User(Username = 'NPLuser2@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u4 = new User(Username = 'NPLuser3@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u5 = new User(Username = 'NPLuser4@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u6 = new User(Username = 'NPLuser5@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u7 = new User(Username = 'NPLuser6@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u8 = new User(Username = 'NPLuser7@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u9 = new User(Username = 'NPLuser8@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u10 = new User(Username = 'NPLuser9@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u11 = new User(Username = 'NPLuser10@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u12 = new User(Username = 'NPLuser11@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u13 = new User(Username = 'NPLuser12@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u14 = new User(Username = 'NPLuser13@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u15 = new User(Username = 'NPLuser14@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        User u16 = new User(Username = 'NPLuser15@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US');
        
        List<User> uList = new List<User>();
        uList.add(u);
        uList.add(u2);
        uList.add(u3);
        uList.add(u4);
        uList.add(u5);
        uList.add(u6);
        uList.add(u7);
        uList.add(u8);
        uList.add(u9);
        uList.add(u10);
        uList.add(u11);
        uList.add(u12);
        uList.add(u13);
        uList.add(u14);
        uList.add(u15);
        uList.add(u16);
        
        fixApproval.add(new ASI_CRM_Fix_Approval_Route__c(ASI_CRM_CN_Type__c = 'New Product Launch - TP Approval'
                                                          , ASI_CRM_CN_Approver_1__c = u2.id
                                                          , recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Fix_Approval_Route__cASI_CRM_CN_Fix_Approval_Route')
                                                         ));
        
        Insert fixApproval;
        
            System.runAs(DMLUser) {
                try {
                    //Wilken 20131125, updated brand director assignment logic, Prepare Role for Owner
                    UserRole supervisorRole = new UserRole(Name='Supervisor Role', DeveloperName = 'Supervisor_Role');
                    insert supervisorRole;
                    u.UserRoleID = supervisorRole.id;
                    
                    UserRole ownerRole = new UserRole(Name='Owner Role', DeveloperName = 'Owner_Role', ParentRoleID = supervisorRole.Id);
                    insert ownerRole;
                    u2.UserRoleID = ownerRole.id;
                    u3.UserRoleID = ownerRole.id;
                    u4.UserRoleID = ownerRole.id;
                    u5.UserRoleID = ownerRole.id;
                    u6.UserRoleID = ownerRole.id;
                    u7.UserRoleID = ownerRole.id;
                    u8.UserRoleID = ownerRole.id;
                    u9.UserRoleID = ownerRole.id;
                    u10.UserRoleID = ownerRole.id;
                    u11.UserRoleID = ownerRole.id;
                    u12.UserRoleID = ownerRole.id;
                    u13.UserRoleID = ownerRole.id;
                    u14.UserRoleID = ownerRole.id;
                    u15.UserRoleID = ownerRole.id;
                    u16.UserRoleID = ownerRole.id;
                    
                    Insert uList;
                    //insert u;
                    
                    //insert u2;
                        
                    if (!isDataCreated){
                        List<Group> publicGroups = [Select Id From Group Where Name IN ('ASI CN NPL Marketing Director', 'ASI CN NPL Brand Director Approvers', 'ASI CN NPL Deputy Managing Director', 
                        'ASI CN NPL Finance Director', 'ASI CN NPL Marketing Director', 'ASI CN NPL National Sales Dev VP', 'ASI CN NPL Trade Marketing Director')];
                        List<GroupMember> groupMembers = new List<GroupMember>();
                        
                        for (Group g : publicGroups){
                            for(User user : uList){
                                GroupMember groupMember = new GroupMember(GroupId = g.Id, UserOrGroupId = user.Id);
                                groupMembers.add(groupMember);
                            }
                        }
                        
                        insert groupMembers;

                        isDataCreated = true;
                    }
                } catch (Exception e){
                }
            } 
        
        Id recordTypeID = [Select Id From RecordType Where SobjectType = 'ASI_CN_NPL_NPL_Request__c' And Name = 'Class A' LIMIT 1].Id;
        
        npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
                                            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = recordTypeID,  
                                            ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment', ownerID = u2.id
                                            , ASI_NPL_Bar_Priority__c = '1', ASI_NPL_Night_Club_Priority__c = '1', ASI_CN_NPL_Chinese_Bar_Priority__c = '1'
                                            , ASI_CN_NPL_KTV_Priority__c = '1', ASI_CN_NPL_FKTV_Priority__c = '1', ASI_CN_NPL_Western_Bar_Priority__c = '1'
                                            , ASI_CN_NPL_CR_Priority__c = '1', ASI_CN_NPL_IHBR_Priority__c = '1', ASI_NPL_Restaurant_Priority__c = '1'
                                            , ASI_NPL_Hotel_Priority__c = '1', ASI_NPL_BulkPurchase_Priority__c = '1', ASI_NPL_VIP_Priority__c = '1'
                                            , ASI_CN_NPL_Hypermarket_Priority__c = '1', ASI_CN_NPL_Cash_Carry_Priority__c = '1', ASI_CN_NPL_Supermarket_Priority__c = '1'
                                            , ASI_NPL_Convenience_Store_Chain_Priority__c = '1', ASI_CN_NPL_Department_Store_Priority__c = '1', ASI_NPL_Liquor_Store_WS_Store_Priority__c = '1'
                                            , ASI_CN_NPL_Wine_Shop_Priority__c = '1', ASI_CN_NPL_Tobacco_Store_Priority__c = '1', ASI_CN_NPL_Grocery_Priority__c = '1'
                                            , ASI_CN_NPL_Convenience_Store_Priority__c = '1', ASI_CN_NPL_E_Commerce_Priority__c = '1', ASI_CN_NPL_Wholesaler_Store_Priority__c = '1'
                                           );
        
        nplList.add(npl);//20170928 Introv
        nplList.add(new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
                                                  ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = recordTypeID,  
                                                  ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment', ownerID = u2.id
                                                  , ASI_NPL_Bar_Priority__c = '2', ASI_NPL_Night_Club_Priority__c = '2', ASI_CN_NPL_Chinese_Bar_Priority__c = '2'
                                                  , ASI_CN_NPL_KTV_Priority__c = '2', ASI_CN_NPL_FKTV_Priority__c = '2', ASI_CN_NPL_Western_Bar_Priority__c = '2'
                                                  , ASI_CN_NPL_CR_Priority__c = '2', ASI_CN_NPL_IHBR_Priority__c = '2', ASI_NPL_Restaurant_Priority__c = '2'
                                                  , ASI_NPL_Hotel_Priority__c = '2', ASI_NPL_BulkPurchase_Priority__c = '2', ASI_NPL_VIP_Priority__c = '2'
                                                  , ASI_CN_NPL_Hypermarket_Priority__c = '2', ASI_CN_NPL_Cash_Carry_Priority__c = '2', ASI_CN_NPL_Supermarket_Priority__c = '2'
                                                  , ASI_NPL_Convenience_Store_Chain_Priority__c = '2', ASI_CN_NPL_Department_Store_Priority__c = '2', ASI_NPL_Liquor_Store_WS_Store_Priority__c = '2'
                                                  , ASI_CN_NPL_Wine_Shop_Priority__c = '2', ASI_CN_NPL_Tobacco_Store_Priority__c = '2', ASI_CN_NPL_Grocery_Priority__c = '2'
                                                  , ASI_CN_NPL_Convenience_Store_Priority__c = '2', ASI_CN_NPL_E_Commerce_Priority__c = '2', ASI_CN_NPL_Wholesaler_Store_Priority__c = '2'));
        
        nplList.add(new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
                                                  ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = recordTypeID,  
                                                  ASI_CN_NPL_Status__c = 'Final Approved', ownerID = u2.id
                                                  , ASI_NPL_Bar_Priority__c = '3', ASI_NPL_Night_Club_Priority__c = '3', ASI_CN_NPL_Chinese_Bar_Priority__c = '3'
                                                  , ASI_CN_NPL_KTV_Priority__c = '3', ASI_CN_NPL_FKTV_Priority__c = '3', ASI_CN_NPL_Western_Bar_Priority__c = '3'
                                                  , ASI_CN_NPL_CR_Priority__c = '3', ASI_CN_NPL_IHBR_Priority__c = '3', ASI_NPL_Restaurant_Priority__c = '3'
                                                  , ASI_NPL_Hotel_Priority__c = '3', ASI_NPL_BulkPurchase_Priority__c = '3', ASI_NPL_VIP_Priority__c = '3'
                                                  , ASI_CN_NPL_Hypermarket_Priority__c = '3', ASI_CN_NPL_Cash_Carry_Priority__c = '3', ASI_CN_NPL_Supermarket_Priority__c = '3'
                                                  , ASI_NPL_Convenience_Store_Chain_Priority__c = '3', ASI_CN_NPL_Department_Store_Priority__c = '3', ASI_NPL_Liquor_Store_WS_Store_Priority__c = '3'
                                                  , ASI_CN_NPL_Wine_Shop_Priority__c = '3', ASI_CN_NPL_Tobacco_Store_Priority__c = '3', ASI_CN_NPL_Grocery_Priority__c = '3'
                                                  , ASI_CN_NPL_Convenience_Store_Priority__c = '3', ASI_CN_NPL_E_Commerce_Priority__c = '3', ASI_CN_NPL_Wholesaler_Store_Priority__c = '3'));
        
        insert nplList;//20170928 Introv
        
        ASI_CN_NPL_ATL_Plan__c atl = new ASI_CN_NPL_ATL_Plan__c(New_Product_Launch_Request__c = npl.Id);
        
        insert atl;
        
        ASI_CN_NPL_BTL_Plan__c btl = new ASI_CN_NPL_BTL_Plan__c(New_Product_Launch_Request__c = npl.Id);
        
        insert btl;
        
        ASI_CN_NPL_VIP_Plan__c vip = new ASI_CN_NPL_VIP_Plan__c(New_Product_Launch_Request__c = npl.Id);
        
        insert vip;
        
        System.debug('NPL Id: ' + npl.Id);
    }
}