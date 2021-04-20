/********************************************************************************
* Inner Classes and helper methods for Credit Analisis BR
*
* NAME: LAT_BR_CreditAnalisisUtils.cls
* AUTHOR: Mariano Boezio                          
********************************************************************************/
public with sharing class LAT_BR_CreditAnalisisUtils {

    //Inner class for Sales Prevission section
    public class PrevisaoDeVendas {
        public LAT_BR_SalesPredictionDAO dao {get; set;}
        public string SKU                 {get;Set;}
        public Decimal CA                 {get;Set;}
        public Decimal Preco              {get;Set;}
        
        public PrevisaoDeVendas (string SKU, Decimal CA, Decimal Preco, LAT_BR_SalesPredictionDAO dao){
            this.SKU = SKU;
            this.CA = CA;
            this.Preco = Preco;
            this.dao = dao;
        }
    }
    
    //Inner class for billling proposal section
    public class PropostaDeFaturamento{
        public string Trimestre {get;Set;}
        public Decimal FY        {get;Set;}
        public Decimal FYAnt     {get;Set;}
        public Decimal Valor     {get;Set;}
        public Decimal ValorAnt {get;Set;}
        public List<LAT_BR_Billing_ProposalDAO> dao {get; set;}
        
        public PropostaDeFaturamento(string Trimestre, Decimal FY, Decimal Valor, Decimal FYAnt, Decimal ValorAnt, List<LAT_BR_Billing_ProposalDAO> dao){
            this.Trimestre = Trimestre;
            this.FY = FY;
            this.Valor = Valor;
            this.FYAnt = FYAnt;
            this.ValorAnt = ValorAnt;
            this.dao = dao;
        }
    }
    
    //Inner Class for Client Behavior section
    public class ComportamentoCliente{
        public string comportamentC {get;Set;}
        public string CCValor         {get;Set;}
        public string Pesos         {get;Set;}
        public string Recomendacao  {get;Set;}
        public List<SelectOption> sOption {get; set;}
        public LAT_BR_Behavior_AnalisisDAO dao {get; set;}
        
        public ComportamentoCliente(string comportamentC, string CCValor, string Pesos, 
                                    string Recomendacao, List<SelectOption> sOption,
                                    LAT_BR_Behavior_AnalisisDAO dao){
            this.comportamentC = comportamentC;
            this.CCValor = CCValor;
            this.Pesos = Pesos;
            this.Recomendacao = Recomendacao;
            this.sOption = sOption;
            this.dao = dao;
        }
    }
    
    //Inner Class for supplier details section
    public class DetalhesMaioresFornecedore{
        public Boolean Associado     {get;Set;}
        public string NomeAssociado  {get;Set;}
        public Decimal MaiorAcumulo  {get;Set;}
        public Decimal DebitoAtual   {get;Set;}
        public Decimal LimiteCredito {get;Set;}
        public LAT_BR_Further_Suppliers_DetailDAO dao {get;Set;}
        
        public DetalhesMaioresFornecedore(Boolean Associado, string NomeAssociado, Decimal MaiorAcumulo, 
                                            Decimal DebitoAtual, Decimal LimiteCredito, LAT_BR_Further_Suppliers_DetailDAO dao){
            this.Associado = Associado;
            this.NomeAssociado = NomeAssociado;
            this.MaiorAcumulo = MaiorAcumulo;
            this.DebitoAtual = DebitoAtual;
            this.LimiteCredito = LimiteCredito;
            this.dao = dao;
        }
    }
    
    //Inner class for CISPInformation section
    public class CISPInfo{
        public String InfoCISP       {get;Set;}
        public Decimal Ordenacao     {get;Set;}
        public string Empresa        {get;Set;}
        public Decimal MaiorAcum     {get;Set;}
        public Date Data             {get;Set;}
        public Decimal Limite        {get;Set;}
        public LAT_BR_CISP_InformationDAO dao {get; set;}
        
        public CISPInfo(String InfoCISP, Decimal Ordenacao, string Empresa, Decimal MaiorAcum, 
                            Date Data, Decimal Limite, LAT_BR_CISP_InformationDAO dao){
            this.InfoCISP = InfoCISP;
            this.Ordenacao = Ordenacao;
            this.Empresa = Empresa;
            this.MaiorAcum = MaiorAcum;
            this.Data = Data;
            this.Limite = Limite;
            this.dao = dao;
        }
    }
    
    public static void upsertSupliers(List<LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore> suppliers, string acId) {
        List<LAT_BR_Further_Suppliers_DetailDAO > fsdDaoList = new List<LAT_BR_Further_Suppliers_DetailDAO >();
        for (LAT_BR_CreditAnalisisUtils.DetalhesMaioresFornecedore dmf: suppliers) {
            if (dmf.NomeAssociado != '') {
                LAT_BR_Further_Suppliers_DetailDAO dao = dmf.dao;
                if (dao.getCreditAnalysis() == null)
                    dao.setCreditAnalysis(acId);
                dao.setAssociate(dmf.Associado);
                dao.setAssocName(dmf.NomeAssociado);
                dao.setCreditLimit(dmf.LimiteCredito);
                dao.setCurrentDebit(dmf.DebitoAtual);
                dao.setHigherAccumulation(dmf.MaiorAcumulo);
                fsdDaoList.add(dao);
            }
        }
        LAT_BR_Further_Suppliers_DetailDAO.upsertList(fsdDaoList);
    }
    
    public static void upsertCISP(List<LAT_BR_CreditAnalisisUtils.CISPInfo> CISPInfo, string acId) {
        List<LAT_BR_CISP_InformationDAO> cispDaoList = new List<LAT_BR_CISP_InformationDAO >();
        for (LAT_BR_CreditAnalisisUtils.CISPInfo cisp: CISPInfo) {
            if (cisp.Empresa != '') {
                LAT_BR_CISP_InformationDAO dao = cisp.dao;
                if (dao.getCreditAnalysis() == null)
                    dao.setCreditAnalysis(acId);
                dao.setCompany(cisp.Empresa);
                dao.setCISPI(cisp.InfoCISP);
                dao.setData(cisp.Data);
                dao.setGreaterAccum(cisp.MaiorAcum);
                dao.setLimitValue(cisp.Limite);
                dao.setOrdination(cisp.Ordenacao);
                cispDaoList.add(dao);
            }
        }
        LAT_BR_CISP_InformationDAO.upsertList(cispDaoList);
    }
    
    public static void upsertClientB(List<LAT_BR_CreditAnalisisUtils.ComportamentoCliente > clientB, string acId) {
        List<LAT_BR_Behavior_AnalisisDAO> badaoList = new List<LAT_BR_Behavior_AnalisisDAO>();
        for (LAT_BR_CreditAnalisisUtils.ComportamentoCliente cc: clientB) {
            if (cc.Recomendacao != null && cc.Recomendacao != '') {
                LAT_BR_Behavior_AnalisisDAO dao = cc.dao;
                if (dao.getCreditAnalysis() == null)
                    dao.setCreditAnalysis(acId);
                dao.setCustomerBehavior(cc.comportamentC);
                dao.setValue(cc.CCValor);
                dao.setWeight(Decimal.valueOf(cc.Recomendacao.replace('%','')));
                badaoList.add(dao);
            }
        }
        LAT_BR_Behavior_AnalisisDAO.upsertList(badaoList);
    }
    
    public static Map<String, String> getQuartersValue() {
        Map<String, String> quarters = new Map<String, String>();
        for(Schema.PickListEntry quarter: LAT_BR_Billing_ProposalDAO.getPicklistQuarter()){
            quarters.put(quarter.getLabel(), quarter.getValue());
        }
        
        return quarters;
    }

    public static void upsertBillingProposal(List<LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento> billingProposal, string acId) {
        List<LAT_BR_Billing_ProposalDAO> bpDaoList = new List<LAT_BR_Billing_ProposalDAO>();
        Map<String, String> valuesMap = getQuartersValue();
        for (LAT_BR_CreditAnalisisUtils.PropostaDeFaturamento pf: billingProposal) {
            for (LAT_BR_Billing_ProposalDAO dao : pf.dao) {
                if (dao.getCreditAnalysis() == null) {
                    dao.setCreditAnalysis(acId);
                }
                dao.setQuarter(valuesMap.get(pf.Trimestre));
                if (!dao.getPreviousFY()) {
                    dao.setValue(pf.Valor);
                    dao.setFY(pf.FY);
                } else {
                    dao.setValue(pf.ValorAnt);
                    dao.setFY(pf.FYAnt);
                }
                bpDaoList.add(dao);
            }
        }
        LAT_BR_Billing_ProposalDAO.upsertList(bpDaoList);
    }
    
    public static void upsertSalesPrevission(List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas> salesPrevission, string acId, Boolean IsPrevious) {
        List<LAT_BR_SalesPredictionDAO> daoList = new List<LAT_BR_SalesPredictionDAO>();
        for (LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas pv: salesPrevission) {
            if (pv.SKU != null && pv.CA != 0 && pv.Preco != 0) {
                LAT_BR_SalesPredictionDAO dao = pv.dao;
                if (dao.getCreditAnalisis() == null)
                    dao.setCreditAnalisis(acId);
                dao.setPreviousFY(IsPrevious);
                dao.setCA(pv.CA);
                dao.setSKU(pv.SKU);
                dao.setPrice(pv.Preco);
                daoList.add(dao);
            }
        }
        LAT_BR_SalesPredictionDAO.upsertList(daoList);
    }
    
    public static List<Analise_de_credito__c> getAcListFromId (String acId){
        return [SELECT id, Conta__c, Ramo_de_atuacao_Macrosegmento__c, Patrimonio_liquido__c,
                        N_Funcionarios__c, Atividade_principal__c, N_de_funcionarios_incluindo_filiais__c,
                        Predio_instala_es__c, Valor_mensal_folha_de_pagamento__c, Valor_mensal_aluguel__c,
                        Metros_quadrados__c, Empresas_coligadas__c, Ano__c, Janeiro__c, Fevereiro__c, Marco__c,
                        Abril__c, Maio__c, Junho__c, Julho__c, Agosto__c, Setembro__c, Outubro__c, Novembro__c,
                        Dezembro__c, Valor_atual_de_estoques__c, Observacoes__c, Comentarios_Consideracoes_finais__c,
                        Special_term__c, Coface_Limit__c, Prazo_normal_de_pagamento__c, Capital_social__c,
                        Current_Limit__c, Greater_Exposure__c, Greater_Exposure_month__c, Sugestao_do_analista__c,
                        RecordTypeId, RecordType.name, Conta__r.Client_code_AN8__c, Conta__r.Status__c, LAT_BR_Status__c,
                        Conta__r.Credit_Line__c, RecordType.DeveloperName, Conta__r.ParentId
                    FROM Analise_de_credito__c
                    WHERE id =: acId];
       
    }
    
    public static List<Analise_de_credito__c> getAcListFromConta (String contaId){
        return [SELECT id, Conta__c, Ramo_de_atuacao_Macrosegmento__c, Patrimonio_liquido__c,
                        N_Funcionarios__c, Atividade_principal__c, N_de_funcionarios_incluindo_filiais__c,
                        Predio_instala_es__c, Valor_mensal_folha_de_pagamento__c, Valor_mensal_aluguel__c,
                        Metros_quadrados__c, Empresas_coligadas__c, Ano__c, Janeiro__c, Fevereiro__c, Marco__c,
                        Abril__c, Maio__c, Junho__c, Julho__c, Agosto__c, Setembro__c, Outubro__c, Novembro__c,
                        Dezembro__c, Valor_atual_de_estoques__c, Observacoes__c, Comentarios_Consideracoes_finais__c,
                        Special_term__c, Coface_Limit__c, Prazo_normal_de_pagamento__c, Capital_social__c,
                        Current_Limit__c, Greater_Exposure__c, Greater_Exposure_month__c, Sugestao_do_analista__c,
                        RecordTypeId, RecordType.name, Conta__r.Client_code_AN8__c, Conta__r.Status__c, LAT_BR_Status__c,
                        Conta__r.Credit_Line__c, RecordType.DeveloperName, Conta__r.ParentId
                    FROM Analise_de_credito__c
                    WHERE Conta__c =: contaId];
       
    }

    // Returns Previous Fiscal Year
    public static String getPreviousFiscalYear(Integer fiscalMonth) {
        Integer currentMonth = Date.today().month();

        if (fiscalMonth >= currentMonth) {
            return String.valueOf(Date.today().addyears(-1).year());
        } else {
            return String.valueOf(Date.today().year());    
        }
    }

    // Calls BI WS to get PY Data
    public static List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas> getPYDataFromBI(String customerAN8, Integer fiscalMonth) {
        Boolean error = false;
        Map<String, String> params = new Map<String, String>();
        params.put('Customer', customerAN8);
        params.put('Yearr', getPreviousFiscalYear(fiscalMonth));
        List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas> result = new List<LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas>();

        String[] reportPath = LAT_GeneralConfigDao.getValueAsStringArray('PATH_BI_REPORT_FATURAMENTO',',');
        String BIxml = '';
        if (!Test.isRunningTest()) {
            BIxml = LAT_WS_GetBIReportsInterface.getBiReportsCallout(params, reportPath[0], 'Brasil');
        }

        if (BIxml.contains('xml')) {
            Dom.Document doc = new Dom.Document();
            doc.load(BIxml);

            //Retrieve the root element for this document.
            Dom.XMLNode data_ds = doc.getRootElement();
            for(Dom.XMLNode child : data_ds.getChildElements()) {
                if ('G_1'.equals(child.getName())) {
                    LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas newNode = new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO());
                    for(Dom.XMLNode subchild : child.getChildElements()) {
                        if (subchild.getName().equals('BRAND')) {
                            newNode.SKU = subchild.getText();
                        } else if (subchild.getName().equals('VOLUME_FY_CA')) {
                            newNode.CA = Decimal.valueOf(subchild.getText());
                        } else if (subchild.getName().equals('PRECO_MEDO')) {
                            newNode.Preco = Decimal.valueOf(subchild.getText());
                        }
                        system.debug('subchildNode----->' + subchild.getName());
                    }
                    result.add(newNode);
                }
            }
        } else {
            error = true;
        }

        if (result.isEmpty() && !error) {
            result.add(new LAT_BR_CreditAnalisisUtils.PrevisaoDeVendas ('', 0, 0, new LAT_BR_SalesPredictionDAO()));
        }
        
        return result;
    }

    
    // Calls BI WS to get PY Data
    public static Map<String, String> getPYPercentsBI(String customerAN8, Integer fiscalMonth) {
        Set<String> QuarterKeys = new Set<String>{'JANUARY-MARCH', 'APRIL-JUNE', 'JULY-SEPTEMBER', 'OCTOBER-DECEMBER'};

        Map<String, String> params = new Map<String, String>();
        params.put('Customer', customerAN8);
        params.put('Yearr', getPreviousFiscalYear(fiscalMonth));
        Map<String, Decimal> resultPer = new Map<String, Decimal>();
        Map<String, Decimal> resultFact = new Map<String, Decimal>();
        for (String keys: QuarterKeys) {
            resultPer.put(keys,0);
            resultFact.put(keys,0);
        } 

        String[] reportPath = LAT_GeneralConfigDao.getValueAsStringArray('PATH_BI_REPORT_FATURAMENTO_TRIM',',');
        String BIxml = '';
        if (!Test.isRunningTest()) {
            BIxml = LAT_WS_GetBIReportsInterface.getBiReportsCallout(params, reportPath[0], 'Brasil');
        }

        if (BIxml.contains('xml')) {
            Dom.Document doc = new Dom.Document();
            doc.load(BIxml);

            //Retrieve the root element for this document.
            Dom.XMLNode data_ds = doc.getRootElement();
            for(Dom.XMLNode child : data_ds.getChildElements()) {
                if ('G_1'.equals(child.getName())) {
                    String Quarter = '';
                    Decimal Percent = 0;
                    Decimal Fat = 0;
                    for(Dom.XMLNode subchild : child.getChildElements()) {
                        if (subchild.getName().equals('TRIMESTRE')) {
                            Quarter = subchild.getText();
                        } else if (subchild.getName().equals('PORCENTAJE')) {
                            Percent += Decimal.valueOf(subchild.getText());
                        } else if (subchild.getName().equals('FATURAMENTO')) {
                            Fat += Decimal.valueOf(subchild.getText());
                        }
                        system.debug('subchildNode----->' + subchild.getName());
                    }
                    if (resultPer.get(Quarter) != null) {
                        resultPer.put(Quarter, resultPer.get(Quarter) + Percent);
                    }
                    if (resultFact.get(Quarter) != null) {
                        resultFact.put(Quarter, resultFact.get(Quarter) + Fat);
                    }
                }
            }


        }
        
        Map<String, String> result = new Map<String, String>();
        for (String keys: QuarterKeys) {
            if (resultPer.get(keys) != null && resultFact.get(keys) != null) {
                result.put(keys,resultPer.get(keys) + '_' + resultFact.get(keys));
            } else {
                result.put(keys,'0_0');
            }
        }

        return result;
    }
}