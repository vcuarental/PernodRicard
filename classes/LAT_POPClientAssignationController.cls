public without sharing class LAT_POPClientAssignationController {
    public LAT_ClientPOP__c dumbClientPOP {get; set;}
    public Visitas__c visita {get;set;}
    public Account cliente {get;set;}
    public boolean saveAgain {get;set;}

    
    public LAT_POPClientAssignationController() {
        saveAgain = false;
        dumbClientPOP = new LAT_ClientPOP__c();
    	
        String visitaId = System.currentPageReference().getParameters().get('vId');
        String clientId = System.currentPageReference().getParameters().get('cId');

		
        if ( visitaId != null) {
        	List<Visitas__c> vList = [SELECT id, Name,Status__c, Conta__c,Conta__r.NAme, Data_da_Visita__c FROM Visitas__c WHERE id =: visitaId];
	    	if (vList.get(0) != null) {
	    		visita = vList.get(0);
	    	}
        }
        if ( clientId != null) {
            List<Account> vList = [SELECT id FROM Account WHERE id =: clientId];
            if (vList.get(0) != null) {
                cliente = vList.get(0);
            }
        }
	}
    
    public PageReference cancelBtn() {
        if(!saveAgain){
             return new PageReference('/' + (visita != null ? visita.id : cliente.id)); 
        }else{
            saveAgain = false;
            return null;
            
        } 
    }
 
    public PageReference doSave() {
    	   if(visita != null || cliente != null){
                Integer leftAmount = 0;
                dumbClientPOP.LAT_Client__c = (visita != null ? visita.Conta__c : cliente.id);
                dumbClientPOP.visita__c = (visita != null ? visita.id : null);
                Boolean match = false;
                List<LAT_KAMPOP__c> tmpKAMPOP =  [SELECT id, Amount__c, Planned__c, AmountLeft__c, RegionalPOP__c, PlanningLeft__c FROM LAT_KAMPOP__c where KAM__c =: userinfo.getUserId()  AND AmountLeft__c > 0 AND RegionalPOP__r.product__c =: dumbClientPOP.Material_POP__c];
                if(tmpKAMPOP != null && tmpKAMPOP.size() >0){
                    match = true;
                    leftAmount = Integer.valueOf(tmpKAMPOP[0].AmountLeft__c);
                }
                if(match){
                    try{
                        if(dumbClientPOP.LAT_Planned__c > leftAmount && !saveAgain){
                            saveAgain = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,Label.LAT_Processes_005));          
                            return null;
                        }
                        insert dumbClientPOP;
                        return new PageReference('/' + (visita != null ? visita.id : cliente.id)); 
                    }catch(exception e){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error ' + e.getMessage()));          
                    }  
                                    
               }else{
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_Processes_020);
                    ApexPages.addMessage(errorMsg);
               }
           }
    	return null;
    }

   


}