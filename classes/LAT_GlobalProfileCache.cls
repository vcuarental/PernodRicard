/********************************************************************************************
*                                       Company: ValueNet
*-------------------------------------------------------------------------------------------*
*   Clase que maneja los registros del object Profile en memoria para no consumir Querys
********************************************************************************************/

public with sharing class LAT_GlobalProfileCache {
    
    private static map<String, Profile> mapNameProfile = new map<String, Profile>();
    private static map<Id, Profile> mapIdProfile = new map<Id, Profile>();
    
    static{
        //Este metodo funciona como "Constructor" y su unica funcion es cargar los mapas
        mapIdProfile = new map<Id, Profile>([SELECT Id, Description, CreatedDate, CreatedById, Name, LastModifiedDate, UserType, UserLicenseId, LastModifiedById, IsSsoEnabled FROM Profile]);
        for(Profile prof: mapIdProfile.values()){
            mapNameProfile.put(Prof.Name, prof);
        }
    }
    
    public static Profile getProfileById(Id profId){
        //Recibe el Id de un Profile y devuelve el registro entero del Profile
        return mapIdProfile.get(profId);
    }
    public static String getProfileNameById(Id profId){
        //Recibe el Id de un Profile y devuelve el Name del Profile
        if(mapIdProfile.containsKey(profId)){
            return mapIdProfile.get(profId).Name;
        }
        return null;
    }
    
    public static Profile getProfileByName(String profName){
        //Recibe el name del Profile y devuelve el registro entero del Profile
        return mapNameProfile.get(profName);
    }
    public static Id getProfileIdByName(String profName){
        //Recibe el name del Profile y devuelve el registro entero del Profile
        if(mapNameProfile.containsKey(profName)){
            return mapNameProfile.get(profName).Id;
        }
        return null;
    }    
    public static List<Profile> getAllProfiles(){
        return mapIdProfile.values();
    }
    
    public static Id getStandardAdminProfileId(){
        //Devuelve el Id del perfil admin standard
        for(String profName: mapNameProfile.keySet()){
            //if(profName == 'LAT_SystemAdministrator' || profName == 'System Administrator'  || profName == 'Administrador do sistema' || profName == 'Administrador del sistema'){
            if(profName == 'LAT_SystemAdministrator'){
                return mapNameProfile.get(profName).Id;
             }
        }
        return null;
    }

    public static Set<Id> getProfileIdsByName(Set<String> setProfNames){
        //Recibe un set con names de Profiles y devuelve un set de Ids de Profiles
        Set<Id> setProfilesId = new Set<Id>();
        for(String profName: mapNameProfile.keySet()){
            if(setProfNames.contains(profName)){
                setProfilesId.add(mapNameProfile.get(profName).Id);
            }
        }
        return setProfilesId;
    }
}