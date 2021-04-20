@istest
public class ASI_KOR_GMAAttachRestAPI_Test{
    
    static testMethod void test_main() {
        String PARAM_GMA_ID = 'gmaid';
        String PARAM_EXT = 'ext';
        ASI_KOR_AccountGenerator acctGen = new ASI_KOR_AccountGenerator();
        ASI_KOR_BrandGenerator brandGen = new ASI_KOR_BrandGenerator();
        ASI_KOR_SubBrandGenerator sbGen = new ASI_KOR_SubBrandGenerator();
        ASI_KOR_GMAGenerator gmaGen = new ASI_KOR_GMAGenerator();
        
        Account venue = acctGen.generateAccount(ASI_KOR_AccountGenerator.RT_Venue);
        insert venue;
        
        ASI_KOR_Brand__c brand = brandGen.generateBrand();
        insert brand;
        ASI_KOR_Sub_Brand__c sb = sbGen.generateSubBrand(brand);
        insert sb;
        
        ASI_KOR_GMA__c gma = gmaGen.generateGMA(venue, sb);
        insert gma;
        
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.httpMethod = 'PUT';
        req.addParameter(PARAM_GMA_ID, gma.Id);
        req.requestBody = Blob.valueOf('test');
        
        Test.startTest();
        
        Map<String, String> result = ASI_KOR_GMAAttachRestAPI.submitChanges();
        
        Test.stopTest();
        
        System.assertEquals('true', result.get('success'));
        List<ASI_KOR_GMA_Image__c> gmaImages = [SELECT Id FROM ASI_KOR_GMA_Image__c WHERE ASI_KOR_Parent__c = :gma.Id];
        System.assertEquals(1, gmaImages.size());
    }
}