public class LAT_BR_SegmentationResultController {
	
	public LAT_BR_ClientChannelSegmentation2Result__c segment{get;set;}
	public boolean hasSegment{get;set;}
	public boolean hasEdit{get;set;}
	public boolean isEdit{get;set;}
	public Id accId{get;set;}
	public Account acc{get;set;}
	public Lat_account__c latacc {get;set;}
    public string descricaoPoliticaComercial {get; set;}

	public Id  politicaBefore{get;set;}
	public boolean tbciBefore{get;set;}

	public LAT_BR_SegmentationResultController(ApexPages.StandardController controller) {
		
		accId = controller.getRecord().Id;
		acc = [Select id,Status__c,Rating,OwnerId from Account where Id=:accId];
		latacc = [Select id from Lat_account__c where Lat_accountId__c=:accId];
		init();
	}

	public void init(){
		hasEdit = false;  
        descricaoPoliticaComercial = '';
        if (userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_BusinessAdministrator') 
        	|| userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_SystemAdministrator')
        	|| userInfo.getProfileId() == LAT_GlobalProfileCache.getProfileIdByName('LAT_BR2_PlanejamentoComercial')) {
        	hasEdit = true;
        }
		isEdit = false;
		
		List<LAT_BR_ClientChannelSegmentation2Result__c> lst = [SELECT Account__c,
									Beneficio_Fiscal__c,
									Channel__c,
									Client_type__c,
									Estrategia_comercial__c,
									FORMATO__c,
									Perfil__c,
									POLiTICA_DE_PRECO__c,
                                    POLiTICA_DE_PRECO_Used__c,
									PRIOR_DE_INVESTIMENTO__c,
									Segment__c,
									Sub_channel__c,Obtained_Layout__c,
									TBCI__c,
									Obtained_POLiTICA_DE_PRECO_Udc__c,
									Politica_Preco_Origin__c,
									Obtained_POLiTICA_DE_PRECO_Udc__r.Name
						FROM LAT_BR_ClientChannelSegmentation2Result__c 
						WHERE Account__c = :accId];


		if(!lst.isEmpty()){
			hasSegment = true;
			segment = lst[0];
			politicaBefore = segment.Obtained_POLiTICA_DE_PRECO_Udc__c;
			tbciBefore = segment.TBCI__c;
		} else {
			hasSegment = false;
		}
	}

	public void doEdit(){
    isEdit = true;
}


	public void changeSegmentation(){
		// check that tbci is going from false to true
		if (tbciBefore && segment.TBCI__c && politicaBefore == segment.Obtained_POLiTICA_DE_PRECO_Udc__c){
			isEdit = false;
		//} else if(!tbciBefore && segment.TBCI__c && acc.Status__c == 'Cliente cadastrado no JDE'){
		} else if (segment.TBCI__c && acc.Status__c == 'Cliente cadastrado no JDE'){
            System.debug('//////////if2');
			//sent to approve
			update new Lat_Account__c (Id=latacc.Id,TBCItext__c = String.valueOf(segment.TBCI__c), Obtained_Approval__c = 'LAT_BR_ACC_DiretorFinanciero', TBCI_revert__c = tbciBefore,Obtained_POLiTICA_DE_PRECO_Udc_revert__c =politicaBefore, LAT_Status_Before_Approval__c = acc.Status__c);
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setComments('Enviado para aprovação TBCI cambio');

			saveUpdatePage();
			//LAT_BR_SegmentationBehaviorHandler.notificateManagers(segment);

			req.setNextApproverIds(new List<Id>{acc.ownerId});
			req.setObjectId (acc.Id);
             // submit the approval request for processing
             Approval.ProcessResult approvalRes = Approval.process(req);
             isEdit = false;
		} else {
			if ((tbciBefore != segment.TBCI__c && acc.Status__c == 'Cliente cadastrado no JDE') || (politicaBefore != segment.Obtained_POLiTICA_DE_PRECO_Udc__c) && acc.Status__c == 'Cliente cadastrado no JDE') {
                System.debug('//////////if3');
                descricaoPoliticaComercial = getDescripcion(segment.Obtained_POLiTICA_DE_PRECO_Udc__c);
                if (descricaoPoliticaComercial != '') {
                    saveUpdatePage();
                    system.debug('Entro a enviar chattre+++');
                    LAT_BR_SegmentationBehaviorHandler.notificateManagers(segment);
                    acc.Status__c = 'Aprovado - Aguardando retorno do JDE';
                    update acc;                
                } else {
                    System.debug('//////////if3else');
                    descricaoPoliticaComercial = 'Descrição Política Comercial para el código ingresado no se ha encontrado.';
                }
			} else {
                System.debug('//////////if4');
                if (politicaBefore != segment.Obtained_POLiTICA_DE_PRECO_Udc__c) {
                    System.debug('//////////if4if');
                    descricaoPoliticaComercial = getDescripcion(segment.Obtained_POLiTICA_DE_PRECO_Udc__c);
                    if (descricaoPoliticaComercial == '') {
                        descricaoPoliticaComercial = 'Descrição Política Comercial para el código ingresado no se ha encontrado.';
                    } else {
                        saveUpdatePage();
                    }
                } else {
                    doSave();
                    isEdit = false;
                }
			}
		}
	}
    
    private void saveUpdatePage() {
        doSave();
        tbciBefore = segment.TBCI__c;
        politicaBefore = segment.Obtained_POLiTICA_DE_PRECO_Udc__c;
    }

    private String getDescripcion(String politicaPreco) {
    	List<LAT_BR_PoliticaComercial__c> descricaoPoliticaComercialList = new List<LAT_BR_PoliticaComercial__c>([Select LAT_BR_DescricaoPoliticaComercial__c 
                                                                                                                 From LAT_BR_PoliticaComercial__c 
                                                                                                                 Where LAT_BR_CodigoPoliticaComercial__c = :politicaPreco]);    
        if (descricaoPoliticaComercialList.size() > 0 && descricaoPoliticaComercialList[0].LAT_BR_DescricaoPoliticaComercial__c != null) {
            return descricaoPoliticaComercialList[0].LAT_BR_DescricaoPoliticaComercial__c;
        } else {
            return '';
        }
    }
    
	public void doSave(){
    try{
    	update new Lat_Account__c (Id=latacc.Id, TBCItext__c = String.valueOf(segment.TBCI__c));
    	segment.LAT_IsRevert__c = true;
        update segment;
        isEdit = false;

        }catch(Exception e){}
    }

    public void doCancel(){
        init();
    }

    public PageReference updateAccount() {
        update segment;
        isEdit = false;

        PageReference tempPage = ApexPages.currentPage();            
        tempPage.setRedirect(true);
        return tempPage ;
    }
}