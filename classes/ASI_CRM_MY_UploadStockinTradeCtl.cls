/*Filename:    ASI_CRM_MY_UploadStockinTradeCtl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     upload a CSV file which with Special Character using Apex into Salesforce
*
* ref: http://salesforce.stackexchange.com/questions/15621/how-to-upload-a-csv-file-which-with-special-character-using-apex-into-salesforce
*
* History
* -----------------------------------------------------------------------------
* 2015-04-20        daniel.wong@introv.com        Created
*/

public class ASI_CRM_MY_UploadStockinTradeCtl{
    public string nameFile{get;set;}
    public transient Blob contentFile{get;set;}
    
    public map<string, id> mapAccount = new map<string, id>();
    public map<string, id> mapSKU = new map<string, id>();
    public map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c> mapRecordHeader = new map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
    public map<string, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> mapRecordDetail = new map<string, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
    public map<string, string> mapStringMonth = new map<string, string>{
        '01'=>'Jan',
        '02'=>'Feb',
        '03'=>'Mar',
        '04'=>'Apr',
        '05'=>'May',
        '06'=>'Jun',
        '07'=>'Jul',
        '08'=>'Aug',
        '09'=>'Sept',
        '10'=>'Oct',
        '11'=>'Nov',
        '12'=>'Dec'
    };
    
    public ID MYSKURT = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MY_SKU');
    //Schema.SObjectType.ASI_MFM_SKU_Code__c.RecordTypeInfosByName.get('MY CRM SKU').RecordTypeId;
    public ID MYHeaderRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade__cASI_CRM_MY_Offtake_Stock_In_Trade');
    //Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade__c.RecordTypeInfosByName.get('ASI CRM MY Offtake Stock In Trade').RecordTypeId;
    public ID MYDetailRT= Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MY_WS_Stock_In_Trade_Detail');
    //Schema.SObjectType.ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c.RecordTypeInfosByName.get('ASI_CRM_MY_WS_Stock_In_Trade_Detail').RecordTypeId;
    public set<id> setHeader = new set<id>();
    
    string[] filelines = new String[]{};
    list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> sitetoupload;
    //list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> siteError;
    list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> sitetoDel;
    
    public class siteErrorClass{
        public integer intLine {get; set;}
        public ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c offtakeError {get; set;}
    }
    list<siteErrorClass> siteErrors;
    
    public map<string, id> getMapAccount(set<string> setWSCode){
        map<string, id> mapAccount = new map<string, id>();
        
        set<id> setRT = new set<id>();
        //id RT1 = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Dummy Outlet Cold Call (MY)').RecordTypeId;
        id RT1 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletColdCall');
        //id RT2 = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Dummy Outlet WS Depletion (MY)').RecordTypeId;
        id RT2 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_DummyOutletDepletion');
        //id RT3 = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Outlet (MY)').RecordTypeId;
        id RT3 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Outlet');
        //id RT4 = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Potential Outlet (MY)').RecordTypeId;
        id RT4 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Potential_Outlet');
        //id RT5 = Schema.SObjectType.ASI_CRM_AccountsAdditionalField__c.RecordTypeInfosByName.get('Wholesaler (MY)').RecordTypeId;
        id RT5 = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_MY_Wholesaler');
        
        setRT.add(RT1);
        setRT.add(RT2);
        setRT.add(RT3);
        setRT.add(RT4);
        setRT.add(RT5);

        List<ASI_CRM_AccountsAdditionalField__c> existingAccts = new List<ASI_CRM_AccountsAdditionalField__c>();
        existingAccts = [
            SELECT Id, ASI_CRM_MY_CustomerCode__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE RecordTypeId IN :setRT
            AND ASI_CRM_MY_CustomerCode__c IN :setWSCode
        ];
        
        for(ASI_CRM_AccountsAdditionalField__c acc : existingAccts){
            mapAccount.put(acc.ASI_CRM_MY_CustomerCode__c, acc.id);
        }
            
        return mapAccount;
    }
    
    public map<string, id> getMapSKU(set<string> setInputSKU){
        map<string, id> mapSKU = new map<string, id>();
        
        List<ASI_MFM_SKU_Code__c> existingSKUs = new List<ASI_MFM_SKU_Code__c>();
        existingSKUs = [
            SELECT Id, ASI_MFM_SKU_Code__c
            FROM ASI_MFM_SKU_Code__c
            WHERE RecordTypeId = :MYSKURT
            AND ASI_MFM_SKU_Code__c IN :setInputSKU
        ];
        
        for(ASI_MFM_SKU_Code__c sku : existingSKUs){
            mapSKU.put(sku.ASI_MFM_SKU_Code__c, sku.id);
        }
        
        return mapSKU;
    }
    
