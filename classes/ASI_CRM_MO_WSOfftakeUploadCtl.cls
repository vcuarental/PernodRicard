/*Filename:    ASI_CRM_MO_WSOfftakeUploadCtl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     upload a CSV file which with Special Character using Apex into Salesforce
*
* ref: http://salesforce.stackexchange.com/questions/15621/how-to-upload-a-csv-file-which-with-special-character-using-apex-into-salesforce
*
* History
* -----------------------------------------------------------------------------
* 2015-03-31        daniel.wong@introv.com        Created
*/

public class ASI_CRM_MO_WSOfftakeUploadCtl{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    
    public map<string, id> mapAccount = new map<string, id>();
    public set<id> setAccount = new set<id>();
    public map<id, id> mapCustomer = new map<id, id>();
    public map<string, id> mapSKU = new map<string, id>();
    public map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c> mapRecordHeader = new map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
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
    
    public ID MOAccountRT = Global_RecordTypeCache.getRtId('AccountASI_HK_CRM_Outlet');
    public ID MOCustomerRT = Global_RecordTypeCache.getRtId('ASI_CRM_AccountsAdditionalField__cASI_CRM_HK_Outlet');
    public ID MOSKURT = Global_RecordTypeCache.getRtId('ASI_MFM_SKU_Code__cASI_CRM_MO_SKU'); //ASI_MFM_SKU_Code__cASI_FOC_CN_SKU //ASI_MFM_SKU_Code__cASI_CRM_MO_SKU
    public ID MOHeaderRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade__cASI_CRM_MO_WS_Offtake');
    public ID MODetailRT = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__cASI_CRM_MO_WSOfftakeDetail');
    
    string[] filelines = new String[]{};
    list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> sitetoupload;
    //list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> siteError;
    list<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> sitetoDel;
    set<id> setHeader = new set<id>();
    
    public class siteErrorClass{
        public integer intLine {get; set;}
        public ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c offtakeError {get; set;}
    }
    list<siteErrorClass> siteErrors;
    
    public map<string, id> getMapAccount(){
        map<string, id> mapAccount = new map<string, id>();
        setAccount = new set<id>();
        
        List<Account> existingAccts = new List<Account>();
        existingAccts = [
            SELECT Id, ASI_KOR_Customer_Code__c
            FROM Account
            WHERE RecordTypeId = :MOAccountRT
            AND (ASI_HK_CRM_Location__c = '#_MACDPLOC'
            OR Name LIKE 'SEAPOWER%')
        ];
        
        for(Account acc : existingAccts){
            mapAccount.put(acc.ASI_KOR_Customer_Code__c, acc.id);
            setAccount.add(acc.id);
        }
        
        List<ASI_CRM_AccountsAdditionalField__c> existingCustomers = new List<ASI_CRM_AccountsAdditionalField__c>();
        existingCustomers = [
            SELECT Id, ASI_CRM_Account__c
            FROM ASI_CRM_AccountsAdditionalField__c
            WHERE ASI_CRM_Account__c IN :setAccount
        ];
        
        for(ASI_CRM_AccountsAdditionalField__c Cus : existingCustomers){
            mapCustomer.put(Cus.ASI_CRM_Account__c, Cus.id);
        }
        
        return mapAccount;
    }
    
    public map<string, id> getMapSKU(){
        map<string, id> mapSKU = new map<string, id>();
        
        List<ASI_MFM_SKU_Code__c> existingSKUs = new List<ASI_MFM_SKU_Code__c>();
        existingSKUs = [
            SELECT Id, ASI_MFM_SKU_Code__c
            FROM ASI_MFM_SKU_Code__c
            WHERE RecordTypeId = :MOSKURT
        ];
        
        for(ASI_MFM_SKU_Code__c sku : existingSKUs){
            mapSKU.put(sku.ASI_MFM_SKU_Code__c, sku.id);
        }
        
        return mapSKU;
    }
    
