/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Opportunity Products
********************************************************************************/
/********************************************************************************
*                       
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 04/11/2016
*
********************************************************************************/

public without sharing class LAT_MX_AP02_OpportunityProductsWOS{
       

    /*****************************************************************************************
    * Nombre del metodo: updatesAvailableCreditLimit
    * Descripcion: Metodo que carga en un set los Ids de los Accounts de los cuales se debe 
                   recalcular el Available Credit Limit y llama a la clase que realiza el calculo
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 09/12/2013
    * Modo: after insert, after update, after delete
    *****************************************************************************************/
    public static void updatesAvailableCreditLimit(List<OpportunityLineItem> triggerNew, Map<Id,OpportunityLineItem> oldMap){
        
        Set<String> setOppsIds = new Set<String>();
        
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(OpportunityLineItem oli: triggerNew){
                if(oldMap.isEmpty() || (!oldMap.isEmpty() && oldMap.containsKey(oli.Id) && (oli.TotalPrice != oldMap.get(oli.Id).TotalPrice || oli.cd_line_status__c != oldMap.get(oli.Id).cd_line_status__c))){
                    setOppsIds.add(oli.OpportunityId);
                }
            }
        }else{
            for(OpportunityLineItem oli: oldMap.values()){
                setOppsIds.add(oli.OpportunityId);
            }       
        } 
        
        List<Opportunity> listOpps = [SELECT Id, AccountId FROM Opportunity WHERE Id IN: setOppsIds];
        Set<String> setAccountsToUpdate = new Set<String>();
        
        for(Opportunity opp: listOpps){
            setAccountsToUpdate.add(opp.AccountId);
        }

        String returnMessage;        
        if(!setAccountsToUpdate.isEmpty()){
            returnMessage = LAT_MX_AvailableCreditLimit.CalculatesAvailableCreditLimit(setAccountsToUpdate);
            System.debug('&&&&&&&&&&&&&&&&&  returnMessage : '+ returnMessage);
            if(returnMessage != 'OK' || LAT_Utils.isRunningTest()){

                if(triggerNew != null && !triggerNew.isEmpty()){
                    for(OpportunityLineItem oli: triggerNew){
                        if(setOppsIds.contains(oli.OpportunityId)){
                            oli.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }
                }else{
                    for(OpportunityLineItem oli: oldMap.values()){
                        if(setOppsIds.contains(oli.OpportunityId)){
                            oli.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }       
                }
            }  
        }
    }

    //MIGRATED 04/11/2016    
    public static void updatesAvailableCreditLimit(List<LAT_OpportunityLineItem__c> triggerNew, Map<Id,LAT_OpportunityLineItem__c> oldMap){
        
        Set<String> setOppsIds = new Set<String>();
        
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(LAT_OpportunityLineItem__c oli: triggerNew){
                if(oldMap.isEmpty() || (!oldMap.isEmpty() && oldMap.containsKey(oli.Id) && (oli.LAT_TotalPrice__c != oldMap.get(oli.Id).LAT_TotalPrice__c || oli.LAT_CdLineStatus__c != oldMap.get(oli.Id).LAT_CdLineStatus__c))){
                    setOppsIds.add(oli.LAT_Opportunity__c);
                }
            }
        }else{
            for(LAT_OpportunityLineItem__c oli: oldMap.values()){
                setOppsIds.add(oli.LAT_Opportunity__c);
            }       
        } 
        
        List<LAT_Opportunity__c> listOpps = [SELECT Id, LAT_Account__c FROM LAT_Opportunity__c WHERE Id IN: setOppsIds];
        Set<String> setAccountsToUpdate = new Set<String>();
        
        for(LAT_Opportunity__c opp: listOpps){
            setAccountsToUpdate.add(opp.LAT_Account__c);
        }

        String returnMessage;        
        if(!setAccountsToUpdate.isEmpty()){
            returnMessage = LAT_MX_AvailableCreditLimit.CalculatesAvailableCreditLimit(setAccountsToUpdate);
            System.debug('&&&&&&&&&&&&&&&&&  LAT_returnMessage : '+ returnMessage);
            if(returnMessage != 'OK' || LAT_Utils.isRunningTest()){
                if(triggerNew != null && !triggerNew.isEmpty()){
                    for(LAT_OpportunityLineItem__c oli: triggerNew){
                        if(setOppsIds.contains(oli.LAT_Opportunity__c)){
                            oli.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }
                }else{
                    for(LAT_OpportunityLineItem__c oli: oldMap.values()){
                        if(setOppsIds.contains(oli.LAT_Opportunity__c)){
                            oli.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }       
                }
            }  
        }
    }            
}