    public map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c> getMapRecordHeader(set<string> setWSCode, set<string> setInputY, set<string> setInputM){
        map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c> mapRecordHeader = new map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
        
        List<ASI_TH_CRM_Offtake_Stock_In_Trade__c> existingHeaders = new List<ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
        existingHeaders = [
            SELECT Id, ASI_CRM_MY_WS__r.ASI_CRM_MY_CustomerCode__c, ASI_TH_CRM_Year__c, ASI_TH_CRM_Month__c, ASI_TH_CRM_Status__c
            FROM ASI_TH_CRM_Offtake_Stock_In_Trade__c
            WHERE RecordTypeId = :MYHeaderRT
            AND (ASI_TH_CRM_Year__c IN :setInputY
            AND ASI_TH_CRM_Month__c IN :setInputM
            AND ASI_CRM_MY_WS__r.ASI_CRM_MY_CustomerCode__c IN :setWSCode)
        ];
        system.debug('-----in function getMapRecordHeader----- existingHeaders : ' + existingHeaders);
        for(ASI_TH_CRM_Offtake_Stock_In_Trade__c off : existingHeaders){
            string strTemp = off.ASI_CRM_MY_WS__r.ASI_CRM_MY_CustomerCode__c + '_' + off.ASI_TH_CRM_Year__c + '_' + off.ASI_TH_CRM_Month__c;
            mapRecordHeader.put(strTemp, off);
            setHeader.add(off.id);
        }
        system.debug('-----in function getMapRecordHeader----- mapRecordHeader : ' + mapRecordHeader);
        return mapRecordHeader;
    }
    
