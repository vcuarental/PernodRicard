@isTest 
public class GRP_CC_RenameFile_TEST {
    @isTest
	public static void testRenameFile() {
        ContentVersion cv=new Contentversion(); 
        cv.title='ABC'; 
        cv.PathOnClient='abc'; 
        Blob b=Blob.valueOf('This is version data'); 
        cv.versiondata=b; 
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id=:cv.id];
        
        list<string> l = new list<string>{cv.ContentDocumentId+';toto'};
        
        system.debug(l);
        
        GRP_CC_RenameFile.getRenameFile(l);
    }
}