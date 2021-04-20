@isTest
public class EUR_CRM_PRS_AspBasedOnCriteriaTest {
    @isTest
    public static void setBPBasedOnCustomerTaxonomy() {
	
        EUR_CRM_PRS_Seg_Aspect__c bplow = new EUR_CRM_PRS_Seg_Aspect__c(
        	EUR_CRM_Segmentation_BP_Aspect_Name__c = 'Low',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_Segmentation_Aspect_BP').getRecordTypeId()
        );
        insert bplow;
        EUR_CRM_PRS_Seg_Aspect__c bphigh = new EUR_CRM_PRS_Seg_Aspect__c(
        	EUR_CRM_Segmentation_BP_Aspect_Name__c = 'High',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_Segmentation_Aspect_BP').getRecordTypeId()
        );
        insert bphigh;
        EUR_CRM_PRS_Seg_Aspect__c bpmedium = new EUR_CRM_PRS_Seg_Aspect__c(
        	EUR_CRM_Segmentation_BP_Aspect_Name__c = 'Medium',
            RecordTypeId = Schema.SObjectType.EUR_CRM_PRS_Seg_Aspect__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_PRS_Segmentation_Aspect_BP').getRecordTypeId()
        );
        insert bpmedium;
        
        EUR_CRM_Customer_Taxonomy__c taxo1 = new EUR_CRM_Customer_Taxonomy__c(
        	Name = 'BE TAXO 1',
            eur_crm_business_potential__c = bplow.id
        );
        EUR_CRM_Customer_Taxonomy__c taxo2 = new EUR_CRM_Customer_Taxonomy__c(
        	Name = 'BE TAXO 1',
            eur_crm_business_potential__c = bphigh.id
        );
        
        insert taxo1;
        insert taxo2;
        
        EUR_CRM_Account__c a = new EUR_CRM_Account__c(
        	RecordTypeId = Schema.SObjectType.EUR_CRM_Account__c.getRecordTypeInfosByDeveloperName().get('EUR_BE_Off_Trade').getRecordTypeId(),
            Name = 'Belgium Off Trade account',
            eur_jb_customer_taxonomy__c = taxo1.id
        );
        insert a;
        
        a = [SELECT Id, RecordType.DeveloperName FROM EUR_CRM_Account__c WHERE id = :a.id];
        Map<String, EUR_PROS_PROFS_Assignment__mdt> criterias = EUR_CRM_PRS_AspectAssignBasedOnCriteria.retrieveMetadata(a.RecordType.DeveloperName);
        
        System.assertEquals(false, EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasBBPLogic(criterias));
        System.assertEquals(true, EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasBPLogic(criterias));
        System.assertEquals(false, EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasILLogic(criterias));
        System.assertEquals(false, EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasVPLogic(criterias));
        
        EUR_CRM_PRS_Segmentation__c prs = [SELECT Id FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :a.id];
        
        EUR_CRM_PRS_AspectAssignBasedOnCriteria.run(a, prs);
        update prs;
        update a;
        
        a = [SELECT id, EUR_CRM_Business_Potential__c, RecordType.DeveloperName FROM EUR_CRM_Account__c WHERE Id = :a.id];
        prs = [SELECT Id, EUR_CRM_Business_Potential__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :a.id];
        System.assertEquals(bplow.id, a.EUR_CRM_Business_Potential__c);
        System.assertEquals(bplow.id, prs.EUR_CRM_Business_Potential__c);
        
        
        //New test
        a.EUR_JB_Customer_Taxonomy__c = taxo2.id;
        update a;
        
        EUR_CRM_PRS_AspectAssignBasedOnCriteria.run(a, prs);
        update prs;
        update a;
        a = [SELECT id, EUR_CRM_Business_Potential__c, RecordType.DeveloperName FROM EUR_CRM_Account__c WHERE Id = :a.id];
        prs = [SELECT Id, EUR_CRM_Business_Potential__c FROM EUR_CRM_PRS_Segmentation__c WHERE EUR_CRM_Account__c = :a.id];
        System.assertEquals(bphigh.id, a.EUR_CRM_Business_Potential__c);
        System.assertEquals(bphigh.id, prs.EUR_CRM_Business_Potential__c);
    }
}