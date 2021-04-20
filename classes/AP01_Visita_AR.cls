/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto Visita__c
*******************************************************************************/

public with sharing class AP01_Visita_AR {
   
  /*****************************************************************************************
    * Nombre del metodo: generateName
    * Descripcion: Completa el nombre de las visitas con diferentes datos
    * Desarrollador: Waldemar Mayo
    * Fecha: 16/10/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void generateName(List<Visitas__c> triggerNew){
    	
        set<id> setIdsPlane = new Set<id>();
        set<id> setIdsAcc = new Set<id>();
        for(Visitas__c visit:triggerNew){
        	if(visit.Conta__c != null){
        		setIdsAcc.add(visit.Conta__c);
        	}
        	if(visit.Planejamento__c != null){
        		setIdsPlane.add(visit.Planejamento__c);
        	}
        }
        
        map<Id, Planejamento__c> mapIdPlane = new map<Id, Planejamento__c>([SELECT Id, M_s_de_Ref_rencia__c, Ano_de_Referencia__c, Owner.FirstName, Owner.LastName FROM  Planejamento__c WHERE id IN : setIdsPlane]);
        map<Id, Account> mapIdAcc= new map<Id, Account>([SELECT Id, Name, AccountNumber FROM  Account WHERE id IN : setIdsAcc]);
        
        map<String, String> mapValueLabel = new map<String, String>();
        for(Schema.PicklistEntry entry: Planejamento__c.M_s_de_Ref_rencia__c.getDescribe().getPicklistValues()){
        	mapValueLabel.put(entry.getValue(), entry.getLabel());
        }
        
        for(Visitas__c visit: triggerNew){
            if(visit.Conta__c != null && visit.Planejamento__c != null && mapIdAcc.containsKey(visit.Conta__c) && mapIdPlane.containsKey(visit.Planejamento__c)){
            	String visName = '';
            	visName += mapValueLabel.get(mapIdPlane.get(visit.Planejamento__c).M_s_de_Ref_rencia__c);
            	visName += '/';
            	visName += mapIdPlane.get(visit.Planejamento__c).Ano_de_Referencia__c;
            	visName += mapIdAcc.get(visit.Conta__c).AccountNumber != null ? (' - '+mapIdAcc.get(visit.Conta__c).AccountNumber):'';
            	visName += ' - ';
            	visName += mapIdAcc.get(visit.Conta__c).Name;
            	visName += ' - ';
            	visName += mapIdPlane.get(visit.Planejamento__c).Owner.FirstName;
            	visName += ' ';
            	visName += mapIdPlane.get(visit.Planejamento__c).Owner.LastName;
            	
            	if(visName.length()>80){
            		visName = visName.substring(0, 80);
            	}
            	
            	visit.Name = visName;
            }
        }
    }
    
    /*********************************************************************************************************
    * Nombre del metodo: VisitaClientWorkHours
    * Descripcion: fills a lookup in visita to Client Work Hours
    * Desarrollador: Denis Aranda
    * Fecha: 11/10/2013
    * Modo: before insert, before update
    *********************************************************************************************************/
    public static void visitaClientWorkHours(List<Visitas__c> triggerNew){
    	
    	List<id> listIdAcc = new List <id>();
    	for(Visitas__c vis: triggerNew){
    		listIdAcc.add(vis.Conta__c);
    	}
    	
    	map<Id, Id> mapAccIdCWH = new map<Id, Id>();
    	for(LAT_CWH_ClientWorkHour__c listCWH: [SELECT id, Name, Account__c, AccountId__c FROM LAT_CWH_ClientWorkHour__c WHERE Account__c IN: listIdAcc ]){
    		mapAccIdCWH.put(listCWH.Account__c, listCWH.id);
    	}
    	
    	for(Visitas__c vis: triggerNew){
    		if(mapAccIdCWH.containsKey(vis.Conta__c)){
    			vis.Client_Work_Hour__c = mapAccIdCWH.get(vis.Conta__c);
    		}
    	}
	}

    public static void shareRecordsWithAccountOwner(List<Visitas__c> triggerNew){
        
        List<Planejamento__Share> toUpdate = new List<Planejamento__Share>(); 
        List<id> tmpIds = new List<id>();
        Set<String> setToUpdate = new Set<String>();

        for (Visitas__c visita : triggerNew){
            tmpIds.add(visita.id);
        }

        List<Visitas__c> visitas = [Select id, Conta__c, Conta__r.OwnerId, Planejamento__c From Visitas__c Where id in :tmpIds];

        for(Visitas__c visita :visitas){
            if(!setToUpdate.contains(visita.Conta__r.OwnerId + '' + visita.Planejamento__c)){
                Planejamento__Share jobShr  = new Planejamento__Share();
                jobShr.ParentId = visita.Planejamento__c;
                jobShr.UserOrGroupId = visita.Conta__r.OwnerId;
                jobShr.AccessLevel = 'Read';
                jobShr.RowCause = 'Manual';

                toUpdate.add(jobShr);

                setToUpdate.add(visita.Conta__r.OwnerId + '' + visita.Planejamento__c);
            }
        }

        if (!toUpdate.isEmpty()){

            try{
                Database.insert(toUpdate,false);
            }catch(exception ex){
                LAT_DebugUtil debugUtil = new LAT_DebugUtil();
                debugUtil.addData('Exception:' + ex.getMessage() + ' Line: ' + ex.getLineNumber() + ' Cause: ' + ex.getCause());
                debugUtil.setOrigin('LAT VISITA/PLANEJAMENTO');
                debugUtil.insertDebug();
            }
        }
    }
}