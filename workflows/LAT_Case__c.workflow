<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Assinatura_nao_aprovada_pelo_cliente</fullName>
        <description>Assinatura não aprovada pelo cliente</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LAT_AreaManager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LAT_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Assinatura_de_novo_contrato_nao_aprovada_cliente</template>
    </alerts>
    <alerts>
        <fullName>CSE_CaseCloseNotification_AR</fullName>
        <description>CSE_CaseCloseNotification_AR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_AR2_CSE_CaseClosedAccountRecordUpdate</template>
    </alerts>
    <alerts>
        <fullName>CSE_CaseClosedViaLegalApproved_AR</fullName>
        <description>CSE_CaseClosedViaLegalApproved_AR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_AR2_CSE_CaseClosedViaLegalApproved</template>
    </alerts>
    <alerts>
        <fullName>CSE_CaseClosedViaLegalRejected_AR</fullName>
        <description>CSE_CaseClosedViaLegalRejected_AR</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_AR2_CSE_CaseClosedViaLegalRejected</template>
    </alerts>
    <alerts>
        <fullName>CSE_CasePaymentProposalApprovedAlert_AR</fullName>
        <description>CSE_CasePaymentProposalApproved_AR</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_AR2_CSE_CasePaymentProposalApproved</template>
    </alerts>
    <alerts>
        <fullName>CSE_CasePaymentProposalRejectedAlert_AR</fullName>
        <description>CSE_CasePaymentProposalRejected_AR</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LAT_Templates/LAT_AR2_CSE_CasePaymentProposalRejected</template>
    </alerts>
    <alerts>
        <fullName>Carta_de_nao_renovacao_de_contrato_PRB</fullName>
        <description>Carta de não renovação de contrato_PRB</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LAT_AreaManager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LAT_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Nao_aprovacao_da_PRB_quanto_a_renovacao_de_contrato</template>
    </alerts>
    <alerts>
        <fullName>Carta_de_nao_renovacao_de_contrato_entregue</fullName>
        <description>Carta de não renovação de contrato entregue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LAT_AreaManager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LAT_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Entrega_de_carta_de_nao_renovacao_de_contrato</template>
    </alerts>
    <alerts>
        <fullName>Demanda_Proposta_de_pagamento_aprovada</fullName>
        <description>Demanda: Proposta de pagamento aprovada</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Demanda_Proposta_de_pagamento_aprovada</template>
    </alerts>
    <alerts>
        <fullName>LAT_BR_AlertCaseRejected</fullName>
        <description>LAT_BR_Alert Case Rejected</description>
        <protected>false</protected>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_CaseRejected</template>
    </alerts>
    <alerts>
        <fullName>LAT_BR_Rejection_Alert</fullName>
        <description>LAT BR Rejection Alert</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Visualforce_Email_Templates/LAT_BR2_Prorroga_o_de_Contrato_Reprovada</template>
    </alerts>
    <alerts>
        <fullName>LAT_MX_CSE_CloseCase_AccountAlteration</fullName>
        <description>LAT_MX_CSE_CloseCase_AccountAlteration</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LAT_MX2_CSE_CloseCaseAccountAlteration</template>
    </alerts>
    <alerts>
        <fullName>Nao_renovacao_de_contrato</fullName>
        <description>Não renovação de contrato</description>
        <protected>false</protected>
        <recipients>
            <recipient>prbrazil_admin@guest.pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <field>LAT_AreaManager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LAT_RegionalManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Nao_renovacao_de_contrato_aprovada</template>
    </alerts>
    <alerts>
        <fullName>Proposta_de_pagamento_aprovada_financeiro</fullName>
        <description>Proposta de pagamento aprovada - financeiro</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Demanda_Proposta_de_pagamento_aprovada</template>
    </alerts>
    <alerts>
        <fullName>Proposta_de_pagamento_rejeitada</fullName>
        <description>Proposta de pagamento rejeitada</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Demanda_Proposta_de_pagamento_rejeitada</template>
    </alerts>
    <alerts>
        <fullName>Proposta_de_renova_o_n_o_aprovada_pelo_cliente</fullName>
        <description>Proposta de renovação não aprovada pelo cliente</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>LAT_AreaManager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>LAT_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Nao_aprovacao_do_cliente_quanto_a_renovacao_de_contrato</template>
    </alerts>
    <alerts>
        <fullName>SLA_1_Nivel</fullName>
        <description>SLA 1º Nível</description>
        <protected>false</protected>
        <recipients>
            <field>LAT_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_SLA_de_termino_de_contrato</template>
    </alerts>
    <alerts>
        <fullName>Termino_de_contrato_SLA_2_Nivel_gerente_de_area</fullName>
        <description>Término de contrato - SLA 2º Nível - gerente de área</description>
        <protected>false</protected>
        <recipients>
            <field>LAT_AreaManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_SLA_de_termino_de_contrato</template>
    </alerts>
    <alerts>
        <fullName>Termino_de_contrato_SLA_2_Nivel_gerente_regional</fullName>
        <description>Término de contrato - SLA 2º Nível - gerente regional</description>
        <protected>false</protected>
        <recipients>
            <field>LAT_RegionalManager__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_SLA_de_termino_de_contrato</template>
    </alerts>
    <fieldUpdates>
        <fullName>Alt_stat_Relatorio_devolvido_correcoes</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Relatório devolvido para correções</literalValue>
        <name>Alt stat - Relatório devolvido correções</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_tipo_registro_Renovacao_do_contrat</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Contrato_Proposta_de_renovacao</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Alt tipo registro - Renovação do contrat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_tipo_registro_prorroga_o_contrato</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Contrato_Processo_de_prorrogacao</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Alt tipo registro - prorrogação contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_Status_Em_analise_ADM_Vendas</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - ADM Vendas</literalValue>
        <name>Altera Status - Em analise - ADM Vendas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_Status_Nao_Aprovado1</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>Altera Status - Não Aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_Status_Nao_aprovado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>Altera Status - Não aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_propriet_rio_adm_vendas</fullName>
        <field>OwnerId</field>
        <lookupValue>Administracao_de_Vendas</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Altera proprietário adm vendas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_propriet_rio_customer_service</fullName>
        <field>OwnerId</field>
        <lookupValue>Customer_service</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Altera proprietário customer service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_propriet_rio_da_demanda</fullName>
        <field>OwnerId</field>
        <lookupValue>Credito_e_Cobranca</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Altera proprietário da demanda</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_proprietario_customer_service</fullName>
        <field>OwnerId</field>
        <lookupValue>Customer_service</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Altera proprietário customer service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_proprietario_planej_comercial</fullName>
        <field>OwnerId</field>
        <lookupValue>Planejamento_comercial</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Altera proprietário planej comercial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Caso_APROVADO</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Aprovado</literalValue>
        <name>Altera status Caso - APROVADO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Em_aprov_vendas</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação - Vendas</literalValue>
        <name>Altera status - Em aprov vendas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AtualizaConsultaRealizadaTRUE</fullName>
        <field>LAT_InquiryHeld__c</field>
        <literalValue>0</literalValue>
        <name>AtualizaConsultaRealizadaTRUE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_Status_Caso_Controladoria</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Controladoria</literalValue>
        <name>Atualiza Status Caso Controladoria</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_Status_Caso_Cred_Cobranca</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Crédito e cobrança</literalValue>
        <name>Atualiza Status Caso Cred Cobranca</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_Status_Caso_Customer_Service</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Customer Service</literalValue>
        <name>Atualiza Status Caso Customer Service</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_Status_Caso_Em_Aprov_Coml</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação - Comercial</literalValue>
        <name>Atualiza Status Caso Em Aprov Coml</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_Status_Caso_Planej_Comercial</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Planejamento Comercial</literalValue>
        <name>Atualiza Status Caso Planej Comercial</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_assunto_vazio_com_Tipo_e_motivo</fullName>
        <field>LAT_Subject__c</field>
        <formula>text(LAT_Type__c) + &quot; - &quot; + text(LAT_Reason__c)</formula>
        <name>Atualiza assunto vazio com Tipo e motivo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_descricao</fullName>
        <field>LAT_Description__c</field>
        <formula>PRIORVALUE( LAT_Description__c ) &amp; BR() &amp; BR() &amp; &quot;Solicitar ao cliente aprovação da renovação&quot;</formula>
        <name>Atualiza descrição</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_descricao_do_caso</fullName>
        <field>LAT_Description__c</field>
        <formula>PRIORVALUE( LAT_Description__c ) &amp; BR() &amp; BR() &amp; &quot;Emitir carta de Não Renovação de Contrato&quot;</formula>
        <name>Atualizadescrição do caso</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_descricao_prorrogacao</fullName>
        <field>LAT_Description__c</field>
        <formula>PRIORVALUE( LAT_Description__c ) &amp; BR() &amp; BR() &amp; &quot;Negociar prorrogação de contrato com o cliente&quot;</formula>
        <name>Atualiza descrição - prorrogação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_stat_proc_carta_n_o_renov</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em processo de Carta de não renovação</literalValue>
        <name>Atualiza stat - proc carta não renov</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Canc_aprovado_cliente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento aprovado pelo cliente</literalValue>
        <name>Atualiza status - Canc. aprovado cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Clausulas_enc_gerente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cláusulas encaminhadas para o Gerente</literalValue>
        <name>Atualiza status - Cláusulas enc gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_enc_consultor</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato encaminhado p/ o consultor</literalValue>
        <name>Atualiza status - Distrato enc consultor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_enc_coodenado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato encaminhado para o coordenador</literalValue>
        <name>Atualiza status - Distrato enc coodenado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_enc_diretor</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato encaminhado p/ diretor</literalValue>
        <name>Atualiza status - Distrato enc. diretor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_enc_diretoria</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato encaminhado p/ diretor</literalValue>
        <name>Atualiza status - Distrato enc diretoria</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_enc_gerente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato encaminhado para o gerente</literalValue>
        <name>Atualiza status - Distrato enc gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_enc_regional</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato assinado encaminhado regional</literalValue>
        <name>Atualiza status - Distrato enc regional</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Distrato_ent_cliente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Distrato entregue para o cliente</literalValue>
        <name>Atualiza status - Distrato ent cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Em_proc_n_o_renova_o</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em processo de não renovação</literalValue>
        <name>Atualiza status - Em proc não renovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Enc_negocia_o_cliente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Encaminhado p/ negociação com cliente</literalValue>
        <name>Atualiza status - Enc negociação cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Sol_de_canc_coordena</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento encaminhado ao Coordenador</literalValue>
        <name>Atualiza status - Sol. de canc. coordena</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Sol_de_canc_juridico</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento encaminhado ao Jurídico</literalValue>
        <name>Atualiza status - Sol. de canc. juridico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Sol_de_cancel_gerente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento encaminhado ao gerente</literalValue>
        <name>Atualiza status - Sol. de cancel gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Sol_enc_Jur_dico</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento encaminhado ao Jurídico</literalValue>
        <name>Atualiza status - Sol. enc. Jurídico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_acordo_aprovado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Acordo aprovado</literalValue>
        <name>Atualiza status - acordo aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_acordo_rejeitado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Acordo rejeitado</literalValue>
        <name>Atualiza status - acordo rejeitado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_aprovado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Aprovado</literalValue>
        <name>Atualiza status - aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_cancel_aprovado_client</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento aprovado pelo cliente</literalValue>
        <name>Atualiza status - cancel aprovado client</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_cancel_enc_gerente</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Cláusulas encaminhadas para o gerente</literalValue>
        <name>Atualiza status - cancel enc gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_em_analise_c_c</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Crédito e cobrança</literalValue>
        <name>Atualiza status - em analise c&amp;c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_em_aprov_Cec</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação - Crédito e Cobrança</literalValue>
        <name>Atualiza status - em aprov C&amp;c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_em_aprova_o_financeir</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação - Financeiro</literalValue>
        <name>Atualiza status - em aprovação financeir</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_em_proc_renova_o</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em processo de renovação</literalValue>
        <name>Atualiza status - em proc renovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_encerrado_via_cartorio</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Encerrado via Cartório</literalValue>
        <name>Atualiza status - encerrado via cartório</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_proc_de_prorrogacao</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Processo de prorrogação pendente</literalValue>
        <name>Atualiza status - proc de prorrogação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_proc_prorrog_finalizad</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Processo de prorrogação finalizado</literalValue>
        <name>Atualiza status - proc prorrog finalizad</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_prorroga_o_contrato</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em processo de prorrogação</literalValue>
        <name>Atualiza status - prorrogação contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_tipo_de_registro_c_proposta</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Proposta_de_pagamento</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza tipo de registro - c proposta</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_tipo_de_registro_s_proposta</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Sem_proposta_de_pagamento</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza tipo de registro - s proposta</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_tipo_reg_justificativa_inadim</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Justificativa_de_inadimplencia</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Atualiza tipo reg - justificativa inadim</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_valor_devido</fullName>
        <field>LAT_ValueDue__c</field>
        <formula>LAT_Account__r.Amount_due__c</formula>
        <name>Atualiza valor devido</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_FinancialApproval_AR</fullName>
        <description>Updates Financial Approval to true.</description>
        <field>LAT_FinancialApproval__c</field>
        <literalValue>1</literalValue>
        <name>CSE_FinancialApproval_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate2_ARG</fullName>
        <description>Updates the Record Type to &apos;Propuesta de Pagos_AR&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_PaymentProposal_AR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate2_ARG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate2_UY</fullName>
        <description>Updates the Record Type to &apos;Propuesta de Pagos_UY&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>Termino_de_contrato</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate2_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate3_ARG</fullName>
        <description>Updates the Record Type to ‘Morosidad a encaminar a Legales_AR’.</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_OverdueToAttorneys_AR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate3_ARG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate3_UY</fullName>
        <description>Updates the Record Type to ‘Morosidad a encaminar a Legales_UY’.</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_OverdueToAttorneys_UY</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate3_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate4_ARG</fullName>
        <description>Updates the Record Type to ‘Sin propuesta de pagos_AR&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_WOPaymentProposal_AR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate4_ARG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate4_UY</fullName>
        <description>Updates the Record Type to ‘Sin propuesta de pagos_UY&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_WOPaymentProposal_UY</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate4_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate5_ARG</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CSE_OverdueJustification_AR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate5_ARG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate5_UY</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CSE_OverdueJustification_UY</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate5_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate6_AR</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CSE_WOPaymentProposal_AR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate6_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate6_UY</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CSE_WOPaymentProposal_UY</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate6_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate_ARG</fullName>
        <description>Updates the Record Type to &apos;Cliente_Moroso_AR&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_OverdueAccount_AR</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate_ARG</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_RTUpdate_UY</fullName>
        <description>Updates the Record Type to &apos;Overdue_Account_UY&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>CSE_OverdueAccount_UY</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>CSE_RTUpdate_UY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate10_AR</fullName>
        <description>Updates Status to &apos;Aprobado Créditos y Cobranzas&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Aprovado</literalValue>
        <name>CSE_StatusUpdate10_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate11_AR</fullName>
        <description>Updates Status to &apos;En aprobación de Créditos y Cobranzas&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação - Crédito e Cobrança</literalValue>
        <name>CSE_StatusUpdate11_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate1_AR</fullName>
        <description>Updates Status to &apos;Propuesta en aprobación de Ventas&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação - Comercial</literalValue>
        <name>CSE_StatusUpdate1_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate2_AR</fullName>
        <description>Updates Status to &apos;Propuesta Aprobada&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Acordo aprovado</literalValue>
        <name>CSE_StatusUpdate2_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate3_AR</fullName>
        <description>Updates Status to &apos;Propuesta Rechazada&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Acordo rejeitado</literalValue>
        <name>CSE_StatusUpdate3_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate4_AR</fullName>
        <description>Updates Status to &apos;Justificación enviada a Creditos y Cobranzas&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Crédito e cobrança</literalValue>
        <name>CSE_StatusUpdate4_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate5_AR</fullName>
        <description>Updates Status to &apos;Morosidad Justificada&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Inadimplência justificada</literalValue>
        <name>CSE_StatusUpdate5_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate6_AR</fullName>
        <description>Updates Status to &apos;Devuelto al Ejecutivo&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Solicitação devolvida para o Consultor</literalValue>
        <name>CSE_StatusUpdate6_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate7_AR</fullName>
        <description>Updates Status to &apos;a ‘Sin propuesta del cliente - Encaminado a Creditos y Cobranzas’</description>
        <field>LAT_Status__c</field>
        <literalValue>Without customer proposal-Sent to Credit</literalValue>
        <name>CSE_StatusUpdate7_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate8_AR</fullName>
        <description>Updates Status to ‘Cerrado vía Legales’.</description>
        <field>LAT_Status__c</field>
        <literalValue>Cancelamento encaminhado ao Jurídico</literalValue>
        <name>CSE_StatusUpdate8_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_StatusUpdate9_AR</fullName>
        <description>Updates Status to ‘Sin propuesta del cliente - Encaminado a Créditos y Cobranzas’</description>
        <field>LAT_Status__c</field>
        <literalValue>Without customer proposal-Sent to Credit</literalValue>
        <name>CSE_StatusUpdate9_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CSE_UpdateSubject_AR</fullName>
        <field>LAT_Subject__c</field>
        <formula>TEXT(LAT_Type__c)  + &quot; - &quot; + TEXT(LAT_Reason__c)</formula>
        <name>CSE_UpdateSubject_AR</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_arquivado_regional</fullName>
        <field>LAT_CheckedOverByRegionalFiled__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - arquivado regional</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_ass_diretor</fullName>
        <field>LAT_CheckedOverByDisDirector__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - ass diretor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_ass_gerente</fullName>
        <field>LAT_CheckedOverByDisManager__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - ass. gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_cond_cancel_defi</fullName>
        <field>LAT_CheckedOverByTerms__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - cond cancel defi</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_dist_ass_coordenador</fullName>
        <field>LAT_CheckedOverByDisCoordinator__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - dist ass. coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_distrato_enc_coordenador</fullName>
        <field>LAT_CheckedOverByDisSigCustomer__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - distrato enc coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_distrato_entregue</fullName>
        <field>LAT_CheckedOverByDisDelCustomer__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - distrato entregue</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Demanda_Envia_para_Fila_ADM_VENDAS</fullName>
        <field>OwnerId</field>
        <lookupValue>Administracao_de_Vendas</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Demanda Envia para Fila ADM VENDAS</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fecha_caso_como_cancelado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Fechado e cancelado</literalValue>
        <name>Fecha caso como cancelado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_CSE_APStepUpdateAdds1</fullName>
        <field>LAT_APStep__c</field>
        <formula>LAT_APStep__c + 1</formula>
        <name>LAT_AR_CSE_APStepUpdateAdds1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_CSE_APStepUpdateOwner</fullName>
        <field>OwnerId</field>
        <lookupValue>matias.dacostacruz@pernod-ricard.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>LAT_AR_CSE_APStepUpdateOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_CSE_APStepUpdateTo1</fullName>
        <field>LAT_APStep__c</field>
        <formula>1</formula>
        <name>LAT_AR_CSE_APStepUpdateTo1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_AR_CSE_APStepUpdateToNull</fullName>
        <field>LAT_APStep__c</field>
        <name>LAT_AR_CSE_APStepUpdateToNull</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CSE_UpdateOwner</fullName>
        <field>OwnerId</field>
        <lookupValue>LAT_BR_ProcessSupervisor</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>LAT_BR_CSE_UpdateOwner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CSE_UpdateStatus</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Reprovado</literalValue>
        <name>LAT_BR_CSE_UpdateStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CSE_UpdateStatus2</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Aprovado</literalValue>
        <name>LAT_BR_CSE_UpdateStatus2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CSE_UpdateStatus3</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação</literalValue>
        <name>LAT_BR_CSE_UpdateStatus3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CSE_UpdateStatus4</fullName>
        <description>RFC 27593</description>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação – Fiscal</literalValue>
        <name>LAT_BR_CSE_UpdateStatus4</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_CSE_UpdateSubject</fullName>
        <field>LAT_Subject__c</field>
        <formula>&apos;Prorrogação de Contrato&apos;</formula>
        <name>LAT_BR_ CSE_UpdateSubject</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_Update_Status_Closed_Resolved</fullName>
        <description>Updates the Status of the Case to &apos;Fechado e Resolvido&apos;</description>
        <field>LAT_Status__c</field>
        <literalValue>Fechado e resolvido</literalValue>
        <name>LAT BR Update Status Closed Resolved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_ChangeCaseOwnerToFiscal</fullName>
        <field>OwnerId</field>
        <lookupValue>LAT_BR_Fiscal</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Altera proprietário Fiscal</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CSE_UpdateRT</fullName>
        <description>Update case RT when it&apos;s closed</description>
        <field>RecordTypeId</field>
        <lookupValue>LAT_MX_CSE_CaseClosed</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>LAT_MX_CSE UpdateRT</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CSE_UpdateStatusAP1</fullName>
        <description>Set status on &apos;Approved&apos; when the case is approved.</description>
        <field>LAT_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>LAT_MX_CSE_UpdateStatusAP1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CSE_UpdateStatusAP2</fullName>
        <description>Update status to &quot;Em aprovacao&quot; when te record is sent to approve</description>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação</literalValue>
        <name>LAT_MX_CSE_UpdateStatusAP2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_MX_CSE_UpdateStatusAP3</fullName>
        <description>Update status to &quot;Not approved&quot; when is rejected the case</description>
        <field>LAT_Status__c</field>
        <literalValue>Not approved</literalValue>
        <name>LAT_MX_CSE_UpdateStatusAP3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_UpdateCaseStatusToFiscal</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em análise - Fiscal</literalValue>
        <name>Atualiza Status Caso Fiscal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Muda_status_caso_EM_APROVACAO</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Em aprovação</literalValue>
        <name>Altera status caso - EM APROVAÇÃO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Preenche_campo_aprovacao_financeiro</fullName>
        <field>LAT_FinancialApproval__c</field>
        <literalValue>1</literalValue>
        <name>Preenche campo aprovação financeiro</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Re_Send_Account_To_JDE</fullName>
        <field>LAT_SendAccountToJDE__c</field>
        <literalValue>1</literalValue>
        <name>Re-Send Account To JDE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Termino_de_contrato_aprovado</fullName>
        <field>LAT_TerminationApproved__c</field>
        <literalValue>1</literalValue>
        <name>Término de contrato aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateStatusReprovado</fullName>
        <field>LAT_Status__c</field>
        <literalValue>Reprovado</literalValue>
        <name>Update Status Reprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>altera_propriet_rio_Controladoria</fullName>
        <field>OwnerId</field>
        <lookupValue>Controladoria</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>altera proprietário Controladoria</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>altera_proprietario_credito_e_cobranca</fullName>
        <field>OwnerId</field>
        <lookupValue>Credito_e_Cobranca</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>altera proprietário credito e cobranca</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Alerta carta de não renovação</fullName>
        <actions>
            <name>Carta_de_nao_renovacao_de_contrato_entregue</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL( LAT_Type__c, &quot;Não Renovação de Contrato&quot;), ISPICKVAL(  LAT_Reason__c , &quot;Carta de não renovação de contrato&quot;), ISPICKVAL( LAT_Status__c, &quot;Fechado e resolvido&quot;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - justificava inadimplencia - Adm Vendas</fullName>
        <actions>
            <name>Altera_propriet_rio_adm_vendas</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Altera_propriet_rio_customer_service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Atualiza_tipo_reg_justificativa_inadim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente inadimplente</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Type__c</field>
            <operation>equals</operation>
            <value>Justificativa de inadimplência</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Rationale__c</field>
            <operation>equals</operation>
            <value>Abatimento de contrato não registrado</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - justificava inadimplencia - CeC</fullName>
        <actions>
            <name>Atualiza_tipo_reg_justificativa_inadim</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>altera_proprietario_credito_e_cobranca</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente inadimplente</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Type__c</field>
            <operation>equals</operation>
            <value>Justificativa de inadimplência</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Rationale__c</field>
            <operation>contains</operation>
            <value>Condição de pagamento incorreta,Outros,Cliente com verba de contrato a receber,Não recebimento do boleto,Negociação c/ data prevista pagamento,Título já pago</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - justificava inadimplencia - Customer Service</fullName>
        <actions>
            <name>Altera_proprietario_customer_service</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Atualiza_tipo_reg_justificativa_inadim</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente inadimplente</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Type__c</field>
            <operation>equals</operation>
            <value>Justificativa de inadimplência</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Rationale__c</field>
            <operation>equals</operation>
            <value>Abatimento parcial de devolução,Devolução total sem ADM,Diferença de preço na NF,Atraso na entrega</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - proposta de pagamento</fullName>
        <actions>
            <name>Atualiza_tipo_de_registro_c_proposta</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente inadimplente</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Type__c</field>
            <operation>equals</operation>
            <value>Proposta de pagamento</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - sem proposta de pagamento</fullName>
        <actions>
            <name>Altera_propriet_rio_da_demanda</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Atualiza_status_em_analise_c_c</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Atualiza_tipo_de_registro_s_proposta</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente inadimplente</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Type__c</field>
            <operation>equals</operation>
            <value>Proposta não realizada</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Atualiza assunto do caso</fullName>
        <actions>
            <name>Atualiza_assunto_vazio_com_Tipo_e_motivo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Subject__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AtualizaObrigatoriedadeConsultaDA</fullName>
        <actions>
            <name>AtualizaConsultaRealizadaTRUE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Toda vez que um numero de DA é alterado o campo &quot;ConsultaRealizada&quot; fica com valor FALSO.</description>
        <formula>AND( PRIORVALUE( LAT_DANumber__c ) &lt;&gt; LAT_DANumber__c , $RecordType.DeveloperName = &quot;Gerar_D_A_no_sistema_ME&quot; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSE_WF01_UpdateAccountOwner_AR</fullName>
        <active>true</active>
        <description>Copies the owner of the Account to the field &quot;Account Owner&quot;</description>
        <formula>(  $RecordType.DeveloperName=&apos;CSE_1_AccountAlteration_ARG&apos; ||  $RecordType.DeveloperName=&apos;CSE_2_AccountAlteration_URU&apos;  )  &amp;&amp;  ( ISNEW() || ISCHANGED(LAT_Account__c) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSE_WF02_EmailAlertCloseCase_AR</fullName>
        <actions>
            <name>CSE_CaseCloseNotification_AR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send an email when status equals to&quot;Fechado e cancelado&quot; o &quot;Fechado e resolvido&quot;.</description>
        <formula>(  $RecordType.DeveloperName=&apos;CSE_1_AccountAlteration_ARG&apos; ||  $RecordType.DeveloperName=&apos;CSE_2_AccountAlteration_URU&apos;  )  &amp;&amp;  ( ISPICKVAL(LAT_Status__c, &apos;Fechado e cancelado&apos;) || ISPICKVAL(LAT_Status__c, &apos;Fechado e resolvido&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CSE_WF03_UpdateRT_ARG</fullName>
        <actions>
            <name>CSE_RTUpdate2_ARG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the record type to &apos;Propuesta de Pagos_AR&apos; when LAT_Type__c equals ‘Propuesta de Pago’.</description>
        <formula>$RecordType.DeveloperName=&apos;CSE_WOPaymentProposal_AR&apos; &amp;&amp; ISPICKVAL(LAT_Type__c, &apos;Proposta de pagamento&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSE_WF04_UpdateRT_UY</fullName>
        <actions>
            <name>CSE_RTUpdate2_UY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the record type to &apos;Propuesta de Pagos_UY&apos; when Type equals ‘Propuesta de Pago’.</description>
        <formula>$RecordType.DeveloperName=&apos;CSE_WOPaymentProposal_UY&apos;  &amp;&amp;  ISPICKVAL(LAT_Type__c, &apos;Proposta de pagamento&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSE_WF05_UpdateRT_ARG</fullName>
        <actions>
            <name>CSE_RTUpdate3_ARG</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the record type to ‘Morosidad a encaminar a Legales_AR’ when Type equals ‘Morosidad a encaminar a Legales’.</description>
        <formula>$RecordType.DeveloperName=&apos;CSE_WOPaymentProposal_AR&apos;  &amp;&amp;  ISPICKVAL(LAT_Type__c, &apos;Overdue to attorneys&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CSE_WF06_UpdateRT_UY</fullName>
        <actions>
            <name>CSE_RTUpdate3_UY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates the record type to ‘Morosidad a encaminar a Legales_UY’ when Type equals ‘Morosidad a encaminar a Legales’.</description>
        <formula>$RecordType.DeveloperName=&apos;CSE_WOPaymentProposal_UY&apos;  &amp;&amp;  ISPICKVAL(LAT_Type__c, &apos;Overdue to attorneys&apos;)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Calcula valor devido</fullName>
        <actions>
            <name>Atualiza_valor_devido</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cliente inadimplente</fullName>
        <actions>
            <name>Cliente_inadimplente</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cliente inadimplente</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Condições definidas</fullName>
        <actions>
            <name>Atualiza_status_Canc_aprovado_cliente</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conferido_por_cond_cancel_defi</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_CancellationDefined__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Demanda de alteração de cadastro de cliente</fullName>
        <actions>
            <name>Atualiza_Status_Caso_Controladoria</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>altera_propriet_rio_Controladoria</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Após aprovações, este workflow captura o chamado que foi fechado por adm vendas ou credito e cobranca e reabre para Controladoria, que vai efetivar a alteração.</description>
        <formula>AND (  $RecordType.Name = &quot;Alteração de cadastro de clientes&quot;,  NOT(PRIORVALUE(LAT_IsClosed__c)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. transportadora&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. recebimento carga&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. tipo de frete&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. tipo de veículo&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. agendamento&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. paletização especial&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. e-mail da NFE&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. endereço faturamento&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. Acting format&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. nome fantasia&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. condição e instrumento de pagamento&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &quot;Alt. Regional de Vendas&quot;)),  NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. Bandeira&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. inscrição estadual&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. Organização&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. prioridade faturamento&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. processo EDI&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. razão social&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. unidade de negócio&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. informações de pedidos&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. cliente pai&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. dados bancários&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. descarga&apos;)), NOT(ISPICKVAL( LAT_Reason__c, &apos;Alt. janela de pedidos&apos;)), LAT_IsClosed__c,  OR (  ISPICKVAL(Priorvalue( LAT_Status__c), &quot;Em análise - Crédito e cobrança&quot;),  ISPICKVAL(Priorvalue( LAT_Status__c), &quot;Em análise - Planejamento Comercial&quot;),  ISPICKVAL(Priorvalue( LAT_Status__c), &quot;Em análise - Customer Service&quot;)  ),  NOT(ISPICKVAL(LAT_Status__c, &quot;Reprovado&quot;))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Distrato arquivado regional</fullName>
        <actions>
            <name>Conferido_por_arquivado_regional</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_TerminationFiledByRegional__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Distrato assinado diretoria</fullName>
        <actions>
            <name>Atualiza_status_Distrato_enc_regional</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conferido_por_ass_diretor</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Entregar_1_via_do_distrato_ao_cliente</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_TerminationSignedByTheBoard__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Distrato assinado pelo cliente</fullName>
        <actions>
            <name>Atualiza_status_Distrato_enc_coodenado</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conferido_por_distrato_enc_coordenador</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_TerminationSignedByTheCustomer__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Distrato assinado pelo coordenador</fullName>
        <actions>
            <name>Atualiza_status_Distrato_enc_gerente</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conferido_por_dist_ass_coordenador</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_TerminationSignedByTheCoordinator__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Distrato assinado pelo gerente</fullName>
        <actions>
            <name>Atualiza_status_Distrato_enc_diretoria</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conferido_por_ass_gerente</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_TerminationSignedByTheManager__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Distrato entregue</fullName>
        <actions>
            <name>Atualiza_status_cancel_aprovado_client</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Conferido_por_distrato_entregue</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_TerminationDeliveredPSubscribeClient__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Encerra demanda com status Distrato entregue p cliente</fullName>
        <actions>
            <name>Atualiza_status_Distrato_ent_cliente</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Cancelamento de contrato</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_IsClosed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LAT_BR_ CSE_WF01_UpdateSubject</fullName>
        <actions>
            <name>LAT_BR_CSE_UpdateSubject</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$RecordType.DeveloperName= &apos;LAT_BR_ContractProrogation&apos;</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_CSE_WF01_ChangeRT</fullName>
        <actions>
            <name>LAT_MX_CSE_UpdateRT</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Change the RT when the case is closed</description>
        <formula>($RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationStatistical&apos; || $RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationCreditAndCollections&apos; || $RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationLegal&apos; || $RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationLogistics&apos;) &amp;&amp; ( ISPICKVAL(LAT_Status__c, &apos;Fechado e cancelado&apos;) || ISPICKVAL(LAT_Status__c, &apos;Fechado e resolvido&apos;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>LAT_MX_CSE_WF02_CaseCloseEmailAlert</fullName>
        <actions>
            <name>LAT_MX_CSE_CloseCase_AccountAlteration</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends and e-mail alert when the Status of the Case changes to &apos;Fechado e resolvido&apos;</description>
        <formula>($RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationStatistical&apos; || $RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationCreditAndCollections&apos; || $RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationLegal&apos; || $RecordType.DeveloperName=&apos;LAT_MX_CSE_AccountAlterationLogistics&apos;) &amp;&amp; ISPICKVAL(LAT_Status__c, &apos;Fechado e resolvido&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Proposta de renovação</fullName>
        <actions>
            <name>Providenciar_proposta_de_renovacao_de_contrato</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.LAT_IsClosed__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Status__c</field>
            <operation>equals</operation>
            <value>Aprovado</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Proposta de renovação</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Proposta de renovação não aprovada cliente</fullName>
        <actions>
            <name>Proposta_de_renova_o_n_o_aprovada_pelo_cliente</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Case__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Proposta de renovação</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_ReasonForNotApproved__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Case__c.LAT_Status__c</field>
            <operation>equals</operation>
            <value>Não aprovado</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Cliente_inadimplente</fullName>
        <assignedToType>owner</assignedToType>
        <description>Um cliente foi identificado como inadimplente. Por favor analise a demanda, relacionada acima, para efetuar a negociação com o mesmo.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Cliente inadimplente</subject>
    </tasks>
    <tasks>
        <fullName>Entregar_1_via_do_distrato_ao_cliente</fullName>
        <assignedToType>owner</assignedToType>
        <description>Entregar 1ª via do distrato ao cliente.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Entregar 1ª via do distrato ao cliente</subject>
    </tasks>
    <tasks>
        <fullName>Providenciar_assinatura_do_cliente</fullName>
        <assignedToType>owner</assignedToType>
        <description>Solicitar ao cliente a assinatura de distrato do contrato relacionado acima.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Providenciar assinatura do cliente</subject>
    </tasks>
    <tasks>
        <fullName>Providenciar_proposta_de_renovacao_de_contrato</fullName>
        <assignedToType>owner</assignedToType>
        <description>Providenciar proposta de renovação de contrato.</description>
        <dueDateOffset>1</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>LAT_Case__c.LAT_ClosedDate__c</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Providenciar proposta de renovação de contrato</subject>
    </tasks>
    <tasks>
        <fullName>Solicitar_ao_cliente_aprova_o_de_cancelamento_de_contrato</fullName>
        <assignedToType>owner</assignedToType>
        <description>Solicitar ao cliente a aprovação das cláusulas de cancelamento de contrato relacionadas à demanda acima.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Solicitar ao cliente aprovação de cancelamento de contrato</subject>
    </tasks>
</Workflow>
