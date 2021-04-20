/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | ESN_CheckIn__c                                                                         |
|     - Description     | Show on a map all last locations of all peoples                                        |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 16/07/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public class ESN_VFC22_AllCheckInMap {
    
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    public Map<String,ESN_CheckIn__c> userId2listCheckIn_map {get;set;}
    public List<ESN_CheckIn__c> userLastCheckIn_list {get;set;}
    public List<String> userName_list {get;set;}
    public String message {get;set;}
    
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    public ESN_VFC22_AllCheckInMap(){
        message = '';
        userId2listCheckIn_map = new Map<String,ESN_CheckIn__c>();
        userName_list = new List<String>();
        
        List<ESN_CheckIn__c> searchList = [SELECT Id, ESN_User__c, ESN_User__r.Name, ESN_User__r.FullPhotoURL, ESN_User__r.SmallPhotoURL, ESN_LocationName__c, ESN_Geolocation__Latitude__s, ESN_Geolocation__Longitude__s, ESN_Date__c, ESN_Address__c FROM ESN_CheckIn__c ORDER BY ESN_Date__c DESC];
        
        for(ESN_CheckIn__c ci : searchList) {            
            if(userId2listCheckIn_map.containsKey(ci.ESN_User__r.Name)){
                if(userId2listCheckIn_map.get(ci.ESN_User__r.Name).ESN_Date__c < ci.ESN_Date__c){
                    userId2listCheckIn_map.put(ci.ESN_User__r.Name,ci);
                }
            } else {
                userId2listCheckIn_map.put(ci.ESN_User__r.Name,ci);
                userName_list.add(ci.ESN_User__r.Name);
            }
        }
        
        //userName_list = new List<String>(userId2listCheckIn_map.KeySet());
        //userName_list.sort();
        userLastCheckIn_list = userId2listCheckIn_map.Values();
    }
}