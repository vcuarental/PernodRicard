/**
 *
 * Unit tests for ESN_IDidIt_ConnectApiHelper.
 *
 * This class works with API version 32.0 and later.
 *
 *
 */

@IsTest
public class ESN_IDIDIT_ConnectApiHelper_Test {

    private static final Profile p = [SELECT Id FROM Profile WHERE Name='ESN SSO USER'];
    private static final User userTest = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='UserTestNew01234', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='UserTestNew01234@testorg.com');

    @IsTest(SeeAllData=true)
    static void testInvalidMentionType() {
        Boolean exceptionThrown = false;
        Account accountTest = new Account(Name = 'Test1230');
        insert accountTest;
        
        try {                     
            ContentVersion cv = new ContentVersion(); 
            cv.VersionData = Blob.valueOf('I am a file posting to Chatter');
            cv.PathOnClient='myFile.txt';
            cv.Title ='myFile'; 
            insert cv;
            ESN_IDIDIT_ConnectApiHelper.postFeedItemWithMentions(null, 'me', '{'+accountTest.Id+'}', cv); // not a group or user id
        }
        catch (ConnectApi.ConnectApiException e) {
            System.assertEquals('Only user and group IDs may be used in inline mentions.', e.getMessage());
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }
    
    @IsTest
    static void testNoMention() {
        Boolean exceptionThrown = false;
        try {
            ESN_IDIDIT_ConnectApiHelper.postFeedItemWithMentions(null, 'me', null, null); // not a group or user id
        }
        catch (ESN_IDIDIT_ConnectApiHelper.InvalidParameterException e) {
            System.assertEquals('The textWithMentions parameter must be non-empty.', e.getMessage());
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }

    @IsTest
    static void testNullString() {
        Boolean exceptionThrown = false;
        try {
            List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs(null);
        }
        catch (ESN_IDIDIT_ConnectApiHelper.InvalidParameterException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }

    @IsTest
    static void testEmptyString() {
        List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs('');
        System.assertEquals(0, segments.size());
    }

    @IsTest
    static void testNoMentions() {
        String text = 'hey there';
        List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs(text);
        
        System.assertEquals(1, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.TextSegmentInput);
        ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(0);
        System.assertEquals(text, textSegment.text);
    }

    @IsTest
    static void testMentionOnly() {
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        //User userTest = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='UserTestNew01234', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='UserTestNew01234@testorg.com');

        System.runAs(userTest) {
        String mentionId = userTest.Id;
        String text = '{' + mentionId + '}';
        List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs(text);
        
        System.assertEquals(1, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.MentionSegmentInput);
        ConnectApi.MentionSegmentInput mentionSegment = (ConnectApi.MentionSegmentInput) segments.get(0);
        System.assertEquals(mentionId, mentionSegment.id);
        }
    }

    @IsTest
    static void testLeadingMention() {
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        //User userTest = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='UserTestNew01234', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='UserTestNew01234@testorg.com');

        System.runAs(userTest) {
            String mentionId = userTest.Id;
            String restOfMessage = ' - how are you?';
            String text = '{' + mentionId + '}' + restOfMessage;
            List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs(text);
    
            System.assertEquals(2, segments.size());
            System.assert(segments.get(0) instanceof ConnectApi.MentionSegmentInput);
            System.assert(segments.get(1) instanceof ConnectApi.TextSegmentInput);
    
            ConnectApi.MentionSegmentInput mentionSegment = (ConnectApi.MentionSegmentInput) segments.get(0);
            System.assertEquals(mentionId, mentionSegment.id);
    
            ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(1);
            System.assertEquals(restOfMessage, textSegment.text);
        }
    }

    @IsTest
    static void testTrailingMention() {
        
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        //User userTest = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='UserTestNew01234', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='UserTestNew01234@testorg.com');

        System.runAs(userTest) {
            String restOfMessage = 'Here we go: ';
            String mentionId = userTest.Id;
            String text = restOfMessage + '{' + mentionId + '}';
            List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs(text);
    
            System.assertEquals(2, segments.size());
            System.assert(segments.get(0) instanceof ConnectApi.TextSegmentInput);
            System.assert(segments.get(1) instanceof ConnectApi.MentionSegmentInput);
    
            ConnectApi.TextSegmentInput textSegment = (ConnectApi.TextSegmentInput) segments.get(0);
            System.assertEquals(restOfMessage, textSegment.text);
    
            ConnectApi.MentionSegmentInput mentionSegment = (ConnectApi.MentionSegmentInput) segments.get(1);
            System.assertEquals(mentionId, mentionSegment.id);
        }
    }

    @IsTest
    static void testAdjacentMentions() {
        
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        //User userTest = new User(Alias = 'standt', Email='standarduser@testorg.com',EmailEncodingKey='UTF-8', LastName='UserTestNew01234', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='UserTestNew01234@testorg.com');

        System.runAs(userTest) {
            String mentionId = userTest.Id;
            //CollaborationGroup cg = new CollaborationGroup(Name='Test Group', CollaborationType='Public');
            CollaborationGroup cg = new CollaborationGroup(Name='TestGroupESN_IDIDIT', CollaborationType='Public');
            insert cg;
            String mentionId2 = cg.Id;
            String text = '{' + mentionId + '}' + '{' + mentionId2 + '}';
            List<ConnectApi.MessageSegmentInput> segments = ESN_IDIDIT_ConnectApiHelper.getMessageSegmentInputs(text);
    
            System.assertEquals(2, segments.size());
            System.assert(segments.get(0) instanceof ConnectApi.MentionSegmentInput);
            System.assert(segments.get(1) instanceof ConnectApi.MentionSegmentInput);
    
            ConnectApi.MentionSegmentInput mentionSegment = (ConnectApi.MentionSegmentInput) segments.get(0);
            System.assertEquals(mentionId, mentionSegment.id);
            
            ConnectApi.MentionSegmentInput mentionSegment2 = (ConnectApi.MentionSegmentInput) segments.get(1);
            System.assertEquals(mentionId2, mentionSegment2.id);
        }
    }

    @IsTest(SeeAllData=true)
    static void testLinkAndHashtagParsing() {
        // The test string is: #Yolo: http://salesforce.com, {005} {005x0000000URNPzzz} test.
        //                     [   ][][                   ][      ][                  ][    ]
        //                     0    1 2                    3       4                   5
        // 0 = hashtag
        // 1 = text1
        // 2 = link
        // 3 = text2
        // 4 = mention
        // 5 = text3
        
        String hashtag = 'Yolo';
        String text1 = ': ';
        String link = 'http://salesforce.com';
        String text2 = ', {005} ';
        String mentionId = UserInfo.getUserId();
        String text3 = ' test.';
        String text = '#' + hashtag + text1 + link + text2 + '{' + mentionId + '}' + text3;

        ContentVersion cv = new ContentVersion(); 
        cv.VersionData = Blob.valueOf('I am a file posting to Chatter');
        cv.PathOnClient='myFile.txt';
        cv.Title ='myFile'; 
        insert cv;
        ConnectApi.FeedElement fi = ESN_IDIDIT_ConnectApiHelper.postFeedItemWithMentions(null, 'me', text, cv);
        
        List<ConnectApi.MessageSegment> segments = fi.body.messageSegments;

        System.assertEquals(6, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.HashtagSegment);
        System.assert(segments.get(1) instanceof ConnectApi.TextSegment);
        System.assert(segments.get(2) instanceof ConnectApi.LinkSegment);
        System.assert(segments.get(3) instanceof ConnectApi.TextSegment);
        System.assert(segments.get(4) instanceof ConnectApi.MentionSegment);
        System.assert(segments.get(5) instanceof ConnectApi.TextSegment);

        ConnectApi.HashtagSegment hashtagSegment = (ConnectApi.HashtagSegment) segments.get(0);
        System.assertEquals(hashtag, hashtagSegment.tag);

        ConnectApi.TextSegment textSegment1 = (ConnectApi.TextSegment) segments.get(1);
        System.assertEquals(text1, textSegment1.text);

        ConnectApi.LinkSegment linkSegment = (ConnectApi.LinkSegment) segments.get(2);
        System.assertEquals(link, linkSegment.url);

        ConnectApi.TextSegment textSegment2 = (ConnectApi.TextSegment) segments.get(3);
        System.assertEquals(text2, textSegment2.text);

        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segments.get(4);
        System.assertEquals(mentionId, mentionSegment.record.id);
        
        ConnectApi.TextSegment textSegment3 = (ConnectApi.TextSegment) segments.get(5);
        System.assertEquals(text3, textSegment3.text);
    }

    @IsTest(SeeAllData=true)
    static void testMentionInComment() {
        ConnectApi.FeedElement fi = ConnectApi.ChatterFeeds.postFeedElement(null, 'me', ConnectApi.FeedElementType.FeedItem, 'hi');
        String mentionId = UserInfo.getUserId();
        String text = '{' + mentionId + '}';
        ConnectApi.Comment comment = ESN_IDIDIT_ConnectApiHelper.postCommentWithMentions(null, fi.id, text);

        List<ConnectApi.MessageSegment> segments = comment.body.messageSegments;
        System.assertEquals(1, segments.size());
        System.assert(segments.get(0) instanceof ConnectApi.MentionSegment);
        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) segments.get(0);
        System.assertEquals(mentionId, mentionSegment.record.id);
    }
    
    @IsTest(SeeAllData=true)
    static void testNoMentionInComment() {
        Boolean exceptionThrown = false;
        ConnectApi.FeedElement fi = ConnectApi.ChatterFeeds.postFeedElement(null, 'me', ConnectApi.FeedElementType.FeedItem, 'hi');
        String mentionId = UserInfo.getUserId();
        String text = '{' + mentionId + '}';
        try {
            ConnectApi.Comment comment = ESN_IDIDIT_ConnectApiHelper.postCommentWithMentions(null, fi.id, null);
        }
        catch (ESN_IDIDIT_ConnectApiHelper.InvalidParameterException e) {
            System.assertEquals('The textWithMentions parameter must be non-empty.', e.getMessage());
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }

}