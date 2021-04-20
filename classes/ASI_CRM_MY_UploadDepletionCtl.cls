/*Filename:    ASI_CRM_MY_UploadDepletionCtl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     upload a CSV file which with Special Character using Apex into Salesforce
*
* ref: http://salesforce.stackexchange.com/questions/15621/how-to-upload-a-csv-file-which-with-special-character-using-apex-into-salesforce
*
* History
* -----------------------------------------------------------------------------
* 2014-12-23        daniel.wong@introv.com        Created
*/

public class ASI_CRM_MY_UploadDepletionCtl{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    public map<string, id> mapOfCustomerId = new map<string, id>();
    public map<string, id> mapSKU = new map<string, id>();
    
    String[] filelines = new String[]{};
    List<ASI_CRM_Depletion__c> sitetoupload;
    
    public set<date> setD = new set<date>();
    public map<string, ASI_CRM_Depletion__c> mapRecord = new map<string, ASI_CRM_Depletion__c>();
    
    public date getRecordDate(string strDate){ 
        //strDate = DD/MM/YY
        integer intY = integer.valueOf(strDate.split('/')[2]);
        integer intM = integer.valueOf(strDate.split('/')[1]);
        integer intD = integer.valueOf(strDate.split('/')[0]);
        
        date dateTemp = date.newInstance(intY, intM, intD);
        return dateTemp;
    }
    
    public map<string, ASI_CRM_Depletion__c> getMapRecord(set<date> setD){
        map<string, ASI_CRM_Depletion__c> mapRecordHeader = new map<string, ASI_CRM_Depletion__c>();
        
        List<ASI_CRM_Depletion__c> existingHeaders = new List<ASI_CRM_Depletion__c>();
        existingHeaders = [
            SELECT Id, ASI_CRM_Wholesaler__c, ASI_CRM_Customer__c, ASI_CRM_MY_SKU__c, ASI_CRM_Depletion_Year__c, ASI_CRM_Depletion_Month__c, ASI_CRM_Shipment_Date__c
            FROM ASI_CRM_Depletion__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_Depletion__cASI_CRM_MY_Depletion')
            AND ASI_CRM_Shipment_Date__c IN :setD
        ];
        system.debug('-----in function getMapRecordHeader----- existingHeaders : ' + existingHeaders);
        for(ASI_CRM_Depletion__c dep : existingHeaders){
            string strTemp = dep.ASI_CRM_Wholesaler__c + '_' + dep.ASI_CRM_Customer__c + '_' + dep.ASI_CRM_MY_SKU__c + '_' + string.valueOf(dep.ASI_CRM_Shipment_Date__c);
            mapRecordHeader.put(strTemp, dep);
        }
        system.debug('-----in function getMapRecordHeader----- mapRecordHeader : ' + mapRecordHeader);
        return mapRecordHeader;
    }
    
