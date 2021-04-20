@isTest
private class ESN_IDIDIT_Report_Test {

    private static final List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name=:Label.ESN_IDIDIT_ChatterGroupName LIMIT 1];
    private static final Profile p = [SELECT Id FROM Profile WHERE Name='ESN SSO USER'];
    private static final User user = new User(Alias='TestUser', Title='AdminTest', Email='testUser@test.fr', EmailEncodingKey='ISO-8859-1', LastName='TestUser', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId=p.Id, TimeZoneSidKey='Europe/Paris', UserName='testUser@pr.test.fr', CompanyName='Test');

    
    @IsTest(SeeAllData=true)   
    static void textWithoutMentions() {
        //Profile p = [SELECT Id FROM Profile WHERE Name='ESN SSO USER'];
        //User user = new User(Alias='TestUser', Title='AdminTest', Email='testUser@test.fr', EmailEncodingKey='ISO-8859-1', LastName='TestUser', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId=p.Id, TimeZoneSidKey='Europe/Paris', UserName='testUser@pr.test.fr', CompanyName='Test');
        //insert user;
        
        // Build a simple feed item page
        ConnectApi.FeedItemPage result = new ConnectApi.FeedItemPage();
        List<ConnectApi.FeedItem> feedItemList = new List<ConnectApi.FeedItem>();
        ConnectApi.FeedItem feedItem = new ConnectApi.FeedItem();
        
        // Construct data
        ConnectApi.UserDetail userDetail = new ConnectApi.UserDetail();
        userDetail.Email = 'pr@test.fr';
        userDetail.CompanyName = 'Company';
        userDetail.Id = user.Id;
        
        ConnectApi.FeedBody feedBody = new ConnectApi.FeedBody();
        ConnectApi.MessageSegment testSegment = new ConnectApi.TextSegment();
        //a modifier en rajoutant 'test'
        //testSegment.text = Label.ESN_IDIDIT_PostMsg1 + ' ' + '10' + ' ' + Label.ESN_IDIDIT_PostMsg2;
        testSegment.text = '';
        List<ConnectApi.MessageSegment> testSegments = new List<ConnectApi.MessageSegment>();
        testSegments.add(testSegment);
        feedBody.messageSegments = testSegments;
        
        // Set values
        feedItem.createdDate = DateTime.now();
        feedItem.actor = userDetail;
        feedItem.body = feedBody;
        feedItem.body.text = testSegment.text;
        
        // Add FeedItem to list
        feedItemList.add(feedItem);        
        
        // Set the test data
        String communityId = null;
        ConnectApi.feedType feedType = ConnectApi.FeedType.Record;
        String subjectId = chatterGroup[0].Id;
        String pageParam = null;
        Integer pageSize = 100;
        ConnectApi.FeedSortOrder sortParam = ConnectApi.FeedSortOrder.CreatedDateDesc;
        result.items = feedItemList;
        
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed(communityId, feedType, subjectId, pageParam, pageSize, sortParam, result);
        
        // Instantiate and construct an instance of ESN_IDidIt_Report
        ESN_IDIDIT_Report controller = new ESN_IDIDIT_Report();
        controller.displayRecords();
        controller.getResult();
        controller.exportToExcel();
    }
    
    @IsTest(SeeAllData=true)    
    static void textWithMentions1() {
        //Profile p = [SELECT Id FROM Profile WHERE Name='ESN SSO USER'];
        //User user = new User(Alias='TestUser', Title='AdminTest', Email='testUser@test.fr', EmailEncodingKey='ISO-8859-1', LastName='TestUser', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId=p.Id, TimeZoneSidKey='Europe/Paris', UserName='testUser@pr.test.fr', CompanyName='Test');
        //insert user;
        
        // Build a simple feed item page
        ConnectApi.FeedItemPage result = new ConnectApi.FeedItemPage();
        List<ConnectApi.FeedItem> feedItemList = new List<ConnectApi.FeedItem>();
        ConnectApi.FeedItem feedItem = new ConnectApi.FeedItem();
        
        // Construct data
        ConnectApi.UserDetail userDetail = new ConnectApi.UserDetail();
        userDetail.Email = 'pr@test.fr';
        userDetail.CompanyName = 'Company';
        userDetail.Id = user.Id;
        
        ConnectApi.FeedBody feedBody = new ConnectApi.FeedBody();
        ConnectApi.MessageSegment testSegment = new ConnectApi.TextSegment();
        //testSegment.text = Label.ESN_IDIDIT_PostMsg2 + '\n\n' + 'text' + '\n\n' + '@' + Label.ESN_IDIDIT_ChatterGroupName;
        //on enleve le label postmsg2
        testSegment.text = 'text' + '\n\n' + '@' + Label.ESN_IDIDIT_ChatterGroupName;

        List<ConnectApi.MessageSegment> testSegments = new List<ConnectApi.MessageSegment>();
        testSegments.add(testSegment);
        feedBody.messageSegments = testSegments;
        
        // Set values
        feedItem.createdDate = DateTime.now();
        feedItem.actor = userDetail;
        feedItem.body = feedBody;
        feedItem.body.text = testSegment.text;
        
        // Add FeedItem to list
        feedItemList.add(feedItem);        
        
        // Set the test data
        String communityId = null;
        ConnectApi.feedType feedType = ConnectApi.FeedType.Record;
        String subjectId = chatterGroup[0].Id;
        String pageParam = null;
        Integer pageSize = 100;
        ConnectApi.FeedSortOrder sortParam = ConnectApi.FeedSortOrder.CreatedDateDesc;
        result.items = feedItemList;
        
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed(communityId, feedType, subjectId, pageParam, pageSize, sortParam, result);
        
        // Instantiate and construct an instance of ESN_IDidIt_Report
        ESN_IDIDIT_Report controller = new ESN_IDIDIT_Report();
        controller.displayRecords();
    }
    
    @IsTest(SeeAllData=true)   
    static void textWithMentions2() {
        //Profile p = [SELECT Id FROM Profile WHERE Name='ESN SSO USER'];
        //User user = new User(Alias='TestUser', Title='AdminTest', Email='testUser@test.fr', EmailEncodingKey='ISO-8859-1', LastName='TestUser', LanguageLocaleKey='fr', LocaleSidKey='fr_FR_EURO', ProfileId=p.Id, TimeZoneSidKey='Europe/Paris', UserName='testUser@pr.test.fr', CompanyName='Test');
        //insert user;
        
        // Build a simple feed item page
        ConnectApi.FeedItemPage result = new ConnectApi.FeedItemPage();
        List<ConnectApi.FeedItem> feedItemList = new List<ConnectApi.FeedItem>();
        ConnectApi.FeedItem feedItem = new ConnectApi.FeedItem();
        
        // Construct data
        ConnectApi.UserDetail userDetail = new ConnectApi.UserDetail();
        userDetail.Email = 'pr@test.fr';
        userDetail.CompanyName = 'Company';
        userDetail.Id = user.Id;
        
        ConnectApi.FeedBody feedBody = new ConnectApi.FeedBody();
        ConnectApi.MessageSegment testSegment = new ConnectApi.TextSegment();
        testSegment.text = 'text' + '$';
        List<ConnectApi.MessageSegment> testSegments = new List<ConnectApi.MessageSegment>();
        testSegments.add(testSegment);
        feedBody.messageSegments = testSegments;
        
        // Set values
        feedItem.createdDate = DateTime.now();
        feedItem.actor = userDetail;
        feedItem.body = feedBody;
        feedItem.body.text = testSegment.text;
        
        // Add FeedItem to list
        feedItemList.add(feedItem);        
        
        // Set the test data
        String communityId = null;
        ConnectApi.feedType feedType = ConnectApi.FeedType.Record;
        String subjectId = chatterGroup[0].Id;
        String pageParam = null;
        Integer pageSize = 100;
        ConnectApi.FeedSortOrder sortParam = ConnectApi.FeedSortOrder.CreatedDateDesc;
        result.items = feedItemList;
        
        ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed(communityId, feedType, subjectId, pageParam, pageSize, sortParam, result);
        
        // Instantiate and construct an instance of ESN_IDidIt_Report
        ESN_IDIDIT_Report controller = new ESN_IDIDIT_Report();
        controller.displayRecords();
    }
}