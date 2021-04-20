/********************************************************************************************
*                                  Company: ValueNet
*--------------------------------------------------------------------------------------------
*         Clase que distribuye los registros por pais del objeto Planejamento__c
********************************************************************************************/

public with sharing class LAT_CTR_Planejamento {
    
    /*ALL TRIGGERS*/
    public static void runTriggers(){
        LAT_Trigger trigger_BR = new LAT_Trigger('Planejamento__c', new set<String>{'BRA_Standard'});
        LAT_Trigger trigger_MX = new LAT_Trigger('Planejamento__c', new set<String>{'LAT_MX_PLV_Approved','LAT_MX_PLV_NewPlanning'});
        triggersBR(trigger_BR);
        triggersMX(trigger_MX);
    }
    
    /*TRIGGERS BR*/
    private static void triggersBR(LAT_Trigger trigger_BR){
        //Before
        if(trigger.isBefore){
            if(trigger.isInsert){
            }
            if(trigger.isUpdate){
            }
            if(trigger.isDelete){
            }
        }
        //After
        if(trigger.isAfter){
            if(trigger.isInsert){
                if(!trigger_BR.getNew().IsEmpty()){
                    LAT_BR_AP01_Planejamento.clientPortfolioCreater(trigger_BR.getNew());
                }
            }
            if(trigger.isUpdate){
                if(!trigger_BR.getNew().IsEmpty()){
                    LAT_BR_AP01_Planejamento.visitaStatusUpdate(trigger_BR.getNew(),new map<Id,Planejamento__c>((List<Planejamento__c>)trigger_BR.getOld()));
                }
            }
            if(trigger.isDelete){
            }
        }
    }

    /*TRIGGERS MX*/
    private static void triggersMX(LAT_Trigger trigger_MX){
        //Before
        if(trigger.isBefore){
            if(trigger.isInsert){
            }
            if(trigger.isUpdate){
                if(!trigger_MX.getNew().IsEmpty()){
                    LAT_MX_AP01_Planejamento.setVisitFrequencyAtApproval(new map<Id,Planejamento__c>((List<Planejamento__c>)trigger_MX.getNew()),new map<Id,Planejamento__c>((List<Planejamento__c>)trigger_MX.getOld()));
                }
            }
            if(trigger.isDelete){
            }
        }
        //After
        if(trigger.isAfter){
            if(trigger.isInsert){
            }
            if(trigger.isUpdate){
            }
            if(trigger.isDelete){
            }
        }
    }
}