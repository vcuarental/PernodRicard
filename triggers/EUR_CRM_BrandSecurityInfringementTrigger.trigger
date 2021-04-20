trigger EUR_CRM_BrandSecurityInfringementTrigger on EUR_CRM_Brand_Security_Infringement__c (after insert) {

    new EUR_CRM_BrandSecurityInfringementTrigHan().run();

}