public class ASI_CRM_VisitationPlanDetailTodayCtr {
    
    @AuraEnabled
    public static visitationPlanDetail getVisitationPlanDetail(String recordId) {
        visitationPlanDetail visitationPlanDetailOut = new visitationPlanDetail();
        ASI_CRM_VisitationPlanSetting__c vpdSetting = ASI_CRM_VisitationPlanSetting__c.getInstance();

        String query = 'select ID, Name, ASI_HK_CRM_Visitation_Plan__c'
                        + ', ASI_CRM_MY_Customer__c, ASI_CRM_MY_Customer__r.Name, ASI_CRM_MY_Customer__r.ASI_TH_CRM_OutletType__r.Name'
                        + ', ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Latitude__s, ASI_CRM_MY_Customer__r.ASI_CRM_CN_GPS_info__Longitude__s'
                        + ', ASI_CRM_MY_Customer__r.' + vpdSetting.ASI_CRM_Customer_Address__c + ', ASI_CRM_MY_Customer__r.' + vpdSetting.ASI_CRM_Customer_Phone__c
                        + ', ASI_HK_CRM_Visit_Date__c, ASI_HK_CRM_Visitation_Plan__r.OwnerId,ASI_MY_CRM_Bottle_Label__c,ASI_MY_CRM_Custody_Condition__c,ASI_MY_CRM_Outlet_Type__c'
                        + ', ASI_MY_CRM_Follow_Plan__c,ASI_CRM_MY_BarDisplay__c,ASI_CRM_MY_Planogram__c,ASI_MY_CRM_Improvements__c'
                        + ', ASI_CRM_MY_Own_Activations__c,ASI_CRM_MY_OwnActivationRemark__c,ASI_MY_CRM_Top_Of_Staff_Mind__c'
                        + ', ASI_MY_CRM_Familiar_WITH_PRM__c,ASI_MY_CRM_Recommend__c,ASI_MY_CRM_Not_Recommend_Reason__c'
                        + ', ASI_MY_CRM_Incentive__c,ASI_TH_CRM_Visit_Date_Time_From__c,ASI_TH_CRM_Visit_Date_Time_To__c,ASI_HK_CRM_Status__c'
                        + ' from ASI_HK_CRM_Visitation_Plan_Detail__c'
                        + ' where id = :recordId';

        visitationPlanDetailOut.currentVisitationPlanDetail = database.query(query);
        visitationPlanDetailOut.custAddress = String.valueOf(visitationPlanDetailOut.currentVisitationPlanDetail.getSobject('ASI_CRM_MY_Customer__r').get(vpdSetting.ASI_CRM_Customer_Address__c));
        visitationPlanDetailOut.custPhone = String.valueOf(visitationPlanDetailOut.currentVisitationPlanDetail.getSobject('ASI_CRM_MY_Customer__r').get(vpdSetting.ASI_CRM_Customer_Phone__c));

        
        visitationPlanDetailOut.noteList = [SELECT Id, ParentId, Title, CreatedBy.Name,Createddate
                FROM Note
                WHERE ParentId IN
                (SELECT Id From ASI_HK_CRM_Visitation_Plan_Detail__c where id=:visitationPlanDetailOut.currentVisitationPlanDetail.id)
               ];
        
        if(visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Bottle_Label__c !=null || visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Custody_Condition__c !=null || visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Outlet_Type__c !=null
        ||(visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Follow_Plan__c !=null && visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Follow_Plan__c!='') || visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_BarDisplay__c
        ||visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_Planogram__c||(visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Improvements__c != null && visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Improvements__c!='')
        ||visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_Own_Activations__c !=null || (visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c!=null && visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_OwnActivationRemark__c!='')
        ||visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c != null || visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Familiar_WITH_PRM__c != null ||visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Recommend__c
        || (visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c!=null && visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Not_Recommend_Reason__c!='')
        || (visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Incentive__c!=null && visitationPlanDetailOut.currentVisitationPlanDetail.ASI_MY_CRM_Incentive__c !=''))
        {
            visitationPlanDetailOut.isQVAP_Done = true;
        }
        else
        {
            visitationPlanDetailOut.isQVAP_Done = false;
        }
        
        if(visitationPlanDetailOut.currentVisitationPlanDetail.ASI_HK_CRM_Visit_Date__c == system.today())
        {
            visitationPlanDetailOut.isToday = true;
        }

        
        
        ASI_CRM_VisitationRTypeMapping__c setting = ASI_CRM_VisitationRTypeMapping__c.getInstance();
		ID rspHeaderRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_RSPHeaderRTypeAPI__c);
        ID iotHeaderRTID = Global_RecordTypeCache.getRtId(setting.ASI_CRM_IOTHeaderRTypeAPI__c);
		ID userID = UserInfo.getUserId();

