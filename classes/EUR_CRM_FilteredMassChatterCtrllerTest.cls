@isTest
public class EUR_CRM_FilteredMassChatterCtrllerTest {
    
    public static List<EUR_CRM_Account__c> acctlist = createAccts();
    
    static testMethod void myUnitTest() {
        Apexpages.Standardsetcontroller acctSetCon = new Apexpages.Standardsetcontroller(Database.getQueryLocator([Select Id From EUR_CRM_Account__c LIMIT 10]));
        EUR_CRM_FilteredMassChatterController controller = new EUR_CRM_FilteredMassChatterController(acctSetCon);
       
        controller.myFeedItem.Body = 'text message test';
        controller.massSendChatterPosts();
        
        controller.myFeedItem.Body = 'content message test';
        Blob b = Blob.valueOf('test content');
        controller.myFeedItem.ContentData = b;
        controller.myFeedItem.ContentFileName = 'test content';
        controller.massSendChatterPosts();
        
        controller.myFeedItem.Body = 'link message test';
        controller.myFeedItem.LinkUrl = 'http://www.yahoo.com';
        controller.myFeedItem.Title = 'yahoo';
        controller.massSendChatterPosts();
    }
    
    public static List<EUR_CRM_Account__c> createAccts(){  
    Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
      
     
        List<EUR_CRM_Account__c> acclist = new List<EUR_CRM_Account__c>();
        EUR_CRM_Account__c euAcct = new EUR_CRM_Account__c(name='test eu account' , recordtypeid=rtId );
        acclist.add(euAcct);
        EUR_CRM_Account__c euAcct2 = new EUR_CRM_Account__c(name='test eu account2' , recordtypeid=rtId );
        acclist.add(euAcct2);
        insert acclist;
        return acclist;
    }
}