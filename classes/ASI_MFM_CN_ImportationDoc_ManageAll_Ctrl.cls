Global with Sharing class ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl {

    public String pageId {Get; Set;}
    public ASI_MFM_Importation_Document__c  importDoc {Get; Set;}
    
    //----------
    public String docTypePicklist {Get; Set;}
    public String docYearPicklist {Get; Set;}
    public String replacePicklist {Get; Set;}
    public String govProofPicklist {Get; Set;}
    public String acceptPricePicklist {Get; Set;}
    
    public ASI_MFM_CN_ImportationDoc_ManageAll_Ctrl(ApexPages.StandardSetController stdSetController){
        init();
    }
    
    public void init(){
        pageId = ApexPages.currentPage().getParameters().get('id');
        importDoc = [SELECT id, ASI_MFM_Request_Purpose__c, ASI_MFM_Region__c
                     , ASI_MFM_Status__c
                     FROM ASI_MFM_Importation_Document__c
                     WHERE ID = :pageId];
        
        docTypePicklist = getPicklistHtmlOption(ASI_MFM_Importation_Document_Detail__c.ASI_MFM_Document_Type__c.getDescribe(), '--None--');
        docYearPicklist = getPicklistHtmlOption(ASI_MFM_Importation_Document_Detail__c.ASI_MFM_Required_Documents_Year__c.getDescribe(), '--None--');
        replacePicklist = getPicklistHtmlOption(ASI_MFM_Importation_Document_Detail__c.ASI_MFM_Possible_to_Replace__c.getDescribe(), '--None--');
        govProofPicklist = getPicklistHtmlOption(ASI_MFM_Importation_Document_Detail__c.ASI_MFM_Gov_Proof__c.getDescribe(), '--None--');
		acceptPricePicklist = getPicklistHtmlOption(ASI_MFM_Importation_Document_Detail__c.ASI_MFM_Accept_Price__c.getDescribe(), '--None--');
    }
    
	public static String getPicklistHtmlOption(Schema.DescribeFieldResult F, String firstOption) {
        String result = '';
        if (firstOption != '') {
            result = '<option value="">'+firstOption+'</option>';
        }
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(Schema.PicklistEntry entry : P){
			result += '<option value="' + entry.getValue() + '">' + entry.getLabel() + '</option>';
        }
        return result;
    }
    
    @remoteAction
    Global static List<ASI_MFM_SKU_Code__c> getAllSKU(){
        
        String json = '';
        
        List<ASI_MFM_SKU_Code__c> sku = new List<ASI_MFM_SKU_Code__c>([SELECT id, name
                                                                       , ASI_MFM_SKU_Code__c 
                                                                       , ASI_FOC_SKU_Chinese_Description__c
                                                                       , ASI_FOC_Packing_Description__c
                                                                       FROM ASI_MFM_SKU_Code__c 
                                                                       WHERE RecordType.DeveloperName Like 'ASI_FOC_CN_SKU']);
        
        Return sku;
    }
    
    @remoteAction
    Global static List<documentLine> documentLine(String headerId){
        
        if(headerId != '' && headerId != Null){
            List<documentLine> docLineClass = new List<documentLine>();
            
            for(ASI_MFM_Importation_Document_Detail__c  obj : [SELECT id, ASI_MFM_Importation_Document__c, ASI_MFM_SKU_Code__c, ASI_MFM_Document_Type__c, ASI_MFM_Required_Documents_Year__c
                                                               , ASI_MFM_Contract_Number__c, ASI_MFM_Use_of_Document__c, ASI_MFM_Possible_to_Replace__c, ASI_MFM_Gov_Proof__c, ASI_MFM_Accept_Price__c
                                                               , ASI_MFM_SKU_Code__r.Name, ASI_MFM_Remarks__c, ASI_MFM_SKU_Code__r.ASI_FOC_SKU_Chinese_Description__c
                                                               , ASI_MFM_SKU_Code__r.ASI_FOC_Packing_Description__c
                                                               FROM ASI_MFM_Importation_Document_Detail__c  
                                                               WHERE ASI_MFM_Importation_Document__c  = :headerId]){
                                                                   documentLine tmp = new documentLine();
                                                                   tmp.lineId 		 = obj.id;
                                                                   tmp.isDelete 		 = false;
                                                                   tmp.remark			 = obj.ASI_MFM_Remarks__c != Null ? obj.ASI_MFM_Remarks__c : '';
                                                                   tmp.skuCode 		 = obj.ASI_MFM_SKU_Code__r.name;
                                                                   tmp.skuId 			 = obj.ASI_MFM_SKU_Code__c != Null ? obj.ASI_MFM_SKU_Code__c : '';
                                                                   tmp.docType 		 = obj.ASI_MFM_Document_Type__c != Null ? obj.ASI_MFM_Document_Type__c : '';
                                                                   tmp.docYear 		 = obj.ASI_MFM_Required_Documents_Year__c != Null ? obj.ASI_MFM_Required_Documents_Year__c : '';
                                                                   tmp.contractNum 	 = obj.ASI_MFM_Contract_Number__c != Null ? obj.ASI_MFM_Contract_Number__c : '';
                                                                   tmp.useOfDoc 		 = obj.ASI_MFM_Use_of_Document__c != Null ? obj.ASI_MFM_Use_of_Document__c : '';
                                                                   tmp.possibleReplace = obj.ASI_MFM_Possible_to_Replace__c != Null ? obj.ASI_MFM_Possible_to_Replace__c : '';
                                                                   tmp.govProof 		 = obj.ASI_MFM_Gov_Proof__c != Null ? obj.ASI_MFM_Gov_Proof__c : '';
                                                                   tmp.acceptPrice 		 = obj.ASI_MFM_Accept_Price__c != Null ? obj.ASI_MFM_Accept_Price__c : '';
                                                                   tmp.skuDescription	 = (obj.ASI_MFM_SKU_Code__r.ASI_FOC_SKU_Chinese_Description__c != Null ? obj.ASI_MFM_SKU_Code__r.ASI_FOC_SKU_Chinese_Description__c : '') + ' (' + (obj.ASI_MFM_SKU_Code__r.ASI_FOC_Packing_Description__c != Null ? obj.ASI_MFM_SKU_Code__r.ASI_FOC_Packing_Description__c : '') + ')';
                                                                   docLineClass.add(tmp);
                                                 }
            return docLineClass;
        }
        return Null;
    }
    
    @remoteAction
    Global static String saveDocumentLine(List<documentLine> upsertList, List<documentLine> deleteList, String headerId){
        
		String errorMsg = '';
        Boolean hasError = false;
        List<ASI_MFM_Importation_Document_Detail__c > deleteLine = new List<ASI_MFM_Importation_Document_Detail__c>();
        List<ASI_MFM_Importation_Document_Detail__c > upsertLine = new List<ASI_MFM_Importation_Document_Detail__c>();
        
        if(deleteList.size() > 0){
            set<String> idSet = new Set<String>();
            for(documentLine deleteitem : deleteList){
                if(!idSet.contains(deleteitem.lineId)){
                    deleteLine.add(new ASI_MFM_Importation_Document_Detail__c(id = deleteitem.lineId));
                    idSet.add(deleteitem.lineId);
                }
            }
        }
        
		if(upsertList.size() > 0){
            set<String> idSet = new Set<String>();
			for(documentLine upsertItem : upsertList){
                
                if(checkIfNull(upsertItem.skuId) || checkIfNull(upsertItem.docType) || checkIfNull(upsertItem.docYear) || checkIfNull(upsertItem.useOfDoc) || checkIfNull(upsertItem.possibleReplace) || checkIfNull(upsertItem.govProof) || checkIfNull(upsertItem.acceptPrice)){
                    hasError = True;
                    errorMsg = 'Please input all mandatory fields.';
                }
                
                if(!idSet.contains(upsertItem.lineId) || checkIfNull(upsertItem.lineId)){
                    upsertLine.add(new ASI_MFM_Importation_Document_Detail__c (id = (upsertItem.lineId == '' ? Null : upsertItem.lineId)
                                                                               , ASI_MFM_Importation_Document__c  = headerId
                                                                               , ASI_MFM_SKU_Code__c  = upsertItem.skuId
                                                                               , ASI_MFM_Document_Type__c  = upsertItem.docType
                                                                               , ASI_MFM_Required_Documents_Year__c  = upsertItem.docYear
                                                                               , ASI_MFM_Contract_Number__c  = upsertItem.contractNum
                                                                               , ASI_MFM_Use_of_Document__c  = upsertItem.useOfDoc
                                                                               , ASI_MFM_Possible_to_Replace__c  = upsertItem.possibleReplace
                                                                               , ASI_MFM_Gov_Proof__c  = upsertItem.govProof
                                                                               , ASI_MFM_Accept_Price__c = upsertItem.acceptPrice
                                                                               , ASI_MFM_Remarks__c = upsertItem.remark
                                                                               , recordTypeId = Global_RecordTypeCache.getRtId('ASI_MFM_Importation_Document_Detail__cASI_MFM_CN_Importation_Document_Detail')
                                                                              ));
                               
                }
                idSet.add(upsertItem.lineId);
            }
        }
        
        if(hasError){
            Return errorMsg;
        }
        
        if(deleteLine.size() > 0){
            
            try{
                delete deleteLine;
            }catch(dmlException dmle){
                
                String e = '';
                for(integer i = 0; i < dmle.getNumDml() ; i++)
                    e += 'Row ' + (dmle.getDmlIndex(i) + 1) + ': ' + dmle.getDmlMessage(i) + '\n';
                
                return e;
            }
        }
        
        if(upsertLine.size() > 0){
            try{
                upsert upsertLine;
            }catch(dmlException dmle){
                
                String e = '';
                for(integer i = 0; i < dmle.getNumDml() ; i++)
                    e += 'Row ' + (dmle.getDmlIndex(i) + 1) + ': ' + dmle.getDmlMessage(i) + '\n';
                
                return e;
            }
        }

        return 'Success';
    }
    
    Private Static Boolean checkIfNull(String value){
        if(value == Null || value == '')
            Return True;
        else
            Return False;
    }
    
    Global Class documentLine{
        Global String skuCode {Get; Set;}
        Global String skuId {Get; Set;}
        Global String docType {Get; Set;}
        Global String docYear {Get; Set;}
        Global String contractNum {Get; Set;}
        Global String useOfDoc {Get; Set;}
        Global String possibleReplace {Get; Set;}
        Global String govProof {Get; Set;}
        Global String acceptPrice {Get; Set;}
        Global String lineId {Get; Set;}
        Global String remark {Get; Set;}
        Global String skuDescription {Get; Set;}
        Global Boolean isDelete {Get; Set;}
    }
}