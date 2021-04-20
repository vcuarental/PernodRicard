/*Filename:    ASI_CRM_MY_UploadWSForecastCtl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     upload a CSV file which with Special Character using Apex into Salesforce
*
* ref: http://salesforce.stackexchange.com/questions/15621/how-to-upload-a-csv-file-which-with-special-character-using-apex-into-salesforce
*
* History
* -----------------------------------------------------------------------------
* 2015-04-20        daniel.wong@introv.com        Created
*/

public class ASI_CRM_MY_UploadWSForecastCtl{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    public map<string, id> mapOfCustomerId = new map<string, id>();
    public map<string, id> mapSKU = new map<string, id>();
    
    String[] filelines = new String[]{};
    List<ASI_CRM_WS_Target__c> sitetoupload;
    
    public set<string> setYear = new set<string>();
    public map<string, ASI_CRM_WS_Target__c> mapRecord = new map<string, ASI_CRM_WS_Target__c>();
    
    public date getRecordDate(string strDate){ 
        //strDate = DD/MM/YY
        /*integer intY = integer.valueOf(strDate.split('/')[2]);
        integer intM = integer.valueOf(strDate.split('/')[1]);
        integer intD = integer.valueOf(strDate.split('/')[0]);*/
        integer intY = integer.valueOf(strDate);
        
        //date dateTemp = date.newInstance(intY, intM, intD);
        date dateTemp = date.newInstance(intY, 7, 1);
        return dateTemp;
    }
    
    public map<string, ASI_CRM_WS_Target__c> getMapRecord(set<string> setYear){
        map<string, ASI_CRM_WS_Target__c> mapRecordHeader = new map<string, ASI_CRM_WS_Target__c>();
        
        List<ASI_CRM_WS_Target__c> existingHeaders = new List<ASI_CRM_WS_Target__c>();
        existingHeaders = [
            SELECT Id, ASI_CRM_T2_WS__c, ASI_CRM_SKU__c, ASI_CRM_Year__c, ASI_CRM_External_ID__c
            FROM ASI_CRM_WS_Target__c
            WHERE RecordTypeId = :Global_RecordTypeCache.getRtId('ASI_CRM_WS_Target__cASI_CRM_MY_WS_Forecast')
            AND ASI_CRM_Year__c IN :setYear
        ];
        system.debug('-----in function getMapRecordHeader----- existingHeaders : ' + existingHeaders);
        for(ASI_CRM_WS_Target__c dep : existingHeaders){
            string strTemp = dep.ASI_CRM_T2_WS__c+ '_' + dep.ASI_CRM_SKU__c+ '_' + dep.ASI_CRM_Year__c;
            mapRecordHeader.put(strTemp, dep);
        }
        system.debug('-----in function getMapRecordHeader----- mapRecordHeader : ' + mapRecordHeader);
        return mapRecordHeader;
    }
    
