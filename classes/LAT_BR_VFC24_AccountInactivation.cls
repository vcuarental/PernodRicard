/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFC24_AccountInactivation {
  public Account acc {get; set;}
  public Case cas {get; set;}
  public LAT_Case__c latCase {get; set;}
  public String errorMsg1 {get; set;}
  public String errorMsg2 {get; set;}

  //MIGRATED 02/11/2016 
  public LAT_BR_VFC24_AccountInactivation(ApexPages.StandardController controller) {
    List<Account> lst = [Select id, Reason_for_Inactivation__c, OwnerId, Type, Rating 
          from Account 
          where id =: controller.getRecord().Id 
          limit 1];
  
    acc = !lst.isEmpty() ? lst.get(0) : new Account();
    
    errorMsg1 = Label.LAT_BR_VFC24_AccountInactivation_Error_Msg_01;
    errorMsg2 = Label.LAT_BR_VFC24_AccountInactivation_Error_Msg_02;
    if(!Utils.wasMigrationDone('1')){
      cas = new Case();
    }else{
      latCase = new LAT_Case__c();
    }
  }

  public pageReference onLoad() {
   
    if (acc.Type == 'Outros') {
      acc.Rating = 'Cliente Inativo';
      if(acc.Reason_for_Inactivation__c == '' || acc.Reason_for_Inactivation__c == null) {
        acc.Reason_for_Inactivation__c = '--None--';
      }  
      update acc;
      return new PageReference( '/'+ acc.id );
      
    } else {
      return null;
    }
  }

  //MIGRATED 02/11/2016 
  public pageReference save() {
    if(!Utils.wasMigrationDone('1')){
      if (acc.Reason_for_Inactivation__c != '--None--' && acc.Reason_for_Inactivation__c != null && acc.Reason_for_Inactivation__c != '') {
        if (cas.Description != null && cas.Description != '') { 
          cas.CurrencyIsoCode = 'BRL';
          cas.Origin = 'Demanda Interna PRB';
          cas.Status = 'Novo';
          cas.OwnerId = acc.OwnerId;
          cas.AccountId = acc.Id;
          cas.Reason = 'Solicitação de inativação de cliente';
          cas.Type = 'Alteração - Cadastro de cliente';
          cas.RecordTypeId = RecordTypeForTest.getRecType('Case', 'Alteracao_cadastro_de_clientes');
          update acc;
          insert cas;
          return new pageReference('/' + cas.id);
        } else {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errorMsg1); // message : 'Debe ingresar una descripción de la razón de la inactivación del Cliente.');
            ApexPages.addMessage(errorMsg);
        }  
      } else {
          ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errorMsg2); // message : 'Debe seleccionar la causa de la inactivación del Cliente para continuar.');
          ApexPages.addMessage(errorMsg);
      }  
      return null;
    }else{
      if (acc.Reason_for_Inactivation__c != '--None--' && acc.Reason_for_Inactivation__c != null && acc.Reason_for_Inactivation__c != '') {
        if (latCase.LAT_Description__c != null && latCase.LAT_Description__c != '') { 
          latCase.CurrencyIsoCode = 'BRL';
          latCase.LAT_Origin__c = 'Demanda Interna PRB';
          latCase.LAT_Status__c = 'Novo';
          latCase.OwnerId = acc.OwnerId;
          latCase.LAT_Account__c = acc.Id;
          latCase.LAT_Reason__c = 'Solicitação de inativação de cliente';
          latCase.LAT_Type__c = 'Alteração - Cadastro de cliente';
          latCase.RecordTypeId = RecordTypeForTest.getRecType('LAT_Case__c', 'Alteracao_cadastro_de_clientes');
          update acc;
          insert latCase;
          return new pageReference('/' + latCase.id);
        } else {
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errorMsg1); // message : 'Debe ingresar una descripción de la razón de la inactivación del Cliente.');
            ApexPages.addMessage(errorMsg);
        }  
      } else {
          ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errorMsg2); // message : 'Debe seleccionar la causa de la inactivación del Cliente para continuar.');
          ApexPages.addMessage(errorMsg);
      }  
      return null;
    }
    return null;  
  }
}