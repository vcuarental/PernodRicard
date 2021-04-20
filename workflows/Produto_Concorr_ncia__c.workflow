<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alerta_de_e_mail_fora_do_range</fullName>
        <description>Alerta de e-mail fora do range</description>
        <protected>false</protected>
        <recipients>
            <recipient>prbrazil_soa@service.pernod-ricard.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Modelos_Pernod/LAT_BR2_Alerta_de_pre_os_de_range</template>
    </alerts>
    <fieldUpdates>
        <fullName>Atualiza_campo_range</fullName>
        <field>Fora_do_Range_Demantra__c</field>
        <literalValue>1</literalValue>
        <name>Atualiza campo range</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Verificar range</fullName>
        <actions>
            <name>Alerta_de_e_mail_fora_do_range</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Atualiza_campo_range</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Verifica se está dentro do range.</description>
        <formula>Pre_o_Garrafa_Pernod__c  &gt;  Range_Demantra_AT__c     ||   Pre_o_Garrafa_Pernod__c  &lt;  Range_Demantra_DE__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
