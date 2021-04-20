public with sharing class LAT_Price_Channel_ARG_Controller {
    public class AplicationException extends Exception {}

    public static void updateAN8Patron(List<LAT_Price_Channel_ARG__c> lstNewValues, Map<Id,LAT_Price_Channel_ARG__c> mapOldValues) {
        List<LAT_B2B_Price_Configs__c> lstCustomSettings = null;
        List<LAT_B2B_Price_Configs__c> lstInsert = null;
        List<LAT_B2B_Price_Configs__c> lstUpdate = null;
        LAT_B2B_Price_Configs__c objB2BPriceConfig = null;
        Map<Id, UDC__c> mapUDC = null;
        Map<Id, Account> mapAccount = null;
        Set<Id> setAccountIds = null;
        String strExternalId = null;

        System.debug('updateAN8Patron [lstNewValues : ' + lstNewValues + ' - mapOldValues : ' + mapOldValues + '] ->');

        mapUDC = new Map<ID, UDC__c>([SELECT Id, Internal_Id__c, Name FROM UDC__c WHERE CodProd__c = '01' AND CodUs__c = '03']);
        lstCustomSettings = new List<LAT_B2B_Price_Configs__c>([SELECT Id, LAT_InternalId__c, LAT_Account__c FROM LAT_B2B_Price_Configs__c]);
        setAccountIds = new Set<Id>();
        lstInsert = new List<LAT_B2B_Price_Configs__c>();
        lstUpdate = new List<LAT_B2B_Price_Configs__c>();

        if(lstNewValues != null && !lstNewValues.isEmpty()) {
            for(LAT_Price_Channel_ARG__c objPriceChannel : lstNewValues) { 
                if(String.isNotBlank(objPriceChannel.LAT_Cliente_Patron__c)) {
                    setAccountIds.add(objPriceChannel.LAT_Cliente_Patron__c);
                }
            }
            System.debug('updateAN8Patron [setAccountIds : ' + setAccountIds + ']');

            mapAccount = new Map<Id, Account>([SELECT Id, Client_Code_AN8__c FROM Account WHERE Id IN :setAccountIds]);
            
            System.debug('updateAN8Patron [mapAccount : ' + mapAccount + ']');

            for(LAT_Price_Channel_ARG__c objPriceChannel : lstNewValues) {
                objB2BPriceConfig = null;
                if(mapOldValues == null || !mapOldValues.containsKey(objPriceChannel.Id) || objPriceChannel.LAT_Cliente_Patron__c <> mapOldValues.get(objPriceChannel.Id).LAT_Cliente_Patron__c) {                    
                    if(mapUDC.containsKey(objPriceChannel.LAT_SubChannel__c)) {
                        strExternalId = mapUDC.get(objPriceChannel.LAT_SubChannel__c).Internal_Id__c; 

                        if(String.isNotBlank(strExternalId)) {
                            for(LAT_B2B_Price_Configs__c objCustomSettings : lstCustomSettings) {
                                System.debug('updateAN8Patron [comparando... -> Internal id : ' + objCustomSettings.LAT_InternalId__c + ' - strExternalId : ' + strExternalId + ']');
                                System.debug('updateAN8Patron [comparando... -> el mapa contiene el cliente : ' + mapAccount.containsKey(objPriceChannel.LAT_Cliente_Patron__c) + ' - strExternalId : ' + strExternalId + ']');
                                if(objCustomSettings.LAT_InternalId__c == strExternalId && mapAccount.containsKey(objPriceChannel.LAT_Cliente_Patron__c)) {
                                    objB2BPriceConfig = objCustomSettings;
                                    objB2BPriceConfig.LAT_Account__c = mapAccount.get(objPriceChannel.LAT_Cliente_Patron__c).Client_Code_AN8__c;
                                    
                                    System.debug('updateAN8Patron [actualizamos... ]');

                                    lstUpdate.add(objB2BPriceConfig);
                                }
                            }

                            System.debug('updateAN8Patron [comparando... -> el mapa contiene el cliente : ' + mapAccount.containsKey(objPriceChannel.LAT_Cliente_Patron__c) + ' - strExternalId : ' + strExternalId + ']');
                            if(objB2BPriceConfig == null && mapAccount.containsKey(objPriceChannel.LAT_Cliente_Patron__c)) {
                                objB2BPriceConfig = new LAT_B2B_Price_Configs__c();
                                objB2BPriceConfig.Name = mapUDC.get(objPriceChannel.LAT_SubChannel__c).Name;
                                objB2BPriceConfig.LAT_InternalId__c = strExternalId;
                                objB2BPriceConfig.LAT_Account__c = mapAccount.get(objPriceChannel.LAT_Cliente_Patron__c).Client_Code_AN8__c;

                                System.debug('updateAN8Patron [insertamos... ]');

                                lstInsert.add(objB2BPriceConfig);
                            }
                        }
                    }      
                }
            }

            update lstUpdate;
            insert lstInsert;
        }

        System.debug('updateAN8Patron [] <-');
    }

    public static void validateOnlyOneChannelIsActive(List<LAT_Price_Channel_ARG__c> lstNewValues) {
        Set<Id> setChannelId = null;
        List<LAT_Price_Channel_ARG__c> lstSubchannels = null;
        String strException = null;
        Boolean boolIsFirst = null;

        System.debug('validateOnlyOneChannelIsActive [lstNewValues : ' + lstNewValues + '] ->');

        setChannelId = new Set<Id>();
        for(LAT_Price_Channel_ARG__c objPriceChannel : lstNewValues) { 
            if(String.isNotBlank(objPriceChannel.LAT_SubChannel__c)) {
                setChannelId.add(objPriceChannel.LAT_SubChannel__c);
            }
        }
        
        lstSubchannels = [SELECT Id, LAT_SubChannel__r.Name FROM LAT_Price_Channel_ARG__c WHERE LAT_SubChannel__c IN: setChannelId];
        if(!lstSubchannels.IsEmpty()) {
            strException = 'Los siguientes subcanales : ';
            boolIsFirst = true;
            for(LAT_Price_Channel_ARG__c objPriceChannel : lstSubchannels) {
                if(boolIsFirst) {
                    boolIsFirst = false;
                } else {
                    strException += ' , ';    
                }
                strException += '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + objPriceChannel.Id + '" target="_blank">' + objPriceChannel.LAT_SubChannel__r.Name + '</a>';
            }
            strException +=  ' ya estan cargados en el sistema.';

            if(lstNewValues.size() == 1) {
                lstNewValues[0].addError(strException, false);
            } else {
                throw new AplicationException(strException);
            }
        }

        System.debug('validateOnlyOneChannelIsActive [] <-');
    }
}