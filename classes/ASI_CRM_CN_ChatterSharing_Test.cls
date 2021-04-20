@isTest(SeeAllData=true)
/*******************************
Tested Classes
1. ASI_CRM_CN_ChatterSharing
2. ASI_CRM_CN_IssueZone_AfterUpsert
3. ASI_CRM_CN_FeedItem_AfterInsert
4. ASI_CRM_CN_FeedComment_AfterInsert
5. ASI_CRM_CN_IssueMobile_Controller
**********************************/
public class ASI_CRM_CN_ChatterSharing_Test{
    static testMethod void ASI_CRM_CN_CreateIssue(){
        //Select CN User
        User objUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true ORDER BY CreatedDate DESC Limit 1];
        User objUser1 = [SELECT id FROM User Where Profile.Name Like 'System Administrator' AND isActive = true ORDER BY CreatedDate ASC Limit 1];
        
        //Create City
        ASI_CRM_City__c objCity = new ASI_CRM_City__c();
        objCity.ASI_CRM_Chinese_Name__c = '中文';
        objCity.Name = 'Test Class City';
        objCity.ASI_CRM_CN_City_Code__c = 'CODE12345';
        insert objCity;
        
        //Issue Zone RecordType
        RecordType RT = [SELECT id, Name FROM RecordType WHERE SObjectType = 'ASI_CRM_Issue_Zone__c' LIMIT 1];
        
        //Create Issue Zone Admin User Group
        ASI_CRM_CN_Issue_Sharing_Admin__c objIssueAdmin = new ASI_CRM_CN_Issue_Sharing_Admin__c();
        objIssueAdmin.ASI_CRM_CN_Issue_Type__c = RT.Name;
        insert objIssueAdmin;
        
        //Create Issue Zone Admin User
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser.ASI_CRM_CN_User__c = objUser.Id;
        insert objAdminUser;
        
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser1 = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser1.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser1.ASI_CRM_CN_User__c = objUser1.Id;
        insert objAdminUser1;
        
