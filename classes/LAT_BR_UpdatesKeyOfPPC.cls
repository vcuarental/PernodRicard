/*******************************************************************************************************
*                                       Company: ValueNet                                              *
*------------------------------------------------------------------------------------------------------*
* Clase que realiza el calculo y actualiza el campo LAT_Key__c de Produto Pernod Ricard e Concorrência *
********************************************************************************************************/
 /********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 17/11/2016
*
********************************************************************************/


public without sharing class LAT_BR_UpdatesKeyOfPPC{
               
    public static void updatesKeyOfPPC(Set<Id> setPPC){
        if(!Utils.wasMigrationDone('1')) {        
            Id prodConcRtId = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard');                  
            
            List<Produto_Concorr_ncia__c> listPPC = [SELECT Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklist__c, Produto_PERNOD__r.LAT_BR_BrandGrouping__c, 
                                                            Checklist_de_Visita__r.Visita__r.RecordTypeId, Checklist_de_Visita__r.Visita__r.Conta__c, 
                                                            Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, LAT_Key__c, Qtde_de_Caixas_Estoque__c,
                                                            Produto_PERNOD__c, Checklist_de_Visita__c, Checklist_de_Visita__r.Visita__c, Checklist_de_Visita__r.Visita__r.Planejamento__c
                                                     FROM Produto_Concorr_ncia__c
                                                     WHERE Id IN: setPPC];
                                                             
            for(Produto_Concorr_ncia__c ppc: listPPC) {
                
                ppc.LAT_Key__c = '';            
                if(ppc.Qtde_de_Caixas_Estoque__c > 0 && ppc.Checklist_de_Visita__c != null
                    && ppc.Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklist__c 
                    && ppc.Produto_PERNOD__c != null && ppc.Produto_PERNOD__r.LAT_BR_BrandGrouping__c != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.RecordTypeId != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.Conta__c != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.Planejamento__c != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c != null) {
                    
                        ppc.LAT_Key__c += prodConcRtId;
                        ppc.LAT_Key__c += '|' + ppc.Produto_PERNOD__r.LAT_BR_BrandGrouping__c;
                        ppc.LAT_Key__c += '|' + ppc.Checklist_de_Visita__r.Visita__r.RecordTypeId;
                        ppc.LAT_Key__c += '|' + ppc.Checklist_de_Visita__r.Visita__r.Conta__c;
                        ppc.LAT_Key__c += '|' + ppc.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c;
                             
                }
                
            }
            
            List<DataBase.SaveResult> scopeSR = DataBase.update(listPPC, false);
        }
        //MIGRATED 17/11/2016
        else {
            Id prodConcRtId = Global_RecordTypeCache.getRtId('Produto_Concorr_ncia__c' + 'BRA_Standard');                  
            
            List<Produto_Concorr_ncia__c> listPPC = [SELECT Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklist__c, LAT_Product__r.LAT_BR_BrandGrouping__c, 
                                                            Checklist_de_Visita__r.Visita__r.RecordTypeId, Checklist_de_Visita__r.Visita__r.Conta__c, 
                                                            Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c, LAT_Key__c, Qtde_de_Caixas_Estoque__c,
                                                            LAT_Product__c, Checklist_de_Visita__c, Checklist_de_Visita__r.Visita__c, Checklist_de_Visita__r.Visita__r.Planejamento__c
                                                     FROM Produto_Concorr_ncia__c
                                                     WHERE Id IN: setPPC];
                                                             
            for(Produto_Concorr_ncia__c ppc: listPPC) {
                
                ppc.LAT_Key__c = '';            
                if(ppc.Qtde_de_Caixas_Estoque__c > 0 && ppc.Checklist_de_Visita__c != null
                    && ppc.Checklist_de_Visita__r.LAT_BR_ValidOnTradeChecklist__c 
                    && ppc.LAT_Product__c != null && ppc.LAT_Product__r.LAT_BR_BrandGrouping__c != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.RecordTypeId != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.Conta__c != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.Planejamento__c != null 
                    && ppc.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c != null) {
                    
                        ppc.LAT_Key__c += prodConcRtId;
                        ppc.LAT_Key__c += '|' + ppc.LAT_Product__r.LAT_BR_BrandGrouping__c;
                        ppc.LAT_Key__c += '|' + ppc.Checklist_de_Visita__r.Visita__r.RecordTypeId;
                        ppc.LAT_Key__c += '|' + ppc.Checklist_de_Visita__r.Visita__r.Conta__c;
                        ppc.LAT_Key__c += '|' + ppc.Checklist_de_Visita__r.Visita__r.Planejamento__r.LAT_MonthYear__c;
                             
                }
                
            }
            
            List<DataBase.SaveResult> scopeSR = DataBase.update(listPPC, false);            
        }  
    }
    
}