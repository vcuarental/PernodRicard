/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_HeavyContractGenerationCtrl
 * Description: Controller for Heavy Contract Generation
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-07-18       Tony Ren                Created
 * 2019-01-29       Hector Tsang            INC0069530 - Change condition of adding postfix
 ****************************************************************************************************************************/

global class ASI_CRM_CN_HeavyContractGenerationCtrl {

    public String xmlStringTestClass {get; set;}{xmlStringTestClass='';}
    public String contractId   {get; set;}
    public String fcdisplayType{GET;SET;}
    public String psfdisplayType{GET;SET;}
    public String vecdisplayType{GET;SET;}
    public boolean isChange = false;
    public boolean isPSFChange = false;
    public boolean isVECChange = false;
    public Boolean isPSFEditable  {get; set;}{isPSFEditable = false;}
    public Boolean isVECEditable  {get; set;}{isPSFEditable = false;}
    public Boolean isEditable  {get; set;}
    public String partName   {get; set;}
    public String TodayString  {get; set;}{TodayString='';}
    public Boolean HightLight {get; set;}
    public String PartyCLegalName='';
    public Boolean IsApprovedVersion {get; set;} {IsApprovedVersion=false;}
    public Boolean dummyVar { get { if (dummyVar != true) {dummyVar = init();} return dummyVar; } set; }
    public ASI_TH_CRM_Contract__c ContractSelected {set;get;}
    public Map<integer, SectionWrapper> headerSectionMap   {get; set;}
    public Map<integer, SectionWrapper> BodySectionMap     {get; set;}
    public Map<integer, SectionWrapper> BodySignatureMap     {get; set;}
    public Map<integer, SectionWrapper> PartyCBodySignatureMap     {get; set;}
    
    public Map<integer, SectionWrapper> AppendixSectionMap {get; set;}
    public Map<integer, SectionWrapper> AppendixSignatureMap {get; set;}
    private Map<String, String> ContractSettingMap   {get; set;}{ContractSettingMap= new Map<String, String>();}
    private Integer BodyContentCuttingNumber = 38;
    private Integer InnerContentCuttingNumber = 37;
    private Set<String> KeySubBrandSet = new Set<String> ();
    public Boolean ExistTwoParty   {get; set;}{ExistTwoParty=false;}
    private Set<String> PartyCIDSet = new Set<String> ();
    public ASI_CRM_CN_HeavyContractGenerationCtrl() {}
    private String reservedPattern = '[.,;。，、:：；　 \'"/）)]';
    private List<ASI_CRM_CN_Covered_Outlet__c> CoveredOutletList = new List<ASI_CRM_CN_Covered_Outlet__c>(); 
    public Boolean onlyTotalChange{GET;SET;}{onlyTotalChange = true;}
    
    
    public Boolean init() {
        CoveredOutletList = new List<ASI_CRM_CN_Covered_Outlet__c>();
        
        TodayString=string.valueOf(system.today());
        IsApprovedVersion=false;
        //Finding Contract header   
        ContractSelected = [SELECT Id,Name,ASI_CRM_Expected_V0_BRSF_Estimated_Total__c,ASI_CRM_Expected_V0_PSF_Estimated_Total__c, ASI_CRM_CN_Is_2nd_KPI_PO__c,
                                   ASI_CRM_CN_Two_Party_Contract_Template__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c,ASI_CRM_CN_No_of_Months__c,
                                   ASI_CRM_CN_Outlet_WS__r.Name,ASI_CRM_CN_Bottle_Collection_Rate__c, ASI_CRM_CN_Status__c,ASI_CRM_Martell_BC_Rate__c,
                                   ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c,ASI_CRM_Contract_Template_Id__c,
                                   ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c,ASI_CRM_CN_Generate_PSF_Type__c,ASI_CRM_CN_Generate_VEC_Type__c,
                                   ASI_CRM_CN_Generate_Contract_Type__c
                            FROM ASI_TH_CRM_Contract__c 
                            WHERE id =:contractId ];
        System.debug(LoggingLevel.INFO, '*** ContractSelected.ASI_CRM_CN_Generate_PSF_Type__c: ' + ContractSelected.ASI_CRM_CN_Generate_PSF_Type__c);
        if (!isChange && ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            fcdisplayType = ContractSelected.ASI_CRM_CN_Generate_Contract_Type__c != ''? ContractSelected.ASI_CRM_CN_Generate_Contract_Type__c:'total';
        }

        if (!isPSFChange && ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            psfdisplayType = ContractSelected.ASI_CRM_CN_Generate_PSF_Type__c != ''? ContractSelected.ASI_CRM_CN_Generate_PSF_Type__c:'item';
        }

        if (!isVECChange && ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            vecdisplayType = ContractSelected.ASI_CRM_CN_Generate_VEC_Type__c != ''? ContractSelected.ASI_CRM_CN_Generate_VEC_Type__c:'item';
        }

        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            if(ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplateOldOrNew(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,true).Id!=nuLL ){
                ExistTwoParty=true;
            }
        } else {
            if(ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplate(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c,true).Id!=nuLL ){
                ExistTwoParty=true;
            }
        }
        
        List<ASI_CRM_Contract_Printout_Setting__c> ContractSettingList =[select Id,ASI_CRM_Header_Section_Name__c,ASI_CRM_isVisible__c,ASI_CRM_Section_Content__c,ASI_CRM_Content_Section_Name__c from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c = :contractId];
        for(ASI_CRM_Contract_Printout_Setting__c ContractSetting:ContractSettingList){
            String SectionContent = ContractSetting.ASI_CRM_Section_Content__c!=null? ContractSetting.ASI_CRM_Section_Content__c: ' ';
            
            ContractSettingMap.put(ContractSetting.ASI_CRM_Content_Section_Name__c,SectionContent);
            if(ContractSetting.ASI_CRM_Content_Section_Name__c.contains('PartyC')){
                
                PartyCIDSet.add(ContractSetting.ASI_CRM_Content_Section_Name__c);
            }
        }
        
        // Covered Outlet
        CoveredOutletList = [SELECT id,Name, ASI_CRM_CN_Contract__c,ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Chi_Name__c, ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Address__c, ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c, ASI_CRM_CN_Outlet__c,ASI_CRM_CN_Outlet__r.Name,ASI_CRM_CN_Outlet__r.ASI_CRM_Account__c FROM ASI_CRM_CN_Covered_Outlet__c WHERE ASI_CRM_CN_Contract__c = :contractId];
        // loading XML 
        LoadDocumentFiles();
 
        UpdateHeaderSectionMap();

        UpdateBodySectionMap();
        
        UpdatingBodySignatureMap();

        UpdatingAppendixSignatureMap();

        //AppendixSignatureMap = BodySignatureMap;
        if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
            UpdateAppendixSectionMap2nd();
        } else {
            UpdateAppendixSectionMap();
        }
        

        return true;
    }

    public Pagereference changeCostType() {
        isChange = true;
        init();

        return null;
    }

    public Pagereference changePSFType() {
        isPSFChange = true;
        init();

        return null;
    }

    public Pagereference changeVECType() {
        isVECChange = true;
        init();

        return null;
    }
    
    public void UpdateHeaderSectionMap(){
        Boolean IsReadOnly=false;
        Map<String, String> params = ApexPages.currentPage().getParameters();
        if(params.containsKey('ViewType')){
            if(params.get('ViewType')=='Read'){
                IsReadOnly=true;
            }
        }
        
        for(integer key : headerSectionMap.keySet()) {
            String PartyAName='';
            if(headerSectionMap.get(key).name=='Sales and Branding Promotion Agreement'){
                //29/1/2019 - Changed by Laputa(Hector) - INC0069530 - Change condition of adding postfix
                if(ContractSelected.ASI_CRM_CN_Status__c=='Final' || ContractSelected.ASI_CRM_CN_Status__c=='Approved'){
                    headerSectionMap.get(key).content+='(最终版)';
                    IsApprovedVersion=true;
                }
                /* 29/1/2019 - Changed by Laputa(Hector) - INC0069530 - Change condition of adding postfix
                if(IsReadOnly){
                    if(ContractSelected.ASI_CRM_CN_Status__c=='Approved'){
                        headerSectionMap.get(key).content+='(最终版)';
                        IsApprovedVersion=true;
                    }
                }else if(!HightLight){
                    if(ContractSelected.ASI_CRM_CN_Status__c!='Draft'){
                        headerSectionMap.get(key).content+='(最终版)';
                        IsApprovedVersion=true;
                    }
                }
                */
            }
            if(headerSectionMap.get(key).name=='Party A' ){
                
                if(headerSectionMap.get(key).content.contains('{1}')){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                        PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                    }else{
                        PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                    }
                    List<String> fillers = new String[] {'',PartyAName};
                    headerSectionMap.get(key).content = String.format(headerSectionMap.get(key).content, fillers);
                }else if(headerSectionMap.get(key).content.contains('{InputWholesaler}')){
                    
                }
                //{InputWholesaler}
            }
            
            if(headerSectionMap.get(key).name=='Party C' ){
                List<String> fillers = new List<String>() ;
                fillers = new String[] {'',GeneratingPartyC_Header(false)  };
                headerSectionMap.get(key).content = String.format(headerSectionMap.get(key).content, fillers);
                
                if(HightLight){
                    String FillersStr='<br/>本协议期限自{1}年{2}月{3}日 至{4}年{5}月{6}日。';
                    List<String> DateFillers = new String[] {'',String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())};
                        
                        headerSectionMap.get(key).content +=String.format(FillersStr, DateFillers);
                }
            }
            
            if(headerSectionMap.get(key).content.contains('{InputWholesaler}')){
                //system.debug('*****************InputWholesaler*******************');
                //system.debug(headerSectionMap.get(key).name);
                headerSectionMap.get(key).content = headerSectionMap.get(key).content.replace('{InputWholesaler}', GeneratingEffectiveSupplierInput(headerSectionMap.get(key).name,false) );
            }
        }
    }
    
    //*******************************************Main Body *******************************************
    public void UpdateBodySectionMap(){
        for(integer key : BodySectionMap.keySet()) {
            //Main Body Split Line
            BodySectionMap.get(key).content=SplitLineIntoRow(BodySectionMap.get(key).content,BodyContentCuttingNumber);
            BodySectionMap.get(key).content=BodySectionMap.get(key).content.replace('/n','&nbsp;');
            
            
            
            //update date in the Body Section
            if(BodySectionMap.get(key).name!=null){
                if(BodySectionMap.get(key).name=='Terms of this Agreement' && ContractSelected.ASI_CRM_CN_PO_End_Date__c !=null && ContractSelected.ASI_CRM_CN_PO_Start_Date__c !=null){//system.debug('**********************************!!!**************************************');//system.debug(BodySectionMap.get(key).content);
                    List<String> fillers = new String[] {'',String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()),
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())};
                            BodySectionMap.get(key).content = String.format(BodySectionMap.get(key).content, fillers);
                }
            }
            
            if(BodySectionMap.get(key).subSectionMap!=null){
                //Looping child content 
                for(integer ChildKey : BodySectionMap.get(key).subSectionMap.keySet()){
                      // Split Line** Do not change the order
                    BodySectionMap.get(key).subSectionMap.get(ChildKey).content=SplitLineIntoRow(BodySectionMap.get(key).subSectionMap.get(ChildKey).content, BodyContentCuttingNumber-5 );
                    BodySectionMap.get(key).subSectionMap.get(ChildKey).content=BodySectionMap.get(key).subSectionMap.get(ChildKey).content.replace('/n','&nbsp;');
                    
                    if(BodySectionMap.get(key).subSectionMap.get(ChildKey).Name !=null ){
                        BodySectionMap.get(key).subSectionMap.get(ChildKey).content= ContentReplace( BodySectionMap.get(key).subSectionMap.get(ChildKey).content,BodySectionMap.get(key).subSectionMap.get(ChildKey).Name,BodySectionMap.get(key).subSectionMap.get(ChildKey).ClassName);
                        if(BodySectionMap.get(key).subSectionMap.get(ChildKey).type == 'Selectable'){// system.debug('Selectable child : ' + BodySectionMap.get(key).subSectionMap.get(ChildKey).Name);
                            BodySectionMap.get(key).subSectionMap.get(ChildKey).isShow = CheckingIsVisibleOrNot(BodySectionMap.get(key).subSectionMap.get(ChildKey).Name);
                        }
                    }
                }
            }
            if(BodySectionMap.get(key).type == 'Selectable'){
                BodySectionMap.get(key).isShow = CheckingIsVisibleOrNot(BodySectionMap.get(key).Name);
            }
        }
    }
    
    public void UpdatingBodySignatureMap(){
        //<img src="/resource/ASI_CN_Company_Chop" alt="CHOP" height="2cm" width="2cm" >  ChopSignature
        for(integer key : BodySignatureMap.keySet()) {
            
            String ContentStr= BodySignatureMap.get(key).content;
            if(ContentStr.indexOf('//')>-1){
                List<String> parts = ContentStr.split('//');
                if(parts.size()>0){
                    if(parts.size()>1){// Size 2+ 
                        String ChopString = '';
                        String whiteString = '';
                        if(parts[0].contains('{1}')){
                            String PartyAName='';
                            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                                PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                            }else{
                                PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                            }
                            parts[0] = parts[0].replace('{1}',PartyAName); 
                             
                            if(parts[1].contains('{2}')){
                                parts[1] = GeneratingPartyC_Header(true);
                            }
                            
                            
                            
                        }else if (BodySignatureMap.get(key).name == 'ChopSignature' && IsApprovedVersion){//ASI_CN_Company_Chop
                            ChopString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="CHOP" height="2cm" width="2cm" >';
                            whiteString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="Placeholder" height="2cm" width="2cm" >';
                        }else if(parts[0].contains('{InputWholesaler}')){
                            parts[0] = parts[0].replace('{InputWholesaler}', GeneratingEffectiveSupplierInput('Party A',true)); 
                        }
                        
                        
                       
                        BodySignatureMap.get(key).RightContent=parts[1]+ChopString;
                        BodySignatureMap.get(key).LeftContent=parts[0]+whiteString;
                    }
                    
                    if(parts.size()==1){
                        BodySignatureMap.get(key).isShow=false;
                        if(BodySignatureMap.get(key).name =='BodySignature2'){ // 丙     方
                        }
                        if(ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                            PartyCBodySignatureMap.get(key).LeftContent=parts[0];
                        }else{
                            BodySignatureMap.get(key).LeftContent=parts[0];
                        }
                        //PartyCBodySignatureMap.get(key).LeftContent=parts[0];
                    }
                }
            }
        }
    }
    
    
    public void UpdatingAppendixSignatureMap(){
        for(integer key : AppendixSignatureMap.keySet()) {
            
            String ContentStr= AppendixSignatureMap.get(key).content;
            if(ContentStr.indexOf('//')>-1){
                List<String> parts = ContentStr.split('//');
                if(parts.size()>0){
                    if(parts.size()>1){// Size 2+ 
                        String ChopString = '';
                        String whiteString = '';
                        if(parts[0].contains('{1}')){
                            String PartyAName='';
                            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                                PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                            }else{
                                PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                            }
                            parts[0] = parts[0].replace('{1}',PartyAName); 
                             
                            if(parts[1].contains('{2}')){
                                parts[1] = GeneratingPartyC_Header(true);
                            }
                            
                            
                            
                        }else if (AppendixSignatureMap.get(key).name == 'ChopSignature' && IsApprovedVersion){//ASI_CN_Company_Chop
                            ChopString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="CHOP" height="2cm" width="2cm" >';
                            whiteString+= '<img src="/resource/ASI_CN_Company_Chop_Placeholder" alt="Placeholder" height="2cm" width="2cm" >';
                        }else if(parts[0].contains('{InputWholesaler}')){
                            parts[0] = parts[0].replace('{InputWholesaler}', GeneratingEffectiveSupplierInput('Party A',true)); 
                        }
                        
                        if(parts[1].contains('.')){
                            parts[1] =' ';
                        }
                       
                        AppendixSignatureMap.get(key).RightContent=parts[1]+ChopString;
                        AppendixSignatureMap.get(key).LeftContent=parts[0]+whiteString;
                    }
                    
                }
            }
        }
       
    }
    
    
    
    
    public void UpdateAppendixSectionMap2nd(){// Sales_Discount_of_A_Class
        System.debug(LoggingLevel.INFO, '*** : UpdateAppendixSectionMap Start RUNING-------------------------------->');
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Map<String,interimData> PSF_Item_Map= new Map<String,interimData>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> VECList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ClubList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> StoreList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        String VECVolumeBase='';
        Boolean HasPSFModule=false;
        KeySubBrandSet = new Set<String> ();
        Decimal PSFBySubBrandTotal= 0.0;
        Decimal PSFByTotalAmount= 0.0;
        
        Decimal PSFTotalContractAmount= 0;
        Decimal VECTotalAmount= 0.0;
        Decimal BRSFTotalAmount=0.0;
        String CoveredOutletListString='';
        Boolean DisplayFixedCostTable=false;
        DataSummaryClass dsc = new DataSummaryClass();
        
        
        //Looping BRSF Line
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractline:  [SELECT Id,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                                                                  ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                                  ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                                  ASI_CRM_Sub_Brand_Grade__r.Name,ASI_CRM_Product_Category__r.Name,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
                                                                  ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, 
                                                                  ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                                                  ASI_CRM_CN_Contract__c,ASI_CRM_Type__c,  ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, 
                                                                  ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, 
                                                                  ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, 
                                                                  ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, 
                                                                  ASI_CRM_CN_Activity_Code__c,ASI_CRM_Module__r.ASI_CRM_CN_AC_Code__r.Name,ASI_CRM_Module__r.ASI_CRM_Remark__c
                                                                  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c 
                                                                  WHERE ASI_CRM_CN_Contract__c = :contractId ] )
        {
            if(contractline.ASI_CRM_Type__c=='BRSF' && contractline.ASI_CRM_CN_Sub_Brand__c!=null && contractline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' ){
                BRSFList.add(contractline);
                BRSFTotalAmount+= contractline.ASI_CRM_CN_Contract_Total_Dummy__c== null? 0:contractline.ASI_CRM_CN_Contract_Total_Dummy__c;
            }
            if(contractline.ASI_CRM_Type__c=='PSF'){
                PSFTotalContractAmount  += contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c; 
                if(contractline.ASI_CRM_Volume_Base__c =='By Sub-Brand' ){
                    isPSFEditable = true;
                    PSFBySubBrandTotal += contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c; // ASI_CRM_CN_Contract_Total_Dummy__c  ASI_CRM_CN_Contract_Total__c
                }
                if(contractline.ASI_CRM_Volume_Base__c =='By Total'){
                    PSFByTotalAmount += contractline.ASI_CRM_CN_Contract_Total_Dummy__c== null? 0:contractline.ASI_CRM_CN_Contract_Total_Dummy__c; 
                }
                if(contractline.ASI_CRM_Key_Sub_brand__c){
                    KeySubBrandSet.add(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c);
                }
                if(contractline.ASI_CRM_Module__c!=null){
                    HasPSFModule=true;
                    if(PSF_Item_Map.containsKey(contractline.ASI_CRM_Module__c)){
                        PSF_Item_Map.get(contractline.ASI_CRM_Module__c).DetailLineMap.put(contractline.Id,contractline);
                    }else{
                        interimData TempData= new interimData();
                        TempData.VolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                        PSF_Item_Map.put(contractline.ASI_CRM_Module__c,TempData);
                        PSF_Item_Map.get(contractline.ASI_CRM_Module__c).DetailLineMap.put(contractline.Id,contractline);
                    }
                }
                
            }
            if(contractline.ASI_CRM_Type__c=='Variable Event Cost'){
                VECTotalAmount+= contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c;
                if (contractline.ASI_CRM_Volume_Base__c == 'By Sub-Brand') {
                    isVECEditable = true;
                }
                if(contractline.ASI_CRM_CN_Sub_Brand__c!=null){
                    if(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' ){
                        VECVolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                        VECList.add(contractline); 
                    }
                }else{
                    VECVolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                    VECList.add(contractline);
                }
                
            }
            
            if (contractline.ASI_CRM_Type__c == 'Fixed') {
                DisplayFixedCostTable=true;
                if (contractline.ASI_CRM_Module__r.ASI_CRM_CN_AC_Code__r.Name.contains('Fixed Event Cost')) {
                    ClubList.add(contractline);
                    dsc.clubVolumeBase = contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                    dsc.clubVolumeRemark = contractline.ASI_CRM_Module__r.ASI_CRM_Remark__c;
                    dsc.clubAmountTotal += contractline.ASI_CRM_CN_Contract_Total__c;

                }else{
                    StoreList.add(contractline);
                    dsc.storeVolumeBase = contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                    dsc.storeVolumeRemark = contractline.ASI_CRM_Module__r.ASI_CRM_Remark__c;
                    dsc.storeAmountTotal += contractline.ASI_CRM_CN_Contract_Total__c;
                }
                dsc.amountTotal += contractline.ASI_CRM_CN_Contract_Total__c;

                if(contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c != 'By Total'){
                    onlyTotalChange = false;
                }
            }
        }
        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:CoveredOutletList)
        {
            if(CoveredOutlet.ASI_CRM_CN_Outlet__c!=null){
                if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c !=null){
                    CoveredOutletListString+='<li>'+ CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c + '</li>' ;
                }else{
                    CoveredOutletListString+='<li>'+ CoveredOutlet.ASI_CRM_CN_Outlet__r.Name + '</li>';
                }
                
            }
        }
        
        
        List<ASI_CRM_Contract_Cost__c> FixCostList= new List<ASI_CRM_Contract_Cost__c>();
        Map<Integer,ASI_CRM_Contract_Cost__c> FixCostMap= new Map<Integer,ASI_CRM_Contract_Cost__c>();
        //Contract Cost
        for(ASI_CRM_Contract_Cost__c cc:[SELECT id,
                                                name,
                                                ASI_CRM_CNY_Est__c,
                                                ASI_CRM_MAF_Est__c,
                                                ASI_CRM_Other_Est__c,
                                                ASI_CRM_CN_Activity_Code__c,
                                                ASI_CRM_CN_Chinese_Description__c,
                                                ASI_CRM_CN_Contract__c,
                                                ASI_CRM_CN_Contract_Amount__c,
                                                ASI_CRM_CN_Estimate_Amount__c,
                                                ASI_CRM_CN_Cost_Type__c,
                                                ASI_CRM_CN_Sequence__c,
                                                ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c 
                                         FROM ASI_CRM_Contract_Cost__c 
                                         WHERE ASI_CRM_CN_Contract__c=: contractId 
                                         order by ASI_CRM_CN_Sequence__c ASC,ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC]){
            if(cc.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                FixCostList.add(cc);
                if(cc.ASI_CRM_CN_Contract_Amount__c!=0 && cc.ASI_CRM_CN_Contract_Amount__c!=null){
                    DisplayFixedCostTable=true;
                }
                
                if(cc.ASI_CRM_CN_Chinese_Description__c=='店家支持'){
                    FixCostMap.put(0, cc);
                    system.debug('EETER 1'+cc.Id);
                }else{
                    FixCostMap.put(1, cc);
                    system.debug('EETER 2'+cc.Id);
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** dsc: ' + dsc);
        for(integer key : AppendixSectionMap.keySet()) {
            System.debug(LoggingLevel.INFO, '*** key: ' + key);
            System.debug(LoggingLevel.INFO, '*** FixCostMap: ' + FixCostMap);
            System.debug(LoggingLevel.INFO, '*** subSectionMap: ' + AppendixSectionMap.get(key).subSectionMap);
            //display item/total Header
            if(AppendixSectionMap.get(key).name == 'FixCostItemClubTableHeader' && ClubList.isEmpty()){
                AppendixSectionMap.get(key).content='';
            }else if(AppendixSectionMap.get(key).name == 'FixCostItemTableHeader' && StoreList.isEmpty()){
                AppendixSectionMap.get(key).content='';
            }else
            if (AppendixSectionMap.get(key).name == 'FixCostItemClubTableHeader' && fcdisplayType != 'item') {
                AppendixSectionMap.get(key).content='';
            }else if (AppendixSectionMap.get(key).name == 'FixCostItemTableHeader' && fcdisplayType != 'item') {
                AppendixSectionMap.get(key).content='';
            }else if(AppendixSectionMap.get(key).name =='FixCostItemClubTable'){
                if(!ClubList.isEmpty()  && fcdisplayType != 'total'){
                    AppendixSectionMap.get(key).content= GenerateFixClubItemTable(AppendixSectionMap.get(key).content,ClubList,AppendixSectionMap.get(key),dsc);
                }else{
                    AppendixSectionMap.get(key).isShow=false;
                    AppendixSectionMap.get(key).content='';
                }
            }else if (AppendixSectionMap.get(key).name =='FixCostItemTable') {
                if(!StoreList.isEmpty()  && fcdisplayType != 'total'){
                    AppendixSectionMap.get(key).content= GenerateFixItemTable(AppendixSectionMap.get(key).content,StoreList,AppendixSectionMap.get(key),dsc);
                }else{
                    AppendixSectionMap.get(key).isShow=false;
                    AppendixSectionMap.get(key).content='';
                }
            }else if( AppendixSectionMap.get(key).name =='FixCostTable'){
                //Handle fix cost table
                if(DisplayFixedCostTable && fcdisplayType != 'item'){ // generate Fix cost table
                    AppendixSectionMap.get(key).content  = GenerateFixCostTable2nd (key,FixCostMap,AppendixSectionMap.get(key).subSectionMap,dsc);
                    system.debug('*******GenerateFixCostTable2nd*********');
                    system.debug(AppendixSectionMap.get(key).content);
                }else{
                    AppendixSectionMap.get(key).content='';
                    AppendixSectionMap.get(key).isShow= false;
                }
            }else if(AppendixSectionMap.get(key).name.contains('FixCostTableHeader') || AppendixSectionMap.get(key).name.contains('FixCostTableLineHeader') ){
                if(!DisplayFixedCostTable){
                    AppendixSectionMap.get(key).content='';
                    AppendixSectionMap.get(key).displayNumber='';
                    AppendixSectionMap.get(key).isShow= false;
                }
            }
            else if( AppendixSectionMap.get(key).name =='SalesDiscount'){  //handle BRSF table, PSF, VEC table
                AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Sales_Discount_of_A_Class' && BRSFList.size()==0){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('BRSFTable')){
                        
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'BRSFTable'){
                            if(BRSFList.size()>0){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= DrawingBRSFTable(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,BRSFList,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                            }else{
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }
                        }
                         if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'BRSFTable_Incentive'){
                            if(BRSFList.size()>0){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= DrawingBRSFTableIncentive(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,BRSFList,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                            }else{
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }
                        }
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Non_standard_Convert'){ //English version 
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type!='Editable'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,67);
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content=AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replaceAll('nbsp','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ');   //else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Sales_Discount_of_B_Class' && !HasPSFModule ){AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;}
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name =='PSFTableHeader' && !HasPSFModule){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name =='PSFTable'){
                        // Drawing PSF Table 
                        if(HasPSFModule){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= DrawingPSFTable2nd(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,PSF_Item_Map,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                        }else{
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        }
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Event_Support' && VECList.size()==0){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Event_Support 1' && VECList.size()==0){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'VECTable'){
                        if(VECList.size()>0){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = DrawingVECTable2nd(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,VECVolumeBase,VECList,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                        }else{
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                            
                            
                        }
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('KeySubBrandPart')){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{Key-SubBrand}')){
                            if(KeySubBrandSet.size()>0){
                                String SubBrandNames= String.valueOf(KeySubBrandSet);
                                SubBrandNames= SubBrandNames.replace('{','');
                                SubBrandNames= SubBrandNames.replace('}','');
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content=AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{Key-SubBrand}', SubBrandNames); 
                            }
                        }
                        if(KeySubBrandSet.size()<=0){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = ''; 
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputPSFTotalAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputPSFTotalAmount}',PSFTotalContractAmount.format() );  
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber);
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = '<div>'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content+'</div>';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='PSFBySubBrandItems'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputSubBrandTotal}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content =AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputSubBrandTotal}', PSFBySubBrandTotal.format());   // String.valueOf(PSFBySubBrandTotal) PSFBySubBrandTotal   //AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount2'+'" />');
                        }
                        
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,40));
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='PSFByTotalItems'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputByTotalAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputByTotalAmount1}', PSFByTotalAmount.format());  //UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1'); // AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputByTotalAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputByTotalAmount2}',PSFByTotalAmount.format() );  
                        }
                        
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent2');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent2}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent2'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount2');
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,40));
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Event_Support Remark'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputVECAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputVECAmount1}',VECTotalAmount.format());//UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputVECAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputVECAmount2}',VECTotalAmount.format());//UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount1'+'" />');
                        }
                        
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent2'); // AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent2}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent2'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount2');
                        }
                        
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,40));
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='ContractLineAddOn'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputPSFTotalAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputPSFTotalAmount}',PSFTotalContractAmount.format() );  
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{BRSFTotalContractAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{BRSFTotalContractAmount}', BRSFTotalAmount.format() );  
                        }
                        
                       
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber));
                    }else{
                        system.debug('Test 1.0 : '+ AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content );
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type!='Editable'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber);
                        }
                        
                    }
                    
                    
                    
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName!=null){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName.contains('VECRemark') && VECList.size()==0 ){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type = 'Read'; 
                        }
                    }
                    
                    
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type=='Selectable'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)){
                            if(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)=='false'){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }                                
                        }
                    }
                    
                    
                }
            }
            else if( AppendixSectionMap.get(key).name =='Payment Conditions'){                
                //looping child node
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Payment_ConditionsC'){
                        List<String> fillers = new String[] {String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day()),BRSFTotalAmount.format()};
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = String.format(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, fillers);
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount}')){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount'); // AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount'+'" />');
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Payment_Conditions_BC_Rate'){//Assign BC Rate
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content =AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{MartellBCRate}',ContractSelected.ASI_CRM_Martell_BC_Rate__c.setScale(0)+'%');                           
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content =AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{BCRate}',ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c.setScale(0)+'%');                           
                    }
                    
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)){
                        //system.assertEquals(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name), Null);
                        if(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)=='false'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        }                                
                    }
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{BRSFTotalContractAmount}')){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{BRSFTotalContractAmount}', BRSFTotalAmount.format() );  
                    }
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('KeySubBrandPart')){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{Key-SubBrand}')){
                            if(KeySubBrandSet.size()>0){
                                String SubBrandNames= String.valueOf(KeySubBrandSet);
                                SubBrandNames= SubBrandNames.replace('{','');
                                SubBrandNames= SubBrandNames.replace('}','');
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content=AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{Key-SubBrand}', SubBrandNames);
                            }
                        }
                        if(KeySubBrandSet.size()<=0){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = ''; 
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputPSFTotalAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputPSFTotalAmount}',PSFTotalContractAmount.format() );  
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber);
                        //AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = '<div>'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content+'</div>';
                    }
                    if(!isEditable && AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName !=null &&
                       AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName.contains('IncludeNumber') ){
                        system.debug('ClassName log : '+ AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName);
                         AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,BodyContentCuttingNumber);
                   
                    }else if(!isEditable){ //AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,InnerContentCuttingNumber);
                    }
                    AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                }
                
            }
           else if( AppendixSectionMap.get(key).name =='Affiliates_List'){
                if(CoveredOutletListString==''){
                    AppendixSectionMap.get(key).isShow=false; 
                }
                
                AppendixSectionMap.get(key).content =  AppendixSectionMap.get(key).content.replace('{Outlet}','<ul>'+CoveredOutletListString+'</ul>');   
                
                
            }
            else if(AppendixSectionMap.get(key).name.contains('AppendixGeneral') || AppendixSectionMap.get(key).name =='Party A undertakes' ){// general part 
                AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                if(AppendixSectionMap.get(key).hasSubSection){
                    //loop child content
                    for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                        String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                        
                        //case 1: if contain '{InputText}'
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputText}')){
                            String ContentText =  ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText') ? 
                                ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText'): '';
                            
                            if(!isEditable){ 
                                //PDF
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = 
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputText}', SplitLineIntoRow(ContentText,InnerContentCuttingNumber) );
                                
                                if(!ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText') ){
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                                }else if(ContentText=='' ||ContentText==' '){
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                                }else if(ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name) ){
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=
                                        ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name)); 
                                }
                            }else{
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputText}', '<textarea cols="30" rows="3" class="InputText " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText"  >'+ContentText+'</textarea>');
                            }
                        }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('FixCostTable')){//Case 2
                            system.debug('case 2 ');
                            system.debug(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name);
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content  = GenerateFixCostTable (ChildKey,FixCostMap,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).subSectionMap);
                        }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type=='Editable'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= GeneratingInputText(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name +'InputText',AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content);
                            if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ==''){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }
                        }else{
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitStringLine(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content);
                        }
                    }
                }
                
            }else if(AppendixSectionMap.get(key).name.contains('Terms of this Agreement') ){
                   List<String> DateFillers = new String[] {'',String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())};
                            
                            AppendixSectionMap.get(key).content =String.format(AppendixSectionMap.get(key).content, DateFillers);
                 
                        
            }else if(AppendixSectionMap.get(key).name=='Party A' ){
                String PartyAName = ''; 
                if(AppendixSectionMap.get(key).content.contains('{1}')){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                        PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                    }else{
                        PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                    }
                    List<String> fillers = new String[] {'',PartyAName};
                        AppendixSectionMap.get(key).content = String.format(AppendixSectionMap.get(key).content, fillers);
                } else if(AppendixSectionMap.get(key).content.contains('{InputWholesaler}')){
                    AppendixSectionMap.get(key).content = AppendixSectionMap.get(key).content.replace('{InputWholesaler}', GeneratingEffectiveSupplierInput('Party A',true)); 
                   
                }
                 AppendixSectionMap.get(key).content = SplitLineIntoRow(AppendixSectionMap.get(key).content,BodyContentCuttingNumber);
                
                
            }else if(AppendixSectionMap.get(key).name =='Party C' ){
                List<String> fillers = new List<String>() ;
                fillers = new String[] {'',GeneratingPartyC_Header(true)  };
                AppendixSectionMap.get(key).content = String.format(AppendixSectionMap.get(key).content, fillers);                
            }
            else{ //others 
                AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                if(AppendixSectionMap.get(key).hasSubSection){
                    for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitStringLine(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content);
                    }
                }
            }
            
            if(AppendixSectionMap.get(key).content.contains('{CoveredOutletTable}')){
                AppendixSectionMap.get(key).content = AppendixSectionMap.get(key).content.replace('{CoveredOutletTable}', GeneratingCoveredOutletTable());
            }
            
            
            //general second looping 
            if(AppendixSectionMap.get(key).hasSubSection){
                if(AppendixSectionMap.get(key).subSectionMap!=null){
                    for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                        //case 1 editable
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type =='Editable' && AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name)){
                            
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name);
                        }
                      
                    }
                }
            }
            if(AppendixSectionMap.get(key).type =='Editable' && AppendixSectionMap.get(key).name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).name)){
                AppendixSectionMap.get(key).content = ContractSettingMap.get(AppendixSectionMap.get(key).name);
                system.debug('Ha:'+AppendixSectionMap.get(key).content);
            }
        }
        ReOrdering();
    }

    public void UpdateAppendixSectionMap(){// Sales_Discount_of_A_Class
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        Map<String,interimData> PSF_Item_Map= new Map<String,interimData>();
        List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> VECList = new List<ASI_CRM_CN_Contract_BRSF_Line_Item__c>();
        String VECVolumeBase='';
        Boolean HasPSFModule=false;
        KeySubBrandSet = new Set<String> ();
        Decimal PSFBySubBrandTotal= 0.0;
        Decimal PSFByTotalAmount= 0.0;
        
        Decimal PSFTotalContractAmount= 0;
        Decimal VECTotalAmount= 0.0;
        Decimal BRSFTotalAmount=0.0;
        String CoveredOutletListString='';
        Boolean DisplayFixedCostTable=false;
        
        
        
        
        //Looping BRSF Line
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c contractline:  [SELECT Id,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c,
                                                                  ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c,ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c,
                                                                  ASI_CRM_Contract_Total_QTY_std_Btl__c,ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c,
                                                                  ASI_CRM_Sub_Brand_Grade__r.Name,ASI_CRM_Product_Category__r.Name,ASI_CRM_Module__r.ASI_CRM_Volume_Base__c,
                                                                  ASI_CRM_Module__c, ASI_CRM_Sub_Brand_Grade__c ,ASI_CRM_Product_Category__c , ASI_CRM_Volume_Base__c, 
                                                                  ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__c,ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_Sub_brand_Grade__r.Name,
                                                                  ASI_CRM_CN_Contract__c,ASI_CRM_Type__c,  ASI_CRM_Key_Sub_brand__c, ASI_CRM_CN_Sub_Brand__r.Name, 
                                                                  ASI_CRM_CN_Contract_BRSF_Per_Bottle__c, ASI_CRM_CN_Contract_Monthly_Qty__c, ASI_CRM_CN_Contract_Total__c, 
                                                                  ASI_CRM_CN_Est_BRSF_Per_Bottle__c, ASI_CRM_CN_Est_Monthly_Qty__c, ASI_CRM_CN_Est_Total__c, ASI_CRM_CN_Sub_Brand__c, 
                                                                  ASI_CRM_CN_Contract_Total_Dummy__c,ASI_CRM_CN_Est_Total_Dummy__c, ASI_CRM_CN_No_of_Months__c, 
                                                                  ASI_CRM_CN_Activity_Code__c  
                                                                  FROM ASI_CRM_CN_Contract_BRSF_Line_Item__c W
                                                                  wHERE ASI_CRM_CN_Contract__c = :contractId ] )
        {
            if(contractline.ASI_CRM_Type__c=='BRSF' && contractline.ASI_CRM_CN_Sub_Brand__c!=null && contractline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' ){
                BRSFList.add(contractline);
                BRSFTotalAmount+= contractline.ASI_CRM_CN_Contract_Total_Dummy__c== null? 0:contractline.ASI_CRM_CN_Contract_Total_Dummy__c;
            }
            if(contractline.ASI_CRM_Type__c=='PSF'){
                PSFTotalContractAmount  += contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c; 
                if(contractline.ASI_CRM_Volume_Base__c =='By Sub-Brand' ){
                    PSFBySubBrandTotal += contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c; // ASI_CRM_CN_Contract_Total_Dummy__c  ASI_CRM_CN_Contract_Total__c
                }
                if(contractline.ASI_CRM_Volume_Base__c =='By Total'){
                    PSFByTotalAmount += contractline.ASI_CRM_CN_Contract_Total_Dummy__c== null? 0:contractline.ASI_CRM_CN_Contract_Total_Dummy__c; 
                }
                if(contractline.ASI_CRM_Key_Sub_brand__c){
                    KeySubBrandSet.add(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c);
                }
                if(contractline.ASI_CRM_Module__c!=null){
                    HasPSFModule=true;
                    if(PSF_Item_Map.containsKey(contractline.ASI_CRM_Module__c)){
                        PSF_Item_Map.get(contractline.ASI_CRM_Module__c).DetailLineMap.put(contractline.Id,contractline);
                    }else{
                        interimData TempData= new interimData();
                        TempData.VolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                        PSF_Item_Map.put(contractline.ASI_CRM_Module__c,TempData);
                        PSF_Item_Map.get(contractline.ASI_CRM_Module__c).DetailLineMap.put(contractline.Id,contractline);
                    }
                }
                
            }
            if(contractline.ASI_CRM_Type__c=='Variable Event Cost'){
                VECTotalAmount+= contractline.ASI_CRM_CN_Contract_Total__c== null? 0:contractline.ASI_CRM_CN_Contract_Total__c;
                if(contractline.ASI_CRM_CN_Sub_Brand__c!=null){
                    if(contractline.ASI_CRM_CN_Sub_Brand__r.ASI_MFM_Sub_brand_Code__c!= '999' ){
                        VECVolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                        VECList.add(contractline); 
                    }
                }else{
                    VECVolumeBase=contractline.ASI_CRM_Module__r.ASI_CRM_Volume_Base__c;
                    VECList.add(contractline);
                }
                
            }
        }
        
       
        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:CoveredOutletList)
        {
            if(CoveredOutlet.ASI_CRM_CN_Outlet__c!=null){
                if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c !=null){
                    CoveredOutletListString+='<li>'+ CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c + '</li>' ;
                }else{
                    CoveredOutletListString+='<li>'+ CoveredOutlet.ASI_CRM_CN_Outlet__r.Name + '</li>';
                }
                
            }
        }
        
        
        List<ASI_CRM_Contract_Cost__c> FixCostList= new List<ASI_CRM_Contract_Cost__c>();
        Map<Integer,ASI_CRM_Contract_Cost__c> FixCostMap= new Map<Integer,ASI_CRM_Contract_Cost__c>();
        //Contract Cost
        for(ASI_CRM_Contract_Cost__c cc:[Select id, name, ASI_CRM_CNY_Est__c, ASI_CRM_MAF_Est__c, ASI_CRM_Other_Est__c, ASI_CRM_CN_Activity_Code__c, ASI_CRM_CN_Chinese_Description__c, ASI_CRM_CN_Contract__c, ASI_CRM_CN_Contract_Amount__c, ASI_CRM_CN_Estimate_Amount__c,ASI_CRM_CN_Cost_Type__c, ASI_CRM_CN_Sequence__c, ASI_CRM_CN_Contract__r.ASI_TH_CRM_Promotion_Type__c from ASI_CRM_Contract_Cost__c where ASI_CRM_CN_Contract__c = :contractId order by ASI_CRM_CN_Sequence__c ASC, ASI_CRM_CN_Activity_Code__r.ASI_CRM_Promotion_Type__r.ASI_CRM_Sequence__c ASC]){
            if(cc.ASI_CRM_CN_Cost_Type__c == 'Fixed'){
                FixCostList.add(cc);
                if(cc.ASI_CRM_CN_Contract_Amount__c!=0 && cc.ASI_CRM_CN_Contract_Amount__c!=null){
                    DisplayFixedCostTable=true;
                }
                
                if(cc.ASI_CRM_CN_Chinese_Description__c=='店家支持'){
                    FixCostMap.put(0, cc);
                    system.debug('EETER 1'+cc.Id);
                }else{
                    FixCostMap.put(1, cc);
                    system.debug('EETER 2'+cc.Id);
                }
            }
        }
        
        
        for(integer key : AppendixSectionMap.keySet()) {
            
            //Handle fix cost table
            if( AppendixSectionMap.get(key).name =='FixCostTable'){
                if(DisplayFixedCostTable){ // generate Fix cost table
                    
                    AppendixSectionMap.get(key).content  = GenerateFixCostTable (key,FixCostMap,AppendixSectionMap.get(key).subSectionMap);
                    system.debug('*******GenerateFixCostTable*********');
                    system.debug(AppendixSectionMap.get(key).content);
                }
            }else if(AppendixSectionMap.get(key).name.contains('FixCostTableHeader') || AppendixSectionMap.get(key).name.contains('FixCostTableLineHeader') ){
                if(!DisplayFixedCostTable){
                    AppendixSectionMap.get(key).content='';
                    AppendixSectionMap.get(key).displayNumber='';
                    AppendixSectionMap.get(key).isShow= false;
                }
            }
            else if( AppendixSectionMap.get(key).name =='SalesDiscount'){  //handle BRSF table, PSF, VEC table
                AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Sales_Discount_of_A_Class' && BRSFList.size()==0){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('BRSFTable')){
                        
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'BRSFTable'){
                            if(BRSFList.size()>0){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= DrawingBRSFTable(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,BRSFList,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                            }else{
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }
                        }
                         if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'BRSFTable_Incentive'){
                            if(BRSFList.size()>0){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= DrawingBRSFTableIncentive(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,BRSFList,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                            }else{
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }
                        }
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Non_standard_Convert'){ //English version 
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type!='Editable'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,67);
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content=AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replaceAll('nbsp','&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ');   //else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Sales_Discount_of_B_Class' && !HasPSFModule ){AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;}
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name =='PSFTableHeader' && !HasPSFModule){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name =='PSFTable'){
                        // Drawing PSF Table 
                        if(HasPSFModule){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= DrawingPSFTable(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,PSF_Item_Map,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                        }else{
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        }
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Event_Support' && VECList.size()==0){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'Event_Support 1' && VECList.size()==0){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name == 'VECTable'){
                        if(VECList.size()>0){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = DrawingVECTable(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,VECVolumeBase,VECList,AppendixSectionMap.get(key).subSectionMap.get(ChildKey));
                        }else{
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                            
                            
                        }
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('KeySubBrandPart')){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{Key-SubBrand}')){
                            if(KeySubBrandSet.size()>0){
                                String SubBrandNames= String.valueOf(KeySubBrandSet);
                                SubBrandNames= SubBrandNames.replace('{','');
                                SubBrandNames= SubBrandNames.replace('}','');
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content=AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{Key-SubBrand}', SubBrandNames); 
                            }
                        }
                        if(KeySubBrandSet.size()<=0){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = ''; 
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputPSFTotalAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputPSFTotalAmount}',PSFTotalContractAmount.format() );  
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber);
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = '<div>'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content+'</div>';
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='PSFBySubBrandItems'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputSubBrandTotal}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content =AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputSubBrandTotal}', PSFBySubBrandTotal.format());   // String.valueOf(PSFBySubBrandTotal) PSFBySubBrandTotal   //AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount2'+'" />');
                        }
                        
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,40));
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='PSFByTotalItems'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputByTotalAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputByTotalAmount1}', PSFByTotalAmount.format());  //UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1'); // AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputByTotalAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputByTotalAmount2}',PSFByTotalAmount.format() );  
                        }
                        
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent2');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent2}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent2'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount2');
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,40));
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Event_Support Remark'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputVECAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputVECAmount1}',VECTotalAmount.format());//UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputVECAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputVECAmount2}',VECTotalAmount.format());//UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount1'+'" />');
                        }
                        
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent1');//AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent1}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent1'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent2'); // AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputPercent2}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputPercent2'+'" />');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount2}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount2');
                        }
                        
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,40));
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='ContractLineAddOn'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount1}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount1');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputPercent}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputPercent');
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputPSFTotalAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputPSFTotalAmount}',PSFTotalContractAmount.format() );  
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{BRSFTotalContractAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{BRSFTotalContractAmount}', BRSFTotalAmount.format() );  
                        }
                        
                       
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = CheckingHightLight(SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber));
                    }else{
                        system.debug('Test 1.0 : '+ AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content );
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type!='Editable'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber);
                        }
                        
                    }
                    
                    
                    
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName!=null){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName.contains('VECRemark') && VECList.size()==0 ){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content='';
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber='';
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type = 'Read'; 
                        }
                    }
                    
                    
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type=='Selectable'){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)){
                            if(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)=='false'){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }                                
                        }
                    }
                    
                    
                }
            }
            else if( AppendixSectionMap.get(key).name =='Payment Conditions'){                
                //looping child node
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Payment_ConditionsC'){
                        List<String> fillers = new String[] {String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()), 
                            String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day()),BRSFTotalAmount.format()};
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = String.format(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, fillers);
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputAmount}')){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = UpdateInputAmount(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content, 'InputAmount'); // AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputAmount}', '<input type="text" class="InputAmount " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputAmount'+'" />');
                    }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name=='Payment_Conditions_BC_Rate'){//Assign BC Rate
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content =AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{MartellBCRate}',ContractSelected.ASI_CRM_Martell_BC_Rate__c.setScale(0)+'%');                           
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content =AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{BCRate}',ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c.setScale(0)+'%');                           
                    }
                    
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)){
                        //system.assertEquals(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name), Null);
                        if(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).Name)=='false'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                        }                                
                    }
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{BRSFTotalContractAmount}')){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{BRSFTotalContractAmount}', BRSFTotalAmount.format() );  
                    }
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('KeySubBrandPart')){
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{Key-SubBrand}')){
                            if(KeySubBrandSet.size()>0){
                                String SubBrandNames= String.valueOf(KeySubBrandSet);
                                SubBrandNames= SubBrandNames.replace('{','');
                                SubBrandNames= SubBrandNames.replace('}','');
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content=AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{Key-SubBrand}', SubBrandNames);
                            }
                        }
                        if(KeySubBrandSet.size()<=0){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = ''; 
                        }
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{OutputPSFTotalAmount}')){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{OutputPSFTotalAmount}',PSFTotalContractAmount.format() );  
                        }
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow( AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ,BodyContentCuttingNumber);
                        //AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = '<div>'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content+'</div>';
                    }
                    if(!isEditable && AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName !=null &&
                       AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName.contains('IncludeNumber') ){
                        system.debug('ClassName log : '+ AppendixSectionMap.get(key).subSectionMap.get(ChildKey).ClassName);
                         AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,BodyContentCuttingNumber);
                   
                    }else if(!isEditable){ //AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content;
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitLineIntoRow(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content,InnerContentCuttingNumber);
                    }
                    AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                }
                
            }
           else if( AppendixSectionMap.get(key).name =='Affiliates_List'){
                if(CoveredOutletListString==''){
                    AppendixSectionMap.get(key).isShow=false; 
                }
                
                AppendixSectionMap.get(key).content =  AppendixSectionMap.get(key).content.replace('{Outlet}','<ul>'+CoveredOutletListString+'</ul>');   
                
                
            }
            else if(AppendixSectionMap.get(key).name.contains('AppendixGeneral') || AppendixSectionMap.get(key).name =='Party A undertakes' ){// general part 
                AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                if(AppendixSectionMap.get(key).hasSubSection){
                    //loop child content
                    for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                        String ExternalKey=String.valueOf(key)+'_'+String.valueOf(ChildKey);
                        
                        //case 1: if contain '{InputText}'
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.contains('{InputText}')){
                            String ContentText =  ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText') ? 
                                ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText'): '';
                            
                            if(!isEditable){ 
                                //PDF
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = 
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputText}', SplitLineIntoRow(ContentText,InnerContentCuttingNumber) );
                                
                                if(!ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText') ){
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                                }else if(ContentText=='' ||ContentText==' '){
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                                }else if(ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name) ){
                                    AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=
                                        ASI_CRM_CN_HeavyContractUtilitiesClass.ChangeStringToBoolean(ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name)); 
                                }
                            }else{
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content.replace('{InputText}', '<textarea cols="30" rows="3" class="InputText " data-id="'+AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name+'InputText"  >'+ContentText+'</textarea>');
                            }
                        }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name.contains('FixCostTable')){//Case 2
                            system.debug('case 2 ');
                            system.debug(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name);
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content  = GenerateFixCostTable (ChildKey,FixCostMap,AppendixSectionMap.get(key).subSectionMap.get(ChildKey).subSectionMap);
                        }else if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type=='Editable'){
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content= GeneratingInputText(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name +'InputText',AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content);
                            if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content ==''){
                                AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow=false;
                            }
                        }else{
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitStringLine(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content);
                        }
                    }
                }
                
            }else if(AppendixSectionMap.get(key).name.contains('Terms of this Agreement') ){
                   List<String> DateFillers = new String[] {'',String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_Start_Date__c.day()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.year()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.month()), 
                        String.valueOf(ContractSelected.ASI_CRM_CN_PO_End_Date__c.day())};
                            
                            AppendixSectionMap.get(key).content =String.format(AppendixSectionMap.get(key).content, DateFillers);
                 
                        
            }else if(AppendixSectionMap.get(key).name=='Party A' ){
                String PartyAName = ''; 
                if(AppendixSectionMap.get(key).content.contains('{1}')){
                    if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
                        PartyAName=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
                    }else{
                        PartyAName=ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
                    }
                    List<String> fillers = new String[] {'',PartyAName};
                        AppendixSectionMap.get(key).content = String.format(AppendixSectionMap.get(key).content, fillers);
                } else if(AppendixSectionMap.get(key).content.contains('{InputWholesaler}')){
                    AppendixSectionMap.get(key).content = AppendixSectionMap.get(key).content.replace('{InputWholesaler}', GeneratingEffectiveSupplierInput('Party A',true)); 
                   
                }
                 AppendixSectionMap.get(key).content = SplitLineIntoRow(AppendixSectionMap.get(key).content,BodyContentCuttingNumber);
                
                
            }else if(AppendixSectionMap.get(key).name =='Party C' ){
                List<String> fillers = new List<String>() ;
                fillers = new String[] {'',GeneratingPartyC_Header(true)  };
                AppendixSectionMap.get(key).content = String.format(AppendixSectionMap.get(key).content, fillers);                
            }
            else{ //others 
                AppendixSectionMap.get(key).content = SplitStringLine(AppendixSectionMap.get(key).content);
                if(AppendixSectionMap.get(key).hasSubSection){
                    for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = SplitStringLine(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content);
                    }
                }
            }
            
            if(AppendixSectionMap.get(key).content.contains('{CoveredOutletTable}')){
                AppendixSectionMap.get(key).content = AppendixSectionMap.get(key).content.replace('{CoveredOutletTable}', GeneratingCoveredOutletTable());
            }
            
            
            //general second looping 
            if(AppendixSectionMap.get(key).hasSubSection){
                if(AppendixSectionMap.get(key).subSectionMap!=null){
                    for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                        //case 1 editable
                        if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).type =='Editable' && AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name)){
                            
                            AppendixSectionMap.get(key).subSectionMap.get(ChildKey).content = ContractSettingMap.get(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).name);
                        }
                      
                    }
                }
            }
            if(AppendixSectionMap.get(key).type =='Editable' && AppendixSectionMap.get(key).name !=null && ContractSettingMap.containsKey(AppendixSectionMap.get(key).name)){
                AppendixSectionMap.get(key).content = ContractSettingMap.get(AppendixSectionMap.get(key).name);
                system.debug('Ha:'+AppendixSectionMap.get(key).content);
            }
        }
        ReOrdering();
    }
    //generate Input Text textarea
    private string GeneratingInputText(String InputKey, string DefaultValue){
        
        String OutputHTML='';
        if(!isEditable){
            if(ContractSettingMap.containsKey(InputKey)){
                OutputHTML=SplitLineIntoRow(ContractSettingMap.get(InputKey),InnerContentCuttingNumber);
            }else{
                OutputHTML='';
            }
        }else{
            String ContentText =  ContractSettingMap.containsKey(InputKey) ? ContractSettingMap.get(InputKey):DefaultValue;
            OutputHTML='<textarea cols="30" rows="3" class="InputText " data-id="'+InputKey+'"  >'+ContentText+'</textarea>';
        }
        return OutputHTML;
    }
    
    private String GenerateFixCostTable(integer AppendixKey,Map<Integer,ASI_CRM_Contract_Cost__c> FixCostMap, Map<integer, SectionWrapper> ChildMap){
        String InnerHTML='<table  style="border: 1px solid black; border-collapse: collapse; ';
        if(!isEditable){
            InnerHTML+= 'width: 35px ';
        }
        InnerHTML+= '" > ';
        decimal FXCTotalAmount=0.0;
        Boolean DisplayTable= false;
        for(integer ChildKey : ChildMap.keySet()){
            String ContentStr= ChildMap.get(ChildKey).content;
            Boolean DisplayFixCostLine=false;
            system.debug('DisplayFixCostLine'+ChildKey);
            
            if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                if(FixCostMap.get(ChildKey-2).ASI_CRM_CN_Contract_Amount__c!=0){
                    DisplayFixCostLine=true;
                    DisplayTable=true;
                }
            }
            
            if(ChildKey==1 || ChildKey==4 ){
                DisplayFixCostLine=true;
            }
            
            if(ContentStr.indexOf('//')>-1 && DisplayFixCostLine){
                List<String> parts = ContentStr.split('//');
                InnerHTML+='<tr style="border: 1px solid black; " >';
                
                if(parts.size()==4){ // if only split 4 part, that is the header
                    integer coun=1;
                    for(string str:parts){
                        if(coun==1){
                            InnerHTML+='<td style="border: 1px solid black; " colspan="2" >'+str+'</td>';
                        }else{
                            InnerHTML+='<td style="border: 1px solid black; "  >'+str+'</td>';
                        }
                        coun++;                                 
                    }
                }
                
                if(parts.size()==5 || parts.size()==2){//if only split 5/2 part,that is detail line
                    integer coun=1;
                    for(string str:parts){
                        string SavedKey=AppendixSectionMap.get(AppendixKey).name+'_'+ChildKey+'_'+String.valueOf(coun);
                        InnerHTML+='<td style="border: 1px solid black; " ';
                        if(coun==2 && str.contains('{InputText}') && AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName !=null){
                            InnerHTML+=  ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler(AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName);
                        }
                        InnerHTML+='>';  
                        
                        if(coun == 1 && str.contains('{FixedCostACCode}')){
                            if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                                InnerHTML+=TableSplitLineRow(FixCostMap.get(ChildKey-2).ASI_CRM_CN_Chinese_Description__c,8); 
                            }
                        }else if(coun==2 && str.contains('{InputText}')){
                            if(isEditable){
                                InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="FixCostTable_Remark"  ';
                            }
                            
                            if(ContractSettingMap.containsKey('FixCostTable_Remark')){
                                String NoteStr= isEditable?  '>'+ContractSettingMap.get('FixCostTable_Remark')+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get('FixCostTable_Remark') ,25));
                                InnerHTML+= NoteStr + '</td>';
                            }else{
                                InnerHTML+= isEditable?  ' ></textarea></td>': '</td>';
                            }
                            
                        }else if(str.contains('{InputAmount}')){
                            if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                                InnerHTML+= FixCostMap.get(ChildKey-2).ASI_CRM_CN_Contract_Amount__c!=null? FixCostMap.get(ChildKey-2).ASI_CRM_CN_Contract_Amount__c.format(): ' ' ;
                                FXCTotalAmount+=FixCostMap.get(ChildKey-2).ASI_CRM_CN_Contract_Amount__c;
                            }
                        }else if( str.contains('{FXTotalAmount}')){
                            InnerHTML+='<div id="FixCostTotalAmount" >'+FXCTotalAmount.format()+'</div>'; // String.valueOf( )
                            
                        }else if( (coun == 2 || coun == 3 ) && str!='<br/>' && ContentStr.contains('{FixedCostACCode}') ){
                            //changes 20171218:Fixed Cost : keep it editable instead of fix.
                            if(ContractSettingMap.containsKey(SavedKey)){
                                if(!isEditable){ 
                                    InnerHTML+= CheckingHightLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),8));
                                }else{
                                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                }
                            }else if(isEditable){
                                InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  >' + str + '</textarea>';
                            }
                            
                        }else if( coun == 5 && str!='<br/>' && ContentStr.contains('{FixedCostACCode}') ){
                            String FixCostId='';
                            
                            if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                                system.debug(ChildKey+ 'FixCostMap66622 : '+FixCostMap.get(ChildKey-2).Id );
                                FixCostId= FixCostMap.get(ChildKey-2).Id;
                            }
                            
                            if(ContractSettingMap.containsKey(SavedKey)){
                                if(!isEditable){ 
                                    InnerHTML+= CheckingHightLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),9));
                                }else{ // Edit Page
                                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  FixCost-Line="'+FixCostId+'"  >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                }
                            }else if(isEditable){
                                InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  FixCost-Line="'+FixCostId+'"    >' + str + '</textarea>';
                            }
                            
                            //if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                             //   system.debug('FixCostMap66622 : '+FixCostMap.get(ChildKey-2).Id );
                           // }
                            
                        }else {
                            InnerHTML+=TableSplitLineRow(str,10); 
                        }
                        
                        InnerHTML+='</td>';
                        coun++;
                    }
                }                
                InnerHTML+='</tr>';
            }
        }
        InnerHTML+='</table>';
        if(!DisplayTable){
            InnerHTML='';
        }
        system.debug('1112 FixCostMap : '+  FixCostMap.size());
        return InnerHTML;
    }

    private String GenerateFixCostTable2nd(integer AppendixKey,Map<Integer,ASI_CRM_Contract_Cost__c> FixCostMap, Map<integer, SectionWrapper> ChildMap,DataSummaryClass dsc){
        String InnerHTML='<table  style="border: 1px solid black; border-collapse: collapse; ';
        System.debug(LoggingLevel.INFO, '*** isEditable: ' + isEditable);
        if(!isEditable){
            InnerHTML+= 'width: 35px ';
        }
        InnerHTML+= '"> ';
        decimal FXCTotalAmount=0.0;
        Boolean DisplayTable= false;
        for(integer ChildKey : ChildMap.keySet()){
            String ContentStr= ChildMap.get(ChildKey).content;
            Boolean DisplayFixCostLine=false;

            // if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
            //     if(FixCostMap.get(ChildKey-2).ASI_CRM_CN_Contract_Amount__c!=0){
            //        DisplayFixCostLine=true;
            //        DisplayTable=true;
            //     }
            // }

            if ((ChildKey == 2 && dsc.storeAmountTotal != 0) 
                || (ChildKey == 3 && dsc.clubAmountTotal != 0)) {
                DisplayFixCostLine=true;
                DisplayTable=true;
            }
            
            if(ChildKey==1 || ChildKey==4 ){
                DisplayFixCostLine=true;
            }
            
            if(ContentStr.indexOf('//')>-1 && DisplayFixCostLine){
                List<String> parts = ContentStr.split('//');
                InnerHTML+='<tr style="border: 1px solid black;" >';
                
                if(parts.size()==4){ // if only split 4 part, that is the header
                    integer coun=1;
                    for(string str:parts){
                        if(coun==1){
                            InnerHTML+='<td style="border: 1px solid black; " colspan="2" >'+str+'</td>';
                        }else{
                            InnerHTML+='<td style="border: 1px solid black; "  >'+str+'</td>';
                        }
                        coun++;                                 
                    }
                }
                
                //body
                if(parts.size()==5 || parts.size()==2){//if only split 5/2 part,that is detail line
                    integer coun=1;
                    for(string str:parts){
                        string SavedKey=AppendixSectionMap.get(AppendixKey).name+'_'+ChildKey+'_'+String.valueOf(coun);
                        System.debug(LoggingLevel.INFO, '*** SavedKey: ' + SavedKey);
                        InnerHTML+='<td style="border: 1px solid black;border-right: 1px solid black; " ';
                        //Remark
                        if(coun==2 && str.contains('{InputText}') && AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName !=null){
                            InnerHTML+=  ASI_CRM_CN_HeavyContractUtilitiesClass.ContractGenClassNameHandler(AppendixSectionMap.get(AppendixKey).subSectionMap.get(ChildKey).ClassName);
                        }
                        InnerHTML+='>';  
                        
                        if(coun == 1 && str.contains('{FixedCostStoreACCode}')){
                            // if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                                InnerHTML += '店家支持'; 
                            // }
                        }else if(coun == 1 && str.contains('{FixedCostClubACCode}')){
                                InnerHTML += '夜店活动费用(固定)'; 
                        }else if(coun==2 && str.contains('{InputText}')){
                            if(isEditable){
                                InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="FixCostTable_Remark"  ';
                            }
                            
                            if(ContractSettingMap.containsKey('FixCostTable_Remark')){
                                String NoteStr= isEditable?  '>'+ContractSettingMap.get('FixCostTable_Remark')+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get('FixCostTable_Remark') ,20));
                                InnerHTML+= NoteStr + '</td>';
                            }else{
                                InnerHTML+= isEditable?  ' ></textarea></td>': '</td>';
                            }
                            
                        }else if(str.contains('{InputStoreAmount}')){
                            // if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                                InnerHTML+= dsc.storeAmountTotal.format();
                            // }
                        }else if (str.contains('{InputClubAmount}')) {
                            InnerHTML+= dsc.clubAmountTotal.format();
                        }else if( str.contains('{FXTotalAmount}')){
                            InnerHTML+='<div id="FixCostTotalAmount" >'+dsc.amountTotal.format()+'</div>'; // String.valueOf( )
                            
                        }else if( (coun == 2 || coun == 3 ) && str!='<br/>' && ContentStr.contains('{FixedCostStoreACCode}') ){
                            //changes 20171218:Fixed Cost : keep it editable instead of fix.
                            if(ContractSettingMap.containsKey(SavedKey)){
                                if(!isEditable){ 
                                    InnerHTML+= CheckingHightLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),6));
                                }else{
                                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                }
                            }else if(isEditable){
                                InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  >' + str + '</textarea>';
                            }
                            
                        }else if( coun == 5 && str!='<br/>' && ContentStr.contains('{FixedCostStoreACCode}') ){
                            // String FixCostId='';
                            
                            // if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                            //     system.debug(ChildKey+ 'FixCostMap66622 : '+FixCostMap.get(ChildKey-2).Id );
                            //     FixCostId= FixCostMap.get(ChildKey-2).Id;
                            // }
                            
                            if(ContractSettingMap.containsKey(SavedKey)){
                                if(!isEditable){ 
                                    InnerHTML+= CheckingHightLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),7));
                                }else{ // Edit Page
                                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"    >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                }
                            }else if(isEditable){
                                InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"      >' + str + '</textarea>';
                            }
                            
                            //if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                             //   system.debug('FixCostMap66622 : '+FixCostMap.get(ChildKey-2).Id );
                           // }
                            
                        }else if( (coun == 2 || coun == 3 ) && str!='<br/>' && ContentStr.contains('{FixedCostClubACCode}') ){
                            //changes 20171218:Fixed Cost : keep it editable instead of fix.
                            if(ContractSettingMap.containsKey(SavedKey)){
                                if(!isEditable){ 
                                    InnerHTML+= CheckingHightLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),6));
                                }else{
                                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                }
                            }else if(isEditable){
                                InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"  >' + str + '</textarea>';
                            }
                            
                        }else if( coun == 5 && str!='<br/>' && ContentStr.contains('{FixedCostClubACCode}') ){
                            // String FixCostId='';
                            
                            // if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                            //     system.debug(ChildKey+ 'FixCostMap66622 : '+FixCostMap.get(ChildKey-2).Id );
                            //     FixCostId= FixCostMap.get(ChildKey-2).Id;
                            // }
                            
                            if(ContractSettingMap.containsKey(SavedKey)){
                                if(!isEditable){ 
                                    InnerHTML+= CheckingHightLight(SplitLineIntoRow(ContractSettingMap.get(SavedKey),7));
                                }else{ // Edit Page
                                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"    >' + ContractSettingMap.get(SavedKey) + '</textarea>';
                                }
                            }else if(isEditable){
                                InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"      >' + str + '</textarea>';
                            }
                            
                            //if(FixCostMap.size()>0 && FixCostMap.containsKey(ChildKey-2)){
                             //   system.debug('FixCostMap66622 : '+FixCostMap.get(ChildKey-2).Id );
                           // }
                            
                        }else {
                            InnerHTML+=TableSplitLineRow(str,10); 
                        }
                        
                        InnerHTML+='</td>';
                        coun++;
                    }
                }                
                InnerHTML+='</tr>';
            }
        }
        InnerHTML+='</table>';
        if(!DisplayTable){
            InnerHTML='';
        }
        System.debug(LoggingLevel.INFO, '*** InnerHTML: ' + InnerHTML);
        return InnerHTML;
    }

    //************* Generating fixcost Item Table**********************
    private String GenerateFixItemTable(String ContentStr,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> StoreList, SectionWrapper ChildMap,DataSummaryClass dsc){

        string InnerHTML='';
        List<String> parts = ContentStr.split('//');
        decimal FXCTotalAmount=0.0;
        Boolean DisplayTable= false;
        Decimal TotalMonthlyVolume  = 0.0;
        Decimal TotalMonthlyIncentive =0.0;
        Decimal TotalVolume  = 0.0;
        Decimal ContractTotal=0.0;
        dsc.storeVolumeRemark = dsc.storeVolumeRemark == null? '':dsc.storeVolumeRemark;

        // Header
        // InnerHTML+='<table  style="border: 1px solid black; border-collapse: collapse;" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+parts[0]+'</td><td style="border: 1px solid black; ">';
        InnerHTML+='<table  style="border: 1px solid black; border-collapse: collapse;';
        if(!isEditable){
            InnerHTML+= 'width:35px';
        }
        InnerHTML+= '" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+parts[0]+'</td><td style="border: 1px solid black; ">';
        if(StoreList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
            InnerHTML += parts[1]+'</td><td style="border: 1px solid black; " >'+parts[2]+'</td><td style="border: 1px solid black; ">';
        }
        InnerHTML+= parts[3]+'</td><td style="border: 1px solid black; " >'+parts[4]+'</td></tr>';

        //Body
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c accbli : StoreList) {
            
            if(StoreList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                Decimal YearlyTotalVolume= accbli.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? accbli.ASI_CRM_CN_Contract_Monthly_Qty__c * accbli.ASI_CRM_CN_No_of_Months__c:0;
                
                InnerHTML+='<tr><td style="border: 1px solid black; ">'+accbli.ASI_CRM_CN_Sub_Brand__r.Name+'</td><td style="border: 1px solid black; text-align: right;" >';
                InnerHTML += accbli.ASI_CRM_CN_Contract_Monthly_Qty__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'
                          + accbli.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'+
                          +YearlyTotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;">';
                
                TotalMonthlyVolume += accbli.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? accbli.ASI_CRM_CN_Contract_Monthly_Qty__c: 0.0;
                TotalMonthlyIncentive += accbli.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c !=null? accbli.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c: 0.0;
                TotalVolume+= YearlyTotalVolume!=null? YearlyTotalVolume:0;
            }else{
                if(StoreList[0].ASI_CRM_Volume_Base__c=='By Grade'){
                    String SBGrade= accbli.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ==null? accbli.ASI_CRM_Sub_Brand_Grade__r.Name : accbli.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ;
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+SBGrade +'</td><td style="border: 1px solid black; text-align: right;">';
                }
                if(StoreList[0].ASI_CRM_Volume_Base__c=='By Category'){
                    String CategoryName= accbli.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? accbli.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : accbli.ASI_CRM_Product_Category__r.Name; 
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+CategoryName+'</td><td style="border: 1px solid black; text-align: right;">';
                }
                if(StoreList[0].ASI_CRM_Volume_Base__c=='By Total'){
                    InnerHTML+='<tr><td style="border: 1px solid black; " >按总销量</td><td style="border: 1px solid black;text-align: right; ">';
                }
                InnerHTML+= accbli.ASI_CRM_Contract_Total_QTY_std_Btl__c.format()+'</td><td style="border: 1px solid black;text-align: right; ">' ;
                TotalVolume+= accbli.ASI_CRM_Contract_Total_QTY_std_Btl__c!=null? accbli.ASI_CRM_Contract_Total_QTY_std_Btl__c:0;
                
            }
            InnerHTML+=accbli.ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td></tr>';
            ContractTotal+=accbli.ASI_CRM_CN_Contract_Total_Dummy__c!=null? accbli.ASI_CRM_CN_Contract_Total_Dummy__c:0;
        }

        System.debug(LoggingLevel.INFO, '*** InnerHTML: ' + InnerHTML);

        if (ChildMap.subSectionMap!=null) {
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                if(ChildMap.subSectionMap.get(InnerKey).name=='FixCostItemTableA_In_total'){ // display Total Amount 
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+ChildMap.subSectionMap.get(InnerKey).content+'</td>';
                    if(StoreList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalMonthlyVolume.format()+'</td>'+ '<td style="border: 1px solid black; text-align: right;" >'+'</td>';
                    }
                    InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalVolume.format()+'</td>'+ '<td style="border: 1px solid black;text-align: right; " >'+ContractTotal.format()+'</td>';
                    InnerHTML+= '</tr>';
                }

                for (String valueKey : ContractSettingMap.keySet()) {
                    if (valueKey == 'FixCostItemfooter' + '_Remark') {
                        dsc.storeVolumeRemark = ContractSettingMap.get(valueKey);
                    }
                }
                // Footer
                if(ChildMap.subSectionMap.get(InnerKey).name =='FixCostItemfooter'){
                    InnerHTML += '<tr>';
                    List<String> footparts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                    for (String str : footparts) {
                        if (str.contains('{InputTextItemStore}')) {
                            if(StoreList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                                InnerHTML+='<td style="border: 1px solid black; " colspan="4"> ';
                                InnerHTML += '<textarea cols="100" rows="3" class="InputText " Module-Id="'+StoreList[0].ASI_CRM_Module__c+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'_Remark'+'">';
                            }else{
                                InnerHTML+='<td style="border: 1px solid black; " colspan="2"> ';
                                InnerHTML += '<textarea cols="100" rows="3" class="InputText " Module-Id="'+StoreList[0].ASI_CRM_Module__c+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'_Remark'+'">';
                            }
                            if(isEditable){
                                InnerHTML += dsc.storeVolumeRemark+ '</textarea>';
                            }else{
                                InnerHTML += CheckingHightLight(SplitLineIntoRow( dsc.storeVolumeRemark ,30))+ '</textarea>';
                            }
                        }else{
                            InnerHTML += '<td style="border: 1px solid black; "> ';
                            InnerHTML += str;
                        }
                        InnerHTML += '</td>';
                    }
                    InnerHTML+= '</tr>';
                }
            }
        }
        InnerHTML+='</table>';
        //System.debug(LoggingLevel.INFO, '*** InnerHTML: ' + InnerHTML);
        return InnerHTML;
    }

    //************* Generating fixcostClub Item Table**********************
    private String GenerateFixClubItemTable(String ContentStr,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> ClubList, SectionWrapper ChildMap,DataSummaryClass dsc){
        System.debug(LoggingLevel.INFO, '*** : ContentStr' + ContentStr);
        System.debug(LoggingLevel.INFO, '*** ChildMap: ' + ChildMap);
        string InnerHTML='';
        List<String> parts = ContentStr.split('//');
        decimal FXCTotalAmount=0.0;
        Boolean DisplayTable= false;
        Decimal TotalMonthlyVolume  = 0.0;
        Decimal TotalMonthlyIncentive =0.0;
        Decimal TotalVolume  = 0.0;
        Decimal ContractTotal=0.0;
        dsc.clubVolumeRemark = dsc.clubVolumeRemark == null? '':dsc.clubVolumeRemark;

        // Header
        InnerHTML+='<table  style="border: 1px solid black; border-collapse: collapse;';
        if(!isEditable){
            InnerHTML+= 'width:35px';
        }
        InnerHTML+= '" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+parts[0]+'</td><td style="border: 1px solid black; ">';
        if(ClubList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
            InnerHTML += parts[1]+'</td><td style="border: 1px solid black; " >'+parts[2]+'</td><td style="border: 1px solid black; ">';
        }
        InnerHTML+= parts[3]+'</td><td style="border: 1px solid black; " >'+parts[4]+'</td></tr>';

        //Body
        for (ASI_CRM_CN_Contract_BRSF_Line_Item__c accbli : ClubList) {
            
            if(ClubList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                Decimal YearlyTotalVolume= accbli.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? accbli.ASI_CRM_CN_Contract_Monthly_Qty__c * accbli.ASI_CRM_CN_No_of_Months__c:0;
                
                InnerHTML+='<tr><td style="border: 1px solid black; ">'+accbli.ASI_CRM_CN_Sub_Brand__r.Name+'</td><td style="border: 1px solid black; text-align: right;" >';
                InnerHTML += accbli.ASI_CRM_CN_Contract_Monthly_Qty__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'
                          + accbli.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'+
                          +YearlyTotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;">';
                
                TotalMonthlyVolume += accbli.ASI_CRM_CN_Contract_Monthly_Qty__c !=null? accbli.ASI_CRM_CN_Contract_Monthly_Qty__c: 0.0;
                TotalMonthlyIncentive += accbli.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c !=null? accbli.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c: 0.0;
                TotalVolume+= YearlyTotalVolume!=null? YearlyTotalVolume:0;
            }else{
                if(ClubList[0].ASI_CRM_Volume_Base__c=='By Grade'){
                    String SBGrade= accbli.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ==null? accbli.ASI_CRM_Sub_Brand_Grade__r.Name : accbli.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ;
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+SBGrade +'</td><td style="border: 1px solid black; text-align: right;">';
                }
                if(ClubList[0].ASI_CRM_Volume_Base__c=='By Category'){
                    String CategoryName= accbli.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? accbli.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : accbli.ASI_CRM_Product_Category__r.Name; 
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+CategoryName+'</td><td style="border: 1px solid black; text-align: right;">';
                }
                if(ClubList[0].ASI_CRM_Volume_Base__c=='By Total'){
                    InnerHTML+='<tr><td style="border: 1px solid black; " >按总销量</td><td style="border: 1px solid black;text-align: right; ">';
                }
                InnerHTML+= accbli.ASI_CRM_Contract_Total_QTY_std_Btl__c.format()+'</td><td style="border: 1px solid black;text-align: right; ">' ;
                TotalVolume+= accbli.ASI_CRM_Contract_Total_QTY_std_Btl__c!=null? accbli.ASI_CRM_Contract_Total_QTY_std_Btl__c:0;
                
            }
            InnerHTML+=accbli.ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td></tr>';
            ContractTotal+=accbli.ASI_CRM_CN_Contract_Total_Dummy__c!=null? accbli.ASI_CRM_CN_Contract_Total_Dummy__c:0;
        }

        System.debug(LoggingLevel.INFO, '*** InnerHTML: ' + InnerHTML);

        if (ChildMap.subSectionMap!=null) {
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                if(ChildMap.subSectionMap.get(InnerKey).name=='FixCostItemClubTableA_In_total'){ // display Total Amount 
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+ChildMap.subSectionMap.get(InnerKey).content+'</td>';
                    if(ClubList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                        InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalMonthlyVolume.format()+'</td>'+ '<td style="border: 1px solid black; text-align: right;" >'+'</td>';
                    }
                    InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalVolume.format()+'</td>'+ '<td style="border: 1px solid black;text-align: right; " >'+ContractTotal.format()+'</td>';
                    InnerHTML+= '</tr>';
                }

                for (String valueKey : ContractSettingMap.keySet()) {
                    if (valueKey == 'FixCostClubItemfooter' + '_Remark') {
                        dsc.clubVolumeRemark = ContractSettingMap.get(valueKey);
                    }
                }
                // Footer
                if(ChildMap.subSectionMap.get(InnerKey).name =='FixCostClubItemfooter'){
                    InnerHTML += '<tr>';
                    List<String> footparts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                    for (String str : footparts) {
                        if (str.contains('{InputTextItemClub}')) {
                            if(ClubList[0].ASI_CRM_Volume_Base__c=='By Sub-Brand'){
                                InnerHTML+='<td style="border: 1px solid black; " colspan="4"> ';
                                InnerHTML += '<textarea cols="100" rows="3" class="InputText " Module-Id="'+ClubList[0].ASI_CRM_Module__c+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'_Remark'+'">';
                            }else{
                                InnerHTML+='<td style="border: 1px solid black; " colspan="2"> ';
                                InnerHTML += '<textarea cols="100" rows="3" class="InputText " Module-Id="'+ClubList[0].ASI_CRM_Module__c+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'_Remark'+'">';
                            }
                            if(isEditable){
                                InnerHTML += dsc.clubVolumeRemark+ '</textarea>';
                            }else{
                                InnerHTML += CheckingHightLight(SplitLineIntoRow( dsc.clubVolumeRemark ,30))+ '</textarea>';
                            }
                        }else{
                            InnerHTML += '<td style="border: 1px solid black; "> ';
                            InnerHTML += str;
                        }
                        InnerHTML += '</td>';
                    }
                    InnerHTML+= '</tr>';
                }
            }
        }
        InnerHTML+='</table>';
        //System.debug(LoggingLevel.INFO, '*** InnerHTML: ' + InnerHTML);
        return InnerHTML;
    }
    
    //************* Generating Covered Outlet Table**********************
    public String GeneratingCoveredOutletTable(){
        string InnerHTML='<br/><table  style="border: 1px solid black; border-collapse: collapse; ';
        
        
        if(!isEditable){
            InnerHTML+= 'width: 35px ';
        }
        InnerHTML+= '" > <tr> <td style="border: 1px solid black;  text-align: left; " > 店名</td><td style="border: 1px solid black;  text-align: left; " >官方名称</td><td style="border: 1px solid black;  text-align: left; " >地址</td></tr>  ';
       
        
        //Add current outlet 
        String LegalNameString = ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name);
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c!=null){
            LegalNameString= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c;
        }
        InnerHTML+='<tr><td style="border: 1px solid black;  text-align: left; ">'+
            ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(ContractSelected.ASI_CRM_CN_Outlet_WS__r.Name)+
            '</td><td style="border: 1px solid black;  text-align: left; ">'+LegalNameString+'</td><td style="border: 1px solid black;  text-align: left; ">';
        if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c!=null){
            InnerHTML+=ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Address__c;
        }
        InnerHTML+='</td></tr>';
        
      
        //Covered Outlet
        for(ASI_CRM_CN_Covered_Outlet__c CoveredOutlet:CoveredOutletList){
            LegalNameString = ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(CoveredOutlet.Name);
            if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c!=null){
                LegalNameString=LineBreakProcess(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Legal_Name__c,10,5) ;
            }
            InnerHTML+='<tr><td style="border: 1px solid black;  text-align: left; ">'+ASI_CRM_CN_HeavyContracFunctionClass.ReplaceNumberInCustomer(CoveredOutlet.ASI_CRM_CN_Outlet__r.Name)+'</td><td style="border: 1px solid black;  text-align: left; ">'+LegalNameString+'</td><td style="border: 1px solid black;  text-align: left; ">';
            if(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Address__c!=null){
                InnerHTML+=LineBreakProcess(CoveredOutlet.ASI_CRM_CN_Outlet__r.ASI_CRM_CN_Address__c,12,5);
            }
            InnerHTML+='</td></tr>';
        }
        InnerHTML +='</table>';
        return InnerHTML;//return '';
    }
    
    
    
    public void ReOrdering(){
        //Re-Ordering
        Integer HeaderLineNumber=1;
        for(integer key : AppendixSectionMap.keySet()) {
            //reordering PSF Number 
            Integer PSFModuleNumber=1;
            //Comment 20180302 unknown reason
            if( AppendixSectionMap.get(key).name =='SalesDiscount'){ 
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber !=null &&  AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber !=''){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber=string.valueOf(HeaderLineNumber-1)+'.'+string.valueOf(PSFModuleNumber);
                        PSFModuleNumber++;
                    }
                }
            }
            
            //Ordering
            if(AppendixSectionMap.get(key).ClassName!=null && AppendixSectionMap.get(key).displayNumber!=null && AppendixSectionMap.get(key).ClassName!='' && AppendixSectionMap.get(key).displayNumber!='' && AppendixSectionMap.get(key).ClassName=='AppendixLineHeader'){
                AppendixSectionMap.get(key).displayNumber=string.valueOf(HeaderLineNumber);
                HeaderLineNumber++;
            }
            
            if( AppendixSectionMap.get(key).name =='Payment Conditions' && !isEditable){
                Integer OrderNumber=1;
                for(integer ChildKey : AppendixSectionMap.get(key).subSectionMap.keySet()){
                    if(AppendixSectionMap.get(key).subSectionMap.get(ChildKey).isShow){
                        AppendixSectionMap.get(key).subSectionMap.get(ChildKey).displayNumber=String.valueOf(OrderNumber)+')';
                        OrderNumber++;
                    }
                }
            }
        }
    }
    
    public String UpdateInputAmount(String ContentName,String InputContent,String KeyString){
        String ReturnContent='';
        String DataId=ContentName+KeyString;
        if(ContractSettingMap.containsKey(DataId)){
            String value= ContractSettingMap.get(DataId);
            if(!isEditable){ 
                ReturnContent= InputContent.replace('{'+KeyString+'}', value );
            }else{
                if(KeyString.contains('Percent') || KeyString.contains('Amount')){
                    ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount RequiredField" data-id="'+DataId+'" value="'+value+'" />');
                }else{
                    ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount " data-id="'+DataId+'" value="'+value+'" />');
                }
            }
        }else if(isEditable){
            if(KeyString.contains('Percent')  ){
                ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount RequiredField" data-id="'+DataId+'" placeholder="25/50/75/100" />');
            }else{
                ReturnContent= InputContent.replace('{'+KeyString+'}', '<input type="text" class="InputAmount RequiredField" data-id="'+DataId+'" />');
            }
        }
        return ReturnContent;
    }
    
    public String DrawingBRSFTableIncentive(String ContentStr,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList,SectionWrapper ChildMap){
        String InnerHTML='  <table style="border: 1px solid black; border-collapse: collapse;    ';
        if(!isEditable){
            InnerHTML+= 'width:38px  ';
        }
        Decimal MonthlyVolume  = 0.0;
        Decimal MonthlyIncentive =0.0;
        Decimal ContractTotalVolume  = 0.0;
        Decimal ContractTotalAmount=0.0;
        // ContentStr= 产品名称和规格// 单瓶销售折扣
        List<String> parts = ContentStr.split('//');
        InnerHTML+=' "  ><tr  style="border: 1px solid black; " >';
        
        for(string str:parts){
            InnerHTML+='<td style="border: 1px solid black; " >'+str+'</td>';
        }
        InnerHTML+='</tr>';
        String ModuleId='';
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:BRSFList){
            if(BRSFLine.ASI_CRM_Module__c!=null && ModuleId==''){
                ModuleId=BRSFLine.ASI_CRM_Module__c;
            }
            String SubBrandName= BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c==null? BRSFLine.ASI_CRM_CN_Sub_Brand__r.Name: BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
            if(!isEditable){
                SubBrandName= SplitLineIntoRow(SubBrandName,10);
            }
            Decimal TotalVolume=BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c:0;
            MonthlyVolume+= BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
            MonthlyIncentive+= BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;
            ContractTotalVolume+=TotalVolume;
            ContractTotalAmount+=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            
            InnerHTML+='<tr style="border: 1px solid black; "><td style="border: 1px solid black; " >'+SubBrandName+
                '</td><td style="border: 1px solid black;  text-align: right; ">'+BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+'</td></tr>';
        }
        
        //Footer
        if(ChildMap.subSectionMap!=null){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                parts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                InnerHTML+='<tr style="border: 1px solid black; ">';
                integer CollumnNum=1;
                for(string str:parts){
                    InnerHTML+= '<td style="border: 1px solid black; " ';
                    if(CollumnNum ==SectionTypeClass.StyleStringCollumnNum){
                        InnerHTML+=SectionTypeClass.StyleString;
                    }
                    if(SectionTypeClass.ClassType=='InputText' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                        InnerHTML+='>';
                        if(isEditable){
                            InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'"  Module-Id="'+ModuleId+'"';
                        }
                        if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                            String NoteStr= isEditable?  '>'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name) ,25));
                            InnerHTML+= NoteStr + '</td>';
                        }else{
                            InnerHTML+= isEditable?  '   >'+str+'</textarea></td>':str+ '</td>';
                        }
                    }else{
                        InnerHTML+='  >'+ SplitLineIntoRow(str,25)+'</td>';
                    }
                    CollumnNum++;
                }
                InnerHTML+='</tr>';
            }
        }
        
        InnerHTML+='</table>';
        return InnerHTML;
        
    }
    
    public String DrawingBRSFTable(String ContentStr,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> BRSFList,SectionWrapper ChildMap){
        String InnerHTML='  <table style="border: 1px solid black; border-collapse: collapse;    ';
        if(!isEditable){
            InnerHTML+= 'width:38px  ';
        }
        Decimal MonthlyVolume  = 0.0;
        Decimal MonthlyIncentive =0.0;
        Decimal ContractTotalVolume  = 0.0;
        Decimal ContractTotalAmount=0.0;
        // ContentStr= 产品名称和规格// 单瓶月销量目标//单瓶销售折扣//合同总销量//合同总销售折扣
        List<String> parts = ContentStr.split('//');
        InnerHTML+=' "  ><tr  style="border: 1px solid black; " >';
        
        for(string str:parts){
            InnerHTML+='<td style="border: 1px solid black; " >'+str+'</td>';
        }
        InnerHTML+='</tr>';
        String ModuleId='';
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c BRSFLine:BRSFList){
            if(BRSFLine.ASI_CRM_Module__c!=null && ModuleId==''){
                ModuleId=BRSFLine.ASI_CRM_Module__c;
            }
            String SubBrandName= BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c==null? BRSFLine.ASI_CRM_CN_Sub_Brand__r.Name: BRSFLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c;
            if(!isEditable){
                SubBrandName= SplitLineIntoRow(SubBrandName,10);
            }
            Decimal TotalVolume=BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null?BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c:0;
            MonthlyVolume+= BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c:0;
            MonthlyIncentive+= BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c:0;
            ContractTotalVolume+=TotalVolume;
            ContractTotalAmount+=BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c:0;
            InnerHTML+='<tr style="border: 1px solid black; "><td style="border: 1px solid black; " >'+SubBrandName+
                '</td><td style="border: 1px solid black;  text-align: right; ">'+BRSFLine.ASI_CRM_CN_Contract_Monthly_Qty__c.format()+
                '</td><td style="border: 1px solid black;  text-align: right; ">'+BRSFLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+
                '</td><td style="border: 1px solid black;  text-align: right; ">'+TotalVolume.format()+
                '</td><td style="border: 1px solid black;  text-align: right; ">'+BRSFLine.ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td></tr>';
        }
        //MonthlyIncentive.format()
        InnerHTML+='<tr style="border: 1px solid black; "><td style="border: 1px solid black; " >总计：'+
            '</td><td style="border: 1px solid black;  text-align: right; ">'+MonthlyVolume.format()+
            '</td><td style="border: 1px solid black;  text-align: right; ">'+
            '</td><td style="border: 1px solid black;  text-align: right; ">'+ContractTotalVolume.format()+
            '</td><td style="border: 1px solid black;  text-align: right; ">'+ContractTotalAmount.format()+'</td></tr>';
        
        //Footer
        if(ChildMap.subSectionMap!=null){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                parts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                InnerHTML+='<tr style="border: 1px solid black; ">';
                integer CollumnNum=1;
                for(string str:parts){
                    InnerHTML+= '<td style="border: 1px solid black; " ';
                    if(CollumnNum ==SectionTypeClass.StyleStringCollumnNum){
                        InnerHTML+=SectionTypeClass.StyleString;
                    }
                    if(SectionTypeClass.ClassType=='InputText' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                        InnerHTML+='>';
                        if(isEditable){
                            InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'"  Module-Id="'+ModuleId+'"';
                        }
                        if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                            
                            String NoteStr= isEditable?  '>'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name) ,25));
                            InnerHTML+= NoteStr + '</td>';
                        }else{
                            InnerHTML+= isEditable?  '   >'+str+'</textarea></td>':str+ '</td>';
                        }
                    }else{
                        InnerHTML+='  >'+ SplitLineIntoRow(str,25)+'</td>';
                    }
                    CollumnNum++;
                }
                InnerHTML+='</tr>';
            }
        }
        
        InnerHTML+='</table>';
        return InnerHTML;
    }
    
    public String DrawingPSFTable2nd(String ContentStr,Map<String,interimData> PSF_Item_Map,SectionWrapper ChildMap){
        System.debug(LoggingLevel.INFO, '*** ChildMap: ' + ChildMap);
        System.debug(LoggingLevel.INFO, '*** ChildMap: ' + ChildMap.subSectionMap);
        System.debug(LoggingLevel.INFO, '*** PSF_Item_Map: ' + PSF_Item_Map);
        System.debug(LoggingLevel.INFO, '*** PSF_Item_Map.keySet(): ' + PSF_Item_Map.keySet());
        List<String> parts = ContentStr.split('//');
        integer ModuleNumber=0;
        string ReturnHTML='';
        for(String key:PSF_Item_Map.keySet()){
            String InnerHTML='';
            ModuleNumber++;
            Decimal TotalMonthlyVolume  = 0.0;
            Decimal TotalMonthlyIncentive =0.0;
            Decimal TotalVolume  = 0.0;
            Decimal ContractTotal=0.0;
            String VolumeBaseStr = (PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand' && psfdisplayType != 'total' ? VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) : 'ByTotal');
            InnerHTML+='<br/> <table  style="border: 1px solid black; border-collapse: collapse;" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+parts[0]+'</td><td style="border: 1px solid black; ">';
            if(PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand' && psfdisplayType != 'total'){
                InnerHTML += parts[1]+'</td><td style="border: 1px solid black; " >'+parts[2]+'</td><td style="border: 1px solid black; ">';
            }
            InnerHTML+= parts[3]+'</td><td style="border: 1px solid black; " >'+parts[4]+'</td></tr>';
            
            integer coun = 1;
            for(String keyline:PSF_Item_Map.get(key).DetailLineMap.keySet()){
                if(PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand'){
                    if (psfdisplayType != 'total') {
                        String SubBrandTempName=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c:PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__r.Name;
                        String SubBrandName = isEditable ? SubBrandTempName : SplitLineIntoRow(SubBrandTempName,8);
                        Decimal YearlyTotalVolume= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c:0;
                        
                        InnerHTML+='<tr><td style="border: 1px solid black; ">'+SubBrandName+'</td><td style="border: 1px solid black; text-align: right;" >';
                        InnerHTML += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'
                            +PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'+
                            +YearlyTotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;">';
                        
                        TotalMonthlyVolume += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c !=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c: 0.0;
                        TotalMonthlyIncentive += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c !=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c: 0.0;
                        TotalVolume+= YearlyTotalVolume!=null? YearlyTotalVolume:0;
                    } else {
                        Decimal YearlyTotalVolume= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c:0;
                        TotalVolume+= YearlyTotalVolume!=null? YearlyTotalVolume:0;
                    }
                }else{
                    if(PSF_Item_Map.get(key).VolumeBase=='By Grade'){
                        String SBGrade= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ==null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Sub_Brand_Grade__r.Name : PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ;
                        InnerHTML+='<tr><td style="border: 1px solid black; " >'+SBGrade +'</td><td style="border: 1px solid black; text-align: right;">';
                    }
                    if(PSF_Item_Map.get(key).VolumeBase=='By Category'){
                        String CategoryName= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Product_Category__r.Name; 
                        InnerHTML+='<tr><td style="border: 1px solid black; " >'+CategoryName+'</td><td style="border: 1px solid black; text-align: right;">';
                    }
                    if(PSF_Item_Map.get(key).VolumeBase=='By Total'){
                        InnerHTML+='<tr><td style="border: 1px solid black; " >按总销量</td><td style="border: 1px solid black;text-align: right; ">';
                    }
                    InnerHTML+= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Contract_Total_QTY_std_Btl__c.format()+'</td><td style="border: 1px solid black;text-align: right; ">' ;
                    TotalVolume+= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Contract_Total_QTY_std_Btl__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Contract_Total_QTY_std_Btl__c:0;
                    
                }
                if (PSF_Item_Map.get(key).VolumeBase!='By Sub-Brand' || psfdisplayType != 'total') {
                    InnerHTML+=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td></tr>';
                }
                ContractTotal+=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c:0;                
            }//Ending of looping
            
            if (PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand' && psfdisplayType == 'total') {
                InnerHTML+='<tr><td style="border: 1px solid black; " >按总销量</td><td style="border: 1px solid black;text-align: right; ">';
                InnerHTML+= TotalVolume.format()+'</td><td style="border: 1px solid black;text-align: right; ">' ;
                InnerHTML+=ContractTotal.format()+'</td></tr>';
            }
            
            //Footer
            if(ChildMap.subSectionMap!=null  ){
                
                for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                    if(ChildMap.subSectionMap.get(InnerKey).name=='PSFTableA_In_total'){ // display Total Amount 
                        InnerHTML+='<tr><td style="border: 1px solid black; " >'+ChildMap.subSectionMap.get(InnerKey).content+'</td>';
                        if(PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand' && psfdisplayType != 'total'){
                            InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalMonthlyVolume.format()+'</td>'+ '<td style="border: 1px solid black; text-align: right;" >'+'</td>';
                        }
                        InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalVolume.format()+'</td>'+ '<td style="border: 1px solid black;text-align: right; " >'+ContractTotal.format()+'</td>';
                        InnerHTML+= '</tr>';
                    }else if(ChildMap.subSectionMap.get(InnerKey).name=='PSFTableA_HeaderTerm'){
                        if(ChildMap.subSectionMap.get(InnerKey).ClassName.contains(VolumeBaseStr ) ){ 
                            InnerHTML =String.valueOf(ModuleNumber)+')'+ ChildMap.subSectionMap.get(InnerKey).content+InnerHTML ;
                        } 
                    }else{
                        Boolean DisplayFlag= false;
                        SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                        if(SectionTypeClass.VolumeBase!=null && SectionTypeClass.VolumeBase==''){
                            DisplayFlag=true;
                        }else{
                            if(VolumeBaseStr==SectionTypeClass.VolumeBase){
                                DisplayFlag=true;
                            }
                        }
                        if(DisplayFlag){
                            InnerHTML+='<tr>';
                            //List<String> FooterParts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                            String NowContent=ChildMap.subSectionMap.get(InnerKey).content;
                            if(ChildMap.subSectionMap.get(InnerKey).content.right(2)=='//'){
                                NowContent+='  ';
                            }
                            List<String> FooterParts = NowContent.split('//');
                            
                            integer CollumnNum=1;
                            for(string str:FooterParts){
                                
                                if(SectionTypeClass.ClassType=='InputText' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                    InnerHTML+= '<td  ';
                                    if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                        InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                    }
                                    InnerHTML+=' style="border: 1px solid black; " >';
                                    if(isEditable){
                                        InnerHTML+='<textarea cols="50" rows="3" class="InputText " Module-Id="'+key+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+key+'"  ';
                                    }
                                    
                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                        String NoteStr= isEditable?  ' style="border: 1px solid black; " >'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key) ,25));
                                        InnerHTML+= NoteStr + '</td>';
                                    }else{
                                        if (str.trim().length()==0){
                                            str='';
                                        }
                                        InnerHTML+= isEditable?  '   style="border: 1px solid black; " >'+str+'</textarea></td>':SplitLineIntoRow(str, 25)+ '<br/></td>';
                                    }
                                }else if(SectionTypeClass.ClassType=='Selectable' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                    
                                    if(isEditable){
                                        InnerHTML+= '<td  ';
                                        if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                            InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                        }
                                        
                                        if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                            if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)=='true'){
                                                InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"  checked="true" />';
                                            }else{
                                                InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"   />';
                                            }
                                        }else{//default
                                            InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"   checked="true" />'; 
                                        }
                                        
                                        String TempString = CheckingHightLight(SplitLineIntoRow(str,25));
                                        TempString=StringCaseHandler(TempString,TotalMonthlyVolume,ContractTotal); 
                                        InnerHTML+= '<span>'+TempString +'</span></td>';
                                    }else{//PDF 
                                        
                                        if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)=='true'){
                                            
                                            if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                                InnerHTML+= '<td  ';
                                                if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                                    InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                                }
                                                String TempString =str;
                                                TempString=StringCaseHandler(TempString,TotalMonthlyVolume,ContractTotal);
                                                TempString= CheckingHightLight(SplitLineIntoRow(TempString,25));
                                                InnerHTML+=' style="border: 1px solid black; " >•'+TempString+'</td>';
                                            }
                                        }
                                    }
                                    
                                }else{
                                    InnerHTML+= '<td  ';
                                    if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                        InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                    }
                                    
                                    InnerHTML+='  style="border: 1px solid black; "  >'+str+'</td>';
                                }
                                
                                CollumnNum++;
                            }
                            
                            InnerHTML+='</tr>';
                        }
                    }
                }
            }
            
            InnerHTML +='</table><br/>';
            ReturnHTML +=InnerHTML;
        }
        return ReturnHTML;
    }

    public String DrawingPSFTable(String ContentStr,Map<String,interimData> PSF_Item_Map,SectionWrapper ChildMap){
        System.debug(LoggingLevel.INFO, '*** ChildMap: ' + ChildMap);
        System.debug(LoggingLevel.INFO, '*** ChildMap: ' + ChildMap.subSectionMap);
        System.debug(LoggingLevel.INFO, '*** PSF_Item_Map: ' + PSF_Item_Map);
        System.debug(LoggingLevel.INFO, '*** PSF_Item_Map.keySet(): ' + PSF_Item_Map.keySet());
        List<String> parts = ContentStr.split('//');
        integer ModuleNumber=0;
        string ReturnHTML='';
        for(String key:PSF_Item_Map.keySet()){
            String InnerHTML='';
            ModuleNumber++;
            Decimal TotalMonthlyVolume  = 0.0;
            Decimal TotalMonthlyIncentive =0.0;
            Decimal TotalVolume  = 0.0;
            Decimal ContractTotal=0.0;
            InnerHTML+='<br/> <table  style="border: 1px solid black; border-collapse: collapse;" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+parts[0]+'</td><td style="border: 1px solid black; ">';
            if(PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand'){
                InnerHTML += parts[1]+'</td><td style="border: 1px solid black; " >'+parts[2]+'</td><td style="border: 1px solid black; ">';
            }
            InnerHTML+= parts[3]+'</td><td style="border: 1px solid black; " >'+parts[4]+'</td></tr>';
            
            integer coun = 1;
            for(String keyline:PSF_Item_Map.get(key).DetailLineMap.keySet()){
                if(PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand'){
                    String SubBrandTempName=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c:PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Sub_Brand__r.Name;
                    String SubBrandName = isEditable ? SubBrandTempName : SplitLineIntoRow(SubBrandTempName,8);
                    Decimal YearlyTotalVolume= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c*ContractSelected.ASI_CRM_CN_No_of_Months__c:0;
                    
                    InnerHTML+='<tr><td style="border: 1px solid black; ">'+SubBrandName+'</td><td style="border: 1px solid black; text-align: right;" >';
                    InnerHTML += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'
                        +PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'+
                        +YearlyTotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;">';
                    
                    TotalMonthlyVolume += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c !=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Monthly_Qty__c: 0.0;
                    TotalMonthlyIncentive += PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c !=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_BRSF_Per_Bottle__c: 0.0;
                    TotalVolume+= YearlyTotalVolume!=null? YearlyTotalVolume:0;
                }else{
                    if(PSF_Item_Map.get(key).VolumeBase=='By Grade'){
                        String SBGrade= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ==null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Sub_Brand_Grade__r.Name : PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ;
                        InnerHTML+='<tr><td style="border: 1px solid black; " >'+SBGrade +'</td><td style="border: 1px solid black; text-align: right;">';
                    }
                    if(PSF_Item_Map.get(key).VolumeBase=='By Category'){
                        String CategoryName= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Product_Category__r.Name; 
                        InnerHTML+='<tr><td style="border: 1px solid black; " >'+CategoryName+'</td><td style="border: 1px solid black; text-align: right;">';
                    }
                    if(PSF_Item_Map.get(key).VolumeBase=='By Total'){
                        InnerHTML+='<tr><td style="border: 1px solid black; " >按总销量</td><td style="border: 1px solid black;text-align: right; ">';
                    }
                    InnerHTML+= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Contract_Total_QTY_std_Btl__c.format()+'</td><td style="border: 1px solid black;text-align: right; ">' ;
                    TotalVolume+= PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Contract_Total_QTY_std_Btl__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_Contract_Total_QTY_std_Btl__c:0;
                    
                }
                InnerHTML+=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td></tr>';
                ContractTotal+=PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c!=null? PSF_Item_Map.get(key).DetailLineMap.get(keyline).ASI_CRM_CN_Contract_Total_Dummy__c:0;                
            }//Ending of looping
            
            
            //Footer
            if(ChildMap.subSectionMap!=null  ){
                
                for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                    if(ChildMap.subSectionMap.get(InnerKey).name=='PSFTableA_In_total'){ // display Total Amount 
                        InnerHTML+='<tr><td style="border: 1px solid black; " >'+ChildMap.subSectionMap.get(InnerKey).content+'</td>';
                        if(PSF_Item_Map.get(key).VolumeBase=='By Sub-Brand'){
                            InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalMonthlyVolume.format()+'</td>'+ '<td style="border: 1px solid black; text-align: right;" >'+'</td>';
                        }
                        InnerHTML+='<td style="border: 1px solid black; text-align: right;" >'+TotalVolume.format()+'</td>'+ '<td style="border: 1px solid black;text-align: right; " >'+ContractTotal.format()+'</td>';
                        InnerHTML+= '</tr>';
                    }else if(ChildMap.subSectionMap.get(InnerKey).name=='PSFTableA_HeaderTerm'){
                        if(ChildMap.subSectionMap.get(InnerKey).ClassName.contains(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase) ) ){ 
                            InnerHTML =String.valueOf(ModuleNumber)+')'+ ChildMap.subSectionMap.get(InnerKey).content+InnerHTML ;
                        } 
                    }else{
                        Boolean DisplayFlag= false;
                        SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                        if(SectionTypeClass.VolumeBase!=null && SectionTypeClass.VolumeBase==''){
                            DisplayFlag=true;
                        }else{
                            if(VolumeBaseNamingFixing(PSF_Item_Map.get(key).VolumeBase)==SectionTypeClass.VolumeBase){
                                DisplayFlag=true;
                            }
                        }
                        if(DisplayFlag){
                            InnerHTML+='<tr>';
                            //List<String> FooterParts = ChildMap.subSectionMap.get(InnerKey).content.split('//');
                            String NowContent=ChildMap.subSectionMap.get(InnerKey).content;
                            if(ChildMap.subSectionMap.get(InnerKey).content.right(2)=='//'){
                                NowContent+='  ';
                            }
                            List<String> FooterParts = NowContent.split('//');
                            
                            integer CollumnNum=1;
                            for(string str:FooterParts){
                                
                                if(SectionTypeClass.ClassType=='InputText' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                    InnerHTML+= '<td  ';
                                    if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                        InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                    }
                                    InnerHTML+=' style="border: 1px solid black; " >';
                                    if(isEditable){
                                        InnerHTML+='<textarea cols="50" rows="3" class="InputText " Module-Id="'+key+'"  data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+key+'"  ';
                                    }
                                    
                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                        String NoteStr= isEditable?  ' style="border: 1px solid black; " >'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key) ,25));
                                        InnerHTML+= NoteStr + '</td>';
                                    }else{
                                        if (str.trim().length()==0){
                                            str='';
                                        }
                                        InnerHTML+= isEditable?  '   style="border: 1px solid black; " >'+str+'</textarea></td>':SplitLineIntoRow(str, 25)+ '<br/></td>';
                                    }
                                }else if(SectionTypeClass.ClassType=='Selectable' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                    
                                    if(isEditable){
                                        InnerHTML+= '<td  ';
                                        if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                            InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                        }
                                        
                                        if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                            if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)=='true'){
                                                InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"  checked="true" />';
                                            }else{
                                                InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"   />';
                                            }
                                        }else{//default
                                            InnerHTML+=' style="border: 1px solid black; "  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+key+'" Module-Id="'+key+'"   checked="true" />'; 
                                        }
                                        
                                        String TempString = CheckingHightLight(SplitLineIntoRow(str,25));
                                        TempString=StringCaseHandler(TempString,TotalMonthlyVolume,ContractTotal); 
                                        InnerHTML+= '<span>'+TempString +'</span></td>';
                                    }else{//PDF 
                                        
                                        if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name+key)=='true'){
                                            
                                            if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name+key)){
                                                InnerHTML+= '<td  ';
                                                if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                                    InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                                }
                                                String TempString =str;
                                                TempString=StringCaseHandler(TempString,TotalMonthlyVolume,ContractTotal);
                                                TempString= CheckingHightLight(SplitLineIntoRow(TempString,25));
                                                InnerHTML+=' style="border: 1px solid black; " >•'+TempString+'</td>';
                                            }
                                        }
                                    }
                                    
                                }else{
                                    InnerHTML+= '<td  ';
                                    if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                        InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                                    }
                                    
                                    InnerHTML+='  style="border: 1px solid black; "  >'+str+'</td>';
                                }
                                
                                CollumnNum++;
                            }
                            
                            InnerHTML+='</tr>';
                        }
                    }
                }
            }
            
            InnerHTML +='</table><br/>';
            ReturnHTML +=InnerHTML;
        }
        return ReturnHTML;
    }
    
    public SectionType ClassNameHandler(String ClassNameStr){
        SectionType TempSectionType = new SectionType();
        List<String> parts =ClassNameStr.split(' ');
        for(string str:parts){
            if(str.contains('rowspan') || str.contains('colspan') ){//system.debug(str.right(1)+'Now '+str.left(1));
                TempSectionType.CollumnNumber= integer.valueOf(str.left(1));
                
                TempSectionType.StyleString=str.substring(1,8)+'='+str.right(1);
                TempSectionType.StyleStringCollumnNum= integer.valueOf(str.left(1));
                
                TempSectionType.TableStyleMap.put(integer.valueOf(str.left(1)), str.substring(1,8)+'='+str.right(1));
                
            }else if(str=='BySubBrand' || str=='ByGrade' || str=='ByCategory'  || str=='ByTotal' ){
                TempSectionType.VolumeBase=str;
            }else if(str.contains('InputText') || str.contains('Selectable')){
                TempSectionType.CollumnNumber= integer.valueOf(str.left(1));
                TempSectionType.ClassType= str.substring(1,str.length());
                TempSectionType.ClassTypeCollumnNum= integer.valueOf(str.left(1));
            }
        }
        return TempSectionType;
    }
    
    //Drawing Variable Event Cost Table 
    public String DrawingVECTable2nd(String ContentStr,String VolumeBase ,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> VECList,SectionWrapper ChildMap){
        String InnerHTML='';
        List<String> parts = ContentStr.split('//'); //产品列表//月销量指标//月达标销售折扣//年销量指标 //年达标销售折扣//备注 // 这里输入备注//总计 
        InnerHTML+='<table  style="border: 1px solid black; border-collapse: collapse;" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+ parts[0]+'</td><td style="border: 1px solid black; ">';
        if(VolumeBase=='By Sub-Brand' && vecdisplayType != 'total'){
            InnerHTML += parts[1]+'</td><td style="border: 1px solid black; " >'+parts[2]+'</td><td style="border: 1px solid black; ">';
        }
        InnerHTML+= parts[3]+'</td><td style="border: 1px solid black; " >'+parts[4]+'</td></tr>';    
        integer coun= 1;
        Decimal TotalMonthlyVolume = 0.0;
        Decimal TotalMonthlyIncentive =0.0;
        Decimal TotalVolume = 0.0;
        Decimal ContractTotal=0.0;
        String VolumeBaseStr = (VolumeBase=='By Sub-Brand' && vecdisplayType != 'total' ? VolumeBaseNamingFixing(VolumeBase) : 'ByTotal');
        
        
        String ModuleId='';
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:VECList){
            
            if(ContractLine.ASI_CRM_Module__c!=null && ModuleId==''){
                ModuleId=ContractLine.ASI_CRM_Module__c;
            }
            
            if(VolumeBase=='By Sub-Brand'){
                if (vecdisplayType != 'total') {
                    String SBTemp = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                    String SubBrandName = isEditable ? SBTemp: SplitLineIntoRow(SBTemp,10); // font-size:11px; 
                    
                    InnerHTML+='<tr  style="'+GenFontSize()+'" ><td style="border: 1px solid black;" >'+SubBrandName+'</td><td style="border: 1px solid black; text-align: right;">'+
                        ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'+ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+ '</td><td style="border: 1px solid black;text-align: right; ">';
                    TotalMonthlyVolume += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c :0.0;
                    TotalMonthlyIncentive += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c :0.0;
                }
            }
            if(VolumeBase=='By Grade'){
                String SBGrade=ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ==null? ContractLine.ASI_CRM_Sub_Brand_Grade__r.Name : ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ;
                
                InnerHTML+='<tr style="'+GenFontSize()+'" ><td style="border: 1px solid black; " >'+SBGrade+'</td><td style="border: 1px solid black; text-align: right;">';
            }
            if(VolumeBase=='By Category'){
                String CategoryName= ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : ContractLine.ASI_CRM_Product_Category__r.Name; 
                
                InnerHTML+='<tr style="'+GenFontSize()+'" ><td style="border: 1px solid black; " >'+CategoryName+'</td><td style="border: 1px solid black;text-align: right; ">';
            }
            if(VolumeBase=='By Total'){
                InnerHTML+='<tr style="'+GenFontSize()+'"><td style="border: 1px solid black; " >按总销量 </td><td style="border: 1px solid black;text-align: right; ">';
            }
            ContractTotal += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c :0.0;
            TotalVolume  += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c *ContractSelected.ASI_CRM_CN_No_of_Months__c :0.0;
            decimal  TotalVolumeTemp=  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c *ContractSelected.ASI_CRM_CN_No_of_Months__c :0.0;
            
            if (VolumeBase!='By Sub-Brand' || vecdisplayType != 'total') {
                InnerHTML+=TotalVolumeTemp.format()+'</td><td style="border: 1px solid black; text-align: right;">'+ ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td>';
            
                InnerHTML+='</tr>';
            }
            
            coun++;
        }
        if (VolumeBase=='By Sub-Brand' && vecdisplayType == 'total') {
            InnerHTML+='<tr style="'+GenFontSize()+'"><td style="border: 1px solid black; " >按总销量 </td><td style="border: 1px solid black;text-align: right; ">';
            InnerHTML+= TotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;">' ;
            InnerHTML+=ContractTotal.format()+'</td></tr>';
        }
        
        if(ChildMap.subSectionMap!=null ){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                if(ChildMap.subSectionMap.get(InnerKey).name=='VECTableA_In_total'){
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+ChildMap.subSectionMap.get(InnerKey).content+'</td>';
                    if(VolumeBase=='By Sub-Brand' && vecdisplayType != 'total'){
                        InnerHTML +='<td style="border: 1px solid black; text-align: right;" >'+TotalMonthlyVolume.format()+'</td><td style="border: 1px solid black; text-align: right;" >'+'</td>';//+TotalMonthlyIncentive.format()
                    }
                    InnerHTML +='<td style="border: 1px solid black; text-align: right;" >'+TotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;" >'+ContractTotal.format()+'</td></tr>';
                }else{
                    
                    Boolean DisplayFlag= false;
                    SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                    if(SectionTypeClass.VolumeBase!=null && SectionTypeClass.VolumeBase==''){
                        DisplayFlag=true;
                    }else{
                        if(VolumeBaseStr==SectionTypeClass.VolumeBase){
                            DisplayFlag=true;
                        }
                    }
                    
                    if(DisplayFlag){
                        InnerHTML+='<tr>';
                        String NowContent=ChildMap.subSectionMap.get(InnerKey).content;
                        if(ChildMap.subSectionMap.get(InnerKey).content.right(2)=='//'){
                            NowContent+='  ';
                        }
                        List<String> FooterParts = NowContent.split('//');
                        integer CollumnNum=1;
                        for(string str:FooterParts){
                            system.debug(' Log 4.5: '+str);
                            InnerHTML+= '<td style="border: 1px solid black; "  ';
                            if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                            }
                            if(SectionTypeClass.ClassType=='InputText' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                InnerHTML+='>';
                                if(isEditable){
                                    InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'"   Module-Id="'+ModuleId+'"  ';
                                }
                                
                                if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                                    String NoteStr= isEditable?  '>'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name) ,20));
                                    InnerHTML+= NoteStr + '</td>';
                                }else{
                                    if (str.trim().length()==0){
                                        str='';
                                    }
                                    InnerHTML+= isEditable?  '   >'+str+'</textarea></td>':str+ '<br/></td>';
                                }
                                
                            }else if(SectionTypeClass.ClassType=='Selectable' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                
                                if(isEditable){
                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                                        if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)=='true'){
                                            InnerHTML+='  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+'" checked="true"/>';//+str+'</td>';   
                                        }else{
                                            InnerHTML+='  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+'"  />';//+str+'</td>';
                                        }
                                    }else{//default
                                        InnerHTML+='  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+'"  checked="true"/>';//+str+'</td>';
                                    }
                                    
                                    str=StringCaseHandler(str,TotalMonthlyVolume,ContractTotal);
                                    InnerHTML+=str+'</td>';
                                    
                                }else{//PDF 
                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                                        str=StringCaseHandler(str,TotalMonthlyVolume,ContractTotal);
                                        str= CheckingHightLight(SplitLineIntoRow(str,35));
                                        InnerHTML+='  >'+str+'</td>';
                                    }
                                }
                                
                            }else{
                                InnerHTML+='  >'+str+'</td>';
                            }
                            
                            CollumnNum++;
                        }
                        
                        InnerHTML+='</tr>';
                    }
                }
            }
        }
        
        InnerHTML+='</table>';
        return InnerHTML;
    }

    public String DrawingVECTable(String ContentStr,String VolumeBase ,List<ASI_CRM_CN_Contract_BRSF_Line_Item__c> VECList,SectionWrapper ChildMap){
        String InnerHTML='';
        List<String> parts = ContentStr.split('//'); //产品列表//月销量指标//月达标销售折扣//年销量指标 //年达标销售折扣//备注 // 这里输入备注//总计 
        InnerHTML+='<table  style="border: 1px solid black; border-collapse: collapse;" ><tr style="border: 1px solid black; " ><td style="border: 1px solid black; ">'+ parts[0]+'</td><td style="border: 1px solid black; ">';
        if(VolumeBase=='By Sub-Brand'){
            InnerHTML += parts[1]+'</td><td style="border: 1px solid black; " >'+parts[2]+'</td><td style="border: 1px solid black; ">';
        }
        InnerHTML+= parts[3]+'</td><td style="border: 1px solid black; " >'+parts[4]+'</td></tr>';    
        integer coun= 1;
        Decimal TotalMonthlyVolume = 0.0;
        Decimal TotalMonthlyIncentive =0.0;
        Decimal TotalVolume = 0.0;
        Decimal ContractTotal=0.0;
        
        
        String ModuleId='';
        for(ASI_CRM_CN_Contract_BRSF_Line_Item__c ContractLine:VECList){
            
            if(ContractLine.ASI_CRM_Module__c!=null && ModuleId==''){
                ModuleId=ContractLine.ASI_CRM_Module__c;
            }
            
            if(VolumeBase=='By Sub-Brand'){
                String SBTemp = ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c!=null? ContractLine.ASI_CRM_CN_Sub_Brand__r.ASI_CRM_CN_CHI_NAME_C__c:ContractLine.ASI_CRM_CN_Sub_Brand__r.Name;
                String SubBrandName = isEditable ? SBTemp: SplitLineIntoRow(SBTemp,10); // font-size:11px; 
                
                InnerHTML+='<tr  style="'+GenFontSize()+'" ><td style="border: 1px solid black;" >'+SubBrandName+'</td><td style="border: 1px solid black; text-align: right;">'+
                    ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c.format()+'</td><td style="border: 1px solid black; text-align: right;">'+ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c.format()+ '</td><td style="border: 1px solid black;text-align: right; ">';
                TotalMonthlyVolume += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c :0.0;
                TotalMonthlyIncentive += ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c!=null? ContractLine.ASI_CRM_CN_Contract_BRSF_Per_Bottle__c :0.0;
            }
            if(VolumeBase=='By Grade'){
                String SBGrade=ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ==null? ContractLine.ASI_CRM_Sub_Brand_Grade__r.Name : ContractLine.ASI_CRM_Sub_Brand_Grade__r.ASI_CRM_Chinese_Name__c ;
                
                InnerHTML+='<tr style="'+GenFontSize()+'" ><td style="border: 1px solid black; " >'+SBGrade+'</td><td style="border: 1px solid black; text-align: right;">';
            }
            if(VolumeBase=='By Category'){
                String CategoryName= ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c != null? ContractLine.ASI_CRM_Product_Category__r.ASI_CRM_CN_Chinese_Name__c : ContractLine.ASI_CRM_Product_Category__r.Name; 
                
                InnerHTML+='<tr style="'+GenFontSize()+'" ><td style="border: 1px solid black; " >'+CategoryName+'</td><td style="border: 1px solid black;text-align: right; ">';
            }
            if(VolumeBase=='By Total'){
                InnerHTML+='<tr style="'+GenFontSize()+'"><td style="border: 1px solid black; " >按总销量 </td><td style="border: 1px solid black;text-align: right; ">';
            }
            ContractTotal += ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c!=null? ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c :0.0;
            TotalVolume  += ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c *ContractSelected.ASI_CRM_CN_No_of_Months__c :0.0;
            decimal  TotalVolumeTemp=  ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c!=null? ContractLine.ASI_CRM_CN_Contract_Monthly_Qty__c *ContractSelected.ASI_CRM_CN_No_of_Months__c :0.0;
            
            InnerHTML+=TotalVolumeTemp.format()+'</td><td style="border: 1px solid black; text-align: right;">'+ ContractLine.ASI_CRM_CN_Contract_Total_Dummy__c.format()+'</td>';
            
            InnerHTML+='</tr>';
            coun++;
        }
        
        if(ChildMap.subSectionMap!=null ){
            for(integer InnerKey : ChildMap.subSectionMap.keySet()){
                if(ChildMap.subSectionMap.get(InnerKey).name=='VECTableA_In_total'){
                    InnerHTML+='<tr><td style="border: 1px solid black; " >'+ChildMap.subSectionMap.get(InnerKey).content+'</td>';
                    if(VolumeBase=='By Sub-Brand'){
                        InnerHTML +='<td style="border: 1px solid black; text-align: right;" >'+TotalMonthlyVolume.format()+'</td><td style="border: 1px solid black; text-align: right;" >'+'</td>';//+TotalMonthlyIncentive.format()
                    }
                    InnerHTML +='<td style="border: 1px solid black; text-align: right;" >'+TotalVolume.format()+'</td><td style="border: 1px solid black; text-align: right;" >'+ContractTotal.format()+'</td></tr>';
                }else{
                    
                    Boolean DisplayFlag= false;
                    SectionType SectionTypeClass = ClassNameHandler(ChildMap.subSectionMap.get(InnerKey).ClassName);
                    if(SectionTypeClass.VolumeBase!=null && SectionTypeClass.VolumeBase==''){
                        DisplayFlag=true;
                    }else{
                        if(VolumeBaseNamingFixing(VolumeBase)==SectionTypeClass.VolumeBase){
                            DisplayFlag=true;
                        }
                    }
                    
                    if(DisplayFlag){
                        InnerHTML+='<tr>';
                        String NowContent=ChildMap.subSectionMap.get(InnerKey).content;
                        if(ChildMap.subSectionMap.get(InnerKey).content.right(2)=='//'){
                            NowContent+='  ';
                        }
                        List<String> FooterParts = NowContent.split('//');
                        integer CollumnNum=1;
                        for(string str:FooterParts){
                            system.debug(' Log 4.5: '+str);
                            InnerHTML+= '<td style="border: 1px solid black; "  ';
                            if(SectionTypeClass.TableStyleMap.containsKey(CollumnNum)){
                                InnerHTML+=SectionTypeClass.TableStyleMap.get(CollumnNum);
                            }
                            if(SectionTypeClass.ClassType=='InputText' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                InnerHTML+='>';
                                if(isEditable){
                                    InnerHTML+='<textarea cols="50" rows="3" class="InputText " data-id="'+ChildMap.subSectionMap.get(InnerKey).Name+'"   Module-Id="'+ModuleId+'"  ';
                                }
                                
                                if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                                    String NoteStr= isEditable?  '>'+ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)+'</textarea>'  : CheckingHightLight(SplitLineIntoRow( ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name) ,20));
                                    InnerHTML+= NoteStr + '</td>';
                                }else{
                                    if (str.trim().length()==0){
                                        str='';
                                    }
                                    InnerHTML+= isEditable?  '   >'+str+'</textarea></td>':str+ '<br/></td>';
                                }
                                
                            }else if(SectionTypeClass.ClassType=='Selectable' && CollumnNum ==SectionTypeClass.ClassTypeCollumnNum){
                                
                                if(isEditable){
                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                                        if(ContractSettingMap.get(ChildMap.subSectionMap.get(InnerKey).Name)=='true'){
                                            InnerHTML+='  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+'" checked="true"/>';//+str+'</td>';   
                                        }else{
                                            InnerHTML+='  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+'"  />';//+str+'</td>';
                                        }
                                    }else{//default
                                        InnerHTML+='  ><input type="checkbox" class="bodySelection '+ChildMap.subSectionMap.get(InnerKey).Name+'"  checked="true"/>';//+str+'</td>';
                                    }
                                    
                                    str=StringCaseHandler(str,TotalMonthlyVolume,ContractTotal);
                                    InnerHTML+=str+'</td>';
                                    
                                }else{//PDF 
                                    if(ContractSettingMap.containsKey(ChildMap.subSectionMap.get(InnerKey).Name)){
                                        str=StringCaseHandler(str,TotalMonthlyVolume,ContractTotal);
                                        str= CheckingHightLight(SplitLineIntoRow(str,35));
                                        InnerHTML+='  >'+str+'</td>';
                                    }
                                }
                                
                            }else{
                                InnerHTML+='  >'+str+'</td>';
                            }
                            
                            CollumnNum++;
                        }
                        
                        InnerHTML+='</tr>';
                    }
                }
            }
        }
        
        InnerHTML+='</table>';
        return InnerHTML;
    }
    
    public String StringCaseHandler(String InputString,Decimal TotalMonthlyVolume,Decimal ContractTotal){
        if(InputString.contains('{TotalMonthlyVolume}')){
            InputString=InputString.replace('{TotalMonthlyVolume}',TotalMonthlyVolume.format());
        }
        if(InputString.contains('{ContractTotal}')){
            InputString=InputString.replace('{ContractTotal}',ContractTotal.format());
        }
        if(InputString.contains('{BCRate}')){
            InputString=InputString.replace('{BCRate}',ContractSelected.ASI_CRM_CN_Bottle_Collection_Rate__c.setScale(0)+'%');
        }
        if(InputString.contains('{MartellBCRate}')){
            InputString=InputString.replace('{MartellBCRate}',ContractSelected.ASI_CRM_Martell_BC_Rate__c.setScale(0)+'%');
        }
        
        if(InputString.contains('{Key-SubBrand}')){
            if(KeySubBrandSet.size()>0){
                String SubBrandNames= String.valueOf(KeySubBrandSet);
                SubBrandNames= SubBrandNames.replace('{','');
                SubBrandNames= SubBrandNames.replace('}','');
                InputString=InputString.replace('{Key-SubBrand}', SubBrandNames);
            }
        }
        return InputString;
    }
    
    public String VolumeBaseNamingFixing(String InputName){
        String str=InputName.replace('-','');
        return str.replace(' ','');
    }
    
    private String SplitStringLine(String InputString){
        return SplitLineIntoRow(InputString,BodyContentCuttingNumber);
    }
    @TestVisible
    private String TableSplitLineRow(String InputString,integer CutNumber ){
        //handle contain '<br/>' case //system.debug('TableSplitLineRow InputString   '+ InputString);
        String outputString ='';
        
        if(!isEditable){
            InputString = InputString.replace('<br/>','|');
            
            if(InputString.length() >= CutNumber ){
                if(InputString.contains('|')){
                    while(InputString.length() >= CutNumber ){ 
                        String StringCut = InputString.subString(0,CutNumber);
                        if(StringCut.contains('|')){
                            integer IndexNum = StringCut.indexOf('|');
                            String FixedString = StringCut.subString(0,IndexNum+1);
                            FixedString=FixedString.replace('|','');
                            
                            outputString = outputString + FixedString + '<br/>'; 
                            InputString= InputString.subString(IndexNum+1);  // StringCut.subString(IndexNum,StringCut.length()-1)+
                        }else{
                            outputString = outputString + StringCut + '<br/>';
                            InputString= InputString.subString(CutNumber);
                        }
                    }
                }else{
                    while(InputString.length() >= CutNumber ){ 
                        outputString = outputString + InputString.subString(0,CutNumber) + '<br/>';
                        InputString= InputString.subString(CutNumber);
                    }
                    
                }
                
            }
            InputString=InputString.replace('|','');
            outputString = outputString + InputString;
            
            
        }else{
            outputString=InputString;
        }
        
        return outputString;
    }
    
    
    
    
    
    
    
    public string genSpace(integer LoopingTimes){
        String spacestr='1';
        String returnString = '';
        for(integer i =0; i<LoopingTimes; i++ ){
            returnString+= spacestr;
        }
        
        return returnString;
    }
    
    
    
    public String GenFontSize(){
        String StyleCSS='';
        if(!isEditable){
            //StyleCSS='font-size:11px;';
        }
        return StyleCSS;
    }
    
    
    
    
    
    
    
    
    
    //Generate  Party C Wholesaler input in Header
    private String GeneratingPartyC_Header( Boolean DisplayOnly){
        System.debug(LoggingLevel.INFO, '*** ContractSelected ' + ContractSelected.ASI_CRM_CN_Outlet_WS__c);
        String HTMLString='<table id="WholesalerTable" >';
        if(PartyCIDSet.size()>0){ // contain in the database
            Integer CountNum=1;
            
            if(isEditable){
                for(String PartyCstr: PartyCIDSet){
                    if(ContractSettingMap.containsKey(PartyCstr)){
                        List<String> Wholesaler = ContractSettingMap.get(PartyCstr).split(':');
                        System.debug(LoggingLevel.INFO, '*** : Wholesaler' + Wholesaler);
                        HTMLString+= '<tr><td>';
                        if(CountNum!=1){// Button X 
                            HTMLString+= '</td><td> <button type="button" style="color: #fff; background-color: #f0ad4e; border-color: #eea236; display: inline-block;  margin-bottom: 0;font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > X</button>';  
                        }else{// Button + 
                            HTMLString+=  ' 乙方：</td><td><button type="button" onclick ="AddingNewWholesaler();" style="color: #fff; background-color:#7e8be4; border-color: #7e8be4; display: inline-block; margin-bottom: 0; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > + </button>' ;
                        }
                        
                        HTMLString+='<input type="text" class="Header_PartyC RequiredField InputText" name="PartyC" data-id="PartyC'+string.valueOf(CountNum)+'" id="PartyC" value="'+
                            Wholesaler.get(0)+ '" Legal-Name="'+Wholesaler.get(2)+'" data-value ="'+Wholesaler.get(1)+'" ></input></td></tr>' ; //(批发商名称)
                    }
                    CountNum++;
                }
            }else{// print name 
                System.debug(LoggingLevel.INFO, '*** : 进入2');
                for(String PartyCstr: PartyCIDSet){
                    if(ContractSettingMap.containsKey(PartyCstr)){
                        List<String> Wholesaler = ContractSettingMap.get(PartyCstr).split(':');
                        if(CountNum!=1){
                            HTMLString+='<tr><td style="color: white;" >乙方：</td> ';
                        }else{ // CountNum == 1 
                            HTMLString+='<tr><td >乙方：</td> ';
                        }
                        HTMLString+='<td>'+CheckingHightLight(Wholesaler.get(2))+'</td></tr>';//(批发商名称)
                        CountNum++;
                    }
                    
                    
                }
            }
        }else{
            if(isEditable){// default
                
                
                String EffectiveSupplierName='';
                String EffectiveSupplierId='';
                PartyCLegalName='';
                List<ASI_CRM_Effective_supplier__c> EffectiveSupplierList =[select id,ASI_CRM_Supplier__c,ASI_CRM_Supplier__r.Name,ASI_CRM_Last_tran_date__c,ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c 
                                                                            from ASI_CRM_Effective_supplier__c where ASI_CRM_Account__c=:ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                                            order by ASI_CRM_Last_tran_date__c desc];
                System.debug(LoggingLevel.INFO, '*** : 进入3'+EffectiveSupplierList);
                if(EffectiveSupplierList.size()>0){
                    EffectiveSupplierName= EffectiveSupplierList[0].ASI_CRM_Supplier__r.Name;
                    EffectiveSupplierId= EffectiveSupplierList[0].ASI_CRM_Supplier__c;
                    PartyCLegalName=EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c !=null?EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c:'';
                }
                
                HTMLString+= '<tr><td>乙方：</td><td>'+
                    ' <button type="button" onclick ="AddingNewWholesaler();" style="color: #fff; background-color:#7e8be4; border-color: #7e8be4; display: inline-block; margin-bottom: 0; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > + </button>' ;
                HTMLString+= '<input  type="text" class="Header_PartyC RequiredField InputText" name="PartyC"  data-id="PartyC1"  id="PartyC" value="'+EffectiveSupplierName+
                    '" Legal-Name="'+PartyCLegalName+'"  data-value ="'+EffectiveSupplierId+'" ></input> </td></tr>' ;// (批发商名称)
            }else{
                HTMLString+= '<tr><td>乙方：</td><td>'+
                    ' <button type="button" onclick ="AddingNewWholesaler();" style="color: #fff; background-color:#7e8be4; border-color: #7e8be4; display: inline-block; margin-bottom: 0; font-weight: 400; line-height: 1.42857143; text-align: center; white-space: nowrap;user-select: none; background-image: none; border: 1px solid transparent; border-radius: 4px;" > + </button>' ;
                HTMLString+= '<input  type="text" class="Header_PartyC RequiredField InputText" name="PartyC"  data-id="PartyC1"  id="PartyC" value=""></input></td></tr>' ; // (批发商名称)
            }
        }
        HTMLString+='</table>';
        
        if(DisplayOnly && isEditable){
            HTMLString ='乙方：';
        }
        /*
        if(DisplayOnly && !isEditable){
            HTMLString ='乙方：'+HTMLString;
        }*/
        
        return HTMLString;
        
    }
    
    
        
    
    //Generate  Generating one Effective Supplier Input
    private String GeneratingEffectiveSupplierInput(String InputKey,Boolean DisplayOnly){
        
        String HTMLString=' ';
        if(ContractSettingMap.containsKey(InputKey)){
             List<String> Wholesaler = ContractSettingMap.get(InputKey).split(':');
            if(isEditable && !DisplayOnly){
               
                HTMLString+='<input type="text" class="Header_PartyC RequiredField InputText" name="PartyC" data-id="'+InputKey+'" id="'+InputKey+'" value="'+
                            Wholesaler.get(0)+ '" Legal-Name="'+Wholesaler.get(2)+'" data-value ="'+Wholesaler.get(1)+'" ></input>' ;
                
            }else{
                
                HTMLString+= Wholesaler.get(2)!=null? Wholesaler.get(2): Wholesaler.get(0);
            }
        }else{
            if(isEditable){// default
                String EffectiveSupplierName='';
                String EffectiveSupplierId='';
                PartyCLegalName='';
                List<ASI_CRM_Effective_supplier__c> EffectiveSupplierList =[select id,ASI_CRM_Supplier__c,ASI_CRM_Supplier__r.Name,ASI_CRM_Last_tran_date__c,ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c 
                                                                            from ASI_CRM_Effective_supplier__c where ASI_CRM_Account__c=:ContractSelected.ASI_CRM_CN_Outlet_WS__c
                                                                            order by ASI_CRM_Last_tran_date__c desc];
                if(EffectiveSupplierList.size()>0){
                    EffectiveSupplierName= EffectiveSupplierList[0].ASI_CRM_Supplier__r.Name;
                    EffectiveSupplierId= EffectiveSupplierList[0].ASI_CRM_Supplier__c;
                    PartyCLegalName=EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c !=null?EffectiveSupplierList[0].ASI_CRM_Supplier__r.ASI_CRM_CN_Legal_Name__c:'';
                }
                
                HTMLString+= '<input  type="text" class="Header_PartyC RequiredField InputText" name="EffectiveSupplierName"  data-id="'+InputKey+'"  id="'+InputKey+'" value="'+EffectiveSupplierName+
                    '" Legal-Name="'+PartyCLegalName+'"  data-value ="'+EffectiveSupplierId+'" ></input>' ;
            }
            if(DisplayOnly){
               HTMLString=' '; 
            }
        }
        
     
        
        return HTMLString;
    }
    
    
    
    
    
    public String CheckingHightLight(String InputContent){
        if(HightLight){ //  #FFFF00
            InputContent='<span style="background-color: #3399ff">'+InputContent+'</span>';
        }
        return  InputContent;
    }
    
    
    private String SplitLineIntoRow(String InputString,integer CutNumber){
        String outputString ='';
        
        integer tempCutNumber = CutNumber;
        if (!isEditable){
            List<String> inputLineList = InputString.split('<br/>');
            for (String inputLine:inputLineList){
                if (inputLine.length() < CutNumber){
                    outputString += inputLine + '<br/>';
                } else {
                    system.debug('inputLine: ' + inputLine);
                    while(inputLine.length() >= CutNumber ){
                        //Add 1 for every 2 symbol/number/alphabet
                        //Add 2 for each '\n'
                        Integer offset = inputLine.subString(0,CutNumber).countMatches('/n') * 2 + (inputLine.subString(0, CutNumber).replaceAll('[\\w ,."*()\'=<>%0-9]','c').countMatches('c') / 2);
                        
                        //To prevent out of bound, new cut number cannot exceed length of the line 
                        tempCutNumber = Math.min(inputLine.length(), CutNumber + offset);
                        
                        Pattern p = Pattern.compile(reservedPattern);
                        Matcher m;
                        do {
                            m = p.matcher(inputLine.subString(tempCutNumber).left(1));
                            if (m.matches()){
                                tempCutNumber = Math.min(inputLine.length(), tempCutNumber + 1);
                            }
                        } while (m.matches());
                        outputString = outputString + inputLine.subString(0,tempCutNumber);
                           
                        //If next line contains less than 2 characters or the line contain line break, forfeit new line
                        if ((inputLine.subString(tempCutNumber).length() > 2 && !inputLine.subString(0,tempCutNumber).contains('<b'))){
                            outputString += '<br/>';
                        }
                        inputLine= inputLine.subString(tempCutNumber);
                    }
                    outputString += inputLine + '<br/>';
                }
            }
            //outputString = outputString + InputString;
        }else{
            outputString=InputString;
        }
        return outputString;
    }
   
    
    public String LineBreakProcess(String InputString,integer CutNumber,integer EnAddNumber ){
        String outputString ='';
        integer tempCutNumber = CutNumber;
        if(!isEditable){// output for PDF
            if(!ASI_CRM_CN_HeavyContracFunctionClass.containsChineseCharacters(InputString)){
                CutNumber= CutNumber + EnAddNumber;
            }
            outputString = SplitLineIntoRow(InputString, CutNumber);
        }else{
            outputString = InputString;
        }
        return outputString;
    }
    
    //Replace the content with the key word
    public String ContentReplace(String InputContent,String InputName,String InputClassName){
        if(InputContent!=null){
            if(InputContent.contains('{InputText}')){
                string InnerHTML='';
                String SavedKey = InputName + 'InputText';
                if(ContractSettingMap.containsKey(SavedKey)){
                    string InputTextArea = ContractSettingMap.get(SavedKey)!=null? ContractSettingMap.get(SavedKey) : '';
                    if(!isEditable){ 
                        InnerHTML+= CheckingHightLight(SplitLineIntoRow(InputTextArea,10));
                    }else{
                        InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+InputName+'"     >' + InputTextArea + '</textarea>';
                    }
                }else if(isEditable){
                    InnerHTML+='<textarea cols="30" rows="3" class="InputText " data-id="'+SavedKey+'"    >' +'   ' + '</textarea>';
                }
                InputContent = InputContent.replace('{InputText}', InnerHTML);
            }
            
            if(InputContent.contains('{CoveredOutletTable}')){
                
                InputContent = InputContent.replace('{CoveredOutletTable}',GeneratingCoveredOutletTable() );
            }
        }
        return InputContent;
    }

    //Checking the checkbox with its content is show or not
    public Boolean CheckingIsVisibleOrNot(String InputName){
        Boolean ReturnIsShow= true;
        if(ContractSettingMap.containsKey(InputName)){
            if(ContractSettingMap.get(InputName)=='false'){
                ReturnIsShow= false;
            }
        }
        
        return ReturnIsShow;
    }
    
    //*****************************************
    //Loading XML Document
    //***************************************
    private void LoadDocumentFiles() {//ASI_CRM_CN_Central_Premium
        //select id,DeveloperName from Folder where DeveloperName='ASI_CRM_CN_Central_Premium'          
        Document DocumentFile  = new Document();
        
        if(ContractSelected.ASI_CRM_Contract_Template_Id__c !=null){
            DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where Id= : ContractSelected.ASI_CRM_Contract_Template_Id__c ];
        }else{
            
            String FolderDeveloperName='ASI_CRM_CN';
            
            FolderDeveloperName+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? '_'+ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c.replace(' Region',''):'';
            FolderDeveloperName+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c!=null? '_'+ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c:'';
            
            
            
            if(ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c==null && ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Commercial_Team__c==null){
                FolderDeveloperName+='_General';
            }
            FolderDeveloperName = FolderDeveloperName.replace(' ','');
            if(ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c){
                FolderDeveloperName = FolderDeveloperName + '_2nd';
            }
            Folder FolderSelected = new Folder();
            
            try{
                system.debug('Finally we get1 '+FolderDeveloperName);
                FolderSelected =[select id,DeveloperName from Folder where DeveloperName=:FolderDeveloperName limit 1 ];
                DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc limit 1]; //Document DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where DeveloperName =:'ASI_CRM_CN_South_Prestige' limit 1];
            }catch(exception e){
                try{
                    FolderDeveloperName='ASI_CRM_CN';
                    FolderDeveloperName+= ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c!=null? '_'+ContractSelected.ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Region__c.replace(' Region',''):'';
                    FolderDeveloperName = FolderDeveloperName.replace(' ','');
                    system.debug('Finally we get2 '+FolderDeveloperName);
                    FolderSelected =[select id,DeveloperName from Folder where DeveloperName=:FolderDeveloperName limit 1 ];
                    DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc limit 1]; 
                }catch(exception e2){
                    system.debug('Finally we get ASI_CRM_CN_General ');
                    if(!Test.isRunningTest()){
                        FolderSelected =[select id,DeveloperName from Folder where DeveloperName='ASI_CRM_CN_General' limit 1 ];
                        DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where FolderId =:FolderSelected.Id order BY LastModifiedDate desc limit 1];
                    }else{
                        DocumentFile =[select id,Body,FolderId,LastModifiedDate from Document where DeveloperName ='ASI_CRM_CN_Heavy_Test_document' limit 1];
                    }
                    
                }
                
            }
        }
        System.debug(LoggingLevel.INFO, '*** DocumentFile: ' + DocumentFile);
        String xmlStr='';
        if(!Test.isRunningTest()){
            xmlStr = DocumentFile.body.toString();
        }else{
            xmlStr = xmlStringTestClass;
        }
        //String xmlStr = DocumentFile.body.toString();
        System.debug(LoggingLevel.INFO, '*** xmlStr: ' + xmlStr);
        Dom.Document doc = new Dom.Document();
        doc.load(xmlStr);
        System.debug(LoggingLevel.INFO, '*** doc: ' + doc);

        Dom.XMLNode docRootNode  = doc.getRootElement();
        System.debug(LoggingLevel.INFO, '*** docRootNode: ' + docRootNode);
        Dom.XMLNode headerNode   = docRootNode.getChildElement('header', null);
        Dom.XMLNode bodyNode     = docRootNode.getChildElement('body', null);
        Dom.XMLNode BodySignatureNode = docRootNode.getChildElement('BodySignature', null);
        Dom.XMLNode appendixNode = docRootNode.getChildElement('appendix', null);
        Dom.XMLNode AppendixSignatureNode = docRootNode.getChildElement('AppendixSignature', null);
        
        
        headerSectionMap   = parseXML(headerNode,'header',BodyContentCuttingNumber);
        BodySectionMap     = parseXML(bodyNode,'body',BodyContentCuttingNumber);
        BodySignatureMap   = parseXML(BodySignatureNode,'BodySignature',BodyContentCuttingNumber);
        PartyCBodySignatureMap   = parseXML(BodySignatureNode,'BodySignature',BodyContentCuttingNumber);
        System.debug(LoggingLevel.INFO, '*** appendixNode: ' + appendixNode);
        AppendixSectionMap = parseXML(appendixNode,'appendix',BodyContentCuttingNumber);
        AppendixSignatureMap= parseXML(AppendixSignatureNode,'AppendixSignature',BodyContentCuttingNumber);
        
        
    }    
    
    private Map<integer, SectionWrapper> parseXML(Dom.XMLNode sectionNode,String NodeType,Integer LineCuttingNumber) {
        Map<integer, SectionWrapper> sectionWrapperMap = new Map<integer, SectionWrapper>();
        integer count=1;
        for(Dom.XMLNode childNode : sectionNode.getChildElements()) {
            
            String name                                = childNode.getAttribute('name', null);
            String style                               = childNode.getAttribute('style', null);
            String content                             = childNode.getChildElement('content', null).getText();
            String displayNumber                       = childNode.getAttribute('displayNumber', null);
            String type                                = childNode.getChildElement('type', null).getText();
            String ClassName                            = childNode.getAttribute('class', null);
            
            
            Map<integer, SectionWrapper> subSectionMap = null;
            Dom.XMLNode subSectionNode = childNode.getChildElement('subSection', null);
            if(subSectionNode != null) {
                subSectionMap = parseXML(subSectionNode,NodeType,InnerContentCuttingNumber);
            }
           
            SectionWrapper sectionWrapper = new SectionWrapper(name, content,style, displayNumber, ClassName,type,subSectionMap);
            sectionWrapperMap.put(count,sectionWrapper);
            count++;
        }
        return sectionWrapperMap;
    }
        
    @RemoteAction
    global static String ChangeTemplate(ASI_TH_CRM_Contract__c InputObject,String RegionName,Boolean IsTwoParty){
        string msg='OK';        
         List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutList = [select id from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c=: InputObject.Id];
         InputObject = [SELECT ASI_CRM_CN_Is_2nd_KPI_PO__c FROM ASI_TH_CRM_Contract__c WHERE Id =: InputObject.Id];
        try{
            Document DocumentFile;
            if (InputObject.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                DocumentFile =ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplateOldOrNew(RegionName,IsTwoParty);
            } else {
                DocumentFile =ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplate(RegionName,IsTwoParty);
            }
            // Document DocumentFile =ASI_CRM_CN_HeavyContracFunctionClass.GenerateContractTemplateOldOrNew(RegionName,IsTwoParty);
            InputObject.ASI_CRM_Contract_Template_Id__c=DocumentFile!=NULL?DocumentFile.Id:NULL;
            if(IsTwoParty){
                InputObject.ASI_CRM_CN_Two_Party_Contract_Template__c =true;
            }else{
                InputObject.ASI_CRM_CN_Two_Party_Contract_Template__c =false; 
            }
            update InputObject;
             
            if(contractPrintoutList.size() > 0) {
                delete contractPrintoutList;
            }
            
        } catch (DMLException e){
            ASI_MFM_ByPass_Setting.ErrorHandling('ASI_CRM_CN_HeavyContractGenerationCtrl.UpdateRecord <br/> in ASI_CRM_CN_ViewHeavyContractPage class have Error  '+'Save Error : ' +e.getMessage() + '</br>','ASI_CRM_CN_HeavyContractGenerationPage',' ');
        }
        
        return msg;
    }
    
    //nextStep:  'back'/ 'approver' / 'customer'
    //InputAmountUpdatedListJson  : Save to ASI_CRM_Contract_Printout_Setting__c 
    //TextUpdatedListJson : Save to ASI_CRM_Contract_Printout_Setting__c 
    //ModuleRefListJson  : Save to ASI_CRM_Module__c 
    // /ContractCostLinesJson save to  ASI_CRM_Contract_Terms__c in ASI_CRM_Contract_Cost__c 
    @RemoteAction
    global static String saveTemplate2nd(String nextStep, String contractId,String InputAmountUpdatedListJson,
                                      String TextUpdatedListJson,String ModuleRefListJson , String ContractCostLinesJson,String fcdisplayType,String psfdisplayType,String vecdisplayType){
        List<String> InputAmountUpdatedList= (List<String>) fromJsonString(InputAmountUpdatedListJson, List<String>.class);
        List<String> TextUpdatedList = (List<String>) fromJsonString(TextUpdatedListJson, List<String>.class);
        List<String> ModuleRefList = (List<String>) fromJsonString(ModuleRefListJson, List<String>.class);
        List<String> ContractCostList = (List<String>) fromJsonString(ContractCostLinesJson, List<String>.class);
        String Msg='OK';
        
        System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            // *******************************Module *******************************
            Map<String,string> ReferenceMap = new Map<String,string>();
            
            for(String ModuleRecord : ModuleRefList) {
                List<String> ModuleInformation = ModuleRecord.split('//');
                if(ModuleInformation.size()>1){
                    if(ReferenceMap.containsKey(ModuleInformation.get(0))){
                        String TempReference= ReferenceMap.get(ModuleInformation.get(0))+'<br/>• '+ModuleInformation.get(1);
                        ReferenceMap.remove(ModuleInformation.get(0));
                        ReferenceMap.put(ModuleInformation.get(0), TempReference);
                    }else{
                        ReferenceMap.put(ModuleInformation.get(0), '• '+ModuleInformation.get(1));
                    }
                }
            }
            //Update Module
            List<ASI_CRM_Module__c> UpdatedModuleList = new List<ASI_CRM_Module__c>();
            for(string  ModuleKey:ReferenceMap.keySet()){
                UpdatedModuleList.add(New ASI_CRM_Module__c( Id=ModuleKey,ASI_CRM_Payment_Reference__c=ReferenceMap.get(ModuleKey)));
            }
            if(UpdatedModuleList.size()>0){
                update UpdatedModuleList;
            }
            
            //update contract generate contract Type
            ASI_TH_CRM_Contract__c atcc= new ASI_TH_CRM_Contract__c();
            atcc.ASI_CRM_CN_Generate_Contract_Type__c = fcdisplayType;
            atcc.ASI_CRM_CN_Generate_PSF_Type__c = psfdisplayType;
            atcc.ASI_CRM_CN_Generate_VEC_Type__c = vecdisplayType;
            atcc.Id = contractId;
            UPDATE atcc;

            //*********************Contract Print out List ********************* Delete existing saved template
            List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutList = [select id from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c=: contractId];
            if(contractPrintoutList.size() > 0) {
                delete contractPrintoutList;
            }
            List<ASI_CRM_Contract_Printout_Setting__c> ContractPrintoutSettingList = new List<ASI_CRM_Contract_Printout_Setting__c>();
            
            for(String TextField : TextUpdatedList) {
                List<String> TextInformation = TextField.split('//');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
                tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'appendix';
                tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = TextInformation.get(0);
                tempContractPrintoutSetting.ASI_CRM_Section_Content__c   = TextInformation.get(1);
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            for(String AmountField : InputAmountUpdatedList) {
                List<String> Information = AmountField.split('//');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                system.debug(Information.get(1) + ' 00000 : '+Information.get(0));
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
                tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'appendix';
                tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = Information.get(0);
                tempContractPrintoutSetting.ASI_CRM_Section_Content__c   = Information.get(1);
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            if(contractPrintoutSettingList.size() > 0) {
                insert contractPrintoutSettingList;
            }
            //***********************Finished Contract Print out Setting************************************************
            
            
            //Update Contract Cost Line
            List<ASI_CRM_Contract_Cost__c> UpdatedContractCostList = new List<ASI_CRM_Contract_Cost__c>();
            
            for(String ContractCostLine: ContractCostList){
                List<String> LineInformation = ContractCostLine.split('//');
                ASI_CRM_Contract_Cost__c ContractCost = new ASI_CRM_Contract_Cost__c();
                ContractCost.ASI_CRM_CN_Contract__c= contractId;
                ContractCost.Id= LineInformation.get(0);
                ContractCost.ASI_CRM_Contract_Terms__c= LineInformation.get(1);
                UpdatedContractCostList.add(ContractCost);
                
            }
            
            if(UpdatedContractCostList.size()>0){
                update UpdatedContractCostList;
            }
            
            
        } catch(Exception e) {
            Database.rollback(databaseSavepoint);
            throw e;
            Msg=e.getDmlMessage(0);
        }
        return Msg;
    }

    @RemoteAction
    global static String saveTemplate(String nextStep, String contractId,String InputAmountUpdatedListJson,
                                      String TextUpdatedListJson,String ModuleRefListJson , String ContractCostLinesJson){
        List<String> InputAmountUpdatedList= (List<String>) fromJsonString(InputAmountUpdatedListJson, List<String>.class);
        List<String> TextUpdatedList = (List<String>) fromJsonString(TextUpdatedListJson, List<String>.class);
        List<String> ModuleRefList = (List<String>) fromJsonString(ModuleRefListJson, List<String>.class);
        List<String> ContractCostList = (List<String>) fromJsonString(ContractCostLinesJson, List<String>.class);
        String Msg='OK';
        
        System.Savepoint databaseSavepoint = Database.setSavepoint();
        try {
            // *******************************Module *******************************
            Map<String,string> ReferenceMap = new Map<String,string>();
            
            for(String ModuleRecord : ModuleRefList) {
                List<String> ModuleInformation = ModuleRecord.split('//');
                if(ModuleInformation.size()>1){
                    if(ReferenceMap.containsKey(ModuleInformation.get(0))){
                        String TempReference= ReferenceMap.get(ModuleInformation.get(0))+'<br/>• '+ModuleInformation.get(1);
                        ReferenceMap.remove(ModuleInformation.get(0));
                        ReferenceMap.put(ModuleInformation.get(0), TempReference);
                    }else{
                        ReferenceMap.put(ModuleInformation.get(0), '• '+ModuleInformation.get(1));
                    }
                }
            }
            //Update Module
            List<ASI_CRM_Module__c> UpdatedModuleList = new List<ASI_CRM_Module__c>();
            for(string  ModuleKey:ReferenceMap.keySet()){
                UpdatedModuleList.add(New ASI_CRM_Module__c( Id=ModuleKey,ASI_CRM_Payment_Reference__c=ReferenceMap.get(ModuleKey)));
            }
            if(UpdatedModuleList.size()>0){
                update UpdatedModuleList;
            }
            
            //*********************Contract Print out List ********************* Delete existing saved template
            List<ASI_CRM_Contract_Printout_Setting__c> contractPrintoutList = [select id from ASI_CRM_Contract_Printout_Setting__c where ASI_CRM_Contract__c=: contractId];
            if(contractPrintoutList.size() > 0) {
                delete contractPrintoutList;
            }
            List<ASI_CRM_Contract_Printout_Setting__c> ContractPrintoutSettingList = new List<ASI_CRM_Contract_Printout_Setting__c>();
            
            for(String TextField : TextUpdatedList) {
                List<String> TextInformation = TextField.split('//');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
                tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'appendix';
                tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = TextInformation.get(0);
                tempContractPrintoutSetting.ASI_CRM_Section_Content__c   = TextInformation.get(1);
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            for(String AmountField : InputAmountUpdatedList) {
                List<String> Information = AmountField.split('//');
                ASI_CRM_Contract_Printout_Setting__c tempContractPrintoutSetting = new ASI_CRM_Contract_Printout_Setting__c();
                system.debug(Information.get(1) + ' 00000 : '+Information.get(0));
                tempContractPrintoutSetting.ASI_CRM_Contract__c             = contractId;
                tempContractPrintoutSetting.ASI_CRM_Header_Section_Name__c  = 'appendix';
                tempContractPrintoutSetting.ASI_CRM_Content_Section_Name__c = Information.get(0);
                tempContractPrintoutSetting.ASI_CRM_Section_Content__c   = Information.get(1);
                contractPrintoutSettingList.add(tempContractPrintoutSetting);
            }
            
            if(contractPrintoutSettingList.size() > 0) {
                insert contractPrintoutSettingList;
            }
            //***********************Finished Contract Print out Setting************************************************
            
            
            //Update Contract Cost Line
            List<ASI_CRM_Contract_Cost__c> UpdatedContractCostList = new List<ASI_CRM_Contract_Cost__c>();
            
            for(String ContractCostLine: ContractCostList){
                List<String> LineInformation = ContractCostLine.split('//');
                ASI_CRM_Contract_Cost__c ContractCost = new ASI_CRM_Contract_Cost__c();
                ContractCost.ASI_CRM_CN_Contract__c= contractId;
                ContractCost.Id= LineInformation.get(0);
                ContractCost.ASI_CRM_Contract_Terms__c= LineInformation.get(1);
                UpdatedContractCostList.add(ContractCost);
                
            }
            
            if(UpdatedContractCostList.size()>0){
                update UpdatedContractCostList;
            }
            
            
        } catch(Exception e) {
            Database.rollback(databaseSavepoint);
            throw e;
            Msg=e.getDmlMessage(0);
        }
        return Msg;
    }
    
    @RemoteAction
    global static List<sObject> findList(string obj,string statement, string qry)
    {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType sot = gd.get(obj);
        if (sot == null)
        {
            // Object name not valid
            return null;
        }//end if
        
        // create the filter text
        String filter = qry;
        
        //begin building the dynamic soql query
        String soql;
        if(filter != '' || filter != null)
            soql = 'select '+statement+' from ' + obj + filter +' order by Name';
        else
            soql = 'select '+statement+' from ' + obj +' order by Name';
        
        List<sObject> sobjs = new List<sObject>();
        
        List<String> results = new List<String>();
        
        System.debug('soql:' + soql);
        try{
            sobjs = Database.query(soql);
            return sobjs; 
        }//end try
        catch (QueryException e){ return null; }//end catch
        return sobjs;
    }    
    
    global static Object fromJsonString(String jsonString, System.Type apexType) {
        if(String.isBlank(jsonString)) {
            return null;
        }
        return System.JSON.deserialize(jsonString, apexType);
    }

    public class DataSummaryClass{
        public String clubVolumeBase = '';
        public String clubVolumeRemark = '';
        public Decimal clubAmountTotal = 0.00;
        public String storeVolumeBase = '';
        public String storeVolumeRemark = '';
        public Decimal storeAmountTotal = 0.00;
        public Decimal amountTotal = 0.00;
    }

    //Wrapper Class for storing all section
    public class SectionWrapper {
        public String name {get; set;}{name='';}
        public String style {get; set;}{style='';}
        public String content {get; set;}{content='';}
        public String content_original {get; set;}{content_original='';}
        public String LeftContent {get; set;}{LeftContent='';}
        public String RightContent {get; set;}{RightContent='';}
        public String displayNumber {get; set;}{displayNumber='';}
        public String ClassName {get; set;}{ClassName='';}
        public String type {get; set;}{type='';}
        public Map<integer, SectionWrapper> subSectionMap {get; set;}{subSectionMap= new Map<integer, SectionWrapper>();}
        public Boolean hasSubSection {get; set;} {hasSubSection=false;}
        public Boolean isShow {get; set;}
        
        public SectionWrapper(String name, String content, String style,String displayNumber, String ClassName, String type, Map<integer, SectionWrapper> subSectionMap) {
            this.name          = name;
            this.content       = content.trim();
            this.content_original = content.trim();
            this.style= style;
            this.displayNumber = displayNumber;
            this.ClassName = ClassName; 
            this.type          = type;
            this.subSectionMap = subSectionMap;
            
            if(subSectionMap == null || subSectionMap.size() == 0) {
                hasSubSection = false; 
            } else {
                hasSubSection = true;
            }
            
            isShow = true;
        }
    }
    
    public Class SectionType{
        public Integer CollumnNumber {set;get;} {CollumnNumber=0;}
        public String VolumeBase {set;get;}{VolumeBase='';}
        public Integer StyleStringCollumnNum {set;get;} {StyleStringCollumnNum=0;}
        public String StyleString {set;get;} {StyleString='';}
        
        public Integer ClassTypeCollumnNum {set;get;} {ClassTypeCollumnNum=0;}
        public String ClassType {set;get;} {ClassType='';}
        
        public Map<Integer,String> TableStyleMap {set;get;} {TableStyleMap= new Map<Integer,String>();}
        
        public SectionType(){}
    }
    
    
    public Class interimData{
        public String VolumeBase  {set;get;} {VolumeBase='';}
        public map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> DetailLineMap{set;get;}{DetailLineMap=new map<String, ASI_CRM_CN_Contract_BRSF_Line_Item__c> ();}
        public interimData(){}
    }
    
}