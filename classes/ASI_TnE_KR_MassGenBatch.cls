global class ASI_TnE_KR_MassGenBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    String detailYear;
    String detailMonth;
    Id OwnerVal = null;
    Id PayeeVal = null;
    
    public String TnEMessage {get;set;}
    public Id claimHeaderRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_KR_TnE');
    public Id claimDetailRecordType = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimDetail__cASI_TnE_KR_Claim_Detail');
    public Id ClaimHeaderRecordTypeAnP = Global_RecordTypeCache.getRTId('ASI_TnE_ClaimHeader__cASI_TnE_KR_AnP');
    public Id userId = UserInfo.getUserId();
    private List<String> noRecordMap = new List<String>();//list of card num which does not have employee name in card mapping object
    private List<String> duplicateRec = new List<String>();
    Map<Id,ASI_TnE_ClaimHeader__c> delHeadMap = new Map<Id,ASI_TnE_ClaimHeader__c>();
    ASI_TnE_Mass_Upload_Log__c uploadLog;
    global ASI_TnE_KR_MassGenBatch(ASI_TnE_Mass_Upload_Log__c uploadLog)
    {
        this.uploadLog = uploadLog;
        TnEMessage ='';
	}

    global database.querylocator start(Database.BatchableContext BC)
    {
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator
            ([SELECT
              ASI_TnE_Transaction_Description__c,
              ASI_TnE_KR_Year__c,
              ASI_TnE_KR_Month__c,
              ASI_TnE_Card_Number__c,
              ASI_TnE_Charge_Date__c,
              ASI_TnE_Charge_Time__c,
              ASI_TnE_KR_Approval_Number__c,
              ASI_TnE_Full_Name__c,
              ASI_TnE_Business_Type__c, //20160804, edited by Leo, T&E upload update
              ASI_TnE_Business_Address__c,
              ASI_TnE_Amount__c 
              FROM ASI_TnE_Corp_Card_Statement_Upload__c 
              WHERE OwnerId =: userId 
              ORDER BY ASI_TnE_Card_Number__c ASC, ASI_TnE_Charge_Date__c ASC]);
    }
    
    // The executeBatch method is called for each chunk of records returned from start.    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<ASI_TnE_Corp_Card_Statement_Upload__c> cCardList = (List<ASI_TnE_Corp_Card_Statement_Upload__c>)scope;//card record in Temp card records
        Map<String, ASI_TnE_Corp_Card_Employee_Mapping__c> mapWithCardNum = new Map<String, ASI_TnE_Corp_Card_Employee_Mapping__c>();//map card num and card map object
        List<ASI_TnE_Corp_Card_Employee_Mapping__c> cardMapping = new List<ASI_TnE_Corp_Card_Employee_Mapping__c>//all card mapping record
            ([SELECT Id,
              ASI_TnE_Assistant_Name__c,
              ASI_TnE_Card_Number_1__c,
              ASI_TnE_Employee_Name__c,
              ASI_TnE_Employee_Name__r.ASI_KOR_Commission_Code__c, 
              ASI_TnE_KR_Card_Type__c
              FROM ASI_TnE_Corp_Card_Employee_Mapping__c 
              WHERE RecordType.DeveloperName =: 'TnE_KR_Corp_Card_Employee_Mapping' 
              AND ASI_TnE_Card_Number_1__c != null 
              AND ASI_TnE_Employee_Name__c != null]);
        
        for(ASI_TnE_Corp_Card_Employee_Mapping__c cardMap: cardMapping)//put a card mapping list to map
        {
            mapWithCardNum.put(cardMap.ASI_TnE_Card_Number_1__c,cardMap);
        }//end for

        Map<String, String> mapRecordExId = new Map<String, String>();//map card num and year,month - Temp card records
        
        for(ASI_TnE_Corp_Card_Statement_Upload__c cCard :cCardList)//loop Temp cad records
        {
            detailYear = cCard.ASI_TnE_KR_Year__c;
            detailMonth = cCard.ASI_TnE_KR_Month__c;
            mapRecordExId.put(cCard.ASI_TnE_Card_Number__c, detailMonth+'/'+detailYear);
        }//end for: loop temp card record
//---------------------------------------------------------------------------------------------------------------------------------------------//

