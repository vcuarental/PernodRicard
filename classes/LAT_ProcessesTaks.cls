public with sharing class LAT_ProcessesTaks {
    public LAT_ProcessesTaks() {

    }

    public static Task createTask(String whatId, String ownerId, String subject,
                                    String description, String recordTypeID, integer daysToDue,String tipo) {


        Double remainderDays = 20;
        if (tipo.contains('POP')) {
            String[] tdays = LAT_GeneralConfigDao.getValueAsStringArray('POP_REMINDER_%', ' ');
            if(tdays != null && tdays.size()>0)remainderDays = Double.valueOf(tdays[0]);
        } else if (tipo.contains('AP')) {
            String[] tdays = LAT_GeneralConfigDao.getValueAsStringArray('AP_REMINDER_%', ' ');
            if(tdays != null && tdays.size()>0)remainderDays = Double.valueOf(tdays[0]);
        }

        Double remDays = (1 - (remainderDays/100));
        system.debug('##### ' + remDays);


        Date dToday = system.today();

        Task task = new Task(
            WhatId = whatId,
            OwnerId = ownerId,
            Subject = subject,
            LAT_Tipo__c = tipo,
            status = 'Iniciada',
            IsReminderSet = true,
            ReminderDateTime = datetime.newInstance(dToday.year(), dToday.month(),dToday.day(), 9, 0,0),
            recordTypeId = recordTypeID,
            description = description,
            ActivityDate = AddBusinessDays(Date.today(),daysToDue)
        );

        task.ReminderDateTime = task.ReminderDateTime.addDays(Integer.valueOf(Date.today().daysBetween(task.ActivityDate)* remDays));
    		return task;
    }

    public static Boolean IsWeekendDay(Date dateParam){
      boolean result     = false;
      //Recover the day of the week
      Date startOfWeek   = dateParam.toStartOfWeek();
      Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
      result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false;
      return result;
   }


   public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd ){
      //Add or decrease in BusinessDaysToAdd days
      Date finalDate = StartDate;
      integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
       while(BusinessDaysToAdd != 0){
           finalDate = finalDate.AddDays(direction);
           if (!isWeekendDay(finalDate)){
               BusinessDaysToAdd -= direction;
           }
       }
       return finalDate;
   }

    public static void insertAndNotificate(List<Task> tasks){
        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.EmailHeader.TriggerUserEmail = TRUE;

        Database.Insert(
            tasks,
            dmlOptions
        );
    }

    public static void checkClosedTasks(List<Task> tasks, List<Task> oldTasks){
        List<LAT_InventoryPOP__c> toUpdate = new list<LAT_InventoryPOP__c>();
        List<String> inventoriesIds = new list<String>();
        List<String> tasksIds = new list<String>();


        for(integer i=0;i<tasks.size();i++){
            Task ta = tasks[i];
            Boolean closed = (ta.status == 'Completed' && oldTasks[i].status != 'Completed') || (ta.status == 'Concluído' && oldTasks[i].status != 'Concluído');
            if(ta.LAT_Tipo__c == 'POP-Inventario' && closed){
                inventoriesIds.add(ta.whatId);
            }else if(ta.LAT_Tipo__c == 'POP-Coletar Evidencia' && closed){
                tasksIds.add(ta.id);
            }
        }
        if(tasksIds != null && tasksIds.size()>0){
            postEvidence(tasksIds);
        }

        toUpdate = [Select id from LAT_InventoryPOP__c where id in: inventoriesIds];

        for(LAT_InventoryPOP__c inv : toUpdate){
            inv.status__c = 'Concluido';
        }

        update toUpdate;
    }

    public static void postEvidence(List<String> tasksIds){
        List<ConnectApi.BatchInput> posts = new List<ConnectApi.BatchInput>();

        try{
            String groupId = '';
            String[] groups = LAT_GeneralConfigDao.getValueAsStringArray('KAM_POP_CHATTER_GROUP', ' ');
            if(groups != null && groups.size()>0)groupId = groups[0];

            Map<Id, Task> tasksMap = new Map<Id,Task>([Select id,whatId,(select Id, Name, Description, LastModifiedDate from Attachments) from task where id in: tasksIds]);
            Map<Id, Attachment> attsMap = new Map<Id,Attachment>([Select Id,Body, Name, Description, LastModifiedDate from Attachment where parentId in: tasksIds]);

            Map<String,ContentVersion> contentMap = new Map<String, ContentVersion>();

            List<String> entregasIds = new List<String>();

            for(Task tk : tasksMap.values()){
                if(tk.attachments != null && tk.attachments.size() > 0){
                    entregasIds.add(tk.whatId);
                    for(Attachment att: tk.attachments){
                        Attachment tmpAtt = attsMap.get(att.id);
                        ContentVersion content = new ContentVersion();
                        content.versionData = tmpAtt.body;
                        content.title = tmpAtt.name;
                        content.pathOnClient = tmpAtt.name;
                        contentMap.put(tk.id + '' + tmpAtt.name, content);
                    }
                }
            }
            insert contentMap.values();

            List<String> contentIds = new list<String>();
            for(ContentVersion cv: contentMap.values()){
                contentIds.add(cv.id);
            }

            Map<Id, LAT_ClientPOP__c> entregasMap = new Map<Id, LAT_ClientPOP__c>([Select id,LAT_Client__r.Name,LAT_Client__r.Client_code_AN8__c,LAT_Client__c, Material_POP__r.Name,Delivered_Date__c,Delivered__c from LAT_ClientPOP__c where id in: entregasIds]);
            Map<Id, ContentVersion> contentsMap = new Map<Id,ContentVersion>([Select id, ContentDocumentId from ContentVersion where id in: contentIds]);

            for(Task tk : tasksMap.values()){
                if(tk.attachments != null && tk.attachments.size() > 0){
                    LAT_ClientPOP__c entrega = entregasMap.get(tk.whatId);
                    if(entrega != null && groupId != ''){
                        ConnectApi.BatchInput batchInput = null;
                        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
                        input.subjectId = '0F9L00000005bcS';

                        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
                        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

                        createParagraph(messageInput.messageSegments,'Cliente: ' + entrega.LAT_Client__r.Name + '-' + entrega.LAT_Client__r.Client_code_AN8__c );
                        createParagraph(messageInput.messageSegments, URL.getSalesforceBaseUrl().toExternalForm() + '/' + entrega.LAT_Client__c );
                        createParagraph(messageInput.messageSegments,'');
                        createParagraph(messageInput.messageSegments,'Material POP: ' + entrega.Material_POP__r.Name);
                        createParagraph(messageInput.messageSegments,'Data Entrega: ' + entrega.Delivered_Date__c.day() + '/' + entrega.Delivered_Date__c.month() + '/' + entrega.Delivered_Date__c.year());
                        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = 'Quantidade Entregue: ' + entrega.Delivered__c;
                        messageInput.messageSegments.add(textSegment);


                        for(Attachment att: tk.attachments){
                            if(contentMap.get(tk.id + '' + att.name) != null){
                                ContentVersion cv = contentMap.get(tk.id + '' + att.name);

                                ConnectApi.InlineImageSegmentInput inlineImageSegment;
                                inlineImageSegment = new ConnectApi.InlineImageSegmentInput();
                                inlineImageSegment.altText = cv.title;
                                inlineImageSegment.fileId = contentsMap.get(cv.id).ContentDocumentId;

                                messageInput.messageSegments.add(inlineImageSegment);
                            }
                        }

                        input.body = messageInput;
                        batchInput = new ConnectApi.BatchInput(input);
                        posts.add(batchInput);
                    }
                }


            }
            if(posts != null && posts.size() > 0){
                ConnectApi.ChatterFeeds.postFeedElementBatch(null, posts);
            }
        }catch(Exception e){

        }
    }

    public static void createParagraph(List<ConnectApi.MessageSegmentInput> segments, String text){
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
        markupBeginSegment.markupType = ConnectApi.MarkupType.Paragraph;
        segments.add(markupBeginSegment);

        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = text;
        segments.add(textSegment);

        ConnectApi.MarkupEndSegmentInput markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
        markupEndSegment.markupType = ConnectApi.MarkupType.Paragraph;
        segments.add(markupEndSegment);
    }

    public static void updateOriginalDueDate(List<Task> tasks){
        for(Task t : tasks){
            if(t.ActivityDate != null && t.LAT_OriginalDueDate__c == null){
                t.LAT_OriginalDueDate__c = t.ActivityDate;
            }
        }
    }
    public static void setOrigin(List<Task> pTasks) {

        for (Task t : pTasks ) {
            if (t.PR_Memo__c == null) {
                t.PR_Memo__c = 'WEB';
            } 
        }

    }

}