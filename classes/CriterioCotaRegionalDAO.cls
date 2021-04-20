/********************************************************************************
*                         Copyright 2012 - Cloud2b
********************************************************************************
* Classe que realiza funções DML no objeto Critério Cotas Regionais.
*
* NAME: CriterioCotaRegionalDAO.cls
* AUTHOR: CARLOS CARVALHO                           DATE: 16/05/2012
*
* MAINTENANCE: INSERIDO LÓGICA DE VALIDAÇÃO DO TIPO DE REGISTRO DOS OBJETOS.
* AUTHOR: CARLOS CARVALHO                           DATE: 10/01/2013 
********************************************************************************/
public with sharing class CriterioCotaRegionalDAO 
{
	  
	private static final CriterioCotaRegionalDAO instance = new CriterioCotaRegionalDAO();
	
	//Recupera o id do tipo de registro do objeto
	private Id idRecTypeCCR = RecordTypeForTest.getRecType( 'Criterio_de_cota_regional__c', 'BRA_Standard' );
	  
	//Construtor privado para impedir a criação de instâncias dessa classe.
	private CriterioCotaRegionalDAO()
	{
	}
	
	//Método responsável por prover a instância dessa classe.
	public static CriterioCotaRegionalDAO getInstance()
	{
	  return instance;
	}
	  
	// Recupera um lista de objetos do tipo Criterio_de_cota_regional__c cujo o SKU esteja contido
	// na lista passada como parametro
	// @param aIdsSKU
	public List< Criterio_de_cota_regional__c > getListCriterioByIdSKU( List< String > aIdsSKU )
	{
		
	    List< Criterio_de_cota_regional__c > listCriterio = null;
	 
	    listCriterio = [ SELECT  Id,
					             Bandeira_regional__c,
					             Executivo__c,
					             Bandeira__c,
					             Canal__c,
					             Cota__c,
					             Cota_nacional__c,
					             Regional__c,
					             SKU__c,
					             Sub_canal__c
					             FROM Criterio_de_cota_regional__c
					             WHERE SKU__c =: aIdsSKU
					             AND RecordTypeId =: idRecTypeCCR ];	                          
	    return listCriterio;
	}
}