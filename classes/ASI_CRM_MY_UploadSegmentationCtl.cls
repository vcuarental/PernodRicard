/*Filename:    ASI_CRM_MY_UploadSegmentationCtl.cls
* Author:      Daniel WONG (Introv Limited)
* Purpose:     upload a CSV file which with Special Character using Apex into Salesforce
*
* ref: http://salesforce.stackexchange.com/questions/15621/how-to-upload-a-csv-file-which-with-special-character-using-apex-into-salesforce
*
* History
* -----------------------------------------------------------------------------
* 2014-12-23        daniel.wong@introv.com        Created
*/

public class ASI_CRM_MY_UploadSegmentationCtl{
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    public map<string, id> mapOfCustomerId = new map<string, id>();
    public map<string, id> mapOfChannelId = new map<string, id>();
    public map<string, id> mapOfOutletImageId = new map<string, id>();
    public map<string, id> mapOfOutletTypeId = new map<string, id>();
    public map<string, id> mapOfOutletStrategyId = new map<string, id>();
    
    String[] filelines = new String[]{};
    List<ASI_CRM_AccountsAdditionalField__c> sitetoupload;
    List<String> acctNames;
    
    List<Account> newAccts = new List<Account>();
    
    public ASI_CRM_MY_UploadSegmentationCtl(ApexPages.StandardController controller){
    }
    
    public void init(set<string> setInputCus, set<string> setInputChannel, set<string> setInputOI){
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
        
        /*------------------------- mapOfChannelId -------------------------*/
        List<ASI_CRM_CN_Channel__c> existingChannels = new List<ASI_CRM_CN_Channel__c>();
        existingChannels = [
            SELECT Id, Name
            FROM ASI_CRM_CN_Channel__c
            WHERE RecordTypeId = :Schema.SObjectType.ASI_CRM_CN_Channel__c.RecordTypeInfosByName.get('MY Segmentation Channel').RecordTypeId
            AND Name IN :setInputChannel
        ];
        
        if(existingChannels != NULL && existingChannels.size() > 0)
            for(ASI_CRM_CN_Channel__c Channel : existingChannels){
                mapOfChannelId.put(Channel.Name, Channel.id);
            }
        system.debug(mapOfChannelId);
        
        /*------------------------- mapOfOutletImageId -------------------------*/
        List<ASI_TH_CRM_OutletImage__c> existingOutletImages = new List<ASI_TH_CRM_OutletImage__c>();
        existingOutletImages = [
            SELECT Id, Name
            FROM ASI_TH_CRM_OutletImage__c
            WHERE RecordTypeId = :Schema.SObjectType.ASI_TH_CRM_OutletImage__c.RecordTypeInfosByName.get('MY Outlet Image').RecordTypeId
            AND Name IN :setInputOI
        ];
        
        if(existingOutletImages != NULL && existingOutletImages.size() > 0)
            for(ASI_TH_CRM_OutletImage__c OutletImage: existingOutletImages){
                mapOfOutletImageId.put(OutletImage.Name, OutletImage.id);
            }
            
        /*------------------------- mapOfOutletTypeId -------------------------*/

    }
    
    public Pagereference ReadFile(){
        //init();
        
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

        sitetoupload = new List<ASI_CRM_AccountsAdditionalField__c>();
        
        if(filelines.size() == 1){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Invalid file format. / the file contains at lease one record.'));
            return null;
        }
        
        try{
            set<string> setInputCus = new set<string>();
            set<string> setInputChannel = new set<string>();
            set<string> setInputOI = new set<string>(); 
            
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                
                string strCus = inputvalues[0];
                string strChannel = inputvalues[1];
                string strOutletImage = inputvalues[5];
                
                setInputCus.add(strCus);
                setInputChannel.add(strChannel);
                setInputOI.add(strOutletImage);
            }
            
            init(setInputCus, setInputChannel, setInputOI);
            
            for(Integer i = 1; i < filelines.size(); i++){
                String[] inputvalues = new String[]{};
                inputvalues = filelines[i].split(',');
                
                ASI_CRM_AccountsAdditionalField__c s = new ASI_CRM_AccountsAdditionalField__c();
                
                // add duplicate later, null
                if(mapOfCustomerId.get(inputvalues[0]) == NULL){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Customer ' + inputvalues[0] + ' cannot be found in the system.'));
                }
                
                s.id = mapOfCustomerId.get(inputvalues[0]);
                s.ASI_CRM_MY_CustomerCode__c = inputvalues[0];
                s.ASI_CRM_Segmentation_Channel__c = mapOfChannelId.get(inputvalues[1]); //if doesnt match, will return null automatically
                s.ASI_CRM_CN_Grade__c = inputvalues[2];
                s.ASI_CRM_Rank__c = inputvalues[3];
                s.ASI_CRM_OutletStrategy__c = inputvalues[4];
                s.ASI_TH_CRM_OutletImage__c = mapOfOutletImageId.get(inputvalues[5]);
                s.ASI_CRM_Volume__c = inputvalues[6];
                s.ASI_CRM_ContractedBrand__c = inputvalues[7]; //it will check null automatically
                s.ASI_CRM_GMA__c = inputvalues[8];
                s.ASI_CRM_Counterfeit__c = inputvalues[9];
                s.ASI_CRM_MarketShare__c = inputvalues[10];
                //if(inputvalues.size() == 12 && inputvalues[11] != NULL)
                    s.ASI_CRM_Market_Responsibility__c = inputvalues[11];
                
                system.debug('************************');
                system.debug('**' + s.id);
                system.debug('**' + s.ASI_CRM_MY_CustomerCode__c);
                system.debug('** inputvalues  : ' + inputvalues);
                system.debug('************************');
                
                sitetoupload.add(s);
            }
            update sitetoupload;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'All the record has been successfully updated.'));
        }
        catch(Exception e){
            //ApexPages.Message errormsg = new ApexPages.Message(ApexPages.severity.ERROR,'The following exception has occurred: ' + e.getMessage());
            //ApexPages.addMessage(errormsg);
            system.debug('---------------SYSTEM ERROR : ' + e.getMessage());
            //getTypeName
            if(e.getTypeName() == 'System.DmlException')
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : Mismatched data has occurred on row' + e.getNumDml()));
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error : Please check the template or try again later'));
        }
        
        return null;
    }

    public List<ASI_CRM_AccountsAdditionalField__c> getuploadedsite(){
        if(sitetoupload != NULL && sitetoupload.size() > 0)
            return sitetoupload;
        else
            return null;
    }
}