//---------------------------------------------------------------------------------------------------------------------------------------------//        
        Map<String, String> duplicateHeader = new Map<String, String>();//list of duplicate claims
        Set<String>duplicateHeadId = new Set<String>();//set of duplicate claim headers id
        List<ASI_TnE_ClaimHeader__c> existingHeader = new List<ASI_TnE_ClaimHeader__c>
            ([Select Id, ASI_TnE_KR_External_ID__c From ASI_TnE_ClaimHeader__c WHERE RecordType.DeveloperName like 'ASI_TnE_KR%' AND ASI_TnE_KR_Year__c like: detailYear AND ASI_TnE_KR_Month__c like: detailMonth]);
        for(ASI_TnE_ClaimHeader__c cHeader :existingHeader)
        {
            if(cHeader.ASI_TnE_KR_External_ID__c != null && cHeader.ASI_TnE_KR_External_ID__c != '')
            {
                String tempCardNumber = cHeader.ASI_TnE_KR_External_ID__c.split('~')[0];//get existing header external id
                String tempStatementMonth = cHeader.ASI_TnE_KR_External_ID__c.split('~')[1];//get existing header external id
                if(mapRecordExId.get(tempCardNumber) != null && mapRecordExId.get(tempCardNumber) == tempStatementMonth)
                {
                    duplicateHeader.put(tempCardNumber,cHeader.ASI_TnE_KR_External_ID__c);
                    duplicateHeadId.add(cHeader.Id);
                }//end if: the card num does not have month value
            }//end if: header external id not null/blank
        }//end for: loop header record
        
//------------------------------------------------------------new claim header---------------------------------------------------------------------//        
        List<ASI_TnE_ClaimHeader__c> newHeaderList = new List<ASI_TnE_ClaimHeader__c>();//list of header which will be insert
        for(String cMap :mapRecordExId.keySet())
        {
            if(mapWithCardNum.get(cMap) != null && !duplicateHeader.containsKey(cMap))
            {
                if(mapWithCardNum.get(cMap).ASI_TnE_Assistant_Name__c != null)
                {
                    OwnerVal = mapWithCardNum.get(cMap).ASI_TnE_Assistant_Name__c;
                    PayeeVal = mapWithCardNum.get(cMap).ASI_TnE_Employee_Name__c;
                }
                else
                    PayeeVal = OwnerVal = mapWithCardNum.get(cMap).ASI_TnE_Employee_Name__c;
                ASI_TnE_ClaimHeader__c claim;
                
                if(mapWithCardNum.get(cMap).ASI_TnE_KR_Card_Type__c=='T&E Card')
                {
                    claim = new ASI_TnE_ClaimHeader__c(
                        OwnerId = OwnerVal,
                        ASI_TnE_KR_Payee__c = PayeeVal,
                        ASI_TnE_Status__c = 'Draft',
                        ASI_TnE_Date__c = system.today(),
                        ASI_TnE_KR_Credit_Card_No__c = cMap,
                        RecordTypeId = claimHeaderRecordType,
                        ASI_TnE_KR_Year__c = detailYear,
                        ASI_TnE_KR_Month__c = detailMonth,
                        ASI_TnE_KR_External_ID__c = cMap + '~' + mapRecordExId.get(cMap));
                }//end if: TnE card Header
                else
                {
                    claim = new ASI_TnE_ClaimHeader__c(
                        OwnerId = OwnerVal,
                        ASI_TnE_KR_Payee__c = PayeeVal,
                        ASI_TnE_Status__c = 'Draft',
                        ASI_TnE_KR_Credit_Card_No__c = cMap,
                        ASI_TnE_Date__c = system.today(),
                        RecordTypeId = ClaimHeaderRecordTypeAnP,
                        ASI_TnE_KR_Year__c = detailYear,
                        ASI_TnE_KR_Month__c = detailMonth,
                        ASI_TnE_KR_External_ID__c = cMap + '~' + mapRecordExId.get(cMap));
                }//end else: AnP card Header
                newHeaderList.add(claim);
            }
            else if(mapWithCardNum.get(cMap) == null)
            {
                noRecordMap.add(cMap);
            }//end else
        }//end for:loop claimDateMap.keySet
