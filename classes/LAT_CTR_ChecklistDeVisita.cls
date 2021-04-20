/**********************************************************************************
*                           Company: ValueNet
*----------------------------------------------------------------------------------
*   Clase que distribuye los registros por pais del objeto Checklist_de_visita__c
***********************************************************************************/

public with sharing class LAT_CTR_ChecklistDeVisita {
  
    /*ALL TRIGGERS*/
    public static void runTriggers(){
        LAT_Trigger trigger_BR = new LAT_Trigger('Checklist_de_visita__c', new set<String>{'Indireto','Off_Trade','On_Trade'});
        triggersBR(trigger_BR);
    }
  
    /*TRIGGERS BR*/
    private static void triggersBR(LAT_Trigger trigger_BR){
        //Before
        //After
        if(trigger.isAfter){
            if(trigger.isUpdate){
                LAT_BR_AP01_ChecklistDeVisita.updatesPPCKey(trigger_BR.getNew(),new map<Id,Checklist_de_visita__c>((List<Checklist_de_visita__c>)trigger_BR.getOld()));
            }
        }
  }
  
}