/**
    *  Class for asserting controller behavior
	*
    *  @author:  PZ - Customertimes Corp.
    *  @created: 21.08.18
    *  @version: 1.0
 */
@isTest
private class EUR_CRM_Test_SalesOrderController {
    
    private static final String FILE_NAME = 'Logo_email';
    
    @isTest
    private static void testGetDocumentRelativeLink(){
        
        Document logo = new Document();
        logo.Body = Blob.valueOf('Some Text');
        logo.ContentType = 'application/pdf';
        logo.DeveloperName = FILE_NAME;
        logo.IsPublic = true;
        logo.Name = FILE_NAME;
        logo.FolderId = UserInfo.getUserId();
        
        insert logo;
        
        System.Test.startTest();
        EUR_CRM_SalesOrderController soc = new EUR_CRM_SalesOrderController();
        soc.fileName = FILE_NAME;
        try{
            soc.getDocumentRelativeLink();
            System.assert(true,'Should not fail');
        } catch(Exception ex){
            System.assert(false,'Should not fail');
        }
        
        System.Test.stopTest();
    }
}