        System.runAs(objUser){
        
            //Create Issue
            ASI_CRM_Issue_Zone__c objIssue = new ASI_CRM_Issue_Zone__c();
            objIssue.RecordTypeId = RT.Id;
            objIssue.ASI_CRM_City__c = objCity.Id;
            objIssue.ASI_CRM_Location_Others__c = 'Test Class Location';
            objIssue.ASI_CRM_Product1__c = 
            objIssue.ASI_CRM_Qty__c = '2';
            objIssue.ASI_CRM_Price1__c = 1;
            objIssue.ASI_CRM_CN_Origin_of_GMA__c = 'Test Remarks';
            insert objIssue;
        }
    }
    static testMethod void ASI_CRM_CN_UpdateIssue(){
        //Select CN User
        User objUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true ORDER BY CreatedDate DESC Limit 1];
        User objUser1 = [SELECT id FROM User Where Profile.Name Like 'System Administrator' AND isActive = true ORDER BY CreatedDate ASC Limit 1];
      
        //Create City
        ASI_CRM_City__c objCity = new ASI_CRM_City__c();
        objCity.ASI_CRM_Chinese_Name__c = '中文';
        objCity.Name = 'Test Class City';
        objCity.ASI_CRM_CN_City_Code__c = 'CODE12345';
        insert objCity;
        
        //Issue Zone RecordType
        RecordType RT = [SELECT id, Name FROM RecordType WHERE SObjectType = 'ASI_CRM_Issue_Zone__c' LIMIT 1];
        
        //Create Issue Zone Admin User Group
        ASI_CRM_CN_Issue_Sharing_Admin__c objIssueAdmin = new ASI_CRM_CN_Issue_Sharing_Admin__c();
        objIssueAdmin.ASI_CRM_CN_Issue_Type__c = RT.Name;
        insert objIssueAdmin;
        
        //Create Issue Zone Admin User
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser.ASI_CRM_CN_User__c = objUser.Id;
        insert objAdminUser;
        
        ASI_CRM_CN_Issue_Sharing_Admin__c objIssueAdmin1 = new ASI_CRM_CN_Issue_Sharing_Admin__c();
        objIssueAdmin1.ASI_CRM_CN_Issue_Type__c = 'Look-alike';
        insert objIssueAdmin1;
        
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser1 = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser1.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin1.id;
        objAdminUser1.ASI_CRM_CN_User__c = objUser1.Id;
        insert objAdminUser1;
        
        System.runAs(objUser){
        
            //Create Issue
            ASI_CRM_Issue_Zone__c objIssue = new ASI_CRM_Issue_Zone__c();
            objIssue.RecordTypeId = RT.Id;
            objIssue.ASI_CRM_City__c = objCity.Id;
            objIssue.ASI_CRM_Location_Others__c = 'Test Class Location';
            objIssue.ASI_CRM_Product1__c = 
            objIssue.ASI_CRM_Qty__c = '2';
            objIssue.ASI_CRM_Price1__c = 1;
            objIssue.ASI_CRM_CN_Origin_of_GMA__c = 'Test Remarks';
            insert objIssue;
objIssue.ASI_CRM_CN_Reclassification__c='Look-alike';      
            update objIssue;
        }
    }
    static testMethod void ASI_CRM_CN_AddFeedItem(){
        //Select CN User
        User objUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        //User objUser1 = [SELECT id FROM User Where Profile.Name Like '%CN%' AND isActive = true Limit 1];
        
        //Create City
        ASI_CRM_City__c objCity = new ASI_CRM_City__c();
        objCity.ASI_CRM_Chinese_Name__c = '中文';
        objCity.Name = 'Test Class City';
        objCity.ASI_CRM_CN_City_Code__c = 'CODE12345';
        insert objCity;
        
        //Issue Zone RecordType
        RecordType RT = [SELECT id, Name FROM RecordType WHERE SObjectType = 'ASI_CRM_Issue_Zone__c' LIMIT 1];
        
        //Create Issue Zone Admin User Group
        ASI_CRM_CN_Issue_Sharing_Admin__c objIssueAdmin = new ASI_CRM_CN_Issue_Sharing_Admin__c();
        objIssueAdmin.ASI_CRM_CN_Issue_Type__c = RT.Name;
        insert objIssueAdmin;
        
        //Create Issue Zone Admin User
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser.ASI_CRM_CN_User__c = objUser.Id;
        insert objAdminUser;
        
        /*ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser1 = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser1.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser1.ASI_CRM_CN_User__c = objUser1.Id;
        insert objAdminUser1;*/
        string strFeeditemid;
        
        System.runAs(objUser){
            Test.startTest();
            
            //Create Issue
            ASI_CRM_Issue_Zone__c objIssue = new ASI_CRM_Issue_Zone__c();
            objIssue.RecordTypeid = RT.Id;
            //objIssue.ASI_CRM_City__c = objCity.Id;
            //20160303 Ben @ Elufa
            objIssue.ASI_CRM_CN_Reclassification__c = 'External GMA';
            objIssue.ASI_CRM_Location_Others__c = 'Test Class Location';
            objIssue.ASI_CRM_Product1__c = 
            objIssue.ASI_CRM_Qty__c = '2';
            objIssue.ASI_CRM_Price1__c = 1;
            objIssue.ASI_CRM_CN_Origin_of_GMA__c = 'Test Remarks';
            insert objIssue;
            
            Id IdMentionChatter = objUser.Id;
            String subjectId = objIssue.Id;  
            String communityId = null;
            //Add a @Mention UserId to Feeditem
            ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Hi ';
            messageInput.messageSegments.add(textSegment);
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = IdMentionChatter ;
            messageInput.messageSegments.add(mentionSegment);
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = '. I have added an new Issue';
            messageInput.messageSegments.add(textSegment);
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;
            ConnectApi.NewFileAttachmentInput FileAttach = new ConnectApi.NewFileAttachmentInput();
            FileAttach.title = 'title of file';
            FileAttach.description = 'description of file';
            input.attachment = FileAttach; 
            ConnectApi.BinaryInput FileAttachBinary = new ConnectApi.BinaryInput(Blob.valueOf('body file'), 'plan/txt', 'filename.txt');
             
            ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, subjectId, input, FileAttachBinary);
            
            FeedItem objFeedItem = new FeedItem();
            objFeedItem.Body = '[is Test]';
            objFeedItem.ParentId = objIssue.id;
            insert objFeedItem;
        }
            
        Test.stopTest();
    }
    static testMethod void ASI_CRM_CN_AddFeedComment(){
        //Select CN User
        User objUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true Limit 1];
        //User objUser1 = [SELECT id FROM User Where Profile.Name Like '%CN%' AND isActive = true Limit 1];
        
        //Create City
        ASI_CRM_City__c objCity = new ASI_CRM_City__c();
        objCity.ASI_CRM_Chinese_Name__c = '中文';
        objCity.Name = 'Test Class City';
        objCity.ASI_CRM_CN_City_Code__c = 'CODE12345';
        insert objCity;
        
        //Issue Zone RecordType
        RecordType RT = [SELECT id, Name FROM RecordType WHERE SObjectType = 'ASI_CRM_Issue_Zone__c' LIMIT 1];
        
        //Create Issue Zone Admin User Group
        ASI_CRM_CN_Issue_Sharing_Admin__c objIssueAdmin = new ASI_CRM_CN_Issue_Sharing_Admin__c();
        objIssueAdmin.ASI_CRM_CN_Issue_Type__c = RT.Name;
        insert objIssueAdmin;
        
        //Create Issue Zone Admin User
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser.ASI_CRM_CN_User__c = objUser.Id;
        insert objAdminUser;
        
        /*ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser1 = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser1.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser1.ASI_CRM_CN_User__c = objUser1.Id;
        insert objAdminUser1;*/
        string strFeeditemid;
        
        //System.runAs(objUser){
            Test.startTest();
            
            //Create Issue
            ASI_CRM_Issue_Zone__c objIssue = new ASI_CRM_Issue_Zone__c();
            objIssue.RecordTypeid = RT.Id;
            //objIssue.ASI_CRM_City__c = objCity.Id;
            objIssue.ASI_CRM_Location_Others__c = 'Test Class Location';
            objIssue.ASI_CRM_Product1__c = 
            objIssue.ASI_CRM_Qty__c = '2';
            objIssue.ASI_CRM_Price1__c = 1;
            objIssue.ASI_CRM_CN_Origin_of_GMA__c = 'Test Remarks';
            insert objIssue;
        
        objIssue.ASI_CRM_CN_Reclassification__c = 'External GMA';
        update objIssue;
            
        //20160303 Ben @ Elufa commented
            /*Id IdMentionChatter = objUser.Id;
            String subjectId = objIssue.Id;  
            
            //Add a @Mention UserId to Feeditem
            ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = 'Hi ';
            messageInput.messageSegments.add(textSegment);
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = IdMentionChatter ;
            messageInput.messageSegments.add(mentionSegment);
            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = '. I have added an new Issue';
            messageInput.messageSegments.add(textSegment);
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            input.body = messageInput;
            ConnectApi.NewFileAttachmentInput FileAttach = new ConnectApi.NewFileAttachmentInput();
            FileAttach.title = 'title of file';
            FileAttach.description = 'description of file';
            input.attachment = FileAttach; 
            ConnectApi.BinaryInput FileAttachBinary = new ConnectApi.BinaryInput(Blob.valueOf('body file'), 'plan/txt', 'filename.txt');
             
            ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, subjectId, input, FileAttachBinary);
            *///20160303 End
        String communityId = null;
            FeedItem objFeedItem = new FeedItem();
            objFeedItem.Body = '[is Test]';
            objFeedItem.ParentId = objIssue.id;
            insert objFeedItem;
            strFeeditemid = objFeedItem.id;

            //Add Comment to FeedItem
            String FeedId = strFeeditemid;
           
            ConnectApi.MessageBodyInput messageInput1 = new ConnectApi.MessageBodyInput();
            messageInput1.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            ConnectApi.TextSegmentInput textSegment1 = new ConnectApi.TextSegmentInput();
            textSegment1.text = 'close ';
            messageInput1.messageSegments.add(textSegment1);
            ConnectApi.CommentInput input1 = new ConnectApi.CommentInput();
            input1.body = messageInput1;
            ConnectApi.Comment feedCommentRep = ConnectApi.ChatterFeeds.postComment(communityId, FeedId, input1, null);
            
            FeedComment FF = new FeedComment();
            FF.CommentBody = 'close';
            FF.FeedItemId = FeedId;
            insert FF;
            list<ASI_CRM_Issue_Zone__c> newIZ = new list<ASI_CRM_Issue_Zone__c>();
            newIZ.add(objIssue);
            list<FeedComment> FIList = new list <FeedComment>();
            FIList.add(FF);
            ASI_CRM_CN_ChatterSharing newsc = new ASI_CRM_CN_ChatterSharing();
            newsc.ASI_CRM_CN_ChatterAdminChangeStatusComment(FIList);
            //newsc.ASI_CRM_CN_AddShare(newIZ);
        //}
            
        Test.stopTest();
    }
    static testMethod void ASI_CRM_CN_IssueMobilePage(){
        //Select CN User
        User objUser = [SELECT id FROM User Where Profile.Name = 'System Administrator' AND isActive = true ORDER BY CreatedDate DESC Limit 1];
        User objUser1 = [SELECT id FROM User Where Profile.Name Like 'System Administrator' AND isActive = true ORDER BY CreatedDate ASC Limit 1];
        
        //Create City
        ASI_CRM_City__c objCity = new ASI_CRM_City__c();
        objCity.ASI_CRM_Chinese_Name__c = '中文';
        objCity.Name = 'Test Class City';
        objCity.ASI_CRM_CN_City_Code__c = 'CODE12345';
        insert objCity;
        
        //Issue Zone RecordType
        RecordType RT = [SELECT id, Name FROM RecordType WHERE SObjectType = 'ASI_CRM_Issue_Zone__c' LIMIT 1];
        
        //Create Issue Zone Admin User Group
        ASI_CRM_CN_Issue_Sharing_Admin__c objIssueAdmin = new ASI_CRM_CN_Issue_Sharing_Admin__c();
        objIssueAdmin.ASI_CRM_CN_Issue_Type__c = RT.Name;
        insert objIssueAdmin;
        
        //Create Issue Zone Admin User
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser.ASI_CRM_CN_User__c = objUser.Id;
        insert objAdminUser;
        
        ASI_CRM_CN_Issue_Sharing_Admin_User_List__c objAdminUser1 = new ASI_CRM_CN_Issue_Sharing_Admin_User_List__c();
        objAdminUser1.ASI_CRM_CN_Issue_Sharing_Group__c = objIssueAdmin.id;
        objAdminUser1.ASI_CRM_CN_User__c = objUser1.Id;
        insert objAdminUser1;
        
        System.runAs(objUser){
        
            //Create Issue
            ASI_CRM_Issue_Zone__c objIssue = new ASI_CRM_Issue_Zone__c();
            objIssue.RecordTypeId = RT.Id;
            objIssue.ASI_CRM_City__c = objCity.Id;
            objIssue.ASI_CRM_Location_Others__c = 'Test Class Location';
            objIssue.ASI_CRM_Product1__c = 
            objIssue.ASI_CRM_Qty__c = '2';
            objIssue.ASI_CRM_Price1__c = 1;
            objIssue.ASI_CRM_CN_Origin_of_GMA__c = 'Test Remarks';
            insert objIssue;
            
            //Test Page ASI_CRM_CN_Issue_Zone_Mobile
            PageReference pageRef = Page.ASI_CRM_CN_Issue_Zone_Mobile;
            Test.setCurrentPage(pageRef);
    
            ApexPages.CurrentPage().getparameters().put('id', objIssue.id);
            ApexPages.StandardController sc = new ApexPages.standardController(objIssue);
            ASI_CRM_CN_IssueMobile_Controller sic = new ASI_CRM_CN_IssueMobile_Controller(sc);
        }
    }
}