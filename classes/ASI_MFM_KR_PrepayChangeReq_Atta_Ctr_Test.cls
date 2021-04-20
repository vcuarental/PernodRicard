/*
Test Class for
ASI_MFM_KR_PrepayChangeReq_Atta_Ctr
ASI_MFM_PrepaymentProposalChangeLog_BeforeUpdate
*/

@isTest
public class ASI_MFM_KR_PrepayChangeReq_Atta_Ctr_Test {
    
    private static ASI_MFM_Prepayment_Proposal_Change_Log__c npl;
    private static Boolean isDataCreated = false;
    
    static testMethod void testCancel(){
        initData();
        
        PageReference pageRef = Page.ASI_MFM_KR_PrepayChangeReq_Atta_Page;
        
        pageRef .getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        
        ASI_MFM_KR_PrepayChangeReq_Atta_Ctr fileAttachCon = new ASI_MFM_KR_PrepayChangeReq_Atta_Ctr();
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_MFM_Prepayment_Change_Request_Att__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';
        
        string nextPage = fileAttachCon.cancel().getUrl();
        
        //Test for class properties
        Integer uploadStepCount = fileAttachCon.getUploadStepCount();
        
        System.debug('Test Cancel return URL: ' + nextPage);
        System.assertEquals(nextPage, '/' + npl.Id);
    }
    
    static testMethod void testAttachPage(){     
        initData();        
        
        PageReference pageRef = Page.ASI_MFM_KR_PrepayChangeReq_Atta_Page;
        
        pageRef.getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        
        ASI_MFM_KR_PrepayChangeReq_Atta_Ctr fileAttachCon = new ASI_MFM_KR_PrepayChangeReq_Atta_Ctr();
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_MFM_Prepayment_Change_Request_Att__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = attachData.size();
        fileAttachCon.contentFileName = 'Test.pdf';
        
        string returnPage = fileAttachCon.uploadAction().getUrl();
        
        //System.assertEquals(returnPage, '/' + npl.Id);
    }
    
    static testMethod void testAttachExceedSizeLimit(){     
        initData();        
        
        PageReference pageRef = Page.ASI_MFM_KR_PrepayChangeReq_Atta_Page;
        
        pageRef.getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        
        ASI_MFM_KR_PrepayChangeReq_Atta_Ctr fileAttachCon = new ASI_MFM_KR_PrepayChangeReq_Atta_Ctr(stdCon);
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_MFM_Prepayment_Change_Request_Att__c';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = ASI_NPL_KR_FileAttachmentController.MAX_FILE_SIZE + 1;
        fileAttachCon.contentFileName = 'Test.pdf';
        
        try{
            String label = fileAttachCon.attachmentObjLabel;
            fileAttachCon.uploadAction(); 
        }catch(Exception e){}
        
    }
    
    static testMethod void testAttachOther(){     
        initData();        
        
        PageReference pageRef = Page.ASI_MFM_KR_PrepayChangeReq_Atta_Page;
        
        pageRef.getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        
        ASI_MFM_KR_PrepayChangeReq_Atta_Ctr fileAttachCon = new ASI_MFM_KR_PrepayChangeReq_Atta_Ctr(stdCon);
        string contentCategory = fileAttachCon.contentCategory;
        Boolean isAttachInApproval = fileAttachCon.isAttachInApproval;
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_MFM_Prepayment_Change_Request_Att__c';
        fileAttachCon.attachmentObjLabel = 'Label';
        fileAttachCon.contentData = attachData;
        fileAttachCon.fileSize = ASI_NPL_KR_FileAttachmentController.MAX_FILE_SIZE + 1;
        fileAttachCon.contentFileName = 'Test.pdf';
        
        try{ 
            String label = fileAttachCon.attachmentObjLabel;
            fileAttachCon.uploadAction(); 
        }catch(Exception e){
        }        
    }
    
    static testMethod void testAttachException(){     
        initData();        
        
        PageReference pageRef = Page.ASI_MFM_KR_PrepayChangeReq_Atta_Page;
        
        pageRef.getParameters().put('id', npl.Id);
        
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(npl);
        
        ASI_MFM_KR_PrepayChangeReq_Atta_Ctr fileAttachCon = new ASI_MFM_KR_PrepayChangeReq_Atta_Ctr(stdCon);
        
        Blob attachData = Blob.toPdf('Test');
        fileAttachCon.sObjParentId = npl.Id;
        fileAttachCon.attachmentObjType = 'ASI_MFM_Prepayment_Change_Request_Att__c';
        fileAttachCon.contentData = null;
        fileAttachCon.fileSize = ASI_NPL_KR_FileAttachmentController.MAX_FILE_SIZE + 1;
        fileAttachCon.contentFileName = 'Test.pdf';
        try{ fileAttachCon.uploadAction(); }catch(Exception e){}
        
        
    }
    
