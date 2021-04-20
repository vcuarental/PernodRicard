/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Credit Analysis
*******************************************************************************/

public with sharing class LAT_MX_AP01_CreditAnalysis{
       
    /*****************************************************************************************
    * Nombre del metodo: UpdatesCredAndCollectionFields
    * Descripcion: Metodo que completa el campo LAT_MX_CreditAndCollectionsExecutive__c y 
                   LAT_MX_CreditAndCollectionsManager__c
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 01/10/2013
    * Modo: before insert
    *****************************************************************************************/
    public static void UpdatesCredAndCollectionFields (List<CRA_CredAnalysis_ARG__c> triggerNew){  
                     
        set<Id> setAccId = new set<Id>();
        
        for(CRA_CredAnalysis_ARG__c cra: triggerNew){
            setAccId.add(cra.Account_ARG__c);
        }        
        map<String, Account> mapAccounts = new map<String, Account> ([SELECT Id, LAT_MX_CreditAndCollectionsExecutive__c, Channel__c FROM Account WHERE Id IN: setAccId]);
        set<Id> setIdUser = new set<Id>();
        
        for(String idAcc: mapAccounts.keyset()){
            if(mapAccounts.get(idAcc).LAT_MX_CreditAndCollectionsExecutive__c != null){
                setIdUser.add(mapAccounts.get(idAcc).LAT_MX_CreditAndCollectionsExecutive__c);
            }
        }
        
        CS006_DefaultUsers__c CsUserId  = CS006_DefaultUsers__c.getOrgDefaults();
        
        map<String,User> mapAprobadores = new map<String,User>();    
     
        map<String, User> mapUs = new map<String, User>();        
        for(User us: [SELECT Id, ManagerId, Username FROM User WHERE Username =: CsUserId.LAT_MX_UserName1__c OR Id IN: setIdUser]){
            if(us.Username == CsUserId.LAT_MX_UserName1__c){
                mapAprobadores.put(us.Username,us);
            }
            mapUs.put(us.id, us);
        }        
        for(CRA_CredAnalysis_ARG__c cra: triggerNew){                
            if(mapAccounts.get(cra.Account_ARG__c).LAT_MX_CreditAndCollectionsExecutive__c != null){
                cra.LAT_MX_CreditAndCollectionsExecutive__c = mapAccounts.get(cra.Account_ARG__c).LAT_MX_CreditAndCollectionsExecutive__c;
                cra.LAT_MX_CreditAndCollectionsManager__c = mapUs.get(cra.LAT_MX_CreditAndCollectionsExecutive__c).ManagerId;      
            }if(mapAprobadores.containsKey(CsUserId.LAT_MX_UserName1__c)){                
                cra.LAT_MX_CreditAndCollectionsExecutive__c = mapAprobadores.get(CsUserId.LAT_MX_UserName1__c).id;
                cra.LAT_MX_CreditAndCollectionsManager__c = mapAprobadores.get(CsUserId.LAT_MX_UserName1__c).ManagerId;
            }
        }           
    }

    /*****************************************************************************************
    * Nombre del metodo: CreditLimitGrantedValidation
    * Descripcion: Validates the Amounth entered in CreditLimitGranted_ARG__c after the record was approved.
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 03/10/2013
    * Modo: before update
    *****************************************************************************************/
    public static void CreditLimitGrantedValidation (List<CRA_CredAnalysis_ARG__c> triggerNew, map<Id, CRA_CredAnalysis_ARG__c> triggerOldMap){
        
        list<LAT_MX_CLA_CreditLimitAudit__c> cla = [SELECT Id, LAT_MX_ThresholdValue__c FROM LAT_MX_CLA_CreditLimitAudit__c WHERE RecordTypeId =: Global_RecordTypeCache.getRtId('LAT_MX_CLA_CreditLimitAudit__c' + 'LAT_MX_CLA_Standard') ORDER BY CreatedDate DESC];      
        
        set<Id> setIdAccounts = new set<Id>();
        
        for(CRA_CredAnalysis_ARG__c cra: triggerNew){
            setIdAccounts.add(cra.Account_ARG__c);
        }
        
        map<Id, Account> mapAccounts = new map<Id, Account>([SELECT Id, Credit_line__c FROM Account WHERE Id IN: setIdAccounts]);
        
        for(CRA_CredAnalysis_ARG__c cra: triggerNew){
            if(cra.LAT_MX_ApprovalProcessAproved__c == true && triggerOldMap.get(cra.id).LAT_MX_ApprovalProcessAproved__c == false){
                if(cla.isEmpty()){
                    cra.addError(label.LAT_MX_AP01_00011);
                    //LAT_MX_AP01_00011: No hay ningún registro de 'Auditoria de Límite de Crédito'.
                } else {
                    if(cra.CreditLimitGranted_ARG__c <= cla[0].LAT_MX_ThresholdValue__c || cra.LAT_MX_AuthorizedByCommittee__c == true){
                        mapAccounts.get(cra.Account_ARG__c).Credit_line__c = cra.CreditLimitGranted_ARG__c;
                        cra.LAT_MX_ApprovalProcessAproved__c = false;
                    } else {
                        cra.addError(label.LAT_MX_AP01_00012);
                        //LAT_MX_AP01_00012: Límite de crédito excedido, se necesita autorización de comité. Marque el campo correspondiente
                    }
                }
            
            }
        }
        update mapAccounts.values();
    }   
    
}