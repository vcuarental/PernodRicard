@isTest
private class ASI_CN_NPL_AttachDocDeleteChatterTest {

    private static ASI_CN_NPL_NPL_Request__c npl;
    private static Boolean isDataCreated = false;
    
    static testMethod void test_main() {
        initRecords();
        
        Test.startTest();
        
        testDeleteForDocObj(npl.Id, 'ASI_CN_NPL_Product_Document__c');
        
        Test.stopTest();
    }
    
    static void testDeleteForDocObj(ID parentId, String docObjAPIName) {
        Test.setCurrentPageReference(Page.ASI_CN_NPL_ProductAttachPage);
        ASI_CN_NPL_FileAttachmentController fileAttachCon = new ASI_CN_NPL_FileAttachmentController();
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = parentId;
        fileAttachCon.attachmentObjType = docObjAPIName;
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';
        fileAttachCon.isAttachInApproval = true;
        PageReference redirectPage = fileAttachCon.uploadAction();
        
        
        List<sObject> docRecords = database.query('SELECT Id, (SELECT Id FROM Feeds) FROM ' + docObjAPIName + ' WHERE ASI_CN_NPL_Parent__c = :parentId');
        List<sObject> feeds = docRecords.get(0).getSObjects('Feeds');
        System.assertEquals(1, feeds.size());
        
        System.debug('Start Delete ASI_CN_NPL_Product_Document__c');
        delete docRecords;
        System.debug('End Delete ASI_CN_NPL_Product_Document__c');
        List<ID> feedItemIds = new List<ID>();
        for (sObject theFeed : feeds) {
            feedItemIds.add(theFeed.Id);
        }
        List<FeedItem> feedItems = [SELECT Id FROM FeedItem WHERE Id IN :feedItemIds];
        System.assertEquals(0, feedItems.size());
    }
        
    static void initRecords() {
        //Prepare Public Group member    
            Profile adminProfile = [Select Id From Profile Where Name = 'System Administrator'];
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
       
        
         Id recordTypeID = [Select Id From RecordType Where SobjectType = 'ASI_CN_NPL_NPL_Request__c' And Name = 'Class A' LIMIT 1].Id;
            
        npl = new ASI_CN_NPL_NPL_Request__c(ASI_CN_NPL_When_to_Launch__c = date.today(), ASI_CN_NPL_Source_of_Volume__c = 'Test', ASI_CN_NPL_Reason_to_Launch__c = 'Test', 
            ASI_CN_NPL_Product_Name_English__c = 'Test', ASI_CN_NPL_Date__c = date.today(), RecordTypeId = recordTypeID, 
            ASI_CN_NPL_Status__c = 'Waiting for S&OP Alignment', ownerID = u2.id);
        
        insert npl;
    }
}