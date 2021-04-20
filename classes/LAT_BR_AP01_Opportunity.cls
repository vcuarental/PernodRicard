/******************************************************************************************
 *   Company:Valuenet    Developers: Romero Nicolas Javier                Date:12/12/2013 *
 ******************************************************************************************/
/********************************************************************************
    * 
    * MIGRACION LICENCIAS 
    * AUTHOR: ZIMMIC                     DATE: 03/11/2016
    *
    ********************************************************************************/
public class LAT_BR_AP01_Opportunity{
    



    /*****************************************************************************************
    * Nombre del metodo: checkAllowWebCRM
    * Descripcion: checkAllowWebCRM
    * Desarrollador: Zimmic
    * Fecha: 17/08/2016
    * Modo: before insert
    *****************************************************************************************/
    public static void checkAllowWebCRM(List<Opportunity> triggerOld){

      

        Boolean allowCRM = Utils.isPartOfMobileCRM(UserInfo.getUserId());
        for(Opportunity opp :triggerOld){
            if(opp.Origem_do_pedido__c == 'CRM' && allowCRM){
                opp.AddError(Label.LAT_BR_AllowWebCRM);
            }
        }
    }

    //MIGRATED 03/11/2016 
    public static void checkAllowWebCRM(List<LAT_Opportunity__c> triggerOld){

      

        Boolean allowCRM = Utils.isPartOfMobileCRM(UserInfo.getUserId());
        for(LAT_Opportunity__c opp :triggerOld){
            if(opp.LAT_OrderOrigin__c == 'CRM' && allowCRM){
                opp.AddError(Label.LAT_BR_AllowWebCRM);
            }
        }
    }

    public static void setMobileOrder(List<Opportunity> triggerOld){
        for(Opportunity opp :triggerOld){
            if (opp.StageName == 'Mobile Order') {
                opp.Origem_do_pedido__c = 'APP';
            }
        }

    }

    //MIGRATED 03/11/2016     
    public static void setMobileOrder(List<LAT_Opportunity__c> triggerOld){
        for(LAT_Opportunity__c opp :triggerOld){
            if (opp.LAT_StageName__c == 'Mobile Order') {
                opp.LAT_OrderOrigin__c = 'APP';
            }
        }

    }





    /*****************************************************************************************
    * Nombre del metodo: updateStockCota
    * Descripcion: Elimina los OLI antes de que se elimine la oportunidad para que se ejecuten los triggers de OLI
    * Desarrollador: Waldemar Mayo
    * Fecha: 05/09/2013
    * Modo: before delete
    *****************************************************************************************/
    public static void updateStockCota(List<Opportunity> triggerOld){
        set<Id> setIdOpp = new set<Id>();
        for(Opportunity opp :triggerOld){
            setIdOpp.add(opp.Id);
        }
        List<OpportunityLineItem> listOli = [SELECT Id, Remover__c FROM OpportunityLineItem WHERE OpportunityId IN: setIdOpp];
        delete listOli;
    }
    
    //MIGRATED 03/11/2016  
    public static void updateStockCota(List<LAT_Opportunity__c> triggerOld){
        set<Id> setIdOpp = new set<Id>();
        for(LAT_Opportunity__c opp :triggerOld){
            setIdOpp.add(opp.Id);
        }
        List<LAT_OpportunityLineItem__c> listOli = [SELECT Id, LAT_Remover__c FROM LAT_OpportunityLineItem__c WHERE LAT_Opportunity__c IN: setIdOpp];
        delete listOli;
    }
    /*****************************************************************************************
    * Nombre del metodo: validateStatusDelete
    * Descripcion: Validacion para impedir eliminar pedidos que no seas status "Novo pedido"
    * Desarrollador: Waldemar Mayo
    * Fecha: 17/01/2014
    * Modo: before delete
    *****************************************************************************************/
    public static void validateStatusDelete(List<Opportunity> triggerOld){
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        
        set<String> allowedProfiles = new set<String>{'Administrador do sistema', 'Administrador del sistema', 'PR BRAZIL System Administrator','LAT_SystemAdministrator', 'System Administrator'};
        
        for(Opportunity opp :triggerOld){
            if(opp.StageName != 'Novo pedido' && (!allowedProfiles.contains(profileName))){
                if(!System.Test.isRunningtest()){
                    opp.addError(Label.LAT_BR_AP01_00006);
                }
                //Label.LAT_BR_AP01_00006 = Pedidos com status diferente de "Novo Pedido" não podem ser excluídos.
            }
        }
    }

    //MIGRATED 03/11/2016 
    public static void validateStatusDelete(List<LAT_Opportunity__c> triggerOld){
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        
        set<String> allowedProfiles = new set<String>{'Administrador do sistema', 'Administrador del sistema', 'PR BRAZIL System Administrator','LAT_SystemAdministrator', 'System Administrator'};
        
        for(LAT_Opportunity__c opp :triggerOld){
            if(opp.LAT_StageName__c != 'Novo pedido' && (!allowedProfiles.contains(profileName))){
                if(!System.Test.isRunningtest()){
                    opp.addError(Label.LAT_BR_AP01_00006);
                }
                //Label.LAT_BR_AP01_00006 = Pedidos com status diferente de "Novo Pedido" não podem ser excluídos.
            }
        }
    }

    public static void setFreihgtCRM(List<LAT_Opportunity__c> triggerOld){

        for(LAT_Opportunity__c opp :triggerOld){
            if(opp.LAT_OrderOrigin__c != 'APP'){
                opp.LAT_FreightFormulaDisplay__c = opp.LAT_FreightPercent__c;
            }
        }
    }
}