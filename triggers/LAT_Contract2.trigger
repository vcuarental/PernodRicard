/*
* LAT_Contract2
* Author: Martin Prado (martin@zimmic.com)
* Date: 07/28/2016
*/
trigger LAT_Contract2 on Lat_Contract2__c (before insert, before update, after update, after insert, before delete) {
    String CONTRACT_STATUS_ACTIVE = 'Ativo';
    String CONTRACT_STATUS_NEW = 'Novo Contrato';
    String CONTRACT_STATUS_REJECTED = 'Reprovado';    
    String CONTRACT_STATUS_APPROVAL = 'Em Aprovação';   
    String CONTRACT_STATUS_DISTRATO = 'Em Distrato';    
    String CONTRACT_STATUS_DISTRATO_APPROVAL = 'Distrato em Aprovação';    
    String CONTRACT_STATUS_DISTRATO_APPROVED = 'Distrato Aprovado';     
    String CONTRACT_STATUS_CLOSED = 'Encerrado';    
    String CONTRACT_PROCESS_STATUS_ADITIVADO = 'Contrato Aditivado';    
    String CONTRACT_PROCESS_STATUS_PRORROGADO = 'Contrato Prorrogado';    

    LAT_Trigger objTrigger = null;
    LAT_Docusign_Config__c objConfig = null;
    Id strProfileId = null;
    User objContractOwner = null;
    Account objContractAccount = null;
    Boolean boolHaveWebPermission =  false;
    Boolean boolIsSOAP = false; 
    String strRequestUrl = null;
    String[] lstAdminProfiles = null;
    Map<String, Double> mapROISegments = null;
    Map<Id, User> mapUsers =  null;
    Map<Id, Account> mapAccounts =null;
    List<LAT_Contract2__c> lstContracts = null;
    List<LAT_Contract2__c> lstContractsToUpdate = null;
    List<LAT_Contract2__c> lstContractsParent = null;
    List<Profile> lstProfiles = null;
    List<LAT_ROISegments__c> lstROISegments = null;
    Set<Id> setUserIds = null;
    Set<Id> setAccountIds = null;
    Set<String> setRecordTypes = null;
    Set<Id> setContractClosedDate = null;
    Set<Id> setToReviewIds = null;

    System.debug('LAT_Contract2.trigger[] ->');

    lstContracts = (Trigger.isDelete) ? Trigger.old : Trigger.new;

    setRecordTypes = new Set<String>();
    setRecordTypes.add('LAT_Eventos_Contrato_de_Parceria');
    setRecordTypes.add('LAT_Eventos_Contrato_de_Parceria_Distribuidor');
    setRecordTypes.add('LAT_OnTrade_LetterAgreementCommercialCondition');
    setRecordTypes.add('LAT_OnTrade_LetterAgreement');
    setRecordTypes.add('LAT_OnTrade_CommercialConditionContract');
    setRecordTypes.add('LAT_OnTrade_SponsorshipAgreementOnTrade');
    setRecordTypes.add('LAT_CartaAtivacao');
    setRecordTypes.add('LAT_BR_Acordo');

    System.debug('LAT_Contract2.trigger[setRecordTypes : ' + setRecordTypes + ']');

    objTrigger = new LAT_Trigger('LAT_Contract2__c', setRecordTypes);

    if(objTrigger.getNew() != null && !objTrigger.getNew().isEmpty()) {
        if (Trigger.isBefore) { 
            System.debug('LAT_Contract2.trigger[isBefore] ->');
            lstROISegments = [SELECT ROI__c, Segment__c 
                                FROM LAT_ROISegments__c];                    

            mapROISegments = new Map<String, Double>();
            for(LAT_ROISegments__c objROISegment : lstROISegments){
                mapROISegments.put(objROISegment.Segment__c.toLowerCase(), objROISegment.ROI__c );
            }

            if (!Utils.isPartOfMobileCRM(UserInfo.getUserId())) {
                boolHaveWebPermission = true;
                System.debug('LAT_Contract2.trigger[Is not part of Mobile CRM -> boolHaveWebPermission : ' + boolHaveWebPermission + ']');
            } else { 
                lstAdminProfiles = LAT_GeneralConfigDao.getValueAsStringArray('Admin', ' ');
                strProfileId = UserInfo.getProfileId();
                lstProfiles = [SELECT Name FROM Profile WHERE Id = :strProfileId];
    
                if (lstProfiles.isEmpty()) {
                    boolHaveWebPermission = (lstProfiles[0].Name != 'LAT_BR2_Vendas');
                    System.debug('LAT_Contract2.trigger[No es LAT Vendas -> boolHaveWebPermission : ' + boolHaveWebPermission + ']');
                } 
                
                if (!boolHaveWebPermission && lstAdminProfiles != null && !lstAdminProfiles.isEmpty() && !lstProfiles.isEmpty()) {
                    for (String strProfileName : lstAdminProfiles) {
                        if (strProfileName == lstProfiles[0].Name) {
                            boolHaveWebPermission = true;
                            System.debug('LAT_Contract2.trigger[Es perfil admin -> boolHaveWebPermission : ' + boolHaveWebPermission + ']');
                        }
                    }
                }
            }

            strRequestUrl = String.valueOf(URL.getCurrentRequestUrl());
            System.debug('LAT_Contract2.trigger[strRequestUrl : ' + strRequestUrl + ']');

            if(strRequestUrl.toLowerCase().contains('services/soap') || strRequestUrl.toLowerCase().contains('services/data') || strRequestUrl.toLowerCase().contains('services/apexrest') || strRequestUrl.toLowerCase().contains('apexfuture') ) {
                boolIsSOAP = true;
            }
            System.debug('LAT_Contract2.trigger[boolHaveWebPermission : ' + boolHaveWebPermission + ']');
            System.debug('LAT_Contract2.trigger[boolIsSOAP : ' + boolIsSOAP + ']');

            for (Lat_Contract2__c objContract : lstContracts) {    
                if (!boolIsSOAP && !boolHaveWebPermission ) {
                    if (Trigger.isDelete && ( objContract.Status__c  != CONTRACT_STATUS_NEW  && objContract.Status__c != CONTRACT_STATUS_REJECTED)) {
                        System.debug('LAT_Contract2.trigger[No puede eliminar un contato en el estado actual: ' + objContract.Status__c + ']');
                        objContract.addError('Você não tem acesso para Deletar Contratos via CRM Web. Favor utilizar o Compass.');
                    }
                    if (trigger.isUpdate || trigger.isInsert) {
                        System.debug('LAT_Contract2.trigger[No puede actualizar un contrato]');
                        objContract.addError('Você não tem acesso para Criar/Editar Contratos via CRM Web. Favor utilizar o Compass.');
                    }    
                }
            }
            System.debug('LAT_Contract2.trigger[isBefore] <-');
        } 

        if (Trigger.isInsert) {
            System.debug('LAT_Contract2.trigger[isInsert] ->');
            setUserIds = new Set<Id>();
            setAccountIds = new Set<Id>();
            setToReviewIds = new Set<Id>();
    
            for ( Lat_Contract2__c objContract : Trigger.new ) {
                setUserIds.add(objContract.OwnerId);
                setAccountIds.add(objContract.Account__c);
                setToReviewIds.add(objContract.Id);
            }
    
            if (trigger.isAfter) {
                System.debug('LAT_Contract2.trigger[isInsert.isAfter] ->');
                lstContractsToUpdate =[SELECT Name, Status__c, LAT_ContractNumber__c, LAT_IsAdmin__c, OriginalContractNumber__c 
                                        FROM LAT_Contract2__c 
                                        WHERE ID IN :setToReviewIds
                                        AND LAT_IsAdmin__c = false];
                
                if (!lstContractsToUpdate.isEmpty()) {               
                    for ( Lat_Contract2__c objContract : lstContractsToUpdate) {
                        objContract.Name = objContract.LAT_ContractNumber__c;
                    }     
                    
                    System.debug('LAT_Contract2.trigger[updating contract names...' + lstContractsToUpdate + ']');
                    update lstContractsToUpdate;
                }
                System.debug('LAT_Contract2.trigger[isInsert.isAfter] <-');
            } else if (trigger.isBefore) {
                System.debug('LAT_Contract2.trigger[isInsert.isBefore] ->');

                mapUsers =  new Map<Id,User>([ SELECT Gerente_de_area__c,Gerente_regional__c,ManagerId 
                                                FROM User 
                                                WHERE Id in: setUserIds]);

                mapAccounts =  new Map<Id,Account>([SELECT Client_code_AN8__c, Id 
                                                    FROM Account 
                                                    WHERE Id in: setAccountIds]);
    
                for (LAT_Contract2__c objContract : Trigger.new ) {
                    if (!objContract.LAT_IsAdmin__c) {
                        System.debug('LAT_Contract2.trigger[updating manager fields...]');

                        if(mapUsers.containsKey(objContract.OwnerId)){
                            objContractOwner = mapUsers.get(objContract.OwnerId);
                            objContract.GeneralManager__c = objContractOwner.Gerente_de_area__c;
                            objContract.Manager__c = objContractOwner.ManagerId;
                            objContract.RegionalManager__c = objContractOwner.Gerente_regional__c;

                            System.debug('LAT_Contract2.trigger[objContract.GeneralManager__c : ' + objContract.GeneralManager__c + ']');
                            System.debug('LAT_Contract2.trigger[objContract.Manager__c : ' + objContract.Manager__c + ']');
                            System.debug('LAT_Contract2.trigger[objContract.RegionalManager__c : ' + objContract.RegionalManager__c + ']');
                        }

                        if(mapAccounts.containsKey(objContract.Account__c)){
                            objContractAccount = mapAccounts.get(objContract.Account__c);
                            if(String.isBlank(objContractAccount.Client_code_AN8__c)){
                                System.debug('LAT_Contract2.trigger[La cuenta del contrato no tiene AN8 - AccountId : ' + objContractAccount.Id + ']');
                                objContract.Account__c.addError(Label.LAT_ContractAN8Error);
                            }
                        }
    
                        if(objContract.ROISegment__c != null){
                            if(mapROISegments.containsKey(objContract.ROISegment__c.toLowerCase())){
                                System.debug('LAT_Contract2.trigger[Asignando segmento ROI... ' + objContract.ROISegment__c + ' : ' + mapROISegments.get(objContract.ROISegment__c.toLowerCase()) + ']');
                                objContract.ROI_Target__c = mapROISegments.get(objContract.ROISegment__c.toLowerCase());
                            }
                        }
                    }
                }
                System.debug('LAT_Contract2.trigger[isInsert.isBefore] <-');
            }
            System.debug('LAT_Contract2.trigger[isInsert] <-');
        }    

        if (Trigger.isUpdate) {
            System.debug('LAT_Contract2.trigger[isUpdate] ->');

            if (Trigger.isAfter) {
                System.debug('LAT_Contract2.trigger[isUpdate.isAfter] ->');

                setContractClosedDate = new Set<Id>();
                for ( Lat_Contract2__c objContract : Trigger.new ) {
                    if (objContract.Status__c == CONTRACT_STATUS_ACTIVE && Trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_ACTIVE) {
                        System.debug('LAT_Contract2.trigger[updateing original date...' + objContract.id + ']');

                        LAT_ContractsCalculations.updateOriginalDate(objContract.id);
    
                        if(objContract.OriginalContractNumber__c != null) {
                            setContractClosedDate.add(objContract.OriginalContractNumber__c);
                        }
                    }
    
                    if( (objContract.Status__c == CONTRACT_STATUS_ACTIVE && Trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_ACTIVE ) || (objContract.Status__c != CONTRACT_STATUS_ACTIVE && Trigger.oldMap.get(objContract.id).Status__c == CONTRACT_STATUS_ACTIVE )) {
                        System.debug('LAT_Contract2.trigger[checking if more than one active contract...' + objContract.id + ']');
                        LAT_CustomerContractsClassification.accountHasMoreThanOneActiveContract(Trigger.newMap);
                    }
    
                    if ((objContract.Status__c == CONTRACT_STATUS_DISTRATO && trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_DISTRATO) && (objContract.ProcessStatus__c == CONTRACT_STATUS_DISTRATO_APPROVAL && trigger.oldMap.get(objContract.id).ProcessStatus__c != CONTRACT_STATUS_DISTRATO_APPROVAL)  ) {
                        System.debug('LAT_Contract2.trigger[sending distrato to approval...' + objContract.id + ']');
                        LAT_ContractDAHandlerInterface.runApprovalProcess(String.valueOf(objContract.Id));
                    }
                }

                if(!setContractClosedDate.IsEmpty()) {
                    lstContractsParent  = [SELECT Id 
                                            FROM LAT_Contract2__c 
                                            WHERE Id IN :setContractClosedDate];

                    if(lstContractsParent.IsEmpty()){
                        for(LAT_Contract2__c objContract : lstContractsParent){
                            objContract.Status__c = CONTRACT_STATUS_CLOSED;
                            objContract.ProcessStatus__c = CONTRACT_PROCESS_STATUS_ADITIVADO;
                        }
                        System.debug('LAT_Contract2.trigger[aditivating contracts...' + lstContractsParent + ']');
                        update lstContractsParent;
                    }
                }
                System.debug('LAT_Contract2.trigger[isUpdate.isAfter] <-');
            }
    
            if(Trigger.isBefore){
                System.debug('LAT_Contract2.trigger[isUpdate.isBefore] ->');
                for(LAT_Contract2__c objContract : Trigger.new) {
                    if( (objContract.LAT_IMMActivityInt__c == null && objContract.Acordo_IMM__c == null ) && objContract.Phase__c == 'Trade Approved'){
                        objContract.addError('Você deve preencher o campo Atividades do IMM antes de aprovar');
                        System.debug('LAT_Contract2.trigger[missing IMM activity...' + objContract.Id + ']');
                    }
                }
    
                // Function to control the value of the contract if is "condicao comercial"
                System.debug('LAT_Contract2.trigger[validating letter aggreement...]');
                LAT_ContractErrorsController.letterOfAgreementValidation(Trigger.new);               
                
                System.debug('LAT_Contract2.trigger[addint attachments and tasks...]');
                LAT_ContractsCalculations.addAttachmentsAndTasks(Trigger.new, Trigger.oldMap);
                
                System.debug('LAT_Contract2.trigger[chatter group notification...]');
                LAT_ContractsCalculations.chatterGroupNotification(Trigger.new, Trigger.oldMap);
    
    
                setUserIds = new Set<Id>();    
                for ( LAT_Contract2__c objContract : Trigger.new ) {
                    if (objContract.OwnerId != Trigger.oldMap.get(objContract.Id).OwnerId) {                                        
                        System.debug('LAT_Contract2.trigger[contract owner changerd...' + Trigger.oldMap.get(objContract.Id).OwnerId + ' --> ' + objContract.OwnerId + ']');
                        setUserIds.add(objContract.OwnerId);
                    } 

                    // When the contract is closed, we have to save the current date
                    // If the contrac is "Em aprovacao" we save the roi segment again
                    //----Esto se hace arriba en el IsBefere. Por que se vuelve a hacer.
                    //
                    if(objContract.ROISegment__c != null){
                        if(mapROISegments.containsKey(objContract.ROISegment__c.toLowerCase())){
                            objContract.ROI_Target__c = mapROISegments.get(objContract.ROISegment__c.toLowerCase());
                        }
                        System.debug('LAT_Contract2.trigger[updating (again) ROI Target...]');
                    }
    
                    if (objContract.Status__c == CONTRACT_STATUS_CLOSED && Trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_CLOSED) {
                        objContract.ClosedDate__c = Date.today();
                        System.debug('LAT_Contract2.trigger[updating contract close date...]');
                    }
                    
                    if (objContract.Status__c == CONTRACT_STATUS_APPROVAL && trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_APPROVAL) {                                        
                        setUserIds.add(objContract.OwnerId);
                    } else if (objContract.Status__c == CONTRACT_STATUS_DISTRATO_APPROVED && Trigger.oldMap.get(objContract.Id).Status__c != CONTRACT_STATUS_DISTRATO_APPROVED){
                        System.debug('LAT_Contract2.trigger[canceling docusing...' + objContract.Id + ']');
                        LAT_Docusign_Utils.cancelDocusignFuture(objContract.Id);
                    }
    
                    objConfig = LAT_Docusign_Utils.getDocusignConfig();    
                    // Uses the signature flow only according to the flow configuration
                    if (!objConfig.Enable_Docusign_Contracts__c){
                        // Signature flow status must udpdate the status do proceso
                        if (objContract.SignaturesFlow__c != trigger.oldMap.get(objContract.id).SignaturesFlow__c ) {
                            System.debug('LAT_Contract2.trigger[updating process status...]');
                            LAT_ContractsCalculations.updateProcessStatus(Trigger.new);
                        }
                    }
    
                    // Extend Contract
                    if (objContract.Status__c == CONTRACT_STATUS_ACTIVE && objContract.ProcessStatus__c == CONTRACT_PROCESS_STATUS_PRORROGADO && Trigger.oldMap.get(objContract.Id).ProcessStatus__c != CONTRACT_PROCESS_STATUS_PRORROGADO) {
                        // If mobile change the status to Prorrogado, we must set some values and don't recaculate values or Roi
                        objContract.OriginalEndDate__c = objContract.EndDate__c;
                        objContract.OriginalContractTerms__c = objContract.ContractTerms__c;
                        objContract.EndDate__c = objContract.EndDate__c.addMonths(12);

                        System.debug('LAT_Contract2.trigger[prorroging contract...' + objContract.Id + ' from ' + objContract.OriginalEndDate__c + ' to ' + objContract.EndDate__c +']');
                    }
                }
    
                mapUsers =  new Map<Id,User>([ SELECT Gerente_de_area__c,Gerente_regional__c,ManagerId 
                                                FROM User 
                                                WHERE Id in: setUserIds]);

                // esto ya se hace arriba.... 4 8 15 16  23  
                for ( LAT_Contract2__c objContract : Trigger.new ) {
                    if(objContract.OwnerId != Trigger.oldMap.get(objContract.Id).OwnerId || objContract.Status__c == CONTRACT_STATUS_APPROVAL && Trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_APPROVAL) {
                        System.debug('LAT_Contract2.trigger[updating manager fields...]');

                        if(mapUsers.containsKey(objContract.OwnerId)){
                            objContractOwner = mapUsers.get(objContract.OwnerId);
                            objContract.GeneralManager__c = objContractOwner.Gerente_de_area__c;
                            objContract.Manager__c = objContractOwner.ManagerId;
                            objContract.RegionalManager__c = objContractOwner.Gerente_regional__c;

                            System.debug('LAT_Contract2.trigger[objContract.GeneralManager__c : ' + objContract.GeneralManager__c + ']');
                            System.debug('LAT_Contract2.trigger[objContract.Manager__c : ' + objContract.Manager__c + ']');
                            System.debug('LAT_Contract2.trigger[objContract.RegionalManager__c : ' + objContract.RegionalManager__c + ']');
                        }

                        if(objContract.Status__c == CONTRACT_STATUS_APPROVAL && Trigger.oldMap.get(objContract.id).Status__c != CONTRACT_STATUS_APPROVAL) {
                            System.debug('LAT_Contract2.trigger[sending contract to approval : ' + objContract.Id + ']');

                            LAT_ContractDAHandlerInterface.runApprovalProcess(String.valueOf(objContract.Id));
                        }
                    }
                }
            }
            System.debug('LAT_Contract2.trigger[isUpdate.isBefore] <-');
        }

        System.debug('LAT_Contract2.trigger[isUpdate)] <-');    }

    /*
    LAT_Trigger trigger_BR = new LAT_Trigger('LAT_Contract2__c', new set<String>{'LAT_Eventos_Contrato_de_Parceria','LAT_Eventos_Contrato_de_Parceria_Distribuidor','LAT_OnTrade_LetterAgreementCommercialCondition','LAT_OnTrade_LetterAgreement','LAT_OnTrade_CommercialConditionContract','LAT_OnTrade_SponsorshipAgreementOnTrade','LAT_CartaAtivacao'});

    if(trigger_BR.getNew() == null) {
        return;
    }
    if(trigger_BR.getNew().isEmpty()) {
        return;
    }
    // New control to allow to update and create via mobile
    if (trigger.isBefore) {
        // We compare the actual profile name, with the admin list from the custom setting,
        // if the user has permission we save the var haveWebPermission
        
        final String[] adminProfiles = LAT_GeneralConfigDao.getValueAsStringArray('Admin', ' ');
        final Id profileId = userinfo.getProfileId();
        final List <Profile> profileName = [SELECT Name FROM Profile WHERE id = :profileId];
        Boolean haveWebPermission =  false;

        // Check if the profile is vendas
        if (profileName.size() > 0) {

            haveWebPermission = (profileName[0].Name != 'LAT_BR2_Vendas');
            System.debug('=================> haveWebPermission: ' + haveWebPermission);
        }

        // Check if the profile is admin
        if (adminProfiles != null && adminProfiles.size() > 0 && profileName.size() > 0) {
            for (String pName : adminProfiles) {
                if (pName == profileName[0].Name) {
                    haveWebPermission = true;
                }
            }
            System.debug('=================> haveWebPermission admin: ' + haveWebPermission);
        }

        // Check if the profile is admin
        if (!Utils.isPartOfMobileCRM(UserInfo.getUserId())) {
            haveWebPermission = true;
            System.debug('=================> haveWebPermission isPartOfMobileCRM: ' + haveWebPermission);
        }


        // If the user doen't has permission and the source is not mobile,
        // we must show an error
        //if(!haveWebPermission) {
        System.debug('=================> SOAP: ' + String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('services/soap'));
        Boolean isSoap = false; //String.valueOf(URL.getCurrentRequestUrl()).toLowerCase().contains('services/soap');
        String requestUrl = String.valueOf(URL.getCurrentRequestUrl());
        if(requestUrl.toLowerCase().contains('services/soap') || requestUrl.toLowerCase().contains('services/data') || requestUrl.toLowerCase().contains('services/apexrest')  ) {
            isSoap = true;
        }

        System.debug('=================> isSoap : ' + isSoap);


        //List <Lat_Contract2__c> contracts = (trigger.isDelete) ? trigger.old : trigger.new;
        List <Lat_Contract2__c> contracts = (trigger.isDelete) ? trigger.old : trigger.new;
        for (Lat_Contract2__c ct : contracts) {
            System.debug('=================> Source: ' + ct.source__c);
            System.debug('=================> Exlusivity__c: ' + ct.Exlusivity__c);

            if (!isSoap && !haveWebPermission ) {
                // HOT FIX, when we use the api service from anonther object(task) the contract is locked
                //if ((ct.Status__c == 'Ativo'  && ct.SignaturesFlow__c == 'Consultor-Contrato Ativado') ||  ct.ProcessStatus__c == 'Contrato Não Assinado Cliente' || ct.SignaturesFlow__c == 'Consultor-Assinatura Cliente'  ) {
                //    System.debug('Updated form Task');

                //}
                if (trigger.isDelete && ('Novo Contrato' != ct.Status__c && 'Reprovado' != ct.Status__c)) {
                    ct.addError('Você não tem acesso para Deletar Contratos via CRM Web. Favor utilizar o Compass.');
                }
                if (trigger.isUpdate ||trigger.isInsert ) {
                    ct.addError('Você não tem acesso para Criar/Editar Contratos via CRM Web. Favor utilizar o Compass.');
                }

            }
        }
    }

    if (trigger.isInsert) {
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> toReviewIds = new Set<Id>();

        for ( Lat_Contract2__c ct : trigger.new ) {
            // Save the userID to query the information that we need to save in the contract to start the approval process
            userIds.add(ct.OwnerId);
            accountIds.add(ct.Account__c);
            toReviewIds.add(ct.Id);
        }


        if (trigger.isAfter) {
            List<LAT_Contract2__c> toUpdate = new List<LAT_Contract2__C>();
            for ( Lat_Contract2__c ct : [SELECT Name, Status__c, LAT_ContractNumber__c, LAT_IsAdmin__c, OriginalContractNumber__c FROM LAT_Contract2__c WHERE ID IN :toReviewIds] ) {
                // define if the name is filled by an autonumber or set in by insertion (old record re-inserted for history tracking)
                if (!ct.LAT_IsAdmin__c) {
                    ct.Name = ct.LAT_ContractNumber__c;
                    toUpdate.add(ct);
                }
                
            }
            if (!toUpdate.isEmpty()){
                update toUpdate;
            }
        }

        if (trigger.isBefore) {

            Map<Id, User> idUserMap =  new Map<Id,User>([SELECT Gerente_de_area__c,Gerente_regional__c,ManagerId FROM User where Id in: userIds]);
            Map<Id, Account> idAccountMap =  new Map<Id,Account>([SELECT Client_code_AN8__c, Id FROM Account where Id in: accountIds]);
            List<LAT_ROISegments__c> roiSegments = [Select ROI__c, Segment__c from LAT_ROISegments__c];
            Map<String, Double> roiSegmentMap = new Map<String, Double>();

            //Load segments values
            for(LAT_ROISegments__c rS : roiSegments){
                roiSegmentMap.put(rS.Segment__c.toLowerCase(), rS.ROI__c );
            }

            for ( Lat_Contract2__c ct : trigger.new ) {
                if (!ct.LAT_IsAdmin__c) {
                    // Update the managers fields in contract based on the User object information
                    if(idUserMap.containsKey(ct.ownerId)){
                        User owner = idUserMap.get(ct.ownerId);
                        ct.GeneralManager__c = owner.Gerente_de_area__c;
                        ct.Manager__c = owner.ManagerId;
                        ct.RegionalManager__c = owner.Gerente_regional__c;
                    }
                    // Only we can create contracts if we have AN8
                    if(idAccountMap.containsKey(ct.Account__c)){
                        Account acc = idAccountMap.get(ct.Account__c);
                        if(String.isBlank(acc.Client_code_AN8__c)){
                            ct.Account__c.addError(Label.LAT_ContractAN8Error);
                        }
                    }

                    if(ct.ROISegment__c != null){
                        if(roiSegmentMap.containsKey(ct.ROISegment__c.toLowerCase())){
                            ct.ROI_Target__c = roiSegmentMap.get(ct.ROISegment__c.toLowerCase());
                        }
                    }
                }
            }
        }

    }

    if (trigger.isUpdate) {

        if (trigger.isAfter) {

            Set<Id> contractClosedDate = new Set<Id>();
            for ( Lat_Contract2__c ct : trigger.new ) {
                // If the contract is active we must save the Original Payment Date on payments
                if (ct.Status__c == 'Ativo' && trigger.oldMap.get(ct.id).Status__c != 'Ativo') {
                    LAT_ContractsCalculations.updateOriginalDate(ct.id);

                    if(ct.OriginalContractNumber__c != null) {
                        contractClosedDate.add(ct.OriginalContractNumber__c);
                    }

                }

                // Account has active contracts
                if(ct.Status__c == 'Ativo' && trigger.oldMap.get(ct.id).Status__c != 'Ativo' || ct.Status__c != 'Ativo' && trigger.oldMap.get(ct.id).Status__c == 'Ativo') {
                    LAT_CustomerContractsClassification.accountHasMoreThanOneActiveContract(trigger.newMap);
                }

                // Cancel contract process:
                if ((ct.Status__c == 'Em Distrato' && trigger.oldMap.get(ct.id).Status__c != 'Em Distrato') && (ct.ProcessStatus__c == 'Distrato em Aprovação' && trigger.oldMap.get(ct.id).ProcessStatus__c != 'Distrato em Aprovação')  ) {
                    // Run approval process
                    LAT_ContractDAHandlerInterface.runApprovalProcess(String.valueOf(ct.Id));
                }
            }
            //
            List<Lat_Contract2__c> contractsParent = [Select Id from Lat_Contract2__c where Id IN :contractClosedDate];
            if(contractsParent.size()>0){
                for(Lat_Contract2__c con :contractsParent){
                    con.Status__c = 'Encerrado';
                    con.ProcessStatus__c = 'Contrato Aditivado';
                }
                update contractsParent;
            }

        }

        if(trigger.isBefore){

            for(LAT_Contract2__c con : trigger.new) {
                if(con.LAT_ImmActivityInt__c == null && con.Phase__c == 'Trade Approved'){
                    con.addError('Você deve preencher o campo Atividades do IMM antes de aprovar');
                }
            }

            // Function to control the value of the contract if is "condicao comercial"
            LAT_ContractErrorsController.letterOfAgreementValidation(trigger.new);
            
            LAT_ContractsCalculations.addAttachmentsAndTasks(trigger.new, trigger.oldMap);
            
            LAT_ContractsCalculations.chatterGroupNotification(trigger.new, trigger.oldMap);

            List<LAT_ROISegments__c> roiSegments = [Select ROI__c, Segment__c from LAT_ROISegments__c];
            Map<String, Double> roiSegmentMap = new Map<String, Double>();

            //Load segments values
            for(LAT_ROISegments__c rS : roiSegments){
                roiSegmentMap.put(rS.Segment__c.toLowerCase(), rS.ROI__c );
            }

            Set<Id> userIds = new Set<Id>();

            for ( Lat_Contract2__c ct : trigger.new ) {
                if (ct.OwnerId != trigger.oldMap.get(ct.id).OwnerId) {
                                    
                    userIds.add(ct.OwnerId);
                // if the contract is cancelled send the Docusign pdf to sign
                } 
                // When the contract is closed, we have to save the current date
                // If the contrac is "Em aprovacao" we save the roi segment again
                if(ct.ROISegment__c != null){
                    if(roiSegmentMap.containsKey(ct.ROISegment__c.toLowerCase())){
                        ct.ROI_Target__c = roiSegmentMap.get(ct.ROISegment__c.toLowerCase());
                    }
                }

                if (ct.Status__c == 'Encerrado' && trigger.oldMap.get(ct.id).Status__c != 'Encerrado') {
                    ct.ClosedDate__c = Date.today();
                }
                if (ct.Status__c == 'Em Aprovação' && trigger.oldMap.get(ct.id).Status__c != 'Em Aprovação') {
                                    
                    userIds.add(ct.OwnerId);
                // if the contract is cancelled send the Docusign pdf to sign
                } else if (ct.Status__c == 'Distrato Aprovado' && trigger.oldMap.get(ct.id).Status__c != 'Distrato Aprovado'){
                    LAT_Docusign_Utils.cancelDocusignFuture(ct.Id);
                }

                // Uses the signature flow only according to the flow configuration
                LAT_Docusign_Config__c config = LAT_Docusign_Utils.getDocusignConfig();

                if (!config.Enable_Docusign_Contracts__c){
                  // Signature flow status must udpdate the status do proceso
                  if (ct.SignaturesFlow__c != trigger.oldMap.get(ct.id).SignaturesFlow__c ) {
                      LAT_ContractsCalculations.updateProcessStatus(trigger.new);
                  }
                }

                // Extend Contract
                if (ct.Status__c == 'Ativo' && ct.ProcessStatus__c == 'Contrato Prorrogado' && trigger.oldMap.get(ct.id).ProcessStatus__c != 'Contrato Prorrogado') {
                    // If mobile change the status to Prorrogado, we must set some values and don't recaculate values or Roi
                    ct.OriginalEndDate__c = ct.EndDate__c;
                    ct.OriginalContractTerms__c = ct.ContractTerms__c;
                    ct.EndDate__c = ct.EndDate__c.addMonths(12);
                }
            }

            List<String> contractIds = new List<String>();

            Map<Id, User> idUserMap =  new Map<Id,User>([SELECT Gerente_de_area__c,Gerente_regional__c,ManagerId FROM User where Id in: userIds]);
            for ( Lat_Contract2__c ct : trigger.new ) {
                if(ct.OwnerId != trigger.oldMap.get(ct.id).OwnerId) {
                    User owner = idUserMap.get(ct.ownerId);
                    ct.GeneralManager__c = owner.Gerente_de_area__c;
                    ct.Manager__c = owner.ManagerId;
                    ct.RegionalManager__c = owner.Gerente_regional__c;
                }

                if (ct.Status__c == 'Em Aprovação' && trigger.oldMap.get(ct.id).Status__c != 'Em Aprovação') {
                    if(idUserMap.containsKey(ct.ownerId)){
                        User owner = idUserMap.get(ct.ownerId);
                        ct.GeneralManager__c = owner.Gerente_de_area__c;
                        ct.Manager__c = owner.ManagerId;
                        ct.RegionalManager__c = owner.Gerente_regional__c;
                    }


                    contractIds.add(ct.Id);

                    // Run approval process
                    LAT_ContractDAHandlerInterface.runApprovalProcess(String.valueOf(ct.Id));
                }
            }
        }
       
    }
 */
}