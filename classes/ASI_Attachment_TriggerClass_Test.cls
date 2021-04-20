@isTest
public class ASI_Attachment_TriggerClass_Test{
    static testmethod void ASI_Attachment_TriggerClass_Test(){
        ASI_Pricing_Approval__c pa = new ASI_Pricing_Approval__c(Name='Test',ASI_Advanced_Pricing__c=true,ASI_Status__c='Complete',ASI_Customer_Name__c='test',ASI_Approved_Level__c=1,ASI_Submission_Date__c=Date.today()); 
        insert pa;
        Blob a = Blob.valueOf('Test Data');  
        Attachment attachment0 = new Attachment();  
        attachment0.ParentId = pa.id;  
        attachment0.Name = 'test';  
        attachment0.Body = a;  
        attachment0.Contenttype = 'application/pdf';
        insert(attachment0);
        
        try{
            delete attachment0;
        }catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('My Error Message') ? true : false;
            System.AssertEquals(expectedExceptionThrown, false);
        } 
    }
}