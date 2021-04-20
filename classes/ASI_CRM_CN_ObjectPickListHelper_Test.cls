@isTest
public class ASI_CRM_CN_ObjectPickListHelper_Test {

    static testMethod void ASI_CRM_CN_ObjectPickListHelper_TEST() {
        
        Account acc = new Account(Name='TEST');
        insert acc;
        
        Contact contact = new Contact(LastName='TEST', AccountId=acc.Id);
        insert contact;
        
        test.startTest();
        
        ASI_CRM_CN_ObjectPickListHelper h;
        
        h = new ASI_CRM_CN_ObjectPickListHelper('Contact','AccountId','LastName',null,null);
        
        test.stopTest();
        
    }
}