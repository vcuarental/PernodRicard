/********************************************************************************************
*                                       Company: ValueNet
*-------------------------------------------------------------------------------------------*
*   Clase para filtrar los registros en triggers por sus RecordTypes
********************************************************************************************/

public with sharing class LAT_Trigger {
    
    private List<Sobject> triggerNew;
    private List<Sobject> triggerOld;
    
    public LAT_Trigger(String SObjectType, set<String> rts){
    	set<Id> setIdRt = Global_RecordTypeCache.getRtIdSet(SObjectType, rts);
    	if(trigger.isUpdate || trigger.isInsert){
    		triggerNew = new List<Sobject>();
	    	for(Sobject obj: trigger.new){
	    		if(setIdRt.contains((Id)obj.get('RecordTypeId'))){
		    		triggerNew.add(obj);
		    	}
	    	}
    	}
    	if(trigger.isUpdate || trigger.isDelete){
    		triggerOld = new List<Sobject>();
		    for(Sobject obj: trigger.old){
	    		if(setIdRt.contains((Id)obj.get('RecordTypeId'))){
		    		triggerOld.add(obj);
		    	}
	    	}			
		}
    }
    
    //Cada metodo devuelve su coleccion filtrada por RecordType
    public list<Sobject> getNew(){
    	return triggerNew;
    }
    public list<Sobject> getOld(){
    	return TriggerOld;
    }
    
    /*TEST CODE IN LAT_Trigger_TEST CLASS*/
}