    public map<string, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> getMapRecordDetail(set<id> setHeader){
        map<string, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> mapRecord = new map<string, ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        
        List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> existingRecords = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        existingRecords = [
            SELECT Id, ASI_TH_CRM_SIT__r.ASI_CRM_MY_WS__c, ASI_TH_CRM_Date__c, ASI_CRM_SKU__c
            FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c
            WHERE RecordTypeId = :MYDetailRT
            AND ASI_TH_CRM_SIT__c IN :setHeader
        ];
        system.debug('-----in function getMapRecordDetail----- existingRecords : ' + existingRecords);
        for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c off : existingRecords){
            string strTemp = off.ASI_TH_CRM_SIT__r.ASI_CRM_MY_WS__c + '_' + off.ASI_CRM_SKU__c + '_' + off.ASI_TH_CRM_Date__c;
            mapRecord.put(strTemp, off);
        }
        system.debug('-----in function getMapRecordHeader----- mapRecordHeader : ' + mapRecordHeader);
        return mapRecord;
    }
    
    public string getRecordYear(string strDate){ 
        //strDate = DD/MM/YY
        string strY = strDate.split('/')[2];
        return strY;
    }
    
    public string getRecordMonth(string strDate){ 
        //strDate = DD/MM/YY
        string strM;
        strM = strDate.split('/')[1];
        if(strM.length() == 1)
            strM = '0' + strM;
        strM = mapStringMonth.get(strM);
        system.debug('---------------strM : ' + strM);
        return strM;
    }
    
    public date getRecordDate(string strDate){ 
        //strDate = DD/MM/YY
        integer intY;
        integer intM;
        integer intD;
        date varDate;
        system.debug('--- getRecordDate strDate --- ' + strDate);
        intY = Integer.valueOf(strDate.split('/')[2]);
        intM = Integer.valueOf(strDate.split('/')[1]);
        intD = Integer.valueOf(strDate.split('/')[0]);
        system.debug('--- getRecordDate intY --- ' + intY);
        system.debug('--- getRecordDate intM --- ' + intM);
        system.debug('--- getRecordDate intD --- ' + intD);
        varDate = date.newInstance(intY, intM, intD);
        system.debug('--- getRecordDate varDate --- ' + varDate);
        return varDate;
    }
    
    public void init(set<string> setWSCode, set<string> setInputSKU, set<string> setInputY, set<string> setInputM){
        mapAccount = getMapAccount(setWSCode);
        mapSKU = getMapSKU(setInputSKU);
        mapRecordHeader = getMapRecordHeader(setWSCode, setInputY, setInputM); system.debug('-----mapRecordHeader-----' + mapRecordHeader);
        mapRecordDetail = getMapRecordDetail(setHeader);
    }
    
    public void clearInit(){
        mapAccount = null; //genMapAccount();
        mapSKU = null; //getMapSKU();
        mapRecordHeader = null; //getMapRecordHeader(); system.debug('-----mapRecordHeader-----' + mapRecordHeader);
        mapRecordDetail = null; //getMapRecordDetail(setHeader);
    }
    
    public Pagereference ReadFile(){
        //init();
        list<string> lstError = new list<string>();
        set<string> setYear = new set<string>();
        set<string> setMonth = new set<string>();

        //check the file type
        try{
            nameFile = contentFile.toString();
            contentFile = null;
        }catch(Exception e){
            clearInit();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file type. Please make sure the uploaded file is in csv format.'));
            return null;
        }
        system.debug('---nameFile---' + nameFile);
        
        if(nameFile.contains('\r\n'))
            filelines = nameFile.split('\r\n');
        else if(nameFile.contains('\r'))
            filelines = nameFile.split('\r');
        else if(nameFile.contains('\n'))
            filelines = nameFile.split('\n');

        sitetoupload = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        siteErrors = new List<siteErrorClass>();
        sitetoDel = new List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c>();
        //setHeader.clear();
        lstError.clear();
        siteErrors.clear();
        
        if(filelines.size() == 1){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid file format. / the file contains at lease one record.'));
            return null;
        }
        
        try{
            set<string> setInputWSCode = new set<string>();
            set<string> setInputSKU = new set<string>();
            set<string> setInputY = new set<string>();
            set<string> setInputM = new set<string>();
            
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                
                if(inputvalues.size() != 6){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                    return null;
                }
                
                string strWSCode = inputvalues[0];
                string strDate = inputvalues[1];
                string strSKUCode = inputvalues[2];
                string strY = getRecordYear(strDate);
                string strM = getRecordMonth(strDate);
                
                setInputWSCode.add(strWSCode);
                // [SH] 2018-11-28 Duplication checking 
                if(setInputSKU.contains(strSKUCode)){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Duplicate SKU Code'));
                    return null;
                }else{
                    setInputSKU.add(strSKUCode);
                }
                // END - [SH]
                setInputY.add(strY);
                setInputM.add(strM);
            }
            
            init(setInputWSCode, setInputSKU, setInputY, setInputM);
            /*
                mapAccount = getMapAccount();
                mapSKU = getMapSKU();
                mapRecordHeader = getMapRecordHeader(); system.debug('-----mapRecordHeader-----' + mapRecordHeader);
                mapRecordDetail = getMapRecordDetail(setHeader);
            */ 
                        
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                boolean hasError = FALSE;
                
                ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c s = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c();
                
                //WS code, Sell out date, PR SKU Code, SKU Descripition, Ending Stock, Total Offtake (Final)
                string strWSCode = inputvalues[0];
                //string strOutletCode = inputvalues[1];
                string strDate = inputvalues[1];
                string strSKUCode = inputvalues[2];
                //string strQty = inputvalues[4];
                string strQty2 = inputvalues[4];
                string strTotal = inputvalues[5];
                string strY = getRecordYear(strDate);
                string strM = getRecordMonth(strDate);
                
                //Check all records if it is in the same Month
                /*setYear.add(strY);
                setMonth.add(strM);
                if(setYear.size() > 1 || setMonth.size() > 1){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure all the records are in the same Month.'));
                    return null;
                }*/
                
                //Check records' header
                string strKey = strWSCode + '_' + strY + '_' + strM;
                string strKeyDetail;
                system.debug('----Looping file line---- NOW checking strKey : ' + strKey);
                
                id headerId;
                if(mapRecordHeader.get(strKey) != NULL){
                    headerId = mapRecordHeader.get(strKey).id;
                }
                
                if(headerId == NULL){
                    if(mapAccount.get(strWSCode) != NULL){
                        ASI_TH_CRM_Offtake_Stock_In_Trade__c newHeader = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(
                            ASI_CRM_MY_WS__c = mapAccount.get(strWSCode),
                            ASI_TH_CRM_Year__c = strY,
                            ASI_TH_CRM_Month__c = strM,
                            ASI_TH_CRM_Status__c = 'Draft',
                            RecordTypeId = MYHeaderRT
                        );
                    
                        insert newHeader;
                        headerId = newHeader.id;
                        mapRecordHeader.put(strKey, newHeader);
                        
                        //update Detail Map
                        setHeader.add(headerId);
                        mapRecordDetail = getMapRecordDetail(setHeader);
                    }else{
                        lstError.add('Line ' + i + ' : Mismatched Wholesaler Code ' + strWSCode);
                        hasError = TRUE;
                        continue;
                    }
                }
                
                //Check header if it is locked
                system.debug('----Looping file line---- NOW checking headerId : ' + headerId);
                /*if(mapRecordHeader.get(strKey).ASI_TH_CRM_Status__c == 'Final'){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The Record ' + mapRecordHeader.get(strKey).name + ' is locked.'));
                    return null;
                }*/
                
                s.ASI_TH_CRM_SIT__c = headerId;
                
                //Check Account mapping
                /*if(mapAccount.get(strOutletCode) != NULL){
                    s.ASI_CRM_MY_WS__c = mapAccount.get(strOutletCode);
                }else{
                    lstError.add('Line ' + i + ' : Mismatched Outlet Code ' + strOutletCode);
                    hasError = TRUE;
                }*/
                
                s.ASI_TH_CRM_Date__c = getRecordDate(strDate);
                system.debug('------ Checking ASI_TH_CRM_Date__c ------' + s.ASI_TH_CRM_Date__c);
                system.debug('------ Checking ASI_CRM_SKU__c --> mapSKU.get(strSKUCode) ------' + mapSKU.get(strSKUCode));
                
                //Check SKU mapping
                if(mapSKU.get(strSKUCode) != NULL){
                    s.ASI_CRM_SKU__c = mapSKU.get(strSKUCode);
                }else{
                    lstError.add('Line ' + i + ' : Mismatched SKU Code ' + strSKUCode);
                    hasError = TRUE;
                }
                
                //Check Qty
                /*if(strQty != NULL){
                    s.ASI_TH_CRM_Beginning_Stock__c = integer.valueOf(strQty.trim());
                }else{
                    lstError.add('Line ' + i + ' : Beginning Stock cannot be empty');
                    hasError = TRUE;
                }*/
                
                if(strQty2 != NULL){
                    s.ASI_TH_CRM_Ending_Stock_Final__c = integer.valueOf(strQty2.trim());
                }else{
                    lstError.add('Line ' + i + ' : Ending Stock cannot be empty');
                    hasError = TRUE;
                }
                
                if(strTotal != NULL){
                    s.ASI_TH_CRM_Total_Offtake_Final__c = integer.valueOf(strTotal.trim());
                }else{
                    lstError.add('Line ' + i + ' : Total Offtake (Final) cannot be empty');
                    hasError = TRUE;
                }
                
                strKeyDetail = mapRecordHeader.get(strKey).ASI_CRM_MY_WS__c + '_' + s.ASI_CRM_SKU__c + '_' + s.ASI_TH_CRM_Date__c;
                if(mapRecordDetail.get(strKeyDetail) != NULL)
                    s.id = mapRecordDetail.get(strKeyDetail).id;
                
                s.RecordTypeId = MYDetailRT;
                sitetoupload.add(s);
                if(hasError){
                    //siteError.add(s);
                    
                    siteErrorClass temp = new siteErrorClass();
                    temp.intLine = i;
                    temp.offtakeError = s;
                    siteErrors.add(temp);
                }
                //setHeader.add(headerId);
            }
            
            /*for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c i : [SELECT id FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE RecordTypeId = :MYDetailRT AND ASI_TH_CRM_SIT__c IN :setHeader]){
                sitetoDel.add(i);
            }*/

            //insert sitetoupload;
            //delete sitetoDel;
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All the record has been successfully updated.'));
        }
        catch(Exception e){
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The following exception has occurred: ' + e.getMessage());
            //ApexPages.addMessage(errormsg);
            //getTypeName
            system.debug('---- Exception ---- ' + e.getMessage());
            lstError.add('SYSTEM catch error : ' + e.getMessage());
        }
        
        if(lstError != NULL && lstError.size() > 0){
            for(string strError : lstError){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strError));
            }
            
            return null;
        }
        nameFile = null;
        contentFile = null;
        filelines = null;
        upsert sitetoupload;
        //delete sitetoDel;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All the record has been successfully updated.'));

        return null;
    }

    public List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> getuploadedsite(){
        if(sitetoupload != NULL && sitetoupload.size() > 0)
            return sitetoupload;
        else
            return null;
    }
    
    /*public List<siteErrorClass> getuploadedsite(){
        if(siteErrors != NULL && siteErrors.size() > 0)
            return siteErrors;
        else
            return null;
    }*/
}