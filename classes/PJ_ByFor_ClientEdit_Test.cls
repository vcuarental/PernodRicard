@isTest
public class PJ_ByFor_ClientEdit_Test {
    
    static testmethod void PJ_ByFor_ClientEdit_Test1() {
        
        Test.startTest();
        
        PJ_ByFor_Client__c client = new PJ_ByFor_Client__c();
        PageReference pageRef1 = Page.PJ_ByFor_ClientEdit;
        Test.setCurrentPage(pageRef1);
        client.PJ_ByFor_Client_Date_of_birth__c = date.newInstance(2016, 10, 19);
        PJ_ByFor_ClientEdit myPage = new PJ_ByFor_ClientEdit(new ApexPages.StandardController(client));
        myPage.init();
        myPage.getCountries();
        myPage.getCountriesList();
        myPage.client.Name = 'Test';
        myPage.contactDate = '10/10/2016';
        myPage.lastsituationupdateDate = '10/10/2016';
        myPage.birthDate =  '10/10/2016';
        
        mypage.save();
        myPage.init();
        List<PJ_ByFor_Client__c> clientsTmp = PJ_ByFor_TestDataFactory.createClientsWithExp(1,0,'Friend');
        myPage.xpDateFromCalendar = clientsTmp[0].Id;
        myPage.save();
        Test.stopTest();
    }
}