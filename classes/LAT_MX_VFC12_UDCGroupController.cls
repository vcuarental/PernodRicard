public with sharing class LAT_MX_VFC12_UDCGroupController {
	
	public UDC__c newUDC {get; set;}
	public List<UDC__c> listUDC {get; set;}
	public Boolean belongsToGroup {get; set;}
	
	public LAT_MX_VFC12_UDCGroupController() {
		
		belongsToGroup = Utils.isPartOfGroup('LAT_MX_Alta_Grupos');

		if (!belongsToGroup) {
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_VFP06_Message08);
	    	ApexPages.addMessage(errorMsg);
		}
		else {
			newUDC = new UDC__c();
			listUDC = new List<UDC__c>();

			getAllMXUDC();
		}
	}

	public void save() {

		newUDC.CodProd__c = 'CRM';
		newUDC.CodUs__c = 'GO';
		newUDC.Internal_Id__c = 12 + '-' + newUDC.CodDefUsuario__c + '-' + newUDC.CodProd__c + '-' + newUDC.CodUs__c;
		newUDC.RecordTypeId = Schema.SObjectType.UDC__c.getRecordTypeInfosByName().get('MX Standard').getRecordTypeId();
		
		try {
		    
		    insert newUDC;

		} catch(DmlException e) {
			
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC09_Error_Msg_9);
	    	ApexPages.addMessage(errorMsg);
		  
		} catch(Exception e) {
			
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
			ApexPages.addMessage(errorMsg);

		} finally {
		    
		}
		
		//CAMBIAR MENSAJE
		ApexPages.Message successMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC09_Success_Msg_1);
		ApexPages.addMessage(successMsg);

		getAllMXUDC();
	}

	private void getAllMXUDC() {

		Id devRecordTypeId = Schema.SObjectType.UDC__c.getRecordTypeInfosByName().get('MX Standard').getRecordTypeId();

		listUDC = [SELECT Id,
						Name,
						CodDefUsuario__c,
						CodProd__c,
						CodUs__c,
						Descricao2__c,
						Internal_Id__c
					FROM UDC__c 
					WHERE RecordTypeId = :devRecordTypeId and
						CodProd__c = 'CRM' and
						CodUs__c = 'GO'
					ORDER BY CreatedDate];

	}
}