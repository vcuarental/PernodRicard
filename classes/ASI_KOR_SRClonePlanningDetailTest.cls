@isTest
public class ASI_KOR_SRClonePlanningDetailTest{

    @isTest
    public static void testClone(){
    
        Map<String,SObject> propObjects = ASI_KOR_TestClassHelper.generateProposalObjects();
		user nsd = (user) propObjects.get(ASI_KOR_TestClassHelper.NSD_USER);
		user rsd = (user) propObjects.get(ASI_KOR_TestClassHelper.RSD_USER);
		user bm = (user) propObjects.get(ASI_KOR_TestClassHelper.BM_USER);
		user sr = (user) propObjects.get(ASI_KOR_TestClassHelper.SR_USER);
		ASI_KOR_Brand__c brand1 = (ASI_KOR_Brand__c) propObjects.get(ASI_KOR_TestClassHelper.ABSOLUT_BRAND);
		
		ASI_KOR_NSD_Proposal_Header__c nsdHeader = new ASI_KOR_NSD_Proposal_Header__c(
			ASI_KOR_Year__c = '2014',   
			ASI_KOR_Month__c = '2', 
			ASI_KOR_Status__c = 'Draft',
			ASI_KOR_No_of_Sumitted_Regions__c = 5,
            ASI_KOR_SYS_Cut_off_Date__c = Date.valueOf('2013-01-14'),
			ownerid = nsd.id
        );
        insert nsdHeader;		
        ASI_KOR_NSD_Proposal_By_Brand__c nsdByBrand = new ASI_KOR_NSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle'
        );        
        insert nsdByBrand;
		
		ASI_KOR_RSD_Proposal_Header__c rsdHeader = new ASI_KOR_RSD_Proposal_Header__c(
			ASI_KOR_Year__c = '2014',   
			ASI_KOR_Month__c = '2', 
			ASI_KOR_Status__c = 'Draft', 
			ASI_KOR_NSD_Proposal_Header__c = nsdHeader.id,
			ownerid = rsd.id
        );
        insert rsdHeader;
        ASI_KOR_RSD_Proposal_By_Brand__c rsdByBrand = new ASI_KOR_RSD_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_RSD_Proposal_Header__c= rsdHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_NSD_Proposal_By_Brand__c = nsdByBrand.id
        );
        insert rsdByBrand;
		
		ASI_KOR_BM_Proposal_Header__c bmHeader = new ASI_KOR_BM_Proposal_Header__c(
			ASI_KOR_Year__c = '2014',   
			ASI_KOR_Month__c = '2', 
			ASI_KOR_Status__c = 'Draft', 
			ASI_KOR_RSD_Proposal_Header__c = rsdHeader.id,
			 ownerid = bm.id 
        );
        insert bmHeader;
       ASI_KOR_BM_Proposal_By_Brand__c bmByBrand = new ASI_KOR_BM_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_RSD_Proposal_By_Brand__c = rsdByBrand.id
        );
        insert bmByBrand;
		
        ASI_KOR_SR_Proposal_Header__c srHeader = new ASI_KOR_SR_Proposal_Header__c(
			ASI_KOR_Year__c = '2014',   
			ASI_KOR_Month__c = '2', 
			ASI_KOR_Status__c = 'Draft',
			ASI_KOR_BM_Proposal_Header__c = bmHeader.id,
         ownerid = sr.id 
        );
        insert srHeader;
        ASI_KOR_SR_Proposal_By_Brand__c srByBrand = new ASI_KOR_SR_Proposal_By_Brand__c(
            ASI_KOR_Brand__c = brand1.id,
            ASI_KOR_SR_Proposal_Header__c = srHeader.id,
            ASI_KOR_UOM__c = 'Bottle',
            ASI_KOR_BM_Proposal_By_Brand__c = bmByBrand.id
            
        );
        insert srByBrand;
		
		PageReference pageRef = Page.ASI_KOR_SRClonePlanningDetail;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', srHeader.id);
        ApexPages.StandardController sc = new ApexPages.standardController(srHeader);
        ASI_KOR_SRClonePlanningDetail controller = new ASI_KOR_SRClonePlanningDetail(sc);
		controller.cloneDetails();
    }
	
}