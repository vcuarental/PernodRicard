/**
 * Created by Andrii Leshchuk on 20.02.2019.
 */

trigger EUR_CRM_ProductCatalogItemTrigger on EUR_CRM_ProductCatalogItem__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    new EUR_CRM_ProductCatalogItemTriggerHandler().run(); 

}