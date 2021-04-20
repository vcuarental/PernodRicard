/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers del objeto Case
*******************************************************************************/
/***********************xs*********************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 02/11/2016
*
********************************************************************************/

public with sharing class AP01_Case_AR {
  

    public static map<Id, RecordType> mapIdRt = new map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Case']);
    public static map<Id, RecordType> mapIdRtLAT = new map<Id, RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Lat_Case__c']);
    /*********************************************************************************************************************
    * Nombre del metodo: UpdateAccountOwnerAndManagerOwner
    * Descripcion: Metodo que completa los campos AccountOwner_AR__c, AccountOwnerManager_AR__c y CaseOwnerManager_AR__c.
    * Desarrollador: Elena Schwarzböck
    * Fecha: 19/03/2013 / modificado 03/06/2013
    * Modo: before insert, before update
    *********************************************************************************************************************/
    public static void UpdateAccountOwnerAndManagerOwner (List<Case> triggerNew){
        /*
        set<Id> setAccountIds = new set<Id>();
        set<Id> setIdOwnersCase = new set<Id>();
        for (Case cse: triggerNew){
            if (mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_1_AccountAlteration_ARG' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_2_AccountAlteration_URU'){
               setAccountIds.add(cse.AccountId);
            }
            setIdOwnersCase.add(cse.OwnerId); // se agrego el 03/06/2013
        }
        list<Account> listAccounts = new list<Account>([SELECT Id, OwnerId FROM Account WHERE Id IN: setAccountIds]);
        set<Id> setIdOwnersAccounts = new set<Id>();
        map<Id, Account> mapIdAccounts = new map<Id, Account>();
        if (!listAccounts.isEmpty()){
            for (Account acc: listAccounts){
                setIdOwnersAccounts.add(acc.OwnerId);
                mapIdAccounts.put(acc.Id, acc);    
            }
        }
        map<Id, User> mapIdUsers = new map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: setIdOwnersAccounts]);

        map<Id, User> mapIdUsersCase = new map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: setIdOwnersCase]);  // se agrego el 03/06/2013

        for (Case cse:triggerNew){
            if (mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_1_AccountAlteration_ARG' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_2_AccountAlteration_URU'){
                if(cse.AccountId != NULL){
                    if(mapIdAccounts.get(cse.AccountId).OwnerId != NULL){
                        cse.AccountOwner_AR__c = mapIdAccounts.get(cse.AccountId).OwnerId;
                    }
                    if(mapIdUsers.get(cse.AccountOwner_AR__c).ManagerId != NULL){
                        cse.AccountOwnerManager_AR__c = mapIdUsers.get(cse.AccountOwner_AR__c).ManagerId;
                    }
                }
                if(cse.AccountId == NULL){    
                    cse.addError(label.AP01_00008_AR);
                }
            }
            //-------------------------
            // se agrego el 03/06/2013
            if (mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_AR' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_UY' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueJustification_AR' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueJustification_UY' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueToAttorneys_AR' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueToAttorneys_UY' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_PaymentProposal_AR' || mapIdRt.get(cse.RecordTypeId).DeveloperName == 'CSE_PaymentProposal_UY'){
                if (cse.OwnerId != NULL){
                    if (mapIdUsersCase.get(cse.OwnerId).ManagerId != NULL){
                        cse.CaseOwnerManager_AR__c = mapIdUsersCase.get(cse.OwnerId).ManagerId;
                    }
                }
            }
        }     */
    }  
    /*****************************************************************************************
    * Nombre del metodo: TypeValidation
    * Descripcion: Validacion del campo type.
    * Desarrollador: Tomas Garcia Etchegaray
    * Fecha: 11/03/2013
    * Modo: before update
    *****************************************************************************************/
    public static void TypeValidation (List<Case> triggerNew, map<Id, Case> TriggerOldMap){
        /*
        for (Case caso: triggerNew){
            if (mapIdRt.get(caso.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_AR' || mapIdRt.get(caso.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_UY'){
                if ( caso.Status == 'Aprovado' && triggerOldMap.get(caso.id).Status == 'Without customer proposal-Sent to Credit' && (caso.Type != 'Proposta de pagamento' || caso.Type != 'Overdue to attorneys') ){
                    caso.adderror(label.AP01_00007_AR);
                }
            }
        }
        */
    }    
    /*****************************************************************************************
    * Nombre del metodo: UpdateRtandIsoCode
    * Descripcion: Según el type del caso actualiza al tipo de registro correspondiente.
    * Desarrollador: Tomas Garcia Etchegaray / modificado por Elena J. Schwarzböck 27/05/2013 lineas 104 a 124
    * Fecha: 11/03/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void UpdateRtandIsoCode (  List<Case> triggerNew ) {
        /*
        
        list<RecordType> recAr  = mapIdRt.values();
        map<string,RecordType> mapidREc = new map<string,RecordType>();
        

        for (RecordType rec : recAr){
            mapidREc.put(rec.DeveloperName,rec);
        }
        
        Set<string> setIds = new set<string>();
        for (Case cas: triggerNew){
    
                setIds.add(cas.AccountID); 
        }
        system.debug('enton');
        map<Id, Account> mapcaseAccount = new map<Id, Account>([SELECT Id, Amount_due_ARG__c, CurrencyIsoCode FROM Account WHERE  Id IN: setIds ]);
              
        
        for( Case cas : triggerNew ){
     
            if (cas.Type == 'Justificativa de inadimplência'){
                if( mapIdRt.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR'){
                //if (cas.RecordTypeId == rtAR.Id){
                    cas.RecordTypeId = mapidREc.get('CSE_OverdueJustification_AR').id;               //                   recJusAR.id;
                } else {
                    if( mapIdRt.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY'){
                    //if (cas.RecordTypeId == rtUY.Id){
                        cas.RecordTypeId = mapidREc.get('CSE_OverdueJustification_UY').id;
                    }
                }
            }
            if (cas.Type == 'Proposta de pagamento'){
                if( mapIdRt.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR'){
                //if (cas.RecordTypeId == rtAR.Id){
                    cas.RecordTypeId = mapidREc.get('CSE_PaymentProposal_AR').id;                      //recProAR.id;
                } else {
                    if( mapIdRt.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY'){
                    //if (cas.RecordTypeId == rtUY.Id){
                        cas.RecordTypeId = mapidREc.get('CSE_PaymentProposal_UY').id;
                    }
                }
            }
            
            // 31/05/2013 Elena J. Schwarzböck cambio de cas.Type == 'Prouesta no realizada' a cas.Type == 'Proposta não realizada' (valor fisico)
            if (cas.Type == 'Proposta não realizada'){
                if( mapIdRt.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR'){
                //if (cas.RecordTypeId == rtAR.Id){
                    cas.RecordTypeId =  mapidREc.get('CSE_WOPaymentProposal_AR').id;                               //recNoProAR.id;
                } else {
                    if( mapIdRt.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY'){
                    //if (cas.RecordTypeId == rtUY.Id){
                        cas.RecordTypeId =  mapidREc.get('CSE_WOPaymentProposal_UY').id;
                    }
                }
            }
            if ( (cas.RecordTypeId == mapidREc.get('CSE_PaymentProposal_AR').id) || (cas.RecordTypeId == mapidREc.get('CSE_PaymentProposal_UY').id) ){
                system.debug('TOKEN entroaif');
                cas.CurrencyIsoCode = mapcaseAccount.get(cas.AccountID).CurrencyIsoCode;
                cas.Value_due__c = mapcaseAccount.get(cas.AccountID).Amount_due_ARG__c;    
            }
        }
        */
    }
    /*****************************************************************************************
    * Nombre del metodo: UpdateSubject
    * Descripcion: Actualiza el subject con el label del picklist
    * Desarrollador: Tomas Garcia Etchegaray
    * Fecha: 11/03/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void UpdateSubject (List<Case> triggerNew, String mode){
        /*
        map<String,String> mapValueLabelType = new map<String,String>();
        map<String,String> mapValueLabelReason = new map<String,String>();
         
         
        Schema.DescribeFieldResult F = Case.Type.getDescribe();
        system.debug(F);
        List<Schema.PicklistEntry> M = F.getPicklistValues();
        
        for(Schema.PicklistEntry valor: M) {
            mapValueLabelType.put(valor.getValue(),valor.getLabel());
        }
        
        Schema.DescribeFieldResult G = Case.Reason.getDescribe();
        system.debug(G);
        List<Schema.PicklistEntry> P = G.getPicklistValues();
        
        for(Schema.PicklistEntry valor: P){
            mapValueLabelReason.put(valor.getValue(),valor.getLabel());
        }

        for (Case cas : triggerNew ){
            
            if( cas.Type != null && cas.Reason != null ){
                cas.Subject = mapValueLabelType.get(cas.Type) + ' - ' + mapValueLabelReason.get(cas.Reason);        
            }   
            if( cas.Type == null && cas.Reason != null ){
                cas.Subject =  mapValueLabelReason.get(cas.Reason);     
            }
            if(  cas.Type != null  && cas.Reason == null ){
                cas.Subject =  mapValueLabelType.get(cas.Type);     
            }
            if( cas.Type  == null && cas.Reason == null ){
                cas.Subject = '';       
            }
        }
        */
    }    
    public static void ValidateCloseCase (List<Case> triggerNew) {
        /*
        List <String> userIdsList = new List <String> ();
        userIdsList = LAT_GeneralConfigDao.getValueAsStringArray('AR_USERS_CLOSING_CASES',',');
        System.debug('%%%%%%% AR_USERS_CLOSING_CASES en ValidateCloseCase '+[SELECT name, id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'AR_USERS_CLOSING_CASES']);
        System.debug('%%%%%%% userinfo.getUserId() '+userinfo.getUserId());
        System.debug('%%%%%%% userIdsList '+userIdsList);
        System.debug('%%%%%%% AR_USERS_CLOSING_CASES en ValidateCloseCase '+[SELECT name, id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'AR_USERS_CLOSING_CASES']);
        
        Set <String> userIds = userIdsList != null ? new Set<String>(userIdsList) : new Set<String>();
        List <String> profilesIdsList = new List <String> ();
        profilesIdsList = LAT_GeneralConfigDao.getValueAsStringArray('AR_PROFILE_CLOSING_CASES',',');
        System.debug('%%%%%%% profilesIdsList() '+profilesIdsList);
        Set <String> profilesIds = profilesIdsList != null ? new Set<String>(profilesIdsList) : new Set<String>();


        for (Case c : triggerNew ) {
            System.debug('%%%%%%% Status del case : '+c.status);
            if (c.Status == 'Fechado e cancelado' || c.Status == 'Fechado e resolvido'){
                List<String> accIds = new List<String>();
                for(Case cs : triggerNew){
                    accIds.add(cs.accountId);
                }
                Map<Id,Account> accMap = new MAp<Id,Account>([Select id,Amount_due__c from Account where id in : accIds]);
                for(Case cs : triggerNew){
                    cs.Value_due__c = accMap.get(cs.AccountId).Amount_due__c;
                }
            } 
            System.debug('%%%%%%%%% userIds.contains(userinfo.getUserId()) '+userIds.contains(userinfo.getUserId()));
            System.debug('%%%%%%%%% profilesIds.contains(userinfo.getProfileId()) '+profilesIds.contains(userinfo.getProfileId()));
           

            if ((c.Status == 'Fechado e cancelado' || c.Status == 'Fechado e resolvido') 
                && !userIds.contains(userinfo.getUserId())
                && !profilesIds.contains(userinfo.getProfileId())) {
                    System.debug('%%%%%%%% entrossss');
                    c.addError(Label.AP01_Case_Ar_Validation_Error);
            }   
        }
        */
    }

 
    //MIGRATED 21/11/2016 
    public static void UpdateAccountOwnerAndManagerOwner (List<Lat_Case__c> triggerNew){
        
        set<Id> setAccountIds = new set<Id>();
        set<Id> setIdOwnersCase = new set<Id>();
        for (Lat_Case__c cse: triggerNew){
            if (mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_1_AccountAlteration_ARG' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_2_AccountAlteration_URU'){
               setAccountIds.add(cse.LAT_Account__c);
            }
            setIdOwnersCase.add(cse.OwnerId); // se agrego el 03/06/2013
        }
        list<Account> listAccounts = new list<Account>([SELECT Id, OwnerId FROM Account WHERE Id IN: setAccountIds]);
        set<Id> setIdOwnersAccounts = new set<Id>();
        map<Id, Account> mapIdAccounts = new map<Id, Account>();
        if (!listAccounts.isEmpty()){
            for (Account acc: listAccounts){
                setIdOwnersAccounts.add(acc.OwnerId);
                mapIdAccounts.put(acc.Id, acc);    
            }
        }
        map<Id, User> mapIdUsers = new map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: setIdOwnersAccounts]);

        map<Id, User> mapIdUsersCase = new map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: setIdOwnersCase]);  // se agrego el 03/06/2013

        for (Lat_Case__c cse:triggerNew){
            if (mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_1_AccountAlteration_ARG' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_2_AccountAlteration_URU'){
                if(cse.LAT_Account__c != NULL){
                    if(mapIdAccounts.get(cse.LAT_Account__c).OwnerId != NULL){
                        cse.LAT_AR_AccountOwner__c = mapIdAccounts.get(cse.LAT_Account__c).OwnerId;
                    }
                    if(mapIdUsers.get(cse.LAT_AR_AccountOwner__c).ManagerId != NULL){
                        cse.LAT_AR_AccountOwnerManager__c = mapIdUsers.get(cse.LAT_AR_AccountOwner__c).ManagerId;
                    }
                }
                if(cse.LAT_Account__c == NULL){    
                    cse.addError(label.AP01_00008_AR);
                }
            }
            //-------------------------
            // se agrego el 03/06/2013
            if (mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_AR' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_UY' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueJustification_AR' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueJustification_UY' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueToAttorneys_AR' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_OverdueToAttorneys_UY' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_PaymentProposal_AR' || mapIdRtLAT.get(cse.RecordTypeId).DeveloperName == 'CSE_PaymentProposal_UY'){
                if (cse.OwnerId != NULL){
                    if (mapIdUsersCase.get(cse.OwnerId).ManagerId != NULL){
                        cse.LAT_AR_CaseOwnerManager__c = mapIdUsersCase.get(cse.OwnerId).ManagerId;
                    }
                }

            }
            //-------------------------
          
        }     
    }
    //MIGRATED 21/11/2016 
    public static void TypeValidation (List<Lat_Case__c> triggerNew, map<Id, Lat_Case__c> TriggerOldMap){
    
        for (Lat_Case__c caso: triggerNew){
            if (mapIdRtLAT.get(caso.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_AR' || mapIdRtLAT.get(caso.RecordTypeId).DeveloperName == 'CSE_WOPaymentProposal_UY'){
                if ( caso.LAT_Status__c == 'Aprovado' && triggerOldMap.get(caso.id).LAT_Status__c == 'Without customer proposal-Sent to Credit' && (caso.LAT_Type__c != 'Proposta de pagamento' || caso.LAT_Type__c != 'Overdue to attorneys') ){
                    caso.adderror(label.AP01_00007_AR);
                }
            }
        }
    }
    //MIGRATED 21/11/2016 
    public static void UpdateRtandIsoCode (  List<Lat_Case__c> triggerNew ){
        
        
        list<RecordType> recAr  = mapIdRtLAT.values();
        map<string,RecordType> mapidREc = new map<string,RecordType>();
        

        for (RecordType rec : recAr){
            mapidREc.put(rec.DeveloperName,rec);
        }
        
        Set<string> setIds = new set<string>();
        for (Lat_Case__c cas: triggerNew){
    
                setIds.add(cas.LAT_Account__c); 
        }
        system.debug('enton');
        map<Id, Account> mapcaseAccount = new map<Id, Account>([SELECT Id, Amount_due_ARG__c, CurrencyIsoCode FROM Account WHERE  Id IN: setIds ]);
              
        
        for( Lat_Case__c cas : triggerNew ){
     
            if (cas.LAT_Type__c == 'Justificativa de inadimplência'){
                if( mapIdRtLAT.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR'){
                //if (cas.RecordTypeId == rtAR.Id){
                    cas.RecordTypeId = mapidREc.get('CSE_OverdueJustification_AR').id;               //                   recJusAR.id;
                } else {
                    if( mapIdRtLAT.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY'){
                    //if (cas.RecordTypeId == rtUY.Id){
                        cas.RecordTypeId = mapidREc.get('CSE_OverdueJustification_UY').id;
                    }
                }
            }
            if (cas.LAT_Type__c == 'Proposta de pagamento'){
                if( mapIdRtLAT.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR'){
                //if (cas.RecordTypeId == rtAR.Id){
                    cas.RecordTypeId = mapidREc.get('CSE_PaymentProposal_AR').id;                      //recProAR.id;
                } else {
                    if( mapIdRtLAT.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY'){
                    //if (cas.RecordTypeId == rtUY.Id){
                        cas.RecordTypeId = mapidREc.get('CSE_PaymentProposal_UY').id;
                    }
                }
            }
            
            // 31/05/2013 Elena J. Schwarzböck cambio de cas.Type == 'Prouesta no realizada' a cas.Type == 'Proposta não realizada' (valor fisico)
            if (cas.LAT_Type__c == 'Proposta não realizada'){
                if( mapIdRtLAT.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_AR'){
                //if (cas.RecordTypeId == rtAR.Id){
                    cas.RecordTypeId =  mapidREc.get('CSE_WOPaymentProposal_AR').id;                               //recNoProAR.id;
                } else {
                    if( mapIdRtLAT.get(cas.RecordTypeId).DeveloperName == 'CSE_OverdueAccount_UY'){
                    //if (cas.RecordTypeId == rtUY.Id){
                        cas.RecordTypeId =  mapidREc.get('CSE_WOPaymentProposal_UY').id;
                    }
                }
            }
            if ( (cas.RecordTypeId == mapidREc.get('CSE_PaymentProposal_AR').id) || (cas.RecordTypeId == mapidREc.get('CSE_PaymentProposal_UY').id) ){
                system.debug('TOKEN entroaif');
                if (cas.LAT_Account__c == null ){
                    cas.adderror('No se pueden crear casos sin seleccionar un cliente, cree el caso desde la pantalla del cliente.');
                    } else {
                cas.CurrencyIsoCode = mapcaseAccount.get(cas.LAT_Account__c).CurrencyIsoCode;
                cas.LAT_ValueDue__c = mapcaseAccount.get(cas.LAT_Account__c).Amount_due_ARG__c;    
                }
            }
        }
    }
    //MIGRATED 21/11/2016 
    public static void UpdateSubject (List<Lat_Case__c> triggerNew, String mode) {
        

        map<String,String> mapValueLabelType = new map<String,String>();
        map<String,String> mapValueLabelReason = new map<String,String>();
         
         
        Schema.DescribeFieldResult F = Lat_Case__c.LAT_Type__c.getDescribe();
        system.debug(F);
        List<Schema.PicklistEntry> M = F.getPicklistValues();
        
        for(Schema.PicklistEntry valor: M){
            mapValueLabelType.put(valor.getValue(),valor.getLabel());
        }
        
        Schema.DescribeFieldResult G = Lat_Case__c.LAT_Reason__c.getDescribe();
        system.debug(G);
        List<Schema.PicklistEntry> P = G.getPicklistValues();
        
        for(Schema.PicklistEntry valor: P){
            mapValueLabelReason.put(valor.getValue(),valor.getLabel());
        }

        for (Lat_Case__c cas : triggerNew ){
            if (cas.RecordTypeId != Global_RecordTypeCache.getRtId('LAT_Case__c'+'B2B_Support')) {
                if( cas.LAT_Type__c != null && cas.LAT_Reason__c != null ) {
                    cas.LAT_Subject__c = mapValueLabelType.get(cas.LAT_Type__c) + ' - ' + mapValueLabelReason.get(cas.LAT_Reason__c);        
                }   
                if( cas.LAT_Type__c == null && cas.LAT_Reason__c != null ) {
                    cas.LAT_Subject__c =  mapValueLabelReason.get(cas.LAT_Reason__c);     
                }
                if(  cas.LAT_Type__c != null  && cas.LAT_Reason__c == null ) { 
                    cas.LAT_Subject__c =  mapValueLabelType.get(cas.LAT_Type__c);     
                }
                if( cas.LAT_Type__c  == null && cas.LAT_Reason__c == null ) {
                    cas.LAT_Subject__c = '';       
                }
            }
            
        }
    }
    //MIGRATED 21/11/2016  //
    public static void ValidateCloseCase (List<Lat_Case__c> triggerNew) {

        List <String> userIdsList = new List <String> ();
        userIdsList = LAT_GeneralConfigDao.getValueAsStringArray('AR_USERS_CLOSING_CASES',',');
        Set <String> userIds = userIdsList != null ? new Set<String>(userIdsList) : new Set<String>();
        List <String> profilesIdsList = new List <String> ();
        profilesIdsList = LAT_GeneralConfigDao.getValueAsStringArray('AR_PROFILE_CLOSING_CASES',',');
        System.debug('%%%%%%%% profilesIdsList en ValidateCloseCase : '+profilesIdsList
        );
        System.debug('%%%%%%%% userinfo.getProfileId() en ValidateCloseCase : '+userinfo.getProfileId());
        
        Set <String> profilesIds = profilesIdsList != null ? new Set<String>(profilesIdsList) : new Set<String>();


        for (Lat_Case__c c : triggerNew ) {
            System.debug('%%%%%%% Status del LAT_case : '+c.LAT_Status__c);
            if (c.LAT_Status__c == 'Fechado e cancelado' || c.LAT_Status__c == 'Fechado e resolvido'){
                List<String> accIds = new List<String>();
                for(Lat_Case__c cs : triggerNew){
                    accIds.add(cs.LAT_Account__c);
                }
                Map<Id,Account> accMap = new MAp<Id,Account>([Select id,Amount_due__c from Account where id in : accIds]);
                for(Lat_Case__c cs : triggerNew){
                    if(cs.LAT_Account__c!=null)
                        cs.LAT_ValueDue__c = accMap.get(cs.LAT_Account__c).Amount_due__c;
                }
            }

            if ((c.LAT_Status__c == 'Fechado e cancelado' || c.LAT_Status__c == 'Fechado e resolvido') 
                && !userIds.contains(userinfo.getUserId())
                && !profilesIds.contains(userinfo.getProfileId())) {
                    c.addError(Label.AP01_Case_Ar_Validation_Error);
                    break;
            }   
            if (c.LAT_Status__c == 'Fechado e cancelado' && c.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c' + 'B2B_New_Account')) {
                String body = 'Estimado Cliente, <br><br>'+
                                'Su solicitud de registro como cliente de Pernod Ricard fue rechazada por los siguientes motivos:<br>'+
                                c.LAT_Comments__c+'<br><br>'+
                                'Por dudas o consultas envianos un email a soportetiendapr@pernod-ricard.com.<br><br>'+
                                'Saludos!<br><br>'+
                                'Pernod Ricard Argentina.';
                String subject = 'Registro como cliente de Pernod Ricard rechazado';
                List<String> emails = new List<String>{'javier@zimmic.com',c.LAT_B2B_EmailContacto__c};
                enviarEmail(body, subject, emails);
            }


        }
    }

    public static void validateB2BClosedCase (List<Lat_Case__c> triggerNew) {
        for(Lat_Case__c caso : triggerNew) {
            if(caso.LAT_Status__c == 'Crear Cliente B2B') {
                createB2BAccount(caso);
                caso.LAT_Status__c = 'Caso Cerrado B2B';
                String body = 'Estimado Cliente, <br><br>'+
                                'Su solicitud de registro como cliente de Pernod Ricard ya está en proceso! <br>En los próximos días estaremos comunicándonos con Ud. para finalizar el registro.<br><br>'+
                                'Por dudas o consultas envianos un email a soportetiendapr@pernod-ricard.com.<br><br>'+
                                'Desde ya muchas gracias!<br><br>'+
                                'Pernod Ricard Argentina.';
                String subject = 'Registro como cliente de Pernod Ricard en proceso';
                List<String> emails = new List<String>{'javier@zimmic.com',caso.LAT_B2B_EmailContacto__c};
                enviarEmail(body, subject, emails);

            }
        }
    }

    public static void createB2BAccount(Lat_Case__c caso){

        LAT_GeneralConfig__c conf = LAT_GeneralConfig__c.getInstance('AR_ACCOUNT_PATRON_B2B');

        Account patron = [SELECT Id, Business_Unit_AR__c FROM Account WHERE Id =:conf.LAT_Value__c ];

        Account toCreate = new Account();
        if(caso.LAT_AR_NewAccountType__c == 'On Trade') {
            toCreate.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_3_OnTrade_ARG');
        } else {
            toCreate.RecordTypeId = Global_RecordTypeCache.getRtId('Account' + 'ACC_1_OffTrade_ARG');
        }

        toCreate.Name = caso.LAT_B2B_NombreFantasia__c;
        toCreate.CNPJ__C = caso.LAT_B2B_IdFiscal__c;
        if(caso.LAT_B2B_Direccion__c != null)
        toCreate.AddressLine1_AR__c = caso.LAT_B2B_Direccion__c.length()>40 ? caso.LAT_B2B_Direccion__c.substring(0, 39) : caso.LAT_B2B_Direccion__c;
        toCreate.Corporate_Name__c = caso.LAT_B2B_RazonSocial__c;
        toCreate.Phone = caso.LAT_B2B_TelefonoContacto__c;
        toCreate.Business_Unit_AR__c = patron.Business_Unit_AR__c;
        toCreate.LAT_BR_RegionalClientOnPremise__c = 'B2B';
        insert toCreate;

        if(caso.LAT_B2B_NombreContacto__c != null && caso.LAT_B2B_NombreContacto__c != '') {
            Contact con = new Contact();
            con.AccountId = toCreate.Id;
            con.RecordTypeId = Global_RecordTypeCache.getRtId('Contact' + 'CTC_Standard_AR');
            con.FirstName = caso.LAT_B2B_NombreContacto__c.split(' ').size() > 1 ? caso.LAT_B2B_NombreContacto__c.split(' ')[0] : ''; 
            con.LastName = caso.LAT_B2B_NombreContacto__c.split(' ').size() > 1 ? caso.LAT_B2B_NombreContacto__c.split(' ')[1] : caso.LAT_B2B_NombreContacto__c; 
            con.Email = caso.LAT_B2B_EmailContacto__c;
            con.Phone = caso.LAT_B2B_TelefonoContacto__c;
            insert con;
        }
        
    }
    public static void enviarEmail(String emailBody, String emailSubject, List<String> emailAddresses) {
            
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emailAddresses);
            mail.setHtmlBody(emailBody);
            mail.setSenderDisplayName('noreply@pernod-ricard.com');
            mail.setSubject(emailSubject);
            
            List<Messaging.SingleEmailMessage> list_emailsToSent = new List<Messaging.SingleEmailMessage>();
            list_emailsToSent.add(mail);    
            
            Messaging.sendEmail(list_emailsToSent);
    }

    public static void processNewB2BCase(List<Lat_Case__c> triggerNew) {
        for(LAT_Case__c caso:triggerNew){
            if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c'+'B2B_Support')){
                postSupportCaseToChatter(caso);
            } else if(caso.RecordTypeId == Global_RecordTypeCache.getRtId('LAT_Case__c'+'B2B_New_Account')){
                try{
                    postNewB2BAccountCaseToChatter(caso);
                } catch(Exception e) {
                    System.debug('%%%% falló en el create account desde el guest : '+e);
                }
                
            }
        }
    }
    
   public static void postSupportCaseToChatter(LAT_Case__c caso) {

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        String body = 'El cliente ' + caso.LAT_AccountName__c +' creó un caso por lo siguiente: \n\n';
        body+= caso.LAT_Subject__c + '\n\n';
        body+= 'Descripción: ' + caso.LAT_Description__c + '\n\n';
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = body;
        System.debug('%%%% textSegmentInput.text : '+textSegmentInput.text);
        messageBodyInput.messageSegments.add(textSegmentInput);
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = LAT_GeneralConfig__c.getInstance('AR_B2B_AdminUserID').LAT_Value__c;//'005D0000002y9fW';
        messageBodyInput.messageSegments.add(mentionSegment);
        
        ConnectApi.MentionSegmentInput mentionSegment2 = new ConnectApi.MentionSegmentInput();
        mentionSegment2.id = caso.CreatedById;
        messageBodyInput.messageSegments.add(mentionSegment2);
        
        System.debug('%%%% messageBodyInput : '+messageBodyInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = caso.Id;


        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        batchInputs.add(batchInput);         
        if (batchInputs.size() > 0) {
            if (!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        } 
                

    } 

    public static void postNewB2BAccountCaseToChatter(LAT_Case__c caso) {

        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        String body = 'El cliente ' + caso.LAT_B2B_NombreFantasia__c +' creó un caso solicitando el alta como cliente. \n\n';
       
        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        textSegmentInput.text = body;
        System.debug('%%%% textSegmentInput.text : '+textSegmentInput.text);
        messageBodyInput.messageSegments.add(textSegmentInput);
        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = '0F99E000000159R';
        messageBodyInput.messageSegments.add(mentionSegment);
        
        System.debug('%%%% messageBodyInput : '+messageBodyInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = caso.Id;


        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        batchInputs.add(batchInput);         
        if (batchInputs.size() > 0) {
            if (!Test.isRunningTest()) {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
        } 
                

    } 
}