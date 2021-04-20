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
private class ESN_chatterDAM_DamApiCallout_Test {

    private static String ASSET_ID = '123456789';
    private static String ASSET_MIDRES_URL = '/servlet/file/153932_66_preview.jpg?ITEM_ENT_ID=153932&COLLSPEC_ENT_ID=6&ITEM_VERSION=3&FILE_SERVICE_CONF_ID=66';

    static testMethod void authenticationTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ESN_chatterDAM_HttpCalloutMockImpl());
        List<String> sessionList = ESN_chatterDAM_DamApiCallout.authentication();
        Test.stopTest();

        System.assertEquals('6E6E91CE0B7A5F2E6CE87D17DF05B5A5', sessionList[0]);
        System.assertEquals('D=6E6E91CE0B7A5F2E6CE87D17DF05B5A5', sessionList[1]);
    }

    static testMethod void getAssetDataTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ESN_chatterDAM_HttpCalloutMockImpl());
        List<String> assetMetadata = ESN_chatterDAM_DamApiCallout.getAssetData(ASSET_ID, null);
        Test.stopTest();
        
        System.assertEquals('Ballantine\'s 12 Key visual _ Portrait.jpg', assetMetadata[0]);
        System.assertEquals('/servlet/file/153932_1_preview.jpg?ITEM_ENT_ID=153932&COLLSPEC_ENT_ID=6&ITEM_VERSION=3&FILE_SERVICE_CONF_ID=1', assetMetadata[1]);
        System.assertEquals('/servlet/file/153932_66_preview.jpg?ITEM_ENT_ID=153932&COLLSPEC_ENT_ID=6&ITEM_VERSION=3&FILE_SERVICE_CONF_ID=66', assetMetadata[2]);        
    }
   
   	static testMethod void encodeAsset_MidResTest() {
   		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ESN_chatterDAM_HttpCalloutMockImpl());
        blob asset_MidRes_Encoded = ESN_chatterDAM_DamApiCallout.encodeAsset_MidRes(ASSET_MIDRES_URL, null);
        Test.stopTest();
        
        System.assertEquals(ASSET_MIDRES_URL, asset_MidRes_Encoded.toString());
   	}
}