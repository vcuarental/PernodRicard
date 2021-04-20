/**********************************************************************************
*                           Company: ValueNet
*----------------------------------------------------------------------------------
*        Clase que distribuye los registros por pais del objeto Product2
***********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 09/11/2016
*
********************************************************************************/

public with sharing class LAT_CTR_Product2{

    /*ALL TRIGGERS*/
    //MIGRATED 09/11/2016 
    public static void runTriggers(){
       
        LAT_Trigger LAT_trigger_MX = new LAT_Trigger('LAT_Product__c', new set<String>{'LAT_MX_PRD_Standard'});
        if (LAT_trigger_MX.getNew().size() > 0) {
            triggersMX(LAT_trigger_MX);
        } 
        LAT_Trigger LAT_trigger_BR = new LAT_Trigger('LAT_Product__c', new set<String>{'BRA_Standard'});
        if (LAT_trigger_BR.getNew().size() > 0) {
            triggersBR(LAT_trigger_BR);
        }    

    }
  
    /*TRIGGERS LAT*/
    private static void triggersLAT(LAT_Trigger trigger_LAT, String country){
        //After

        if(trigger.isAfter){
            if(trigger.isInsert){
                LAT_AP01_Product2.createsPriceBookEntry(trigger_LAT.getNew());
            }

        }
    }
    

    /*TRIGGERS BR*/
    private static void triggersBR(LAT_Trigger trigger_BR){
        //Before
        //After
        if(trigger.isAfter){
            if(trigger.isInsert){
                LAT_AP01_Product2.validateKeyBrandIsNotEmpty(trigger_BR.getNew());
            }
           
            if(trigger.isUpdate){
                LAT_AP01_Product2.validateKeyBrandIsNotEmpty(trigger_BR.getNew());
            }
        }
    }

    /*TRIGGERS MX*/
    private static void triggersMX(LAT_Trigger trigger_MX){
        //Before
        
        if(trigger.isBefore){
            LAT_AP01_Product2.updateIndexMargin(trigger_MX.getNew(), 'LAT_MX_PRD_Standard');
            if (trigger.isUpdate) {
                LAT_AP01_Product2.updateRestriction(trigger_MX.getNew());
            }
        }
    }
}