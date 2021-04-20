@RestResource(UrlMapping='/ASI_MFM_HK_PO_Webservice_AmountRelease/*')
Global without Sharing class ASI_MFM_HK_PO_Webservice_AmountRelease {

    //{\"poId\":\"a9NM00000004EbC\"}
    @HttpPost
    Global Static void getPORecord(){        
        List<ASI_TnE_ClaimHeader__c> tneHeader = new List<ASI_TnE_ClaimHeader__c>();
        Set<String> concurIdSet = new Set<String>();
        restRequest req = restcontext.request;
        restResponse res = RestContext.response;
        
        system.debug('Request Body: ' + req.requestBody.toString());
        
        List<detailDataClass> transactionsList = (List<detailDataClass>)system.JSON.deserialize(req.requestBody.toString(), List<detailDataClass>.class);
        parametersClass parameterList = new parametersClass();
        parameterList.transactions = transactionsList;
            
        replaceNullValue(parameterList, concurIdSet);
        
        res.addHeader('Content-Type','application/json');
        
        Savepoint sp = Database.setSavepoint();
        
        tneHeader = new List<ASI_TnE_ClaimHeader__c>([SELECT id, ASI_TnE_Status__c
                                                      , ASI_TnE_3rd_Party__c
                                                      FROM ASI_TnE_ClaimHeader__c
                                                      WHERE (ASI_TnE_KR_External_ID__c IN : concurIdSet
                                                             OR (ASI_TnE_Status__c = 'Draft'
                                                                 AND ASI_TnE_KR_External_ID__c != Null
                                                                 AND ASI_TnE_KR_External_ID__c != '')
                                                            )
                                                      AND RecordTypeId = : Global_RecordTypeCache.getRtId('ASI_TnE_ClaimHeader__cASI_TnE_HK_Claim_Header')
                                                     ]);
        
        for(ASI_TnE_ClaimHeader__c obj : tneHeader){
            obj.ASI_TnE_Status__c = 'Draft';
            obj.ASI_TnE_3rd_Party__c = False;
        }
        try{
            
            Update tneHeader;
            Delete tneHeader;
            
        }catch(dmlException dmle){
            
            Database.rollback(sp);
            parameterList.success = False;
            parameterList.returnMsg = 'Unable to delete T&E Claim in SFDC, Please contact admin, Error Message: ' + dmle.getMessage();
            res.responseBody = blob.valueOf(JSON.serialize(parameterList));
            Return;
        }
        
        res.responseBody = blob.valueOf(JSON.serialize(parameterList));
        
        system.debug('Response Body: ' + res.responseBody.toString());
        return;
    }
    
    Private Static Void replaceNullValue(parametersClass parameterList, Set<String> concurIdSet){
        
        parameterList.concurReportId = parameterList.concurReportId != Null ? parameterList.concurReportId : '';
        parameterList.currentUser = parameterList.currentUser != Null ? parameterList.currentUser : '';
        parameterList.success = parameterList.success != Null ? parameterList.success : True;
        parameterList.returnMsg = parameterList.returnMsg != Null ? parameterList.returnMsg : '';
        parameterList.transactions = parameterList.transactions != Null ? parameterList.transactions : new List<detailDataClass>();
        
        for(detailDataClass obj : parameterList.transactions){
            
            obj.returnMsg = obj.returnMsg != Null ? obj.returnMsg : '';
            obj.concurReportId = obj.concurReportId != Null ? obj.concurReportId : '';
            obj.success = obj.success != Null ? obj.success : True;
            /*obj.poNumber = obj.poNumber != Null ? obj.poNumber : '';
            obj.CAPEXPlanNumber = obj.CAPEXPlanNumber != Null ? obj.CAPEXPlanNumber : '';
            obj.concurLineId = obj.concurLineId != Null ? obj.concurLineId : '';
            obj.fxRate = obj.fxRate != Null ? obj.fxRate : 1;
            obj.expenseAmount = obj.expenseAmount != Null ? obj.expenseAmount : 0;
            */
            
            if(obj.concurReportId != Null && obj.concurReportId != '')
                concurIdSet.add(obj.concurReportId);
        }
    }
    
    Public class parametersClass{
        
        Public String concurReportId;
        Public String currentUser;
        Public String returnMsg;
        Public Boolean success; // allOrNone;
        Public List<detailDataClass> transactions = new List<detailDataClass>();
    }
    
    Public Class detailDataClass{
        
        Public String returnMsg;
        Public String concurReportId;
        Public Boolean success;
        /*Public String poNumber;
        Public String concurLineId;
        Public String CAPEXPlanNumber;
        Public Decimal fxRate;
        Public Decimal expenseAmount;
        Public Boolean success;
        Public String expenseType;
        Public String recordNumber;*/
    }
}