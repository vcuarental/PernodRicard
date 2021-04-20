public with sharing class LAT_BR_Inactivation_AccMob_Controller {


	public Account acc {get;set;}
	public Case cas {get;set;}
	public String accId {get;set;}
	public String errorMsg1 {get; set;}
    public String errorMsg2 {get; set;}

    //Inativo
    public Boolean clienteInactivo {get;set;}

	public LAT_BR_Inactivation_AccMob_Controller() {
			
		accId = ApexPages.currentPage().getParameters().get('id');
		 List<Account> lst = [Select Id, Reason_for_Inactivation__c, OwnerId, Type, Rating 
					          from Account 
					          where id =: accId
					          limit 1];
					  
	    acc = !lst.isEmpty() ? lst.get(0) : new Account();
	    clienteInactivo = false;
	    cas = new Case();
	    errorMsg1 = Label.LAT_BR_VFC24_AccountInactivation_Error_Msg_01;
	    errorMsg2 = Label.LAT_BR_VFC24_AccountInactivation_Error_Msg_02;


	    if(acc != null && acc.Id != null){
	     if (acc.Type == 'Outros') {

		      acc.Rating = 'Cliente Inativo';

		      if(acc.Reason_for_Inactivation__c == '' || acc.Reason_for_Inactivation__c == null) {
		        acc.Reason_for_Inactivation__c = '--None--';
		      }  
		      update acc;

		      clienteInactivo = true;
		      //return new PageReference( '/'+ acc.id );
		      
		    } 

		}
	}


	public pageReference save() {

		system.debug('Acc: ' + acc);

		try{
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

	        ApexPages.Message saveMsg = new ApexPages.Message(ApexPages.severity.INFO, 'Cliente actualizado');
	        ApexPages.addMessage(saveMsg);
	        return null;
	        //return new pageReference('/' + cas.id);
	      } else {
	          ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errorMsg1); // message : 'Debe ingresar una descripción de la razón de la inactivación del Cliente.');
	          ApexPages.addMessage(errorMsg);
	      }  
	    } else {
	        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, errorMsg2); // message : 'Debe seleccionar la causa de la inactivación del Cliente para continuar.');
	        ApexPages.addMessage(errorMsg);
	    } 

	    }catch(Exception e){
	    	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()); 
	        ApexPages.addMessage(errorMsg);
	    } 
	    return null;

	}
}