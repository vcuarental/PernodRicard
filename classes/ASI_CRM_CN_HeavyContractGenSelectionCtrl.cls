//ASI_CRM_CN_HeavyContractGenerationPage 
public class ASI_CRM_CN_HeavyContractGenSelectionCtrl {
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;} {ContractSelected= new ASI_TH_CRM_Contract__c();}
    public string ContractTemplateId {set;get;} {ContractTemplateId='';}
    public List<SelectOption> TemplateSelectOption {set;get;}{TemplateSelectOption= new List<SelectOption>();}
    
    
    
    public boolean ProcessPermission {get;set;}{ProcessPermission=true;}
    public String Msg {get;set;} {Msg='';}
    
    
    
    public ASI_CRM_CN_HeavyContractGenSelectionCtrl(){}
    
    
    public void init(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String contractId = params.get('id');
       // Contract = [SELECT Id,Name, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:contractId ];
        
        ContractSelected = [SELECT Id,Name, ASI_CRM_Contract_Template_Id__c,ASI_CRM_CN_No_of_Months__c,ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Status__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,
                            ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE id =:contractId ];
        
        Boolean NeedGoToInputDetailPage=false;
        //Check if user have input the required Field 
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractline:  [SELECT Id,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,ASI_CRM_Sub_Brand_Grade__r.Name,ASI_CRM_Product_Category__r.Name,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,ASI_CRM_CN_Contract__c,ASI_CRM_Type__c,  ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, ASI_CRM_CN_Activity_Code__c  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c W
                                                                  wHERE ASI_CRM_CN_Contract__c = :ContractSelected.Id ] )
        {
            if(contractline.ASI_CRM_CN_Contract_Monthly_Qty__c==Null){
                NeedGoToInputDetailPage = true;
            }
            
            if(contractline.ASI_CRM_CN_Est_Monthly_Qty__c==Null){
                 NeedGoToInputDetailPage = true;
            }
        }

        if( NeedGoToInputDetailPage){
            ProcessPermission=false;
            Msg='请先去‘新增合同细节’页面输入信息。Please go to Edit Contract Detail Page firstly. ';
        }
        
        
        
        
        TemplateSelectOption= new List<SelectOption>();
        
        String FolderDeveloperName='ASI_CRM_CN';
        
        FolderDeveloperName+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? '_'+ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c.replace(' Region',''):'';
        FolderDeveloperName+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? '_'+ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
        
        
        
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c==null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c==null){
            FolderDeveloperName+='_General';
        }
        FolderDeveloperName = FolderDeveloperName.replace(' ','');
        
        
         Folder FolderSelected = new Folder();
        List<Document> DocumentFileList  = new List<Document>();
        try{
            system.debug('Finally we get1 '+FolderDeveloperName);
            FolderSelected =[select id,DeveloperName from Folder where DeveloperName=:FolderDeveloperName limit 1 ];
            DocumentFileList =[select id,Body,FolderId,LastModifiedDate,DeveloperName from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc ]; 
        }catch(exception e){
            try{
                FolderDeveloperName='ASI_CRM_CN';
                FolderDeveloperName+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? '_'+ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c.replace(' Region',''):'';
                FolderDeveloperName = FolderDeveloperName.replace(' ','');
                system.debug('Finally we get2 '+FolderDeveloperName);
                FolderSelected =[select id,DeveloperName from Folder where DeveloperName=:FolderDeveloperName limit 1 ];
                DocumentFileList =[select id,Body,FolderId,LastModifiedDate,DeveloperName from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc]; 
            }catch(exception e2){
                system.debug('Finally we get ASI_CRM_CN_General');
                if(!Test.isRunningTest()){
                    FolderSelected =[select id,DeveloperName from Folder where DeveloperName='ASI_CRM_CN_General' limit 1 ];DocumentFileList =[select id,Body,FolderId,LastModifiedDate,DeveloperName from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc ];
                }else{
                     DocumentFileList =[select id,Body,FolderId,LastModifiedDate,DeveloperName from Document where DeveloperName ='ASI_CRM_CN_Heavy_Test_document' ];
                }
                
            }
            
        }
        
        for(Document docTmep:DocumentFileList ){TemplateSelectOption.add(new SelectOption(docTmep.Id, docTmep.DeveloperName));system.debug(docTmep.DeveloperName);
        }
        
        
        
        
    }
    
    public PageReference proceed() {
        
        
        try{ 
            ContractSelected.ASI_CRM_Contract_Template_Id__c = ContractTemplateId;
            update ContractSelected;
        }catch(Exception e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractUtilitiesClass.RestructureHistoricalFinancialIndicatorData <br/> in ASI_CRM_CN_ViewHeavyContractPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_ViewHeavyContractCtrl','Calculation function failed! with contract Id: '+ContractSelected.id );
        }
        
        
        
        
        if(ProcessPermission){
            String url='/apex/ASI_CRM_CN_HeavyContractGenerationPage?edit=1&id='+ContractSelected.Id+'&TemplateId='+ContractTemplateId;
            return new pageReference(url); 
        }else{
           return Null;
        }
        
        
        
    }
    
    public PageReference ProceedDirect() {
        String url='/apex/ASI_CRM_CN_HeavyContractGenerationPage?edit=1&id='+ContractSelected.Id+'&TemplateId='+ContractSelected.ASI_CRM_Contract_Template_Id__c;
        return new pageReference(url); 
        
    }
    
    
}