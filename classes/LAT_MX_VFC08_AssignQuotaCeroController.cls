/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/
public with sharing class LAT_MX_VFC08_AssignQuotaCeroController {

	public LAT_MX_QTA_Quota__c Quota            {get; set;}
  	public List<LAT_MX_QTA_Quota__c> Existing   {get; set;}
  	public String Messages  {get; set;}
  
  	private final Integer MAX_INSERT_SIZE = 10000;
  	private final Set<Id> setIdRecordType = Global_RecordTypeCache.getRtIdSet('Account', new Set <String> {'LAT_MX_ACC_OffTrade', 'LAT_MX_ACC_OnTrade'});
  
  	public LAT_MX_VFC08_AssignQuotaCeroController() {
    	this.Quota = new LAT_MX_QTA_Quota__c();
    	this.Existing = new List<LAT_MX_QTA_Quota__c>();
  	}

  	public PageReference Generate() {
        if(!Utils.wasMigrationDone('12')) { 
	    	if (this.Quota.LAT_MX_Product__c != null){
	     		if (this.Quota.LAT_MX_ValidityUntil__c != null && this.Quota.LAT_MX_ValiditySince__c != null) {
	     			if (this.Quota.LAT_MX_ValiditySince__c >= Date.today()) {	
			       		if (this.Quota.LAT_MX_ValidityUntil__c > this.Quota.LAT_MX_ValiditySince__c) {	
				        	this.Existing = [SELECT LAT_MX_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        						WHERE LAT_MX_Product__c =: this.Quota.LAT_MX_Product__c AND LAT_MX_ValiditySince__c <=: this.Quota.LAT_MX_ValidityUntil__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c LIMIT 1000];
				        	if (this.Existing.isEmpty()) {
			            		if (this.insertQuotas(this.Quota.LAT_MX_Product__c)){
			              			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_1); // Label mesage :'Se ha ingresado la cuota con éxito.'
			       			  		ApexPages.addMessage(errorMsg);
				       				this.Existing.clear();
				       				this.Quota.LAT_MX_Product__c = null;
				       				this.Quota.LAT_MX_ValidityUntil__c = null;
				       				this.Quota.LAT_MX_ValiditySince__c = null;
			      				}
				        	} else {
				            	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_1); // Label mesage :'Ya existen cuotas para ese producto en ese período'
				          		ApexPages.addMessage(errorMsg);
				        	}
				      	} else {
				      		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_2); // Label mesage : 'La fecha de finalización debe ser posterior a la fecha de inicio.'
				       		ApexPages.addMessage(errorMsg);
				        	this.Quota.LAT_MX_ValidityUntil__c = null;
				      	}
				    } else {
				    	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_3); // Label mesage : 'La fecha de inicio no puede ser anterior a la fecha actual.'
		          		ApexPages.addMessage(errorMsg);
		          		this.Quota.LAT_MX_ValiditySince__c = null;
				    }
				} else {
				  	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_4); // Label mesage : 'Debe seleccionar fecha de inicio y finalización para ingresar la cuota.'
				    ApexPages.addMessage(errorMsg);
				}      	
		    } else {
	   			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_5); // Label mesage : 'Debe seleccionar un Producto para generar la cuota.'
	        	ApexPages.addMessage(errorMsg);
			}     
		   	return null;
		}
		//MIGRATED 17/11/2016
		else {
	    	if (this.Quota.LAT_Product__c != null){
	     		if (this.Quota.LAT_MX_ValidityUntil__c != null && this.Quota.LAT_MX_ValiditySince__c != null) {
	     			if (this.Quota.LAT_MX_ValiditySince__c >= Date.today()) {	
			       		if (this.Quota.LAT_MX_ValidityUntil__c > this.Quota.LAT_MX_ValiditySince__c) {	
				        	this.Existing = [SELECT LAT_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        						WHERE LAT_Product__c =: this.Quota.LAT_Product__c AND LAT_MX_ValiditySince__c <=: this.Quota.LAT_MX_ValidityUntil__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c LIMIT 1000];
				        	if (this.Existing.isEmpty()) {
			            		if (this.insertQuotas(this.Quota.LAT_Product__c)){
			              			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_1); // Label mesage :'Se ha ingresado la cuota con éxito.'
			       			  		ApexPages.addMessage(errorMsg);
				       				this.Existing.clear();
				       				this.Quota.LAT_Product__c = null;
				       				this.Quota.LAT_MX_ValidityUntil__c = null;
				       				this.Quota.LAT_MX_ValiditySince__c = null;
			      				}
				        	} else {
				            	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_1); // Label mesage :'Ya existen cuotas para ese producto en ese período'
				          		ApexPages.addMessage(errorMsg);
				        	}
				      	} else {
				      		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_2); // Label mesage : 'La fecha de finalización debe ser posterior a la fecha de inicio.'
				       		ApexPages.addMessage(errorMsg);
				        	this.Quota.LAT_MX_ValidityUntil__c = null;
				      	}
				    } else {
				    	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_3); // Label mesage : 'La fecha de inicio no puede ser anterior a la fecha actual.'
		          		ApexPages.addMessage(errorMsg);
		          		this.Quota.LAT_MX_ValiditySince__c = null;
				    }
				} else {
				  	ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_4); // Label mesage : 'Debe seleccionar fecha de inicio y finalización para ingresar la cuota.'
				    ApexPages.addMessage(errorMsg);
				}      	
		    } else {
	   			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_5); // Label mesage : 'Debe seleccionar un Producto para generar la cuota.'
	        	ApexPages.addMessage(errorMsg);
			}     
		   	return null;
		}
  	}

  	public void EliminateOne() {
    	String Index = system.currentPageReference().getParameters().get('listIndex');
    	if (Index != null) {
      		Integer i = Integer.valueOf(Index);
      		LAT_MX_QTA_Quota__c toRemove = this.Existing.get(i);
      		delete toRemove;
      		this.Existing.remove(i);
      		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_2); // Label mesage : 'Se ha eliminado la cuota con éxito.'
      		ApexPages.addMessage(errorMsg);
    	}  
  		return;
  	}

  	public void Ajustar() {      
   		try {
        	if(!Utils.wasMigrationDone('12')) {
	   			List <LAT_MX_QTA_Quota__c> lstCuotasAnteriores = [SELECT LAT_MX_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        				WHERE LAT_MX_Product__c =: this.Quota.LAT_MX_Product__c AND LAT_MX_ValidityUntil__c <: this.Quota.LAT_MX_ValiditySince__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c.addDays(-1)];
				Map <String, LAT_MX_QTA_Quota__c> mapCuotasAnteriores = new Map<String, LAT_MX_QTA_Quota__c>();
				for (LAT_MX_QTA_Quota__c q : lstCuotasAnteriores) {
					mapCuotasAnteriores.put(q.LAT_MX_Client__c, q);
				}
		    	ApexPages.Message errorMsg = null;
		    	String Index = null;
	      		Index = system.currentPageReference().getParameters().get('listIndexAjustar');
	      		if (Index != null) {
	        		if (this.Quota.LAT_MX_ValiditySince__c != null) {
	        			if (this.Quota.LAT_MX_ValiditySince__c >= Date.today()) {
		          			Integer i = Integer.valueOf(Index);
		          			LAT_MX_QTA_Quota__c quotaToUpdate = this.Existing.get(i);
		          			if (mapCuotasAnteriores.get(quotaToUpdate.LAT_MX_Client__c) == null) {	
			          			if ((this.Quota.LAT_MX_ValiditySince__c.addDays(-1)) > quotaToUpdate.LAT_MX_ValiditySince__c) {  
		          					quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
		              				update quotaToUpdate;
		              				errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
			       					ApexPages.addMessage(errorMsg);
				        		} else {			          	
			       	       			quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
			              			quotaToUpdate.LAT_MX_ValiditySince__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-2);
				              		update quotaToUpdate;
				              		errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
					       			ApexPages.addMessage(errorMsg);
		            			}    
			        		} else {
			            		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_8); // Label mesage :'No se puede ajustar esta cuota, si desea generar una nueva cuota elimine la cuota que deseaba ajustar.'
				         		ApexPages.addMessage(errorMsg);
			        		}	
			      		} else {
			      			errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_3); // Label mesage : 'La fecha de inicio no puede ser anterior a la fecha actual.'
				       		ApexPages.addMessage(errorMsg);
			      		}         
	        		} else {
			    		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_6); // Label mesage : 'Para ajustar la fecha de la cuota debe ingresar una fecha de inicio de la cuota a generar.'
		         		ApexPages.addMessage(errorMsg);	  
			    	}
				}
			}
			//MIGRATED 17/11/2016
			else {
	   			List <LAT_MX_QTA_Quota__c> lstCuotasAnteriores = [SELECT LAT_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        				WHERE LAT_Product__c =: this.Quota.LAT_Product__c AND LAT_MX_ValidityUntil__c <: this.Quota.LAT_MX_ValiditySince__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c.addDays(-1)];
				Map <String, LAT_MX_QTA_Quota__c> mapCuotasAnteriores = new Map<String, LAT_MX_QTA_Quota__c>();
				for (LAT_MX_QTA_Quota__c q : lstCuotasAnteriores) {
					mapCuotasAnteriores.put(q.LAT_MX_Client__c, q);
				}
		    	ApexPages.Message errorMsg = null;
		    	String Index = null;
	      		Index = system.currentPageReference().getParameters().get('listIndexAjustar');
	      		if (Index != null) {
	        		if (this.Quota.LAT_MX_ValiditySince__c != null) {
	        			if (this.Quota.LAT_MX_ValiditySince__c >= Date.today()) {
		          			Integer i = Integer.valueOf(Index);
		          			LAT_MX_QTA_Quota__c quotaToUpdate = this.Existing.get(i);
		          			if (mapCuotasAnteriores.get(quotaToUpdate.LAT_MX_Client__c) == null) {	
			          			if ((this.Quota.LAT_MX_ValiditySince__c.addDays(-1)) > quotaToUpdate.LAT_MX_ValiditySince__c) {  
		          					quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
		              				update quotaToUpdate;
		              				errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
			       					ApexPages.addMessage(errorMsg);
				        		} else {			          	
			       	       			quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
			              			quotaToUpdate.LAT_MX_ValiditySince__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-2);
				              		update quotaToUpdate;
				              		errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
					       			ApexPages.addMessage(errorMsg);
		            			}    
			        		} else {
			            		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_8); // Label mesage :'No se puede ajustar esta cuota, si desea generar una nueva cuota elimine la cuota que deseaba ajustar.'
				         		ApexPages.addMessage(errorMsg);
			        		}	
			      		} else {
			      			errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_3); // Label mesage : 'La fecha de inicio no puede ser anterior a la fecha actual.'
				       		ApexPages.addMessage(errorMsg);
			      		}         
	        		} else {
			    		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_6); // Label mesage : 'Para ajustar la fecha de la cuota debe ingresar una fecha de inicio de la cuota a generar.'
		         		ApexPages.addMessage(errorMsg);	  
			    	}
				}				
			}  
	  	} catch (Exception e) {

	  	} 
    	return;
  	}   

  	public void AjustarTodos() {
  		try {
        	if(!Utils.wasMigrationDone('12')) {  			
	  			Boolean primera = true;
	    		this.Existing = [SELECT LAT_MX_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        				WHERE LAT_MX_Product__c =: this.Quota.LAT_MX_Product__c AND LAT_MX_ValiditySince__c <=: this.Quota.LAT_MX_ValidityUntil__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c];
				List <LAT_MX_QTA_Quota__c> lstCuotasAnteriores = [SELECT LAT_MX_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        				WHERE LAT_MX_Product__c =: this.Quota.LAT_MX_Product__c AND LAT_MX_ValidityUntil__c <: this.Quota.LAT_MX_ValiditySince__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c.addDays(-1)];
				Map <String, LAT_MX_QTA_Quota__c> mapCuotasAnteriores = new Map<String, LAT_MX_QTA_Quota__c>();
	    		for (LAT_MX_QTA_Quota__c q : lstCuotasAnteriores) {
					mapCuotasAnteriores.put(q.LAT_MX_Client__c, q);
				}
				List <LAT_MX_QTA_Quota__c> cuotasToUpdate = new List<LAT_MX_QTA_Quota__c>();
				ApexPages.Message errorMsg = null;
				String mensajeError = '';
	    		for (Integer i = 0; i < this.Existing.size(); i++) {  						
			   		if (this.Quota.LAT_MX_ValiditySince__c != null) {
	        			if (this.Quota.LAT_MX_ValiditySince__c >= Date.today()) {
		          			LAT_MX_QTA_Quota__c quotaToUpdate = this.Existing.get(i);
		          			if (mapCuotasAnteriores.get(quotaToUpdate.LAT_MX_Client__c) == null) {	
			          			if ((this.Quota.LAT_MX_ValiditySince__c.addDays(-1)) > quotaToUpdate.LAT_MX_ValiditySince__c) {  
		          					quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
		              				cuotasToUpdate.add(quotaToUpdate);
		              				errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
			       					ApexPages.addMessage(errorMsg);
				        		} else {			          	
					            	quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
					            	quotaToUpdate.LAT_MX_ValiditySince__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-2);
					            	cuotasToUpdate.add(quotaToUpdate);
					            	errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
						       		ApexPages.addMessage(errorMsg);
		            			}    
			        		} else {
			        			if (!primera){
			            			mensajeError += ', ' + i;
			        			} else {
			        				mensajeError += ' ' + i;
			        				primera = false;
			        			}
			        		}	
			      		} else {
			      			errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_3); // Label mesage : 'La fecha de inicio no puede ser anterior a la fecha actual.'
				       		ApexPages.addMessage(errorMsg);
			      		}         
	        		} else {
			    		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_6); // Label mesage : 'Para ajustar la fecha de la cuota debe ingresar una fecha de inicio de la cuota a generar.'
		         		ApexPages.addMessage(errorMsg);	  
			    	}
				}
	  	  		if (mensajeError != '') {
			  		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_9 + mensajeError + Label.LAT_MX_VFC08_Error_Msg_10); // Label mesage : 'No se puede ajustar las siguientes cuotas :' + mensajeError + '. Si desea generar una nueva cuota, elimínelas.'
		      		ApexPages.addMessage(errorMsg);	 
			  	}
			  	if (cuotasToUpdate.size() > 0) {
			  		update cuotasToUpdate;
			  	}
			}
			//MIGRATED 17/11/2016
			else {
	  			Boolean primera = true;
	    		this.Existing = [SELECT LAT_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        				WHERE LAT_Product__c =: this.Quota.LAT_Product__c AND LAT_MX_ValiditySince__c <=: this.Quota.LAT_MX_ValidityUntil__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c];
				List <LAT_MX_QTA_Quota__c> lstCuotasAnteriores = [SELECT LAT_Product__c, LAT_MX_ValiditySince__c, LAT_MX_ValidityUntil__c, LAT_MX_Client__c, LAT_MX_Quota__c, LAT_MX_QuotaBalance__c  FROM LAT_MX_QTA_Quota__c  
				        				WHERE LAT_Product__c =: this.Quota.LAT_Product__c AND LAT_MX_ValidityUntil__c <: this.Quota.LAT_MX_ValiditySince__c AND LAT_MX_ValidityUntil__c >=: this.Quota.LAT_MX_ValiditySince__c.addDays(-1)];
				Map <String, LAT_MX_QTA_Quota__c> mapCuotasAnteriores = new Map<String, LAT_MX_QTA_Quota__c>();
	    		for (LAT_MX_QTA_Quota__c q : lstCuotasAnteriores) {
					mapCuotasAnteriores.put(q.LAT_MX_Client__c, q);
				}
				List <LAT_MX_QTA_Quota__c> cuotasToUpdate = new List<LAT_MX_QTA_Quota__c>();
				ApexPages.Message errorMsg = null;
				String mensajeError = '';
	    		for (Integer i = 0; i < this.Existing.size(); i++) {  						
			   		if (this.Quota.LAT_MX_ValiditySince__c != null) {
	        			if (this.Quota.LAT_MX_ValiditySince__c >= Date.today()) {
		          			LAT_MX_QTA_Quota__c quotaToUpdate = this.Existing.get(i);
		          			if (mapCuotasAnteriores.get(quotaToUpdate.LAT_MX_Client__c) == null) {	
			          			if ((this.Quota.LAT_MX_ValiditySince__c.addDays(-1)) > quotaToUpdate.LAT_MX_ValiditySince__c) {  
		          					quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
		              				cuotasToUpdate.add(quotaToUpdate);
		              				errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
			       					ApexPages.addMessage(errorMsg);
				        		} else {			          	
					            	quotaToUpdate.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-1);
					            	quotaToUpdate.LAT_MX_ValiditySince__c = this.Quota.LAT_MX_ValiditySince__c.addDays(-2);
					            	cuotasToUpdate.add(quotaToUpdate);
					            	errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Confirm_Msg_3); // Label mesage : 'Se ha ajustado la fecha de finalización de la cuota con éxito.'
						       		ApexPages.addMessage(errorMsg);
		            			}    
			        		} else {
			        			if (!primera){
			            			mensajeError += ', ' + i;
			        			} else {
			        				mensajeError += ' ' + i;
			        				primera = false;
			        			}
			        		}	
			      		} else {
			      			errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_3); // Label mesage : 'La fecha de inicio no puede ser anterior a la fecha actual.'
				       		ApexPages.addMessage(errorMsg);
			      		}         
	        		} else {
			    		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_6); // Label mesage : 'Para ajustar la fecha de la cuota debe ingresar una fecha de inicio de la cuota a generar.'
		         		ApexPages.addMessage(errorMsg);	  
			    	}
				}
	  	  		if (mensajeError != '') {
			  		errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_MX_VFC08_Error_Msg_9 + mensajeError + Label.LAT_MX_VFC08_Error_Msg_10); // Label mesage : 'No se puede ajustar las siguientes cuotas :' + mensajeError + '. Si desea generar una nueva cuota, elimínelas.'
		      		ApexPages.addMessage(errorMsg);	 
			  	}
			  	if (cuotasToUpdate.size() > 0) {
			  		update cuotasToUpdate;
			  	}				
			}
  		} catch (Exception e) {
  			//this.Generate();
  		} 	
  		return ;    	
  	}

  	public void EliminarTodos() {
    	if (Existing != null){
      		delete this.Existing;
      		this.Existing.clear();
      		ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.CONFIRM, Label.LAT_MX_VFC08_Error_Msg_7); // Label mesage : 'Se han eliminado las cuotas con éxito.'
      		ApexPages.addMessage(errorMsg);
    	}
    	return;
    }

  	private boolean insertQuotas(Id ProductId) {
    	if(!Utils.wasMigrationDone('12')) {  		
	    	List<Product2> products = [SELECT Id FROM Product2 WHERE id =: ProductId];
	   	 	if (!products.isEmpty()) {
	      		List<LAT_MX_QTA_Quota__c> newQuotas = new List<LAT_MX_QTA_Quota__c>();
	      		Product2 prod = products.get(0);
	      		for(Account account: [SELECT Id FROM Account WHERE recordTypeId IN: setIdRecordType AND type IN ('Payer', 'Consignee')]) {
	        		// cargo cuota 0 a este cliente para todos los productos
	        		LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c();
	        		quota.LAT_MX_Client__c = account.Id;
	        		quota.LAT_MX_Product__c = prod.Id;
	        		quota.LAT_MX_Quota__c = 0;
	        		quota.LAT_MX_QuotaBalance__c = 0;
	        		if (this.Quota.LAT_MX_ValidityUntil__c != null) {
	          			quota.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValidityUntil__c; 
	        		} else {
	          			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR,  Label.LAT_MX_VFC08_Error_Msg_4); // Label mesage : 'Debe seleccionar fecha de inicio y finalización para ingresar la cuota.'
	          			ApexPages.addMessage(errorMsg);
	          			return false;                    
	        		}
	        		if (this.Quota.LAT_MX_ValiditySince__c != null) {
	          			quota.LAT_MX_ValiditySince__c = this.Quota.LAT_MX_ValiditySince__c;
	        		} else {
	          			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR,  Label.LAT_MX_VFC08_Error_Msg_4); // Label mesage : 'Debe seleccionar fecha de inicio y finalización para ingresar la cuota.'
	          			ApexPages.addMessage(errorMsg);
	          			return false;                   
	        		}               
	        		newQuotas.add(quota);            
	        		// si para el proximo se pasa, grabo ahora y limpio la lista
	        		if (newQuotas.size() + products.size() >= MAX_INSERT_SIZE) {
	         			insert newQuotas;
	          			newQuotas.clear();
	        		}
	      		} 
	      		if (newQuotas.size() > 0) {
	          		insert newQuotas;
	      		}
	   	 	}
	    	return true;
	    }
		//MIGRATED 17/11/2016 
	    else {
	    	List<LAT_Product__c> products = [SELECT Id FROM LAT_Product__c WHERE id =: ProductId];
	   	 	if (!products.isEmpty()) {
	      		List<LAT_MX_QTA_Quota__c> newQuotas = new List<LAT_MX_QTA_Quota__c>();
	      		LAT_Product__c prod = products.get(0);
	      		for(Account account: [SELECT Id FROM Account WHERE recordTypeId IN: setIdRecordType AND type IN ('Payer', 'Consignee')]) {
	        		// cargo cuota 0 a este cliente para todos los productos
	        		LAT_MX_QTA_Quota__c quota = new LAT_MX_QTA_Quota__c();
	        		quota.LAT_MX_Client__c = account.Id;
	        		quota.LAT_Product__c = prod.Id;
	        		quota.LAT_MX_Quota__c = 0;
	        		quota.LAT_MX_QuotaBalance__c = 0;
	        		if (this.Quota.LAT_MX_ValidityUntil__c != null) {
	          			quota.LAT_MX_ValidityUntil__c = this.Quota.LAT_MX_ValidityUntil__c; 
	        		} else {
	          			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR,  Label.LAT_MX_VFC08_Error_Msg_4); // Label mesage : 'Debe seleccionar fecha de inicio y finalización para ingresar la cuota.'
	          			ApexPages.addMessage(errorMsg);
	          			return false;                    
	        		}
	        		if (this.Quota.LAT_MX_ValiditySince__c != null) {
	          			quota.LAT_MX_ValiditySince__c = this.Quota.LAT_MX_ValiditySince__c;
	        		} else {
	          			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR,  Label.LAT_MX_VFC08_Error_Msg_4); // Label mesage : 'Debe seleccionar fecha de inicio y finalización para ingresar la cuota.'
	          			ApexPages.addMessage(errorMsg);
	          			return false;                   
	        		}               
	        		newQuotas.add(quota);            
	        		// si para el proximo se pasa, grabo ahora y limpio la lista
	        		if (newQuotas.size() + products.size() >= MAX_INSERT_SIZE) {
	         			insert newQuotas;
	          			newQuotas.clear();
	        		}
	      		} 
	      		if (newQuotas.size() > 0) {
	          		insert newQuotas;
	      		}
	   	 	}
	    	return true;	    	
	    }
  	}
}