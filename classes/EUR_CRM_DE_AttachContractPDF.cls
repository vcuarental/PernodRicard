/*
    Auto Attach Contract PDF to Notes and Attachment if 
    all of the following conditions are met.
        1. Trigger Action is After Update
        2. Contract Record Type = DE
        3. EUR_CRM_Active__c changes from false to true
        4. EUR_CRM_Total_Contract_Value__c is Less than or equal to 3500 €
        5. EUR_CRM_Contract_Type__c is Standard Contract
    if EUR_CRM_Contract_Sub_Type__c is Basic Contract
        use the EUR_CRM_DE_ContractPDF_Basic VF page
    else if EUR_CRM_Contract_Sub_Type__c is Concept Contract
        use the EUR_CRM_DE_ContractPDF_Concept VF page
    to generate the PDF
    
*/


public without sharing class EUR_CRM_DE_AttachContractPDF extends EUR_CRM_TriggerAbstract{

    public EUR_CRM_DE_AttachContractPDF(){
        super('EUR_CRM_DE_AttachContractPDF');
    }
    public static String BASIC_CONTRACT = 'Basic Contract';
    public static String CONCEPT_CONTRACT = 'Concept Contract';
    public static String STANDARD_CONTRACT = 'Standard Contract';
    public static final Decimal CONTRACT_VALUE_THRESHOLD = 3500;
    public final static Set<String> validContractRecordTypes = new Set<String>{
            'EUR_DE_Contract'};

    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){

        List<Recordtype> contractRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Contract__c');
        Map<Id,Recordtype> contractRecordTypeMap = new Map<Id,Recordtype>();

        for(Recordtype rt : contractRecordTypes ){
            contractRecordTypeMap.put(rt.id,rt);
        }

        List<EUR_CRM_Contract__c> contracts = new List<EUR_CRM_Contract__c>();
        String contractIdString = '';
        for(EUR_CRM_Contract__c contract : (List<EUR_CRM_Contract__c>) sObjList){
            EUR_CRM_Contract__c oldContract = (EUR_CRM_Contract__c) oldMap.get(contract.id);
            //if(contract.EUR_CRM_Total_Contract_Value__c <= CONTRACT_VALUE_THRESHOLD
            //System.Debug('@@Contract Status(New/Old/Type/Total):' + contract.EUR_CRM_Status__c + '|' + oldContract.EUR_CRM_Status__c + '|' + contract.EUR_CRM_Contract_Type__c + '|' + contract.EUR_CRM_DE_Actual_Contract_Total__c);
            //System.Debug('@@contractRecordTypeMap:'+contractRecordTypeMap.get(contract.recordTypeId).developername);
            //System.Debug('@@validContractRecordTypes:'+validContractRecordTypes.contains(contractRecordTypeMap.get(contract.recordTypeId).developername));
            if(contract.EUR_CRM_DE_Actual_Contract_Total__c <= CONTRACT_VALUE_THRESHOLD
                    && contract.EUR_CRM_Contract_Type__c == STANDARD_CONTRACT
                    && validContractRecordTypes.contains(contractRecordTypeMap.get(contract.recordTypeId).developername)
                    && contract.EUR_CRM_Status__c != oldContract.EUR_CRM_Status__c
                    && contract.EUR_CRM_Status__c == 'Approved'
                    //&& contract.EUR_CRM_Status__c == 'Activated'
                    //&& contract.EUR_CRM_Active__c
                    //&& !oldContract.EUR_CRM_Active__c
                    ){
                //System.Debug('@@Add Contract');
                contracts.add(contract);
                // contractIdString += contract.id;
            }
        }

        //System.debug('$$TEST');
        if(contracts.size() > 0){
            Set<Id> contractIdSet = new Set<Id>();
            for(EUR_CRM_Contract__c contract : contracts) {
//                EUR_CRM_DE_AttachContractPDFContent.attachPDFToContractAsync(contract.Id, UserInfo.getSessionId());
                contractIdSet.add(contract.Id);
            }
            List<EUR_CRM_Contract__c> contractUpdateList = [SELECT Id,EUR_CRM_Status__c FROM EUR_CRM_Contract__c WHERE Id in :contractIdSet];
            for(EUR_CRM_Contract__c contract : contractUpdateList) {
                contract.EUR_CRM_Status__c = 'Activated';
                contract.EUR_CRM_Active__c = true;
                contract.EUR_CRM_Contract_Signed__c = true;
            }
            update contractUpdateList;
            //savePDF(contracts);
            //attachPDF(formatContractIds(contracts),UserInfo.getSessionId()); 
        }
    }
    //@future (callout=true)
    public static void attachPDF(String contractIdString,String userSessionId){
        EUR_CRM_MassUploadPDFAttachment batch = new EUR_CRM_MassUploadPDFAttachment(contractIdString);
        batch.sessionId = userSessionId;
        Database.executeBatch(batch, 1);
    }

    public static List<EUR_CRM_Contract__c> retrieveContracts(String contractIdString){
        Set<String> contractIds = new Set<String>();

        for(String s : contractIdString.split(','))
            contractIds.add(s);
        return [select EUR_CRM_Contract_Copy_File_Name__c, Name, Id from EUR_CRM_Contract__c where id in: contractIds];
    }
    public static String formatContractIds(List<EUR_CRM_Contract__c> contracts){
        String ids = '';

        for(Integer i = 0; i < contracts.size() ; i++){
            EUR_CRM_Contract__c contract = contracts.get(i);
            ids += contract.id;
            if(i < contracts.size() - 1)
                ids +=',';
        }
        return ids;
    }
/*
    public static List<Attachment> checkAndRemoveContractAttachments(List<EUR_CRM_Contract__c> contracts){
      
        Set<String> pdfNames = new Set<String>(); 
        pdfNames.add('CONTRACT_PDF_NO_NAME.pdf');
           Set<String> contractIds = new Set<String>(); 
      
        system.debug('### pdfNames' + pdfNames);
        List<Attachment> attachments = [select id from Attachment where ParentId in: contractIds and name in: pdfNames];
       // if(attachments != null && attachments.size() > 0)
       return attachments;
    }
*/
/*
    public static void  savePDF(List<EUR_CRM_Contract__c> contracts){        
        List<Attachment> attachments = new List<Attachment>();
        for(EUR_CRM_Contract__c contract : contracts){
            
            Id contractId = contract.id;
            
            PageReference pdf = null;
            
            if(contract.EUR_CRM_Contract_Sub_Type__c == BASIC_CONTRACT){
                pdf = Page.EUR_CRM_DE_ContractPDF_Basic;     
            }else if(contract.EUR_CRM_Contract_Sub_Type__c == CONCEPT_CONTRACT){
                pdf = Page.EUR_CRM_DE_ContractPDF_Concept;
            }else{
                return;
            } 
            pdf.getParameters().put('id',contractId);
            Attachment attach = new Attachment(); 
            Blob body;
            String fileName = contract.EUR_CRM_Contract_Copy_File_Name__c == null ? 'CONTRACT_PDF_NO_NAME' : contract.EUR_CRM_Contract_Copy_File_Name__c ;
            try {
                body = pdf.getContent(); 
            } catch (VisualforceException e) {
                body = Blob.valueOf('Some Text');
            } 
            attach.Body = body;
            attach.Name = fileName + '.pdf';
            attach.IsPrivate = false; 
            attach.ParentId = contractId; 
            attachments.add(attach);
        }
        insert attachments;
    } 
*/
}