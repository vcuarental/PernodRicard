@isTest
public class MMPJ_XRM_LCR03_DisplayPicture_Test {
    
    @isTest
    private static void getLastImageApexTest(){
        Account vAccount = createaccount();
        ContentVersion vContentVersion = createContentVersion('MMPJ_XRM_photo_contact_Test');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink vContentDocumentLink = createContentDocumentLink(vAccount, documents[0]);
        
        System.AssertEquals(documents[0].Id, MMPJ_XRM_LCR03_DisplayPicture.getLastImageApex(vAccount.Id));        
    }
    
    @isTest
    public static void updateContentDocumentTitleApexTest() {
        Account vAccount = createaccount();
        ContentVersion vContentVersion = createContentVersion('Test');
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink vContentDocumentLink = createContentDocumentLink(vAccount, documents[0]);
        MMPJ_XRM_LCR03_DisplayPicture.updateContentDocumentTitleApex(documents[0].Id);
        
        System.AssertEquals(documents[0].Id, MMPJ_XRM_LCR03_DisplayPicture.getLastImageApex(vAccount.Id));
    }
    
    @isTest
    private static void deleteLastImageApexTest(){
        Account vAccount = createaccount();
        ContentVersion vContentVersion1 = createContentVersion('MMPJ_XRM_photo_contact_Test1');
        ContentVersion vContentVersion2 = createContentVersion('MMPJ_XRM_photo_contact_Test2');
        //we check if the last image linked to vAccount is not vContentVersion1
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument order by Title ASC];
        ContentDocumentLink vContentDocumentLink1 = createContentDocumentLink(vAccount, documents[0]);
        ContentDocumentLink vContentDocumentLink2 = createContentDocumentLink(vAccount, documents[1]);
        System.AssertNotEquals(documents[0].Id, MMPJ_XRM_LCR03_DisplayPicture.getLastImageApex(vAccount.Id));
        //we delete the last image and after we check if the last image linked to vAccount is now vContentVersion1
        MMPJ_XRM_LCR03_DisplayPicture.deleteLastImageApex(vAccount.Id);
        System.AssertEquals(documents[0].Id, MMPJ_XRM_LCR03_DisplayPicture.getLastImageApex(vAccount.Id));
        
    }
    
    //create Account  record 
    private static account createaccount(){ 
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        return acct;
    }
    
    //create ContentDocumentLink  record 
    private static ContentDocumentLink createContentDocumentLink(Account pAccount, ContentDocument pContentDocument){
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = pAccount.id;
        cdl.ContentDocumentId = pContentDocument.Id;
        cdl.shareType = 'V';
        insert cdl; 
        return cdl;
    }
    
    //create ContentVersion
    private static ContentVersion createContentVersion(String pTitle){
        ContentVersion vContentVersion = new ContentVersion(
            Title = pTitle,
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert vContentVersion;
        return vContentVersion;
    }
}