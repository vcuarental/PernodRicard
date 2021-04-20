/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Contract.
* NAME: CustomerHandlerInterfaceTest.CLS
* AUTHOR: ROGÉRIO ALVARENGA                         DATE: 10/05/2012
*
* MAINTENANCE
* AUTHOR: CARLOS CARVALHO                           DATE: 01/08/2012
*
* MAINTENANCE: Inserido método getListContractsByIds
* AUTHOR: CARLOS CARVALHO                           DATE: 28/09/2012
*
* MAINTENANCE: Inserido campos nos métodos: getListContractByIds e getContractById.
* AUTHOR: CARLOS CARVALHO                           DATE: 11/10/2012
*
* MAINTENANCE: Inserido seguintes códigos: método getIds(), listIdsRecType e atribuído para as
* cláusulas WHERE a listIdsRecType.
* AUTHOR: CARLOS CARVALHO                           DATE: 07/01/2013
********************************************************************************/
public with sharing class ContractDAO {
  
  private static final ContractDAO instance = new ContractDAO();
  
  private List< Id > listIdsRecType = getIds();
  
  private List< Id > getIds(){
  	List< Id > lList = new List< Id >();
  	lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_OFF'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_on'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOffTrade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'AlteracaoContratoAtivoOnTrade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Alteracao_de_contrato_aprovada_On_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_aprovado'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_Off_Trade_ativo'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_aprovada'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Assinatura_de_contrato_com_aprovacao'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Ativacao_de_contrato'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_Off_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_On_Trade'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_off'));
    lList.add( RecordTypeForTest.getRecType( 'LAT_Contract__c', 'Cancelamento_de_contrato_aprovado_on'));
    return lList;
  }
  

  //Método responsável por prover a instância dessa classe.
  public static ContractDAO getInstance()
  {
    return instance;
  }
  
  
  //Método responsável por recuperar uma lista de contratos de uma determinado lista de contas.
  //@param aAccounts (Ids das contas).
  public List< LAT_Contract__c > getListContractByAccount( List< String > aAccounts )
  {
    return [ Select Account__c, Volume_absolut_100__c, Volume_Absolut_Elyx__c, Volume_Absolut_Flavors__c,
             Volume_Absolut_Vodka__c, Volume_Ballantine_s_12Y__c, Volume_Ballantine_s_17Y__c,
             Volume_Ballantine_s_21Y__c, Volume_Ballantine_s_30Y__c, Volume_Ballantine_s_Finest__c,
             Volume_Cachaca_Janeiro__c, Volume_Cachaca_Sao_Francisco__c, Volume_Chivas_Regal_12_Years__c,
             Volume_Chivas_Regal_18_Years__c, Volume_Chivas_Regal_25_Years__c, Volume_Domecq_Tradicional__c,
             Volume_Havana_Club_3_Anos__c, Volume_Havana_Club_7_anos__c, Volume_Havana_Club_Anejo_Reserva__c,
             Volume_Jameson_Standard__c, Volume_Jim_Beam_Black__c, Volume_Jim_Beam_White__c,
             Volume_Kahlua__c, Volume_Malibu_Nacional__c, Volume_Montilla_Cristal__c,
             Volume_Mumm_Champagne__c, Volume_Mumm_Espumante__c, Volume_Natu_Nobilis__c,
             Volume_Olmeca__c, Volume_Orloff__c, Volume_Passport_LBS__c, Volume_Perrier_Jouet__c,
             Volume_Perrier_Jouet_1_5L__c, Volume_Perrier_Jouet_Belle_Epoque__c, 
             Volume_Perrier_Jouet_Belle_Epq1_5L__c, Volume_Royal_Salute__c, Volume_Royal_Salute_38YO__c,
             Volume_Sandeman__c, Volume_Teachers__c, Volume_Tezon__c, Volume_Wall_Street__c,
             Volume_Wyborowa_Exquisite__c, 
             
             //Portifolio Pernod Ricard
             Vodkas_importadas_Absolut__c, Vodkas_importadas_Absolut_Flavours__c,
             Vodkas_importadas_Wyborowa_Exquisite__c, Vodkas_importadas_Wyborowa__c,
             Vodkas_importadas_Absolut_Elyx__c, Vodkas_nacionais_Orloff__c,
             Whisky_Std_Ballantines_Finest__c,  Whisky_Premium_12_anos_Chivas_12__c,
             Whisky_Premium_12_anos_Ballantines_12__c, Whisky_Super_Premium_Chivas_18__c,
             Whisky_Super_Premium_Chivas_25__c, Whisky_Super_Premium_Royal_Salute__c,
             Whisky_Super_Premium_Ballantines_17__c,  Whisky_Super_Premium_Ballantines_21__c,
             Whisky_Super_Premium_Ballantines_30__c,  Whisky_Irlandes_Jameson__c,
             Whisky_Engarrafado_Passport__c,  Whisky_Engarrafado_Teachers__c,
             Whisky_Nacional_Natu_Nobilis__c, Whisky_Bourbon_Jim_Bean__c,
             Champagne_Perrier_Jouet_Belle_Epoque__c, Champagne_Perrier_Jouet_Grand_Brut__c,
             Champagne_Mumm_Cordon_Rouge__c,  Espumante_Mumm_Cuvee__c, Espumante_Mumm_Petit__c, 
             Rum_Importado_Havana_Club__c,  Rum_Nacional_Malibu__c, Rum_Nacional_Montila__c,
             Gin_Beefeater__c, Cachaca_Janeiro__c,  Licor_Kahlua__c, Licor_Ricard__c,
             Vinhos_Jacobs_Creek__c,  Vinhos_Marques_de_Arienzo__c, Vinhos_Graffigna__c,
             Cognac_Martell__c,
             
             //Contrapartidas de Visibilidade
             Visibilidade_do_produto__c, Tailor_made__c, Uniforme__c, Material__c,
             Venda_de_Garrafa__c, Incentivo_da_Brigada__c, Comunicacao__c, Festas_Eventos__c,
             Cardapio__c, Consultoria_de_Mixologistas__c, Projetos_Especiais__c, Ativacao__c,
             
             // Visibilidade
             Armarios_de_Clube_da_Vodka__c, Armarios_de_Clube_de_Whisky__c,
             Prateleiras_dos_Bares__c, Cabine_de_DJ__c,
             
             // Acordo Promocional
             Prioridade_venda_Vodkas_Nacionais__c, Prioridade_venda_Vodka_Super_Premium__c,
             Prioridade_venda_Whisky_Nacional__c, Prioridade_venda_Whiskie_Americano__c,
             Prioridade_venda_Whiskie_Irlandes__c, Prioridade_venda_Whisky_12_anos__c,
             Prioridade_venda_Rum_Nacional__c, Prioridade_venda_Champagne__c,
             Prioridade_venda_Vinhos__c, Exclusiv_promoc_Vodkas_Nacionais__c,
             Exclusiv_promoc_Vodka_Super_Premium__c, Exclusiv_promoc_Whisky_Nacional__c,
             Exclusiv_promoc_Whiskie_Bourbon__c, Exclusiv_promoc_Whiskie_Irlandes__c,
             Exclusiv_promoc_Whisky_12_anos__c, Exclusiv_promoc_Rum_Nacional__c, Exclusiv_promoc_Champagne__c,
             Exclusiv_promoc_Vinhos__c, Exclusiv_visual_Vodkas_Nacionais__c, Exclusiv_visual_Vodka_Super_Premium__c,
             Exclusiv_visual_Whisky_Nacional__c, Exclusiv_visual_Whiskie_Bourbon__c,
             Exclusiv_visual_Whiskie_Irlandes__c, Exclusiv_visual_Whisky_12_anos__c,
             Exclusiv_visual_Rum_Nacional__c, Exclusiv_visual_Champagne__c, Exclusiv_visual_Vinhos__c,
             Prioridade_venda_Vodkas_Importadas__c, Prioridade_venda_Tequila_Std__c,
             Prioridade_venda_Whisky_Engarrafado__c, Prioridade_venda_Tequila_S_Premium__c,
             Prioridade_venda_Whisky_Std__c, Prioridade_venda_Whisky_Super_Premium__c,
             Prioridade_venda_Rum_Importado__c, Prioridade_venda_Espumantes__c,
             Exclusiv_promoc_Vodkas_Importadas__c, Exclusiv_promoc_Tequila__c, Exclusiv_promoc_Whisky_Engarrafado__c,
             Exclusiv_promoc_Tequila_super_premium__c, Exclusiv_promoc_Whisky_Std__c,
             Exclusiv_promoc_Whisky_Super_Premium__c, Exclusiv_promoc_Rum_Importado__c,
             Exclusiv_promoc_Espumantes__c, Exclusiv_visual_Vodkas_Importadas__c, Exclusiv_visual_Tequila__c,
             Exclusiv_visual_Whisky_Engarrafado__c, Exclusiv_visual_Tequila_super_premium__c,
             Exclusiv_visual_Whisky_Std__c, Exclusiv_visual_Whisky_Super_Premium__c,
             Exclusiv_visual_Rum_Importado__c, Exclusiv_visual_Espumantes__c,
             
             // Detalhamento
             Pecas_Tailor_Made_Quantidade__c, Pecas_Tailor_Made_Ambiente_Local1__c,
             Pecas_Tailor_Made_Ambiente_Local2__c, Pecas_Tailor_Made_Ambiente_Local3__c, 
             Pecas_Tailor_Made_Marcas1__c, Pecas_Tailor_Made_Marcas2__c,
             Pecas_Tailor_Made_Marcas3__c
             
             From LAT_Contract__c Where Account__c =: aAccounts and status__c ='Ativo' 
             AND RecordTypeId =: listIdsRecType];
      
  }
  
  //Recupera campos do contrato atraves do Id do contrato. Utilizado pelo ContractManagerInterface.
  //@author : Carlos Carvalho - Data: 01/08/2012
  public LAT_Contract__c getContractById( String idContract ){
    LAT_Contract__c lContract = null;
     try{
      lContract = [Select Id, 
                          ProvisionarAte__c,
                ContractNumber__c,
                Status_da_INtegra_o__c,
                MensagemIntegracao__c,
              StartDate__c,
              EndDate__c,
              OwnerId,
                            Owner.UserName,
              RecordTypeId,
              CreatedById,
              CreatedBy.UserName,
              LastModifiedById,
                            LastModifiedBy.UserName,
              LastModifiedDate,
                            Contrato_original__r.ContractNumber__c,
              Contrato_original__c,
              Contrato_por__c,
              Account__r.Client_code_AN8__c,
              Account__r.Customer_Flag__c,
              Account__r.Customer_organization__c
              From LAT_Contract__c Where id =: idContract ANd RecordTypeId =: listIdsRecType limit 1];
              
     }catch(QueryException e){
      System.debug(e.getMessage());
     }
     
     return lContract;
  }
  
  
    public List< LAT_Contract__c > getListContractByIds( List< String > aIdsContract ){
        List< LAT_Contract__c > lList = new List< LAT_Contract__c >();
      
      lList = [Select Id,
                      ProvisionarAte__c,
                      ContractNumber__c,
                      StartDate__c,
                      EndDate__c,
                      OwnerId,
                      status__c,
                      Owner.UserName,
                      RecordTypeId,
                      CreatedById,
                      CreatedBy.UserName,
                      LastModifiedById,
                      LastModifiedBy.UserName,
                      LastModifiedDate,
                      Contrato_original__c,
                        Contrato_original__r.ContractNumber__c,
                      Contrato_por__c,
                      Account__r.Client_code_AN8__c,
                      Account__r.Customer_Flag__c,
                      Account__r.Customer_Organization__c,
                      demanda01_Aprovado__c,
                      demanda02_Aprovado__c
                      From LAT_Contract__c
                      Where Id =: aIdsContract
                      AND RecordTypeId =: listIdsRecType
               ];
               
      return lList;
  }
}