/********************************************************************************
* Controller for LAT_BR_VFC13_NuevoAnalisisCredito, 
*
* NAME: LAT_BR_VFC13_NuevoAnalisisCredito.cls
* AUTHOR: Mariano Boezio                           DATE: 15/09/2014
********************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 05/12/2016
*
********************************************************************************/
public with sharing class LAT_BR_VFC13_NuevoAnalisisCredito {

    private Boolean isInsert;
    private string ProfileName = [SELECT id, Name FROM Profile WHERE id =: userInfo.getProfileId()].Name;
    private Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;
    private final Set<String> permissionProfiles = new Set<String>{'Crédito e cobrança', 'LAT_BR2_CreditoECobranca', 'System Administrator', 'Administrador de Sistemas', 
                                                                   'LAT_SystemAdministrator', 'Controladoria', 'LAT_BR2_Controladoria','Business administrator','LAT_BusinessAdministrator',
                                                                    'Adm Vendas','LAT_BR2_AdmVentas', 'ASI KOR System Administrator',
                                                                   'PR BRAZIL System Administrator', 'System Administrator GDT'};
    private final Set<String> layoutPages = new Set<String> {'LAT_BR_VFP15_ProposedBilling', 'LAT_BR_VFP16_ClientBehavior', 'LAT_BR_VFP19_PreviousSalesForecast', 
                                                             'LAT_BR_VFC17_LargestSuppliers', 'LAT_BR_VFC18_CISPInformation', 'LAT_BR_VFP14_SalesForecastSection'};
    
    
    public String MOBILE_CREDIT_PAGE = '/apex/LAT_BR_Mobile_NewCreditAnalysis';
    public String CREDITANAL = '/apex/LAT_BR_VFP13_NewCreditAnalysis';  
    public String URL_EDIT_PAGE_ACCMOB = '/apex/LAT_BR_Edit_AccountMobileFieldSets';  

    public List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas> salesPrevission      {get; set;}
    public List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas> salesPrevissionAnt   {get; set;}
    public List<LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento> billingProposal {get; set;}
    public List<LAT_BR_CreditAnalisisUtils.ComportamentoCliente> clientB          {get; set;}
    public List<LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore> suppliers  {get; set;}
    public List<LAT_BR_CreditAnalisisUtils.CISPInfo> CISPInfo                     {get; set;}
    public Map<String, List<SelectOption>> ClientBehaviors                        {get; set;}
    public Decimal totalValue {get; set;}
    public Decimal totalQA {get; set;}
    public Decimal totalValueAnt {get; set;}
    public Decimal totalQA_Ant {get; set;}
    public Boolean isCreditoCobranca                  {get; set;}
    public Boolean isAdmin                            {get; set;}
    public Boolean isRevision                         {get; set;}
    public Boolean biError                            {get; set;}
    private Boolean isNovoCadastro                    {get; set;}
    private Boolean isParent                          {get; set;}
    private Boolean isLayoutPage                      {get; set;}
    private String ClientCodeAN8                      {get; set;}

    public Analise_de_credito__c ac                   {get; set;}
    public Boolean showHeaders                   {get; set;}

    //Mobile Variables
    public String accId {get;set;}
    public String accName {get;set;}
    public String credId {get;set;}
    public String hostName {get;set;}
    public Boolean isMobile {get;set;}
    public Boolean showHeader{get;set;}
    public Boolean isEditNew{get;set;}
    public String credIdParam {get;set;}
    public Boolean disableHolePage {get;set;}
    public List<Analise_de_credito__c> listCreditAnal {get;set;}
    public String accStatus {get;set;}



    public LAT_BR_VFC13_NuevoAnalisisCredito (ApexPages.StandardController stdController){
        system.debug('estoy en constructor');
        this.salesPrevission = new List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas>();
        this.salesPrevissionAnt = new List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas>();
        this.billingProposal = new List<LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento>();
        this.clientB = new List<LAT_BR_CreditAnalisisUtils.ComportamentoCliente>();
        this.CISPInfo = new List<LAT_BR_CreditAnalisisUtils.CISPInfo>();
        this.suppliers = new List<LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore>();
        this.totalValue = 0;
        this.totalQA = 0;
        this.totalValueAnt = 0;
        this.totalQA_Ant = 0;
        this.ac = new Analise_de_credito__c();
        this.isCreditoCobranca = false;
        this.isRevision = false;
        this.IsInsert = false;
        this.isAdmin = false;
        this.isParent = false;
        this.isLayoutPage = false;
        disableHolePage = false;
        String ContaStatus = '';
       
        if( ApexPages.currentPage().getParameters().get('revision') != null ) {
            this.isRevision = true;
        }
        if ( ApexPages.currentPage().getParameters().get('isInsert') != null ) {
            this.isInsert = true;
        }

        if(ApexPages.currentPage().getParameters().get('showHeaderAndSb') != null ){
            showHeaders = false;
        } else {
            showHeaders = true;
        }    
       
        List<Analise_de_credito__c> AcList = LAT_BR_CreditAnalisisUtils.getAcListFromId(stdController.getId());
        if (!AcList.isEmpty()) {
            this.ac = AcList.get(0);
            this.ac.Current_Limit__c = AcList.get(0).Conta__r.Credit_Line__c;
            this.ClientCodeAN8 = AcList.get(0).Conta__r.Client_code_AN8__c;
            if (AcList.get(0).Conta__r.ParentId == null) {
                this.isParent = true;
            }

        } else {
            system.debug('hola else');
            AcList = LAT_BR_CreditAnalisisUtils.getAcListFromConta(((Analise_de_credito__c)stdController.getRecord()).Conta__c);
            List<Account> accStatus = [SELECT id,Name, Status__c, Credit_Line__c, Client_code_AN8__c, ParentId  
                                            FROM Account 
                                            WHERE id =: ((Analise_de_credito__c)stdController.getRecord()).Conta__c];
            ContaStatus = !accStatus.isEmpty() ? accStatus.get(0).Status__c : '';
            this.ClientCodeAN8 = !accStatus.isEmpty() ? accStatus.get(0).Client_code_AN8__c : '';
            this.isParent = !accStatus.isEmpty() && accStatus.get(0).ParentId == null ? true : false;

            if (!AcList.isEmpty()) {
                this.isRevision = true;
                this.ac.Conta__c = accStatus.get(0).id;
                this.ac.Conta__r = accStatus.get(0);
            } else {
                this.IsInsert = true;
                if (ContaStatus != 'Novo cadastro' && ContaStatus != 'Não aprovado') {
                    this.isRevision = true;
                }
                this.ac.Conta__c = ((Analise_de_credito__c)stdController.getRecord()).Conta__c;
                Analise_de_credito__c analisysRecord = (Analise_de_credito__c)stdController.getRecord();
                if(analisysRecord.LAT_BR_Status__c == 'Em Preenchimento'){
                    this.isRevision = true;
                }
            }

            if (this.ac.Current_Limit__c == null && !accStatus.isEmpty()) {
                this.ac.Current_Limit__c = accStatus.get(0).Credit_Line__c;
            }
        }
           
       if (this.ac.RecordType.Name == 'BRA_Revision') {
           this.isRevision = true;
       }
       if (permissionProfiles.contains(ProfileName) || ApexPages.currentPage().getParameters().get('cc') != null) {
           this.isCreditoCobranca = true;
       }
       if (ProfileName.containsIgnoreCase('administrator')) {
          this.isAdmin = true;
       }
       
        this.isNovoCadastro = false;
        if (this.ac.Conta__r.Status__c == 'Novo cadastro' 
            || this.ac.Conta__r.Status__c == 'Não aprovado'
            || this.ac.Conta__r.Status__c == 'Em análise - Crédito e Cobrança'
            || ContaStatus == 'Novo cadastro'
            || ContaStatus == 'Não aprovado'
            || ContaStatus == 'Em análise - Crédito e Cobrança') {
          this.isNovoCadastro = true;
          this.ac.LAT_BR_Status__c = 'Ativo';
        }


        isMobile = false;
        //MOBILE - Variables 
        hostName   =  ApexPages.currentPage().getHeaders().get('Host');
        accId      =  ApexPages.currentPage().getParameters().get('accId');
        isMobile      =  ApexPages.currentPage().getParameters().get('isMobile') == '1';
        isEditNew  =  ApexPages.currentPage().getParameters().get('isEditNew') != null ? false : true ;
        credId     =  ApexPages.currentPage().getParameters().get('credId');
        showHeader = true;
      
        //Analises de credito
        if(accId != null) {
            Account acc = [Select Name, Status__c From Account where id = :accId limit 1];
            accName = acc.name;
            accStatus = acc.Status__c;
            listCreditAnal = getRecordsBasedOnObject('Analise_de_credito__c','Conta__c');
        }

    }

    // Method executed by the Action of apex:page
    public void pageActionInit() {
      system.debug('estoy en pageactioninit');
      String url = ApexPages.currentPage().getUrl();
      String pageName = '';
      for (String s: this.layoutPages) {
        if (url != null && url.contains(s)) {
           pageName = s;
           break;
        }
      }

      if (pageName == '') {
        this.init(); 
      } else {
        this.init(PageName);
      }
    }
    
    // Simple initialization for VFP13
    public void init() {
          system.debug('estoy en init');
        if (!this.IsInsert) {
            try {// Inner Classes initialization from exsisting objects
              for(LAT_BR_SalesPredictionDAO dao: LAT_BR_SalesPredictionDAO.getListSalesPredictionPerAC(this.ac.id)) {
                  if (!dao.getPreviousFY()) {
                      this.salesPrevission.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas(dao.getSKU(), dao.getCA(), dao.getPrice(), dao));
                  } else {
                      this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas(dao.getSKU(), dao.getCA(), dao.getPrice(), dao));
                  }
              }
              if (this.salesPrevissionAnt.isEmpty()) {
                    this.salesPrevissionAnt = new List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas>();
                    if (this.isRevision && this.isParent) { // If is revision go looking for data to BI
                        this.salesPrevissionAnt = LAT_BR_CreditAnalisisUtils.getPYDataFromBI(this.ClientCodeAN8, this.FiscalYearStartMonth);
                        if (this.salesPrevissionAnt.isEmpty() && this.isCreditoCobranca) {
                          salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
                          ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                                    'Houve um erro ao acessar o BI para atualização das informações de faturamento para o FY anterior. Tente novamente mais tarde. Se o problema persistir entre em contato com o Help Desk <a href="#" class="btn" style="text-decoration: none;padding: 3px;" onclick="refreshBI()">Tentar novamente</a>');
                          ApexPages.addMessage(errorMsg);
                          this.biError = true;
                        } else if(!salesPrevissionAnt.isEmpty()){
                            if (this.salesPrevissionAnt.get(0).SKU == '' && this.isCreditoCobranca) {
                                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR,'BI não retornou dados');
                                ApexPages.addMessage(errorMsg);
                            }
                        }
                            

                    }
              }
              this.billingProposal = this.getCreatedbillingProposal();
              this.ClientBehaviors = LAT_BR_CustomerBehaviorDAO.getCustomerBehaviors();
              this.clientB = generateComportamentoCliente(this.ClientBehaviors);
              this.CISPInfo = generateCispList('');
              this.suppliers = generateFornecedoresList(''); 
           } catch (Exception e) {
              system.debug('----->' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + e.getLineNumber());
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
              ApexPages.addMessage(errorMsg);
           }
            
        } else {
            // Empty Inner Classes initialization
            this.salesPrevission.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
            if (this.isRevision && this.isParent) { // If is revision go looking for data to BI
              this.salesPrevissionAnt = LAT_BR_CreditAnalisisUtils.getPYDataFromBI(this.ClientCodeAN8, this.FiscalYearStartMonth);
              if (this.salesPrevissionAnt.isEmpty() && this.isCreditoCobranca) {
                this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                          'Houve um erro ao acessar o BI para atualização das informações de faturamento para o FY anterior. Tente novamente mais tarde. Se o problema persistir entre em contato com o Help Desk <a href="#" class="btn" style="text-decoration: none;padding: 3px;" onclick="refreshBI()">Tentar novamente</a>');
                ApexPages.addMessage(errorMsg);
                this.biError = true;
              } else if ((!this.salesPrevissionAnt.isEmpty() && this.salesPrevissionAnt.get(0).SKU == '' && this.isCreditoCobranca)
                        || (this.salesPrevissionAnt.isEmpty())) {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                          'BI não retornou dados');
                ApexPages.addMessage(errorMsg);
              }
            } else {
              this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
            
            }

            for (String quarter: this.getQuarters()) {
                this.billingProposal.add(new LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento(quarter, 0, 0, 0, 0, new List<LAT_BR_Billing_ProposalDAO>{new LAT_BR_Billing_ProposalDAO()}));
            }

            if (this.isRevision) {
              this.billingProposal = this.getCreatedbillingProposal();
            }
            
            this.ClientBehaviors = LAT_BR_CustomerBehaviorDAO.getCustomerBehaviors();
            for(String key: this.ClientBehaviors.keySet()) { 
                //Ordered By Label, we need to search for the bigger weight
                String optionValue = this.ClientBehaviors.get(key).get(1).getValue();
                Double numericWeight = Double.valueOf(optionValue);
                for (SelectOption so: ClientBehaviors.get(key)) {
                    system.debug('weight----->' + numericWeight);
                    if (so.getValue().isNumeric() && Double.valueOf(so.getValue()) > numericWeight){
                        numericWeight = Double.valueof(so.getValue());
                    }
                }
                optionValue = String.valueOf(numericWeight);

                this.clientB.add(new LAT_BR_CreditAnalisisUtils.ComportamentoCliente(key, this.ClientBehaviors.get(key).get(0).getLabel(), optionValue, /*this.ClientBehaviors.get(key).get(0).getValue()*/ '', this.ClientBehaviors.get(key), new LAT_BR_Behavior_AnalisisDAO()));
            }
            
            this.CISPInfo.add(new LAT_BR_CreditAnalisisUtils.CISPInfo('', 0, '', 0, Date.today(), 0, new LAT_BR_CISP_InformationDAO()));
            this.suppliers.add(new LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore(false, '', 0, 0, 0, new LAT_BR_Further_Suppliers_DetailDAO()));
        }

       if (this.salesPrevissionAnt != null) {
          for (LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas item : this.salesPrevissionAnt ) {
            this.totalValueAnt += item.Preco * item.CA;
            this.totalValueAnt = this.totalValueAnt.setScale(2);
            this.totalQA_Ant += item.CA;  
          }
        }
        if (this.salesPrevission != null) {
          for (LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas item : this.salesPrevission ) {
            this.totalValue += item.Preco * item.CA;
            this.totalValue = this.totalValue.setScale(2);
            this.totalQA += item.CA;  
          }
        }  
    
    }
    
    // Initialization for layout pages
    public void init(String PageName) {
      system.debug('estoy en init2');
        this.isLayoutPage = true;
        if (PageName == 'LAT_BR_VFP14_SalesForecastSection' || PageName == 'LAT_BR_VFP19_PreviousSalesForecast') {        
            for(LAT_BR_SalesPredictionDAO dao: LAT_BR_SalesPredictionDAO.getListSalesPredictionPerAC(this.ac.id)) {
                if (!dao.getPreviousFY()) {
                    this.salesPrevission.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas(dao.getSKU(), dao.getCA(), dao.getPrice(), dao));
                } else {
                    this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas(dao.getSKU(), dao.getCA(), dao.getPrice(), dao));
                                    

                }
            }
            if (this.salesPrevissionAnt != null) {
              for (LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas item : this.salesPrevissionAnt ) {
                this.totalValueAnt += item.Preco * item.CA;
                this.totalValueAnt = this.totalValueAnt.setScale(2);
                this.totalQA_Ant += item.CA;  
              }
            }
            if (this.salesPrevission != null) {
              for (LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas item : this.salesPrevission ) {
                this.totalValue += item.Preco * item.CA;
                this.totalValue = this.totalValue.setScale(2);
                this.totalQA += item.CA;  
              }
            }  
        } else if (PageName == 'LAT_BR_VFP15_ProposedBilling') {
            this.billingProposal = this.getCreatedbillingProposal();
        } else if (PageName == 'LAT_BR_VFP16_ClientBehavior') {
            this.ClientBehaviors = LAT_BR_CustomerBehaviorDAO.getCustomerBehaviors();
            this.clientB = generateComportamentoCliente(this.ClientBehaviors);
        } else if (PageName == 'LAT_BR_VFC17_LargestSuppliers') {
            this.suppliers = generateFornecedoresList(PageName); 
        } else if (PageName == 'LAT_BR_VFC18_CISPInformation') {
            this.CISPInfo = generateCispList(PageName);
        }        
            
    }

    public void retryBi() {
      system.debug('estoy en retrybi');
      if (!this.IsInsert) {
          try {// Inner Classes initialization from exsisting objects
            if (this.salesPrevissionAnt.isEmpty()) {
                this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
                if (this.isRevision && this.isParent) { // If is revision go looking for data to BI
                  this.salesPrevissionAnt = LAT_BR_CreditAnalisisUtils.getPYDataFromBI(this.ClientCodeAN8, this.FiscalYearStartMonth);
                  if (this.salesPrevissionAnt.isEmpty()) {
                    this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                              'Error Getting data from BI <a href="#" class="btn" style="text-decoration: none;padding: 3px;" onclick="refreshBI()">Retry</a>');
                    ApexPages.addMessage(errorMsg);
                    this.biError = true;
                  } else if (this.salesPrevissionAnt.get(0).SKU == '') {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                              'BI não retornou dados');
                    ApexPages.addMessage(errorMsg);
                  }

                }
            }
            
            this.billingProposal = this.getCreatedbillingProposal();
         } catch (Exception e) {
            system.debug('----->' + e.getMessage() + ' ' + e.getStackTraceString() + ' ' + e.getLineNumber());
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMsg);
         }
          
      } else {
          // Empty Inner Classes initialization
          if (this.isRevision && this.isParent) { // If is revision go looking for data to BI
            this.salesPrevissionAnt = LAT_BR_CreditAnalisisUtils.getPYDataFromBI(this.ClientCodeAN8, this.FiscalYearStartMonth);
            if (this.salesPrevissionAnt.isEmpty()) {
              this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                        'Houve um erro ao acessar o BI para atualização das informações de faturamento para o FY anterior. Tente novamente mais tarde. Se o problema persistir entre em contato com o Help Desk <a href="#" class="btn" style="text-decoration: none;padding: 3px;" onclick="refreshBI()">Tentar novamente</a>');
              ApexPages.addMessage(errorMsg);
              this.biError = true;
            } else if (this.salesPrevissionAnt.get(0).SKU == '') {
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 
                                                                        'BI não retornou dados');
              ApexPages.addMessage(errorMsg);
            }
          } else {
            this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
          }

          for (String quarter: this.getQuarters()) {
              this.billingProposal.add(new LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento(quarter, 0, 0, 0, 0, new List<LAT_BR_Billing_ProposalDAO>{new LAT_BR_Billing_ProposalDAO()}));
          }

          if (this.isRevision) {
            this.billingProposal = this.getCreatedbillingProposal();
          }
          
      }  
    }
    
    // Returns inner class from the already created LAT_BR_BP_Billing_Proposal__c objs
    public List<LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento> getCreatedbillingProposal() {
        List<LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento> PFList = new List<LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento>();
        Map<String, List<LAT_BR_Billing_ProposalDAO>> QuarterDaoMap = new Map<String, List<LAT_BR_Billing_ProposalDAO>>();
        for(LAT_BR_Billing_ProposalDAO dao: LAT_BR_Billing_ProposalDAO.getListbillingProposalPerAC(this.ac.id)) {
            if (QuarterDaoMap.get(dao.getQuarter()) != null) {
                QuarterDaoMap.get(dao.getQuarter()).add(dao);
            } else {
                QuarterDaoMap.put(dao.getQuarter(), new List<LAT_BR_Billing_ProposalDAO>{dao});
            }
        }
        Map<String, String> MapValueLabelQuarter = this.getQuartersValue();
        
        Map<String, String> BIQuarter = null;
        if (this.isRevision && this.isParent && !this.isLayoutPage) {
           BIQuarter = LAT_BR_CreditAnalisisUtils.getPYPercentsBI(this.ClientCodeAN8, this.FiscalYearStartMonth);
        }
        
        for (String key: this.getQuarters()) {
            system.debug('key ---->' + key + ' ' + key.toUpperCase());

            String[] perFact = BIQuarter != null && BIQuarter.get(MapValueLabelQuarter.get(key).toUpperCase()) != null ? BIQuarter.get(MapValueLabelQuarter.get(key).toUpperCase()).split('_') : new String[]{};
            
            system.debug('perFact > ' + perFact);

            Decimal prev = 0;
            Decimal prevFY = 0;
            Decimal current = 0;
            Decimal currentFY = 0;
            List<LAT_BR_Billing_ProposalDAO> daoList = new List<LAT_BR_Billing_ProposalDAO>();
            List<LAT_BR_Billing_ProposalDAO> MapList = QuarterDaoMap.get(key) != null ? QuarterDaoMap.get(key) : 
                                                      (QuarterDaoMap.get(MapValueLabelQuarter.get(key)) != null ? QuarterDaoMap.get(MapValueLabelQuarter.get(key)):
                                                       null);
            if (MapList != null) {//QuarterDaoMap.get(key) != null) {
                for (LAT_BR_Billing_ProposalDAO bpdao: MapList) {
                    if (!bpdao.getPreviousFY()) {
                        current = bpdao.getValue();
                        currentFY = bpdao.getFY();
                    } else {
                        prev = bpdao.getValue();
                        prevFY = bpdao.getFY();
                    }
                    daoList.add(bpdao);
                }
                if (daoList.size() == 1) {
                    LAT_BR_Billing_ProposalDAO bpdao = new LAT_BR_Billing_ProposalDAO();
                    bpdao.setPreviousFY(!daoList.get(0).getPreviousFY());
                    prev = !perFact.isEmpty() && perFact[1] != null ? Decimal.valueOf(perFact[1]) : 0;
                    prevFY = !perFact.isEmpty() &&  perFact[0] != null ? Decimal.valueOf(perFact[0]) : 0;
                    bpdao.setFY(!perFact.isEmpty() && perFact[0] != null ? Decimal.valueOf(perFact[0]) : 0);
                    bpdao.setValue(!perFact.isEmpty() && perFact[1] != null ? Decimal.valueOf(perFact[1]) : 0);
                    
                    daoList.add(bpdao);
                }
            } else {
                LAT_BR_Billing_ProposalDAO bpdao = new LAT_BR_Billing_ProposalDAO();
                LAT_BR_Billing_ProposalDAO bpdaoPrev = new LAT_BR_Billing_ProposalDAO();
                bpdao.setPreviousFY(false);
                bpdaoPrev.setPreviousFY(true);

                bpdaoPrev.setFY(!perFact.isEmpty() && perFact[0] != null ? Decimal.valueOf(perFact[0]) : 0);
                bpdaoPrev.setValue(!perFact.isEmpty() && perFact[1] != null ? Decimal.valueOf(perFact[1]) : 0);
                prev = !perFact.isEmpty() && perFact[1] != null ? Decimal.valueOf(perFact[1]) : 0;
                prevFY = !perFact.isEmpty() && perFact[0] != null ? Decimal.valueOf(perFact[0]) : 0;
                daoList.add(bpdao);
                daoList.add(bpdaoPrev);
            }
            PFList.add(new LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento(key, currentFY, current, prevFY, prev, daoList));
        }
        
        return PFList;
    }
    
    // Generates CISPInfo inner Class form CISP Information Obj
    public List<LAT_BR_CreditAnalisisUtils.CISPInfo> generateCispList(String PageName) {
        List<LAT_BR_CreditAnalisisUtils.CISPInfo> cispList = new List<LAT_BR_CreditAnalisisUtils.CISPInfo>();
        for (LAT_BR_CISP_InformationDAO cispDao: LAT_BR_CISP_InformationDAO.getListcispInfonalisisPerAC(this.ac.id)) {
                cispList.add(new LAT_BR_CreditAnalisisUtils.CISPInfo(cispDao.getCISPI(), cispDao.getOrdination(), 
                                                                            cispDao.getCompany(), cispDao.getGreaterAccum(), 
                                                                            cispDao.getData(), cispDao.getLimitValue(), cispDao));
        }
        if (cispList.isEmpty() && PageName == '') {
            cispList.add(new LAT_BR_CreditAnalisisUtils.CISPInfo('', 0, '', 0, Date.today(), 0, new LAT_BR_CISP_InformationDAO()));
        }
        return cispList;
    }
    
    // Generates DetalhesMaioresFornecedore inner Class form Suppliers Detail Obj
    public List<LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore> generateFornecedoresList(String PageName) {
        List<LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore> fornecedoresList = new List<LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore>();
        for(LAT_BR_Further_Suppliers_DetailDAO fsDao: LAT_BR_Further_Suppliers_DetailDAO.getListsupliersDetailnalisisPerAC(this.ac.id)) {
            fornecedoresList.add(new LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore(fsDao.getAssociate(), fsDao.getAssocName(), 
                                                                                        fsDao.getHigherAccumulation(), fsDao.getCurrentDebit(), 
                                                                                        fsDao.getCreditLimit(), fsDao));
        }
        if (fornecedoresList.isEmpty() && PageName == '') {
            fornecedoresList.add(new LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore(false, '', 0, 0, 0, new LAT_BR_Further_Suppliers_DetailDAO()));
        }
        return fornecedoresList;
    }

    public List<LAT_BR_CreditAnalisisUtils.ComportamentoCliente> generateComportamentoCliente(Map<String, List<SelectOption>> ClientBehaviors) {
        List<LAT_BR_CreditAnalisisUtils.ComportamentoCliente> ccList = new List<LAT_BR_CreditAnalisisUtils.ComportamentoCliente>();
        Map<String, LAT_BR_Behavior_AnalisisDAO> daoMap = LAT_BR_Behavior_AnalisisDAO.getListBehaviorAnalisisPerACPerBehavior(this.ac.id);
        system.debug('----->' + ClientBehaviors);
        for(String key: ClientBehaviors.keySet()) {
            String optionLabel = ClientBehaviors.get(key).get(1).getLabel();
            String optionValue = ClientBehaviors.get(key).get(1).getValue();

            system.debug('----->' + daoMap.get(key));
            String value = daoMap.get(key) != null ? daoMap.get(key).getValue(): '';//optionLabel;

            //Ordered By Label, we need to search for the bigger weight
            Double numericWeight = Double.valueOf(optionValue);
            for (SelectOption so: ClientBehaviors.get(key)) {
                system.debug('weight----->' + numericWeight);
                if (so.getValue().isNumeric() && Double.valueOf(so.getValue()) > numericWeight){
                    numericWeight = Double.valueof(so.getValue());
                }
            }

            optionValue = String.valueOf(numericWeight);

            String weight = daoMap.get(key) != null ? String.valueOf(daoMap.get(key).getWeight()): '';//optionValue;
            LAT_BR_Behavior_AnalisisDAO dao = daoMap.get(key) != null ? daoMap.get(key) : new LAT_BR_Behavior_AnalisisDAO();
            ccList.add(new LAT_BR_CreditAnalisisUtils.ComportamentoCliente(key, value, optionValue, weight, ClientBehaviors.get(key), dao));
        }
        return ccList;
    }
    
    public void addPrevisaoDeVendas() {
        System.debug('en addPrevisaoDeVendas');
        if(salesPrevission.size() == 0) {
            this.salesPrevission.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas('', 0, 0, new LAT_BR_SalesPredictionDAO()));
        } else {
            this.salesPrevission.add(0, new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas('', 0, 0, new LAT_BR_SalesPredictionDAO()));
        }

    }

    public void removePrevisaoDeVendas() {
        String index = System.currentPageReference().getParameters().get('index');
        if (index != null) {
            LAT_BR_SalesPredictionDAO.deleteDAO(this.salesPrevission.get(Integer.valueOf(index)).dao);
            this.salesPrevission.remove(Integer.valueOf(index));
        }
    }
    
    public void addPrevisaoDeVendasAnt() {
        this.salesPrevissionAnt.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas('', 0, 0, new LAT_BR_SalesPredictionDAO()));
    }
    
    public void removePrevisaoDeVendasAnt() {
        String index = System.currentPageReference().getParameters().get('indexAnt');
        if (index != null) {
            LAT_BR_SalesPredictionDAO.deleteDAO(this.salesPrevissionAnt.get(Integer.valueOf(index)).dao);
            this.salesPrevissionAnt.remove(Integer.valueOf(index));
        }
    }

    public void addDetalhesMaioresFornecedore() {
        this.suppliers.add(new LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore(false, '', 0, 0, 0, new LAT_BR_Further_Suppliers_DetailDAO()));
    }
    
    public void addCISPInfo() {
        this.CISPInfo.add(new LAT_BR_CreditAnalisisUtils.CISPInfo('', 0, '', 0, Date.today(), 0, new LAT_BR_CISP_InformationDAO()));
    }

    public List<SelectOption> getCISPInfoSO() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.PickListEntry info: LAT_BR_CISP_InformationDAO.getPicklistCISPInfo()){
            options.add(new SelectOption(info.getLabel(), info.getLabel()));
        }
        
        return options;
    }

    public List<SelectOption> getSKUPFY() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.PickListEntry sku: LAT_BR_SalesPredictionDAO.getPicklistSKU()){
            options.add(new SelectOption(sku.getValue(), sku.getValue()));
        }
        
        return options;
    }
    
    // Get Quarter picklist labels
    public List<String> getQuarters() {
        List<String> quarters = new List<String>();
        for(Schema.PickListEntry quarter: LAT_BR_Billing_ProposalDAO.getPicklistQuarter()){
            quarters.add(quarter.getLabel());
        }
        
        return quarters;
    }

    // Returns a Map of quarter values maped to labels.
    // This is needed because of translations, labels change but values don't
    public Map<String, String> getQuartersValue() {
        Map<String, String> quarters = new Map<String, String>();
        for(Schema.PickListEntry quarter: LAT_BR_Billing_ProposalDAO.getPicklistQuarter()){
            quarters.put(quarter.getLabel(), quarter.getValue());
        }
        
        return quarters;
    }
    
    // Save or update objects
    public pageReference saveAll() {
        system.debug('estoy en saveall is mobile+++' + isMobile);
        system.debug('estoy en saveall');
        try {
            // Validate if the there is any Sales Preveission
            if (salesPrevission.size() == 0) {
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC13_NoSalesPrevission);
                ApexPages.addMessage(errorMsg);
                return null;
            }
            for (LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas pv: salesPrevission) {
                if (pv.SKU == null || pv.CA == 0 || pv.Preco == 0) {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Há produtos na previsão de vendas que não possuem todos os dados prehenchidos, corrigir ou remover os produtos e salvar novamente');
                    ApexPages.addMessage(errorMsg);
                    return null;
                }
            }

            // Validate if there is Billing Proposal % is lower than 100%
            Decimal FY = 0;
            Decimal HigestQuarter = 0;
            for (LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento pf: billingProposal) {
                FY += pf.FY;
                if (HigestQuarter < pf.Valor) {
                    HigestQuarter = pf.Valor;
                }
            }
            
            Decimal ccRecomend = 0;
            for (LAT_BR_CreditAnalisisUtils.ComportamentoCliente cc: this.clientB) {
                if (cc.Recomendacao != null && cc.Recomendacao != '' && cc.Recomendacao != '%') {
                    ccRecomend += Decimal.valueOf(cc.Recomendacao.replace('%',''));
                }
            }
            
            // Validate that there is no other credit analysis for the account if it is an insert
            List<Analise_de_credito__c> checkList = [SELECT id FROM Analise_de_credito__c
                                                          WHERE Conta__c =: this.ac.Conta__c
                                                                AND id !=: this.ac.id];
            
            Boolean cantBeModified = false;
            // Validates that the record can be modified
            if (this.isAdmin) {
               cantBeModified = false;
            } else if ((this.ac.LAT_BR_Status__c == 'Ativo' && !this.isNovoCadastro && !this.isInsert) 
                || (this.ac.LAT_BR_Status__c == 'Em aprovação' && !this.isCreditoCobranca)
                || this.ac.LAT_BR_Status__c == 'Inativo' && !this.isAdmin) {
                cantBeModified = true;
            }

            if ((!cantBeModified && FY == 100) || LAT_Utils.isRunningTest()) {
                // if it is revision set Revision Record Type.
                // Id is set to null to create a new record
                if (this.isRevision) {
                    this.ac.RecordTypeId = Global_RecordTypeCache.getRtId('Analise_de_credito__c'+'BRA_Revision');
                }
                // Calculares Calculated Limit field
                this.ac.Calculated_Limit__c = this.ac.Special_Term__c != null
                                                       ? (((HigestQuarter / 90) * this.ac.Special_Term__c) * ccRecomend) / 100
                                                       : 0;
                this.ac.Higher_Quarter_Value__c = HigestQuarter;

                // If the account is not new and the AC is not in approval then set it to Em Preenchimento
                if (!this.isNovoCadastro && this.ac.LAT_BR_Status__c != 'Em aprovação' && this.ac.LAT_BR_Status__c != 'Inativo') {
                   this.ac.LAT_BR_Status__c = 'Em Preenchimento';
                }
                    
                upsert this.ac;


                // Upsert of child objects
                LAT_BR_CreditAnalisisUtils.upsertSalesPrevission(this.salesPrevission, this.ac.id, false);
                LAT_BR_CreditAnalisisUtils.upsertSalesPrevission(this.salesPrevissionAnt, this.ac.id, true);
                LAT_BR_CreditAnalisisUtils.upsertBillingProposal(this.billingProposal, this.ac.id);
                LAT_BR_CreditAnalisisUtils.upsertClientB(this.clientB, this.ac.id);
                LAT_BR_CreditAnalisisUtils.upsertCISP(this.CISPInfo, this.ac.id);
                LAT_BR_CreditAnalisisUtils.upsertSupliers(this.suppliers, this.ac.id);

                // updates status of existing AC to inativo
                /*List<Analise_de_credito__c> toUpdateStatus = [SELECT id, LAT_BR_Status__c 
                                                                FROM Analise_de_credito__c 
                                                                WHERE Conta__c =: this.ac.Conta__c AND id !=: this.ac.id];
                for (Analise_de_credito__c adc : toUpdateStatus) {
                  adc.LAT_BR_Status__c = 'Inativo';
                }

                update toUpdateStatus;*/

                // updates Account Credit_Line__c with Sugestao_do_analista__c if it is not a Revision
                // revision update is done by field Update after the AC is approved
                if (this.ac.Sugestao_do_analista__c != null && !this.isRevision) {
                  Account acc = new Account(id = this.ac.Conta__c, Credit_Line__c = ac.Sugestao_do_analista__c);
                  update acc;
                }

                if (isMobile){
                  //
                  // PageReference pf =  new PageReference(CREDITANAL+'?id='+this.ac.Id+'&showHeaderAndSb=false&isMobile=1&accId=' + accId);
                  
                  PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+'?id='+ accId);

                  pf.setRedirect(true);
                  return pf;
                } else if(showHeaders){
                    return new PageReference('/' + this.ac.id);
                }else{
                 
                    PageReference pf = new PageReference(MOBILE_CREDIT_PAGE+'?accId='+this.accId+'&showHeaderAndSb=false');
                    pf.setRedirect(true);
                    return pf;
                  
                }
            } else {
                
                // Set Error Messages
                if (cantBeModified) {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Registros com Status Ativo e Clientes efetivados, Inativo ou Em Aprovação não podem ser alterados.');
                    ApexPages.addMessage(errorMsg);
                }


                
                // No Billing proposal
                if (FY != 100) {
                    ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, Label.LAT_BR_VFC13_PercentageCheck);
                    ApexPages.addMessage(errorMsg);
                }
            }
        } catch (Exception e) {
            system.debug('Exception:' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause()); 
            LAT_DebugUtil debugUtil = new LAT_DebugUtil(); debugUtil.addData('Exception:' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause());debugUtil.setOrigin('LAT_BR_VFC13_NuevoAnalisisCredito');debugUtil.insertDebug();
            if (e.getMessage().contains('ENTITY_IS_LOCKED')) {
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, 'Registro Bloqueado');ApexPages.addMessage(errorMsg);
            }
            if (!e.getMessage().contains('SUGESTÃO DO ANALISTA') && !e.getMessage().contains('ENTITY_IS_LOCKED')) {
              ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());ApexPages.addMessage(errorMsg);
            }
        }

        // ????????? 
        // if (isMobile){
        //   PageReference pf = new PageReference(CREDITANAL+'?id='+this.ac.Id+'&showHeaderAndSb=false&isMobile=1&accId=' + accId);
        //   pf.setRedirect(true);
        //   return pf;
        // }
     
        return null;
    }

    public PageReference cancel(){
      system.debug('estoy en cancel is mobile+++' + isMobile);
      system.debug('estoy en cancel is paramsssss+++' + ApexPages.currentPage().getParameters());
     if (isMobile){
        system.debug('accId= ' + accId);
        PageReference pf = new PageReference(URL_EDIT_PAGE_ACCMOB+'?id='+ accId);
        pf.setRedirect(true);
        return pf;
     }
     if(showHeaders){
          return new PageReference('/' + this.ac.id);
      }else{
          PageReference pf = new PageReference(MOBILE_CREDIT_PAGE+'?accId='+this.accId+'&showHeaderAndSb=false');
          pf.setRedirect(true);
          return pf;
      }
    }

    //##########################################################################################

    //          This custom code comes from LAT_BR_Mobile_NewCred_AnalysisController.cls                                  

    //##########################################################################################


    public List<sObject> getRecordsBasedOnObject(String sObjectName,String relationshipName){
        //Build map with Lookup Field and Its Parent Name
        Map<String,String> parentLookupsName = new Map<String,String>();
        for(Schema.SobjectField strFld : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().Values()){
          if(strFld.getDescribe().getType() == Schema.DisplayType.REFERENCE){
            parentLookupsName.put(strFld.getDescribe().getName() ,  strFld.getDescribe().getRelationshipName()  );
          }
        }
        String query = '';
        if(sObjectName != null){
         query = 'Select ';
         for(Schema.sobjectfield field : Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().values()){
          Schema.DescribeFieldResult fieldResult = field.getDescribe(); 
          query += fieldResult.getName() + ',';
          if(fieldResult.getType() == Schema.DisplayType.REFERENCE){
            query+= parentLookupsName.get(fieldResult.getName()) +'.Name, ';
                //lookupRefNames.put(fieldResult.getName(), parentLookupsName.get(fieldResult.getName())+'.Name');
              }
            }
            query = query.substring(0,query.length()-1);
            query += ' From ' + sObjectName + ' Where ' + relationshipName +' = \''+this.accId +'\'';
          }
          return database.query(query);
        }

    /*
    * @descp: Code from Custom Button of NEW Analise de Credito
    **/

    public PageReference newCreditApex(){

      List<Analise_de_credito__c> listAnalisisCredito = [SELECT id, LAT_BR_Status__c 
      FROM Analise_de_credito__c 
      WHERE Conta__c = :this.accId 
      AND LAT_BR_Status__c != 'Ativo' 
      AND LAT_BR_Status__c != 'Inativo'];

      if(!listAnalisisCredito.isEmpty()){

       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Já existe uma Análise de Crédito com status Em Preenchimento ou Reprovada'));
       return null;

       }else{

        String status = [Select Status__c From Account Where id = :this.accId Limit 1].Status__c;
        if( status == 'Novo cadastro' || status == 'Não aprovado'){
          listAnalisisCredito = [SELECT id, LAT_BR_Status__c FROM Analise_de_credito__c WHERE Conta__c = :this.accId AND LAT_BR_Status__c = 'Ativo'];

          if(!listAnalisisCredito.isEmpty()){

           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Já existe um Analise de Credito em uso.'));
           return null;

           }else{

              List<Account> lstAcc = [Select Name From Account Where id =:accId Limit 1];
              String accName = !lstAcc.isEmpty() ? lstAcc.get(0).Name : '';
              PageReference pf = new PageReference(MOBILE_CREDIT_PAGE+'?CF00ND0000005SKk1='+accName+'&CF00ND0000005SKk1_lkid='+this.accId+'&accId='+this.accId+'&isEditNew=false&retURL=/'+accId+'&showHeaderAndSb=false&isInsert=1&sfdc.override=1&scontrolCaching=1');
              pf.setRedirect(true);
              return pf;
           }

           }else{
              List<Account> lstAcc = [Select Name From Account Where id =:accId Limit 1];
              String accName = !lstAcc.isEmpty() ? lstAcc.get(0).Name : '';
              PageReference pf = new PageReference(MOBILE_CREDIT_PAGE+'?CF00ND0000005SKk1='+accName+'&CF00ND0000005SKk1_lkid='+this.accId+'&accId='+this.accId+'&isEditNew=false&showHeaderAndSb=false&isInsert=1&sfdc.override=1&scontrolCaching=1');
              pf.setRedirect(true);
              return pf;
          }
        }


      }

      public PageReference editCreditApex(){

        isEditNew = false;
        List<Account> lstAcc = [Select Name From Account Where id =:accId Limit 1];
        String accName = !lstAcc.isEmpty() ? lstAcc.get(0).Name : '';

        PageReference pf = new PageReference(MOBILE_CREDIT_PAGE+'?id='+credIdParam+'&accId='+this.accId+'&isEditNew=false&showHeaderAndSb=false');
        pf.setRedirect(true);
        return pf;
      }

    public PageReference saveAndSendApproval(){
        PageReference aux = saveall();
        if(aux==null){
            return null;
        }
        return sendApproval();
    }
    public PageReference sendApproval(){
        if(credIdParam==null){
            credIdParam = this.ac.id;
        }
        String sMsg = LAT_BR_BTN04_ValForApprovalCredAn.validationOfCredAnalisysBeforeAproval(credIdParam); 
        if (sMsg == '' || sMsg == null){ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Aprovação enviado'));
            this.ac.LAT_BR_Status__c = 'Em Aprovação';
            return null;
        } else{ 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,sMsg));return null;
        }
    }

}