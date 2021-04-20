global class LAT_PromotionalActionHandler {

    public LAT_PromotionalActionHandler() {}

    @InvocableMethod
    public static void initAction(List<String> ids) {
      updatePromotionalActionFields(ids);
      //closePromotionalActionTasks(ids);
      //createPromotionalActionTasks(ids);
    }


    /*
    * setSegmentation
    * Sets the Segmentation Lookup according to the selected Account.
    */
    public static void setSegmentation(List<LAT_AccountInAction__c> triggerNew) {

        Set<Id> accIds =  new Set<Id>();
        for (LAT_AccountInAction__c aia : triggerNew){
            accIds.add(aia.LAT_Account__c);
        }

        List<LAT_BR_ClientChannelSegmentation2Result__c> segms = [SELECT Id, Account__c FROM LAT_BR_ClientChannelSegmentation2Result__c WHERE Account__c IN :accIds];
        Map<Id, LAT_BR_ClientChannelSegmentation2Result__c> mapSegms = new Map<Id, LAT_BR_ClientChannelSegmentation2Result__c>();
        for(LAT_BR_ClientChannelSegmentation2Result__c seg : segms) {
            mapSegms.put(seg.Account__c, seg);
        }

        for(LAT_AccountInAction__c aia : triggerNew) {
            if(mapSegms.get(aia.LAT_Account__c) != null) {
                aia.LAT_Segmentation__c = mapSegms.get(aia.LAT_Account__c).Id;
            }
        }


    }

    /*
    * assingMechanic
    * If the field is empty, we must set the value with the default Mechanic
    */
    public static void assingMechanic(List<LAT_AccountInAction__c> triggerNew) {

        Set<Id> findDefault =  new Set<Id>();
        List<LAT_Mecanica__c> mech = new List<LAT_Mecanica__c>();

        for (LAT_AccountInAction__c cbr: triggerNew) {
            if(cbr.mechanic__c == null) {
                findDefault.add(cbr.LAT_PromotionalAction__c);
            }
        }
        if(!findDefault.isEmpty()){
            mech = [Select Id, LAT_PromotionalAction__c, LAT_Default__c from LAT_Mecanica__c where LAT_PromotionalAction__c IN :findDefault and LAT_Default__c=true ] ;
        }
        for (LAT_AccountInAction__c cbr: triggerNew) {
            for (LAT_Mecanica__c mecObj: mech) {
                if(mecObj.LAT_PromotionalAction__c ==  cbr.LAT_PromotionalAction__c &&  cbr.mechanic__c == null) {
                    cbr.mechanic__c = mecObj.Id;
                }
            }
        }
    }

    /*
    * setApproveByClient
    * By default on the insert we must set to true the field setApproveByClient
    */
    public static void setApproveByClient(List<LAT_AccountInAction__c> triggerNew) {
        for (LAT_AccountInAction__c cbr: triggerNew) {
            cbr.LAT_ApprovedByClient__c = true;
        }
    }


    /*
    * generate Tasks
    * When the AP is Approved we must generate tasks for each client
    */
    // public static void generateClientTasks(List<LAT_AccountInAction__c> triggerNew,  Map<id, LAT_ClientByRegion__c> oldMap) {
    //     for (LAT_AccountInAction__c cbr: triggerNew) {
    //         if (cbr.LAT_status__c == 'Ação aprovada' && oldMap.get(cbr.id).LAT_status__c != 'Ação aprovada') {
    //             LAT_ClientByRegionHandler.SendToApproval(cbr.Id);
    //         }
    //     }
    // }

    /*
    * generateTaskPromotionalActionInit
    *
    */
    public static void generateTaskPromotionalActionInit(List<LAT_PromotionalAction__c> triggerNew, Map<id, LAT_PromotionalAction__c> oldMap) {


        for (LAT_PromotionalAction__c cbr: triggerNew) {
            if (cbr.LAT_status__c == 'Ação iniciada' && oldMap.get(cbr.id).LAT_status__c != 'Ação iniciada') {
                generateKPIsAndBrandsForClients(cbr.Id);
            }
        }
    }

    /*
    * generateTaskForNewClients
    * Used on "Accion Aprovada" layout by a button on top
    * @param apID = Promotional Action Id
    */
    Webservice static String generateTaskForNewClients(String apID) {
        generateKPIsAndBrandsForClients(apID);
        return 'Tasks created successfully';
    }

    /*
    * generateTaskPromotionalActionInit
    * For each client we must generate a KPI and a Brand
    * @param apID = Promotional Action Id
    */
    private static void generateKPIsAndBrandsForClients(Id apID) {

        List<LAT_AccountInAction__c> clients = [SELECT Id, (SELECT Id FROM LAT_KPIClients__r), LAT_Account__r.ownerId, LAT_Account__r.recordTypeId, LAT_Account__r.recordType.Name   FROM LAT_AccountInAction__c WHERE LAT_PromotionalAction__c =: apID];
        Integer daysToDue = LAT_PromotionalActionHandler.getSLANumberOfDays('AP_SLA_IMPLEMENTEDACTION');

        SYSTEM.debug('============\n  daysToDue: '+daysToDue+' \n ===========');

        // we must generate Kpi and brands for each clients based on AP related lists
        if(!clients.isEmpty()) {
            SYSTEM.debug('============\n  clients is not Empty: '+clients+' \n ===========');
            // KPIS
            List<LAT_ActionKPI__c> kpis = [SELECT Id, LAT_PromotionalAction__c, LAT_KPI__c, LAT_KPI__r.Name, LAT_KPI__r.LAT_KPI_OffTrade__c, LAT_KPI__r.LAT_KPI_OnTrade__c,  Name FROM LAT_ActionKPI__c WHERE LAT_PromotionalAction__c =: apID ];

            // BRANDS
            List<LAT_PromotionalActionKeyBrands__c> brands = [SELECT Id, LAT_KeyBrand__c, LAT_BrandName__c,  Promotional_Action__c FROM LAT_PromotionalActionKeyBrands__c WHERE Promotional_Action__c =: apID ];

            // ATTACHMENT
            //List<Attachment> attachments = [Select id,parentId,name, body from Attachment where parentId =: apID];

            Set<Id> ownersId = new Set<Id>();
            for(LAT_AccountInAction__c cl : clients) {
                ownersId.add(cl.LAT_Account__r.ownerId);
            }
            
            Map<Id, Task> clientTaskMaps = new Map<Id,Task>();

            String taskRecordtypeId = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction') ;

            List<Task> tasks = [SELECT id, whatId FROM task WHERE whatId IN :clients AND OwnerId IN :ownersId AND Subject = 'Ação Implementada?' AND RecordTypeID = :taskRecordtypeId AND Status = 'Iniciada'];
            SYSTEM.debug('============\n  Task ya existentes encontradas: '+tasks+' \n ===========');
            for (Task t :tasks) {
                clientTaskMaps.put(t.whatId, t);
            }

            // Insert KPIs
            //List<LAT_ClientKPI__c> clientKPIToInsert = new List<LAT_ClientKPI__c>();
            List<LAT_APBrandClient__c> brandToInsert = new List<LAT_APBrandClient__c>();
            List<taskCLientsWrapper> toInsert = new List<taskCLientsWrapper>();

            for(LAT_AccountInAction__c cl : clients) {
                SYSTEM.debug('============\n  entramos en el LAT_AccountInAction__c: '+cl+' \n ===========');
                if (!clientTaskMaps.containsKey(cl.id)) {
                    SYSTEM.debug('%%%%%%%% No habían tareas, por lo que se van a crear.');
                    // New Validation: We must create the KPI's, brand, and task only if this doesn't exists
                    if(cl.LAT_KPIClients__r.size() == 0) {
                        String recordType = '';

                        if(cl.LAT_Account__r.recordTypeId != null) {
                            recordType = cl.LAT_Account__r.recordType.Name;
                        }

                        taskCLientsWrapper wrapper = new taskCLientsWrapper();
                        Task task = LAT_ProcessesTaks.createTask(cl.id, cl.LAT_Account__r.ownerId, 'Ação Implementada?',
                                 '', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), daysToDue, 'AP-Ação Implementada');
                        task.LAT_AccountInAction__c = cl.Id;
                        wrapper.parent = task;
                        wrapper.childs = new List<LAT_ClientKPI__c>();
                        toInsert.add(wrapper);
                        if(!kpis.isEmpty()) {

                            for(LAT_ActionKPI__c kp : kpis) {

                                LAT_ClientKPI__c clientKPI = new LAT_ClientKPI__c();
                                clientKPI.LAT_AccountInAction__c = cl.Id;
                                clientKPI.Name = kp.LAT_KPI__r.Name;
                                clientKPI.LAT_Quantity__c = 0 ;
                                clientKPI.LAT_ActionKPI__c = kp.Id ;
                                //clientKPI.LAT_Task__c =  task.Id;//taskId;
                                clientKPI.LAT_TaskName__c = task.subject;
                                
                                if((recordType == 'On Trade' && kp.LAT_KPI__r.LAT_KPI_OnTrade__c) || (recordType == 'Off Trade' && kp.LAT_KPI__r.LAT_KPI_OffTrade__c) ) {
                                    wrapper.childs.add(clientKPI);
                                    SYSTEM.debug('%%%%%%%% Se agregan LAT_ClientKPI__c');
                                }
                            }
                        }

                        if(!brands.isEmpty()) {

                            for(LAT_PromotionalActionKeyBrands__c brand : brands) {
                                LAT_APBrandClient__c brandKPI = new LAT_APBrandClient__c();
                                brandKPI.LAT_AccountInAction__c = cl.Id;
                                brandKPI.LAT_ActionBrand__c = brand.Id ;
                                brandKPI.Name = brand.LAT_BrandName__c;
                                brandToInsert.add(brandKPI);
                            }
                        }
                    }
                }

            }

            if(!brandToInsert.isEmpty()){
                SYSTEM.debug('%%%%%%%% Se insertan brandToInsert');
                insert brandToInsert;
            }
            
            if(!toInsert.isEmpty()){
                List<Task> taskToInsert = new List<Task>();
                for (taskCLientsWrapper w : toInsert) {
                    if (w.parent != null) {
                        taskToInsert.add(w.parent);
                    }
                }
                if (taskToInsert.size() > 0) {
                    SYSTEM.debug('%%%%%%%% Se insertan taskToInsert');
                    insert taskToInsert;
                }
                
                List<LAT_ClientKPI__c> clientKPIToInsert = new List<LAT_ClientKPI__c>();
                for (taskCLientsWrapper w : toInsert) {
                    if (w.parent != null) {
                        for (LAT_ClientKPI__c h : w.childs) {
                            h.LAT_Task__c =  w.parent.Id;
                            clientKPIToInsert.add(h);
                        }
                    }
                }    
                if (clientKPIToInsert.size() > 0) {
                    SYSTEM.debug('%%%%%%%% Se insertan clientKPIToInsert');
                    insert clientKPIToInsert;
                }
                
            }



            // Insert KPIs

        }
    }
    //Wrapper class for storeing the Task and it's related Client KPI related childs. To make bulk DML inserts at the end of the method.
    private class taskCLientsWrapper {
        public Task parent;
        public List<LAT_ClientKPI__c> childs;
    }

    /*
    * generateAttachmentsToTask
    * clone the promotional actions files and save it into the task
    */
    // public static void generateAttachmentsToTask(Task task, List<Attachment> attachments) {
    //
    //  if(!attachments.isEmpty()){
    //      List<Attachment> newAttachments = new List<Attachment>();
    //      for(Attachment att : attachments){
    //          Attachment newFile = att.clone();
    //          newFile.ParentId = task.Id;
    //          newFile.OwnerId = task.OwnerId;
    //          newAttachments.add(newFile);
    //      }
    //      if(!newAttachments.isEmpty()){
    //          insert newAttachments;
    //      }
    //
    //  }
    // }

    /*
    * checkAdheringClients
    */
    public static void checkAdheringClients(List<LAT_AccountInAction__c> triggerNew) {

        Set<Id> clientRegionIds =  new Set<Id>();
        Set<Id> apIds = new Set<Id>();
        Set<Id> accountIds =  new Set<Id>();
        Set<Id> segmIds =  new Set<Id>();

        for (LAT_AccountInAction__c aia: triggerNew) {
            apIds.add(aia.LAT_PromotionalAction__c);
            accountIds.add(aia.LAT_Account__c);
            segmIds.add(aia.LAT_Segmentation__c);
        }

        System.debug('---- apIds  ----> ' + apIds);
        //List<LAT_ClientByRegion__c> cbr = [Select Id from LAT_ClientByRegion__c where Id IN :clientRegionIds];
        Map<Id, LAT_ClientByRegion__c> cbr = new Map<Id, LAT_ClientByRegion__c>([Select Id, LAT_Profile__r.Name, RecordTypeId, Promotional_Action__c, LAT_UF__c,LAT_Channel__c, LAT_Regional__c, LAT_Sub_Channel__c,
                                                                                    LAT_Profile__c, LAT_Segment__c,LAT_UDCSubChannel__c, UDC_Channel__c,
                                                                                    LAT_RegionalClientOnPremise__c, RecordType.developerName from LAT_ClientByRegion__c where Promotional_Action__c IN :apIds]);
        Map<Id, Account> accs = new Map<Id, Account>([Select Id, Segmentation_Type_on_trade__c  , Revenue_UF__c, Channel__c, Regional__c, Sub_Channel_Rating__c, Sub_Channel_Rating__r.Name, Sub_Channel__c, Rating_segmentation_targert_market__c, LAT_BR_RegionalClientOnPremise__c from Account where Id IN :accountIds]);
        Map<Id, LAT_BR_ClientChannelSegmentation2Result__c> segms = new Map<Id, LAT_BR_ClientChannelSegmentation2Result__c>(
                                        [SELECT Id, Obtained_Channel_Udc__c, Obtained_SubChannel_Udc__c, Obtained_Segment_Udc__c, Perfil__c FROM LAT_BR_ClientChannelSegmentation2Result__c WHERE Id IN :segmIds]);     
        

        System.debug('---- xxxx  ----> ');

        for (LAT_AccountInAction__c aia: triggerNew) {
            Boolean retCheck = false;
            Account acc = accs.get(aia.LAT_Account__c);
            LAT_BR_ClientChannelSegmentation2Result__c segm = segms.get(aia.LAT_Segmentation__c);
            Set<Id> matchClientByRegionIds = new Set<Id>();

            for(Id cbrId : cbr.keyset()){
                LAT_ClientByRegion__c lcbr = cbr.get(cbrId);

                System.debug('---- lcbr  ----> '+lcbr);
                System.debug('---- acc  ----> '+acc);
                System.debug('---- segm  ----> '+segm);
                if(lcbr!=null &&  acc!=null && segm!=null && lcbr.RecordTypeId != null) {
                    if(
                        (lcbr.LAT_UF__c != null && acc.Revenue_UF__c != null) && (lcbr.LAT_UF__c !=  acc.Revenue_UF__c) ||
                        (lcbr.UDC_Channel__c != null && segm.Obtained_Channel_Udc__c != null) && (lcbr.UDC_Channel__c != segm.Obtained_Channel_Udc__c) ||
                        (lcbr.LAT_UDCSubChannel__c != null && segm.Obtained_SubChannel_Udc__c != null) && (lcbr.LAT_UDCSubChannel__c != segm.Obtained_SubChannel_Udc__c) ||
                        (lcbr.LAT_Segment__c != null && segm.Obtained_Segment_Udc__c != null) && (lcbr.LAT_Segment__c !=  segm.Obtained_Segment_Udc__c) ||
                        (lcbr.LAT_Profile__c != null && segm.Perfil__c != null) && (lcbr.LAT_Profile__r.Name !=  segm.Perfil__c)||
                        (lcbr.LAT_RegionalClientOnPremise__c != null && acc.LAT_BR_RegionalClientOnPremise__c != null) && (lcbr.LAT_RegionalClientOnPremise__c !=  acc.LAT_BR_RegionalClientOnPremise__c) ||
                        (lcbr.LAT_Regional__c != null && acc.Regional__c != null) && (lcbr.LAT_Regional__c !=  acc.Regional__c)


                    ){
                        system.debug('##################### NO MATCH' + lcbr.id);
                    } else {
                        system.debug('#####################  MATCH' + lcbr.id);
                        matchClientByRegionIds.add(lcbr.id);
                    }
                    
                }


            }
            system.debug('>>>>>>' + matchClientByRegionIds);

            aia.ClientNotAdhering__c = (matchClientByRegionIds.size()==0);

        }

    }

    // This method handles task creation for promotional actions
    public static void createPromotionalActionTasks(List<String> ids) {
        /*
      if(ids != null && ids.size() > 0){
          String promotionId = ids[0];

          Map<id, LAT_AccountInAction__c> clientes = new  Map<id, LAT_AccountInAction__c>([Select id, Name, LAT_Execute__c, LAT_CollectData__c, LAT_RetireMaterials__c, LAT_PromotionalAction__r.LAT_endDate__c,LAT_Account__r.ownerId,LAT_PromotionalAction__r.LAT_Status__c, LAT_PromotionalAction__c, LAT_Status__c from LAT_AccountInAction__c where LAT_PromotionalAction__c =: promotionId]);
          Map<id, LAT_PromotionalAction__c> promotionalActions = new Map<id, LAT_PromotionalAction__c>([SELECT id, Name, RecordTypeId, RecordType.DeveloperName, OwnerId, Owner.Name, LAT_BusinessCycle__c, LAT_StartDate__c, LAT_EndDate__c, LAT_Description__c, LAT_Booster__c, LAT_Brand__c, LAT_CancelationReason__c, LAT_PromotionalPack__c, LAT_Quantidade_de_Clientes__c, LAT_status__c, (SELECT id,Description__c,Product__c,Promotional_Action__c FROM LAT_DataCollect__r) FROM LAT_PromotionalAction__c WHERE id =: promotionId]);
          List<LAT_AccountInActionCollect__c> aiacList = new List<LAT_AccountInActionCollect__c>();

          List<Task> tasks = new List<Task>();
          List<Task> coletaTasks = new List<Task>();

          List<Attachment> originalAttachments = new List<Attachment>();
          List<Attachment> newAttachments = new List<Attachment>();

          for(Attachment att : [Select id,parentId,name, body from Attachment where parentId =: promotionId]){
            originalAttachments.add(att);
          }

          if(clientes.values() != null && clientes.values().size() > 0){
            LAT_PromotionalAction__c pa = promotionalActions.get(promotionId);

            for(LAT_AccountInAction__c cli : clientes.values()){
              if (cli.LAT_PromotionalAction__r.LAT_Status__c == 'Ação iniciada') {
                if (cli.LAT_Status__c == 'Cliente Validado') {
                  tasks.addAll(manageInitialTasks(cli));
                  //cli.LAT_Status__c = 'Ação iniciada';
                }
              } else if (cli.LAT_PromotionalAction__r.LAT_Status__c == 'Ação Finalizada') {
                Integer dueDaysColetaAIAC = getSLANumberOfDays('AP_SLA_COLLECTS');
                if(cli.LAT_Execute__c){
                  LAT_AccountInActionCollect__c aiac = new LAT_AccountInActionCollect__c();
                  aiac.Name = 'Coletar Dados cliente: ' + cli.Name;
                  aiac.AccountInAction__c = cli.id;
                  aiac.LAT_DueDate__c = LAT_ProcessesTaks.AddBusinessDays(Date.today(),dueDaysColetaAIAC);
                  aiacList.add(aiac);
                }
              } else if (cli.LAT_PromotionalAction__r.LAT_Status__c == 'Ação cancelada' && cli.LAT_Status__c == 'Ação aprovada pelo cliente') {
                Integer dueDaysCanceltationTask = getSLANumberOfDays('AP_SLA_CANCELATION');
                Task task = LAT_ProcessesTaks.createTask(cli.id, cli.LAT_Account__r.ownerId, 'Ação Promocional Cancelada',
                         'Formalizar o cancelamento da ação junto ao cliente', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), dueDaysCanceltationTask, 'AP-Formalizar Cancelamento');
                task.LAT_PromotionalAction__c = cli.LAT_PromotionalAction__c;
                task.LAT_AccountInAction__c = cli.id;
                tasks.add(task);
              }
            }
            Database.DMLOptions dmlOptions = new Database.DMLOptions();
            dmlOptions.EmailHeader.TriggerUserEmail = TRUE;

            Database.Insert(
               tasks,
               dmlOptions
            );

            if (!aiacList.isEmpty()) {
              Database.Insert(
                aiacList,
                dmlOptions
              );

              // Create Collects if the action is finalized and colection is requested
              List<LAT_AccountInActionCollectLine__c> aialList = new List<LAT_AccountInActionCollectLine__c>();
              for (LAT_AccountInActionCollect__c aiac: aiacList) {
                if (clientes.get(aiac.AccountInAction__c) != null) {
                  Integer dueDaysColetaTask = getSLANumberOfDays('AP_SLA_COLLECTS');
                  Task task = LAT_ProcessesTaks.createTask(aiac.id, clientes.get(aiac.AccountInAction__c).LAT_Account__r.ownerId, 'Coletar Dados',
                         'Coletar Dados', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), dueDaysColetaTask, 'AP-Coletar dados no cliente');
                  task.LAT_PromotionalAction__c = promotionId;
                  task.LAT_AccountInAction__c = aiac.AccountInAction__c;
                  coletaTasks.add(task);
                }

                for (LAT_DataCollect__c dc: promotionalActions.get(promotionId).LAT_DataCollect__r) {
                  LAT_AccountInActionCollectLine__c aiacl = new LAT_AccountInActionCollectLine__c();
                  aiacl.LAT_AccountInActionCollect__c = aiac.id;
                  aiacl.DataCollect__c = dc.id;
                  aialList.add(aiacl);
                }
              }

              Database.Insert(
                coletaTasks,
                dmlOptions
              );

              Database.Insert(
                aialList,
                dmlOptions
              );
            }

            try {
              update clientes.values();
            } catch (Exception e) {
              LAT_DebugUtil.addException('LAT_PromotionalActionHandler-createPromotionalActionTasks', e, '-1');
            }
         }
      }
      */
    }

    // Get SLA from LAT_GeneralConfig
    public static Integer getSLANumberOfDays(string configName) {
      Integer days = 15;
      String[] dueDays = LAT_GeneralConfigDao.getValueAsStringArray(configName, ' ');
      if(dueDays != null && dueDays.size()>0)days = Integer.valueOf(dueDays[0]);

      return days;
    }

    // Used to create the initial task of the actions (Offer action to client and Evidence)
    public static List<Task> manageInitialTasks( LAT_AccountInAction__c cli) {
      Integer offerDueDays = getSLANumberOfDays('AP_SLA_OFFER_ACTION');

      List<Task> tasks = new List<Task>();
      Task taskPresentation = LAT_ProcessesTaks.createTask(cli.id, cli.LAT_Account__r.ownerId, 'Apresentar Ação ao Cliente',
                              'Apresentar Ação ao Cliente', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), offerDueDays,
                              'AP-Apresentar Proposta ao Cliente');
      taskPresentation.LAT_PromotionalAction__c = cli.LAT_PromotionalAction__c;
      taskPresentation.LAT_AccountInAction__c = cli.id;
      taskPresentation.ActivityDate = cli.LAT_PromotionalAction__r.LAT_endDate__c;
      tasks.add(taskPresentation);

      return tasks;
   }

   public static void runClientesTriggers(){
      if(trigger.isAfter){
         if(trigger.isUpdate){
            reApprovedClient();
            substituteClientCreateTask(trigger.new, (Map<id, LAT_AccountInAction__c>)trigger.oldMap);
            createTaskEvidencia(trigger.new, (Map<id, LAT_AccountInAction__c>)trigger.oldMap);
            CreateAIACKPIs(trigger.new, (Map<id, LAT_AccountInAction__c>)trigger.oldMap);
         }else if (trigger.isInsert){
            shareRecords();
            substituteClient(trigger.new);
         }
         updateRegionalClient();
         LAT_ClientByRegionHandler.calculateAddedByRegion(trigger.new);
      }else if(trigger.isBefore){
         if(trigger.isUpdate){
            updateClienteFoco();
         }
      }
   }

  public static void CreateAIACKPIs(List<LAT_AccountInAction__c> triggerNew, Map<id, LAT_AccountInAction__c> oldMap) {
    List<String> ids = new List<String>();
    List<String> paIds = new List<String>();
    for (LAT_AccountInAction__c cli: triggerNew) {
      if (cli.LAT_Status__c == 'Ação aprovada pelo cliente'
          && oldMap.get(cli.id) != null
          && oldMap.get(cli.id).LAT_Status__c != 'Ação aprovada pelo cliente' ) {
          ids.add(cli.id);
          paIds.add(cli.LAT_PromotionalAction__c);
      }
    }
    if (!ids.isEmpty()) {
      List<String> kpiIds = new List<String>();
      for (LAT_ActionKPI__c kpi: [SELECT id FROM LAT_ActionKPI__c WHERE LAT_PromotionalAction__c =: paIds ORDER BY LAT_KPI__r.Name]) {
        kpiIds.add(kpi.id);
      }
      if (!kpiIds.isEmpty()) {
        LAT_CreateAPKPIBatch cab = new LAT_CreateAPKPIBatch(ids, kpiIds);
        Database.executeBatch(cab, 10);
      }
    }

  }

  public static void CreateAKKPIs(List<LAT_ActionKPI__c> triggerNew) {
    List<String> ids = new List<String>();
    List<String> paIds = new List<String>();
    List<String> aiacIds = new List<String>();
    for (LAT_ActionKPI__c akpi: triggerNew) {
      paIds.add(akpi.LAT_PromotionalAction__c);
      ids.add(akpi.id);
    }
    for (LAT_AccountInAction__c cli: [SELECT id, LAT_Status__c FROM LAT_AccountInAction__c WHERE LAT_PromotionalAction__c IN: paIds]) {
      if (cli.LAT_Status__c == 'Ação aprovada pelo cliente') {
          aiacIds.add(cli.id);
      }
    }
    if (!ids.isEmpty() && !aiacIds.isEmpty()) {
      LAT_CreateAPKPIBatch cab = new LAT_CreateAPKPIBatch(aiacIds, ids);
      Database.executeBatch(new LAT_CreateAPKPIBatch(aiacIds, ids), 10);
    }

  }

   public static Boolean isRuningAgain = false;
   public static void updateRegionalClient() {
      if (!isRuningAgain) {
        isRuningAgain = true;
        Set<String> paSet = new Set<String>();
        Map<String, List<LAT_AccountInAction__c>> regionalOnToAccountInAction = new Map<String, List<LAT_AccountInAction__c>>();
        Map<String, List<LAT_AccountInAction__c>> regionalOffToAccountInAction = new Map<String, List<LAT_AccountInAction__c>>();
        for (LAT_AccountInAction__c acc: [SELECT id, LAT_Account__c, LAT_Account__r.LAT_BR_RegionalClientOnPremise__c,
                                                 LAT_ClientByRegion__c, LAT_PromotionalAction__c, LAT_Account__r.Regional__c,
                                                 LAT_Account__r.RecordType.DeveloperName
                                            FROM LAT_AccountInAction__c WHERE id IN: trigger.new]) {
          if (acc.LAT_ClientByRegion__c == null) {
            if (acc.LAT_Account__r.RecordType.DeveloperName == 'On_Trade') {
              if (regionalOnToAccountInAction.get(acc.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c) != null) {
                regionalOnToAccountInAction.get(acc.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c).add(acc);
              } else {
                regionalOnToAccountInAction.put(acc.LAT_Account__r.LAT_BR_RegionalClientOnPremise__c, new List<LAT_AccountInAction__c>{acc});
              }
            } else if (acc.LAT_Account__r.RecordType.DeveloperName == 'Off_Trade') {
              if (regionalOffToAccountInAction.get(acc.LAT_Account__r.Regional__c) != null) {
                regionalOffToAccountInAction.get(acc.LAT_Account__r.Regional__c).add(acc);
              } else {
                regionalOffToAccountInAction.put(acc.LAT_Account__r.Regional__c, new List<LAT_AccountInAction__c>{acc});
              }
            }
            paSet.add(acc.LAT_PromotionalAction__c);
          }
        }

        List<LAT_AccountInAction__c> aiaList = new List<LAT_AccountInAction__c>();
        for (LAT_ClientByRegion__c cbr: [SELECT id, LAT_Regional__c, LAT_RegionalClientOnPremise__c FROM LAT_ClientByRegion__c
                                          WHERE Promotional_Action__c IN: paSet]) {
          if (regionalOnToAccountInAction.get(cbr.LAT_RegionalClientOnPremise__c) != null) {
            for (LAT_AccountInAction__c aia: regionalOnToAccountInAction.get(cbr.LAT_RegionalClientOnPremise__c)) {
               aia.LAT_ClientByRegion__c = cbr.id;
               aiaList.add(aia);
            }
            regionalOnToAccountInAction.remove(cbr.LAT_RegionalClientOnPremise__c);
          } else if (regionalOffToAccountInAction.get(cbr.LAT_Regional__c) != null) {
            for (LAT_AccountInAction__c aia: regionalOffToAccountInAction.get(cbr.LAT_Regional__c)) {
               aia.LAT_ClientByRegion__c = cbr.id;
               aiaList.add(aia);
            }
            regionalOffToAccountInAction.remove(cbr.LAT_Regional__c);
          }
        }

        for (String key: regionalOnToAccountInAction.keyset()) {
          for (LAT_AccountInAction__c aia: regionalOnToAccountInAction.get(key)) {
             aia.LAT_Status__c = 'Cliente não previsto';
             aiaList.add(aia);
          }
        }

        for (String key: regionalOffToAccountInAction.keyset()) {
          for (LAT_AccountInAction__c aia: regionalOffToAccountInAction.get(key)) {
             aia.LAT_Status__c = 'Cliente não previsto';
             aiaList.add(aia);
          }
        }

        update aiaList;
      }
   }

   public static void updateClienteFoco(){
      for(LAT_AccountInAction__c foco : (List<LAT_AccountInAction__c>)trigger.new){
         if(foco.LAT_Status__c == 'Ação aprovada pelo cliente') foco.LAT_Execute__c = true;
         //if(!foco.LAT_ClientAccepted__c)foco.LAT_Execute__c = false;
      }
   }

   public static void reApprovedClient(){
       // Removed by MP
    //   List<String> Ids = new List<String>();
    //   List<task> tasks = new List<task>();
      //
    //   for(integer i = 0; i < trigger.new.size(); i++){
    //      if(((LAT_AccountInAction__c)trigger.new[i]).LAT_Status__c == 'Ação Iniciada' && ((LAT_AccountInAction__c)trigger.old[i]).LAT_Status__c == 'Ação não aprovada pelo cliente'){
    //         ids.add(trigger.new[i].id);
    //      }
    //   }
      //
    //   for(LAT_AccountInAction__c acc : [Select id,LAT_PromotionalAction__r.LAT_endDate__c,LAT_PromotionalAction__c ,LAT_Account__r.owner.managerId,LAT_Account__r.owner.Gerente_de_area__c,LAT_Account__r.owner.Gerente_regional__c from LAT_AccountInAction__c where id in: ids]){
    //      Task task = createTask(acc.id, acc.LAT_Account__r.ownerId, 'Ofrecer Ação ao cliente', 'Ação Promocional','Iniciada' );
    //      task.ActivityDate = acc.LAT_PromotionalAction__r.LAT_endDate__c;
    //      task.IsReminderSet = true;
    //      task.ReminderDateTime = System.now();
    //      task.recordTypeId = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction');
    //      task.ReminderDateTime = task.ReminderDateTime.addDays(Integer.valueOf(Date.today().daysBetween(task.ActivityDate)* 0.8));
    //      tasks.add(task);
    //   }
      //
    //   if(tasks.size() >0)insert tasks;
   }



   public static void shareRecords(){

      system.debug('------>shareRecords');
      List<String> Ids = new List<String>();
      List<String> paIds = new List<String>();
      List<LAT_PromotionalAction__Share> toUpdate = new List<LAT_PromotionalAction__Share>();

      for(LAT_AccountInAction__c acc : (List<LAT_AccountInAction__c>)trigger.new){
         ids.add(acc.id);
         paIds.add(acc.LAT_PromotionalAction__c);
      }
      system.debug('------>' + paIds);
      Map<String, LAT_PromotionalAction__Share> userToPas = new Map<String, LAT_PromotionalAction__Share>();
      for (LAT_PromotionalAction__Share pas: [select id, ParentId, UserOrGroupId from LAT_PromotionalAction__Share where UserOrGroupId != null and ParentId IN: paIds]){
         userToPas.put(pas.UserOrGroupId, pas);
         system.debug('------>' + pas.UserOrGroupId);
      }

      for(LAT_AccountInAction__c acc : [Select id,LAT_PromotionalAction__c ,LAT_Account__r.owner.managerId,LAT_Account__r.owner.Gerente_de_area__c,LAT_Account__r.owner.Gerente_regional__c, LAT_Account__r.ownerId from LAT_AccountInAction__c where id in: ids]){

         LAT_PromotionalAction__Share jobShr  = new LAT_PromotionalAction__Share();
         if (acc.LAT_Account__r.owner.managerId != null
             && userToPas.get(acc.LAT_Account__r.owner.managerId) == null) {
            jobShr.ParentId = acc.LAT_PromotionalAction__c;
            jobShr.UserOrGroupId = acc.LAT_Account__r.owner.managerId;
            jobShr.AccessLevel = 'Edit';
            toUpdate.add(jobShr);
         }

         if(acc.LAT_Account__r.owner.Gerente_de_area__c != null
            && userToPas.get(acc.LAT_Account__r.owner.Gerente_de_area__c) == null){
            jobShr  = new LAT_PromotionalAction__Share();
            jobShr.ParentId = acc.LAT_PromotionalAction__c;
            jobShr.UserOrGroupId = acc.LAT_Account__r.owner.Gerente_de_area__c;
            jobShr.AccessLevel = 'Edit';
            toUpdate.add(jobShr);
         }

         if(acc.LAT_Account__r.owner.Gerente_regional__c != null
            && userToPas.get(acc.LAT_Account__r.owner.Gerente_regional__c) == null){
            jobShr  = new LAT_PromotionalAction__Share();
            jobShr.ParentId = acc.LAT_PromotionalAction__c;
            jobShr.UserOrGroupId = acc.LAT_Account__r.owner.Gerente_regional__c;
            jobShr.AccessLevel = 'Edit';
            toUpdate.add(jobShr);
         }

         if ( acc.LAT_Account__r.ownerId != null
             && userToPas.get(acc.LAT_Account__r.ownerId) == null) {
            jobShr  = new LAT_PromotionalAction__Share();
            jobShr.ParentId = acc.LAT_PromotionalAction__c;
            jobShr.UserOrGroupId = acc.LAT_Account__r.ownerId;
            jobShr.AccessLevel = 'Edit';
            toUpdate.add(jobShr);
         }

      }

      if (!toUpdate.isEmpty()) {
        insert toUpdate;
      }
   }


   public static void updatePromotionalActionFields(List<String> ids) {
      if(ids != null && ids.size() > 0){
         List<LAT_PromotionalAction__c> paList = [SELECT id, name,LAT_Status__c,owner.email, (SELECT id,LAT_Account__r.Owner.Email FROM LAT_AccountInAction__r WHERE (LAT_Status__c = 'Ação aprovada pelo cliente' OR LAT_Status__c = 'Ação Iniciada')) FROM LAT_PromotionalAction__c WHERE id =: ids];
         List<LAT_PromotionalAction__c> toUpdate = new List<LAT_PromotionalAction__c>();
         Set<String> ownersAccountMails = new Set<String>();
         List<LAT_AccountInAction__c> hiToUp = new List<LAT_AccountInAction__c>();

         for (LAT_PromotionalAction__c pa: paList) {
            if (pa.LAT_Status__c == 'Ação aprovada'){
               pa.LAT_Status__c = 'Ação iniciada';
               pa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_PromotionalAction__c'+'Iniciada');
               toUpdate.add(pa);
            } else if (pa.LAT_Status__c == 'Ação Finalizada') {
               pa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_PromotionalAction__c'+'LAT_Finalizada');
               toUpdate.add(pa);
               ownersAccountMails.add(pa.owner.email);
               for(LAT_AccountInAction__c hi: pa.LAT_AccountInAction__r){
                   hi.LAT_Status__c = 'Ação Finalizada';
                   hiToUp.add(hi);

                   if(!ownersAccountMails.contains(hi.LAT_Account__r.Owner.Email)){
                    if (hi.LAT_Account__r.Owner.Email != null) {
                     ownersAccountMails.add(hi.LAT_Account__r.Owner.Email);
                    }
                   }
               }

            }
         }
         update hiToUp;
         update toUpdate;
      }
   }

   public static Integer getAmmountOfDays() {
      Integer days = 15;
      String[] dueDays = LAT_GeneralConfigDao.getValueAsStringArray('AP_SLA_%', ' ');
      if(dueDays != null && dueDays.size()>0)days = Integer.valueOf(dueDays[0]);
      return days;
   }

   Webservice static String pagarPromotionalActionTasks(String paid) {
        Map<id, LAT_AccountInAction__c> clientes = new  Map<id, LAT_AccountInAction__c>([SELECT id, LAT_PromotionalAction__r.LAT_Status__c,
                                                         LAT_Account__r.ownerId FROM LAT_AccountInAction__c
                                                   WHERE LAT_PromotionalAction__c =: paid AND (LAT_Status__c = 'Ação não aprovada pelo cliente' OR LAT_Status__c = 'Ação Finalizada')]);

         String returnMessage = '';
          // COMMENTED OLD CODE BY MP - TO DO, CONFIRM AND REMOVE
        //  if (!clientes.isEmpty()) {
        //     List<LAT_ActionClientPayment__c> acpList = [SELECT id, LAT_AccountInAction__c, LAT_AccountInAction__r.Name,
        //                                                        LAT_AccountInAction__r.LAT_PromotionalAction__c,
        //                                                        LAT_AccountInAction__r.LAT_Account__r.ownerId, LAT_TaskCreated__c,
        //                                                        (Select id, LAT_ActionClientPayment__c, LAT_Description__c,
        //                                                           LAT_Value__c FROM ActionClientPaymentLines__r)
        //                                                  FROM LAT_ActionClientPayment__c
        //                                                  WHERE LAT_AccountInAction__c IN: clientes.values()];
        //     if (!acpList.isEmpty()) {
        //        List<Task> tasks = new List<Task>();
        //        List<LAT_AccountInAction__c> aiaToUpdate = new List<LAT_AccountInAction__c>();
        //        for (LAT_ActionClientPayment__c acp: acpList) {
        //           if (!acp.LAT_TaskCreated__c) {
        //              Task t = LAT_ProcessesTaks.createTask(acp.id, acp.LAT_AccountInAction__r.LAT_Account__r.ownerId, 'Realizar pagamentos',
        //                                               'Realizar pagamentos', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), getSLANumberOfDays('AP_SLA_PAYMENTS'), 'AP-Realizar Pagamento');
        //              t.LAT_PromotionalAction__c = acp.LAT_AccountInAction__r.LAT_PromotionalAction__c;
        //              t.LAT_AccountInAction__c = acp.LAT_AccountInAction__c;
        //              tasks.add(t);
         //
        //              LAT_AccountInAction__c aia = clientes.get(acp.LAT_AccountInAction__c);
        //              if (aia != null) {
        //                 aia.LAT_Status__c = 'Pagamentos Autorizados';
        //                 aiaToUpdate.add(aia);
        //              }
        //              acp.LAT_TaskCreated__c = true;
        //           }
        //        }
         //
        //        if (!tasks.isEmpty()) {
        //           Database.DMLOptions dmlOptions = new Database.DMLOptions();
        //           dmlOptions.EmailHeader.TriggerUserEmail = TRUE;
         //
        //           Database.Insert(
        //              tasks,
        //              dmlOptions
        //           );
         //
        //           update acpList;
         //
        //           if (!aiaToUpdate.isEmpty()) {
        //              update aiaToUpdate;
        //           }
        //        }
         //
        //        returnMessage += 'Tarefas creadas';
         //
        //     } else {
        //        returnMessage += 'Por favor, faça upload de Pagamentos';
        //     }
        //  }

         return returnMessage;

   }

   Webservice static String pagarClienteActionTasks(String cid) {
         Map<id, LAT_AccountInAction__c> clientes = new  Map<id, LAT_AccountInAction__c>([SELECT id, LAT_PromotionalAction__r.LAT_Status__c,
                                                                                                LAT_Account__r.ownerId FROM LAT_AccountInAction__c
                                                                                          WHERE id =: cid AND LAT_Status__c = 'Ação Finalizada']);

         String returnMessage = '';
         // COMMENTED OLD CODE BY MP - TO DO, CONFIRM AND REMOVE
        //  if (!clientes.isEmpty()) {
        //     List<LAT_ActionClientPayment__c> acpList = [SELECT id, LAT_AccountInAction__c, LAT_AccountInAction__r.Name,
        //                                                        LAT_AccountInAction__r.LAT_PromotionalAction__c,
        //                                                        LAT_AccountInAction__r.LAT_Account__r.ownerId, LAT_TaskCreated__c,
        //                                                        (Select id, LAT_ActionClientPayment__c, LAT_Description__c,
        //                                                           LAT_Value__c FROM ActionClientPaymentLines__r)
        //                                                  FROM LAT_ActionClientPayment__c
        //                                                  WHERE LAT_AccountInAction__c IN: clientes.values()];
        //     if (!acpList.isEmpty()) {
        //        List<Task> tasks = new List<Task>();
        //        List<LAT_AccountInAction__c> aiaToUpdate = new List<LAT_AccountInAction__c>();
        //        for (LAT_ActionClientPayment__c acp: acpList) {
        //           if (!acp.LAT_TaskCreated__c) {
        //              Task t = LAT_ProcessesTaks.createTask(acp.id, acp.LAT_AccountInAction__r.LAT_Account__r.ownerId, 'Realizar pagamentos',
        //                                               'Realizar pagamentos', Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), getAmmountOfDays(), 'AP-Realizar Pagamento');
        //              t.LAT_PromotionalAction__c = acp.LAT_AccountInAction__r.LAT_PromotionalAction__c;
        //              t.LAT_AccountInAction__c = acp.LAT_AccountInAction__c;
        //              tasks.add(t);
         //
        //              acp.LAT_TaskCreated__c = true;
         //
        //              LAT_AccountInAction__c aia = clientes.get(acp.LAT_AccountInAction__c);
        //              if (aia != null) {
        //                 aia.LAT_Status__c = 'Pagamentos Autorizados';
        //                 aiaToUpdate.add(aia);
        //              }                  }
        //        }
         //
        //        if (!tasks.isEmpty()) {
        //           Database.DMLOptions dmlOptions = new Database.DMLOptions();
        //           dmlOptions.EmailHeader.TriggerUserEmail = TRUE;
         //
        //           Database.Insert(
        //              tasks,
        //              dmlOptions
        //           );
         //
        //           update acpList;
         //
        //           if (!aiaToUpdate.isEmpty()) {
        //              update aiaToUpdate;
        //           }
         //
        //        }
         //
        //        returnMessage += 'Tarefas creadas';
         //
        //     } else {
        //        returnMessage += 'Por favor, faça upload de Pagamentos';
        //     }
        //  }

         return returnMessage;

   }

   public static void closePromotionalActionTasks(List<String> ids) {
       /*
      if(ids != null && ids.size() > 0) {
         List<LAT_AccountInAction__c> clientes = [Select id, LAT_PromotionalAction__r.LAT_Status__c, LAT_PromotionalAction__c from LAT_AccountInAction__c where LAT_PromotionalAction__c =: ids AND LAT_PromotionalAction__r.LAT_Status__c = 'Ação cancelada'];
         List<String> toUpdate = new List<String>();

         List<String> toCloseIds = new List<String>();
         for (LAT_AccountInAction__c accAction: clientes) {
            if (accAction.LAT_PromotionalAction__r.LAT_Status__c == 'Ação cancelada') {
               toUpdate.add(accAction.id);
               accAction.LAT_Status__c = 'Ação cancelada pela PRB';
               toCloseIds.add(accAction.id);
            }
         }

         List<Task> tList = [SELECT id, status FROM Task WHERE LAT_AccountInAction__c =: toCloseIds AND recordTypeId =: Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction')];
         for (Task t: tList) {
            t.status = 'Completed';//'Concluído';
         }

         try {
            update tList;
            update clientes;
         } catch (Exception e) {
            LAT_DebugUtil.addException('LAT_PromotionalActionHandler-closePromotionalActionTasks', e, '-1');
         }
      }
      */
   }

   public static Task createTask(String whatId, String ownerId, String subject, String description,String tipo) {
      Task task = new Task();
      task.WhatId = whatId;
      task.OwnerId = ownerId;
      task.Subject = subject;
      task.LAT_Tipo__c = tipo;
      task.status = 'Iniciada';
      task.recordTypeId = Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction');
      task.description = description;
      return task;
   }

   public static void closeTasks(List<Task> tasks) {
      List<String> ids = new List<String>();
      List<LAT_AccountInAction__c> toUpdate = new List<LAT_AccountInAction__c>();
      Map<String,LAT_AccountInAction__c> actionMap = new Map<String,LAT_AccountInAction__c>();

      for(Task t : tasks){
         if(t.status == 'Concluído'){
            system.debug('aaaaa '+t.status );
            ids.add(t.whatId);
         }
      }

      for(LAT_AccountInAction__c t : [Select id,LAT_DataCollected__c, LAT_RemovedMaterials__c from  LAT_AccountInAction__c where id =: ids]){
         actionMap.put(t.id, t);
      }

      for(Task t : tasks){
         if(actionMap.get(t.whatId) != null){
            LAT_AccountInAction__c act = actionMap.get(t.whatId);
            if(t.LAT_Tipo__c == 'Coletar'){
               act.LAT_DataCollected__c = true;
            }else if(t.LAT_Tipo__c == 'Iniciada'){

            }else if(t.LAT_Tipo__c == 'Materiais'){
               act.LAT_RemovedMaterials__c = true;
            }else if(t.LAT_Tipo__c == 'Pagamento'){
               act.LAT_Status__c = 'Ação encerrada no cliente';
            }else if(t.LAT_Tipo__c == 'Cancelada'){
               act.LAT_Status__c =  'Ação cancelada pela PRB';
            }
            toUpdate.add(act);
         }
      }
      update toUpdate;
   }

   Webservice static void notificarManagers(String id) {
      List<LAT_AccountInAction__c> tmpAccs = [Select id,LAT_PromotionalAction__c ,LAT_Account__r.owner.managerId,LAT_Account__r.owner.Gerente_de_area__c,LAT_Account__r.owner.Gerente_regional__c from LAT_AccountInAction__c where LAT_PromotionalAction__c =: id];
      if(tmpAccs != null && tmpAccs.size() > 0){
          List<ConnectApi.BatchInput> feedList = new List<ConnectApi.BatchInput>();
          ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();

          input.subjectId = id;

          ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
          messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

              for(LAT_AccountInAction__c acc : tmpAccs){
                  // Create mention to Opportunity Owner
                  ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
                  mentionSegment.id = acc.LAT_Account__r.owner.managerId;
                  messageInput.messageSegments.add(mentionSegment);

                  if(acc.LAT_Account__r.owner.Gerente_de_area__c != null){
                      mentionSegment = new ConnectApi.MentionSegmentInput();
                      mentionSegment.id = acc.LAT_Account__r.owner.Gerente_de_area__c;
                      messageInput.messageSegments.add(mentionSegment);
                  }

                  if(acc.LAT_Account__r.owner.Gerente_regional__c != null){
                      mentionSegment = new ConnectApi.MentionSegmentInput();
                      mentionSegment.id = acc.LAT_Account__r.owner.Gerente_regional__c;
                      messageInput.messageSegments.add(mentionSegment);
                  }
              }

               ConnectApi.TextSegmentInput textSegment;
               textSegment = new ConnectApi.TextSegmentInput();
               textSegment.text = '\nClientes selecionados \n';
               messageInput.messageSegments.add(textSegment);
               input.body = messageInput;

               ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(input);
               feedList.add(batchInput);
               if (!Test.isRunningTest()){
                    ConnectApi.ChatterFeeds.postFeedElementBatch(null, feedList);
               } else {
                  system.debug('Test');
               }

      }
   }

   public static void sendEmail(List<String> toAddresses, LAT_PromotionalAction__c promo) {
      if (!toAddresses.isEmpty()) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSubject('Promoción finalizada');
        String msg = 'Promoción finalizada.';
        msg += '\n\n ' + promo.name;
        msg += '\n\n  https://' + URL.getSalesforceBaseUrl().getHost() + '/'+ promo.id;

        mail.setPlainTextBody(msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      }
   }


   public static void substituteClient(List<LAT_AccountInAction__c> triggerNew) {
      for (LAT_AccountInAction__c cli: triggerNew) {
         if (cli.LAT_Status__c == 'Cliente Substituto') {
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(cli.id);
            Approval.ProcessResult result = Approval.process(app);
         }
      }
   }

   public static void substituteClientCreateTask(List<LAT_AccountInAction__c> triggerNew, Map<id, LAT_AccountInAction__c> mapOld) {
      List<Task> tasks = new List<Task>();
      for (LAT_AccountInAction__c cli: [Select id,  LAT_CollectData__c, LAT_RetireMaterials__c, LAT_PromotionalAction__r.LAT_endDate__c,LAT_Account__r.ownerId,LAT_PromotionalAction__r.LAT_Status__c, LAT_PromotionalAction__c, LAT_Status__c  from LAT_AccountInAction__c where id IN: triggerNew]) {
          if (cli.LAT_Status__c == 'Cliente Validado' && mapOld.get(cli.id).LAT_Status__c == 'Cliente Substituto') {
            tasks.addAll(manageInitialTasks(cli));
          }
      }

      if (!tasks.isEmpty()) {
         insert tasks;
      }
   }

   webservice static String finaliceAction(String paid) {
      List<LAT_PromotionalAction__c> paList = [SELECT id, name, LAT_Status__c, owner.email, OwnerId, RecordTypeId,
                                                   (SELECT id, LAT_Status__c, LAT_Account__r.Owner.Email, RecordTypeId FROM LAT_AccountInAction__r WHERE (LAT_Status__c = 'Ação aprovada pelo cliente' OR LAT_Status__c = 'Ação Iniciada'))
                                                FROM LAT_PromotionalAction__c WHERE id =: paid];
      String returnMessage = '';

      if (!paList.isEmpty()) {
         LAT_PromotionalAction__c pa = paList.get(0);
         //if (pa.OwnerId == userInfo.getUserId()) {

            pa.LAT_Status__c = 'Ação Finalizada';
            pa.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_PromotionalAction__c'+'LAT_Finalizada');

            List<LAT_AccountInAction__c> toUpdateClients = new List<LAT_AccountInAction__c>();
            for (LAT_AccountInAction__c aia: pa.LAT_AccountInAction__r) {
               aia.LAT_Status__c = 'Ação Finalizada';
               aia.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_AccountInAction__c'+'LAT_Finalizada');
               toUpdateClients.add(aia);
            }
            try {
               update pa;
               update toUpdateClients;
            } catch (Exception e) {
               returnMessage += e.getMessage();
               LAT_DebugUtil.addException('LAT_PromotionalActionHandler-finaliceAction', e, '-1');
            }
        //  } else {
        //     if ((pa.OwnerId != userInfo.getUserId())) {
        //         returnMessage += 'Somente o proprietário pode finalizar a promoção';
        //     }
        //  }
      }

      return returnMessage;
   }

    webservice static String cancelAction(String paid) {
      List<LAT_PromotionalAction__c> paList = [SELECT id, LAT_CancelationReason__c, name, LAT_Status__c, owner.email,
                                                      OwnerId, RecordTypeId, (SELECT id,LAT_Account__r.Owner.Email
                                                      FROM LAT_AccountInAction__r)
                                                FROM LAT_PromotionalAction__c WHERE id =: paid];
      String returnMessage = '';

      if (!paList.isEmpty()) {
         LAT_PromotionalAction__c pa = paList.get(0);
         if (pa.LAT_CancelationReason__c != '' && pa.LAT_CancelationReason__c != null) {
            pa.LAT_Status__c = 'Ação cancelada';
            pa.RecordTypeId = Global_RecordTypeCache.getRtId('LAT_PromotionalAction__c'+'LAT_Cancelada');
            try {
               update pa;
            } catch (Exception e) {
               returnMessage += e.getMessage();
               LAT_DebugUtil.addException('LAT_PromotionalActionHandler-cancelAction', e, '-1');
            }
         } else  {
            returnMessage += 'Informar Motivo de Cancelamento';
         }
      }

      return returnMessage;

   }

   public static void cerrarPagamento(List<Task> triggerNew, List<Task> triggerOld) {
       //Commented by MP
   //    Map<id, Messaging.SingleEmailMessage> emailsToSend = new Map<id, Messaging.SingleEmailMessage>();
   //    Map<id, Task> oldMap = new  Map<id, Task> ([SELECT id, status FROM Task WHERE id IN: triggerOld]);
   //
   //    List<String> acpIds = new List<String>();
   //    for (Task t: triggerNew) {
   //       if (t.LAT_Tipo__c == 'AP-Realizar Pagamento'
   //          && (t.status == 'Completed' || t.status == 'Concluído')) {
   //          system.debug('t.WhatId2----->' + t.WhatId);
   //          acpIds.add(t.WhatId);
   //       }
   //
   //    }
   //
   //    List<LAT_ActionClientPayment__c> acpList = [SELECT id, LAT_AccountInAction__c, LAT_AccountInAction__r.Name,
   //                                                             LAT_AccountInAction__r.LAT_PromotionalAction__c, LAT_AccountInAction__r.LAT_PromotionalAction__r.Name,
   //                                                             LAT_AccountInAction__r.LAT_Account__r.ownerId, LAT_TaskCreated__c,
   //                                                             LAT_Contact__c, LAT_Contact__r.Email,
   //                                                             (Select id, LAT_ActionClientPayment__c, LAT_Description__c,
   //                                                                LAT_Value__c FROM ActionClientPaymentLines__r)
   //                                                       FROM LAT_ActionClientPayment__c
   //                                                       WHERE id =: acpIds];
   //
   //    system.debug('acpList----->' + acpList);
   //    if (!acpList.isEmpty()) {
   //       List<String> aiacIds = new List<String>();
   //       for (LAT_ActionClientPayment__c acp: acpList) {
   //          if (acp.LAT_Contact__c != null && acp.LAT_Contact__r.Email != null) {
   //             emailsToSend.put(acp.LAT_AccountInAction__c, sendEmailPagamentos(acp));
   //          }
   //          aiacIds.add(acp.LAT_AccountInAction__c);
   //       }
   //
   //       List<LAT_AccountInAction__c> aiacList = [SELECT id, LAT_Status__c FROM LAT_AccountInAction__c WHERE id IN: aiacIds];
   //       for (LAT_AccountInAction__c aiac: aiacList) {
   //         aiac.LAT_Status__c = 'Pagamento Realizado';
   //       }
   //       try {
   //          update aiacList;
   //          system.debug('emailsToSend----->' + emailsToSend);
   //
   //          // This is a hack in order to get the content of the email before
   //          // sending it, and saving it as an attachment
   //          /*Savepoint sp = Database.setSavepoint();
   //            Messaging.sendEmail(emailsToSend.values());
   //          Database.rollback(sp);
   //
   //          List<Attachment> attList = new List<Attachment>();
   //          for (String clientId: emailsToSend.keySet()) {
   //            // Take the email content
   //            if (emailsToSend.get(clientId) != null) {
   //              Messaging.SingleEmailMessage mail = emailsToSend.get(clientId);
   //              Blob pdfBlob = !Test.isRunningTest() ? Blob.toPdf(mail.getHtmlBody()): Blob.toPdf('Testing');
   //              attList.add ( new Attachment (
   //                ParentId = clientId,
   //                Name = mail.getSubject() + '.pdf',
   //                Body = pdfBlob
   //              ));
   //            }
   //          }
   //
   //          insert attList;*/
   //
   //          Messaging.sendEmail(emailsToSend.values());
   //       } catch (Exception e) {
   //          system.debug('error----->' + e.getMessage());
   //          LAT_DebugUtil.addException('LAT_PromotionalActionHandler-cerrarPagamento', e, '-1');
   //       }
   //    }
   }


   public static Messaging.SingleEmailMessage sendEmailPagamentos(LAT_ActionClientPayment__c acp) {


      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = 'LAT_APPaymentNotifications'];
      mail.setTemplateId(et.id);
      mail.setTargetObjectId(acp.LAT_Contact__c);
      mail.setWhatId(acp.id);
      mail.setSaveAsActivity(true);
      /*mail.setToAddresses(new List<String> {acp.LAT_Contact__r.Email});
      mail.setSubject('Termo de quitação ativação ' + acp.LAT_AccountInAction__r.LAT_PromotionalAction__r.Name);
      String message = 'Prezado cliente, sua campanha de incentivo de ' + acp.LAT_AccountInAction__r.LAT_PromotionalAction__r.Name +' foi finalizada em ' +
                       'nosso sistema. Reconhecendo que a entrega formal e pessoal da premiação/bonificação foi ' +
                       'realizada através de um consultor Pernod Ricard em sua presença, serve a presente mensagem ' +
                       'para outorgar-se a mais plena, rasa, mútua e integral quitação das obrigações decorrentes da ' +
                       'ativação promocional em questão, nada mais podendo ser reclamado a qualquer título, obrigando ' +
                       'seus herdeiros e sucessores ao cumprimento do presente. Adicionalmente, reconhecem as Partes que ' +
                       'as obrigações acima estabelecidas decorreram de consenso mútuo, e põem fim a quaisquer divergências '+
                       'cíveis, trabalhistas, tributárias ou comerciais entre as empresas ou sócios, e afastam quaisquer '+
                       'possíveis perdas patrimoniais e morais, ratificando-se que não resta nenhuma obrigação adicional, '+
                       'subjacente ou pendente de cumprimento entre elas senão as ora especificadas, relativamente ao período '+
                       'acima descrito.\n\n';
      for (LAT_ActionClientPaymentLine__c acpl: acp.ActionClientPaymentLines__r) {
         message += acpl.LAT_Description__c + '   ' + acpl.LAT_Value__c + '\n';
      }
      mail.setPlainTextBody(message);*/
      return mail;
   }

    webservice static String sendToApproval(String paid) {
      String returnMessage= '';
      if (paid != null && paid != '') {
        List<LAT_PromotionalAction__c> paList = [SELECT id, Name, RecordTypeId, RecordType.DeveloperName, OwnerId, Owner.Name,
                                                    LAT_BusinessCycle__c, LAT_StartDate__c, LAT_EndDate__c, LAT_Description__c,
                                                    LAT_Booster__c, LAT_Brand__c, LAT_CancelationReason__c,
                                                    LAT_PromotionalPack__c, LAT_Quantidade_de_Clientes__c, LAT_status__c,
                                                    LAT_AmountOfColetas__c, LAT_AmountOfRegions__c,
                                                    (Select id FROM Marcas__r), (Select id from attachments), (Select id FROM Mecanicas__r)
                                                FROM LAT_PromotionalAction__c WHERE id =: paId];

        if (!paList.isEmpty()) {
          LAT_PromotionalAction__c pa = paList.get(0);

        //   if(pa.attachments == null || pa.attachments.size() == 0){
        //       returnMessage +=  '- Favor anexar o PPT de Sales Toolkit para enviar a aprovação \n';
        //   }

          // TO DO, REMOVE
        //   if (pa.LAT_AmountOfColetas__c == 0 ) {
        //     returnMessage += '- Favor informar o(s) Dado(s) a Coletar para enviar a aprovação \n';
        //   }

          if (pa.LAT_AmountOfRegions__c == 0) {
            returnMessage += '- Favor informar Clientes por Regional para enviar a aprovação \n';
          }

          if (pa.Marcas__r.isEmpty()) {
            returnMessage += '- Favor informar a(s) Marca(s) para enviar a aprovação \n';
          }

          if (pa.Mecanicas__r.isEmpty()) {
            returnMessage += '- Favor informar a(s) Mecânica(s) para enviar a aprovação \n';
          }

          if (returnMessage == '') {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(paid);
            Approval.ProcessResult result = Approval.process(req);
          }
        }
      }

      return returnMessage;
   }

    // public static void generateKPITasks(List<String> apIds){
    //  Map<Id, LAT_PromotionalAction__c> generateKpi = New Map<Id, LAT_PromotionalAction__c>([SELECT id, (Select Id, LAT_Account__r.ownerId, LAT_Account__r.recordTypeId, LAT_Account__r.recordType.Name  from LAT_AccountInAction__r), LAT_StartDate__c, LAT_EndDate__c, LAT_status__c, Name, (Select Id, LAT_PromotionalAction__c,  LAT_KPI__c, LAT_KPI__r.Name, LAT_KPI__r.LAT_KPI_Recurring__c, LAT_KPI__r.LAT_KPI_OffTrade__c, LAT_KPI__r.LAT_KPI_OnTrade__c from LAT_ActionKPIs__r where LAT_KPI__r.LAT_KPI_Recurring__c = true) from LAT_PromotionalAction__c where Id in:apIds]);
    //
    //  Integer recurrentDays = LAT_PromotionalActionHandler.getSLANumberOfDays('AP_KPI_COLLECTS');
    //  SYSTEM.debug('============\n  generateKpi: '+generateKpi+' \n ===========');
    //
    //  for(String apKey : generateKpi.keyset()){
    //      LAT_PromotionalAction__c ap = generateKpi.get(apKey);
    //      // Check if we have some KPI recurrent
    //      if(!ap.LAT_ActionKPIs__r.isEmpty()) {
    //          Date today = Date.today();
    //          Date nexTaskDate = today.addDays(recurrentDays);
    //          SYSTEM.debug('============\n  today: '+today+' \n ===========');
    //
    //          SYSTEM.debug('============\n  nexTaskDate: '+nexTaskDate+' \n ===========');
    //
    //
    //
    //          List<Integer> taskDatesToSave = new List<Integer>();
    //          SYSTEM.debug('============\n  taskDatesToSave: '+taskDatesToSave+' \n ===========');
    //
    //          while (ap.LAT_EndDate__c > nexTaskDate && ap.LAT_StartDate__c < nexTaskDate ) {
    //              taskDatesToSave.add(recurrentDays);
    //              recurrentDays = recurrentDays + recurrentDays;
    //              nexTaskDate = nexTaskDate.addDays(recurrentDays);
    //          }
    //          SYSTEM.debug('============\n  taskDatesToSave: '+taskDatesToSave+' \n ===========');
    //          if(!taskDatesToSave.isEmpty()){
    //              generateKPIsRecucrentsForClients(ap, taskDatesToSave);
    //          }
    //
    //      }
    //
    //  }
    // }







    public static void implemetedActionFinished(List<Task> triggerNew, List<Task> triggerOld) {

        Map<id, Task> oldMap = new  Map<id, Task> ([SELECT id, status FROM Task WHERE id IN: triggerOld]);

        List<String> acpIds = new List<String>();
        List<String> apIds = new List<String>();

        for (Task t: triggerNew) {
          if (t.LAT_Tipo__c == 'AP-Ação Implementada'
             && (t.status == 'Completed' || t.status == 'Concluído')) {
             system.debug('t.WhatId2----->' + t.WhatId);
             acpIds.add(t.WhatId);
          }
        }
        SYSTEM.DEBUG('WhatId2'+apIds);
        List<LAT_AccountInAction__c> accList = [SELECT id, LAT_PromotionalAction__c, LAT_Status__c FROM LAT_AccountInAction__c
                                                  WHERE id IN :acpIds ];


        SYSTEM.DEBUG('accList>>>>>>>>'+accList);
        if(!accList.isEmpty()){
            for(LAT_AccountInAction__c laia : accList){
                laia.LAT_ImplementedAction__c = true;
                apIds.add(laia.LAT_PromotionalAction__c);
            }
            SYSTEM.DEBUG('apIds>>>>>>>>'+apIds);
            SYSTEM.DEBUG('generateKPITasks <<<<<<<>>>>>>>>');


            update accList;

        }
        // if(!apIds.isEmpty()){
        //  generateKPITasks(apIds);
        // }





                                                    //   aiac.LAT_ImplementedAction__c = true;
                                                    //   update aiac;
        // if (tk.LAT_Tipo__c == 'AP-Ação Implementada') {
        //   List<LAT_AccountInAction__c> accList = [SELECT id, LAT_Status__c FROM LAT_AccountInAction__c
        //                                               WHERE id =: tk.WhatId];
        //   if (!accList.isEmpty()) {
        //     LAT_AccountInAction__c aiac = accList.get(0);
        //     aiac.LAT_ImplementedAction__c = true;
        //     update aiac;
        //   }
        // }
    }


  webservice static void manageClosingTasks(String taskId){
    List<Task> taskList = [SELECT id, WhatId, status, LAT_Tipo__c FROM Task WHERE id =: taskId AND status != 'Completed'];
        if (!taskList.isEmpty()) {
            Task tk = taskList.get(0);

            try {
        if (tk.LAT_Tipo__c == ' AP-Apresentar Proposta ao Cliente') {
          List<LAT_AccountInAction__c> accList = [SELECT id, LAT_Status__c FROM LAT_AccountInAction__c
                                                      WHERE id =: tk.WhatId];
          if (!accList.isEmpty()) {
            LAT_AccountInAction__c aiac = accList.get(0);
            aiac.LAT_Status__c = 'Ação aprovada pelo cliente';
            update aiac;
          }
        }
        // if (tk.LAT_Tipo__c == 'AP-Ação Implementada') {
        //   List<LAT_AccountInAction__c> accList = [SELECT id, LAT_Status__c FROM LAT_AccountInAction__c
        //                                               WHERE id =: tk.WhatId];
        //   if (!accList.isEmpty()) {
        //     LAT_AccountInAction__c aiac = accList.get(0);
        //     aiac.LAT_ImplementedAction__c = true;
        //     update aiac;
        //   }
        // }

            } catch (Exception e){
                LAT_DebugUtil.addException('LAT_ClientByRegionHandler-manageClosingTasks', e, '-1');
            }
        }
  }

  public static void createTaskEvidencia(List<LAT_AccountInAction__c> triggerNew, Map<id, LAT_AccountInAction__c> oldMap) {
    List<Task> tasks = new List<Task>();
    for (LAT_AccountInAction__c cli: [SELECT id, LAT_Status__c, LAT_Account__r.ownerId, LAT_PromotionalAction__c FROM LAT_AccountInAction__c WHERE id IN:triggerNew]) {
      if (cli.LAT_Status__c == 'Ação aprovada pelo cliente'
          && oldMap.get(cli.id) != null
          && oldMap.get(cli.id).LAT_Status__c != 'Ação aprovada pelo cliente' ) {

        //if (cli.LAT_PromotionalAction__r.LAT_ActivationMaterial__c) {
          Integer evidenceDueDays = getSLANumberOfDays('AP_SLA_EVIDENCE');
          Task taskEvidencia = LAT_ProcessesTaks.createTask(cli.id, cli.LAT_Account__r.ownerId, 'Coletar Evidência de Implementação da Ação',
                                               'Favor coletar a evidência de implementação do Material de Ativação' ,
                                               Global_RecordTypeCache.getRtId('Task'+'LAT_PromotionalAction'), evidenceDueDays, 'AP-Coletar Evidencia');
          taskEvidencia.LAT_PromotionalAction__c = cli.LAT_PromotionalAction__c;
          taskEvidencia.LAT_AccountInAction__c = cli.id;
          tasks.add(taskEvidencia);
       // }

      }
    }
    if (!tasks.isEmpty()) {
      insert tasks;
    }
  }

  webservice static void initPromotionalAction(String paId){
    List<LAT_PromotionalAction__c> paList = [SELECT id, Name, RecordTypeId, RecordType.DeveloperName, OwnerId, Owner.Name,
                                                LAT_BusinessCycle__c, LAT_StartDate__c, LAT_EndDate__c, LAT_Description__c,
                                                LAT_Booster__c, LAT_Brand__c, LAT_CancelationReason__c,
                                                LAT_PromotionalPack__c, LAT_Quantidade_de_Clientes__c, LAT_status__c
                                            FROM LAT_PromotionalAction__c WHERE id =: paId];

    if (!paList.isEmpty()) {
      LAT_PromotionalAction__c pa = paList.get(0);
      if (pa.LAT_Status__c != '') {
        if (pa.LAT_Status__c == 'Ação aprovada'){
          try {
            pa.LAT_Status__c = 'Ação iniciada';
            pa.recordTypeId = Global_RecordTypeCache.getRtId('LAT_PromotionalAction__c'+'Iniciada');
            update pa;

            closePromotionalActionTasks(new List<String>{paId});
            createPromotionalActionTasks(new List<String>{paId});
          } catch (Exception e) {
            LAT_DebugUtil.addException('LAT_PromotionalActionHandler-initPromotionalAction', e, '-1');
          }
        }
      }
    }

  }

  public static void postToChatterGroup(List<LAT_PromotionalAction__c> triggerNew, Map<id, LAT_PromotionalAction__c> oldMap){
    List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();
    String groupId = '';
    String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('AP_CHATTER_GROUP', ' ');
    if(groups != null && groups.size()>0)groupId = groups[0];

    for (LAT_PromotionalAction__c pa: triggerNew) {
      if (trigger.isInsert) {
        String msg = 'Ação Promocional ' + pa.Name + ' criada';
        ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>(), msg, pa.id);
        if(post != null)posts.add(post);
      } else if (pa.LAT_Status__c == 'Ação iniciada' && oldMap.get(pa.id) != null && oldMap.get(pa.id).LAT_Status__c != 'Ação iniciada'){
        String msg = 'Ação Promocional ' + pa.Name + ' iniciada';
        ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>(), msg, pa.id);
        if(post != null)posts.add(post);
      } else if (pa.LAT_Status__c == 'Ação Finalizada' && oldMap.get(pa.id) != null && oldMap.get(pa.id).LAT_Status__c != 'Ação Finalizada'){
        String msg = 'Ação Promocional ' + pa.Name + ' finalizada';
        ConnectApi.BatchInput post = LAT_ProcessesNotifications.generateChatterPost(groupId,new List<String>(), msg, pa.id);
        if(post != null)posts.add(post);
      }

    }
    LAT_ProcessesNotifications.post(posts);
  }

  /*
  * generatePromotionalActionTasks
  * In the past we had a button to generate tasks on the Clients by Region, we don't want to use this button anymore, and
  * call the method automatcly when the action is approved
  * @param triggerNew, oldMap
  */
  public static void generatePromotionalActionTasks(List<LAT_PromotionalAction__c> triggerNew, Map<id, LAT_PromotionalAction__c> oldMap) {
    SYSTEM.debug('============\n  generatePromotionalActionTasks \n ===========');
    for (LAT_PromotionalAction__c pa: triggerNew) {
        if (trigger.isUpdate) {
            SYSTEM.debug('============\n  pa.LAT_Status__c: '+pa.LAT_Status__c+' \n ===========');
            SYSTEM.debug('============\n  oldMap.get(pa.id).LAT_Status__c: '+oldMap.get(pa.id).LAT_Status__c+' \n ===========');
            if (pa.LAT_Status__c == 'Ação aprovada' && oldMap.get(pa.id) != null && oldMap.get(pa.id).LAT_Status__c != 'Ação aprovada'){
                LAT_ClientByRegionHandler.SendToApproval(pa.id);
                SYSTEM.debug('============\n  pa.id: '+pa.id+' \n ===========');
            }
        }

    }

  }
  public static void getMockDataPromAction() {
        String jsonMock=        '{';
        jsonMock += '    "id": 175,';
        jsonMock +='    "type": "CP",';
        jsonMock +='    "documentType": "CP",';
        jsonMock +='    "description": "Lorem Ipsum",';
        jsonMock +='    "dateRequest": "2017-09-17T08:00:00.000Z",';
        jsonMock +='    "dateApproval": null,';
        jsonMock +='    "amountReceived": 0,';
        jsonMock +='    "dateAccount": null,';
        jsonMock +='    "accountBatchNumber": null,';
        jsonMock +='    "subarea": {';
        jsonMock +='        "idSubarea": 9';
        jsonMock +='    },';
        jsonMock +='    "status": {';
        jsonMock +='        "idStatus": 4,';
        jsonMock +='        "description": "CRIADO"';
        jsonMock +='    },';
        jsonMock +='    "error": {';
        jsonMock +='        "idError": 4,';
        jsonMock +='        "description": "CRIADO"';
        jsonMock +='    },';
        jsonMock +='    "message": {' ;
        jsonMock +='        "description": "CRIADO"';
        jsonMock +='    },';
        jsonMock +='    }';

    }

}