<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alerta_para_elabora_o_de_condi_es_contratuais</fullName>
        <description>Alerta para elaboração de condições contratuais</description>
        <protected>false</protected>
        <recipients>
            <recipient>prbrazil_soa@service.pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Elaborar_Condi_oes_de_clausulas_de_cancelamento_de_contrato</template>
    </alerts>
    <alerts>
        <fullName>Alteracao_de_contrato_rejeitada</fullName>
        <description>Alteração de contrato rejeitada</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Alteracao_de_contrato_rejeitada</template>
    </alerts>
    <alerts>
        <fullName>Alteracao_do_contrato</fullName>
        <description>Alteração do contrato - Efetivada</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Gerente_Regional__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente_de_area__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Alteracao_de_contrato_Efetivada</template>
    </alerts>
    <alerts>
        <fullName>Alteracao_do_contrato_off</fullName>
        <description>Alteração do contrato - off</description>
        <protected>false</protected>
        <recipients>
            <recipient>prbrazil_soa@service.pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Alteracao_de_contrato_aprovada</template>
    </alerts>
    <alerts>
        <fullName>Aprovacao_solicitacao_de_assinatura_de_contratos</fullName>
        <description>Aprovação solicitação de assinatura de contratos.</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Assinatura_de_novo_contrato_aprovada_prb</template>
    </alerts>
    <alerts>
        <fullName>Cancelamento_do_contrato</fullName>
        <description>Cancelamento do contrato - Efetivada</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Gerente_Regional__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente_de_area__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Cancelamento_de_contrato_Efetivada</template>
    </alerts>
    <alerts>
        <fullName>Contrato_Finalizado</fullName>
        <description>Contrato Finalizado</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Gerente_Regional__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente_de_area__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Contrato_finalizado</template>
    </alerts>
    <alerts>
        <fullName>Contrato_ativado</fullName>
        <description>Contrato ativado</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Gerente_Regional__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente_de_area__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Contrato_ativado</template>
    </alerts>
    <alerts>
        <fullName>Contrato_ativo_vencendo_hoje</fullName>
        <description>Contrato ativo vencendo hoje</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Contrato_vencido</template>
    </alerts>
    <alerts>
        <fullName>Contrato_do_concorrente_a_expirar</fullName>
        <description>Contrato do concorrente a expirar</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Contrato_do_concorrente_a_expirar</template>
    </alerts>
    <alerts>
        <fullName>Contrato_prorrogado</fullName>
        <description>Contrato prorrogado</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <recipients>
            <field>Gerente_Regional__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Gerente_de_area__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/Contrato_prorrogado</template>
    </alerts>
    <fieldUpdates>
        <fullName>Aditamento_enc_cliente</fullName>
        <field>Status__c</field>
        <name>Aditamento enc cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Aditamento_gerado_pelo_jur_dico</fullName>
        <field>Aditamento_gerado__c</field>
        <literalValue>1</literalValue>
        <name>Aditamento gerado pelo jurídico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_Status_contrato_Cancelado</fullName>
        <field>Status__c</field>
        <literalValue>Cancelado</literalValue>
        <name>Alt Status contrato - Cancelado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_contrato_Ativo</fullName>
        <field>Status__c</field>
        <literalValue>Ativo</literalValue>
        <name>Alt status contrato - Ativo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_contrato_Sol_Cancelamento</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação de cancelamento de contrato</literalValue>
        <name>Alt status contrato - Sol Cancelamento</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_contrato_nao_aprovado</fullName>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>Alt status contrato - não aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_Opp_aprov_PRB</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Oportunidade aprovada pela PRB</literalValue>
        <name>Alt status proc - Opp aprov PRB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_Opp_aprovada_PRB</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Oportunidade aprovada pela PRB</literalValue>
        <name>Alt status proc - Opp aprovada PRB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_adit_enc_aprov</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Aditamento encaminhado para aprovações</literalValue>
        <name>Alt status proc - adit enc aprov</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_adit_enc_consult</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Aditamento encaminhado para o Consultor</literalValue>
        <name>Alt status proc - adit enc consult</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_altera_o_de_contrato</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Alteração enviada para aprovação</literalValue>
        <name>Alt status proc - alteração de contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_aprova_altera_contrat</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Alteração enviada para aprovação</literalValue>
        <name>Alt status proc - aprova altera contrat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_cancel_enc_coordenador</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação de cancelamento encaminhada para o Coordenador</literalValue>
        <name>Alt status proc - cancel enc coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_cancel_enc_geren_area</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação de cancelamento encaminhada para o Gerente de Área</literalValue>
        <name>Alt status proc - cancel enc geren area</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_cancel_enc_gerente</fullName>
        <field>Status_do_processo__c</field>
        <name>Alt status proc - cancel enc gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_cancel_enc_juridico</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação encaminhada para o Jurídico</literalValue>
        <name>Alt status proc - cancel enc juridico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_cla_enc_p_gerente</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Cláusulas encaminhadas para o Gerente</literalValue>
        <name>Alt status proc - cla enc p gerente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_distr_enc_p_aprova_es</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Distrato encaminhado para aprovações</literalValue>
        <name>Alt status proc - distr enc p aprovações</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_distr_enc_p_consultor</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Distrato encaminhado para o Consultor</literalValue>
        <name>Alt status proc - distr enc p consultor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_distrato_nao_aprovado</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Distrato não aprovado</literalValue>
        <name>Alt status proc - distrato não aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_em_an_lise_p_renova_o</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Em análise para renovação</literalValue>
        <name>Alt status proc - em análise p renovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_enc_aprov_juridico</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Encaminhado para o Jurídico</literalValue>
        <name>Alt status proc - enc aprov juridico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_enc_negocia_o_cliente</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Encaminhado para negociação com o cliente</literalValue>
        <name>Alt status proc - enc negociação cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_estudo_em_aprova_o</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Estudo encaminhado para aprovação</literalValue>
        <name>Alt status proc - estudo em aprovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_estudo_em_aprova_o1</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Estudo encaminhado para aprovação</literalValue>
        <name>Alt status proc - estudo em aprovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_reprova_altera_contrat</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Proposta não aprovada</literalValue>
        <name>Alt status proc - reprova altera contrat</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_sol_devolv_coordenador</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação devolvida para o Coordenador</literalValue>
        <name>Alt status proc - sol devolv coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_sol_devolv_p_consultor</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação devolvida para o Consultor</literalValue>
        <name>Alt status proc - sol devolv p consultor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_sol_elabora_distrato</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação de elaboração do distrato</literalValue>
        <name>Alt status proc - sol elabora distrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_status_proc_sol_enc_juridico</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Solicitação encaminhada para o Jurídico</literalValue>
        <name>Alt status proc - sol enc jurídico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_tipo_reg_alt_contrato_off</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Alteracao_de_contrato_aprovada_Off_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Alt tipo reg - alt contrato off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_tipo_reg_cancel_contrato_off</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Cancelamento_de_contrato_aprovado_off</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Alt tipo reg - cancel contrato off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_tipo_reg_cancel_contrato_on</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Cancelamento_de_contrato_aprovado_on</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Alt tipo reg - cancel contrato on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Alt_tipo_reg_contrato_off_ativo</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_Off_Trade_ativo</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Alt tipo reg - contrato off ativo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AlteraStatus</fullName>
        <field>Status__c</field>
        <literalValue>Em elaboração</literalValue>
        <name>Altera status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AlteraTipoDeRegistroAssinatura1</fullName>
        <description>Altera tipo registro &apos;On trade - Contrato não aprovado&apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>OnTradeContratoNaoAprovado</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo registro assinatura 1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AlteraTipoDeRegistroAssinatura2</fullName>
        <description>Altera tipo registro &apos;Assinatura de contrato com aprovação - On Trade &apos;</description>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_com_aprovacao</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo registro assinatura 2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_demanda01</fullName>
        <field>demanda01_Aprovado__c</field>
        <literalValue>0</literalValue>
        <name>Altera demanda01</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_demanda02</fullName>
        <field>demanda02_Aprovado__c</field>
        <literalValue>0</literalValue>
        <name>Altera demanda02</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Ativo</fullName>
        <field>Status__c</field>
        <literalValue>Ativo</literalValue>
        <name>Altera status - Ativo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_Em_cancelamento</fullName>
        <field>Status__c</field>
        <literalValue>Em cancelamento</literalValue>
        <name>Altera status - Em cancelamento</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_contrato_EM_APROVACAO</fullName>
        <field>Status__c</field>
        <literalValue>Em aprovação</literalValue>
        <name>Altera status contrato - EM APROVAÇÃO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_contrato_EM_APROVA_O</fullName>
        <field>Status__c</field>
        <literalValue>Em aprovação</literalValue>
        <name>Altera status contrato - EM APROVAÇÃO</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_status_rejeitado_juridico</fullName>
        <field>Status__c</field>
        <name>Altera status - rejeitado juridico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_Ativa_o_de_co</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Ativacao_de_contrato</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro - Ativação de co</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_Cancel_aprov</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Cancelamento_de_contrato_aprovado_on</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro - Cancel aprov</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_On_Trade</fullName>
        <description>Altera o tipo de registro do contrato para &quot;Assinatura de contrato - On Trade&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>Ativacao_de_contrato</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro On Trade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_aprovacao_off</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_com_aprovacao_Off_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro - aprovação off</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_aprovacao_on</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_com_aprovacao</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro - aprovação on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_assinatura</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_aprovada</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro assinatura</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_assinatura1</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Alteracao_de_contrato_aprovada_On_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro assinatura</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_de_registro_para_aprova_o</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_com_aprovacao</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo de registro para aprovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_reg_Alt_aprov_contrato_on</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Alteracao_de_contrato_aprovada_On_Trade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo reg - Alt aprov contrato on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_reg_Contrato_off_aprova</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Assinatura_de_contrato_Off_Trade_aprovado</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo reg - Contrato off aprova</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Altera_tipo_registro_alt_contrato_on</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Alteracao_de_contrato_on</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Altera tipo registro - alt contrato on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Ativa_altera_o_de_contrato</fullName>
        <field>Status__c</field>
        <literalValue>Ativo</literalValue>
        <name>Ativa alteração de contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>AtualizaStatusEmElaboracao</fullName>
        <description>Atualiza status do contrato para &quot;Em elaboração&quot;.</description>
        <field>Status__c</field>
        <literalValue>Em elaboração</literalValue>
        <name>AtualizaStatusEmElaboracao</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_fase_Contrato</fullName>
        <field>Fase__c</field>
        <literalValue>Contrato</literalValue>
        <name>Atualiza fase - Contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_fase_Oportunidade</fullName>
        <field>Fase__c</field>
        <literalValue>Oportunidade</literalValue>
        <name>Atualiza fase - Oportunidade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_fase_Oportunidade1</fullName>
        <field>Fase__c</field>
        <literalValue>Oportunidade</literalValue>
        <name>Atualiza fase - Oportunidade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_fase_estudo</fullName>
        <field>Fase__c</field>
        <literalValue>Estudo</literalValue>
        <name>Atualiza fase - estudo</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_o_campo_fluxo011</fullName>
        <field>Fluxo01_Aprovado__c</field>
        <literalValue>1</literalValue>
        <name>Atualiza o campo fluxo01</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_o_campo_fluxo02</fullName>
        <field>Fluxo02_Aprovado__c</field>
        <literalValue>1</literalValue>
        <name>Atualiza o campo fluxo02</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_prazo_notifica_o</fullName>
        <field>OwnerExpirationNotice__c</field>
        <literalValue>60 Days</literalValue>
        <name>Atualiza prazo notificação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Adit_entregue_cliente</fullName>
        <field>Status__c</field>
        <name>Atualiza status - Adit entregue cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Alt_enviada_p_aprov</fullName>
        <field>Status__c</field>
        <literalValue>Em aprovação</literalValue>
        <name>Atualiza status - Alt enviada p/ aprov</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Enc_para_assinaturas</fullName>
        <field>Status__c</field>
        <name>Atualiza status - Enc para assinaturas</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Enc_para_coordenador</fullName>
        <field>Status__c</field>
        <name>Atualiza status - Enc para coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_Opp_aprovada_PRB</fullName>
        <field>Status__c</field>
        <name>Atualiza status - Opp aprovada PRB</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_adit_ass_cliente</fullName>
        <field>Status__c</field>
        <name>Atualiza status - adit ass cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_adit_ass_enc_consultor</fullName>
        <field>Status__c</field>
        <name>Atualiza status - adit ass enc consultor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_adit_ass_enc_p_regiona</fullName>
        <field>Status__c</field>
        <name>Atualiza status - adit ass enc p regiona</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_adit_enc_consultor</fullName>
        <field>Status__c</field>
        <name>Atualiza status - adit enc consultor</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_aprovado_cliente</fullName>
        <field>Status__c</field>
        <name>Atualiza status - aprovado cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_ass_de_trade</fullName>
        <field>Status__c</field>
        <name>Atualiza status - ass de trade</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_ass_enc_coordenador</fullName>
        <field>Status__c</field>
        <name>Atualiza status - ass enc coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_contrato_Juridico</fullName>
        <field>Status__c</field>
        <name>Atualiza status contrato - Jurídico</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_contrato_aditamento</fullName>
        <field>Status__c</field>
        <name>Atualiza status contrato - aditamento</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_contrato_finalizado</fullName>
        <field>Status__c</field>
        <literalValue>Finalizado</literalValue>
        <name>Atualiza status - contrato finalizado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_em_analise_renova_o</fullName>
        <field>Status__c</field>
        <name>Atualiza status - em análise renovação</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_encaminhado_assinatura</fullName>
        <field>Status__c</field>
        <name>Atualiza status - encaminhado assinatura</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_enviado_assist_reg</fullName>
        <field>Status__c</field>
        <name>Atualiza status - enviado assist reg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_enviado_procurador_reg</fullName>
        <field>Status__c</field>
        <name>Atualiza status - enviado procurador reg</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_n_o_aprovado</fullName>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>Atualiza status - não aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_nao_aprovado</fullName>
        <field>Status__c</field>
        <literalValue>Não aprovado</literalValue>
        <name>Atualiza status - não aprovado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_proc_opp_aprovada_pr</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Proposta não aprovada</literalValue>
        <name>Atualiza status proc - opp ñ aprovada pr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_proc_opp_aprovada_pr1</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Proposta não aprovada</literalValue>
        <name>Atualiza status proc - opp ñ aprovada pr</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_proc_opp_aprovada_prb</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Oportunidade aprovada pela PRB</literalValue>
        <name>Atualiza status proc - opp aprovada prb</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Atualiza_status_proc_opp_aprovada_prb1</fullName>
        <field>Status_do_processo__c</field>
        <literalValue>Oportunidade aprovada pela PRB</literalValue>
        <name>Atualiza status proc - opp aprovada prb</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_adit_ass_cliente</fullName>
        <field>Conferido_por_assinatura_alteracao__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - adit ass cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_adit_enc_ass_cliente</fullName>
        <field>Conferido_por_coordenador__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - adit enc ass cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_adit_entregue_ao_cliente</fullName>
        <field>Conferido_por_enc_ass__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - adit entregue ao cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_aditamento_gerado</fullName>
        <field>Conferido_por_doc_ok__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - aditamento gerado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_aditamento_registrado</fullName>
        <field>Conferido_por_ass_procurador__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - aditamento registrado</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_alt_ass_de_contrato</fullName>
        <field>Conferido_por_apro_cli__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - alt ass de contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_aprovado_cliente</fullName>
        <field>Conferido_por_adit_enc_cliente__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - aprovado cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_ass_coordenador</fullName>
        <field>Conferido_por_adit_entregue_ao_cliente__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - ass. coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_ass_gerente_procurador</fullName>
        <field>Conferido_por_ass_diretoria__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - ass gerente (procurador)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_ass_proc_regional</fullName>
        <field>Conferido_por_adt_ass_cliente__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - ass proc regional</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_assinado_cliente</fullName>
        <field>Conferido_por_ass_cliente__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - assinado cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_assinatura_contrato</fullName>
        <field>Conferido_por_aditamento_gerado__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - assinatura contrato</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_diretoria</fullName>
        <field>Conferido_por_ass_gerente_procurador__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - diretoria</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_documentacao_ok</fullName>
        <field>Conferido_por_ass_cliente__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - documentação ok</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Conferido_por_pgto_1_parcela</fullName>
        <field>Conferido_por_aditamento_registrado__c</field>
        <formula>$User.FirstName &amp; &quot; &quot; &amp; $User.LastName &amp; &quot; em &quot; &amp; MID(text((NOW()-3/24)), 9,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 6,2) &amp; &quot;/&quot; &amp; MID(text((NOW()-3/24)), 1,4) &amp; MID(text((NOW()-3/24)), 11,6)</formula>
        <name>Conferido por - pgto 1ª parcela</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ContratoAlteraTipoRegistroAlteracaoOff</fullName>
        <description>Altera o tipo de registro do contrato para &quot;AlteracaoContratoAtivoOffTrade&quot;.</description>
        <field>RecordTypeId</field>
        <lookupValue>AlteracaoContratoAtivoOffTrade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ContratoAlteraTipoRegistroAlteracaoOff</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ContratoAlteraTipoRegistroAlteracaoOn</fullName>
        <description>Altera o tipo de registro de contrato para &quot;AlteracaoContratoAtivoOnTrade&quot;</description>
        <field>RecordTypeId</field>
        <lookupValue>AlteracaoContratoAtivoOnTrade</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>ContratoAlteraTipoRegistroAlteracaoOn</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>LAT_BR_RealValidityDate</fullName>
        <field>LAT_BR_RealValidityDate__c</field>
        <formula>EndDate__c</formula>
        <name>LAT_BR_RealValidityDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_aprovado_pelo_cliente</fullName>
        <field>Aprovado_pelo_cliente__c</field>
        <literalValue>0</literalValue>
        <name>Limpa aprovado pelo cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_assinatua_proc_regional</fullName>
        <field>Assinatura_procurador_regional__c</field>
        <literalValue>0</literalValue>
        <name>Limpa assinatua proc regional</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_assinatura_coordenador</fullName>
        <field>Assinatura_coordenador__c</field>
        <literalValue>0</literalValue>
        <name>Limpa assinatura coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_conferido_aprov_cliente</fullName>
        <field>Conferido_por_adit_enc_cliente__c</field>
        <name>Limpa conferido aprov cliente</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_conferido_assinatura_coordenador</fullName>
        <field>Conferido_por_adit_entregue_ao_cliente__c</field>
        <name>Limpa conferido assinatura coordenador</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_conferido_assinatura_proc_regional</fullName>
        <field>Conferido_por_adt_ass_cliente__c</field>
        <name>Limpa assinatura proc regional</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_conferido_enc_assinatura</fullName>
        <field>Conferido_por_aditamento_gerado__c</field>
        <name>Limpa conferido enc assinatura</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_conferido_pgto_1_parcela</fullName>
        <field>Conferido_por_aditamento_registrado__c</field>
        <name>Limpa conferido pgto 1ª parcela</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_encaminhado_para_assinatura</fullName>
        <field>Encaminhado_para_assinatura__c</field>
        <literalValue>0</literalValue>
        <name>Limpa encaminhado para assinatura</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_pgto_1_parcela</fullName>
        <field>Pagamento_1a_parcela__c</field>
        <literalValue>0</literalValue>
        <name>Limpa pgto 1ª parcela</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_signatario</fullName>
        <field>Signatario_da_empresa__c</field>
        <name>Limpa signatário</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_signatario2</fullName>
        <field>Signatario_da_empresa_2__c</field>
        <name>Limpa signatário</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Limpa_trigger_on</fullName>
        <field>trigger_on__c</field>
        <literalValue>0</literalValue>
        <name>Limpa trigger on</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>finalizado_60_dias</fullName>
        <description>finalizado 60 dias</description>
        <field>finalizado_60_dias__c</field>
        <literalValue>1</literalValue>
        <name>finalizado 60 dias</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Alerta ativação de contrato</fullName>
        <actions>
            <name>Contrato_ativado</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status_do_processo__c</field>
            <operation>equals</operation>
            <value>Encaminhado para o Assistente da Regional</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Motivo_de_cancelamento_do_contrato__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Ativo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Alerta ativação de contrato - futuro</fullName>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status_do_processo__c</field>
            <operation>equals</operation>
            <value>Encaminhado para o Assistente da Regional</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Motivo_de_cancelamento_do_contrato__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Ativo</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contrato_ativado</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Altera_status_Ativo</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Inicio_da_vigencia__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - Alteração de contrato - OFF</fullName>
        <active>true</active>
        <formula>AND (ISPICKVAL(Status_do_processo__c , &apos;Estudo de alteração de contrato&apos;)  ,  (ISPICKVAL(Account__r.Channel__c , &apos;Off Trade&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Altera tipo de registro - Alteração de contrato - ON</fullName>
        <actions>
            <name>Altera_tipo_registro_alt_contrato_on</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(         ISPICKVAL(Status_do_processo__c, &apos;Estudo de alteração de contrato&apos;) ,                                               ISPICKVAL( Account__r.Channel__c ,&apos;On Trade&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Alteração de contrato - Efetivada</fullName>
        <actions>
            <name>Alteracao_do_contrato</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status_do_processo__c</field>
            <operation>equals</operation>
            <value>Encaminhado para assinaturas</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Ativa alteração de contrato</fullName>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Alteração de contrato,Alteração de contrato aprovada</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>notEqual</operation>
            <value>Em elaboração,Ativo,Cancelado,Não aprovado</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Status_do_processo__c</field>
            <operation>equals</operation>
            <value>Encaminhado para assinaturas</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Data_de_inicio_da_vigencia_da_alteracao__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Ativa_altera_o_de_contrato</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.StartDate__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Ativa contrato</fullName>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Aprovado</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alt_status_contrato_Ativo</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Inicio_da_vigencia__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Atualiza notificação</fullName>
        <active>true</active>
        <formula>True</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Bloqueia contrato aditado%2C finalizado e cancelado</fullName>
        <actions>
            <name>Altera_tipo_de_registro_assinatura</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelado,Aditado,Finalizado</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Bloqueia contrato finalizado</fullName>
        <actions>
            <name>Altera_tipo_de_registro_assinatura</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Finalizado</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Cancelamento de contrato - Distrato</fullName>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status_do_processo__c</field>
            <operation>equals</operation>
            <value>Distrato encaminhado para assinaturas</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alt_Status_contrato_Cancelado</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Data_de_vigencia_do_distrato__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Cancelamento de contrato - Efetivada</fullName>
        <actions>
            <name>Cancelamento_do_contrato</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status_do_processo__c</field>
            <operation>equals</operation>
            <value>Distrato encaminhado para assinaturas</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contrato - ON Ativo</fullName>
        <actions>
            <name>Altera_tipo_de_registro_Ativa_o_de_co</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   	OR ( 		ISPICKVAL( Status__c , &apos;Ativo&apos;) ,   		ISPICKVAL( Status__c , &apos;Aprovado&apos;) 		) , 	ISPICKVAL(Motivo_de_cancelamento_do_contrato__c ,&apos;&apos;) , 	OR ( 		ISPICKVAL( Status_do_processo__c,&apos;Encaminhado para o Assistente da Regional&apos;), 		ISPICKVAL( Status_do_processo__c, &apos;Encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Aditamento entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Processo finalizado&apos;)  		) , 	ISPICKVAL(Account__r.Channel__c , &apos;On Trade&apos;), 	ISBLANK(Data_de_inicio_da_vigencia_da_alteracao__c) 		 	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contrato - Off Ativo</fullName>
        <actions>
            <name>Alt_tipo_reg_contrato_off_ativo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   	OR ( 		ISPICKVAL( Status__c , &apos;Ativo&apos;) ,   		ISPICKVAL( Status__c , &apos;Aprovado&apos;) 		) , 	ISPICKVAL(Motivo_de_cancelamento_do_contrato__c ,&apos;&apos;) , 	OR ( 		ISPICKVAL( Status_do_processo__c,&apos;Encaminhado para o Assistente da Regional&apos;), 		ISPICKVAL( Status_do_processo__c, &apos;Encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Aditamento entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Processo finalizado&apos;)  		) , 	ISPICKVAL(Account__r.Channel__c , &apos;Off Trade&apos;), 	ISBLANK(Data_de_inicio_da_vigencia_da_alteracao__c) 		 	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contrato Alteração Ativo - OFF TRADE</fullName>
        <actions>
            <name>ContratoAlteraTipoRegistroAlteracaoOff</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   	OR ( 		ISPICKVAL( Status__c , &apos;Ativo&apos;) ,   		ISPICKVAL( Status__c , &apos;Aprovado&apos;) 		) , 	ISPICKVAL(Motivo_de_cancelamento_do_contrato__c ,&apos;&apos;) , 	OR ( 		ISPICKVAL( Status_do_processo__c,&apos;Encaminhado para o Assistente da Regional&apos;), 		ISPICKVAL( Status_do_processo__c, &apos;Encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Aditamento entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Processo finalizado&apos;)  		) , 	ISPICKVAL(Account__r.Channel__c , &apos;Off Trade&apos;), 	 NOT(ISBLANK(Data_de_inicio_da_vigencia_da_alteracao__c)) 		 	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contrato Alteração Ativo - ON TRADE</fullName>
        <actions>
            <name>ContratoAlteraTipoRegistroAlteracaoOn</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(   	OR ( 		ISPICKVAL( Status__c , &apos;Ativo&apos;) ,   		ISPICKVAL( Status__c , &apos;Aprovado&apos;) 		) , 	ISPICKVAL(Motivo_de_cancelamento_do_contrato__c ,&apos;&apos;) , 	OR ( 		ISPICKVAL( Status_do_processo__c,&apos;Encaminhado para o Assistente da Regional&apos;), 		ISPICKVAL( Status_do_processo__c, &apos;Encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato encaminhado para assinaturas&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Distrato entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Aditamento entregue para o cliente&apos;) , 		ISPICKVAL( Status_do_processo__c, &apos;Processo finalizado&apos;)  		) , 	ISPICKVAL(Account__r.Channel__c , &apos;On Trade&apos;), 	NOT(ISBLANK(Data_de_inicio_da_vigencia_da_alteracao__c)) 		 	)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Contrato encerrado contrapartida cumprida</fullName>
        <actions>
            <name>Atualiza_status_contrato_finalizado</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Data_de_cumprimento_contrapartidas__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Contrato finalizado</fullName>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Status__c</field>
            <operation>equals</operation>
            <value>Ativo</value>
        </criteriaItems>
        <criteriaItems>
            <field>LAT_Contract__c.Data_de_cumprimento_contrapartidas__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contrato_Finalizado</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Atualiza_status_contrato_finalizado</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Data_de_cumprimento_contrapartidas__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Contrato_Finalizado</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Atualiza_status_contrato_finalizado</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Calculo_de_data__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Contrato prorrogado</fullName>
        <actions>
            <name>Contrato_prorrogado</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Data_de_cumprimento_contrapartidas__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Enviar estudo para aprovação - off</fullName>
        <actions>
            <name>Altera_tipo_de_registro_aprovacao_off</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Atualiza_fase_estudo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>and (             ISPICKVAL( Account__r.Channel__c , &apos;Off Trade&apos;),           ISPICKVAL(Status_do_processo__c , &apos;Estudo em elaboração&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Enviar estudo para aprovação - on</fullName>
        <actions>
            <name>Altera_tipo_de_registro_aprovacao_on</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Atualiza_fase_estudo</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(                  NOT(ISBLANK(Valor_do_contrato__c)),   ISPICKVAL( Status_do_processo__c , &apos;Estudo em elaboração&apos;),   ISPICKVAL(  Account__r.Channel__c  , &apos;On Trade&apos;) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Expiração contrato concorrente</fullName>
        <active>true</active>
        <criteriaItems>
            <field>LAT_Contract__c.Termino_da_vigencia__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contrato_do_concorrente_a_expirar</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Termino_da_vigencia__c</offsetFromField>
            <timeLength>-90</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>LAT_BR_ CT_WF01_UpdateRealValidityDate</fullName>
        <actions>
            <name>LAT_BR_RealValidityDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>(  $RecordType.DeveloperName=&apos;Alteracao_de_contrato_OFF&apos; ||  $RecordType.DeveloperName=&apos;Alteracao_de_contrato_on&apos; ||  $RecordType.DeveloperName=&apos;AlteracaoContratoAtivoOffTrade&apos; || $RecordType.DeveloperName=&apos;AlteracaoContratoAtivoOnTrade&apos; || $RecordType.DeveloperName=&apos;Alteracao_de_contrato_aprovada_Off_Trade&apos; ||  $RecordType.DeveloperName=&apos;Alteracao_de_contrato_aprovada_On_Trade&apos; ||  $RecordType.DeveloperName=&apos;Assinatura_de_contrato_Off_Trade_aprovado&apos; ||  $RecordType.DeveloperName=&apos;Assinatura_de_contrato_Off_Trade&apos;  || $RecordType.DeveloperName=&apos;Assinatura_de_contrato_Off_Trade_ativo&apos; ||  $RecordType.DeveloperName=&apos;Assinatura_de_contrato&apos; ||  $RecordType.DeveloperName=&apos;Assinatura_de_contrato_aprovada&apos;||  $RecordType.DeveloperName=&apos;Assinatura_de_contrato_com_aprovacao_Off_Trade&apos; ||  $RecordType.DeveloperName=&apos;Assinatura_de_contrato_com_aprovacao&apos; ||  $RecordType.DeveloperName=&apos;Ativacao_de_contrato&apos; ||  $RecordType.DeveloperName=&apos;Cancelamento_de_contrato_Off_Trade&apos;||  $RecordType.DeveloperName=&apos;Cancelamento_de_contrato_On_Trade&apos; ||  $RecordType.DeveloperName=&apos;Cancelamento_de_contrato_aprovado_off&apos; ||  $RecordType.DeveloperName=&apos;Cancelamento_de_contrato_aprovado_on&apos; ||  $RecordType.DeveloperName=&apos;OnTradeContratoNaoAprovado&apos;  )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Limpa trigger on</fullName>
        <actions>
            <name>Limpa_trigger_on</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>trigger_on__c</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ReativaçãoContrato</fullName>
        <actions>
            <name>AlteraStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>AlteraTipoDeRegistroAssinatura2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Altera_demanda01</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Altera_demanda02</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Altera tipo registro &apos;On trade - Contrato não aprovado&apos; en reativação Contrato</description>
        <formula>$RecordType.DeveloperName=&apos;OnTradeContratoNaoAprovado&apos; &amp;&amp; PRIORVALUE(RecordTypeId)==RecordTypeId</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Vencimento do contrato</fullName>
        <active>true</active>
        <formula>ISPICKVAL(Status__c, &apos;Ativado&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Alt_status_proc_em_an_lise_p_renova_o</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>LAT_Contract__c.Calculo_de_data__c</offsetFromField>
            <timeLength>-60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>finalizado 60 dias</fullName>
        <actions>
            <name>finalizado_60_dias</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Marcar o campo quando passar 60 dias da data de termino do contrato</description>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>LAT_Contract__c.Calculo_de_data__c</offsetFromField>
            <timeLength>60</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <tasks>
        <fullName>Contrato_aprovado_para_apresentar_ao_cliente</fullName>
        <assignedToType>owner</assignedToType>
        <description>Informamos que sua solicitação de assinatura de novo contrato foi aprovada para apresentação ao respectivo cliente.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Contrato aprovado para apresentar ao cliente</subject>
    </tasks>
    <tasks>
        <fullName>Entregar_aditamento_ao_cliente</fullName>
        <assignedToType>owner</assignedToType>
        <description>Aditamento registrado na regional, entregar 1ª via ao cliente.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Entregar aditamento ao cliente</subject>
    </tasks>
    <tasks>
        <fullName>Expiracao_do_contrato_da_concorrencia</fullName>
        <assignedToType>owner</assignedToType>
        <description>Contrato da concorrência expirará dentro de 60 dias. Para visualizar as informações do mesmo, clique no link relacionado.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>LAT_Contract__c.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Expiração contrato da concorrência</subject>
    </tasks>
    <tasks>
        <fullName>Imprimir_o_aditamento_e_colher_a_assinatura_do_cliente</fullName>
        <assignedToType>owner</assignedToType>
        <description>Imprimir 3 vias do aditamento, colher a assinatura do cliente, reconhecimento de firma e documentação complementar se necessário.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Imprimir o aditamento e colher a assinatura do cliente</subject>
    </tasks>
    <tasks>
        <fullName>Solicitar_a_aprova_o_de_renova_o_de_contrato</fullName>
        <assignedToType>owner</assignedToType>
        <description>Solicitar a aprovação de renovação do contrato relacionado acima.</description>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Não iniciado</status>
        <subject>Solicitar a aprovação de renovação de contrato</subject>
    </tasks>
</Workflow>
