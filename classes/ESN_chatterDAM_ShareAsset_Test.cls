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
private class ESN_chatterDAM_ShareAsset_Test {

	@IsTest(SeeAllData=true)
    static void shareWithMyFollowers() {
        PageReference pageRef = new PageReference('/apex/ESN_chatterDAM');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('AssetId', 'https://absolut-brandcloud.pernod-ricard.com/files/asset/item123456789/');
        
        Test.setMock(HttpCalloutMock.class, new ESN_chatterDAM_HttpCalloutMockImpl());
        ESN_chatterDAM_ShareAsset controller = new ESN_chatterDAM_ShareAsset();
        controller.selectedTo = 'My Followers';
    	controller.message = 'Ceci est un test @['+UserInfo.getName()+']';
        controller.getShareTo();
        controller.getGroups();
        controller.postAssetOnChatter();
    }
    
    @IsTest(SeeAllData=true)
    static void shareWithAGroup() {
        List<CollaborationGroup> group_List = [SELECT Id, Name FROM CollaborationGroup WHERE Id IN (SELECT CollaborationGroupId FROM CollaborationGroupMember WHERE MemberId=:UserInfo.getUserId()) LIMIT 1];
        PageReference pageRef = new PageReference('/apex/ESN_chatterDAM');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('AssetId', 'https://absolut-brandcloud.pernod-ricard.com/files/asset/item123456789/');
        
        Test.setMock(HttpCalloutMock.class, new ESN_chatterDAM_HttpCalloutMockImpl());
        ESN_chatterDAM_ShareAsset controller = new ESN_chatterDAM_ShareAsset();
        controller.selectedTo = 'A Group';
        controller.selectedGroup = group_List[0].Id;
    	controller.message = 'Ceci est un test @['+group_List[0].Id+']';
        controller.postAssetOnChatter();
    }
    
    @IsTest(SeeAllData=true)
    static void assetDataNotFound() {
        PageReference pageRef = new PageReference('/apex/ESN_chatterDAM');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('AssetId', '');
        
        Test.setMock(HttpCalloutMock.class, new ESN_chatterDAM_HttpCalloutMockImpl());
        ESN_chatterDAM_ShareAsset controller = new ESN_chatterDAM_ShareAsset();
        controller.selectedTo = 'My Followers';
    	controller.message = 'Ceci est un test';
        controller.postAssetOnChatter();
    }
}