		List<ASI_CRM_RSPHeader__c> rspHeader = [
			select ID, Name, ASI_CRM_Branch__c
					, ASI_CRM_Customer__c, ASI_CRM_Date__c, ASI_CRM_Remark__c, RecordTypeId
			from ASI_CRM_RSPHeader__c
			where RecordTypeId = :rspHeaderRTID
			and OwnerId = :userID
			and ASI_CRM_Customer__c = :visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_Customer__c
			and ASI_CRM_Date__c = :visitationPlanDetailOut.currentVisitationPlanDetail.ASI_HK_CRM_Visit_Date__c
			limit 1
		];

        List<ASI_CRM_IOTHeader__c> iotHeader=[
            select ID from ASI_CRM_IOTHeader__c
            where OwnerId = :userID
            and RecordTypeId = :iotHeaderRTID
            and ASI_CRM_Customer__c = : visitationPlanDetailOut.currentVisitationPlanDetail.ASI_CRM_MY_Customer__c
            and DAY_ONLY(Createddate) = :visitationPlanDetailOut.currentVisitationPlanDetail.ASI_HK_CRM_Visit_Date__c
        ];

        List<ASI_CRM_EVENTCapture__c>eventList = new List<ASI_CRM_EVENTCapture__c>();
        eventList = [Select Id from ASI_CRM_EVENTCapture__c where ASI_CRM_MY_VisitationPlanDetail__c =: recordId];

        visitationPlanDetailOut.isRSP_Done = rspHeader.size()>0;
        visitationPlanDetailOut.isIOT_Done = iotHeader.size()>0;
        visitationPlanDetailOut.isEvent_Done = eventList.size()>0;

        visitationPlanDetailOut.conVList = getPhoto(recordId);

        visitationPlanDetailOut.currentVisitationPlanDetail.ASI_HK_CRM_Status__c = visitationPlanDetailOut.currentVisitationPlanDetail.ASI_HK_CRM_Status__c == null?'Planned':visitationPlanDetailOut.currentVisitationPlanDetail.ASI_HK_CRM_Status__c;
        
