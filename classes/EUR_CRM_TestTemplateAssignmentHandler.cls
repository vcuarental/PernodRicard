/**
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test class for EUR_CRM_TemplateAssignmentHandler Class.
  @Author:      IPC
  @History:     JUN.18.2014 - Created
 */
@isTest
private class EUR_CRM_TestTemplateAssignmentHandler {
    private static EUR_CRM_Account__c acct;
    private static EUR_CRM_Group_Outlet_Type__c goutletType;
    private static EUR_CRM_Outlet_Type__c outletType;
    private static EUR_CRM_Image_Level__c imgLevel;
    private static EUR_CRM_Volume_Potential__c volPotential;
    private static EUR_CRM_Visit_Frequency__c visitFreq;
    private static EUR_CRM_Visit_Frequency_Criteria__c visitCriteria;
    private static EUR_CRM_Customer_Taxonomy__c custTaxonomy;
    private static EUR_CRM_JB_Template__c template;
    private static EUR_CRM_JB_Template_Criteria__c tempCiteria;
    
    public static void dataInsert() {
        goutletType = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_Name__c='Restaurant');
        insert goutletType;
        
        outletType = new EUR_CRM_Outlet_Type__c(EUR_CRM_Name__c='Restaurant', EUR_CRM_Group_Outlet_Type__c=goutletType.Id);
        insert outletType;
        
        imgLevel = new EUR_CRM_Image_Level__c(EUR_CRM_Name__c='Leading');
        insert imgLevel;
        
        volPotential = new EUR_CRM_Volume_Potential__c(EUR_CRM_Name__c='High');
        insert volPotential;
        
        visitFreq = new EUR_CRM_Visit_Frequency__c(name='once a week');
        insert visitFreq;
        
        visitCriteria = new EUR_CRM_Visit_Frequency_Criteria__c(EUR_CRM_Visit_Frequency__c=visitFreq.Id, 
                                                                EUR_CRM_Group_Outlet_Type__c=goutletType.Id, EUR_CRM_Outlet_Type__c=outletType.Id, 
                                                                EUR_CRM_Image_Level__c=imgLevel.Id, EUR_CRM_Volume_Potential__c=volPotential.id);
        insert visitCriteria;
        
        template = EUR_CRM_TestClassUtilityHelper.createTemplate(1, 'GB Template', 'template name')[0];
        insert template;
        system.assert(template.Id!=null);
    
        tempCiteria = EUR_CRM_TestClassUtilityHelper.createTemplateCriteria(1, 'GB Template Criteria', template.Id)[0];
        tempCiteria.EUR_JB_Active__c = true;
        tempCiteria.EUR_JB_Group_Outlet_Type__c = goutletType.Id;
        tempCiteria.EUR_JB_Outlet_Type__c = outletType.Id;
        tempCiteria.EUR_JB_Image_Level__c = imgLevel.id;
        tempCiteria.EUR_JB_Volume_Potential__c = volPotential.Id;
        insert tempCiteria;
        system.assert(tempCiteria.Id!=null);
         Id rtId = [select id from recordtype where developername = 'EUR_GB_FS_Indirect' and sobjecttype = 'eur_crm_account__c' limit 1].id;
        acct = new EUR_CRM_Account__c(Name='GB test on trade account');
        acct.EUR_CRM_Group_Outlet_Type__c = goutletType.Id;
        acct.EUR_CRM_Outlet_Type__c = outletType.Id;
        acct.EUR_CRM_Image_Level__c = imgLevel.id;
        acct.EUR_CRM_Volume_Potential__c = volPotential.Id;
        acct.EUR_JB_Default_Template__c = template.Id;
        acct.recordtypeid=rtId;
        insert acct;
        
        custTaxonomy = new EUR_CRM_Customer_Taxonomy__c();
        custTaxonomy.Name = 'test Name';
        insert custTaxonomy;
    }
    
    static testmethod void tempAssignment1(){
        test.startTest();
            dataInsert();
        test.stopTest();
    }
    
    static testmethod void tempAssignment2(){
        dataInsert();
        test.startTest();
            acct.EUR_CRM_Group_Outlet_Type__c = null;
            acct.EUR_JB_Customer_Taxonomy__c = custTaxonomy.Id;
            update acct;
        test.stopTest();
    }
}