    public void init(set<string> setInputCus, set<string> setInputSKU){
        /*------------------------- mapOfCustomerId -------------------------*/
        List<ASI_CRM_AccountsAdditionalField__c> existingAccts = new List<ASI_CRM_AccountsAdditionalField__c>();
        existingAccts = [
            SELECT Id, ASI_CRM_MY_CustomerCode__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE (RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Outlet (MY)').RecordTypeId
            OR RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Potential Outlet (MY)').RecordTypeId
            OR RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Wholesaler (MY)').RecordTypeId
            OR RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Dummy Outlet Cold Call (MY)').RecordTypeId
            OR RecordTypeId = :Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Dummy Outlet WS Depletion (MY)').RecordTypeId)
            AND ASI_CRM_MY_CustomerCode__c IN :setInputCus
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
            AND ASI_MFM_SKU_Code__c IN :setInputSKU
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

        sitetoupload = new List<ASI_CRM_WS_Target__c>();
        lstError.clear();
        
        set<string> setInputCus = new set<string>();
        set<string> setInputSKU = new set<string>();
        
        for(Integer i = 1; i < filelines.size(); i++){
            String[] inputvalues = new String[]{};
            inputvalues = filelines[i].split(',');
            
            if(inputvalues.size() != 15){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                return null;
            }
            
            string strDate = inputvalues[2];
            Date uploadDate = getRecordDate(strDate);
            setYear.add(string.valueOf(uploadDate.year()));
            
            string strWS = inputvalues[0];
            string strSKU = inputvalues[1];
            
            setInputCus.add(strWS);
            setInputSKU.add(strSKU);
        }
        
        mapRecord = getMapRecord(setYear);
        
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
                
                if(inputvalues.size() != 15){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                    return null;
                }
                
                ASI_CRM_WS_Target__c s = new ASI_CRM_WS_Target__c();
                //WS Code, SKU code, Date, Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
                //WS Codeinputvalues[0], SKU codeinputvalues[1], Dateinputvalues[2], Julinputvalues[3], Aug, Sep, Oct, Nov, Dec, Jan, Feb, Mar, Apr, May, Jun
                string strWS = inputvalues[0];
                string strSKU = inputvalues[1];
                string strDate = inputvalues[2];
                string str01 = inputvalues[9]; //Jan
                string str02 = inputvalues[10]; // Feb
                string str03 = inputvalues[11];
                string str04 = inputvalues[12];
                string str05 = inputvalues[13];
                string str06 = inputvalues[14];
                string str07 = inputvalues[3];
                string str08 = inputvalues[4];
                string str09 = inputvalues[5];
                string str10 = inputvalues[6];
                string str11 = inputvalues[7];
                string str12 = inputvalues[8]; //Dec
                
                id idWS;
                id idSKU;
                if(strWS != NULL && mapOfCustomerId.get(strWS) != NULL)
                    idWS = mapOfCustomerId.get(strWS); 
                else
                    lstError.add('Line ' + i + ' : Mismatched Wholesaler Code ' + strWS);
                    
                if(strSKU != NULL && mapSKU.get(strSKU) != NULL)
                    idSKU = mapSKU.get(strSKU);
                else
                    lstError.add('Line ' + i + ' : Mismatched SKU Code ' + strSKU);
                    
                Date uploadDate = getRecordDate(strDate);
                string strKey;
                
                if(idWS != NULL && idSKU != NULL && uploadDate != NULL)
                    strKey = string.valueOf(idWS) + '_' + string.valueOf(idSKU) + '_' + string.valueOf(uploadDate.Year());
                
                system.debug('------------LOOPING LINE---------------- strKey : ' + strKey);
                system.debug('------------LOOPING LINE---------------- mapRecord : ' + mapRecord);

                if(strKey != NULL && mapRecord.get(strKey) != NULL)
                    s.id = mapRecord.get(strKey).id;
                s.ASI_CRM_T2_WS__c = idWS;
                s.ASI_CRM_SKU__c = idSKU;
                s.ASI_CRM_MY_TargetDate__c = uploadDate;
                
                if(str01 != NULL)
                    s.ASI_CRM_January__c = integer.valueOf(str01);
                if(str02 != NULL)
                    s.ASI_CRM_February__c = integer.valueOf(str02);
                if(str03 != NULL)
                    s.ASI_CRM_March__c = integer.valueOf(str03);
                if(str04 != NULL)
                    s.ASI_CRM_April__c = integer.valueOf(str04);
                if(str05 != NULL)
                    s.ASI_CRM_May__c = integer.valueOf(str05);
                if(str06 != NULL)
                    s.ASI_CRM_June__c = integer.valueOf(str06);
                if(str07 != NULL)
                    s.ASI_CRM_July__c = integer.valueOf(str07);
                if(str08 != NULL)
                    s.ASI_CRM_August__c = integer.valueOf(str08);
                if(str09 != NULL)
                    s.ASI_CRM_September__c = integer.valueOf(str09);
                if(str10 != NULL)
                    s.ASI_CRM_October__c = integer.valueOf(str10);
                if(str11 != NULL)
                    s.ASI_CRM_November__c = integer.valueOf(str11);
                if(str12 != NULL)
                    s.ASI_CRM_December__c = integer.valueOf(str12);
                
                //ASI_CRM_External_ID__c = MY_CusCOde_SKU_Year_TARGET
                s.ASI_CRM_External_ID__c = 'MY_' + strWS + '_' + strSKU + '_' + string.valueOf(uploadDate.Year()) +'_FORECAST';
                s.recordTypeId = Global_RecordTypeCache.getRtId('ASI_CRM_WS_Target__cASI_CRM_MY_WS_Forecast');
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

    public List<ASI_CRM_WS_Target__c> getuploadedsite(){
        if(sitetoupload != NULL && sitetoupload.size() > 0)
            return sitetoupload;
        else
            return null;
    }
}