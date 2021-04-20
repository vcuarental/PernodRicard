@isTest
public class CorbyScrbdChatterFeedController_CA_Test{
    @isTest
        static void doTest(){
            //create some test properties for testing ConnectApi classes. We'll start with 3 feed items so we can
            //test some different attachment types
            final String FEED_ITEM_1_ID = 'feedItemOneId'; 
            final String FEED_ITEM_2_ID = 'feedItemTwoId';
            final String FEED_ITEM_3_ID = 'feedItemThreeId';
            final String LIKE_ID = 'theLikeId';
            //the following variable will need to be changed to 0F9D0000000UGqS prior to production move
            final String SCOREBOARD_GROUP_ID = '0F9d00000000fJc';
            final String SCOREBOARD_GROUP_NM = 'Canada - Corby Scorecard';
            final String USER_ID = 'theUserId';
            final String USER_NM = 'theUserName';
            final String CONTENT_DWNLD_URL = '/sfc/servlet.shepherd/version/download/1.0?asPdf=false&operationContext=CHATTER';
            
            //Instantiate and construct an instance of CorbyScrbdChatterFeed_CA
            CorbyScrbdChatterFeedController_CA controller = new CorbyScrbdChatterFeedController_CA();
            System.assertEquals(null, controller.refreshFeed());
            
            //Instantiate and construct an instance of CorbyScrbdChatterFeedExtension_CA.   
            CorbyScrbdChatterFeedExtension_CA controllerExt = new CorbyScrbdChatterFeedExtension_CA(controller); 
            
            //set the controller extension class variables and assert that the getters return the expected values
            controllerExt.setFeedItemId(FEED_ITEM_1_ID);
            System.assertEquals(FEED_ITEM_1_ID, controllerExt.getFeedItemId());
            
            controllerExt.setLikeId(LIKE_ID);
            System.assertEquals(LIKE_ID, controllerExt.getLikeId());
            controllerExt.addLikeToFeedItem();
            controllerExt.removeLikeFromFeedItem();
            
            controllerExt.setCommentToAdd('Test comment.');
            System.assertEquals('Test comment.', controllerExt.getCommentToAdd());
            controllerExt.addCommentToFeedItem();
            
            controllerExt.setPollChoicePosition(1);
            System.assertEquals(1, controllerExt.getPollChoicePosition());
            controllerExt.addVoteToFeedItemPoll();
            
            
            //Build a simple feed item page
            ConnectApi.FeedItemPage testPage = new ConnectApi.FeedItemPage();
            List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
            //Create the first feed item
            ConnectApi.FeedItem testFeedItemOne = new ConnectApi.FeedItem();
            testFeedItemOne.id = FEED_ITEM_1_ID;
            testFeedItemOne.relativeCreatedDate = 'Just now.';
            testFeedItemOne.actor = new ConnectApi.UserSummary();
            ((ConnectApi.User)testFeedItemOne.actor).name = 'theFeedItemUserName';
            ((ConnectApi.User)testFeedItemOne.actor).id = 'theFeedItemUserId';
            ConnectApi.FeedBody testFeedBodyOne = new ConnectApi.FeedBody();
            //add a few different types of MessageSegments to the feed body
            List<ConnectApi.MessageSegment> testSegmentsOne = new List<ConnectApi.MessageSegment>();
            ConnectApi.TextSegment testTextSegmentOne = new ConnectApi.TextSegment();
            testTextSegmentOne.text = 'This is the feedBody of feedItemOne.';
            testSegmentsOne.add(testTextSegmentOne);
            ConnectApi.MentionSegment testMentionSegment = new ConnectApi.MentionSegment();
            testMentionSegment.user = new ConnectApi.UserSummary();
            testMentionSegment.user.name = 'testMentionUserName';
            testMentionSegment.user.id = 'testMentionUserId';
            testSegmentsOne.add(testMentionSegment);
            ConnectApi.HashtagSegment testHashtagSegment = new ConnectApi.HashtagSegment();
            testHashtagSegment.tag = 'theHashTag';
            testSegmentsOne.add(testHashtagSegment);
            ConnectApi.LinkSegment testLinkSegment = new ConnectApi.LinkSegment();
            testLinkSegment.url = 'http://www.theLinkSegmentUrl.com';
            testSegmentsOne.add(testLinkSegment);
            testFeedBodyOne.messageSegments = testSegmentsOne;
            testFeedItemOne.body = testFeedBodyOne;
            //create a Like and add it to the feedItem
            ConnectApi.ChatterLikePage testLikePage = new ConnectApi.ChatterLikePage();
            List<ConnectApi.ChatterLike> testLikes = new List<ConnectApi.ChatterLike>();
            ConnectApi.ChatterLike testLike =  new ConnectApi.ChatterLike();
            ConnectApi.Reference testMyLikeRef = new ConnectApi.Reference();
            ConnectApi.Reference testFeedItemRef = new ConnectApi.Reference();
            testMyLikeRef.id = LIKE_ID;
            testLike.id = LIKE_ID;
            testFeedItemRef.id = LIKE_ID;
            testLike.likedItem = testFeedItemRef;
            testLikes.add(testlike);
            testLikePage.likes = testLikes;
            testFeedItemOne.likes = testLikePage;
            testFeedItemOne.isLikedByCurrentUser = true;
            testFeedItemOne.myLike = testMyLikeRef;
            ConnectApi.MessageBody testLikesMessage = new ConnectApi.MessageBody();
            testLikesMessage.text = 'You like this.';
            testFeedItemOne.likesMessage = testLikesMessage;
            
            //create a comment and add it to the feedItem
            ConnectApi.Comment testComment = new ConnectApi.Comment();
            ConnectApi.FeedBody testCommentBody = new ConnectApi.FeedBody();
            List<ConnectApi.MessageSegment> testCommentSegments = new List<ConnectApi.MessageSegment>();
            ConnectApi.MessageSegment testCommentSegment = new ConnectApi.TextSegment();
            testCommentSegment.text = 'This is the comment feedBody.';
            testCommentSegments.add(testCommentSegment);
            testCommentBody.messageSegments = testCommentSegments;
            testComment.body = testCommentBody;
            testComment.user = new ConnectApi.UserSummary();
            testComment.user.name = 'testCommentUser';
            testComment.user.id = 'testCommentUserId';
            testComment.relativeCreatedDate = '1 minute ago.';
            //create a content attachment for the comment
            ConnectApi.ContentAttachment testCmtAtmt = new ConnectApi.ContentAttachment();
            testCmtAtmt.renditionUrl = 'http://www.theCommentContent.com';
            testCmtAtmt.description = 'theCommentContentDescription';
            testCmtAtmt.title = 'theCommentContentTitle';
            testCmtAtmt.hasImagePreview = false;
            testCmtAtmt.versionId = '1.0';
            testComment.attachment = testCmtAtmt;
            //create the comment page and add our comment to it
            ConnectApi.CommentPage testCommentPage = new ConnectApi.CommentPage();
            List<ConnectApi.Comment> testComments = new List<ConnectApi.Comment>();
            testComments.add(testComment);
            testCommentPage.comments = testComments;
            testFeedItemOne.comments = testCommentPage;
            
            //create the Second feed item
            ConnectApi.FeedItem testFeedItemTwo = new ConnectApi.FeedItem();
            testFeedItemTwo.id = FEED_ITEM_2_ID;
            testFeedItemTwo.relativeCreatedDate = 'One minute ago.';
            testFeedItemTwo.actor = new ConnectApi.UserSummary();
            ((ConnectApi.User)testFeedItemTwo.actor).name = 'theFeedItem2UserName';
            ((ConnectApi.User)testFeedItemTwo.actor).id = 'theFeedItem2UserId';
            ConnectApi.FeedBody testFeedBodyTwo = new ConnectApi.FeedBody();
            //add something to the feed body of feed item 2 
            List<ConnectApi.MessageSegment> testSegmentsTwo = new List<ConnectApi.MessageSegment>();
            ConnectApi.TextSegment testTextSegmentTwo = new ConnectApi.TextSegment();
            testTextSegmentTwo.text = 'This is the feedBody of feedItemTwo.';
            testSegmentsTwo.add(testTextSegmentTwo);
            testFeedBodyTwo.messageSegments = testSegmentsTwo;
            testFeedItemTwo.body = testFeedBodyTwo;
            
            //create the Third feedItem
            ConnectApi.FeedItem testFeedItemThree = new ConnectApi.FeedItem();
            testFeedItemThree.id = FEED_ITEM_3_ID;
            testFeedItemThree.relativeCreatedDate = 'Two minutes ago.';
            testFeedItemThree.actor = new ConnectApi.UserSummary();
            ((ConnectApi.User)testFeedItemThree.actor).name = 'theFeedItem3UserName';
            ((ConnectApi.User)testFeedItemThree.actor).id = 'theFeedItem3UserId';
            ConnectApi.FeedBody testFeedBodyThree = new ConnectApi.FeedBody();
            //add something to the feed body of feed item 3 
            List<ConnectApi.MessageSegment> testSegmentsThree = new List<ConnectApi.MessageSegment>();
            ConnectApi.TextSegment testTextSegmentThree = new ConnectApi.TextSegment();
            testTextSegmentThree.text = 'This is the feedBody of feedItemThree. Is there a poll attached?';
            testSegmentsThree.add(testTextSegmentThree);
            testFeedBodyThree.messageSegments = testSegmentsThree;
            testFeedItemThree.body = testFeedBodyThree;
            
            //create a CommentInfo item from the comment above
            CommentInfo_CA testCommentInfo = new CommentInfo_CA(testComment);
            
            //create a chatterGroup page
            ConnectApi.ChatterGroupPage testChatterGrpPg = new ConnectApi.ChatterGroupPage();
            List<ConnectApi.ChatterGroupDetail> testGroups = new List<ConnectApi.ChatterGroupDetail>();
            ConnectApi.ChatterGroupDetail testGroup =  new ConnectApi.ChatterGroupDetail();
            testGroup.id = SCOREBOARD_GROUP_ID;
            testGroup.name = SCOREBOARD_GROUP_NM;
            testGroups.add(testGroup);
            testChatterGrpPg.groups = testGroups;
            
            //create a parent feedItem for our testFeedItems
            testFeedItemOne.parent = testChatterGrpPg.groups[0];
            testFeedItemOne.parent.motif = new ConnectApi.Motif();
            testFeedItemOne.parent.motif.smallIconUrl = 'http://www.smallicon.com/icon.jpg';
            testFeedItemTwo.parent = testChatterGrpPg.groups[0];
            testFeedItemTwo.parent.motif = new ConnectApi.Motif();
            testFeedItemTwo.parent.motif.smallIconUrl = 'http://www.smallicon.com/icon.jpg';
            testFeedItemThree.parent = testChatterGrpPg.groups[0];
            testFeedItemThree.parent.motif = new ConnectApi.Motif();
            testFeedItemThree.parent.motif.smallIconUrl = 'http://www.smallicon.com/icon.jpg';
            
            //create a content attachment for our first FeedItem
            ConnectApi.ContentAttachment testContentAttachment = new ConnectApi.ContentAttachment();
            testContentAttachment.renditionUrl = 'http://www.theRenditionUrl.com';
            testContentAttachment.description = 'theAttachmentDescription';
            testContentAttachment.title = 'theAttachmentTitle';
            testContentAttachment.hasImagePreview = false;
            testContentAttachment.versionId = '1.0';
            testFeedItemOne.attachment = testContentAttachment;
            
            //create a link attachment for our second FeedItem
            ConnectApi.LinkAttachment testLinkAttachment = new ConnectApi.LinkAttachment();
            testLinkAttachment.title = 'theLinkAttachmentTitle';
            testLinkAttachment.url = 'http://www.theLinkAttachmentUrl.com';
            testFeedItemTwo.attachment = testLinkAttachment;
            
            //create a feed poll for our third FeedItem
            ConnectApi.FeedPoll testFeedPoll = new ConnectApi.FeedPoll();
            List<ConnectApi.FeedPollChoice> testChoices = new List<ConnectApi.FeedPollChoice>();
            ConnectApi.FeedPollChoice testPollChoiceOne = new ConnectApi.FeedPollChoice();
            testPollChoiceOne.position = 0;
            testPollChoiceOne.id = 'testChoiceOneId';
            testPollChoiceOne.text = 'Yes';
            testPollChoiceOne.voteCount = 0;
            testPollChoiceOne.voteCountRatio = 0.0;
            ConnectApi.FeedPollChoice testPollChoiceTwo = new ConnectApi.FeedPollChoice();
            testPollChoiceTwo.position = 1;
            testPollChoiceTwo.id = 'testChoiceTwoId';
            testPollChoiceTwo.text = 'No';
            testPollChoiceTwo.voteCount = 0;
            testPollChoiceTwo.voteCountRatio = 0.0;
            testChoices.add(testPollChoiceOne);
            testChoices.add(testPollChoiceTwo);
            testFeedPoll.choices = testChoices;
            testFeedItemThree.attachment = testFeedPoll;
            
            testItemList.add(testFeedItemOne);
            testItemList.add(testFeedItemTwo);
            testItemList.add(testFeedItemThree);
            testPage.items = testItemList;
            
            // Set the test data
            ConnectApi.ChatterGroups.setTestSearchGroups(null, 'Canada - Corby Scoreboard', null, 1, testChatterGrpPg);
            ConnectApi.ChatterFeeds.setTestGetFeedItemsFromFeed(null, ConnectApi.FeedType.Record, SCOREBOARD_GROUP_ID, testPage);
            
            // The method returns the test page, which we know has one item in it.
            // Test the size is correct and then test the attributes of the feed item
            Test.startTest();
                //test the FeedItemInfo_CA object
                List<FeedItemInfo_CA> testFeedItemInfoList = CorbyScrbdChatterFeedController_CA.getNewsFeedForDisplay();
                System.assertEquals(3, testFeedItemInfoList.size());
                System.assertEquals(FEED_ITEM_1_ID, testFeedItemInfoList[0].getFeedItemId());
                System.assertEquals(FEED_ITEM_1_ID, testFeedItemInfoList[0].getFeedItem().id);
                System.assertEquals('theFeedItemUserId', testFeedItemInfoList[0].getUserId());
                System.assertEquals('theFeedItemUserName', testFeedItemInfoList[0].getUserName());
                System.assertEquals('This is the feedBody of feedItemOne. <a href="/testMentionUserId" style="color:#015ba7;text-decoration:none;" onmouseover="this.style.textDecoration = \'underline\'" onmouseout="this.style.textDecoration = \'none\'">@testMentionUserName</a>  <a href="/_ui/core/chatter/topics/TopicPage?name=theHashTag&ref=hash_mention" style="color:#015ba7;text-decoration:none;" onmouseover="this.style.textDecoration = \'underline\'" onmouseout="this.style.textDecoration = \'none\'">#theHashTag</a>  <a href="http://www.theLinkSegmentUrl.com">http://www.theLinkSegmentUrl.com</a> ', testFeedItemInfoList[0].getFormattedtext());
                System.assertEquals(SCOREBOARD_GROUP_ID, testFeedItemInfoList[0].getFeedItemParentId());
                System.assertEquals(SCOREBOARD_GROUP_NM, testFeedItemInfoList[0].getFeedItemParentName());
                System.assertEquals('http://www.smallicon.com/icon.jpg', testFeedItemInfoList[0].getFeedItemParentSmallIconUrl());
                System.assertEquals(LIKE_ID, testFeedItemInfoList[0].getMyLikeId());
                System.assertEquals('Just now.', testFeedItemInfoList[0].getRelativeCreatedDate());
                System.assertEquals('You like this.', testFeedItemInfoList[0].getLikesMessage());
                System.assertEquals('http://www.theRenditionUrl.com', testFeedItemInfoList[0].getImageUrl());
                System.assertEquals('theAttachmentDescription', testFeedItemInfoList[0].getContentDescription());
                System.assertEquals('theAttachmentTitle', testFeedItemInfoList[0].getContentTitle());
                System.assertEquals(false, testFeedItemInfoList[0].getHasImagePreview());
                System.assertEquals('1.0', testFeedItemInfoList[0].getContentId());
                System.assertEquals(CONTENT_DWNLD_URL, testFeedItemInfoList[0].getContentDownloadUrl());
                System.assertEquals(0, testFeedItemInfoList[0].getCommentCount());
                //test the CommentInfo object
                System.assertequals('This is the comment feedBody.', testCommentInfo.getComment().body.messageSegments[0].text);
                System.assertEquals('testCommentUser', testCommentInfo.getUserName());
                System.assertEquals('testCommentUserId', testCommentInfo.getUserId());
                System.assertEquals('http://www.theCommentContent.com', testCommentInfo.getImageUrl());
                System.assertequals('This is the comment feedBody.', testCommentInfo.getFormattedText());
                System.assertEquals('theCommentContentDescription', testCommentInfo.getContentDescription());
                System.assertEquals('theCommentContentTitle', testCommentInfo.getContentTitle());
                System.assertEquals(false, testCommentInfo.getHasImagePreview());
                System.assertEquals('1 minute ago.', testCommentInfo.getRelativeCreatedDate());
                System.assertEquals('1.0', testCommentInfo.getContentId());
                System.assertEquals('/sfc/servlet.shepherd/version/download/1.0?asPdf=false&operationContext=CHATTER', testCommentInfo.getContentDownloadUrl());
                System.assertEquals('theLinkAttachmentTitle', testFeedItemInfoList[1].getLinkTitle());
                System.assertEquals('http://www.theLinkAttachmentUrl.com', testFeedItemInfoList[1].getLinkUrl());
                System.assertEquals(2, testFeedItemInfoList[2].getNumChoices());
                System.assertEquals(2, testFeedItemInfoList[2].getPoll().choices.size());
            Test.stopTest();
        }
}