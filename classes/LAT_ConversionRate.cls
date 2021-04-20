/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 03/11/2016
*
********************************************************************************/

public with sharing class LAT_ConversionRate {
    
    public static Map<String,id> getOpportunityMapping(String Country, List<OpportunityLineItem> triggerNew, String DestinyUnit) {
        Map<String,id> mapeoKey = new Map<String,id>();
        for(OpportunityLineItem oppIt: triggerNew){
            if(oppIt.Sku__c != null && oppIt.CD_unit__c != null){
                String keyMap = Country+'-'+oppIt.Sku__c+'-'+oppIt.CD_unit__c+'-'+ DestinyUnit;
                mapeoKey.put(keyMap,oppIt.id);
            }    
        }

        return mapeoKey;
    }
    
    //MIGRATED 03/11/2016
    public static Map<String,id> getOpportunityMapping(String Country, List<LAT_OpportunityLineItem__c> triggerNew, String DestinyUnit) {
        Map<String,id> mapeoKey = new Map<String,id>();
        for(LAT_OpportunityLineItem__c oppIt: triggerNew){
            if(oppIt.LAT_Sku__c != null && oppIt.LAT_CDUnit__c != null){
                String keyMap = Country+'-'+oppIt.LAT_Sku__c+'-'+oppIt.LAT_CDUnit__c+'-'+ DestinyUnit;
                mapeoKey.put(keyMap,oppIt.id);
            }    
        }

        return mapeoKey;
    }

    public static Map<String,Double> ConversionRateCalculation(MAP<String,id> mapConvRates) {
        
        if(!Utils.wasMigrationDone('12')) {
            Map<String,Double> porcentajes = new Map<String,Double>();
            if(mapConvRates != null){
                List <LAT_UnitConversionRates__c> convRates = [SELECT id, Destino__c, Origen__c, SKU__c, KeyUnica__c, 
                                                                      Factor__c FROM LAT_UnitConversionRates__c 
                                                                      WHERE KeyUnica__c IN: mapConvRates.keySet()];
                for(LAT_UnitConversionRates__c conv : convRates){
                    porcentajes.put(conv.KeyUnica__c,conv.Factor__c);
                }
            }  
            return porcentajes;
        } 
        //MIGRATED 03/11/2016
        else{
            Map<String,Double> porcentajes = new Map<String,Double>();
            if(mapConvRates != null){
                List <LAT_UnitConversionRates__c> convRates = [SELECT id, Destino__c, Origen__c, LAT_Product__c, LAT_KeyUnica__c, 
                                                                      Factor__c FROM LAT_UnitConversionRates__c 
                                                                      WHERE LAT_KeyUnica__c IN: mapConvRates.keySet()];
                for(LAT_UnitConversionRates__c conv : convRates){
                    porcentajes.put(conv.LAT_KeyUnica__c,conv.Factor__c);
                }
            }  
            return porcentajes;            
        } 
    }
}