    static void initData(){
        //Prepare Public Group member    
        Profile adminProfile = [Select Id From Profile Where Name = 'ASI System Administrator'];
        User DMLUser = [Select Id, ASI_MFM_Team__c From User Where ProfileId = :adminProfile.Id And IsActive = true Limit 1];
        
        User u = new User(Username = 'NPLsupervisor@supervisor.com', email = 'supervisor@supervisor.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='sup', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', ASI_MFM_Team__c ='Brand Marketing');
        User u2 = new User(Username = 'NPLuser@user.com', email = 'user@user.com', profileID = adminProfile.id, IsActive = true, LastName='Supervisor', Alias='user', TimeZoneSidKey='GMT', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', ASI_MFM_Team__c ='Brand Marketing');
        user u3 = new User();
        u3 = [SELECT id, ASI_MFM_Team__c FROM User Where id = : Userinfo.getUserId()];
        u3.ASI_MFM_Team__c = 'Brand Marketing';
        Update u3;
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
        
        Account acc2 = new Account(recordTypeId=Global_RecordTypeCache.getRtId('AccountASI_KR_Supplier'),Name='Name1');          
        insert acc2;
        
        ASI_MFM_Tax_Code__c TaxCode = new ASI_MFM_Tax_Code__c (Name = 'JA11',
                                                               recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Tax_Code__cASI_MFM_KR_Tax_Code'),
                                                               ASI_MFM_VAT_Rate__c = 100,
                                                               ASI_MFM_Tax_Expl_Code__c = 'E');
        insert TaxCode;  
        
        ASI_MFM_Payment__c PaymentHeader = new ASI_MFM_Payment__c (ASI_MFM_Status__c = 'Submitted',
                                                                   recordtypeid = Global_RecordTypeCache.getRtId('ASI_MFM_Payment__cASI_MFM_KR_Payment'),
                                                                   ASI_MFM_Supplier_Name__c = acc2.id,
                                                                   ASI_MFM_Company_Code__c = '222',
                                                                   ASI_MFM_Send_Approval_Email__c=true,
                                                                   ASI_MFM_Is_Direct_Payment__c = false,
                                                                   ASI_MFM_Pre_payment__c = true,
                                                                   ASI_MFM_Tax_Code__c = TaxCode.id,
                                                                   ASI_MFM_Invoice_Number__c = 'OLD INVOICE NUMBER'
                                                                  );  
        
        insert PaymentHeader;        
        
        List<ASI_MFM_Fix_Approval_Route__c> FARList= new List<ASI_MFM_Fix_Approval_Route__c>();
        ASI_MFM_Fix_Approval_Route__c fapp = new ASI_MFM_Fix_Approval_Route__c(recordtypeid= Global_RecordTypeCache.getRtId('ASI_MFM_Fix_Approval_Route__cASI_MFM_KR_Fix_Approval_Route'), 
                                                                               ASI_MFM_Approval_Limit_CA2__c=1.1,ASI_MFM_Approval_Limit_CA3__c=2,ASI_MFM_Approval_Limit_CA4__c=1,
                                                                               ASI_MFM_Corporate_Approver_2__c= u.id,ASI_MFM_Corporate_Approver_3__c= u.id,ASI_MFM_Corporate_Approver_4__c= u.id,
                                                                               ASI_MFM_Need_Brand_Marketing__c='7',
                                                                               ASI_MFM_KR_Grand_Category__c='Non Service',ASI_MFM_Module__c='Prepayment Proposal Change Log', 
                                                                               ASI_MFM_Team__c ='Brand Marketing', ASI_MFM_Finance__c = u.id);
        FARList.add(fapp);
        
        
        insert FARList; 
        
        
        npl = new ASI_MFM_Prepayment_Proposal_Change_Log__c(RecordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Prepayment_Proposal_Change_Log__cASI_MFM_KR_Prepayment_Proposal_Change_Log'),
                                                            ASI_MFM_Payment__c = PaymentHeader.id, ASI_MFM_Requested_By__c=u3.id);
        
        insert npl;
        
        System.debug('Prepayment Change Request Id: ' + npl.Id);
    }
    
}