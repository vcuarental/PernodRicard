@isTest
public class GRP_CC_AttachPDF_Test {
    
    
    @isTest
    private static void savePDFFileTest(){
        
        CORE_Region__c r = new CORE_Region__c();
        r.Name = 'Region test';
        insert r;
        GRP_CC_Group__c cg = new GRP_CC_Group__c();
        cg.GRP_CC_GroupeResponsible__c = 'test@pernod-ricard.com.test';
        cg.GRP_CC_Domain__c = 'fake_domain';
        insert cg;
        GRP_CC_Chain__c ch = new GRP_CC_Chain__c();
        ch.Name='Ch test';
        ch.GRP_CC_Group__c = cg.Id;
        insert ch;
        CORE_Country__c country = new CORE_Country__c();
        country.name = 'TestFrance';
        country.CORE_Region__c = r.Id;
        insert country;
        GRP_CC_ChainAccount__c ca = new GRP_CC_ChainAccount__c();
        ca.GRP_CC_Chain__c=ch.Id;
        ca.GRP_CC_ChainAccountResponsible__c = 'test@test.fr';
        ca.GRP_CC_Region__c = r.Id;
        ca.GRP_CC_Country__c=country.Id;
        insert ca;
        
        GRP_CC_deep_dive__c vDeep_dive = new GRP_CC_deep_dive__c(
            Name = 'test',
            GRP_CC_Chain_Account__c = ca.id,
            GRP_CC_Statut__c = 'Done'
        );
            insert vDeep_dive;
        
     
     
        GRP_CC_AttachPDF.savePDFFile(vDeep_dive.Id, 'deepdive');
        
        
        
    }
}