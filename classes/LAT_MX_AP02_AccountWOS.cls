/*******************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------
*   Clase que contiene los triggers PRM del objeto Account
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/

public without sharing class LAT_MX_AP02_AccountWOS {
    
    //Este set contiene los nombres de los metodos que no se deben ejecutar
    //Si contiene "All" no se ejecuta ningun metodo
    //Debe ser cargado y limpiado en cada DML para no arrastrar 
    public static set<String> setExcludedMethods = new set<String>();
    
    /*****************************************************************************************
    * Nombre del metodo: ApprovalProcessFlow
    * Descripcion: Metodo que actualiza el campo LAT_MX_APStep__c que controla el proceso de aprobacion 
    *              y valida los campos que debe completar cada area antes de aprobar
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 16/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void ApprovalProcessFlow (List<Account> triggerNew, map<Id, Account> triggerOldMap){
               
        if(setExcludedMethods.contains('ApprovalProcessFlow') || setExcludedMethods.contains('All'))return;
               
        map<Decimal, String> mapStep = new map<Decimal, String> {
            1 => 'Em aprovação  - Comercial',
            2 => 'Analysis - Commercial Administration',
            3 => 'Analysis - Commercial Administration',
            4 => 'Analysis - Commercial Control',
            5 => 'Em análise - Crédito e Cobrança',
            6 => 'Em análise - Crédito e Cobrança',
            7 => 'Analysis - Logistics'};
        
        list<String> listCamposFaltantes = new list<String>();
        String CamposFaltantes = '';
        
        User us;
        CS006_DefaultUsers__c CsUserId  = CS006_DefaultUsers__c.getOrgDefaults();
        
        map<Id, list<LAT_MX_PMN_PromissoryNote__c>> mapAccIdProms = new map<Id, list<LAT_MX_PMN_PromissoryNote__c>>();
        map<Id, list<ProcessInstance>> mapAccIdProcs = new map<Id, list<ProcessInstance>>();
        
        Boolean queryPromNote = false;
        Boolean queryUserAndProcessInst = false;
        
        set<Id> setAccIds = new set<Id>();
        for (Account acc: triggerNew){
            setAccIds.add(acc.Id);
            if(acc.LAT_MX_APStep__c == 0 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == null){
                queryPromNote = true;
            }
            if(acc.LAT_MX_APStep__c == 5 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == 4){
                queryPromNote = true;
                queryUserAndProcessInst = true;
            }
        }
        
        
        if(queryPromNote){
            for(LAT_MX_PMN_PromissoryNote__c pr: [SELECT Id, LAT_MX_Executor__c, LAT_MX_LegalProcessApprover__c, LAT_MX_ApprovalDate__c FROM LAT_MX_PMN_PromissoryNote__c WHERE LAT_MX_Executor__c IN: setAccIds ORDER BY CreatedDate DESC]){
                if(mapAccIdProms.containsKey(pr.LAT_MX_Executor__c)){
                    mapAccIdProms.get(pr.LAT_MX_Executor__c).add(pr);
                }else{
                    mapAccIdProms.put(pr.LAT_MX_Executor__c, new List<LAT_MX_PMN_PromissoryNote__c>{pr});
                }
            }
        }
        
        if(queryUserAndProcessInst){
            for(ProcessInstance pi: [SELECT Id, TargetObjectId, (SELECT Id, ProcessInstanceId, TargetObjectId, OriginalActorId, ActorId, CreatedDate, CreatedById FROM StepsAndWorkitems) FROM ProcessInstance WHERE targetObjectId IN: setAccIds ORDER BY CreatedDate DESC]){
                if(mapAccIdProcs.containsKey(pi.TargetObjectId)){
                    mapAccIdProcs.get(pi.TargetObjectId).add(pi);
                }else{
                    mapAccIdProcs.put(pi.TargetObjectId, new List<ProcessInstance>{pi});
                }
            }
            us = [SELECT Id, UserName FROM User WHERE UserName =: CsUserId.LAT_MX_UserName3__c];
        }
        
        for (Account acc: triggerNew){
            String Message = '';
           
            if(acc.LAT_MX_APStep__c == 0 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == null){
                //validacion que no permite mandar a aprobar si no esta vacio el campo 'Informaciones necesarias para aprobacion' para Off
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade') && (acc.LAT_InformationUnfilled__c != '')){
                    String CamposFaltantesOff = acc.LAT_InformationUnfilled__c.replace('<br/>','\n');
                    CamposFaltantesOff = CamposFaltantesOff.replace('<b>','');
                    CamposFaltantesOff = CamposFaltantesOff.replace('</b>','');
                    CamposFaltantesOff = CamposFaltantesOff.replace('<span style="color: red;">','');
                    CamposFaltantesOff = CamposFaltantesOff.replace('</span>','');
                    Message += '\n' + label.LAT_MX_AP02_00003 + ' \n' + CamposFaltantesOff;
                    //LAT_MX_AP02_00003: Falta completar la siguiente información:
                }
                //validacion que no permite mandar a aprobar si no esta vacio el campo 'Informaciones necesarias para aprobacion' para On
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade') && (acc.LAT_InformationUnfilled__c != '')){
                    String CamposFaltantesOn = acc.LAT_InformationUnfilled__c.replace('<br/>','\n');
                    CamposFaltantesOn = CamposFaltantesOn.replace('<b>','');
                    CamposFaltantesOn = CamposFaltantesOn.replace('</b>','');
                    CamposFaltantesOn = CamposFaltantesOn.replace('<span style="color: red;">','');
                    CamposFaltantesOn = CamposFaltantesOn.replace('</span>','');
                    Message += '\n' + label.LAT_MX_AP02_00003 + ' \n' + CamposFaltantesOn;
                    //LAT_MX_AP02_00003: Falta completar la siguiente información:
                }
                //validacion que no permite mandar a aprobar si no esta vacio el campo 'Documentos faltantes'      
                if(acc.LAT_MX_MissingDocuments__c != null){
                    Message += '\n' + label.LAT_MX_AP02_00004 + ' \n' + acc.LAT_MX_MissingDocuments__c;
                    //LAT_MX_AP02_00004: Faltan los siguientes documentos:
                }
                //validacion que no permite mandar a aprobar un registro de tipo Pagador con Canal Mayorista que no tiene Pagare relacionado
                if(acc.Type == 'Payer' && acc.Channel__c == 'WS'){
                    
                    list<LAT_MX_PMN_PromissoryNote__c> listPagare = new list<LAT_MX_PMN_PromissoryNote__c>();
                    if(mapAccIdProms.containsKey(acc.Id)){
                        listPagare = mapAccIdProms.get(acc.Id);
                    }
                    
                    if(listPagare.IsEmpty()){
                        if(Message == ''){
                            Message += '\n' + label.LAT_MX_AP02_00002;
                            //LAT_MX_AP02_00002: No es posible enviar el registro a aprobación ya que no hay Pagaré generado.
                        }else{
                            Message += '\n\n' + label.LAT_MX_AP02_00002;
                            //LAT_MX_AP02_00002: No es posible enviar el registro a aprobación ya que no hay Pagaré generado.
                        }
                    }
                }
                if(Message != ''){
                    acc.AddError(Message);
                }
            }

            if(acc.LAT_MX_APStep__c == 0 && (triggerOldMap.get(acc.id).LAT_MX_APStep__c == null || acc.LAT_MX_APStep__c != triggerOldMap.get(acc.id).LAT_MX_APStep__c)){
                //primera vez que entro al proceso de aprobacion. modifica el Status y el AP Step
                if(triggerOldMap.get(acc.id).LAT_MX_APStep__c == null){
                    acc.Status__c = mapStep.get(1);
                    acc.LAT_MX_APStep__c = 1;
                //caso en que se reactiva el proceso de aprobacion. se asigna el AP Step del paso en que se rechazo y el Status que corresponde a ese paso    
                }else{
                    acc.Status__c = mapStep.get(triggerOldMap.get(acc.id).LAT_MX_APStep__c);
                    acc.LAT_MX_APStep__c = triggerOldMap.get(acc.id).LAT_MX_APStep__c;
                }
            }
           
            //validaciones de campos que se deben completar durante la Aprobacion de Administración Comercial
            if((acc.LAT_MX_APStep__c == 4 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == 2)|| (acc.LAT_MX_APStep__c == 7 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == 2)){
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')){
                    if(acc.LAT_MX_ABCCode__c == null){ listCamposFaltantes.add(Schema.Account.Field.LAT_MX_ABCCode__c.getDescribe().getLabel());}
                    if(acc.LAT_MX_BatchProcess__c == null){ listCamposFaltantes.add(Schema.Account.Field.LAT_MX_BatchProcess__c.getDescribe().getLabel());}
                    if(acc.LAT_MX_FiscalRate__c == null){ listCamposFaltantes.add(Schema.Account.Field.LAT_MX_FiscalRate__c.getDescribe().getLabel());}
                }
                if(acc.Frequency_of_Visits__c == null){ listCamposFaltantes.add(Schema.Account.Field.Frequency_of_Visits__c.getDescribe().getLabel());}
                if(acc.Regional__c == null){ listCamposFaltantes.add(Schema.Account.Regional__c.getDescribe().getLabel());}
                if(acc.Type == 'Payer'){
                    if(acc.Billing_Priority__c == null){ listCamposFaltantes.add(Schema.Account.Field.Billing_Priority__c.getDescribe().getLabel());}
                }
            }
                        
            //validaciones de campos que se  deben completar durante la Aprobacion de Legales
            if(acc.LAT_MX_APStep__c == 5 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == 4){
                List<ProcessInstance> procis = new List<ProcessInstance>();
                if(mapAccIdProcs.containsKey(acc.Id)){
                    procis = mapAccIdProcs.get(acc.Id);
                }
                
                list<LAT_MX_PMN_PromissoryNote__c> listPagare = new list<LAT_MX_PMN_PromissoryNote__c>();
                if(mapAccIdProms.containsKey(acc.Id)){
                    listPagare = mapAccIdProms.get(acc.Id);
                }
                
                if(!procis.isEmpty() && !listPagare.IsEmpty() && CsUserId.LAT_MX_UserName3__c != null){
                    for(ProcessInstance pi: procis){
                        for(integer i=0;i<pi.StepsAndWorkitems.size()-1;i++){
                            if(pi.StepsAndWorkitems[i].OriginalActorId == us.Id){
                                listPagare[0].LAT_MX_LegalProcessApprover__c = pi.StepsAndWorkitems[i].ActorId;
                                listPagare[0].LAT_MX_ApprovalDate__c = pi.StepsAndWorkitems[i].CreatedDate.date();
                            }
                                
                        }
                    }
                    if(!listPagare.isEmpty()){
                        update listPagare;
                    }
                }
            }
            
            //validaciones de campos que se  deben completar durante la Aprobacion de Créditos y Cobranzas
            if(acc.LAT_MX_APStep__c == 7 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == 5){
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')){
                    if(acc.Credit_line__c == null){ listCamposFaltantes.add(Schema.Account.Field.Credit_line__c.getDescribe().getLabel());}
                }
                if(acc.Type == 'Payer'){
                    if(acc.Contact_Schedule__c == null){ listCamposFaltantes.add(Schema.Account.Field.Contact_Schedule__c.getDescribe().getLabel());}
                    if(acc.LAT_MX_CreditAndCollectionsExecutive__c == null){ listCamposFaltantes.add(Schema.Account.Field.LAT_MX_CreditAndCollectionsExecutive__c.getDescribe().getLabel());}
                    if(acc.Payment_instrument__c == null){ listCamposFaltantes.add(Schema.Account.Field.Payment_instrument__c.getDescribe().getLabel());}
                    if(acc.Customer_GL__c == null){ listCamposFaltantes.add(Schema.Account.Field.Customer_GL__c.getDescribe().getLabel());}                    
                    if(acc.LAT_MX_CreditVersionLevel__c == null){ listCamposFaltantes.add(Schema.Account.Field.LAT_MX_CreditVersionLevel__c.getDescribe().getLabel());}
                }                
            }
            //validaciones de campos que se  deben completar durante la Aprobacion de Logística
            if(acc.LAT_MX_APStep__c == 8 && triggerOldMap.get(acc.id).LAT_MX_APStep__c == 7){
                if(acc.Business_Unit_AR__c == null){ listCamposFaltantes.add(Schema.Account.Field.Business_Unit_AR__c.getDescribe().getLabel());}
                if(acc.RecordTypeId == Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OffTrade')){               
                    if(acc.LAT_MX_ZoneNumber__c == null){ listCamposFaltantes.add(Schema.Account.Field.LAT_MX_ZoneNumber__c.getDescribe().getLabel());}
                }
            }
            //si hay campo que falta completar se muestra un mensaje con el label de los campos
            if(!listCamposFaltantes.isEmpty()){
                if(listCamposFaltantes.size() > 1){
                    for(Integer i = 0; i < listCamposFaltantes.size() ; i++){
                        if(i == listCamposFaltantes.size()-1){
                            CamposFaltantes = CamposFaltantes + listCamposFaltantes[i];
                        }else{
                            CamposFaltantes = CamposFaltantes + listCamposFaltantes[i] + ', ';
                        }
                    }
                }else{
                    CamposFaltantes = CamposFaltantes + listCamposFaltantes[0];
                }
                acc.addError(label.LAT_MX_AP02_00001 + ' ' + CamposFaltantes);
                //LAT_MX_AP02_00001: Debe completar los siguientes campos para aprobar el registro:
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: AccountCloneFieldToNull
    * Descripcion: Metodo que vacia campos cuando se clona un cliente 
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 10/10/2013
    * Modo: before insert
    *****************************************************************************************/
    public static void AccountCloneFieldToNull(List<Account> triggerNew){
        
        if(setExcludedMethods.contains('AccountCloneFieldToNull') || setExcludedMethods.contains('All'))return;
        
        String profName = LAT_GlobalProfileCache.getProfileNameById(UserInfo.getProfileId());
        Boolean isUserMX = profName == 'LAT_MX_Administracion Comercial' || 
                           profName == 'LAT_MX_Creditos y Cobranzas' || 
                           profName == 'LAT_MX_Legales' || 
                           profName == 'LAT_MX_Logistica' || 
                           profName == 'LAT_MX_On Premise' || 
                           profName == 'LAT_MX_Vendedor' ||
                           profName == 'LAT_MX2_AdministracionComercial' || 
                           profName == 'LAT_MX2_CreditosyCobranzas' || 
                           profName == 'LAT_MX2_Legales' || 
                           profName == 'LAT_MX2_Logistica' || 
                           profName == 'LAT_MX2_OnPremise' || 
                           profName == 'LAT_MX2_Vendedor' ||
                           profName == 'LAT_MX2_Vendedor_OnPremise';
        
        for(Account acc: triggerNew){
            if(isUserMX){
                acc.Client_code_AN8__c = null;
                acc.Credit_line__c = null;
                acc.Reason_for_Inactivation__c = null;
                acc.Status__c = 'Novo cadastro';
                acc.Rating = null;
                acc.LAT_MX_APStep__c = null;
            }
        }
    }
    
    /*********************************************************************************************************
    * Nombre del metodo: updatesAvailableCreditLimit
    * Descripcion: Metodo que carga en un set los Ids de los Accounts de los cuales se debe 
                   recalcular el Available Credit Limit y llama a la clase que realiza el calculo
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 09/12/2013
    * Modo: after insert, after update, after delete
    *********************************************************************************************************/
    public static void updatesAvailableCreditLimit(List<Account> triggerNew, Map<Id,Account> oldMap){
        
        if(setExcludedMethods.contains('updatesAvailableCreditLimit') || setExcludedMethods.contains('All'))return;
        
        Set<String> setAccountsToUpdate = new Set<String>();
        if(triggerNew != null && !triggerNew.isEmpty()){
            for(Account acc: triggerNew){
                if(oldMap == null || (oldMap != null && oldMap.containsKey(acc.Id) &&  acc.Credit_line__c != oldMap.get(acc.Id).Credit_line__c)){
                      setAccountsToUpdate.add(acc.Id); 
                }
            }
        }else{
            for(Account acc: OldMap.values()){
                if(acc.ParentId != null){
                    setAccountsToUpdate.add(acc.Id); 
                }
            }
        }
        
        String returnMessage; 
        if(!setAccountsToUpdate.isEmpty()){
            returnMessage = LAT_MX_AvailableCreditLimit.CalculatesAvailableCreditLimit(setAccountsToUpdate);
            if(returnMessage != 'OK'){
                if(triggerNew != null && !triggerNew.isEmpty()){
                    for(Account acc: triggerNew){
                        if(setAccountsToUpdate.contains(acc.Id)){
                            acc.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }
                }else{
                    for(Account acc: OldMap.values()){
                        if(setAccountsToUpdate.contains(acc.Id)){
                            acc.addError(label.LAT_MX_AP01_00021 + ' ' + returnMessage);
                            //LAT_MX_AP01_00021: No se pudo actualizar el Límite de crédito disponible para el cliente o alguno de sus hijos por el siguiente error:
                        }
                    }
                }
            }
        }
          
    }  
    
    /*****************************************************************************************
    * Nombre del metodo: UpdateCNPJChildAccount
    * Descripcion: Si la cuenta tiene padre y el tipo de cliente es Consignado, Tienda que entrega 
    * información o Tienda donde ejecuto  that provides information, se copia el cnpj del padre al hijo
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 13/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void UpdateCNPJChildAccount (List<Account> triggerNew){
        
        if(setExcludedMethods.contains('UpdateCNPJChildAccount') || setExcludedMethods.contains('All'))return;
        
        set<Id> setParentIds = new set<Id>();
        for (Account acc: triggerNew){
            if(acc.ParentId != null){
                setParentIds.add(acc.ParentId);
            }
        }
        if(!setParentIds.isEmpty()){
            map<Id, Account> mapParentAccount = new map<Id, Account>([SELECT Id, CNPJ__c, LAT_MX_FiscalEntityType__c, Payment_Condition__c FROM Account WHERE Id IN: setParentIds]);
            for (Account acc: triggerNew){
                if ((acc.type == 'Consignee' || acc.type == 'Execution Store' || acc.type == 'Store that provides information') && (acc.ParentId != NULL)){
                    if(mapParentAccount.containsKey(acc.ParentId)){
                        acc.CNPJ__c = mapParentAccount.get(acc.ParentId).CNPJ__c;
                        acc.LAT_MX_FiscalEntityType__c = mapParentAccount.get(acc.ParentId).LAT_MX_FiscalEntityType__c;
                        acc.Payment_Condition__c = mapParentAccount.get(acc.ParentId).Payment_Condition__c;
                    } else {
                        acc.adderror(label.LAT_MX_AP01_00006);
                        //LAT_MX_AP01_00006: El usuario no tiene acceso al registro del cliente padre.
                    }
                }
            }
        }
    }
    
    /*****************************************************************************************
    * Nombre del metodo: ValidationCNPJDuplicate
    * Descripcion: Valida que no se inserten Accounts con CNPJ duplicados
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 16/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void ValidationCNPJduplicate (List<Account> triggerNew, String UpdateOinsert, map<Id, Account> oldMap){
        
        if(setExcludedMethods.contains('ValidationCNPJduplicate') || setExcludedMethods.contains('All'))return;
        
        List<Account> triggerNew2 = new List<Account>();
        for(Account acc: triggerNew){
            if(acc.RecordTypeID != Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')){
            if(UpdateOinsert == 'insert' || acc.ParentId != oldMap.get(acc.Id).ParentId || acc.SaveDuplicatedFiscalID_AR__c != oldMap.get(acc.Id).SaveDuplicatedFiscalID_AR__c){
                triggerNew2.add(acc);
               }
            }
        }
        
        if(!triggerNew2.isEmpty()){
    
            list<account> accSincheckParents = new list<account>();
            list<account> accSincheckSons = new list<account>();
            list<account> accConcheck = new list<account>();
            list<account> accOrdenada = new list<account>();
            set<string> setcnpjRepes = new set<string>();
         
            for (Integer i = 0; i < triggerNew2.size(); i++) {
                if (triggerNew2[i].ParentId == null && triggerNew2[i].SaveDuplicatedFiscalID_AR__c == false ){  // (si ES padre y NO tiene el check en true)
                    accSincheckParents.add(triggerNew2[i]);
                }
                if (triggerNew2[i].ParentId != null ){  // (si ES hijo y NO tiene el check en true)
                    accSincheckSons.add(triggerNew2[i]);
                }
                if (triggerNew2[i].SaveDuplicatedFiscalID_AR__c == true && triggerNew2[i].ParentId == null  ){  // (SI tiene el check en true)
                    accConcheck.add(triggerNew2[i]);
                }
            }
          
            // INSERTO TODAS LAS ACCOUNT EN TRIGGER NEW PERO EN ORDEN.
    
            for (Account acc : accSincheckParents){   
                accOrdenada.add(acc);
            }
    
            for (Account acc : accSincheckSons){   
                accOrdenada.add(acc);
            }
    
            for (Account acc : accConcheck){   
                accOrdenada.add(acc);
            }
            
            for (Account acc : accOrdenada){
                if ( !setcnpjRepes.Contains(acc.CNPJ__c) ){
                    setcnpjRepes.add(acc.CNPJ__c);
                } else {
                    if(acc.ParentId == NULL && acc.SaveDuplicatedFiscalID_AR__c == false){
                        acc.adderror(label.LAT_MX_AP01_00005 + acc.CNPJ__c);
                        //LAT_MX_AP01_00005: Id Fiscal duplicado:
                    }
                }             
            }
            
            set<string> setMX = new set<string>();
            
            for(Account acc: accOrdenada){
                if(acc.ParentId == null){
                    setMX.add(acc.CNPJ__c);
                }
            }
            
            list<Account> cuentasBaseDatosMX = new list<Account>();
            
            Set<Id> setRtMX = Global_RecordTypeCache.getRtIdSet('Account', new Set<String>{'LAT_MX_ACC_OffTrade','LAT_MX_ACC_OnTrade'});
    
            if (UpdateOinsert == 'insert'){
                cuentasBaseDatosMX = ([SELECT Id, CNPJ__c, Name, Client_code_AN8__c FROM Account WHERE cnpj__c IN:setMX AND ParentId=:null AND RecordTypeId IN: setRtMX]);
            }else{
                cuentasBaseDatosMX = ([SELECT Id, CNPJ__c, Name, Client_code_AN8__c FROM Account WHERE cnpj__c IN:setMX AND ParentId=:null AND id NOT IN:triggerNew2 AND RecordTypeId IN: setRtMX]);
            }
        
            map<String,Account> mapCnpjAcc = new map<String,Account>();
            set<id> setID = new set<id>();
            
            if (!cuentasBaseDatosMX.isEmpty()){
                for (Account acc : cuentasBaseDatosMX){
                    mapCnpjAcc.put(acc.CNPJ__c , acc);
                }
            }
                   
            for (Account acc : accOrdenada){
                if(acc.RecordTypeID != Global_RecordTypeCache.getRtId('Account' + 'LAT_MX_ACC_OnTrade')){
                if(acc.ParentId == null){
                    if( mapCnpjAcc.containsKey(acc.CNPJ__c)  && acc.SaveDuplicatedFiscalID_AR__c == false){
                        if(mapCnpjAcc.get(acc.CNPJ__c).Client_code_AN8__c == null){
                            acc.adderror(label.LAT_MX_AP01_00002 + ' ' + mapCnpjAcc.get(acc.CNPJ__c).Name + ', ' + label.LAT_MX_AP01_00003 + ' ' + label.LAT_MX_AP01_00008 + ' ' +  label.LAT_MX_AP01_00004);                    
                            //LAT_MX_AP01_00002: ID fiscal Duplicado. El valor ya existe para el siguiente cliente:
                            //LAT_MX_AP01_00003: Código de cliente (AN8):
                            //LAT_MX_AP01_00008: No posee.
                            //LAT_MX_AP01_00004: Si desea duplicar el ID Fiscal marque la casilla 'Grabar con ID Fiscal Duplicado’.
                        } else{
                            acc.adderror(label.LAT_MX_AP01_00002 + ' ' + mapCnpjAcc.get(acc.CNPJ__c).Name + ', ' + label.LAT_MX_AP01_00003 + ' ' + mapCnpjAcc.get(acc.CNPJ__c).Client_code_AN8__c + '. ' +  label.LAT_MX_AP01_00004);
                            //LAT_MX_AP01_00002: ID fiscal Duplicado. El valor ya existe para el siguiente cliente:
                            //LAT_MX_AP01_00003: Código de cliente (AN8):
                            //LAT_MX_AP01_00004: Si desea duplicar el ID Fiscal marque la casilla 'Grabar con ID Fiscal Duplicado’.
                        }
                    }
                }
            }
            }
        }
    }

    /*****************************************************************************************
    * Nombre del metodo: ValidatesGranSonAccounts
    * Descripcion: Valida que una cuenta no pueda tener nietos.
    * Desarrollador: Elena J. Schwarzböck
    * Fecha: 18/09/2013
    * Modo: before insert, before update
    *****************************************************************************************/
    public static void GrandSonValidate(List<Account> triggerNew){
        
        if(setExcludedMethods.contains('GrandSonValidate') || setExcludedMethods.contains('All'))return;
        
        Set<id> setIdsParent = new Set<id>();
        for (Account acc : triggerNew) {
            if(acc.ParentId!=null){
                setIdsParent.add(acc.ParentId);
            }       
        }
        
        Set<id> setIdsParentWithParent = new Set<id>();
        for(Account accs: [SELECT id, Recordtype.developerName FROM Account where ParentId != null and Id IN: setIdsParent]){
            setIdsParentWithParent.add(accs.Id);
        }
        
        for (Account acc : triggerNew) {
            if(acc.ParentId!=null){
                if(setIdsParentWithParent.contains(acc.ParentId)){
                    acc.adderror(label.LAT_MX_AP01_00007);
                    //LAT_MX_AP01_00007: No se pueden crear Cuentas Nieto.
                }
            }
        }
    }    
    
}