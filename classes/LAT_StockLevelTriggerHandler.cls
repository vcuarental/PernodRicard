public with sharing class LAT_StockLevelTriggerHandler {

    public static void updateLatStockLevel(Map<Id,Lat_stock__c> oldValues, List<Lat_stock__c> newValues,Boolean isUpdate) {

        if(isUpdate){
            //Re calculate Stock level if stock/safety changed 
            for(Lat_stock__c ls : newValues){
                if(ls.Lat_stock__c != oldValues.get(ls.Id).Lat_stock__c 
                    || ls.LAT_Safety_Stock__c != oldValues.get(ls.Id).LAT_Safety_Stock__c){

                    if(ls.Lat_stock__c == 0 ){
                        ls.Lat_StockLevel__c = 'No Stock';
                    }else{
                        if(ls.LAT_Safety_Stock__c == null ){
                            ls.Lat_StockLevel__c = 'Unknown';
                        }else{
                            if(ls.LAT_Stock__c > ls.LAT_Safety_Stock__c){
                                ls.Lat_StockLevel__c = 'Ok';
                            }else if(ls.LAT_Stock__c < ls.LAT_Safety_Stock__c){
                                ls.Lat_StockLevel__c = 'Low';
                            }
                        }
                    }
                }
            }
        }
        if(!isUpdate){
                for(Lat_stock__c ls : newValues){
                    if(ls.Lat_stock__c == 0 ){
                        ls.Lat_StockLevel__c = 'No Stock';
                    }else{
                        if(ls.LAT_Safety_Stock__c == null ){
                            ls.Lat_StockLevel__c = 'Unknown';
                        }else{
                            if(ls.LAT_Stock__c > ls.LAT_Safety_Stock__c){
                                ls.Lat_StockLevel__c = 'Ok';
                            }else if(ls.LAT_Stock__c < ls.LAT_Safety_Stock__c){
                                ls.Lat_StockLevel__c = 'Low';
                            }
                        }
                    }
                }
        }
    }



}