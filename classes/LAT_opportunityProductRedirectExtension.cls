/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 08/11/2016
*
********************************************************************************/

public with sharing class LAT_opportunityProductRedirectExtension {
    Id oppId;

    // we are extending the OpportunityLineItem controller, so we query to get the parent OpportunityId
    public LAT_opportunityProductRedirectExtension(ApexPages.StandardController controller) {
        oppId = [select Id, LAT_Opportunity__c from LAT_OpportunityLineItem__c where Id = :controller.getRecord().Id limit 1].LAT_Opportunity__c;
    }
    
    // then we redirect to our desired page with the Opportunity Id in the URL
    public pageReference redirect(){
        return new PageReference('/apex/LAT_opportunityProductEntry?id=' + oppId);
    }

}