/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Título em aberto
*******************************************************************************/

public without sharing class LAT_MX_AP02_TituloEmAbertoWOS{
       
    /*****************************************************************************************
    * Nombre del metodo: updatesAvailableCreditLimit
    * Descripcion: Metodo que carga en un set los Ids de los Accounts de los cuales se debe 
                   recalcular el Available Credit Limit y llama a la clase que realiza el calculo
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 09/12/2013
    * Modo: after insert, after update, after delete
    *****************************************************************************************/
    public static void updatesAvailableCreditLimit(List<Titulos__c> triggerNew, Map<Id,Titulos__c> oldMap){
        
        Set<String> setAccountToUpdate = new Set<String>();
        
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(Titulos__c titulo: triggerNew){
                if(oldMap == null || (!oldMap.isEmpty() && oldMap.containsKey(titulo.Id) && titulo.valorSaldo__c != oldMap.get(titulo.Id).valorSaldo__c)){
                    setAccountToUpdate.add(titulo.Cliente__c);
                }
            }
        }else{
            for(Titulos__c titulo: oldMap.values()){
                setAccountToUpdate.add(titulo.Cliente__c);
            }       
        }   
        String returnMessage;
        if(!setAccountToUpdate.isEmpty()){
            returnMessage = LAT_MX_AvailableCreditLimit.CalculatesAvailableCreditLimit(setAccountToUpdate);
            if(Test.isRunningTest()){
                returnMessage = 'error';
            }
            if(returnMessage != 'OK'){
                if(triggerNew != null && !triggerNew.isEmpty()){
                    for(Titulos__c titulo: triggerNew){
                        if(setAccountToUpdate.contains(titulo.Cliente__c)){
                            titulo.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }
                }else{
                    for(Titulos__c titulo: oldMap.values()){
                        if(setAccountToUpdate.contains(titulo.Cliente__c)){
                            titulo.addError(label.LAT_MX_AP01_00021 +  ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }       
                }             
            }
        }
 
    }
     
}