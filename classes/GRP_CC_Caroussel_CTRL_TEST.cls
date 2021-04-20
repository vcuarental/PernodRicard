@isTest 
public class GRP_CC_Caroussel_CTRL_TEST {
    
    @TestSetup
    static void makeData() {
        CORE_Region__c region = new CORE_Region__c();
        region.Name = 'EMEA';
        insert region;

        CORE_Country__c country = new CORE_Country__c();
        country.Name = 'test Country';
        country.CORE_Region__c = region.Id;
        insert country;

        GRP_CC_Group__c group1 = new GRP_CC_Group__c();
        group1.Name = 'group';
        group1.GRP_CC_GroupeResponsible__c = 'zegfze@zgesd.ciom';
        group1.GRP_CC_Domain__c = 'sdgsdg';
        insert group1;

        GRP_CC_Chain__c chain = new GRP_CC_Chain__c();
        chain.Name = 'test Chain';
        chain.GRP_CC_Group__c = group1.Id;
        insert chain;

        GRP_CC_ChainAccount__c chainAccount = new GRP_CC_ChainAccount__c();
        chainAccount.Name = 'test ChainAccount';
        chainAccount.GRP_CC_ChainAccountResponsible__c = 'test.chainAccount@pernod-ricard.com';
        chainAccount.GRP_CC_Chain__c = chain.Id;
        chainAccount.GRP_CC_Country__c = country.Id;
        chainAccount.GRP_CC_Region__c = region.Id;
        insert chainAccount;

        GRP_CC_Deep_dive__c deepDive = new GRP_CC_Deep_dive__c();
        deepDive.Name = 'test deepDive';
        deepDive.GRP_CC_Chain_Account__c = chainAccount.Id;
        insert deepDive;
    }

    
    
    @isTest
	public static void testCaroussel() {
        
		GRP_CC_Deep_dive__c deepDive = [SELECT Id, GRP_CC_Chain_Account__r.Name FROM GRP_CC_Deep_dive__c WHERE Name = 'test deepDive'];        
                
        ContentVersion cv=new Contentversion(); 
        cv.title='ecran_ABC.jpg'; 
        cv.PathOnClient='ecran_ABC.jpg'; 
        Blob b=Blob.valueOf('This is version data'); 
        cv.versiondata=b; 
        insert cv;
        
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE id=:cv.id];
        
        
        ContentDocumentLink cdl=new ContentDocumentLink(); 
        cdl.ContentDocumentId =	cv.ContentDocumentId;
        cdl.LinkedEntityId 	=	deepDive.Id;
        cdl.ShareType 		= 	'V';
        cdl.Visibility 		=	'AllUsers';
        
        insert cdl;
        
        
        GRP_CC_Caroussel_CTRL.getUrlImage(deepDive.id, 'ecran');
        
        
        
        

    }
}