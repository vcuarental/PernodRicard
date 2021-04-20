/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Gabarito_de_Execucao__c
*******************************************************************************/

public with sharing class LAT_BR_AP01_GabaritodeExecucao {
	
	/*****************************************************************************************
    * Nombre del metodo: validateOnlyOneGabarito
    * Descripcion: Metodo que valida que el CheckList de Visita solo tenga un Gabarito
    * Desarrollador: Waldemar Mayo
    * Fecha: 19/02/2014
    * Modo: before insert
    *****************************************************************************************/
    public static void validateOnlyOneGabarito(List<Gabarito_de_Execucao__c> triggerNew){
    	map<Id, Integer> mapIdChecCantGab = new map<Id, Integer>();
    	
    	for(Gabarito_de_Execucao__c gab: triggerNew){
    		if(mapIdChecCantGab.containsKey(gab.Checklist_de_Visita__c)){
    			Integer auxCant = mapIdChecCantGab.get(gab.Checklist_de_Visita__c);
    			mapIdChecCantGab.put(gab.Checklist_de_Visita__c, auxCant+1);
    		}else{
    			mapIdChecCantGab.put(gab.Checklist_de_Visita__c, 1);
    		}
    	}
    	for(Gabarito_de_Execucao__c gabOnDB: [SELECT Id, Checklist_de_Visita__c FROM Gabarito_de_Execucao__c WHERE Checklist_de_Visita__c IN: mapIdChecCantGab.keySet()]){
    		Integer auxCant = mapIdChecCantGab.get(gabOnDB.Checklist_de_Visita__c);
    		mapIdChecCantGab.put(gabOnDB.Checklist_de_Visita__c, auxCant+1);
    	}
    	
    	for(Gabarito_de_Execucao__c gab: triggerNew){
    		if(mapIdChecCantGab.containsKey(gab.Checklist_de_Visita__c) && mapIdChecCantGab.get(gab.Checklist_de_Visita__c) > 1){
    			gab.addError(Label.LAT_BR_BTN01_00003);
    			//Label.LAT_BR_BTN01_00003 = Não é possível a criação de mais de um Gabarito de Execução no mesmo CheckList de Visita. Se deseja alterar o Gabarito, clique em Editar
    		}
    	}
    }
    
    /*****************************************************************************************
    * Nombre del metodo: lastGabaritoValido
    * Descripcion: Makes the checkList of the last Gabarito created or Updated Valido
    * Desarrollador: Denis Aranda
    * Fecha: 19/02/2014
    * Modo: After Insert, After update
    *****************************************************************************************/
    public static void lastGabaritoValidoInsUpd(List<Gabarito_de_Execucao__c> triggerNew){
    	
    	set<String> mapAccountMonthYear = new set<String>();
    	set<Id> setIdCheckToValidUpdate = new set<Id>();
    	Set<String> setCheckId = new Set<String>();
    	set<Date> setMonthYear = new set<Date>();
    	set<Id> setAccounts = new set<Id>();
    	
    	for(Gabarito_de_Execucao__c gab: triggerNew){
    		setCheckId.add(gab.Checklist_de_Visita__c);
    	}
    	
    	for(Checklist_de_visita__c che: [SELECT id, Name, LAT_BR_ValidOnTradeChecklistGE__c, Visita__r.Conta__c, Visita__r.Planejamento__r.LAT_MonthYear__c FROM Checklist_de_visita__c WHERE Id IN: setCheckId]){
    		setAccounts.add(che.Visita__r.Conta__c);
    		setMonthYear.add(che.Visita__r.Planejamento__r.LAT_MonthYear__c);
    		if(!mapAccountMonthYear.contains(che.Visita__r.Conta__c+'-'+che.Visita__r.Planejamento__r.LAT_MonthYear__c)){
    			mapAccountMonthYear.add(che.Visita__r.Conta__c+'-'+che.Visita__r.Planejamento__r.LAT_MonthYear__c);
    			setIdCheckToValidUpdate.add(che.Id);
    		}
    	}
    	
    	List<Checklist_de_visita__c> listCheckToUpdate = new List<Checklist_de_visita__c>();
    	for(Checklist_de_visita__c che: [SELECT id, Name, LAT_BR_ValidOnTradeChecklistGE__c, Visita__r.Conta__c, Visita__r.Planejamento__r.LAT_MonthYear__c FROM Checklist_de_visita__c WHERE Visita__r.Conta__c IN: setAccounts AND Visita__r.Planejamento__r.LAT_MonthYear__c IN: setMonthYear]){
    		if(mapAccountMonthYear.contains(che.Visita__r.Conta__c+'-'+che.Visita__r.Planejamento__r.LAT_MonthYear__c)){
	    		if(setIdCheckToValidUpdate.contains(che.Id)){
	    			if(!che.LAT_BR_ValidOnTradeChecklistGE__c){
		    			che.LAT_BR_ValidOnTradeChecklistGE__c = true;
		    			listCheckToUpdate.add(che);
	    			}
	    		}else{
	    			if(che.LAT_BR_ValidOnTradeChecklistGE__c){
		    			che.LAT_BR_ValidOnTradeChecklistGE__c = false;
		    			listCheckToUpdate.add(che);
	    			}
	    		}
    		}
    	}
    	update listCheckToUpdate;
    }
    
    /*****************************************************************************************
    * Nombre del metodo: lastGabaritoValido
    * Descripcion: Makes the checkList of the last Gabarito created or Updated Valido
    * Desarrollador: Denis Aranda
    * Fecha: 19/02/2014
    * Modo: After Delete
    *****************************************************************************************/
    public static void lastGabaritoValidoDel(List<Gabarito_de_Execucao__c> triggerOld){
    	Set<String> setIdCheck = new Set<String>();
    	
    	for(Gabarito_de_Execucao__c gab: triggerOld){
    		setIdCheck.add(gab.Checklist_de_visita__c);
    	}
    	List<Checklist_de_visita__c> listTriggerOldtoUpdate = [SELECT id, Name, LAT_BR_ValidOnTradeChecklistGE__c FROM Checklist_de_visita__c WHERE Id IN: setIdCheck AND LAT_BR_ValidOnTradeChecklistGE__c =: true];
    	for(Checklist_de_visita__c trig: listTriggerOldtoUpdate){
    		trig.LAT_BR_ValidOnTradeChecklistGE__c = false;
    	}
    	
    	update listTriggerOldtoUpdate;
    }

    /**********************************************************************************************
    * Nombre del metodo: Check menu section
    * Descripcion: if Listed products is yes, no products will be allowed to be added in not listed
    * Desarrollador: Mariano Boezio
    * Fecha: 29/07/2015
    * Modo: Before Insert, Before update
    ***********************************************************************************************/
    public static void validateMenuSection(List<Gabarito_de_Execucao__c> triggerNew){
        for (Gabarito_de_Execucao__c ge: triggerNew) {
            if (ge.LAT_BR_GDE_Products_Listed_on_Menues__c == 'Sim') {
                ge.LAT_BR_GDE_Not_Listed_Brands__c = '';
            }
        }

    }
}