    public map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c> getMapRecordHeader(){
        map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c> mapRecordHeader = new map<string, ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
        
        List<ASI_TH_CRM_Offtake_Stock_In_Trade__c> existingHeaders = new List<ASI_TH_CRM_Offtake_Stock_In_Trade__c>();
        existingHeaders = [
            SELECT Id, Name, ASI_TH_CRM_Account__r.ASI_KOR_Customer_Code__c, ASI_TH_CRM_Year__c, ASI_TH_CRM_Month__c, ASI_TH_CRM_Status__c
            FROM ASI_TH_CRM_Offtake_Stock_In_Trade__c
            WHERE RecordTypeId = :MOHeaderRT
        ];
        system.debug('-----in function getMapRecordHeader----- existingHeaders : ' + existingHeaders);
        for(ASI_TH_CRM_Offtake_Stock_In_Trade__c off : existingHeaders){
            string strTemp = off.ASI_TH_CRM_Account__r.ASI_KOR_Customer_Code__c + '_' + off.ASI_TH_CRM_Year__c + '_' + off.ASI_TH_CRM_Month__c;
            mapRecordHeader.put(strTemp, off);
        }
        system.debug('-----in function getMapRecordHeader----- mapRecordHeader : ' + mapRecordHeader);
        return mapRecordHeader;
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
    
    public void init(){
        mapAccount = getMapAccount();
        mapSKU = getMapSKU();
        mapRecordHeader = getMapRecordHeader(); system.debug('-----mapRecordHeader-----' + mapRecordHeader);
    }
    
    public Pagereference ReadFile(){
        init();
        list<string> lstError = new list<string>();
        set<string> setYear = new set<string>();
        set<string> setMonth = new set<string>();
        
        //check the file type
        try{
            nameFile = contentFile.toString();
        }catch(Exception e){
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
        setHeader.clear();
        lstError.clear();
        siteErrors.clear();
        
        if(filelines.size() == 1){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid file format. / the file contains at lease one record.'));
            return null;
        }
            
        try{
            system.debug('------------------filelines.size() : ' + filelines.size());
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                boolean hasError = FALSE;
                
                system.debug('---------------------------------------inputvalues.size() : ' + inputvalues.size());
                if(inputvalues.size() != 8){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure the uploaded file is in the correct format.'));
                    return null;
                }
                
                ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c s = new ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c();
                
                //Seapower code, Outlet code, Outlet name, Sell out date, PR SKU Code, PR SKU Code, Seapower SKU Code, SKU Descripition, Qty in bt
                string strSeaPowerCode = inputvalues[0];
                string strOutletCode = inputvalues[1];
                string strDate = inputvalues[3];
                string strSKUCode = inputvalues[4];
                string strQty = inputvalues[7];
                
                string strY = getRecordYear(strDate);
                string strM = getRecordMonth(strDate);
                
                //Check all records if it is in the same Month
                setYear.add(strY);
                setMonth.add(strM);
                if(setYear.size() > 1 || setMonth.size() > 1){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched file format. Please make sure all the records are in the same Month.'));
                    return null;
                }
                
                //Check records' header
                string strKey = strSeaPowerCode + '_' + strY + '_' + strM;
                system.debug('----Looping file line---- NOW checking strKey : ' + strKey);
                
                id headerId;
                if(mapRecordHeader.get(strKey) != NULL)
                    headerId = mapRecordHeader.get(strKey).id;
                
                if(headerId == NULL){
                    if(mapAccount.get(strSeaPowerCode) != NULL){
                        ASI_TH_CRM_Offtake_Stock_In_Trade__c newHeader = new ASI_TH_CRM_Offtake_Stock_In_Trade__c(
                            ASI_TH_CRM_Account__c = mapAccount.get(strSeaPowerCode),
                            ASI_TH_CRM_Year__c = strY,
                            ASI_TH_CRM_Month__c = strM,
                            ASI_TH_CRM_Status__c = 'Draft',
                            RecordTypeId = MOHeaderRT
                        );
                    
                        insert newHeader;
                        headerId = newHeader.id;
                        mapRecordHeader.put(strKey, newHeader);
                    }else{
                        lstError.add('Line ' + i + ' : Mismatched SeaPower Code ' + strSeaPowerCode);
                        hasError = TRUE;
                        continue;
                    }
                }
                
                //Check header if it is locked
                system.debug('----Looping file line---- NOW checking headerId : ' + headerId);
                if(mapRecordHeader.get(strKey).ASI_TH_CRM_Status__c == 'Final'){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The Record ' + mapRecordHeader.get(strKey).name + ' is locked.'));
                    return null;
                }
                
                s.ASI_TH_CRM_SIT__c = headerId;
                
                //Check Account mapping
                if(mapAccount.get(strOutletCode) != NULL){
                    s.ASI_TH_CRM_Account__c = mapAccount.get(strOutletCode);
                    s.ASI_CRM_Customer__c = mapCustomer.get(s.ASI_TH_CRM_Account__c);
                }else{
                    lstError.add('Line ' + i + ' : Mismatched Outlet Code ' + strOutletCode);
                    hasError = TRUE;
                }
                
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
                if(strQty != NULL){
                    if(integer.valueOf(strQty.trim()) == 0){
                        lstError.add('Line ' + i + ' : Qty in bt cannot be zero');
                        hasError = TRUE;
                    }else{
                        s.ASI_CRM_Quantity_Bottle__c = integer.valueOf(strQty.trim());
                    }
                }else{
                    lstError.add('Line ' + i + ' : Qty in bt cannot be empty');
                    hasError = TRUE;
                }
                
                s.RecordTypeId = MODetailRT;
                sitetoupload.add(s);
                if(hasError){
                    //siteError.add(s);
                    
                    siteErrorClass temp = new siteErrorClass();
                    temp.intLine = i;
                    temp.offtakeError = s;
                    siteErrors.add(temp);
                }
                setHeader.add(headerId);
            }
            
            system.debug('-------------------- setHeader : ' + setHeader);
            
            for(ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c i : [SELECT id FROM ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c WHERE RecordTypeId = :MODetailRT AND ASI_TH_CRM_SIT__c IN :setHeader]){
                sitetoDel.add(i);
            }

            //insert sitetoupload;
            //delete sitetoDel;
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All the record has been successfully updated.'));
        }
        catch(Exception e){
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The following exception has occurred: ' + e.getMessage());
            //ApexPages.addMessage(errormsg);
            //getTypeName
            system.debug('---- Exception ---- ' + e.getMessage());
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Mismatched data has occurred on row' + e.getNumDml()));
            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please check the template or try again later'));
            lstError.add('Catch System Error : ' + e.getMessage());
        }
        
        if(lstError != NULL && lstError.size() > 0){
            for(string strError : lstError){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, strError));
            }
            
            return null;
        }
        
        insert sitetoupload;
        delete sitetoDel;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All the record has been successfully updated.'));

        return null;
    }

    /*public List<ASI_TH_CRM_Offtake_Stock_In_Trade_Detail__c> getuploadedsite(){
        if(siteErrors != NULL && siteErrors.size() > 0)
            return siteErrors;
        else
            return null;
    }*/
    
    public List<siteErrorClass> getuploadedsite(){
        if(siteErrors != NULL && siteErrors.size() > 0)
            return siteErrors;
        else
            return null;
    }
}