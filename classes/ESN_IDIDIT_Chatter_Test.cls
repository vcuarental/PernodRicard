@isTest
private class ESN_IDIDIT_Chatter_Test {

    private static final List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name=:Label.ESN_IDIDIT_ChatterGroupName LIMIT 1];
       
    @IsTest(SeeAllData=true)
    static void fileNotSelected() {
        //List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name=:Label.ESN_IDIDIT_ChatterGroupName LIMIT 1];
        
        CollaborationGroup gr = new CollaborationGroup();
        gr.Name='groupTest';
        gr.CollaborationType='Public';
        insert gr;
        
        PageReference pageRef = new PageReference('/apex/ESN_IDidIt');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',gr.id);

        ESN_IDIDIT_Chatter controller = new ESN_IDIDIT_Chatter();
        
        //controller.counter = '1';
        controller.subjectId = chatterGroup[0].id;
        controller.message = 'test';
        controller.Post();
    }
    
    @IsTest(SeeAllData=true)
    static void counterNotFilled() {
        //List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name=:Label.ESN_IDIDIT_ChatterGroupName LIMIT 1];
        
        CollaborationGroup gr = new CollaborationGroup();
        gr.Name='groupTest';
        gr.CollaborationType='Public';
        insert gr;
        
        ContentVersion cv = new ContentVersion(); 
        cv.VersionData = Blob.valueOf('I am a file posting to Chatter');
        cv.PathOnClient='myFile.txt';
        cv.Title ='myFile'; 
        insert cv;
        
        PageReference pageRef = new PageReference('/apex/ESN_IDidIt');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',gr.id);
        
        ESN_IDIDIT_Chatter controller = new ESN_IDIDIT_Chatter();
        //controller.counter = null;
        controller.message = 'test';
        controller.subjectId = chatterGroup[0].id;
        controller.file=cv;
        controller.Post();
    }
    
   /* static testMethod void counterNotNumeric() {
        CollaborationGroup gr = new CollaborationGroup();
        gr.Name='groupTest';
        gr.CollaborationType='Public';
        insert gr;
        
        ContentVersion cv = new ContentVersion(); 
        cv.VersionData = Blob.valueOf('I am a file posting to Chatter');
        cv.PathOnClient='myFile.txt';
        cv.Title ='myFile'; 
        insert cv;
        
        PageReference pageRef = new PageReference('/apex/ESN_IDidIt');
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('Id',gr.id);
        
        ESN_IDIDIT_Chatter controller = new ESN_IDIDIT_Chatter();
        controller.counter = 'test';
        controller.message = 'test';
        controller.file=cv;
        controller.Post();
    }*/
}