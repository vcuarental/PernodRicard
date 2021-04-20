/**************************************************************************************
*                           Company: ValueNet
*--------------------------------------------------------------------------------------
*   Clase que contiene los triggers PRB del objeto Produto Pernod Ricard e Concorrência
***************************************************************************************/

public with sharing class LAT_BR_AP01_ProdutoPRConcorrencia{

    public static boolean runTrigger = true;
       
    /*****************************************************************************************
    * Nombre del metodo: ValidationCreateEditDelete
    * Descripcion: Method that doesn't allow to create, edit or delet records if the related 
                   Checklist has field LAT_BR_ValidOnTradeChecklist__c set to false
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 06/11/2013
    * Modo: before insert, before update, before delete
    *****************************************************************************************/
    
    public static void ValidationCreateEditDelete (List<Produto_Concorr_ncia__c> triggerNewOrOld){     

        if(runTrigger){
            Set<String> setChecks = new Set<String>();
            
            for(Produto_Concorr_ncia__c prodPR: triggerNewOrOld){            
                 setChecks.add(prodPR.Checklist_de_visita__c);
            }
                    
            Map<String,Checklist_de_visita__c> mapCheck = new Map<String,Checklist_de_visita__c>([ SELECT Id, LAT_BR_ValidOnTradeChecklist__c FROM Checklist_de_visita__c WHERE Id IN: setChecks ]);
                     
            for(Produto_Concorr_ncia__c prodPR: triggerNewOrOld){
                if(mapCheck.get(prodPR.Checklist_de_visita__c).LAT_BR_ValidOnTradeChecklist__c == false){
                    prodPR.addError(label.LAT_BR_AP01_00004);
                    //LAT_BR_AP01_00004: Não é possível editar ou excluir registros quando o campo 'Colecta Valida?' não esta marcado.
                }                 
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: updatesKey
    * Descripcion: Method that calls the method that updates the field LAT_Key__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 05/05/2014
    * Modo: after insert, after update
    *****************************************************************************************/
    
    public static void updatesKey(List<Produto_Concorr_ncia__c> triggerNew, map<Id,Produto_Concorr_ncia__c> oldMap){ 
                        
        Set<Id> setPPC = new Set<Id>();

        for(Produto_Concorr_ncia__c ppc: triggerNew){
            if(trigger.isInsert){
                setPPC.add(ppc.Id);
            }else if(trigger.isUpdate && (ppc.RecordTypeId != oldMap.get(ppc.Id).RecordTypeId || ppc.Qtde_de_Caixas_Estoque__c != oldMap.get(ppc.Id).Qtde_de_Caixas_Estoque__c)){
                setPPC.add(ppc.Id);   
            }
        }
        
        if(!setPPC.isEmpty()){      
            runTrigger = false;      
            LAT_BR_UpdatesKeyOfPPC.updatesKeyOfPPC(setPPC);
        }        

    }
}