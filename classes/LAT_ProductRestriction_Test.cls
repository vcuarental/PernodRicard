@istest
public with sharing class LAT_ProductRestriction_Test {

    static testMethod void unitTest() {
      List<LAT_Product__c> productsList = new List<LAT_Product__c>();
      LAT_Product__c prod1 = new LAT_Product__c(Name = 'TestProd', 
        LAT_IsActive__c = true, 
        LAT_CDUnit__c = 'CA', 
        LAT_ExternalID__c = '12-444', 
        LAT_QTLeadTime__c = 5, 
        LAT_Sku__c = '5666', 
        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
      LAT_Product__c prod2 = new LAT_Product__c(Name = 'TestProd2', 
        LAT_IsActive__c = true, 
        LAT_CDUnit__c = 'CA', 
        LAT_ExternalID__c = '12-443', 
        LAT_Sku__c = '5667', 
        RecordTypeId = Global_RecordTypeCache.getRtId('LAT_Product__c' + 'BRA_Standard'));
      insert new List<LAT_Product__c>{prod1, prod2};
      
      LAT_ProductRestriction pr = new LAT_ProductRestriction();

      pr.mostrarPopUp();
      pr.ocultarPopUp();
      
      ApexPages.currentPage().getParameters().put('input1', 'test');
      pr.buscar();

      pr.idProducto = prod1.id;
      pr.seleccionarProducto();

      pr.producto = prod1;
      pr.restringirProducto();
      
      prod1.LAT_RestrictionInit__c = Date.Today();
      update prod1;
      pr.restringirProducto();
      
      prod1.LAT_RestrictionEnd__c = Date.Today();
      update prod1;
      pr.restringirProducto();
      prod1.LAT_RestrictionEnd__c = Date.Today().addDays(-2);
      update prod1;
      prod1.LAT_RestrictionDescription__c = 'Test';
      update prod1;
      pr.restringirProducto();

      pr.idProducto = prod2.id;
      pr.quitarRestriccion();

      pr.limpiar();
      pr.cancelar();
    }
    
}