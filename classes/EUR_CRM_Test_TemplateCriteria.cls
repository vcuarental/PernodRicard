@isTest
public class EUR_CRM_Test_TemplateCriteria{
    private static EUR_CRM_JB_Template__c template;
    private static EUR_CRM_JB_Template_Criteria__c tempCiteria;
    private static EUR_CRM_Group_Outlet_Type__c goutletType;
    private static EUR_CRM_Outlet_Type__c outletType;
    private static EUR_CRM_Image_Level__c imgLevel;
    private static EUR_CRM_Volume_Potential__c volPotential;
    
    static testmethod void testTemplateCriteria1(){
        template = EUR_CRM_TestClassUtilityHelper.createTemplate(1, 'GB Template', 'template name')[0];
        insert template;
        system.assert(template.Id!=null);
        
        goutletType = new EUR_CRM_Group_Outlet_Type__c(EUR_CRM_Name__c='Restaurant');
        insert goutletType;

        outletType = new EUR_CRM_Outlet_Type__c(EUR_CRM_Name__c='Restaurant', EUR_CRM_Group_Outlet_Type__c=goutletType.Id);
        insert outletType;
        
        imgLevel = new EUR_CRM_Image_Level__c(EUR_CRM_Name__c='Leading');
        insert imgLevel;
        
        volPotential = new EUR_CRM_Volume_Potential__c(EUR_CRM_Name__c='High');
        insert volPotential;

        tempCiteria = EUR_CRM_TestClassUtilityHelper.createTemplateCriteria(1, 'GB Template Criteria', template.Id)[0];
        tempCiteria.EUR_JB_Active__c = true;
        tempCiteria.EUR_JB_Group_Outlet_Type__c = goutletType.Id;
        tempCiteria.EUR_JB_Outlet_Type__c = outletType.Id;
        tempCiteria.EUR_JB_Image_Level__c = imgLevel.id;
        tempCiteria.EUR_JB_Volume_Potential__c = volPotential.Id;
        insert tempCiteria;
        update tempCiteria;
    }

}