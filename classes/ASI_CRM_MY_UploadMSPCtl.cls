/*Filename:    ASI_CRM_MY_UploadMSPCtl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     upload a CSV file which with Special Character using Apex into Salesforce
*
* ref: http://salesforce.stackexchange.com/questions/15621/how-to-upload-a-csv-file-which-with-special-character-using-apex-into-salesforce
*
* History
* -----------------------------------------------------------------------------
* 2015-04-20        daniel.wong@introv.com        Created
*/

public class ASI_CRM_MY_UploadMSPCtl{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    public map<string, id> mapOfCustomerId = new map<string, id>();
    public map<string, id> mapSKU = new map<string, id>();
    
    String[] filelines = new String[]{};
    List<ASI_CRM_MY_SKUPriceCost__c> sitetoupload;
    
    public set<date> setDate = new set<date>();
    public map<string, ASI_CRM_MY_SKUPriceCost__c> mapRecord = new map<string, ASI_CRM_MY_SKUPriceCost__c>();
    
    public date getRecordDate(string strDate){ 
        //strDate = DD/MM/YY
        integer intY = integer.valueOf(strDate.split('/')[2]);
        integer intM = integer.valueOf(strDate.split('/')[1]);
        integer intD = integer.valueOf(strDate.split('/')[0]);
        
        date dateTemp = date.newInstance(intY, intM, intD);
        return dateTemp;
    }
    
    public map<string, ASI_CRM_MY_SKUPriceCost__c> getMapRecord(set<date> setDate){
        map<string, ASI_CRM_MY_SKUPriceCost__c> mapRecordHeader = new map<string, ASI_CRM_MY_SKUPriceCost__c>();
        
        List<ASI_CRM_MY_SKUPriceCost__c> existingHeaders = new List<ASI_CRM_MY_SKUPriceCost__c>();
        existingHeaders = [
            SELECT Id, ASI_CRM_SKU__c, ASI_CRM_EffectiveDate__c
            FROM ASI_CRM_MY_SKUPriceCost__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP')
            AND ASI_CRM_EffectiveDate__c IN :setDate
        ];
        system.debug('-----in function getMapRecordHeader----- existingHeaders : ' + existingHeaders);
        for(ASI_CRM_MY_SKUPriceCost__c dep : existingHeaders){
            string strTemp = dep.ASI_CRM_SKU__c + '_' + dep.ASI_CRM_EffectiveDate__c;
            mapRecordHeader.put(strTemp, dep);
        }
        system.debug('-----in function getMapRecordHeader----- mapRecordHeader : ' + mapRecordHeader);
        return mapRecordHeader;
    }
    
    public void init(set<string> setSKU){
        List<ASI_MFM_SKU_Code__c> existingSKUs = new List<ASI_MFM_SKU_Code__c>();
        existingSKUs = [
            SELECT Id, ASI_MFM_SKU_Code__c
            FROM ASI_MFM_SKU_Code__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU')
        ];
        
        for(ASI_MFM_SKU_Code__c sku : existingSKUs){
            mapSKU.put(sku.ASI_MFM_SKU_Code__c, sku.id);
        }
        
    }
    
    public Pagereference ReadFile(){
        //init();
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

        sitetoupload = new List<ASI_CRM_MY_SKUPriceCost__c>();
        lstError.clear();
        
        set<string> setInputSKU = new set<string>();
        
        for(Integer i = 1; i < filelines.size(); i++){
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            
            if(inputvalues.size() != 4){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                return null;
            }
            
            string strDate = inputvalues[1];
            if(ASI_CRM_MY_Function.IsValidDate(strDate)){
                Date uploadDate = getRecordDate(strDate);
                setDate.add(uploadDate);
            }else{
                lstError.add('Line ' + i + ' : invalid date format ' + strDate + ', please make sure the input date is/ are in correct format DD/MM/YYYY.');
            }
            
            string strSKU = inputvalues[0].trim();
            setInputSKU.add(strSKU);
        }
        
        mapRecord = getMapRecord(setDate);
        
        init(setInputSKU);
        
        if(filelines.size() == 1){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid file format. / the file contains at lease one record.'));
            return null;
        }
        
        try{
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                boolean hasError = FALSE;
                
                if(inputvalues.size() != 4){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                    return null;
                }
                
                ASI_CRM_MY_SKUPriceCost__c s = new ASI_CRM_MY_SKUPriceCost__c();
                //SKU, Date, IGC, Cus Code2
                string strSKU = inputvalues[0].trim();
                string strDate = inputvalues[1].trim();
                string strIGC = inputvalues[2].trim();
                string strCC2 = inputvalues[3].trim();
                
                id idSKU;

                if(strSKU != NULL && mapSKU.get(strSKU) != NULL)
                    idSKU = mapSKU.get(strSKU);
                else
                    lstError.add('Line ' + i + ' : Mismatched SKU Code ' + strSKU);
                    
                Date uploadDate = getRecordDate(strDate);
                string strKey;
                
                if(idSKU != NULL && uploadDate != NULL)
                    strKey = string.valueOf(idSKU) + '_' + string.valueOf(uploadDate) + ' 00:00:00';
                
                system.debug('------------LOOPING LINE---------------- strKey : ' + strKey);
                system.debug('------------LOOPING LINE---------------- mapRecord : ' + mapRecord);

                if(strKey != NULL && mapRecord.get(strKey) != NULL)
                    s.id = mapRecord.get(strKey).id;
                system.debug('------------LOOPING LINE---------------- sid : ' + s.id);
                s.ASI_CRM_SKU__c = idSKU;
                s.ASI_CRM_EffectiveDate__c = uploadDate;
                
                if(strIGC != NULL)
                    s.ASI_CRM_Price__c = decimal.valueOf(strIGC.trim());
                
                s.ASI_CRM_Customer_Category_Code_2__c = strCC2;
                
                //ASI_CRM_External_ID__c = MY_CusCOde_SKU_Year_TARGET
                //s.ASI_CRM_External_ID__c = 'MY_' + strWS + '_' + strSKU + '_' + string.valueOf(uploadDate.Year()) +'_FORECAST';
                s.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_MY_SKUPriceCost__cASI_CRM_MY_MinSP');
                sitetoupload.add(s);
            }
        }
        catch(Exception e){
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The following exception has occurred: ' + e.getMessage());
            //ApexPages.addMessage(errormsg);
            
            //getTypeName
            lstError.add('Catch System Error : ' + e.getMessage());
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

    public List<ASI_CRM_MY_SKUPriceCost__c> getuploadedsite(){
        if(sitetoupload != NULL && sitetoupload.size() > 0)
            return sitetoupload;
        else
            return null;
    }
}