        return visitationPlanDetailOut;
    }

    @AuraEnabled
    public static visitationPlanDetail_QVAP getCurrentVisitationPlanDetail(String recordId) {
        visitationPlanDetail_QVAP visitationPlanDetailOut= new visitationPlanDetail_QVAP();
        visitationPlanDetailOut.currentVisitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        visitationPlanDetailOut.currentVisitationPlanDetail = [
            select ID, Name, ASI_MY_CRM_Bottle_Label__c,ASI_MY_CRM_Custody_Condition__c,ASI_MY_CRM_Outlet_Type__c
            ,ASI_MY_CRM_Follow_Plan__c,ASI_CRM_MY_BarDisplay__c,ASI_CRM_MY_Planogram__c,ASI_MY_CRM_Improvements__c
            ,ASI_CRM_MY_Own_Activations__c,ASI_CRM_MY_OwnActivationRemark__c,ASI_MY_CRM_Top_Of_Staff_Mind__c
            ,ASI_MY_CRM_Familiar_WITH_PRM__c,ASI_MY_CRM_Recommend__c,ASI_MY_CRM_Not_Recommend_Reason__c
            ,ASI_MY_CRM_Incentive__c
			from ASI_HK_CRM_Visitation_Plan_Detail__c
            where id =: recordId
        ];
 
        ASI_CRM_VisitationPlanSetting__c taskSetting = ASI_CRM_VisitationPlanSetting__c.getinstance();
        visitationPlanDetailOut.bottleLabel.add('');
        visitationPlanDetailOut.bottleLabel.addall(taskSetting.ASI_CRM_Bottle_Label__c.split(','));

        visitationPlanDetailOut.custodyCondition.add('');
        visitationPlanDetailOut.custodyCondition.addall(taskSetting.ASI_CRM_Custody_Condition__c.split(','));

        visitationPlanDetailOut.outletType.add('');
        visitationPlanDetailOut.outletType.addall(taskSetting.ASI_CRM_Outlet_Type__c.split(','));

        visitationPlanDetailOut.ownActivations.add('');
        visitationPlanDetailOut.ownActivations.addall(taskSetting.ASI_CRM_Own_Activations__c.split(','));

        visitationPlanDetailOut.topOfStaffMind.add('');
        visitationPlanDetailOut.topOfStaffMind.addall(taskSetting.ASI_CRM_Top_Of_Staff_Mind__c.split(','));

        visitationPlanDetailOut.familiarWithPRM.add('');
        visitationPlanDetailOut.familiarWithPRM.addall(taskSetting.ASI_CRM_Familiar_With_PRM__c.split(','));

        System.debug(visitationPlanDetailOut.outletType);
        
        
        return visitationPlanDetailOut;
    }

    @AuraEnabled
    public static string saveVisitationPlanDetail(String  updateVisitationDetailJson) 
    {
        system.debug('Start function');
        system.debug(system.now());

        system.debug(updateVisitationDetailJson);
        ASI_HK_CRM_Visitation_Plan_Detail__c updateVisitationDetail = (ASI_HK_CRM_Visitation_Plan_Detail__c) 
        JSON.deserialize(updateVisitationDetailJson, ASI_HK_CRM_Visitation_Plan_Detail__c.class);
        system.debug('Start deserialize');
        system.debug(system.now());
        updateVisitationDetail.ASI_MY_CRM_Bottle_Label__c = updateVisitationDetail.ASI_MY_CRM_Bottle_Label__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_MY_CRM_Bottle_Label__c;
        updateVisitationDetail.ASI_MY_CRM_Custody_Condition__c = updateVisitationDetail.ASI_MY_CRM_Custody_Condition__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_MY_CRM_Custody_Condition__c;
        updateVisitationDetail.ASI_MY_CRM_Outlet_Type__c = updateVisitationDetail.ASI_MY_CRM_Outlet_Type__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_MY_CRM_Outlet_Type__c;
        updateVisitationDetail.ASI_MY_CRM_Improvements__c = updateVisitationDetail.ASI_MY_CRM_Improvements__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_MY_CRM_Improvements__c;
        updateVisitationDetail.ASI_CRM_MY_Own_Activations__c = updateVisitationDetail.ASI_CRM_MY_Own_Activations__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_CRM_MY_Own_Activations__c;   
        updateVisitationDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c = updateVisitationDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_MY_CRM_Top_Of_Staff_Mind__c;   
        updateVisitationDetail.ASI_MY_CRM_Familiar_WITH_PRM__c = updateVisitationDetail.ASI_MY_CRM_Familiar_WITH_PRM__c == ''
                                                            ? null
                                                            : updateVisitationDetail.ASI_MY_CRM_Familiar_WITH_PRM__c;                                                                                                                                                                                                                                                                                                            

        system.debug('Start save');
        system.debug(system.now());
        update updateVisitationDetail;
        system.debug('End save');
        system.debug(system.now());
        return '';
    }

    @AuraEnabled
    public static void updateVisitationTime(String recordId, String  action) 
    {
        ASI_HK_CRM_Visitation_Plan_Detail__c vpd = new ASI_HK_CRM_Visitation_Plan_Detail__c();
        vpd.id = recordId;
        if(action == 'StartVisit')
        {
            vpd.ASI_TH_CRM_Visit_Date_Time_From__c = system.now();
        }
        else if(action == 'CancelVisit')
        {
            vpd.ASI_HK_CRM_Status__c = 'Cancelled';
        }
        else 
        {
            vpd.ASI_TH_CRM_Visit_Date_Time_To__c = system.now();
            vpd.ASI_HK_CRM_Status__c = 'Achieved';
        }
        update vpd;
    }

    @AuraEnabled
    public static Note getNote(String recordId) 
    {
        Note currentNote = new Note();
        currentNote = [SELECT Id, ParentId, Title,Body, CreatedBy.Name,Createddate
                FROM Note
                WHERE Id =: recordId
               ];
        return currentNote;
    }
    @AuraEnabled
    public static Note upsertNote(String recordId,String titleIn, String bodyIn,String parentIdIn) 
    {
        String noteId = recordId==null || recordId==''? null : recordId;
        Note currentNote = new Note(id=noteId,ParentId=parentIdIn, Title=titleIn,Body=bodyIn);
        upsert currentNote;
        return currentNote;
    }

    @AuraEnabled
    public static List<ContentVersion> getPhoto(String recordId) 
    {
        List<ContentDocumentLink> conDLList = new List<ContentDocumentLink>();
        List<ContentVersion> conVList= new List<ContentVersion>();
        set<id> conDSetId = new set<id>();

        conDLList = [select id, ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: recordId];
        if(conDLList != null && conDLList.size() > 0)
        {
            for(ContentDocumentLink conDL : conDLList)
            {
                conDSetId.add(conDL.ContentDocumentId);
            }
            conVList = [select Id, title, ContentDocumentId from contentversion where ContentDocumentId in : conDSetId order by Createddate];

        }

        return conVList;

    }

    @AuraEnabled
    public static List<eventWithPhoto> getEventList(String recordId) 
    {
        set<id> eventIdSet = new set<id>();
        set<id> contentDocIdSet = new set<id>();
        List<eventWithPhoto> eventWithPhotoList = new List<eventWithPhoto>();
        List<ASI_CRM_EVENTCapture__c> eventList = new List<ASI_CRM_EVENTCapture__c>();
        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
        List<ContentVersion> conVersionList = new List<ContentVersion>();
        Map<id, set<id>> eventConDocLinkMap = new Map<id, set<id>>();
        Map<id, ContentVersion> ContentVersionMap = new Map<id, ContentVersion>();


        eventList = [select id, Name, ASI_CRM_MY_PRMorCompetitor__c from ASI_CRM_EVENTCapture__c where ASI_CRM_MY_VisitationPlanDetail__c =: recordId];

        if(eventList != null && eventList.size() > 0 )
        {
            for(ASI_CRM_EVENTCapture__c eventCapture: eventList)
            {
                eventIdSet.add(eventCapture.id);
            }
            conDocLinkList =[select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId in: eventIdSet];

            if(conDocLinkList != null && conDocLinkList.size() > 0)
            {
                for(ContentDocumentLink conDocLink :conDocLinkList)
                {
                    if(!eventConDocLinkMap.containskey(conDocLink.LinkedEntityId))
                    {
                        set<id> conDocIdSet = new set<id>();
                        conDocIdSet.add(conDocLink.ContentDocumentId);
                        eventConDocLinkMap.put(conDocLink.LinkedEntityId,conDocIdSet);
                    }
                    else{
                        eventConDocLinkMap.get(conDocLink.LinkedEntityId).add(conDocLink.ContentDocumentId);
                    }
                    contentDocIdSet.add(conDocLink.ContentDocumentId);
                }
                conVersionList = [select Id, ContentDocumentId from ContentVersion where ContentDocumentId in : contentDocIdSet];

                for(ContentVersion conV : conVersionList)
                {
                    ContentVersionMap.put(conV.ContentDocumentId,conV);
                }
            }
            for(ASI_CRM_EVENTCapture__c eventCapture2: eventList)
            {
                eventWithPhoto eWP = new eventWithPhoto();
                eWP.eventId = eventCapture2.id;
                eWP.Name = eventCapture2.Name;
                eWP.ASI_CRM_MY_PRMorCompetitor = eventCapture2.ASI_CRM_MY_PRMorCompetitor__c;
                if(eventConDocLinkMap.containskey(eventCapture2.id))
                {
                    for(id docID : eventConDocLinkMap.get(eventCapture2.id))
                    {
                        if(ContentVersionMap.containskey(docID))
                        {
                            eWP.conVList.add(ContentVersionMap.get(docID));
                        }

                    }
                }
                switch on eWP.conVList.size(){
                    when 1 {
                        eWP.hasPhoto0 = true;
                        eWP.hasPhoto1 = false;
                        eWP.hasPhoto2 = false;
                        eWP.Photo0 = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + eWP.conVList[0].Id + ');'; 
                    }
                    when 2 {
                        eWP.hasPhoto0 = true;
                        eWP.hasPhoto1 = true;
                        eWP.hasPhoto2 = false;
                        eWP.Photo0 = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + eWP.conVList[0].Id + ');'; 
                        eWP.Photo1 = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + eWP.conVList[1].Id + ');'; 
                    }
                    when 3 {
                        eWP.hasPhoto0 = true;
                        eWP.hasPhoto1 = true;
                        eWP.hasPhoto2 = true;
                        eWP.Photo0 = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + eWP.conVList[0].Id + ');'; 
                        eWP.Photo1 = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + eWP.conVList[1].Id + ');'; 
                        eWP.Photo2 = 'background-repeat: no-repeat;background-position: center center;background-size: cover; background-image: url(/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB120BY90&versionId=' + eWP.conVList[2].Id + ');'; 
                    }
                    when else {
                        eWP.hasPhoto0 = false;
                        eWP.hasPhoto1 = false;
                        eWP.hasPhoto2 = false;
                    }
                }
                eventWithPhotoList.add(eWP);
            }
        }
        return eventWithPhotoList;
    }


    @AuraEnabled
    public static ASI_CRM_EVENTCapture__c createEventCapture(String  eventCaptureJson) 
    {
        system.debug('Start function');
        system.debug(eventCaptureJson);

        ASI_CRM_EVENTCapture__c eventCapture = (ASI_CRM_EVENTCapture__c) 
        JSON.deserialize(eventCaptureJson, ASI_CRM_EVENTCapture__c.class);
        system.debug('Start deserialize');
        system.debug(eventCapture);
        eventCapture.ASI_CRM_MY_PRMorCompetitor__c = eventCapture.ASI_CRM_MY_PRMorCompetitor__c == ''?
                                                        null : eventCapture.ASI_CRM_MY_PRMorCompetitor__c;
        eventCapture.ASI_CRM_MY_TypeActivation__c = eventCapture.ASI_CRM_MY_TypeActivation__c == ''?
                                                        null : eventCapture.ASI_CRM_MY_TypeActivation__c;

        eventCapture.RecordTypeId = Global_RecordTypeCache.getRtId(ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_EventRTypeAPI__c);

        insert eventCapture;
        return eventCapture;
    }

    @AuraEnabled
    public static String getSubBrandRecordType() {
        String query = 'RecordTypeId = \''+ Global_RecordTypeCache.getRtId(ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_SubBrandRTypeAPI__c) + '\'';
        return query;
    }

    @AuraEnabled
    public static List<ASI_MFM_Sub_brand__c> getSubBrandList(String Name) {
        String nameForSearch = '%'+Name+'%';
        system.debug(ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_SubBrandRTypeAPI__c);
        String rtID = Global_RecordTypeCache.getRtId(ASI_CRM_VisitationRTypeMapping__c.getinstance().ASI_CRM_SubBrandRTypeAPI__c);
        List<ASI_MFM_Sub_brand__c> sbList = new List<ASI_MFM_Sub_brand__c>();
        
        sbList = [Select Id, Name from ASI_MFM_Sub_brand__c where Name like: nameForSearch and RecordTypeId =: rtID limit 20];
        system.debug(nameForSearch);
        system.debug(rtID);
        system.debug(sbList);
        return sbList;
    }

    @AuraEnabled
    public static ASI_CRM_EVENTCapture__c updateEventCapture(String  eventCaptureJson) 
    {
        system.debug('Start function');
        system.debug(eventCaptureJson);

        ASI_CRM_EVENTCapture__c eventCapture = (ASI_CRM_EVENTCapture__c) 
        JSON.deserialize(eventCaptureJson, ASI_CRM_EVENTCapture__c.class);
        system.debug('Start deserialize');
        system.debug(eventCapture);
        eventCapture.ASI_CRM_MY_PRMorCompetitor__c = eventCapture.ASI_CRM_MY_PRMorCompetitor__c == ''?
                                                        null : eventCapture.ASI_CRM_MY_PRMorCompetitor__c;
        eventCapture.ASI_CRM_MY_TypeActivation__c = eventCapture.ASI_CRM_MY_TypeActivation__c == ''?
                                                        null : eventCapture.ASI_CRM_MY_TypeActivation__c;

        update eventCapture;
        return eventCapture;
    }

    @AuraEnabled
    public static eventWithPhotoForEdit getEventCapture(String  recordId) 
    {
        set<id> eventIdSet = new set<id>();
        set<id> contentDocIdSet = new set<id>();
        eventWithPhotoForEdit eventWithPhoto = new eventWithPhotoForEdit();
        List<ASI_CRM_EVENTCapture__c> eventList = new List<ASI_CRM_EVENTCapture__c>();
        List<ContentDocumentLink> conDocLinkList = new List<ContentDocumentLink>();
        List<ContentVersion> conVersionList = new List<ContentVersion>();
        Map<id, set<id>> eventConDocLinkMap = new Map<id, set<id>>();


        eventWithPhoto.currentEvent = [select id, Name, ASI_CRM_MY_ActivationEndDate__c,ASI_CRM_MY_ActivationEndTime__c
                                        ,ASI_CRM_MY_ActivationStartDate__c,ASI_CRM_MY_ActivationStartTime__c,ASI_CRM_MY_Brand__c
                                        ,ASI_CRM_MY_SeeSameEvent__c,ASI_CRM_MY_MoreActivation__c,ASI_CRM_MY_InitiatedOutlet__c
                                        ,ASI_CRM_MY_PRMorCompetitor__c,ASI_CRM_MY_NumberBAs__c,ASI_CRM_MY_Outlet__c,ASI_CRM_MY_PromotionMechanics__c
                                        ,ASI_CRM_MY_Remarks__c,ASI_CRM_MY_Subbrand__c,ASI_CRM_MY_BrandOther__c,ASI_CRM_MY_TypeActivation__c
                                        ,ASI_CRM_MY_TypeOther__c,ASI_CRM_MY_VisitationPlanDetail__c,ASI_CRM_MY_WhereActivation__c
                                        ,ASI_CRM_MY_Subbrand__r.Name
                                        from ASI_CRM_EVENTCapture__c where id =: recordId];


            conDocLinkList =[select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId =: eventWithPhoto.currentEvent.id];

            if(conDocLinkList != null && conDocLinkList.size() > 0)
            {
                for(ContentDocumentLink conDocLink :conDocLinkList)
                {
                    contentDocIdSet.add(conDocLink.ContentDocumentId);
                }
                eventWithPhoto.conVList = [select Id, ContentDocumentId from ContentVersion where ContentDocumentId in : contentDocIdSet order by Createddate];
            }
            

        system.debug(eventWithPhoto);
            
        return eventWithPhoto;
    }

    public class visitationPlanDetail {
        @AuraEnabled 
        public List<Note> noteList {get; set;}
        @AuraEnabled 
        public ASI_HK_CRM_Visitation_Plan_Detail__c currentVisitationPlanDetail {get; set;}
        @AuraEnabled 
        public ASI_CRM_VisitationPlanSetting__c  taskSetting  {get; set;}
        @AuraEnabled 
        public boolean isQVAP_Done {get;set;}
        @AuraEnabled 
        public boolean isToday {get;set;}
        @AuraEnabled 
        public boolean isRSP_Done {get;set;}
        @AuraEnabled 
        public boolean isIOT_Done {get;set;}
        @AuraEnabled 
        public boolean isEvent_Done {get;set;}
        @AuraEnabled 
        public List<ContentVersion> conVList {get;set;}
        @AuraEnabled 
        public String custAddress { get;set; }
        @AuraEnabled 
        public String custPhone { get;set; }
        
        public visitationPlanDetail() {
            this.currentVisitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
            this.noteList = new List<Note>();
            this.taskSetting = ASI_CRM_VisitationPlanSetting__c.getinstance();
            this.isToday = false;
            this.conVList = new List<ContentVersion>();
        }
        
    }

    public class visitationPlanDetail_QVAP {
        @AuraEnabled 
        public ASI_HK_CRM_Visitation_Plan_Detail__c currentVisitationPlanDetail {get; set;}
        @AuraEnabled 
        public list<String>  bottleLabel  {get; set;}
        @AuraEnabled
        public list<String> custodyCondition {get;set;}
        @AuraEnabled
        public list<String> outletType {get;set;}
        @AuraEnabled
        public List<String> ownActivations {get;set;}
        @AuraEnabled
        public List<String> topOfStaffMind {get;set;}
        @AuraEnabled
        public List<String> familiarWithPRM {get;set;}
        
        public visitationPlanDetail_QVAP() {
            this.currentVisitationPlanDetail = new ASI_HK_CRM_Visitation_Plan_Detail__c();
            this.bottleLabel = new list<String>();
            this.custodyCondition = new list<String>();
            this.outletType = new List<String>();
            this.ownActivations = new List<String>();
            this.topOfStaffMind = new List<String>();
            this.familiarWithPRM = new List<String>();
        }
        
    }

    public class eventWithPhoto {
        @AuraEnabled
        public String eventId {get;set;}
        @AuraEnabled
        public String ASI_CRM_MY_PRMorCompetitor {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Boolean hasPhoto0 {get;set;}
        @AuraEnabled
        public Boolean hasPhoto1 {get;set;}
        @AuraEnabled
        public Boolean hasPhoto2 {get;set;}
        @AuraEnabled
        public String Photo0 {get;set;}
        @AuraEnabled
        public String Photo1 {get;set;}
        @AuraEnabled
        public String Photo2 {get;set;}
        public List<ContentVersion> conVList {get;set;}

        public eventWithPhoto() {
            this.conVList = new List<ContentVersion>();
            this.hasPhoto0 = false;
            this.hasPhoto1 = false;
            this.hasPhoto2 = false;
            this.Photo0 = '';
            this.Photo1 = '';
            this.Photo2 = '';
        }
    }

    public class eventWithPhotoForEdit {
        @AuraEnabled
        public ASI_CRM_EVENTCapture__c currentEvent {get;set;}
        @AuraEnabled
        public List<ContentVersion> conVList {get;set;}

        public eventWithPhotoForEdit() {
            this.currentEvent = new ASI_CRM_EVENTCapture__c();
            this.conVList = new List<ContentVersion>();

        }
    }
    
    @AuraEnabled
    public static void deletePhoto(String recordId)  {
        List<ContentDocument> ConD = [select Id from ContentDocument where Id =: recordId];
        delete ConD;
    }
    
}