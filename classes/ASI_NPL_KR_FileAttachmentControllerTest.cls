@isTest
private class ASI_NPL_KR_FileAttachmentControllerTest {
    private static ASI_CN_NPL_NPL_Request__c npl;
    private static Boolean isDataCreated = false;

    static testMethod void testCancel(){
        initData();

        PageReference pageRef = Page.ASI_NPL_KR_AttachmentUploadPage;
        
        pageRef .getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_NPL_KR_FileAttachmentController fileAttachCon = new ASI_NPL_KR_FileAttachmentController();
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_CN_NPL_Product_Document__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';

        string nextPage = fileAttachCon.cancel().getUrl();

        //Test for class properties
        Boolean hasCategoryField = fileAttachCon.hasCategoryField;
        Integer uploadStepCount = fileAttachCon.getUploadStepCount();
        List<SelectOption> categories = fileAttachCon.categories;
        
        System.debug('Test Cancel return URL: ' + nextPage);
        System.assertEquals(nextPage, '/' + npl.Id);
    }

    static testMethod void testAttachPage(){     
        initData();        
        
        PageReference pageRef = Page.ASI_NPL_KR_AttachmentUploadPage;
        
        pageRef.getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_NPL_KR_FileAttachmentController fileAttachCon = new ASI_NPL_KR_FileAttachmentController();
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_CN_NPL_Product_Document__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';

        string returnPage = fileAttachCon.uploadAction().getUrl();
        
        //System.assertEquals(returnPage, '/' + npl.Id);
    }
    
    static testMethod void testAttachExceedSizeLimit(){     
        initData();        
        
        ASI_CN_NPL_Product_Document__c nplatt = new ASI_CN_NPL_Product_Document__c(ASI_CN_NPL_File_Size__c = 1
                                                                                   , ASI_CN_NPL_Attach_in_Approval__c = True
                                                                                   , ASI_CN_NPL_Parent__c = npl.id
                                                                                  );
        
        Insert nplatt;
        
        PageReference pageRef = Page.ASI_NPL_KR_AttachmentUploadPage;
        
        pageRef.getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);

        ASI_NPL_KR_FileAttachmentController fileAttachCon = new ASI_NPL_KR_FileAttachmentController(stdCon);
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_CN_NPL_Product_Document__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = ASI_NPL_KR_FileAttachmentController.MAX_FILE_SIZE + 1;
        fileAttachCon.contentFileName = 'Test.pdf';

        //PageReference returnPage = fileAttachCon.uploadAction();
        
        //Update NPL for ASI_CN_NPL_NewProductLaunchRequest_AfterUpdate to be executed for covering test code of exceeding file size limit
        npl.ASI_CN_NPL_Step_1_Approved__c = true;
        update npl;
        
        //System.assertEquals(null,returnPage );
    }
      
    static void initData(){
        //Prepare Public Group member    
            Profile adminProfile = [Select Id From Profile Where Name = 'ASI System Administrator'];
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
            ASI_CN_NPL_Status__c = 'Waiting to Update Final Version');
        
        insert npl;
        
        System.debug('NPL Id: ' + npl.Id);
    }
}