//---------------------------------------------------new claim header, not yet insert-----------------------------------------------------//
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        Set<String> claimHeaderId = new Set<String>();//set of header Id, for new insert header
        Set<String> detailExId = new Set<String>();//set of transaction num, used to check line item is created or not
        List<ASI_TnE_ClaimHeader__c> createdHeader = new List<ASI_TnE_ClaimHeader__c>();
        if(newHeaderList.size()>0 || duplicateHeader.size()>0) //if there are new header or existing header in list
        {
            try{
                if(newHeaderList.size() > 0) //if there are any new header
                {
                    results = database.insert(newHeaderList,true); //insert new header
                    for(Database.SaveResult res: results)
                    {
                        if(res.isSuccess())
                        {
                            claimHeaderId.add(res.getId()); //get back the header id, store in set
                        }//end if
                    }//end for
                }//end if
               
                if(claimHeaderId.size() > 0 || duplicateHeadId.size() > 0) //if there are new header or existing header in set
                {
                    Map<String, Id> claimHeaderMap = new Map<String, Id>(); //map to store header, key: card num
                    createdHeader = [Select id, ASI_TnE_KR_Credit_Card_No__c //select all new header and existing
                                     From ASI_TnE_ClaimHeader__c 
                                     Where (Id IN: claimHeaderId OR Id IN: duplicateHeadId)
                                     AND (recordTypeID =: claimHeaderRecordType OR recordTypeID =: claimHeaderRecordTypeAnP)];
                    
                    for(ASI_TnE_ClaimHeader__c cH :createdHeader)
                    {
                        claimHeaderMap.put(cH.ASI_TnE_KR_Credit_Card_No__c, cH.Id);
                    }//end for
                    
                    List<ASI_TnE_ClaimDetail__c> insertedDetail = new List<ASI_TnE_ClaimDetail__c> //select those created line item with new header or existing header
                        ([Select id, ASI_TnE_KR_Detail_External_ID__c 
                          From ASI_TnE_ClaimDetail__c 
                          Where (ASI_TnE_ClaimHeader__c IN: claimHeaderId OR ASI_TnE_ClaimHeader__c IN: duplicateHeadId)
                          AND recordTypeID =: claimDetailRecordType]);
                    for(ASI_TnE_ClaimDetail__c cD :insertedDetail)
                    {
                        detailExId.add(cD.ASI_TnE_KR_Detail_External_ID__c);
                    }//end for
                    
                    List<ASI_TnE_ClaimDetail__c> claimDetail = new List<ASI_TnE_ClaimDetail__c>();
                    if(!cCardList.isEmpty())
                    for(ASI_TnE_Corp_Card_Statement_Upload__c cCard :cCardList)
                    {
                        //check the card number has card mapping and has header and does not existing
                        if(mapWithCardNum.containsKey(cCard.ASI_TnE_Card_Number__c) && claimHeaderMap.containsKey(cCard.ASI_TnE_Card_Number__c) && !detailExId.contains(cCard.ASI_TnE_KR_Approval_Number__c))
                        {
                            Id ownerId = mapWithCardNum.get(cCard.ASI_TnE_Card_Number__c).ASI_TnE_Employee_Name__c;
                            Id claimId = claimHeaderMap.get(cCard.ASI_TnE_Card_Number__c);
                            //check the record is belongs to T&E
                            if(mapWithCardNum.get(cCard.ASI_TnE_Card_Number__c).ASI_TnE_KR_Card_Type__c == 'T&E Card')
                            {
                                ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
                                    ASI_TnE_ClaimHeader__c = claimId,
                                    recordTypeId = claimDetailRecordType,
                                    ASI_TnE_Receipt_Date__c = cCard.ASI_TnE_Charge_Date__c,
                                    ASI_TnE_KR_Receipt_Time__c = cCard.ASI_TnE_Charge_Time__c,
                                    ASI_TnE_KR_Business_Name__c = cCard.ASI_TnE_Full_Name__c,
                                    ASI_TnE_Currency__c = 'KRW',
                                    ASI_TnE_Receipt_Amount__c = cCard.ASI_TnE_Amount__c,
                                    ASI_TnE_FX_Rate__c = 1,
                                    ASI_TnE_Total_Number_Pax__c = 1,
                                    ASI_TnE_KR_Detail_External_ID__c = cCard.ASI_TnE_KR_Approval_Number__c,
                                    ASI_TnE_KR_Business_Address__c = cCard.ASI_TnE_Business_Address__c,
                                	ASI_TnE_KR_Business_Type__c = cCard.ASI_TnE_Business_Type__c); //20160804, edited by Leo, T&E upload update
                                claimDetail.add(detail);
                            }//end if: TnE detail
                            else
                            {
                                ASI_TnE_ClaimDetail__c detail = new ASI_TnE_ClaimDetail__c(
                                    ASI_TnE_ClaimHeader__c = claimId,
                                    recordTypeId = claimDetailRecordType,
                                    ASI_TnE_Receipt_Date__c = cCard.ASI_TnE_Charge_Date__c,
                                    ASI_TnE_KR_Receipt_Time__c = cCard.ASI_TnE_Charge_Time__c,
                                    ASI_TnE_KR_Business_Name__c = cCard.ASI_TnE_Full_Name__c,
                                    ASI_TnE_Currency__c = 'KRW',
                                    ASI_TnE_Receipt_Amount__c = cCard.ASI_TnE_Amount__c,
                                    ASI_TnE_FX_Rate__c = 1,
                                    ASI_TnE_Approved_Amount__c = 1, //added by Leo,01-06-2015
                                    ASI_TnE_KR_Detail_External_ID__c = cCard.ASI_TnE_KR_Approval_Number__c,
                                    ASI_TnE_KR_Business_Address__c = cCard.ASI_TnE_Business_Address__c,
                                	ASI_TnE_KR_Business_Type__c = cCard.ASI_TnE_Business_Type__c); //20160804, edited by Leo, T&E upload update
                                claimDetail.add(detail);
                            }//end else: AnP detail
                        }//end if
                        else if(detailExId.contains(cCard.ASI_TnE_KR_Approval_Number__c))//store duplicate transaction records
                        {
                            duplicateRec.add(cCard.ASI_TnE_KR_Approval_Number__c);
                        }//end else if
                    }//end for
                    if(claimDetail.size() > 0) //if any new line item created
                    {
                        insert claimDetail; //insert new line items
                    }//end if: if any claim detail needs to insert
                }//end if: claimHeaderId set || duplicateHeadId set has any records
                else
                {
                    TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Record(s) to Generate! </span></div>';
                }//end else: if there are no any new header or existing header in set
            }//end try
            catch(DmlException e)
            {
                TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate T&E Failed! </span></div>';
                TnEMessage += '<div style="color:red;">';
                for(integer j = 0;j < e.getNumDml(); j++)
                {
                    TnEMessage += 'Row ' + j + ': ' + e.getDmlMessage(j) + '\n';
                }//end for
                TnEMessage += '</div>';
            }//end catch
        }//end if: newHeaderList || duplicateHeader has any records
        else
        {
            TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/info16.png" style="vertical-align: middle;"/> <span style="color:blue; font-weight: bold; vertical-align: middle;"> No Record(s) to Generate! </span></div>';
        }
        
        if(createdHeader.size() >0)//store the header which created between progress
        {
            for(ASI_TnE_ClaimHeader__c cH :createdHeader)//store all the insert header in map
            {
                if(!delHeadMap.containsKey(cH.Id))
                {
                    delHeadMap.put(cH.Id, cH);
                }//end if
            }//end for
        }//end if
        
        //handle error msg
        if(noRecordMap.size() > 0){
            TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate T&E Failed! </span></div>';
            TnEMessage += '<div style="color:red;">'+noRecordMap.size()+' rows does not have any mapping records.<ul>';
            TnEMessage += '<div style="color:blue;">The following Card No. does not have a match on the employee mapping table.<ul>';
            for(String cn :noRecordMap){
                TnEMessage += '<li>' + cn + '</li>';
            }//end for
            TnEMessage += '</ul>Please add the mapping to generate T&E again.</div><br/><br/>';
        }
        if(duplicateRec.size() > 0){
            TnEMessage = '<div style="height: 25px;"><img src="/img/msg_icons/error16.png" style="vertical-align: middle;"/> <span style="color:red; font-weight: bold; vertical-align: middle;"> Generate T&E Failed! </span></div>';
            TnEMessage += '<div style="color:red;">'+duplicateRec.size()+' rows of duplicate records were found.<ul>';
            TnEMessage += '<div style="color:blue;">The following Transaction number below failed to generage T&E due to duplicate T&E detected.<ul>';
            for(String cn :duplicateRec){
                TnEMessage += '<li>' + cn + '</li>';
            }//end for
        }
    }//end method: excute 
    
    global void finish(Database.BatchableContext BC)
    {
        String msg ='';
        if(noRecordMap.size() > 0)//check if card is not exist
        {
            msg += TnEMessage;
            delete delHeadMap.values(); //rollback(?) created records
        }
        else if(duplicateRec.size() > 0)
        {
            msg += TnEMessage;
        }
        else
        {
            msg = 'success';
        }
        uploadLog.ASI_TnE_Error_Message__c = msg;
        update uploadLog;
        
        List<ASI_TnE_Corp_Card_Statement_Upload__c> delIntray = new List<ASI_TnE_Corp_Card_Statement_Upload__c>
                ([Select Id From ASI_TnE_Corp_Card_Statement_Upload__c Where OwnerId =: userId]);//get back all records in Intray Object, and clear the records
        if(delIntray.size() > 0)
        {
            delete delIntray;//clear Intray object records
        }//end if
    }//end method: finish
}