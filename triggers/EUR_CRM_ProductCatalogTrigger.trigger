/**
 * Created by Andrii Leshchuk on 20.02.2019.
 */

trigger EUR_CRM_ProductCatalogTrigger on EUR_CRM_ProductCatalog__c (after insert) {

        new EUR_CRM_ProductCatalogTriggerHandler().run(); 
}