    public void init(set<string> setCus, set<string> setSKU){
        /*------------------------- mapOfCustomerId -------------------------*/
        List<ASI_CRM_AccountsAdditionalField__c> existingAccts = new List<ASI_CRM_AccountsAdditionalField__c>();
        existingAccts = [
            SELECT Id, ASI_CRM_MY_CustomerCode__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE (RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Outlet (MY)').RecordTypeId
            OR RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Potential Outlet (MY)').RecordTypeId
            OR RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Wholesaler (MY)').RecordTypeId)
            AND ASI_CRM_MY_CustomerCode__c IN :setCus
        ];
        
        if(existingAccts != NULL && existingAccts.size() > 0)
            for(ASI_CRM_AccountsAdditionalField__c Acc : existingAccts){
                mapOfCustomerId.put(Acc.ASI_CRM_MY_CustomerCode__c, Acc.id);
            }
        system.debug(mapOfCustomerId);
        
        List<ASI_MFM_SKU_Code__c> existingSKUs = new List<ASI_MFM_SKU_Code__c>();
        existingSKUs = [
            SELECT Id, ASI_MFM_SKU_Code__c
            FROM ASI_MFM_SKU_Code__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')
            AND ASI_MFM_SKU_Code__c IN :setSKU
        ];
        
        for(ASI_MFM_SKU_Code__c sku : existingSKUs){
            mapSKU.put(sku.ASI_MFM_SKU_Code__c, sku.id);
        }
        
    }
    
    public Pagereference ReadFile(){
        
        list<string> lstError = new list<string>();
        
        // check the file type
        try{
            nameFile = contentFile.toString();
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file type. Please make your uploaded file is in csv format.'));
            return null;
        }
        
        system.debug('---nameFile---' + nameFile);
        
        if(nameFile.contains('\r\n'))
            filelines = nameFile.split('\r\n');
        else if(nameFile.contains('\r'))
            filelines = nameFile.split('\r');
        else if(nameFile.contains('\n'))
            filelines = nameFile.split('\n');

        sitetoupload = new List<ASI_CRM_Depletion__c>();
        lstError.clear();
        
        set<string> setInputCus = new set<string>();
        set<string> setInputSKU = new set<string>();
        
        for(Integer i = 1; i < filelines.size(); i++){
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            
            if(inputvalues.size() != 5){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                return null;
            }
            
            string strDate = inputvalues[3];
            if(ASI_CRM_MY_Function.IsValidDate(strDate)){
                Date uploadDate = getRecordDate(strDate);
                setD.add(uploadDate);
            }else{
                lstError.add('Line ' + i + ' : invalid date format ' + strDate + ', please make sure the input date is/ are in correct format DD/MM/YYYY.');
            }
            
            string strWS = inputvalues[0];
            string strCus = inputvalues[1];
            string strSKU = inputvalues[2];
            
            if(strWS != NULL)
                setInputCus.add(strWS);
            if(strCus != NULL)
                setInputCus.add(strCus);
            if(strSKU != NULL)
                setInputSKU.add(strSKU);
        }
        
        mapRecord = getMapRecord(setD);
        
        if(filelines.size() == 1){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid file format. / the file contains at lease one record.'));
            return null;
        }
        
        init(setInputCus, setInputSKU);
        
        try{
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                boolean hasError = FALSE;
                
                
                if(inputvalues.size() != 5){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                    return null;
                }
                
                ASI_CRM_Depletion__c s = new ASI_CRM_Depletion__c();
                //WS code, Customer code, SKU code, Shipment Date, Depletion Volume
                
                string strWS = inputvalues[0];
                string strCus = inputvalues[1];
                string strSKU = inputvalues[2];
                id idWS;
                id idCus;
                id idSKU;
                if(strWS != NULL && mapOfCustomerId.get(strWS) != NULL)
                    idWS = mapOfCustomerId.get(strWS); 
                else
                    lstError.add('Line ' + i + ' : Mismatched Wholesaler Code ' + strWS);
                    
                if(strCus != NULL && mapOfCustomerId.get(strCus) != NULL)
                    idCus= mapOfCustomerId.get(strCus);
                else
                    lstError.add('Line ' + i + ' : Mismatched Customer Code ' + strCus);
                    
                if(strSKU != NULL && mapSKU.get(strSKU) != NULL)
                    idSKU = mapSKU.get(strSKU);
                else
                    lstError.add('Line ' + i + ' : Mismatched SKU Code ' + strSKU);
                    
                string strDate = inputvalues[3];
                Date uploadDate = getRecordDate(strDate);
                
                string strKey;
                if(idWS != NULL && idCus != NULL && idSKU != NULL && uploadDate != NULL)
                    strKey = string.valueOf(idWS) + '_' + string.valueOf(idCus) + '_' + string.valueOf(idSKU) + '_' + string.valueOf(uploadDate);
                
                system.debug('------------LOOPING LINE---------------- strKey : ' + strKey);
                system.debug('------------LOOPING LINE---------------- mapRecord : ' + mapRecord);

                if(strKey != NULL && mapRecord.get(strKey) != NULL)
                    s.id = mapRecord.get(strKey).id;
                s.ASI_CRM_Wholesaler__c = idWS;
                s.ASI_CRM_Customer__c = idCus;
                s.ASI_CRM_MY_SKU__c = idSKU;
                s.ASI_CRM_Shipment_Date__c = uploadDate;
                s.ASI_CRM_Depletion_Volume__c = integer.valueOf(inputvalues[4]);
                s.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_Depletion__cASI_CRM_MY_Depletion');
                sitetoupload.add(s);
            }
        }
        catch(Exception e){
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The following exception has occurred: ' + e.getMessage());
            //ApexPages.addMessage(errormsg);
            
            //getTypeName
            lstError.add('SYSTEM Catch Error : ' +  e.getMessage());
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched data has occurred on row' + e.getNumDml()));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please check the template or try again later'));
        }
        
        if(lstError != NULL && lstError.size() > 0){
            for(string strError : lstError){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strError));
            }
        }else{
            upsert sitetoupload;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All the record has been successfully updated.'));
        }
        return null;
    }

    public List<ASI_CRM_Depletion__c> getuploadedsite(){
        if(sitetoupload != NULL && sitetoupload.size() > 0)
            return sitetoupload;
        else
            return null;
    }
}