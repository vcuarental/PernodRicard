/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ESN_DRUPAL_MB_ShareOnChatter_Test {

	@IsTest(SeeAllData=true)
    static void shareWithMyFollowers() {
        Test.startTest();
        
		PageReference pageRef = new PageReference('/apex/ESN_DRUPAL_MB_ShareOnChatter');
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Title', 'Article to share on Chatter');
		ApexPages.currentPage().getParameters().put('Link', 'http://www.google.fr');
        ApexPages.currentPage().getParameters().put('Thumbnail', 'https://mybrands.pernod-ricard.com/files/temporary/unmanaged/f676f218d99bb7b7daf6474969f49e70/private/styles/content_list/private/pr-media-browser/EOY15_Absolut_Electrik_GTR_Guideline.jpg');
		
		Test.setMock(HttpCalloutMock.class, new ESN_DRUPAL_MB_HttpCalloutMockImpl());
        ESN_DRUPAL_MB_ShareOnChatter controller = new ESN_DRUPAL_MB_ShareOnChatter();
        controller.selectedTo = 'My Followers';
    	controller.message = 'Ceci est un test @['+UserInfo.getName()+']';
        controller.getShareTo();
        controller.getGroups();
        controller.shareOnChatter();
        
		Test.stopTest();
    }
    
    @IsTest(SeeAllData=true)
    static void shareWithAGroup() {
        Test.startTest();
		
		List<CollaborationGroup> group_List = [SELECT Id, Name FROM CollaborationGroup WHERE Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:UserInfo.getUserId()) LIMIT 1];
        PageReference pageRef = new PageReference('/apex/ESN_DRUPAL_MB_ShareOnChatter');
        Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('Title', 'Article to share on Chatter');
		ApexPages.currentPage().getParameters().put('Link', 'http://www.google.fr');
        ApexPages.currentPage().getParameters().put('Thumbnail', 'https://mybrands.pernod-ricard.com/files/temporary/unmanaged/f676f218d99bb7b7daf6474969f49e70/private/styles/content_list/private/pr-media-browser/EOY15_Absolut_Electrik_GTR_Guideline.jpg');

		Test.setMock(HttpCalloutMock.class, new ESN_DRUPAL_MB_HttpCalloutMockImpl());
		ESN_DRUPAL_MB_ShareOnChatter controller = new ESN_DRUPAL_MB_ShareOnChatter();
        controller.selectedTo = 'A Group';
        controller.selectedGroup = group_List[0].Id;
    	controller.message = 'Ceci est un test @['+group_List[0].Id+']';
        controller.shareOnChatter();

		Test.stopTest();
    }

    @IsTest(SeeAllData=true)
    static void errorMissingParameters() {
        PageReference pageRef = new PageReference('/apex/ESN_DRUPAL_MB_ShareOnChatter');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Title', 'Article to share on Chatter');
		ApexPages.currentPage().getParameters().put('Link', 'http://www.google.fr');
        ApexPages.currentPage().getParameters().put('Thumbnail', '');
        
        ESN_DRUPAL_MB_ShareOnChatter controller = new ESN_DRUPAL_MB_ShareOnChatter();
    }
}