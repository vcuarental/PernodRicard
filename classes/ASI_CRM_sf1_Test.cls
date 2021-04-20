@isTest
public class ASI_CRM_sf1_Test{
    
    static testMethod void ASI_CRM_sf1_AddPhoto_TEST() {
        test.startTest();        
        {
            Account a = new Account();
            ASI_CRM_sf1_AddPhoto obj = new ASI_CRM_sf1_AddPhoto(new ApexPages.StandardController(a));
            
            ASI_CRM_sf1_AddPhoto.sf1Data data = new ASI_CRM_sf1_AddPhoto.sf1Data();
            data.bImage = Blob.valueOf('xxxxxxxxxxxxxxc');
            data.ParentId = '0000001';
            data.sImage = 'aaa:bbb;ccc:ddd,eee';
            data.contentType = 'contentType';
            data.bodyLength = 100;
            data.name = 'Name';            
            ASI_CRM_sf1_AddPhoto.submitData(data);
            
            
            ASI_CRM_sf1_AddPhoto.sf1Data data1 = new ASI_CRM_sf1_AddPhoto.sf1Data();
            data1.bImage = Blob.valueOf('xxxxxxxxxxxxxxc');
            data1.ParentId = '0000001';
            data1.sImage = '';
            data1.contentType = 'contentType';
            data1.bodyLength = 100;
            data1.name = 'Name';            
            ASI_CRM_sf1_AddPhoto.submitData(data1);
        }
        test.stopTest();        
    }
    
    static testMethod void ASI_CRM_sf1Result_TEST() {
        test.startTest();        
        {
            ASI_CRM_sf1_AddPhoto.sf1Data data = new ASI_CRM_sf1_AddPhoto.sf1Data();
            data.bImage = Blob.valueOf('xxxxxxxxxxxxxxc');
            data.ParentId = '0000001';
            data.sImage = '';
            data.contentType = 'contentType';
            data.bodyLength = 100;
            data.name = 'Name';            
            ASI_CRM_sf1_AddPhoto.submitData(data);
            
            Account acc = new Account(Name='aaa');
            insert acc;
            Blob b = Blob.valueOf('Test Data');
            Attachment attachment = new Attachment();
            attachment.ParentId = acc.id;
            attachment.Name = 'Test Attachment for Parent';
            attachment.Body = b;
            insert(attachment);
            
            ASI_CRM_sf1Result a = new ASI_CRM_sf1Result(attachment.id); 
            
            ASI_CRM_sf1Result r_exception = new ASI_CRM_sf1Result(new ASI_CRM_CN_Function.CRMException('TEST'));
            
        }
        test.stopTest();        

    }
}