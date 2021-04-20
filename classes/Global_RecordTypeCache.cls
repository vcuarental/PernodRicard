/********************************************************************************************
*                                       Company: ValueNet
*-------------------------------------------------------------------------------------------*
*   Clase que maneja los registros del object RecordType en memoria para no consumir Querys
********************************************************************************************/

public with sharing class Global_RecordTypeCache {
    
    private static map<String, List<RecordType>> mapObjTypeListRt = new map<String, List<RecordType>>();
    private static map<String, RecordType> mapObjTypeDevNameId = new map<String, RecordType>();
    private static map<Id, RecordType> mapIdRt = new map<Id, RecordType>();
    
    static{
        //Este metodo funciona como "Constructor" y su unica funcion es cargar los mapas
        mapIdRt = new map<Id, RecordType>([SELECT Id, DeveloperName, Description, Name, IsActive, SystemModstamp, SobjectType, NamespacePrefix, LastModifiedDate, LastModifiedById, IsPersonType, CreatedDate, CreatedById, BusinessProcessId FROM RecordType]);
        for(RecordType rt: mapIdRt.values()){
            mapObjTypeDevNameId.put(rt.SobjectType+rt.DeveloperName, rt);
            
            if(mapObjTypeListRt.containsKey(rt.SobjectType)){
                mapObjTypeListRt.get(rt.SobjectType).add(rt);
            }else{
                mapObjTypeListRt.put(rt.SobjectType, new List<RecordType>{rt});
            }
        }
    }
    
    public static RecordType getRt(Id rtId){
        //Recibe el Id de un RecordType y devuelve el registro entero del RecordType
        return mapIdRt.get(rtId);
    }
    public static RecordType getRtRec(String SobjectTypeDevName){
        //Recibe la concatenacion del SObjectType+DeveloperName y devuelve el registro entero del RecordType
        return mapObjTypeDevNameId.get(SobjectTypeDevName);
    }
    public static Id getRtId(String SobjectTypeDevName){
        //Recibe la concatenacion del SObjectType+DeveloperName y devuelve el Id del RecordType
        Id idReturn;
        if(mapObjTypeDevNameId.containsKey(SobjectTypeDevName)){idReturn = mapObjTypeDevNameId.get(SobjectTypeDevName).Id;}
        return idReturn;
    }
    public static List<RecordType> getRtList(String SobjectType){
        //Recibe un tipo de SObject y devuelve la lista de RecordTypes de ese tipo, si el tipo de object no se encuentra devuelve una lista vacia 
        List<RecordType> listRt = new List<RecordType>();
        if(mapObjTypeListRt.containsKey(SobjectType)){listRt = mapObjTypeListRt.get(SobjectType);}
        return listRt;
    }
    public static set<Id> getRtIdSet(String SobjectType, Set<String> setDevName){
        //Recibe un set con los DeveloperNames y un String que contiene el SObjectType. Devuelve una set con los Ids de los RecordTypes si encuentra todos, sino devuelve un set vacio
        set<Id> setRtId = new set<Id>();
        for(RecordType rt: mapObjTypeListRt.get(SobjectType)){
            if(setDevName.contains(rt.DeveloperName)){
                setRtId.add(rt.id);
            }
        }
        if(setDevName.size() != setRtId.size()){setRtId = new set<Id>();}
        return setRtId;
    }
    
}