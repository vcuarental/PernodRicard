global class LAT_BR_PromotionalActionScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        postToChatter();
        generateActivities();
		database.executebatch(new LAT_PromotionalActionTaskBatch(), 10);

    }
    // Method for creating a Chatter Post one month before de Promotional Action Begins.
    // oo
    public static void postToChatter() {
        //List<LAT_PromotionalAction__c> nextMonthActions = [SELECT id, Name, LAT_StartDate__c, (SELECT LAT_RegionalSupervisor__r.Supervisor__c FROM Clientes_por_Regional__r)
        List<LAT_PromotionalAction__c> nextMonthActions = [SELECT id, Name, LAT_StartDate__c, (SELECT LAT_RegionalSupervisor2__c FROM Clientes_por_Regional__r)

                                               FROM LAT_PromotionalAction__c WHERE LAT_StartDate__c = NEXT_N_DAYS:30];

        LAT_CHATTER_POST_BODY__c cs = [SELECT Body__c FROM LAT_CHATTER_POST_BODY__c WHERE Name = 'LAT_BR_AP_IniciarAcao'];
        String body = cs.Body__c;
        CollaborationGroup chatterGroup = [select Id, Name from CollaborationGroup where Name = 'Ações Promocionais'];
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for (LAT_PromotionalAction__c pa : nextMonthActions) {
            body = body.replace('xx_ACTION_NAME_xx', pa.Name );


			//Time myTime = Time.newInstance(0, 0, 0, 0);
			DateTime dt = DateTime.newInstance(pa.LAT_StartDate__c.year(), pa.LAT_StartDate__c.month(), pa.LAT_StartDate__c.day() );

            body = body.replace('xx_START_DATE_xx', dt.format('dd-MM-yyyy'));
            body = body + ' \n ';

            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            textSegmentInput.text = body;
            System.debug('%%%% textSegmentInput.text : '+textSegmentInput.text);
            messageBodyInput.messageSegments.add(textSegmentInput);

            for (LAT_ClientByRegion__c clienteRegional : pa.Clientes_por_Regional__r) {
                //if (clienteRegional.LAT_RegionalSupervisor__r.Supervisor__c != null) {
                if (clienteRegional.LAT_RegionalSupervisor2__c != null) {

                    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                    mentionSegmentInput.id = clienteRegional.LAT_RegionalSupervisor2__c;
                    messageBodyInput.messageSegments.add(mentionSegmentInput);
                }
            }
            System.debug('%%%% messageBodyInput : '+messageBodyInput);
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = chatterGroup.Id;

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            batchInputs.add(batchInput);
        }

        if (batchInputs.size() > 0) {
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }

    public static void generateActivities() {
        List<LAT_PromotionalAction__c> todayActions = [SELECT id, Name, LAT_StartDate__c, OwnerId
                                                FROM LAT_PromotionalAction__c WHERE LAT_StartDate__c = TODAY];
        List<Task> toInsert = new List<Task>();
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'LAT_PromotionalAction'];
        LAT_GeneralConfig__c gc = [SELECT name, id, LAT_Value__c FROM LAT_GeneralConfig__c where name = 'Promotional_Action_Task_Days'];
        Integer days = Integer.valueOf(gc.LAT_Value__c);

        for (LAT_PromotionalAction__c pa : todayActions) {
            Task newTask = new Task();
            newTask.OwnerId = pa.OwnerId;
            newTask.RecordTypeId = rt.Id;
            newTask.ActivityDate = Date.Today().addDays(days);
            newTask.LAT_PromotionalAction__c = pa.Id;
            toInsert.add(newTask);

        }

        if (toInsert.size() > 0) {
            insert toInsert;
        }

    }


}